From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 4/8] netpoll: netpoll_send_skb simplify
Date: Thu, 11 Aug 2005 21:19:11 -0500
Message-ID: <5.502409567@selenic.com>
References: <4.502409567@selenic.com>
Cc: ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.com>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <4.502409567@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Minor netpoll_send_skb restructuring

Restructure to avoid confusing goto and move some bits out of the
retry loop.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: l/net/core/netpoll.c
===================================================================
--- l.orig/net/core/netpoll.c	2005-08-07 15:15:48.000000000 -0500
+++ l/net/core/netpoll.c	2005-08-07 16:59:27.000000000 -0500
@@ -248,14 +248,14 @@ static void netpoll_send_skb(struct netp
 	int status;
 	struct netpoll_info *npinfo;
 
-repeat:
-	if(!np || !np->dev || !netif_running(np->dev)) {
+	if (!np || !np->dev || !netif_running(np->dev)) {
 		__kfree_skb(skb);
 		return;
 	}
 
-	/* avoid recursion */
 	npinfo = np->dev->npinfo;
+
+	/* avoid recursion */
 	if (npinfo->poll_owner == smp_processor_id() ||
 	    np->dev->xmit_lock_owner == smp_processor_id()) {
 		if (np->drop)
@@ -265,29 +265,31 @@ repeat:
 		return;
 	}
 
-	spin_lock(&np->dev->xmit_lock);
-	np->dev->xmit_lock_owner = smp_processor_id();
+	while (1) {
+		spin_lock(&np->dev->xmit_lock);
+		np->dev->xmit_lock_owner = smp_processor_id();
+
+		/*
+		 * network drivers do not expect to be called if the queue is
+		 * stopped.
+		 */
+		if (netif_queue_stopped(np->dev)) {
+			np->dev->xmit_lock_owner = -1;
+			spin_unlock(&np->dev->xmit_lock);
+			netpoll_poll(np);
+			continue;
+		}
 
-	/*
-	 * network drivers do not expect to be called if the queue is
-	 * stopped.
-	 */
-	if (netif_queue_stopped(np->dev)) {
+		status = np->dev->hard_start_xmit(skb, np->dev);
 		np->dev->xmit_lock_owner = -1;
 		spin_unlock(&np->dev->xmit_lock);
 
-		netpoll_poll(np);
-		goto repeat;
-	}
-
-	status = np->dev->hard_start_xmit(skb, np->dev);
-	np->dev->xmit_lock_owner = -1;
-	spin_unlock(&np->dev->xmit_lock);
+		/* success */
+		if(!status)
+			return;
 
-	/* transmit busy */
-	if(status) {
+		/* transmit busy */
 		netpoll_poll(np);
-		goto repeat;
 	}
 }
 
