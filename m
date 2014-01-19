From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] net: core: orphan frags before queuing to slow qdisc
Date: Sun, 19 Jan 2014 11:21:40 +0200
Message-ID: <20140119092140.GA2984@redhat.com>
References: <1389951734-13234-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389951734-13234-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 17, 2014 at 05:42:14PM +0800, Jason Wang wrote:
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
> 
> Solve this issue by orphaning the frags before queuing it to a slow qdisc (the
> one without TCQ_F_CAN_BYPASS).

This seems too aggressive to me.
The issue is that packet can stay queued indefinitely long.
So I think we should only do this for tbf.

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
> -- 
> 1.8.3.2
