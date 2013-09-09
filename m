From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 14/16] flexcard: can: CAN local loopback using SKB pflags
Date: Mon,  9 Sep 2013 09:25:11 +0200
Message-ID: <1378711513-2548-15-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38035 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210Ab3IIHnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:43:31 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flexcard receives CAN local loopback in hardware. Include the direction
information from the raw CAN message (DMA) in the pflags of SKB and use it
later in the CAN raw layer.

Signed-off-by: Holger Dengler <dengler@linutronix.de>
---
 drivers/net/can/c_can/c_can_platform.c | 14 +++++++++++---
 include/uapi/linux/can/raw.h           | 20 ++++++++++++++++++++
 net/can/raw.c                          | 22 ++++++----------------
 3 files changed, 37 insertions(+), 19 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index c6c1eb4..d8b99b5 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -35,6 +35,7 @@
 #include <linux/flexcard.h>
 
 #include <linux/can/dev.h>
+#include <linux/can/raw.h>
 
 #include "c_can.h"
 
@@ -125,6 +126,7 @@ static int c_can_rx_pkt(void *p, void *data, size_t len)
 	struct can_frame *frame;
 	struct sk_buff *skb;
 	u32 flags, id, state, type;
+	unsigned int *pflags;
 
 	switch (le32_to_cpu(pb->header.type)) {
 	case fc_packet_type_can:
@@ -142,14 +144,20 @@ static int c_can_rx_pkt(void *p, void *data, size_t len)
 		else
 			frame->can_id = id & CAN_SFF_MASK;
 
+		if (flags & BIT(12)) {
+			pflags = can_raw_flags(skb);
+			*pflags |= CAN_RAW_TX_ECHO;
+		} else {
+			/* No accounting for local echo packages */
+			stats->rx_packets++;
+			stats->rx_bytes += frame->can_dlc;
+		}
+
 		if (flags & BIT(13))
 			frame->can_id |= CAN_RTR_FLAG;
 		frame->can_dlc = (flags >> 8) & 0xf;
 		memcpy(frame->data, pt->can_packet.data, frame->can_dlc);
 		netif_receive_skb(skb);
-
-		stats->rx_packets++;
-		stats->rx_bytes += frame->can_dlc;
 		break;
 
 	case fc_packet_type_can_error:
diff --git a/include/uapi/linux/can/raw.h b/include/uapi/linux/can/raw.h
index a814062..188738c 100644
--- a/include/uapi/linux/can/raw.h
+++ b/include/uapi/linux/can/raw.h
@@ -27,4 +27,24 @@ enum {
 	CAN_RAW_FD_FRAMES,	/* allow CAN FD frames (default:off) */
 };
 
+#ifdef __KERNEL__
+
+#define CAN_RAW_TX_ECHO	0x00000001	/* CAN hardware TX echo packet */
+
+/*
+ * Return pointer to store the extra msg flags for raw_recvmsg().
+ * We use the space of one unsigned int beyond the 'struct sockaddr_can'
+ * in skb->cb.
+ */
+static inline unsigned int *can_raw_flags(struct sk_buff *skb)
+{
+	BUILD_BUG_ON(sizeof(skb->cb) <= (sizeof(struct sockaddr_can) +
+					 sizeof(unsigned int)));
+
+	/* return pointer after struct sockaddr_can */
+	return (unsigned int *)(&((struct sockaddr_can *)skb->cb)[1]);
+}
+
+#endif /* __KERNEL__ */
+
 #endif
diff --git a/net/can/raw.c b/net/can/raw.c
index 641e1c8..80498cf 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -90,20 +90,6 @@ struct raw_sock {
 	can_err_mask_t err_mask;
 };
 
-/*
- * Return pointer to store the extra msg flags for raw_recvmsg().
- * We use the space of one unsigned int beyond the 'struct sockaddr_can'
- * in skb->cb.
- */
-static inline unsigned int *raw_flags(struct sk_buff *skb)
-{
-	BUILD_BUG_ON(sizeof(skb->cb) <= (sizeof(struct sockaddr_can) +
-					 sizeof(unsigned int)));
-
-	/* return pointer after struct sockaddr_can */
-	return (unsigned int *)(&((struct sockaddr_can *)skb->cb)[1]);
-}
-
 static inline struct raw_sock *raw_sk(const struct sock *sk)
 {
 	return (struct raw_sock *)sk;
@@ -117,6 +103,10 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
 	struct sk_buff *skb;
 	unsigned int *pflags;
 
+	pflags = can_raw_flags(oskb);
+	if (*pflags & CAN_RAW_TX_ECHO)
+		oskb->sk = sk;
+
 	/* check the received tx sock reference */
 	if (!ro->recv_own_msgs && oskb->sk == sk)
 		return;
@@ -148,7 +138,7 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
 	addr->can_ifindex = skb->dev->ifindex;
 
 	/* add CAN specific message flags for raw_recvmsg() */
-	pflags = raw_flags(skb);
+	pflags = can_raw_flags(skb);
 	*pflags = 0;
 	if (oskb->sk)
 		*pflags |= MSG_DONTROUTE;
@@ -780,7 +770,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 	/* assign the flags that have been recorded in raw_rcv() */
-	msg->msg_flags |= *(raw_flags(skb));
+	msg->msg_flags |= *(can_raw_flags(skb));
 
 	skb_free_datagram(sk, skb);
 
-- 
1.8.4.rc3
