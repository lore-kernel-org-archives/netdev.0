From: Ranjit Manomohan <ranjitm@google.com>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Mon, 15 May 2006 16:11:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.56.0605151602330.29636@ranjit.corp.google.com>
References: <20060514031034.5d0396e7.akpm@osdl.org>
 <20060514.134231.101346572.davem@davemloft.net>
 <Pine.LNX.4.56.0605151409110.25064@ranjit.corp.google.com>
 <20060515.142645.94689626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ranjitm@google.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:34072 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1750717AbWEOXLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 19:11:24 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060515.142645.94689626.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 May 2006, David S. Miller wrote:

> From: Ranjit Manomohan <ranjitm@google.com>
> Date: Mon, 15 May 2006 14:19:06 -0700 (PDT)
> 
> > Heres a new version which does a copy instead of the clone to avoid
> > the double cloning issue.
> 
> I still very much dislike this patch because it is creating
> 1 more clone per packet than is actually necessary and that
> is very expensive.
> 
> dev_queue_xmit_nit() is going to clone whatever SKB you send into
> there, so better to just bump the reference count (with skb_get())
> instead of cloning or copying.
> 

I was a bit apprehensive about just incrementing the refcnt but that works 
too. Attached is the modified version.

-Thanks,
Ranjit

--- linux-2.6/net/sched/sch_generic.c	2006-05-10 12:34:52.000000000 -0700
+++ linux/net/sched/sch_generic.c	2006-05-15 15:48:03.000000000 -0700
@@ -136,8 +136,12 @@
 
 			if (!netif_queue_stopped(dev)) {
 				int ret;
+				struct sk_buff *skbc = NULL;
+				/* Increment the reference count on the skb so
+				 * that we can use it after a successful xmit.
+				 */
 				if (netdev_nit)
-					dev_queue_xmit_nit(skb, dev);
+					skbc = skb_get(skb);
 
 				ret = dev->hard_start_xmit(skb, dev);
 				if (ret == NETDEV_TX_OK) { 
@@ -145,9 +149,20 @@
 						dev->xmit_lock_owner = -1;
 						spin_unlock(&dev->xmit_lock);
 					}
+					if (skbc) {
+						/* transmit succeeded, 
+						 * trace the buffer. */
+						dev_queue_xmit_nit(skbc,dev);
+						kfree_skb(skbc);
+					}
 					spin_lock(&dev->queue_lock);
 					return -1;
 				}
+
+				/* Call free in case we incremented refcnt */
+				if (skbc)
+					kfree_skb(skbc);
+
 				if (ret == NETDEV_TX_LOCKED && nolock) {
 					spin_lock(&dev->queue_lock);
 					goto collision; 
