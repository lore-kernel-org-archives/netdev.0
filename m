From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 31/47] Bluetooth: Add initial support for ERTM packets transfers
Date: Sun, 30 Aug 2009 01:50:45 -0700
Message-ID: <1c2acffb76d4bc5fd27c4ea55cc27ad8ead10f9a.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
 <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
 <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
 <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
 <9666fb356da78a5ec28403197d72e8cd6aa16424.1251621661.git.marcel@holtmann.org>
 <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
 <91d697302b291205171840bfe84c1563e171acb2.1251621661.git.marcel@holtmann.org>
 <e0721f99ba33d13a88746732be2d74ca805abf55.1251621661.git.marcel@holtmann.org>
 <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
 <3318b2362bf0528be77123c480249663557dfbfc.1251621661.git.marcel@holtmann.org>
 <5959809ded86e267c1a95fb44738a224c30d3434.1251621661.git.marcel@holtmann.org>
 <a6a67efd7088702fdbbb780c5a3f8e1a74e77b63.1251621661.git.marcel@holtmann.org>
 <52d18347dfb61519aa0f58fe1759edd3ad8c4e36.1251621661.git.marcel@holtmann.org>
 <44dd46de325c4d47abfd1361e5d84a548edb8e42.1251621661.git.marcel@holtmann.org>
 <c6b03cf986eab00e20d0dbc852b233bb83472138.1251621661.git.marcel@holtmann.org>
 <65c7c4918450f8c4545ccb02a9c7a3d77e073535.1251621661.git.marcel@holtmann.org>
 <f2fcfcd670257236ebf2088bbdf26f6a8ef459fe.1251621661.git.marcel@holtmann.org>
 <22121fc9152ca8f25a2d790860832ccb6a414c4d.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53318 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbZH3Iw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:28 -0400
In-Reply-To: <22121fc9152ca8f25a2d790860832ccb6a414c4d.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

This patch adds support for ERTM transfers, without retransmission, with
txWindow up to 63 and with acknowledgement of packets received. Now the
packets are queued before call l2cap_do_send(), so packets couldn't be
sent at the time we call l2cap_sock_sendmsg(). They will be sent in
an asynchronous way on later calls of l2cap_ertm_send(). Besides if an
error occurs on calling l2cap_do_send() we disconnect the channel.

Initially based on a patch from Nathan Holstein <nathan@lampreynetworks.com>

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/bluetooth.h |    3 +-
 include/net/bluetooth/l2cap.h     |   54 +++++-
 net/bluetooth/l2cap.c             |  384 ++++++++++++++++++++++++++++++++-----
 3 files changed, 390 insertions(+), 51 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 968166a..65a5cf8 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -138,8 +138,9 @@ struct sock *bt_accept_dequeue(struct sock *parent, struct socket *newsock);
 struct bt_skb_cb {
 	__u8 pkt_type;
 	__u8 incoming;
+	__u8 tx_seq;
 };
