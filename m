From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net V2] vhost: net: switch to use data copy if pending
 DMAs exceed the limit
Date: Mon, 10 Mar 2014 10:03:10 +0200
Message-ID: <20140310080310.GA754@redhat.com>
References: <1394170107-12018-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Qin Chuanyu <qinchuanyu@huawei.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtio-dev-return-448-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
Content-Disposition: inline
In-Reply-To: <1394170107-12018-1-git-send-email-jasowang@redhat.com>
List-Id: netdev.vger.kernel.org

On Fri, Mar 07, 2014 at 01:28:27PM +0800, Jason Wang wrote:
> We used to stop the handling of tx when the number of pending DMAs
> exceeds VHOST_MAX_PEND. This is used to reduce the memory occupation
> of both host and guest. But it was too aggressive in some cases, since
> any delay or blocking of a single packet may delay or block the guest
> transmission. Consider the following setup:
> 
>     +-----+        +-----+
>     | VM1 |        | VM2 |
>     +--+--+        +--+--+
>        |              |
>     +--+--+        +--+--+
>     | tap0|        | tap1|
>     +--+--+        +--+--+
>        |              |
>     pfifo_fast   htb(10Mbit/s)
>        |              |
>     +--+--------------+---+
>     |     bridge          |
>     +--+------------------+
>        |
>     pfifo_fast
>        |
>     +-----+
>     | eth0|(100Mbit/s)
>     +-----+
> 
> - start two VMs and connect them to a bridge
> - add an physical card (100Mbit/s) to that bridge
> - setup htb on tap1 and limit its throughput to 10Mbit/s
> - run two netperfs in the same time, one is from VM1 to VM2. Another is
>   from VM1 to an external host through eth0.
> - result shows that not only the VM1 to VM2 traffic were throttled but
>   also the VM1 to external host through eth0 is also throttled somehow.
> 
> This is because the delay added by htb may lead the delay the finish
> of DMAs and cause the pending DMAs for tap0 exceeds the limit
> (VHOST_MAX_PEND). In this case vhost stop handling tx request until
> htb send some packets. The problem here is all of the packets
> transmission were blocked even if it does not go to VM2.
> 
> We can solve this issue by relaxing it a little bit: switching to use
> data copy instead of stopping tx when the number of pending DMAs
> exceed half of the vq size. This is safe because:
> 
> - The number of pending DMAs were still limited (half of the vq size)
> - The out of order completion during mode switch can make sure that
>   most of the tx buffers were freed in time in guest.
> 
> So even if about 50% packets were delayed in zero-copy case, vhost
> could continue to do the transmission through data copy in this case.
> 
> Test result:
> 
> Before this patch:
> VM1 to VM2 throughput is 9.3Mbit/s
> VM1 to External throughput is 40Mbit/s
> CPU utilization is 7%
> 
> After this patch:
> VM1 to VM2 throughput is 9.3Mbit/s
> Vm1 to External throughput is 93Mbit/s
> CPU utilization is 16%
> 
> Completed performance test on 40gbe shows no obvious changes in both
> throughput and cpu utilization with this patch.
> 
> The patch only solve this issue when unlimited sndbuf. We still need a
> solution for limited sndbuf.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Qin Chuanyu <qinchuanyu@huawei.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

I thought hard about this.
Here's what worries me: if there are still head of line
blocking issues lurking in the stack, they will still
hurt guests such as windows which rely on timely
completion of buffers, but it makes it
that much harder to reproduce the problems with
linux guests which don't.
And this will make even it harder to figure out
whether zero copy is actually active to diagnose
high cpu utilization cases.


So I think this is a good trick, but let's make
this path conditional on a new debugging module parameter:
how about head_of_line_blocking with default off?
This way if we suspect packets are delayed forever
somewhere, we can enable that and see guest networking block.

Additionally, I think we should add a way to count zero copy
and non zero copy packets.
I see two ways to implement this: add tracepoints in vhost-net
or add counters in tun accessible with ethtool.
This can be a patch on top and does not have to block
this one though.

> ---
> Changes from V1:
> - Remove VHOST_MAX_PEND and switch to use half of the vq size as the limit
> - Add cpu utilization in commit log
> ---
>  drivers/vhost/net.c | 19 +++++++------------
>  1 file changed, 7 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index a0fa5de..2925e9a 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -38,8 +38,6 @@ MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
>   * Using this limit prevents one virtqueue from starving others. */
>  #define VHOST_NET_WEIGHT 0x80000
>  
> -/* MAX number of TX used buffers for outstanding zerocopy */
> -#define VHOST_MAX_PEND 128
>  #define VHOST_GOODCOPY_LEN 256
>  
>  /*
> @@ -345,7 +343,7 @@ static void handle_tx(struct vhost_net *net)
>  		.msg_flags = MSG_DONTWAIT,
>  	};
>  	size_t len, total_len = 0;
> -	int err;
> +	int err, num_pends;
>  	size_t hdr_size;
>  	struct socket *sock;
>  	struct vhost_net_ubuf_ref *uninitialized_var(ubufs);
> @@ -366,13 +364,6 @@ static void handle_tx(struct vhost_net *net)
>  		if (zcopy)
>  			vhost_zerocopy_signal_used(net, vq);
>  
> -		/* If more outstanding DMAs, queue the work.
> -		 * Handle upend_idx wrap around
> -		 */
> -		if (unlikely((nvq->upend_idx + vq->num - VHOST_MAX_PEND)
> -			      % UIO_MAXIOV == nvq->done_idx))
> -			break;
> -
>  		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
>  					 ARRAY_SIZE(vq->iov),
>  					 &out, &in,
> @@ -405,9 +396,13 @@ static void handle_tx(struct vhost_net *net)
>  			break;
>  		}
>  
> +		num_pends = likely(nvq->upend_idx >= nvq->done_idx) ?
> +			    (nvq->upend_idx - nvq->done_idx) :
> +			    (nvq->upend_idx + UIO_MAXIOV -
> +			     nvq->done_idx);
> +
>  		zcopy_used = zcopy && len >= VHOST_GOODCOPY_LEN
> -				   && (nvq->upend_idx + 1) % UIO_MAXIOV !=
> -				      nvq->done_idx
> +				   && num_pends <= vq->num >> 1
>  				   && vhost_net_tx_select_zcopy(net);
>  
>  		/* use msg_control to pass vhost zerocopy ubuf info to skb */
> -- 
> 1.8.3.2
