From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC v4 net-next 0/5] virtio_net: enabling tx interrupts
Date: Tue, 02 Dec 2014 03:23:20 +0008
Message-ID: <1417490120.4405.2@smtp.corp.redhat.com>
References: <1417429028-11971-1-git-send-email-jasowang@redhat.com>
	<20141201104223.GB16108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: pagupta@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141201104223.GB16108@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On Mon, Dec 1, 2014 at 6:42 PM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> On Mon, Dec 01, 2014 at 06:17:03PM +0800, Jason Wang wrote:
>>  Hello:
>>  
>>  We used to orphan packets before transmission for virtio-net. This 
>> breaks
>>  socket accounting and can lead serveral functions won't work, e.g:
>>  
>>  - Byte Queue Limit depends on tx completion nofication to work.
>>  - Packet Generator depends on tx completion nofication for the last
>>    transmitted packet to complete.
>>  - TCP Small Queue depends on proper accounting of sk_wmem_alloc to 
>> work.
>>  
>>  This series tries to solve the issue by enabling tx interrupts. To 
>> minize
>>  the performance impacts of this, several optimizations were used:
>>  
>>  - In guest side, virtqueue_enable_cb_delayed() was used to delay 
>> the tx
>>    interrupt untile 3/4 pending packets were sent.
>>  - In host side, interrupt coalescing were used to reduce tx 
>> interrupts.
>>  
>>  Performance test results[1] (tx-frames 16 tx-usecs 16) shows:
>>  
>>  - For guest receiving. No obvious regression on throughput were
>>    noticed. More cpu utilization were noticed in few cases.
>>  - For guest transmission. Very huge improvement on througput for 
>> small
>>    packet transmission were noticed. This is expected since TSQ and 
>> other
>>    optimization for small packet transmission work after tx 
>> interrupt. But
>>    will use more cpu for large packets.
>>  - For TCP_RR, regression (10% on transaction rate and cpu 
>> utilization) were
>>    found. Tx interrupt won't help but cause overhead in this case. 
>> Using
>>    more aggressive coalescing parameters may help to reduce the 
>> regression.
> 
> OK, you do have posted coalescing patches - does it help any?

Helps a lot.

For RX, it saves about 5% - 10% cpu. (reduce 60%-90% tx intrs)
For small packet TX, it increases 33% - 245% throughput. (reduce 
 about 60% inters)
For TCP_RR, it increase the 3%-10% trans.rate. (reduce 40%-80% tx intrs)

> 
> I'm not sure the regression is due to interrupts.
> It would make sense for CPU but why would it
> hurt transaction rate?

Anyway guest need to take some cycles to handle tx interrupts.
And transaction rate does increase if we coalesces more tx interurpts. 
> 
> 
> It's possible that we are deferring kicks too much due to BQL.
> 
> As an experiment: do we get any of it back if we do
> -        if (kick || netif_xmit_stopped(txq))
> -                virtqueue_kick(sq->vq);
> +        virtqueue_kick(sq->vq);
> ?


I will try, but during TCP_RR, at most 1 packets were pending,
I suspect if BQL can help in this case.
> 
> 
> If yes, we can just kick e.g. periodically, e.g. after queueing each
> X bytes.

