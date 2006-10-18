From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netpoll: netpoll_send_skb local optimization
Date: Wed, 18 Oct 2006 13:55:51 -0700
Message-ID: <20061018135551.789f7bb7@freekitty>
References: <20061018135033.4a4872b8@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23223 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422923AbWJRU4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 16:56:50 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061018135033.4a4872b8@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This cleans up netpoll_send_skb:
 * np and np->dev are always non-null given the local callers
 * get device into a local variable

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- orig/net/core/netpoll.c	2006-10-18 13:44:27.000000000 -0700
+++ new/net/core/netpoll.c	2006-10-18 13:46:03.000000000 -0700
@@ -270,19 +270,19 @@
 
 static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 {
+	struct net_device *dev = np->dev;
+	struct netpoll_info *npinfo = dev->npinfo;
 	int status;
-	struct netpoll_info *npinfo;
 
-	if (!np || !np->dev || !netif_device_present(np->dev) || !netif_running(np->dev)) {
+	if (!netif_device_present(dev) || !netif_running(dev)) {
 		__kfree_skb(skb);
 		return;
 	}
 
-	npinfo = np->dev->npinfo;
 
 	/* avoid recursion */
 	if (npinfo->poll_owner == smp_processor_id() ||
-	    np->dev->xmit_lock_owner == smp_processor_id()) {
+	    dev->xmit_lock_owner == smp_processor_id()) {
 		if (np->drop)
 			np->drop(skb);
 		else
@@ -292,17 +292,17 @@
 
 	do {
 		npinfo->tries--;
-		netif_tx_lock(np->dev);
+		netif_tx_lock(dev);
 
 		/*
 		 * network drivers do not expect to be called if the queue is
 		 * stopped.
 		 */
 		status = NETDEV_TX_BUSY;
-		if (!netif_queue_stopped(np->dev))
-			status = np->dev->hard_start_xmit(skb, np->dev);
+		if (!netif_queue_stopped(dev))
+			status = dev->hard_start_xmit(skb, dev);
 
-		netif_tx_unlock(np->dev);
+		netif_tx_unlock(dev);
 
 		/* success */
 		if(!status) {
