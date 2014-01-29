From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH stable 3.11+] can: use private sk reference to detect originating
 socket
Date: Wed, 29 Jan 2014 14:44:40 +0100
Message-ID: <52E905C8.1060408@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.163]:9029 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbaA2Noy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 08:44:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 376c7311bdb6 (net: add a temporary sanity check in skb_orphan())
leads to a BUG in can_put_echo_skb() when skb_orphan() is executed.

The use of skb->sk to detect the originating socket can lead to side effects
in net/core and net/sched. Therefore the reference needed in net/can/raw.c is
now stored in a CAN private skbuff space in struct can_skb_priv.

The reference which comes with the CAN frame is only needed in raw_rcv() and
checked against his own sock pointer and does only special things if it
matches. So removing the socket does not hurt as the in-flight skbs are
removed and the receive filters are purged anyway when the socket disappears.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

Here's my idea to fix up the original skb->sk handling concept for detecting
the originating socket instance. The patch applies properly down to 3.11.

Eric please take a look if I used sock_alloc_send_skb() correctly in bcm.c.
Andre please check if you see any functional differences on your machine.

Tnx & regards,
Oliver

ps. I would suggest to move the BUG() in WARN_ON_ONCE() to fulfill the
requirement to detect a possible misuse but not kill the entire machine.
BUG() is intended to be used when there's no way to continue any reasonable
operation. Detecting and fixing this issue half a year after the "temporary
sanity check" has been integrated is a bad example for using BUG() IMO.

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 13a9098..6d51fb7 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -323,7 +323,6 @@ void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	if (!priv->echo_skb[idx]) {
-		struct sock *srcsk = skb->sk;
 
 		if (atomic_read(&skb->users) != 1) {
 			struct sk_buff *old_skb = skb;
@@ -335,8 +334,6 @@ void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
 		} else
 			skb_orphan(skb);
 
-		skb->sk = srcsk;
-
 		/* make settings for echo to reduce code in irq context */
 		skb->protocol = htons(ETH_P_CAN);
 		skb->pkt_type = PACKET_BROADCAST;
@@ -513,6 +510,7 @@ struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf)
 
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = dev->ifindex;
+	can_skb_prv(skb)->src_sk = NULL;
 
 	*cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
 	memset(*cf, 0, sizeof(struct can_frame));
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index e24e669..d27a1c9 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1133,8 +1133,6 @@ static void ican3_handle_message(struct ican3_dev *mod, struct ican3_msg *msg)
  */
 static void ican3_put_echo_skb(struct ican3_dev *mod, struct sk_buff *skb)
 {
-	struct sock *srcsk = skb->sk;
-
 	if (atomic_read(&skb->users) != 1) {
 		struct sk_buff *old_skb = skb;
 
@@ -1142,11 +1140,8 @@ static void ican3_put_echo_skb(struct ican3_dev *mod, struct sk_buff *skb)
 		kfree_skb(old_skb);
 		if (!skb)
 			return;
-	} else {
+	} else
 		skb_orphan(skb);
-	}
-
-	skb->sk = srcsk;
 
 	/* save this skb for tx interrupt echo handling */
 	skb_queue_tail(&mod->echoq, skb);
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 3fcdae2..44766c18 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -215,6 +215,7 @@ static void slc_bump(struct slcan *sl)
 
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = sl->dev->ifindex;
+	can_skb_prv(skb)->src_sk = NULL;
 
 	memcpy(skb_put(skb, sizeof(struct can_frame)),
 	       &cf, sizeof(struct can_frame));
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 0a2a5ee..1a89116 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -116,14 +116,11 @@ static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
 	/* perform standard echo handling for CAN network interfaces */
 
 	if (loop) {
-		struct sock *srcsk = skb->sk;
-
 		skb = skb_share_check(skb, GFP_ATOMIC);
 		if (!skb)
 			return NETDEV_TX_OK;
 
 		/* receive with packet counting */
-		skb->sk = srcsk;
 		vcan_rx(skb, dev);
 	} else {
 		/* no looped packets => no counting */
diff --git a/include/linux/can/skb.h b/include/linux/can/skb.h
index 2f0543f..a8dc078 100644
--- a/include/linux/can/skb.h
+++ b/include/linux/can/skb.h
@@ -25,10 +25,12 @@
 /**
  * struct can_skb_priv - private additional data inside CAN sk_buffs
  * @ifindex:	ifindex of the first interface the CAN frame appeared on
+ * @src_sk:	pointer to the originating sock to detect self generated skbs
  * @cf:		align to the following CAN frame at skb->data
  */
 struct can_skb_priv {
 	int ifindex;
+	struct sock *src_sk;
 	struct can_frame cf[0];
 };
 
diff --git a/net/can/af_can.c b/net/can/af_can.c
index d249874..6ed6a23 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -270,15 +270,6 @@ int can_send(struct sk_buff *skb, int loop)
 		/* indication for the CAN driver: do loopback */
 		skb->pkt_type = PACKET_LOOPBACK;
 
-		/*
-		 * The reference to the originating sock may be required
-		 * by the receiving socket to check whether the frame is
-		 * its own. Example: can_raw sockopt CAN_RAW_RECV_OWN_MSGS
-		 * Therefore we have to ensure that skb->sk remains the
-		 * reference to the originating sock by restoring skb->sk
-		 * after each skb_clone() or skb_orphan() usage.
-		 */
-
 		if (!(skb->dev->flags & IFF_ECHO)) {
 			/*
 			 * If the interface is not capable to do loopback
@@ -290,7 +281,6 @@ int can_send(struct sk_buff *skb, int loop)
 				return -ENOMEM;
 			}
 
-			newskb->sk = skb->sk;
 			newskb->ip_summed = CHECKSUM_UNNECESSARY;
 			newskb->pkt_type = PACKET_BROADCAST;
 		}
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 3fc737b..f10f521 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -245,7 +245,9 @@ static void bcm_can_tx(struct bcm_op *op)
 {
 	struct sk_buff *skb;
 	struct net_device *dev;
+	struct sock *sk = op->sk;
 	struct can_frame *cf = &op->frames[op->currframe];
+	int err;
 
 	/* no target device? => exit */
 	if (!op->ifindex)
@@ -257,18 +259,23 @@ static void bcm_can_tx(struct bcm_op *op)
 		return;
 	}
 
-	skb = alloc_skb(CFSIZ + sizeof(struct can_skb_priv), gfp_any());
+	/*
+	 * we are probably in softirq context (timer, net-rx):
+	 * get an unblocked skb
+	 */
+	sk->sk_allocation = GFP_ATOMIC;
+	skb = sock_alloc_send_skb(sk, CFSIZ + sizeof(struct can_skb_priv),
+				  1, &err);
 	if (!skb)
 		goto out;
 
 	can_skb_reserve(skb);
-	can_skb_prv(skb)->ifindex = dev->ifindex;
-
 	memcpy(skb_put(skb, CFSIZ), cf, CFSIZ);
 
 	/* send with loopback */
+	can_skb_prv(skb)->ifindex = dev->ifindex;
+	can_skb_prv(skb)->src_sk = sk;
 	skb->dev = dev;
-	skb->sk = op->sk;
 	can_send(skb, 1);
 
 	/* update statistics */
@@ -1203,12 +1210,13 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk)
 	if (!ifindex)
 		return -ENODEV;
 
