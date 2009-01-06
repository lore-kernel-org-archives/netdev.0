From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: can: omit unneeded skb_clone() calls
Date: Tue, 06 Jan 2009 10:38:47 +0100
Message-ID: <496326A7.7070405@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050601030509090504060803"
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:16751 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbZAFJiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 04:38:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050601030509090504060803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The AF_CAN core delivered always cloned sk_buffs to the AF_CAN
protocols, although this was _only_ needed by the can-raw protocol.
With this (additionally documented) change, the AF_CAN core calls the
callback functions of the registered AF_CAN protocols with the original
(uncloned) sk_buff pointer and let's the can-raw protocol do the
skb_clone() itself which omits all unneeded skb_clone() calls for other
AF_CAN protocols.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>
---

Hello Dave,

this is a simple (and tested) improvement to omit superfluous 
skb_clone() calls in the CAN core.
Please check if it's ok for the current merge window as it is not really 
a fix.
If it's not ok, i'll resubmit it when net-next-2.6 re-opens.

Thanks,
Oliver

--------------050601030509090504060803
Content-Type: text/x-patch;
 name="omit_skbclone.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="omit_skbclone.patch"

diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index f50785a..25085cb 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -19,7 +19,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 
-#define CAN_VERSION "20081130"
+#define CAN_VERSION "20090105"
 
 /* increment this number each time you change some user-space interface */
 #define CAN_ABI_VERSION "8"
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 3dadb33..fa417ca 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -414,6 +414,12 @@ static struct hlist_head *find_rcv_list(canid_t *can_id, canid_t *mask,
  *  The filter can be inverted (CAN_INV_FILTER bit set in can_id) or it can
  *  filter for error frames (CAN_ERR_FLAG bit set in mask).
  *
+ *  The provided pointer to the sk_buff is guaranteed to be valid as long as
+ *  the callback function is running. The callback function must *not* free
+ *  the given sk_buff while processing it's task. When the given sk_buff is
+ *  needed after the end of the callback function it must be cloned inside
+ *  the callback function with skb_clone().
+ *
  * Return:
  *  0 on success
  *  -ENOMEM on missing cache mem to create subscription entry
@@ -569,13 +575,8 @@ EXPORT_SYMBOL(can_rx_unregister);
 
 static inline void deliver(struct sk_buff *skb, struct receiver *r)
 {
-	struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
-
-	if (clone) {
-		clone->sk = skb->sk;
-		r->func(clone, r->data);
-		r->matches++;
-	}
+	r->func(skb, r->data);
+	r->matches++;
 }
 
 static int can_rcv_filter(struct dev_rcv_lists *d, struct sk_buff *skb)
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 6248ae2..1649c8a 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -633,7 +633,7 @@ static void bcm_rx_handler(struct sk_buff *skb, void *data)
 	hrtimer_cancel(&op->timer);
 
 	if (op->can_id != rxframe->can_id)
-		goto rx_freeskb;
+		return;
 
 	/* save rx timestamp */
 	op->rx_stamp = skb->tstamp;
@@ -645,19 +645,19 @@ static void bcm_rx_handler(struct sk_buff *skb, void *data)
 	if (op->flags & RX_RTR_FRAME) {
 		/* send reply for RTR-request (placed in op->frames[0]) */
 		bcm_can_tx(op);
-		goto rx_freeskb;
+		return;
 	}
 
 	if (op->flags & RX_FILTER_ID) {
 		/* the easiest case */
 		bcm_rx_update_and_send(op, &op->last_frames[0], rxframe);
-		goto rx_freeskb_starttimer;
+		goto rx_starttimer;
 	}
 
 	if (op->nframes == 1) {
 		/* simple compare with index 0 */
 		bcm_rx_cmp_to_index(op, 0, rxframe);
-		goto rx_freeskb_starttimer;
+		goto rx_starttimer;
 	}
 
 	if (op->nframes > 1) {
@@ -678,10 +678,8 @@ static void bcm_rx_handler(struct sk_buff *skb, void *data)
 		}
 	}
 
-rx_freeskb_starttimer:
+rx_starttimer:
 	bcm_rx_starttimer(op);
-rx_freeskb:
-	kfree_skb(skb);
 }
 
 /*
diff --git a/net/can/raw.c b/net/can/raw.c
index 27aab63..f64b7e6 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -99,13 +99,14 @@ static void raw_rcv(struct sk_buff *skb, void *data)
 	struct raw_sock *ro = raw_sk(sk);
 	struct sockaddr_can *addr;
 
-	if (!ro->recv_own_msgs) {
-		/* check the received tx sock reference */
-		if (skb->sk == sk) {
-			kfree_skb(skb);
-			return;
-		}
-	}
+	/* check the received tx sock reference */
+	if ((!ro->recv_own_msgs) && (skb->sk == sk))
+		return;
+
+	/* clone the given skb to be able to enqueue it into the rcv queue */
+	skb = skb_clone(skb, GFP_ATOMIC);
+	if (!skb)
+		return;
 
 	/*
 	 *  Put the datagram to the queue so that raw_recvmsg() can

--------------050601030509090504060803--
