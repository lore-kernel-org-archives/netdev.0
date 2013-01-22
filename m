From: Peter Lieven <pl@dlhnet.de>
Subject: Re: tap devices not receiving packets from a bridge
Date: Tue, 22 Jan 2013 10:43:34 +0100
Message-ID: <50FE5F46.50500@dlhnet.de>
References: <50AE36E0.8000307@dlhnet.de>
	<20121123070211.GC22787@stefanha-thinkpad.hitronhub.home>
	<E85C6011-548D-4507-A776-1028DD3E3515@dlhnet.de>
	<20121123110146.GC7051@redhat.com> <50FE5607.9020405@dlhnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Hajnoczi <stefanha@gmail.com>, qemu-devel@nongnu.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <50FE5607.9020405@dlhnet.de>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On 22.01.2013 10:04, Peter Lieven wrote:
> On 23.11.2012 12:01, Michael S. Tsirkin wrote:
>> On Fri, Nov 23, 2012 at 10:41:21AM +0100, Peter Lieven wrote:
>>>
>>> Am 23.11.2012 um 08:02 schrieb Stefan Hajnoczi:
>>>
>>>> On Thu, Nov 22, 2012 at 03:29:52PM +0100, Peter Lieven wrote:
>>>>> is anyone aware of a problem with the linux network bridge that in very rare circumstances stops
>>>>> a bridge from sending pakets to a tap device?
>>>>>
>>>>> My problem occurs in conjunction with vanilla qemu-kvm-1.2.0 and Ubuntu Kernel 3.2.0-34.53
>>>>> which is based on Linux 3.2.33.
>>>>>
>>>>> I was not yet able to reproduce the issue, it happens in really rare cases. The symptom is that
>>>>> the tap does not have any TX packets. RX is working fine. I see the packets coming in at
>>>>> the physical interface on the host, but they are not forwarded to the tap interface.
>>>>> The bridge itself has learnt the mac address of the vServer that is connected to the tap interface.
>>>>> It does not help to toggle the bridge link status,  the tap interface status or the interface in the vServer.
>>>>> It seems that problem occurs if a tap interface that has previously been used, but set to nonpersistent
>>>>> is set persistent again and then is by chance assigned to the same vServer (=same mac address on same
>>>>> bridge) again. Unfortunately it seems not to be reproducible.
>>>>
>>>> Not sure but this patch from Michael Tsirkin may help - it solves an
>>>> issue with persistent tap devices:
>>>>
>>>> http://patchwork.ozlabs.org/patch/198598/
>>>
>>> Hi Stefan,
>>>
>>> thanks for the pointer. I have seen this patch, but I have neglected it because it was dealing
>>> with persistent taps. But maybe the taps in the kernel are not deleted directly.
>>> Can you remember what the syptomps of the above issue have been? Sorry for
>>> being vague, but I currently have no clue whats going on.
>>>
>>> Can someone who has more internal knowledge of the bridging/tap code say if qemu can
>>> be responsible at all if the tap device is not receiving packets from the bridge.
>>>
>>> If I have the following config. Lets say packets coming in via physical interface eth1.123,
>>> and a bridge called br123.I further have a virtual machine with tap0. Both eth1.123
>>> and tap0 are member of br123.
>>>
>>> If the issue occurs the vServer has no network connectivity inbound. If I sent a ping
>>> from the vServer I see it on tap0 and leaving on eth1.123. I see further the arp reply coming
>>> in via eth1.123, but the reply can't be seen on tap0.
>>>
>>> Peter
>>
>> If guest is not consuming packets, a TX queue in tap device
>> will with time overrun (there's space for 1000 packets there).
>> This is code from tun:
>>
>>          if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
>>                            >= dev->tx_queue_len / tun->numqueues){
>>                  if (!(tun->flags & TUN_ONE_QUEUE)) {
>>                          /* Normal queueing mode. */
>>                          /* Packet scheduler handles dropping of further
>>   * packets. */
>>                          netif_stop_subqueue(dev, txq);
>>
>>                          /* We won't see all dropped packets
>>   * individually, so overrun
>>                           * error is more appropriate. */
>>                          dev->stats.tx_fifo_errors++;
>>
>>
>> So you can detect that this triggered by looking at fifo errors counter in device.
>>
>> Once this happens TX queue is stopped, then you hit this path:
>>
>>                          if (!netif_xmit_stopped(txq)) {
>>                                  __this_cpu_inc(xmit_recursion);
>>                                  rc = dev_hard_start_xmit(skb, dev, txq);
>>                                  __this_cpu_dec(xmit_recursion);
>>                                  if (dev_xmit_complete(rc)) {
>>                                          HARD_TX_UNLOCK(dev, txq);
>>                                          goto out;
>>                                  }
>>                          }
>>
>> so packets are not passed to device anymore.
>> It will stay this way until guest consumes some packets and
>> queue is restarted.
>
> After some time I again have a vServer in this state. It seems not like there
> are no TX errors.
>
> # ifconfig tap10
> tap10     Link encap:Ethernet  HWaddr 7a:59:20:6f:e7:e5
>            inet6 addr: fe80::7859:20ff:fe6f:e7e5/64 Scope:Link
>            UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
>            RX packets:197431 errors:0 dropped:0 overruns:0 frame:0
>            TX packets:264309 errors:0 dropped:0 overruns:2 carrier:0
>            collisions:0 txqueuelen:500
>            RX bytes:13842063 (13.8 MB)  TX bytes:35092821 (35.0 MB)
>
> It seems like the bridge is not forwarding any packets to the tap device anymore altough it has learnt
> the MAC-Adresses and there are also broadcast packets coming in.
>
> Any more ideas where I could debug?

Would like to add I see the packets in ebtables forwarding chain, but the TX counters
of the interface are not increasing.

Peter


>
> Peter
>
>>
>>>>
>>>> Stefan
>
