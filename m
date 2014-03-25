From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 01/54] uml/net_kern: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Tue, 25 Mar 2014 11:05:14 -0700
Message-ID: <87fvm6cfxh.fsf@x220.int.ebiederm.org>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	<1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	<1395752472.12610.108.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51856 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754206AbaCYSF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 14:05:27 -0400
In-Reply-To: <1395752472.12610.108.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Tue, 25 Mar 2014 06:01:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Mon, 2014-03-24 at 23:04 -0700, Eric W. Biederman wrote:
>> From: "Eric W. Biederman" <ebiederm@xmission.com>
>> 
>> Replace dev_kfree_skb with dev_consume_skb_any in uml_net_start_xmit
>> as it can be called in hard irq and other contexts.
>> 
>> dev_consume_skb_any is used as uml_net_start_xmit typically
>> consumes (not drops) packets.
>
> Well, this is not exactly true. This driver certainly can drop packets.
>
> Here is an untested/not even compiled patch.

I said typically which does make it true :P.

I care because I trying to keep us from calling kfree_skb or consume_skb
aka dev_kfree_skb in hard irq context, as that can result in nasty
issues.

Since I am touching those places I am doing my best to pick the
correct consume or kfree variant that matches what the code does,
and there isn't always one.  But that is all at a best effort so I can
preserve the code logic.

These patches are deliberately very conservative so I can successfully
make and test them with simply code inspection.

I really don't think using enum skb_free_reason makes any sense
whatsoever.  Not in the implementation of dev_kfree_skb_any and
dev_kfree_skb_irq and certainly not in a driver.  What
net/core/drop_monitor.c wants is the address of the function where drops
occur (so we can track down and debug why the kernel is dropping
packets) and the existing implementation of dev_kfree_skb_any and
dev_kfree_skb_irq loose that information.  The use of enum
skb_free_reason is a big part of the reason why we loose that
information.  (We should be using a (void *) so that we can capture
__builtin_return_address(0) instead.  Your expanded use of enum
skb_free_reason below seems to encourage the bad implemenation and make
it even harder to fix dev_kfree_skb_any and dev_kfree_skb_irq.

In other locations with the same logic I justified the change as not
changing semantics when going from consume_skb (aka dev_kfree_skb) to
dev_consume_skb.  My apologies for not mentioning that in uml/net_kern.
I think not causing a regression in the kfree/consume distinction is
more important than getting the code exactly right.

If you are really interested in seeing us get the consume_skb vs
kfree_skb difference correct in drivers I recommend an audit of drivers
yourself.  A few weeks ago when I started looking at this there
was exactly one instance of dev_consume_skb_any or was it just
consume_skb in the entire driver tree.

So I really think getting the drop vs consume distinction perfect right
now is silly when it is hard to test and we have so much low hanging
fruit where the distinction was not even recognized.

So please ack my patches (especially this one) on the basis of execution
context correctness and drop/kfree distinction no regression or best
effort correctness.

Eric

> diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
> index 39f186252e02..8d1df7ed759e 100644
> --- a/arch/um/drivers/net_kern.c
> +++ b/arch/um/drivers/net_kern.c
> @@ -212,6 +212,7 @@ static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	struct uml_net_private *lp = netdev_priv(dev);
>  	unsigned long flags;
>  	int len;
> +	enum skb_free_reason reason = SKB_REASON_CONSUMED;
>  
>  	netif_stop_queue(dev);
>  
> @@ -228,19 +229,18 @@ static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  		/* this is normally done in the interrupt when tx finishes */
>  		netif_wake_queue(dev);
> -	}
> -	else if (len == 0) {
> -		netif_start_queue(dev);
> -		dev->stats.tx_dropped++;
> -	}
> -	else {
> +	} else {
> +		reason = SKB_REASON_DROPPED;
>  		netif_start_queue(dev);
> -		printk(KERN_ERR "uml_net_start_xmit: failed(%d)\n", len);
> +		if (len == 0)
> +			dev->stats.tx_dropped++;
> +		else
> +			pr_err("uml_net_start_xmit: failed(%d)\n", len);
>  	}
>  
>  	spin_unlock_irqrestore(&lp->lock, flags);
>  
> -	dev_kfree_skb(skb);
> +	__dev_kfree_skb_any(skb, reason);
>  
>  	return NETDEV_TX_OK;
>  }
