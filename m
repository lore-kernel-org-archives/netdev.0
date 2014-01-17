From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: core: orphan frags before queuing to slow qdisc
Date: Fri, 17 Jan 2014 06:28:17 -0800
Message-ID: <1389968897.31367.489.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389951734-13234-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389951734-13234-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-01-17 at 17:42 +0800, Jason Wang wrote:
> Many qdiscs can queue a packet for a long time, this will lead an issue
> with zerocopy skb. It means the frags will not be orphaned in an expected
> short time, this breaks the assumption that virtio-net will transmit the
> packet in time.
> 
> So if guest packets were queued through such kind of qdisc and hit the
> limitation of the max pending packets for virtio/vhost. All packets that
> go to another destination from guest will also be blocked.
> 
> A case for reproducing the issue:
> 
> - Boot two VMs and connect them to the same bridge kvmbr.
> - Setup tbf with a very low rate/burst on eth0 which is a port of kvmbr.
> - Let VM1 send lots of packets thorugh eth0
> - After a while, VM1 is unable to send any packets out since the number of
>   pending packets (queued to tbf) were exceeds the limitation of vhost/virito

So whats the problem ? If the limit is low, you cannot sent packets.

Solution : increase the limit, or tell the vm to lower its rate.

Oh wait, are you bitten because you did some prior skb_orphan() to allow
the vm to send unlimited number of skbs ???

> 
> Solve this issue by orphaning the frags before queuing it to a slow qdisc (the
> one without TCQ_F_CAN_BYPASS).

Why orphaning the frags only solves the problem ? A skb without zerocopy
frags should also be blocked for a while.

Seriously, lets admit this zero copy stuff is utterly broken.


TCQ_F_CAN_BYPASS is not enough. Some NIC have separate queues with
strict priorities.

It seems to me that you are pushing to use FIFO (the only qdisc setting
TCQ_F_CAN_BYPASS), by adding yet another test in fast path (I do not
know how we can still call it a fast path), while we already have smart
qdisc to avoid the inherent HOL and unfairness problems of FIFO.

> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  net/core/dev.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0ce469e..1209774 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2700,6 +2700,12 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>  	contended = qdisc_is_running(q);
>  	if (unlikely(contended))
>  		spin_lock(&q->busylock);
> +	if (!(q->flags & TCQ_F_CAN_BYPASS) &&
> +	    unlikely(skb_orphan_frags(skb, GFP_ATOMIC))) {
> +		kfree_skb(skb);
> +		rc = NET_XMIT_DROP;
> +		goto out;
> +	}

Are you aware that copying stuff takes time ?

If yes, why is it done after taking the busylock spinlock ?

>  
>  	spin_lock(root_lock);
>  	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> @@ -2739,6 +2745,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>  		}
>  	}
>  	spin_unlock(root_lock);
> +out:
>  	if (unlikely(contended))
>  		spin_unlock(&q->busylock);
>  	return rc;
