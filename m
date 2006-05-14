From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Sun, 14 May 2006 03:10:34 -0700
Message-ID: <20060514031034.5d0396e7.akpm@osdl.org>
References: <Pine.LNX.4.56.0605101315380.8735@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37580 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932390AbWENKNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 May 2006 06:13:44 -0400
To: Ranjit Manomohan <ranjitm@google.com>
In-Reply-To: <Pine.LNX.4.56.0605101315380.8735@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ranjit Manomohan <ranjitm@google.com> wrote:
>
> This patch fixes the problem where tcpdump shows duplicate packets
> while tracing outbound packets on drivers which support lockless
> transmit. The patch changes the current behaviour to tracing the
> packets only on a successful transmit.
> 

There was no feedback on this one?

> 
> --- linux-2.6/net/sched/sch_generic.c	2006-05-10 12:34:52.000000000 -0700
> +++ linux/net/sched/sch_generic.c	2006-05-10 12:39:38.000000000 -0700
> @@ -136,8 +136,12 @@
>  
>  			if (!netif_queue_stopped(dev)) {
>  				int ret;
> +				struct sk_buff *skbc = NULL;
> +				/* Clone the skb so that we hold a reference
> +				 * to its data and we can trace it after a
> +				 * successful transmit. */

Like this:

				/*
				 * Clone the skb so that we hold a reference to
				 * its data and we can trace it after a
				 * successful transmit
				 */

>  				if (netdev_nit)
> -					dev_queue_xmit_nit(skb, dev);
> +					skbc = skb_clone(skb, GFP_ATOMIC);
>  
>  				ret = dev->hard_start_xmit(skb, dev);
>  				if (ret == NETDEV_TX_OK) { 
> @@ -145,6 +149,15 @@
>  						dev->xmit_lock_owner = -1;
>  						spin_unlock(&dev->xmit_lock);
>  					}
> +					if(skbc) {

Like this:
					if (skbc)

> +						/* transmit succeeded, 
> +						 * trace the clone. */
> +						dev_queue_xmit_nit(skbc,dev);
> +						kfree_skb(skbc);
> +					}
> +					/* Free clone if it exists */
> +					if(skbc)

					if (skbc)

> +						kfree_skb(skbc);

We don't need to test for skbc==NULL - kfree_skb(NULL) is legal.

This code will end up running kfree_skb(skbc) twice.  Unless
dev_queue_xmit_nit() takes an additional ref on the skb (I don't think it
does), this will cause corruption of freed memory.


>  					spin_lock(&dev->queue_lock);
>  					return -1;
>  				}

dev_queue_xmit_nit() already clones the skb.  It's a bit sad to be taking a
clone of a clone like this.  Avoidable?
