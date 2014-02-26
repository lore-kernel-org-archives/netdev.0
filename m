From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] vhost: net: switch to use data copy if pending DMAs
	exceed the limit
Date: Wed, 26 Feb 2014 13:53:18 +0800
Message-ID: <530D814E.2080708@redhat.com>
References: <1393311238-7750-1-git-send-email-jasowang@redhat.com>
	<20140225135738.GA15274@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Qin Chuanyu <qinchuanyu@huawei.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140225135738.GA15274@redhat.com>
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

On 02/25/2014 09:57 PM, Michael S. Tsirkin wrote:
> On Tue, Feb 25, 2014 at 02:53:58PM +0800, Jason Wang wrote:
>> We used to stop the handling of tx when the number of pending DMAs
>> exceeds VHOST_MAX_PEND. This is used to reduce the memory occupation
>> of both host and guest. But it was too aggressive in some cases, since
>> any delay or blocking of a single packet may delay or block the guest
>> transmission. Consider the following setup:
>>
>>      +-----+        +-----+
>>      | VM1 |        | VM2 |
>>      +--+--+        +--+--+
>>         |              |
>>      +--+--+        +--+--+
>>      | tap0|        | tap1|
>>      +--+--+        +--+--+
>>         |              |
>>      pfifo_fast   htb(10Mbit/s)
>>         |              |
>>      +--+--------------+---+
>>      |     bridge          |
>>      +--+------------------+
>>         |
>>      pfifo_fast
>>         |
>>      +-----+
>>      | eth0|(100Mbit/s)
>>      +-----+
>>
>> - start two VMs and connect them to a bridge
>> - add an physical card (100Mbit/s) to that bridge
>> - setup htb on tap1 and limit its throughput to 10Mbit/s
>> - run two netperfs in the same time, one is from VM1 to VM2. Another is
>>    from VM1 to an external host through eth0.
>> - result shows that not only the VM1 to VM2 traffic were throttled but
>>    also the VM1 to external host through eth0 is also throttled somehow.
>>
>> This is because the delay added by htb may lead the delay the finish
>> of DMAs and cause the pending DMAs for tap0 exceeds the limit
>> (VHOST_MAX_PEND). In this case vhost stop handling tx request until
>> htb send some packets. The problem here is all of the packets
>> transmission were blocked even if it does not go to VM2.
>>
>> We can solve this issue by relaxing it a little bit: switching to use
>> data copy instead of stopping tx when the number of pending DMAs
>> exceed the VHOST_MAX_PEND. This is safe because:
>>
>> - The number of pending DMAs were still limited by VHOST_MAX_PEND
>> - The out of order completion during mode switch can make sure that
>>    most of the tx buffers were freed in time in guest.
>>
>> So even if about 50% packets were delayed in zero-copy case, vhost
>> could continue to do the transmission through data copy in this case.
>>
>> Test result:
>>
>> Before this patch:
>> VM1 to VM2 throughput is 9.3Mbit/s
>> VM1 to External throughput is 40Mbit/s
>>
>> After this patch:
>> VM1 to VM2 throughput is 9.3Mbit/s
>> Vm1 to External throughput is 93Mbit/s
> Would like to see CPU utilization #s as well.
>

Will measure this.
>> Simple performance test on 40gbe shows no obvious changes in
>> throughput after this patch.
>>
>> The patch only solve this issue when unlimited sndbuf. We still need a
>> solution for limited sndbuf.
>>
>> Cc: Michael S. Tsirkin<mst@redhat.com>
>> Cc: Qin Chuanyu<qinchuanyu@huawei.com>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
> I think this needs some thought.
>
> In particular I think this works because VHOST_MAX_PEND
> is much smaller than the ring size.
> Shouldn't max_pend then be tied to the ring size if it's small?
>

Yes it should. I just reuse the VHOST_MAX_PEND since it was there for a 
long time.
> Another question is about stopping vhost:
> ATM it's waiting for skbs to complete.
> Should we maybe hunt down skbs queued and destroy them
> instead?
> I think this happens when a device is removed.
>
> Thoughts?
>

Agree, vhost net removal should not be blocked by a skb. But since the 
skbs could be queued may places, just destroy them may need extra locks.

Haven't thought this deeply, but another possible sloution is to rcuify 
destructor_arg and assign it to NULL during vhost_net removing.
>> ---
>>   drivers/vhost/net.c | 17 +++++++----------
>>   1 file changed, 7 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index a0fa5de..3e96e47 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -345,7 +345,7 @@ static void handle_tx(struct vhost_net *net)
>>   		.msg_flags = MSG_DONTWAIT,
>>   	};
>>   	size_t len, total_len = 0;
>> -	int err;
>> +	int err, num_pends;
>>   	size_t hdr_size;
>>   	struct socket *sock;
>>   	struct vhost_net_ubuf_ref *uninitialized_var(ubufs);
>> @@ -366,13 +366,6 @@ static void handle_tx(struct vhost_net *net)
>>   		if (zcopy)
>>   			vhost_zerocopy_signal_used(net, vq);
>>
>> -		/* If more outstanding DMAs, queue the work.
>> -		 * Handle upend_idx wrap around
>> -		 */
>> -		if (unlikely((nvq->upend_idx + vq->num - VHOST_MAX_PEND)
>> -			      % UIO_MAXIOV == nvq->done_idx))
>> -			break;
>> -
>>   		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
>>   					 ARRAY_SIZE(vq->iov),
>>   					&out,&in,
>> @@ -405,9 +398,13 @@ static void handle_tx(struct vhost_net *net)
>>   			break;
>>   		}
>>
>> +		num_pends = likely(nvq->upend_idx>= nvq->done_idx) ?
>> +			    (nvq->upend_idx - nvq->done_idx) :
>> +			    (nvq->upend_idx + UIO_MAXIOV -
>> +			     nvq->done_idx);
>> +
>>   		zcopy_used = zcopy&&  len>= VHOST_GOODCOPY_LEN
>> -				&&  (nvq->upend_idx + 1) % UIO_MAXIOV !=
>> -				      nvq->done_idx
>> +				&&  num_pends<= VHOST_MAX_PEND
>>   				&&  vhost_net_tx_select_zcopy(net);
>>
>>   		/* use msg_control to pass vhost zerocopy ubuf info to skb */
>> -- 
>> 1.8.3.2