Okay, let me try to see if this help.
> 
>>  Changes from RFC V3:
>>  - Don't free tx packets in ndo_start_xmit()
>>  - Add interrupt coalescing support for virtio-net
>>  Changes from RFC v2:
>>  - clean up code, address issues raised by Jason
>>  Changes from RFC v1:
>>  - address comments by Jason Wang, use delayed cb everywhere
>>  - rebased Jason's patch on top of mine and include it (with some 
>> tweaks)
>>  
>>  Please reivew. Comments were more than welcomed.
>>  
>>  [1] Performance Test result:
>>  
>>  Environment:
>>  - Two Intel(R) Xeon(R) CPU E5620 @ 2.40GHz machines connected back 
>> to back
>>    with 82599ES cards.
>>  - Both host and guest were net-next.git plus the patch
>>  - Coalescing parameters for the card:
>>    Adaptive RX: off  TX: off
>>    rx-usecs: 1
>>    rx-frames: 0
>>    tx-usecs: 0
>>    tx-frames: 0
>>  - Vhost_net was enabled and zerocopy was disabled
>>  - Tests was done by netperf-2.6
>>  - Guest has 2 vcpus with single queue virtio-net
>>  
>>  Results:
>>  - Numbers of square brackets are whose significance is grater than 
>> 95%
>>  
>>  Guest RX:
>>  
>>  size/sessions/+throughput/+cpu/+per_cpu_throughput/
>>  64/1/+2.0326/[+6.2807%]/-3.9970%/
>>  64/2/-0.2104%/[+3.2012%]/[-3.3058%]/
>>  64/4/+1.5956%/+2.2451%/-0.6353%/
>>  64/8/+1.1732%/+3.5123%/-2.2598%/
>>  256/1/+3.7619%/[+5.8117%]/-1.9372%/
>>  256/2/-0.0661%/[+3.2511%]/-3.2127%/
>>  256/4/+1.1435%/[-8.1842%]/[+10.1591%]/
>>  256/8/[+2.2447%]/[+6.2044%]/[-3.7283%]/
>>  1024/1/+9.1479%/[+12.0997%]/[-2.6332%]/
>>  1024/2/[-17.3341%]/[+0.0000%]/[-17.3341%]/
>>  1024/4/[-0.6284%]/-1.0376%/+0.4135%/
>>  1024/8/+1.1444%/-1.6069%/+2.7961%/
>>  4096/1/+0.0401%/-0.5993%/+0.6433%/
>>  4096/2/[-0.5894%]/-2.2071%/+1.6542%/
>>  4096/4/[-0.5560%]/-1.4969%/+0.9553%/
>>  4096/8/-0.3362%/+2.7086%/-2.9645%/
>>  16384/1/-0.0285%/+0.7247%/-0.7478%/
>>  16384/2/-0.5286%/+0.3287%/-0.8545%/
>>  16384/4/-0.3297%/-2.0543%/+1.7608%/
>>  16384/8/+1.0932%/+4.0253%/-2.8187%/
>>  65535/1/+0.0003%/-0.1502%/+0.1508%/
>>  65535/2/[-0.6065%]/+0.2309%/-0.8355%/
>>  65535/4/[-0.6861%]/[+3.9451%]/[-4.4554%]/
>>  65535/8/+1.8359%/+3.1590%/-1.2825%/
>>  
>>  Guest RX:
>>  size/sessions/+throughput/+cpu/+per_cpu_throughput/
>>  64/1/[+65.0961%]/[-8.6807%]/[+80.7900%]/
>>  64/2/[+6.0288%]/[-2.2823%]/[+8.5052%]/
>>  64/4/[+5.9038%]/[-2.1834%]/[+8.2677%]/
>>  64/8/[+5.4154%]/[-2.1804%]/[+7.7651%]/
>>  256/1/[+184.6462%]/[+4.8906%]/[+171.3742%]/
>>  256/2/[+46.0731%]/[-8.9626%]/[+60.4539%]/
>>  256/4/[+45.8547%]/[-8.3027%]/[+59.0612%]/
>>  256/8/[+45.3486%]/[-8.4024%]/[+58.6817%]/
>>  1024/1/[+432.5372%]/[+3.9566%]/[+412.2689%]/
>>  1024/2/[-1.4207%]/[-23.6426%]/[+29.1025%]/
>>  1024/4/-0.1003%/[-13.6416%]/[+15.6804%]/
>>  1024/8/[+0.2200%]/[+2.0634%]/[-1.8061%]/
>>  4096/1/[+18.4835%]/[-46.1508%]/[+120.0283%]/
>>  4096/2/+0.1770%/[-26.2780%]/[+35.8848%]/
>>  4096/4/-0.1012%/-0.7353%/+0.6388%/
>>  4096/8/-0.6091%/+1.4159%/-1.9968%/
>>  16384/1/-0.0424%/[+11.9373%]/[-10.7021%]/
>>  16384/2/+0.0482%/+2.4685%/-2.3620%/
>>  16384/4/+0.0840%/[+5.3587%]/[-5.0064%]/
>>  16384/8/+0.0048%/[+5.0176%]/[-4.7733%]/
>>  65535/1/-0.0095%/[+10.9408%]/[-9.8705%]/
>>  65535/2/+0.1515%/[+8.1709%]/[-7.4137%]/
>>  65535/4/+0.0203%/[+5.4316%]/[-5.1325%]/
>>  65535/8/+0.1427%/[+6.2753%]/[-5.7705%]/
>>  
>>  size/sessions/+trans.rate/+cpu/+per_cpu_trans.rate/
>>  64/1/+0.2346%/[+11.5080%]/[-10.1099%]/
>>  64/25/[-10.7893%]/-0.5791%/[-10.2697%]/
>>  64/50/[-11.5997%]/-0.3429%/[-11.2956%]/
>>  256/1/+0.7219%/[+13.2374%]/[-11.0524%]/
>>  256/25/-6.9567%/+0.8887%/[-7.7763%]/
>>  256/50/[-4.8814%]/-0.0338%/[-4.8492%]/
>>  4096/1/-1.6061%/-0.7561%/-0.8565%/
>>  4096/25/[+2.2120%]/[+1.0839%]/+1.1161%/
>>  4096/50/[+5.6180%]/[+3.2116%]/[+2.3315%]/
>>  
>>  Jason Wang (4):
>>    virtio_net: enable tx interrupt
>>    virtio-net: optimize free_old_xmit_skbs stats
>>    virtio-net: add basic interrupt coalescing support
>>    vhost_net: interrupt coalescing support
>>  
>>  Michael S. Tsirkin (1):
>>    virtio_net: bql
>>  
>>   drivers/net/virtio_net.c        | 211 
>> ++++++++++++++++++++++++++++++++--------
>>   drivers/vhost/net.c             | 200 
>> +++++++++++++++++++++++++++++++++++--
>>   include/uapi/linux/vhost.h      |  12 +++
>>   include/uapi/linux/virtio_net.h |  12 +++
>>   4 files changed, 383 insertions(+), 52 deletions(-)
>>  
>>  -- 
>>  1.8.3.1
