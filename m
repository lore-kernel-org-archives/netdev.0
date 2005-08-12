From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 2/8] netpoll: deadlock bugfix
Date: Thu, 11 Aug 2005 21:19:10 -0500
Message-ID: <3.502409567@selenic.com>
References: <2.502409567@selenic.com>
Cc: ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.com>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <2.502409567@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This fixes an obvious deadlock in the netpoll code.  netpoll_rx takes the
npinfo->rx_lock.  netpoll_rx is also the only caller of arp_reply (through
__netpoll_rx).  As such, it is not necessary to take this lock.

Signed-off-by: Jeff Moyer <jmoyer@redhat.com>
Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: l/net/core/netpoll.c
===================================================================
--- l.orig/net/core/netpoll.c	2005-08-06 17:47:48.000000000 -0500
+++ l/net/core/netpoll.c	2005-08-06 17:47:49.000000000 -0500
@@ -353,11 +353,8 @@ static void arp_reply(struct sk_buff *sk
 	struct sk_buff *send_skb;
 	struct netpoll *np = NULL;
 
-	spin_lock_irqsave(&npinfo->rx_lock, flags);
 	if (npinfo->rx_np && npinfo->rx_np->dev == skb->dev)
 		np = npinfo->rx_np;
-	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-
 	if (!np)
 		return;
 
