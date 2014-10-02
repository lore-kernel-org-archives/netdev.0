From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] net: better IFF_XMIT_DST_RELEASE support
Date: Thu, 2 Oct 2014 22:34:34 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1410022231100.3225@ja.home.ssi.bg>
References: <1412267647.22242.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47013 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751806AbaJBTem (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 15:34:42 -0400
In-Reply-To: <1412267647.22242.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 2 Oct 2014, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Testing xmit_more support with netperf and connected UDP sockets,
> I found strange dst refcount false sharing.
> 
> Current handling of IFF_XMIT_DST_RELEASE is not optimal.
> 
> dropping dst in validate_xmit_skb() is certainly too late in case
> packet was queued by cpu X but dequeued by cpu Y
> 
> The logical point to take care of drop/force is in __dev_queue_xmit()
> before even taking qdisc lock.

	Does it hurt skb_dst usage in net/sched/, for example,
dst->tclassid in net/sched/cls_route.c ?

> @@ -2895,6 +2887,14 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
>  
>  	skb_update_prio(skb);
>  
> +	/* If device doesn't need skb->dst, release it right now while
> +	 * its hot in this cpu cache
> +	 */
> +	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
> +		skb_dst_drop(skb);
> +	else
> +		skb_dst_force(skb);
> +
>  	txq = netdev_pick_tx(dev, skb, accel_priv);
>  	q = rcu_dereference_bh(txq->qdisc);

Regards

--
Julian Anastasov <ja@ssi.bg>
