From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH net-2.6] can: Use WARN_ONCE() instead of BUG_ON() for sanity
 check in receive path
Date: Mon, 10 Aug 2009 13:27:09 +0200
Message-ID: <4A80040D.3030009@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080804050308040309050206"
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	Luotao Fu <l.fu@pengutronix.de>,
	Michael Olbrich <m.olbrich@pengutronix.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:24251 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752776AbZHJL1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 07:27:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080804050308040309050206
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

To ensure a proper handling of CAN frames transported in skbuffs some checks
need to be performed at receive time.

As stated by Michael Olbrich and Luotao Fu BUG_ON() might be to restrictive.
This is right as we can just drop the non conform skbuff and the Kernel can
continue working.

This patch replaces the BUG_ON() with a WARN_ONCE() so that the system remains
healthy but we made the problem visible (once).

Additionally it changes the return values to the common NET_RX_xxx constants.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>
CC: Michael Olbrich <m.olbrich@pengutronix.de>
CC: Luotao Fu <l.fu@pengutronix.de>

---


--------------080804050308040309050206
Content-Type: text/x-patch;
 name="af_can_convert_bug_to_warn.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_can_convert_bug_to_warn.patch"

diff --git a/net/can/af_can.c b/net/can/af_can.c
index e733725..ef1c43a 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -651,12 +651,16 @@ static int can_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	int matches;
 
-	if (dev->type != ARPHRD_CAN || !net_eq(dev_net(dev), &init_net)) {
-		kfree_skb(skb);
-		return 0;
-	}
+	if (!net_eq(dev_net(dev), &init_net))
+		goto drop;
 
-	BUG_ON(skb->len != sizeof(struct can_frame) || cf->can_dlc > 8);
+	if (WARN_ONCE(dev->type != ARPHRD_CAN ||
+		      skb->len != sizeof(struct can_frame) ||
+		      cf->can_dlc > 8,
+		      "PF_CAN: dropped non conform skbuf: "
+		      "dev type %d, len %d, can_dlc %d\n",
+		      dev->type, skb->len, cf->can_dlc))
+		goto drop;
 
 	/* update statistics */
 	can_stats.rx_frames++;
@@ -682,7 +686,11 @@ static int can_rcv(struct sk_buff *skb, struct net_device *dev,
 		can_stats.matches_delta++;
 	}
 
-	return 0;
+	return NET_RX_SUCCESS;
+
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
 }
 
 /*

--------------080804050308040309050206--
