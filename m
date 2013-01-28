From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net-next] can: rework skb reserved data handling
Date: Mon, 28 Jan 2013 19:33:33 +0100
Message-ID: <5106C47D.9000704@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:57501 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab3A1Sdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 13:33:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added accessor and skb_reserve helpers for struct can_skb_priv.
Removed pointless skb_headroom() check.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
CC: Marc Kleine-Budde <mkl@pengutronix.de>

---

Hello Dave,

as suggested here's a rework fixing the two issues with the new CAN skb
private data space.

It looks really much better now. Tnx for the feedback.

Oliver

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 59ada08..f9cba41 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -512,8 +512,8 @@ struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf)
 	skb->pkt_type = PACKET_BROADCAST;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	skb_reserve(skb, sizeof(struct can_skb_priv));
-	((struct can_skb_priv *)(skb->head))->ifindex = dev->ifindex;
+	can_skb_reserve(skb);
+	can_skb_prv(skb)->ifindex = dev->ifindex;
 
 	*cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
 	memset(*cf, 0, sizeof(struct can_frame));
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index e79a8d1..06b7e09 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -195,8 +195,8 @@ static void slc_bump(struct slcan *sl)
 	skb->pkt_type = PACKET_BROADCAST;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	skb_reserve(skb, sizeof(struct can_skb_priv));
-	((struct can_skb_priv *)(skb->head))->ifindex = sl->dev->ifindex;
+	can_skb_reserve(skb);
+	can_skb_prv(skb)->ifindex = sl->dev->ifindex;
 
 	memcpy(skb_put(skb, sizeof(struct can_frame)),
 	       &cf, sizeof(struct can_frame));
diff --git a/include/linux/can/skb.h b/include/linux/can/skb.h
index 4b0f24d..2f0543f 100644
--- a/include/linux/can/skb.h
+++ b/include/linux/can/skb.h
@@ -32,4 +32,14 @@ struct can_skb_priv {
 	struct can_frame cf[0];
 };
 
+static inline struct can_skb_priv *can_skb_prv(struct sk_buff *skb)
+{
+	return (struct can_skb_priv *)(skb->head);
+}
+
+static inline void can_skb_reserve(struct sk_buff *skb)
+{
+	skb_reserve(skb, sizeof(struct can_skb_priv));
+}
+
 #endif /* CAN_SKB_H */
diff --git a/net/can/bcm.c b/net/can/bcm.c
index ccc27b9..28e12d1 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -261,8 +261,8 @@ static void bcm_can_tx(struct bcm_op *op)
 	if (!skb)
 		goto out;
 
-	skb_reserve(skb, sizeof(struct can_skb_priv));
-	((struct can_skb_priv *)(skb->head))->ifindex = dev->ifindex;
+	can_skb_reserve(skb);
+	can_skb_prv(skb)->ifindex = dev->ifindex;
 
 	memcpy(skb_put(skb, CFSIZ), cf, CFSIZ);
 
@@ -1207,7 +1207,7 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk)
 	if (!skb)
 		return -ENOMEM;
 
-	skb_reserve(skb, sizeof(struct can_skb_priv));
+	can_skb_reserve(skb);
 
 	err = memcpy_fromiovec(skb_put(skb, CFSIZ), msg->msg_iov, CFSIZ);
 	if (err < 0) {
@@ -1221,7 +1221,7 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk)
 		return -ENODEV;
 	}
 
-	((struct can_skb_priv *)(skb->head))->ifindex = dev->ifindex;
+	can_skb_prv(skb)->ifindex = dev->ifindex;
 	skb->dev = dev;
 	skb->sk  = sk;
 	err = can_send(skb, 1); /* send with loopback */
diff --git a/net/can/gw.c b/net/can/gw.c
index acdd465..c185fcd 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -381,9 +381,7 @@ static void can_can_gw_rcv(struct sk_buff *skb, void *data)
 
 	/* is sending the skb back to the incoming interface not allowed? */
 	if (!(gwj->flags & CGW_FLAGS_CAN_IIF_TX_OK) &&
-	    skb_headroom(skb) == sizeof(struct can_skb_priv) &&
-	    (((struct can_skb_priv *)(skb->head))->ifindex ==
-	     gwj->dst.dev->ifindex))
+	    can_skb_prv(skb)->ifindex == gwj->dst.dev->ifindex)
 		return;
 
 	/*
diff --git a/net/can/raw.c b/net/can/raw.c
index 5d860e8..c1764e4 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -705,8 +705,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (!skb)
 		goto put_dev;
 
-	skb_reserve(skb, sizeof(struct can_skb_priv));
-	((struct can_skb_priv *)(skb->head))->ifindex = dev->ifindex;
+	can_skb_reserve(skb);
+	can_skb_prv(skb)->ifindex = dev->ifindex;
 
 	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 	if (err < 0)