-#define bt_cb(skb) ((struct bt_skb_cb *)(skb->cb)) 
+#define bt_cb(skb) ((struct bt_skb_cb *)((skb)->cb))
 
 static inline struct sk_buff *bt_skb_alloc(unsigned int len, gfp_t how)
 {
diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 6fc7698..9bbfbe7 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -29,7 +29,8 @@
 #define L2CAP_DEFAULT_MTU		672
 #define L2CAP_DEFAULT_MIN_MTU		48
 #define L2CAP_DEFAULT_FLUSH_TO		0xffff
-#define L2CAP_DEFAULT_TX_WINDOW		1
+#define L2CAP_DEFAULT_TX_WINDOW		63
+#define L2CAP_DEFAULT_NUM_TO_ACK        (L2CAP_DEFAULT_TX_WINDOW/5)
 #define L2CAP_DEFAULT_MAX_RECEIVE	1
 #define L2CAP_DEFAULT_RETRANS_TO	300    /* 300 milliseconds */
 #define L2CAP_DEFAULT_MONITOR_TO	1000   /* 1 second */
@@ -94,6 +95,31 @@ struct l2cap_conninfo {
 #define L2CAP_FCS_NONE		0x00
 #define L2CAP_FCS_CRC16		0x01
 
+/* L2CAP Control Field bit masks */
+#define L2CAP_CTRL_SAR               0xC000
+#define L2CAP_CTRL_REQSEQ            0x3F00
+#define L2CAP_CTRL_TXSEQ             0x007E
+#define L2CAP_CTRL_RETRANS           0x0080
+#define L2CAP_CTRL_FINAL             0x0080
+#define L2CAP_CTRL_POLL              0x0010
+#define L2CAP_CTRL_SUPERVISE         0x000C
+#define L2CAP_CTRL_FRAME_TYPE        0x0001 /* I- or S-Frame */
+
+#define L2CAP_CTRL_TXSEQ_SHIFT      1
+#define L2CAP_CTRL_REQSEQ_SHIFT     8
+
+/* L2CAP Supervisory Function */
+#define L2CAP_SUPER_RCV_READY           0x0000
+#define L2CAP_SUPER_REJECT              0x0004
+#define L2CAP_SUPER_RCV_NOT_READY       0x0008
+#define L2CAP_SUPER_SELECT_REJECT       0x000C
+
+/* L2CAP Segmentation and Reassembly */
+#define L2CAP_SDU_UNSEGMENTED       0x0000
+#define L2CAP_SDU_START             0x4000
+#define L2CAP_SDU_END               0x8000
+#define L2CAP_SDU_CONTINUE          0xC000
+
 /* L2CAP structures */
 struct l2cap_hdr {
 	__le16     len;
@@ -262,6 +288,7 @@ struct l2cap_conn {
 
 /* ----- L2CAP channel and socket info ----- */
 #define l2cap_pi(sk) ((struct l2cap_pinfo *) sk)
+#define TX_QUEUE(sk) (&l2cap_pi(sk)->tx_queue)
 
 struct l2cap_pinfo {
 	struct bt_sock	bt;
@@ -285,6 +312,13 @@ struct l2cap_pinfo {
 	__u8		conf_len;
 	__u8		conf_state;
 
+	__u8		next_tx_seq;
+	__u8		expected_ack_seq;
+	__u8		req_seq;
+	__u8		expected_tx_seq;
+	__u8		unacked_frames;
+	__u8		num_to_ack;
+
 	__u8		ident;
 
 	__u8		remote_tx_win;
@@ -295,6 +329,7 @@ struct l2cap_pinfo {
 
 	__le16		sport;
 
+	struct sk_buff_head	tx_queue;
 	struct l2cap_conn	*conn;
 	struct sock		*next_c;
 	struct sock		*prev_c;
@@ -311,6 +346,23 @@ struct l2cap_pinfo {
 #define L2CAP_CONF_MAX_CONF_REQ 2
 #define L2CAP_CONF_MAX_CONF_RSP 2
 
+static inline int l2cap_tx_window_full(struct sock *sk)
+{
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	int sub;
+
+	sub = (pi->next_tx_seq - pi->expected_ack_seq) % 64;
+
+	if (sub < 0)
+		sub += 64;
+
+	return (sub == pi->remote_tx_win);
+}
+
+#define __get_txseq(ctrl) ((ctrl) & L2CAP_CTRL_TXSEQ) >> 1
+#define __get_reqseq(ctrl) ((ctrl) & L2CAP_CTRL_REQSEQ) >> 8
+#define __is_iframe(ctrl) !((ctrl) & L2CAP_CTRL_FRAME_TYPE)
+#define __is_sframe(ctrl) (ctrl) & L2CAP_CTRL_FRAME_TYPE
 
 void l2cap_load(void);
 
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index c1b5620..45b8697 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -333,6 +333,30 @@ static inline int l2cap_send_cmd(struct l2cap_conn *conn, u8 ident, u8 code, u16
 	return hci_send_acl(conn->hcon, skb, 0);
 }
 
+static inline int l2cap_send_sframe(struct l2cap_pinfo *pi, u16 control)
+{
+	struct sk_buff *skb;
+	struct l2cap_hdr *lh;
+	struct l2cap_conn *conn = pi->conn;
+	int count;
+
+	BT_DBG("pi %p, control 0x%2.2x", pi, control);
+
+	count = min_t(unsigned int, conn->mtu, L2CAP_HDR_SIZE + 2);
+	control |= L2CAP_CTRL_FRAME_TYPE;
+
+	skb = bt_skb_alloc(count, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+
+	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh->len = cpu_to_le16(2);
+	lh->cid = cpu_to_le16(pi->dcid);
+	put_unaligned_le16(control, skb_put(skb, 2));
+
+	return hci_send_acl(pi->conn->hcon, skb, 0);
+}
+
 static void l2cap_do_start(struct sock *sk)
 {
 	struct l2cap_conn *conn = l2cap_pi(sk)->conn;
@@ -1154,39 +1178,80 @@ static int l2cap_sock_getname(struct socket *sock, struct sockaddr *addr, int *l
 	return 0;
 }
 
-static inline int l2cap_do_send(struct sock *sk, struct msghdr *msg, int len)
+static void l2cap_drop_acked_frames(struct sock *sk)
 {
-	struct l2cap_conn *conn = l2cap_pi(sk)->conn;
-	struct sk_buff *skb, **frag;
-	int err, hlen, count, sent = 0;
-	struct l2cap_hdr *lh;
+	struct sk_buff *skb;
 
-	BT_DBG("sk %p len %d", sk, len);
+	while ((skb = skb_peek(TX_QUEUE(sk)))) {
+		if (bt_cb(skb)->tx_seq == l2cap_pi(sk)->expected_ack_seq)
+			break;
 
-	/* First fragment (with L2CAP header) */
-	if (sk->sk_type == SOCK_DGRAM)
-		hlen = L2CAP_HDR_SIZE + 2;
-	else
-		hlen = L2CAP_HDR_SIZE;
+		skb = skb_dequeue(TX_QUEUE(sk));
+		kfree_skb(skb);
 
-	count = min_t(unsigned int, (conn->mtu - hlen), len);
+		l2cap_pi(sk)->unacked_frames--;
+	}
 
-	skb = bt_skb_send_alloc(sk, hlen + count,
-			msg->msg_flags & MSG_DONTWAIT, &err);
-	if (!skb)
-		return err;
+	return;
+}
 
-	/* Create L2CAP header */
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
-	lh->cid = cpu_to_le16(l2cap_pi(sk)->dcid);
-	lh->len = cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
+static inline int l2cap_do_send(struct sock *sk, struct sk_buff *skb)
+{
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	int err;
+
+	BT_DBG("sk %p, skb %p len %d", sk, skb, skb->len);
+
+	err = hci_send_acl(pi->conn->hcon, skb, 0);
+	if (err < 0)
+		kfree_skb(skb);
+
+	return err;
+}
+
+static int l2cap_ertm_send(struct sock *sk)
+{
+	struct sk_buff *skb, *tx_skb;
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	u16 control;
+	int err;
+
+	while ((skb = sk->sk_send_head) && (!l2cap_tx_window_full(sk))) {
+		tx_skb = skb_clone(skb, GFP_ATOMIC);
 
-	if (sk->sk_type == SOCK_DGRAM)
-		put_unaligned(l2cap_pi(sk)->psm, (__le16 *) skb_put(skb, 2));
+		control = get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
+		control |= (pi->req_seq << L2CAP_CTRL_REQSEQ_SHIFT)
+				| (pi->next_tx_seq << L2CAP_CTRL_TXSEQ_SHIFT);
+		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
+
+		err = l2cap_do_send(sk, tx_skb);
+		if (err < 0) {
+			l2cap_send_disconn_req(pi->conn, sk);
+			return err;
+		}
+
+		bt_cb(skb)->tx_seq = pi->next_tx_seq;
+		pi->next_tx_seq = (pi->next_tx_seq + 1) % 64;
+
+		pi->unacked_frames++;
+
+		if (skb_queue_is_last(TX_QUEUE(sk), skb))
+			sk->sk_send_head = NULL;
+		else
+			sk->sk_send_head = skb_queue_next(TX_QUEUE(sk), skb);
+	}
+
+	return 0;
+}
+
+static inline int l2cap_skbuff_fromiovec(struct sock *sk, struct msghdr *msg, int len, int count, struct sk_buff *skb)
+{
+	struct l2cap_conn *conn = l2cap_pi(sk)->conn;
+	struct sk_buff **frag;
+	int err, sent = 0;
 
 	if (memcpy_fromiovec(skb_put(skb, count), msg->msg_iov, count)) {
-		err = -EFAULT;
-		goto fail;
+		return -EFAULT;
 	}
 
 	sent += count;
@@ -1199,33 +1264,112 @@ static inline int l2cap_do_send(struct sock *sk, struct msghdr *msg, int len)
 
 		*frag = bt_skb_send_alloc(sk, count, msg->msg_flags & MSG_DONTWAIT, &err);
 		if (!*frag)
-			goto fail;
-
-		if (memcpy_fromiovec(skb_put(*frag, count), msg->msg_iov, count)) {
-			err = -EFAULT;
-			goto fail;
-		}
+			return -EFAULT;
+		if (memcpy_fromiovec(skb_put(*frag, count), msg->msg_iov, count))
+			return -EFAULT;
 
 		sent += count;
 		len  -= count;
 
 		frag = &(*frag)->next;
 	}
-	err = hci_send_acl(conn->hcon, skb, 0);
-	if (err < 0)
-		goto fail;
 
 	return sent;
+}
 
-fail:
-	kfree_skb(skb);
-	return err;
+static struct sk_buff *l2cap_create_connless_pdu(struct sock *sk, struct msghdr *msg, size_t len)
+{
+	struct l2cap_conn *conn = l2cap_pi(sk)->conn;
+	struct sk_buff *skb;
+	int err, count, hlen = L2CAP_HDR_SIZE + 2;
+	struct l2cap_hdr *lh;
+
+	BT_DBG("sk %p len %d", sk, (int)len);
+
+	count = min_t(unsigned int, (conn->mtu - hlen), len);
+	skb = bt_skb_send_alloc(sk, count + hlen,
+			msg->msg_flags & MSG_DONTWAIT, &err);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
+	/* Create L2CAP header */
+	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh->cid = cpu_to_le16(l2cap_pi(sk)->dcid);
+	lh->len = cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
+	put_unaligned_le16(l2cap_pi(sk)->psm, skb_put(skb, 2));
+
+	err = l2cap_skbuff_fromiovec(sk, msg, len, count, skb);
+	if (unlikely(err < 0)) {
+		kfree_skb(skb);
+		return ERR_PTR(err);
+	}
+	return skb;
+}
+
+static struct sk_buff *l2cap_create_basic_pdu(struct sock *sk, struct msghdr *msg, size_t len)
+{
+	struct l2cap_conn *conn = l2cap_pi(sk)->conn;
+	struct sk_buff *skb;
+	int err, count, hlen = L2CAP_HDR_SIZE;
+	struct l2cap_hdr *lh;
+
+	BT_DBG("sk %p len %d", sk, (int)len);
+
+	count = min_t(unsigned int, (conn->mtu - hlen), len);
+	skb = bt_skb_send_alloc(sk, count + hlen,
+			msg->msg_flags & MSG_DONTWAIT, &err);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
+	/* Create L2CAP header */
+	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh->cid = cpu_to_le16(l2cap_pi(sk)->dcid);
+	lh->len = cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
+
+	err = l2cap_skbuff_fromiovec(sk, msg, len, count, skb);
+	if (unlikely(err < 0)) {
+		kfree_skb(skb);
+		return ERR_PTR(err);
+	}
+	return skb;
+}
+
+static struct sk_buff *l2cap_create_ertm_pdu(struct sock *sk, struct msghdr *msg, size_t len, u16 control)
+{
+	struct l2cap_conn *conn = l2cap_pi(sk)->conn;
+	struct sk_buff *skb;
+	int err, count, hlen = L2CAP_HDR_SIZE + 2;
+	struct l2cap_hdr *lh;
+
+	BT_DBG("sk %p len %d", sk, (int)len);
+
+	count = min_t(unsigned int, (conn->mtu - hlen), len);
+	skb = bt_skb_send_alloc(sk, count + hlen,
+			msg->msg_flags & MSG_DONTWAIT, &err);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
+	/* Create L2CAP header */
+	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh->cid = cpu_to_le16(l2cap_pi(sk)->dcid);
+	lh->len = cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
+	put_unaligned_le16(control, skb_put(skb, 2));
+
+	err = l2cap_skbuff_fromiovec(sk, msg, len, count, skb);
+	if (unlikely(err < 0)) {
+		kfree_skb(skb);
+		return ERR_PTR(err);
+	}
+	return skb;
 }
 
 static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	int err = 0;
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	struct sk_buff *skb;
+	u16 control;
+	int err;
 
 	BT_DBG("sock %p, sk %p", sock, sk);
 
@@ -1237,16 +1381,67 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct ms
 		return -EOPNOTSUPP;
 
 	/* Check outgoing MTU */
-	if (sk->sk_type != SOCK_RAW && len > l2cap_pi(sk)->omtu)
+	if (sk->sk_type == SOCK_SEQPACKET && pi->mode == L2CAP_MODE_BASIC
+			&& len > pi->omtu)
 		return -EINVAL;
 
 	lock_sock(sk);
 
-	if (sk->sk_state == BT_CONNECTED)
-		err = l2cap_do_send(sk, msg, len);
-	else
+	if (sk->sk_state != BT_CONNECTED) {
 		err = -ENOTCONN;
+		goto done;
+	}
+
+	/* Connectionless channel */
+	if (sk->sk_type == SOCK_DGRAM) {
+		skb = l2cap_create_connless_pdu(sk, msg, len);
+		err = l2cap_do_send(sk, skb);
+		goto done;
+	}
 
+	switch (pi->mode) {
+	case L2CAP_MODE_BASIC:
+		/* Create a basic PDU */
+		skb = l2cap_create_basic_pdu(sk, msg, len);
+		if (IS_ERR(skb)) {
+			err = PTR_ERR(skb);
+			goto done;
+		}
+
+		err = l2cap_do_send(sk, skb);
+		if (!err)
+			err = len;
+		break;
+
+	case L2CAP_MODE_ERTM:
+		/* Entire SDU fits into one PDU */
+		if (len <= pi->omtu) {
+			control = L2CAP_SDU_UNSEGMENTED;
+			skb = l2cap_create_ertm_pdu(sk, msg, len, control);
+			if (IS_ERR(skb)) {
+				err = PTR_ERR(skb);
+				goto done;
+			}
+		} else {
+			/* FIXME: Segmentation will be added later */
+			err = -EINVAL;
+			goto done;
+		}
+		__skb_queue_tail(TX_QUEUE(sk), skb);
+		if (sk->sk_send_head == NULL)
+			sk->sk_send_head = skb;
+
+		err = l2cap_ertm_send(sk);
+		if (!err)
+			err = len;
+		break;
+
+	default:
+		BT_DBG("bad state %1.1x", pi->mode);
+		err = -EINVAL;
+	}
+
+done:
 	release_sock(sk);
 	return err;
 }
@@ -2301,6 +2496,10 @@ static inline int l2cap_config_req(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 
 	if (l2cap_pi(sk)->conf_state & L2CAP_CONF_INPUT_DONE) {
 		sk->sk_state = BT_CONNECTED;
+		l2cap_pi(sk)->next_tx_seq = 0;
+		l2cap_pi(sk)->expected_ack_seq = 0;
+		l2cap_pi(sk)->unacked_frames = 0;
+		__skb_queue_head_init(TX_QUEUE(sk));
 		l2cap_chan_ready(sk);
 		goto unlock;
 	}
@@ -2375,6 +2574,9 @@ static inline int l2cap_config_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 
 	if (l2cap_pi(sk)->conf_state & L2CAP_CONF_OUTPUT_DONE) {
 		sk->sk_state = BT_CONNECTED;
+		l2cap_pi(sk)->expected_tx_seq = 0;
+		l2cap_pi(sk)->num_to_ack = 0;
+		__skb_queue_head_init(TX_QUEUE(sk));
 		l2cap_chan_ready(sk);
 	}
 
@@ -2405,6 +2607,8 @@ static inline int l2cap_disconnect_req(struct l2cap_conn *conn, struct l2cap_cmd
 
 	sk->sk_shutdown = SHUTDOWN_MASK;
 
+	skb_queue_purge(TX_QUEUE(sk));
+
 	l2cap_chan_del(sk, ECONNRESET);
 	bh_unlock_sock(sk);
 
@@ -2427,6 +2631,8 @@ static inline int l2cap_disconnect_rsp(struct l2cap_conn *conn, struct l2cap_cmd
 	if (!sk)
 		return 0;
 
+	skb_queue_purge(TX_QUEUE(sk));
+
 	l2cap_chan_del(sk, 0);
 	bh_unlock_sock(sk);
 
@@ -2602,9 +2808,60 @@ static inline void l2cap_sig_channel(struct l2cap_conn *conn, struct sk_buff *sk
 	kfree_skb(skb);
 }
 
+static inline int l2cap_data_channel_iframe(struct sock *sk, u16 rx_control, struct sk_buff *skb)
+{
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	u8 tx_seq = __get_txseq(rx_control);
+	u16 tx_control = 0;
+	int err = 0;
+
+	BT_DBG("sk %p rx_control 0x%4.4x len %d", sk, rx_control, skb->len);
+
+	if (tx_seq != pi->expected_tx_seq)
+		return -EINVAL;
+
+	pi->expected_tx_seq = (pi->expected_tx_seq + 1) % 64;
+	err = sock_queue_rcv_skb(sk, skb);
+	if (err)
+		return err;
+
+	pi->num_to_ack = (pi->num_to_ack + 1) % L2CAP_DEFAULT_NUM_TO_ACK;
+	if (pi->num_to_ack == L2CAP_DEFAULT_NUM_TO_ACK - 1) {
+		tx_control |= L2CAP_CTRL_FRAME_TYPE;
+		tx_control |= L2CAP_SUPER_RCV_READY;
+		tx_control |= pi->expected_tx_seq << L2CAP_CTRL_REQSEQ_SHIFT;
+		err = l2cap_send_sframe(pi, tx_control);
+	}
+	return err;
+}
+
+static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, struct sk_buff *skb)
+{
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+
+	BT_DBG("sk %p rx_control 0x%4.4x len %d", sk, rx_control, skb->len);
+
+	switch (rx_control & L2CAP_CTRL_SUPERVISE) {
+	case L2CAP_SUPER_RCV_READY:
+		pi->expected_ack_seq = __get_reqseq(rx_control);
+		l2cap_drop_acked_frames(sk);
+		l2cap_ertm_send(sk);
+		break;
+
+	case L2CAP_SUPER_RCV_NOT_READY:
+	case L2CAP_SUPER_REJECT:
+	case L2CAP_SUPER_SELECT_REJECT:
+		break;
+	}
+
+	return 0;
+}
+
 static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk_buff *skb)
 {
 	struct sock *sk;
+	u16 control;
+	int err;
 
 	sk = l2cap_get_chan_by_scid(&conn->chan_list, cid);
 	if (!sk) {
@@ -2617,16 +2874,40 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 	if (sk->sk_state != BT_CONNECTED)
 		goto drop;
 
-	if (l2cap_pi(sk)->imtu < skb->len)
-		goto drop;
+	switch (l2cap_pi(sk)->mode) {
+	case L2CAP_MODE_BASIC:
+		/* If socket recv buffers overflows we drop data here
+		 * which is *bad* because L2CAP has to be reliable.
+		 * But we don't have any other choice. L2CAP doesn't
+		 * provide flow control mechanism. */
 
-	/* If socket recv buffers overflows we drop data here
-	 * which is *bad* because L2CAP has to be reliable.
-	 * But we don't have any other choice. L2CAP doesn't
-	 * provide flow control mechanism. */
+		if (l2cap_pi(sk)->imtu < skb->len)
+			goto drop;
 
-	if (!sock_queue_rcv_skb(sk, skb))
-		goto done;
+		if (!sock_queue_rcv_skb(sk, skb))
+			goto done;
+		break;
+
+	case L2CAP_MODE_ERTM:
+		control = get_unaligned_le16(skb->data);
+		skb_pull(skb, 2);
+
+		if (l2cap_pi(sk)->imtu < skb->len)
+			goto drop;
+
+		if (__is_iframe(control))
+			err = l2cap_data_channel_iframe(sk, control, skb);
+		else
+			err = l2cap_data_channel_sframe(sk, control, skb);
+
+		if (!err)
+			goto done;
+		break;
+
+	default:
+		BT_DBG("sk %p: bad mode 0x%2.2x", sk, l2cap_pi(sk)->mode);
+		break;
+	}
 
 drop:
 	kfree_skb(skb);
@@ -2676,6 +2957,11 @@ static void l2cap_recv_frame(struct l2cap_conn *conn, struct sk_buff *skb)
 	cid = __le16_to_cpu(lh->cid);
 	len = __le16_to_cpu(lh->len);
 
+	if (len != skb->len) {
+		kfree_skb(skb);
+		return;
+	}
+
 	BT_DBG("len %d, cid 0x%4.4x", len, cid);
 
 	switch (cid) {
-- 
1.6.2.5

