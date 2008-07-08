From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [-stable] can: add sanity checks
Date: Tue, 08 Jul 2008 18:34:50 +0200
Message-ID: <4873972A.3000404@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050807070008060309050501"
Cc: David Miller <davem@davemloft.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Andre Naujoks <nautsch@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: stable@kernel.org, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:9635 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492AbYGHQgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 12:36:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050807070008060309050501
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
Signed-off-by: David S. Miller <davem@davemloft.net>
---


Hello Greg,

please consider this patch for your next 2.6.25-stable. It adds several 
sanity checks for the CAN subsystem and became part of 2.6.26 in 
upstream commit

7f2d38eb7a42bea1c1df51bbdaa2ca0f0bdda07f

For your convenience i added the backported patch that applies directly 
on linux-2.6.25.y.git

Thanks & best regards,
Oliver


--------------050807070008060309050501
Content-Type: text/x-diff;
 name="can-sanity-checks-stable25.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can-sanity-checks-stable25.patch"

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 6b956f5..57594b9 100644
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
 
 	if (dev->type != ARPHRD_CAN || dev->nd_net != &init_net) {
@@ -612,6 +620,8 @@ static int can_rcv(struct sk_buff *skb, struct net_device *dev,
 		return 0;
 	}
 
+	BUG_ON(skb->len != sizeof(struct can_frame) || cf->can_dlc > 8);
+
 	/* update statistics */
 	can_stats.rx_frames++;
 	can_stats.rx_frames_delta++;
diff --git a/net/can/bcm.c b/net/can/bcm.c
index bd4282d..2709292 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -326,7 +326,7 @@ static void bcm_send_to_user(struct bcm_op *op, struct bcm_msg_head *head,
 
 	if (head->nframes) {
 		/* can_frames starting here */
-		firstframe = (struct can_frame *) skb_tail_pointer(skb);
+		firstframe = (struct can_frame *)skb_tail_pointer(skb);
 
 		memcpy(skb_put(skb, datalen), frames, datalen);
 
@@ -818,6 +818,10 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		for (i = 0; i < msg_head->nframes; i++) {
 			err = memcpy_fromiovec((u8 *)&op->frames[i],
 					       msg->msg_iov, CFSIZ);
+
+			if (op->frames[i].can_dlc > 8)
+				err = -EINVAL;
+
 			if (err < 0)
 				return err;
 
@@ -850,6 +854,10 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
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
@@ -1161,9 +1169,12 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk)
 
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
 
@@ -1182,6 +1193,10 @@ static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (!bo->bound)
 		return -ENOTCONN;
 
+	/* check for valid message length from userspace */
+	if (size < MHSIZ || (size - MHSIZ) % CFSIZ)
+		return -EINVAL;
+
 	/* check for alternative ifindex for this bcm_op */
 
 	if (!ifindex && msg->msg_name) {
@@ -1256,8 +1271,8 @@ static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
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
index da26bbb..ba33944 100644
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

--------------050807070008060309050501--
