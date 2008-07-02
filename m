From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: can: add sanity checks
Date: Wed, 02 Jul 2008 20:44:48 +0200
Message-ID: <486BCCA0.9040006@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010307030205010701080607"
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Andre Naujoks <nautsch@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:56162 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbYGBSrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 14:47:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010307030205010701080607
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Even though the CAN netlayer only deals with CAN netdevices, the 
netlayer interface to the userspace and to the device layer should 
perform some sanity checks.

This patch adds several sanity checks that mainly prevent userspace apps 
to send broken content into the system that may be misinterpreted by 
some other userspace application.

Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>
Acked-by: Andre Naujoks <nautsch@gmail.com>
---


Hello Dave,

please consider this patch for 2.6.26. It adds several sanity checks 
that turned out to be necessary. I'll additionally cook a patch for 
-stable .25 .

Thanks to Andre Naujoks who accidentally built a really broken userspace 
app :-]

Thanks & best regards,
Oliver

--------------010307030205010701080607
Content-Type: text/x-diff;
 name="can-sanity-checks.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can-sanity-checks.patch"

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 7e8ca28..484bbf6 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -205,12 +205,19 @@ static int can_create(struct net *net, struct socket *sock, int protocol)
  *  -ENOBUFS on full driver queue (see net_xmit_errno())
  *  -ENOMEM when local loopback failed at calling skb_clone()
  *  -EPERM when trying to send on a non-CAN interface
+ *  -EINVAL when the skb->data does not contain a valid CAN frame
  */
 int can_send(struct sk_buff *skb, int loop)
 {
 	struct sk_buff *newskb = NULL;
+	struct can_frame *cf = (struct can_frame *)skb->data;
 	int err;
 
+	if (skb->len != sizeof(struct can_frame) || cf->can_dlc > 8) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
 	if (skb->dev->type != ARPHRD_CAN) {
 		kfree_skb(skb);
 		return -EPERM;
@@ -605,6 +612,7 @@ static int can_rcv(struct sk_buff *skb, struct net_device *dev,
 		   struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct dev_rcv_lists *d;
+	struct can_frame *cf = (struct can_frame *)skb->data;
 	int matches;
 
 	if (dev->type != ARPHRD_CAN || dev_net(dev) != &init_net) {
@@ -612,6 +620,8 @@ static int can_rcv(struct sk_buff *skb, struct net_device *dev,
 		return 0;
 	}
 
+	BUG_ON(skb->len != sizeof(struct can_frame) || cf->can_dlc > 8);
+
 	/* update statistics */
 	can_stats.rx_frames++;
 	can_stats.rx_frames_delta++;
diff --git a/net/can/bcm.c b/net/can/bcm.c
index d9a3a9d..72c2ce9 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -298,7 +298,7 @@ static void bcm_send_to_user(struct bcm_op *op, struct bcm_msg_head *head,
 
 	if (head->nframes) {
 		/* can_frames starting here */
-		firstframe = (struct can_frame *) skb_tail_pointer(skb);
+		firstframe = (struct can_frame *)skb_tail_pointer(skb);
 
 		memcpy(skb_put(skb, datalen), frames, datalen);
 
@@ -826,6 +826,10 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		for (i = 0; i < msg_head->nframes; i++) {
 			err = memcpy_fromiovec((u8 *)&op->frames[i],
 					       msg->msg_iov, CFSIZ);
+
+			if (op->frames[i].can_dlc > 8)
+				err = -EINVAL;
+
 			if (err < 0)
 				return err;
 
@@ -858,6 +862,10 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		for (i = 0; i < msg_head->nframes; i++) {
 			err = memcpy_fromiovec((u8 *)&op->frames[i],
 					       msg->msg_iov, CFSIZ);
+
+			if (op->frames[i].can_dlc > 8)
+				err = -EINVAL;
+
 			if (err < 0) {
 				if (op->frames != &op->sframe)
 					kfree(op->frames);
@@ -1164,9 +1172,12 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk)
 
 	skb->dev = dev;
 	skb->sk  = sk;
-	can_send(skb, 1); /* send with loopback */
+	err = can_send(skb, 1); /* send with loopback */
 	dev_put(dev);
 
+	if (err)
+		return err;
+
 	return CFSIZ + MHSIZ;
 }
 
@@ -1185,6 +1196,10 @@ static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (!bo->bound)
 		return -ENOTCONN;
 
+	/* check for valid message length from userspace */
+	if (size < MHSIZ || (size - MHSIZ) % CFSIZ)
+		return -EINVAL;
+
 	/* check for alternative ifindex for this bcm_op */
 
 	if (!ifindex && msg->msg_name) {
@@ -1259,8 +1274,8 @@ static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
 		break;
 
 	case TX_SEND:
-		/* we need at least one can_frame */
-		if (msg_head.nframes < 1)
+		/* we need exactly one can_frame behind the msg head */
+		if ((msg_head.nframes != 1) || (size != CFSIZ + MHSIZ))
 			ret = -EINVAL;
 		else
 			ret = bcm_tx_send(msg, ifindex, sk);
diff --git a/net/can/raw.c b/net/can/raw.c
index 69877b8..3e46ee3 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -632,6 +632,9 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	} else
 		ifindex = ro->ifindex;
 
+	if (size != sizeof(struct can_frame))
+		return -EINVAL;
+
 	dev = dev_get_by_index(&init_net, ifindex);
 	if (!dev)
 		return -ENXIO;

--------------010307030205010701080607--