-	skb = alloc_skb(CFSIZ + sizeof(struct can_skb_priv), GFP_KERNEL);
+	/* get an unblocked skb */
+	skb = sock_alloc_send_skb(sk, CFSIZ + sizeof(struct can_skb_priv),
+				  1, &err);
 	if (!skb)
 		return -ENOMEM;
 
 	can_skb_reserve(skb);
-
 	err = memcpy_fromiovec(skb_put(skb, CFSIZ), msg->msg_iov, CFSIZ);
 	if (err < 0) {
 		kfree_skb(skb);
@@ -1221,10 +1229,11 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk)
 		return -ENODEV;
 	}
 
-	can_skb_prv(skb)->ifindex = dev->ifindex;
+	/* send with loopback */
+	can_skb_prv(skb)->ifindex = ifindex;
+	can_skb_prv(skb)->src_sk = sk;
 	skb->dev = dev;
-	skb->sk  = sk;
-	err = can_send(skb, 1); /* send with loopback */
+	err = can_send(skb, 1);
 	dev_put(dev);
 
 	if (err)
diff --git a/net/can/raw.c b/net/can/raw.c
index 07d72d8..7e67560 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -113,12 +113,13 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
 {
 	struct sock *sk = (struct sock *)data;
 	struct raw_sock *ro = raw_sk(sk);
+	struct sock *src_sk = can_skb_prv(oskb)->src_sk;
 	struct sockaddr_can *addr;
 	struct sk_buff *skb;
 	unsigned int *pflags;
 
 	/* check the received tx sock reference */
-	if (!ro->recv_own_msgs && oskb->sk == sk)
+	if (!ro->recv_own_msgs && src_sk == sk)
 		return;
 
 	/* do not pass frames with DLC > 8 to a legacy socket */
@@ -150,9 +151,9 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
 	/* add CAN specific message flags for raw_recvmsg() */
 	pflags = raw_flags(skb);
 	*pflags = 0;
-	if (oskb->sk)
+	if (src_sk)
 		*pflags |= MSG_DONTROUTE;
-	if (oskb->sk == sk)
+	if (src_sk == sk)
 		*pflags |= MSG_CONFIRM;
 
 	if (sock_queue_rcv_skb(sk, skb) < 0)
@@ -705,17 +706,15 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 		goto put_dev;
 
 	can_skb_reserve(skb);
-	can_skb_prv(skb)->ifindex = dev->ifindex;
-
 	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 	if (err < 0)
 		goto free_skb;
 
 	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 
+	can_skb_prv(skb)->ifindex = dev->ifindex;
+	can_skb_prv(skb)->src_sk = sk;
 	skb->dev = dev;
-	skb->sk  = sk;
-
 	err = can_send(skb, ro->loopback);
 
 	dev_put(dev);
