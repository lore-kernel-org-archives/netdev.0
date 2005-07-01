From: Jeff Moyer <jmoyer@redhat.com>
Subject: [rfc | patch 6/6] netpoll: fix deadlock in arp_reply
Date: Fri, 1 Jul 2005 19:10:20 -0400
Message-ID: <17093.52572.3153.664456@segfault.boston.redhat.com>
References: <17093.52306.136742.190912@segfault.boston.redhat.com>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261415AbVGAXSs@vger.kernel.org>
To: mpm@selenic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
In-Reply-To: <17093.52306.136742.190912@segfault.boston.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes an obvious deadlock in the netpoll code.  netpoll_rx takes the
npinfo->rx_lock.  netpoll_rx is also the only caller of arp_reply (through
__netpoll_rx).  As such, it is not necessary to take this lock.

Signed-off-by: Jeff Moyer <jmoyer@redhat.com>

--- linux-2.6.12/net/core/netpoll.c.orig	2005-07-01 17:55:24.313339068 -0400
+++ linux-2.6.12/net/core/netpoll.c	2005-07-01 17:55:57.354863472 -0400
@@ -370,11 +370,8 @@ static void arp_reply(struct sk_buff *sk
 	struct sk_buff *send_skb;
 	struct netpoll *np = NULL;
 
-	spin_lock_irqsave(&npinfo->rx_lock, flags);
 	if (npinfo->rx_np && npinfo->rx_np->dev == skb->dev)
 		np = npinfo->rx_np;
-	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-
 	if (!np)
 		return;
 
