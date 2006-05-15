From: Ranjit Manomohan <ranjitm@google.com>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Mon, 15 May 2006 14:19:06 -0700 (PDT)
Message-ID: <Pine.LNX.4.56.0605151409110.25064@ranjit.corp.google.com>
References: <Pine.LNX.4.56.0605101315380.8735@ranjit.corp.google.com>
 <20060514031034.5d0396e7.akpm@osdl.org> <20060514.134231.101346572.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@osdl.org, ranjitm@google.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:15339 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP id S965251AbWEOVUO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 17:20:14 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060514.134231.101346572.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 14 May 2006, David S. Miller wrote:

> From: Andrew Morton <akpm@osdl.org>
> Date: Sun, 14 May 2006 03:10:34 -0700
> 
> > It's a bit sad to be taking a clone of a clone like this.
> > Avoidable?
> 
> Besides, clones of clones are illegal, if it's already a clone
> you must make a copy.
> 

Heres a new version which does a copy instead of the clone to avoid
the double cloning issue.

-Thanks,
Ranjit

--- linux-2.6/net/sched/sch_generic.c	2006-05-10 12:34:52.000000000 -0700
+++ linux/net/sched/sch_generic.c	2006-05-15 13:49:09.000000000 -0700
@@ -136,8 +136,11 @@
 
 			if (!netif_queue_stopped(dev)) {
 				int ret;
+				struct sk_buff *skbc = NULL;
+				/* Copy the skb so that we can trace it after
+				 * a successful transmit. */
 				if (netdev_nit)
-					dev_queue_xmit_nit(skb, dev);
+					skbc = skb_copy(skb, GFP_ATOMIC);
 
 				ret = dev->hard_start_xmit(skb, dev);
 				if (ret == NETDEV_TX_OK) { 
@@ -145,9 +148,20 @@
 						dev->xmit_lock_owner = -1;
 						spin_unlock(&dev->xmit_lock);
 					}
+					if (skbc) {
+						/* transmit succeeded, 
+						 * trace the copy. */
+						dev_queue_xmit_nit(skbc,dev);
+						kfree_skb(skbc);
+					}
 					spin_lock(&dev->queue_lock);
 					return -1;
 				}
+
+				/* Free copy if it exists */
+				if (skbc)
+					kfree_skb(skbc);
+
 				if (ret == NETDEV_TX_LOCKED && nolock) {
 					spin_lock(&dev->queue_lock);
 					goto collision; 
 
