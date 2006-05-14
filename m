From: Ranjit Manomohan <ranjitm@google.com>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Sun, 14 May 2006 08:58:39 -0700 (PDT)
Message-ID: <Pine.LNX.4.56.0605140854500.20697@ranjit.corp.google.com>
References: <Pine.LNX.4.56.0605101315380.8735@ranjit.corp.google.com>
 <20060514031034.5d0396e7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ranjit Manomohan <ranjitm@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:25153 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1751476AbWENP6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 May 2006 11:58:53 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060514031034.5d0396e7.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you for the comments. Incorporated feedback into current version.

-Thanks,
Ranjit

--- linux-2.6/net/sched/sch_generic.c	2006-05-10 12:34:52.000000000 -0700
+++ linux/net/sched/sch_generic.c	2006-05-14 08:53:33.000000000 -0700
@@ -136,8 +136,12 @@
 
 			if (!netif_queue_stopped(dev)) {
 				int ret;
+				struct sk_buff *skbc = NULL;
+				/* Clone the skb so that we hold a reference
+				 * to its data and we can trace it after a
+				 * successful transmit. */
 				if (netdev_nit)
-					dev_queue_xmit_nit(skb, dev);
+					skbc = skb_clone(skb, GFP_ATOMIC);
 
 				ret = dev->hard_start_xmit(skb, dev);
 				if (ret == NETDEV_TX_OK) { 
@@ -145,9 +149,17 @@
 						dev->xmit_lock_owner = -1;
 						spin_unlock(&dev->xmit_lock);
 					}
+					if (skbc) {
+						/* transmit succeeded, 
+						 * trace the clone. */
+						dev_queue_xmit_nit(skbc,dev);
+						kfree_skb(skbc);
+					}
 					spin_lock(&dev->queue_lock);
 					return -1;
 				}
+				/* Free clone if it exists */
+				kfree_skb(skbc);
 				if (ret == NETDEV_TX_LOCKED && nolock) {
 					spin_lock(&dev->queue_lock);
 					goto collision; 
