From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 32/47] Bluetooth: Add support for Segmentation and Reassembly of SDUs
Date: Sun, 30 Aug 2009 01:50:46 -0700
Message-ID: <c74e560cd0101455f1889515e1527e4c2e266113.1251621661.git.marcel@holtmann.org>
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
 <1c2acffb76d4bc5fd27c4ea55cc27ad8ead10f9a.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53313 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbZH3Iw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:29 -0400
In-Reply-To: <1c2acffb76d4bc5fd27c4ea55cc27ad8ead10f9a.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

ERTM should use Segmentation and Reassembly to break down a SDU in many
PDUs on sending data to the other side.

On sending packets we queue all 'segments' until end of segmentation and
just the add them to the queue for sending. On receiving we create a new
SKB with the SDU reassembled.

Initially based on a patch from Nathan Holstein <nathan@lampreynetworks.com>

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    9 ++-
 net/bluetooth/l2cap.c         |  170 +++++++++++++++++++++++++++++++++++++----
 2 files changed, 162 insertions(+), 17 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 9bbfbe7..0afde8d 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -34,7 +34,7 @@
 #define L2CAP_DEFAULT_MAX_RECEIVE	1
 #define L2CAP_DEFAULT_RETRANS_TO	300    /* 300 milliseconds */
 #define L2CAP_DEFAULT_MONITOR_TO	1000   /* 1 second */
-#define L2CAP_DEFAULT_MAX_RX_APDU	0xfff7
+#define L2CAP_DEFAULT_MAX_PDU_SIZE	672
 
 #define L2CAP_CONN_TIMEOUT	(40000) /* 40 seconds */
 #define L2CAP_INFO_TIMEOUT	(4000)  /*  4 seconds */
@@ -311,6 +311,7 @@ struct l2cap_pinfo {
 	__u8		conf_req[64];
 	__u8		conf_len;
 	__u8		conf_state;
+	__u8		conn_state;
 
 	__u8		next_tx_seq;
 	__u8		expected_ack_seq;
@@ -318,6 +319,9 @@ struct l2cap_pinfo {
 	__u8		expected_tx_seq;
 	__u8		unacked_frames;
 	__u8		num_to_ack;
+	__u16		sdu_len;
+	__u16		partial_sdu_len;
+	struct sk_buff	*sdu;
 
 	__u8		ident;
 
@@ -346,6 +350,8 @@ struct l2cap_pinfo {
 #define L2CAP_CONF_MAX_CONF_REQ 2
 #define L2CAP_CONF_MAX_CONF_RSP 2
 
+#define L2CAP_CONN_SAR_SDU         0x01
+
 static inline int l2cap_tx_window_full(struct sock *sk)
 {
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
@@ -363,6 +369,7 @@ static inline int l2cap_tx_window_full(struct sock *sk)
 #define __get_reqseq(ctrl) ((ctrl) & L2CAP_CTRL_REQSEQ) >> 8
 #define __is_iframe(ctrl) !((ctrl) & L2CAP_CTRL_FRAME_TYPE)
 #define __is_sframe(ctrl) (ctrl) & L2CAP_CTRL_FRAME_TYPE
+#define __is_sar_start(ctrl) ((ctrl) & L2CAP_CTRL_SAR) == L2CAP_SDU_START
 
 void l2cap_load(void);
 
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 45b8697..167e025 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1334,7 +1334,7 @@ static struct sk_buff *l2cap_create_basic_pdu(struct sock *sk, struct msghdr *ms
 	return skb;
 }
 
-static struct sk_buff *l2cap_create_ertm_pdu(struct sock *sk, struct msghdr *msg, size_t len, u16 control)
+static struct sk_buff *l2cap_create_ertm_pdu(struct sock *sk, struct msghdr *msg, size_t len, u16 control, u16 sdulen)
 {
 	struct l2cap_conn *conn = l2cap_pi(sk)->conn;
 	struct sk_buff *skb;
@@ -1343,6 +1343,9 @@ static struct sk_buff *l2cap_create_ertm_pdu(struct sock *sk, struct msghdr *msg
 
 	BT_DBG("sk %p len %d", sk, (int)len);
 
+	if (sdulen)
+		hlen += 2;
+
 	count = min_t(unsigned int, (conn->mtu - hlen), len);
 	skb = bt_skb_send_alloc(sk, count + hlen,
 			msg->msg_flags & MSG_DONTWAIT, &err);
@@ -1354,6 +1357,8 @@ static struct sk_buff *l2cap_create_ertm_pdu(struct sock *sk, struct msghdr *msg
 	lh->cid = cpu_to_le16(l2cap_pi(sk)->dcid);
 	lh->len = cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
 	put_unaligned_le16(control, skb_put(skb, 2));
+	if (sdulen)
+		put_unaligned_le16(sdulen, skb_put(skb, 2));
 
 	err = l2cap_skbuff_fromiovec(sk, msg, len, count, skb);
 	if (unlikely(err < 0)) {
@@ -1363,6 +1368,54 @@ static struct sk_buff *l2cap_create_ertm_pdu(struct sock *sk, struct msghdr *msg
 	return skb;
 }
 
+static inline int l2cap_sar_segment_sdu(struct sock *sk, struct msghdr *msg, size_t len)
+{
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	struct sk_buff *skb;
+	struct sk_buff_head sar_queue;
+	u16 control;
+	size_t size = 0;
+
+	__skb_queue_head_init(&sar_queue);
+	control = L2CAP_SDU_START;
+	skb = l2cap_create_ertm_pdu(sk, msg, pi->max_pdu_size, control, len);
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
+
+	__skb_queue_tail(&sar_queue, skb);
+	len -= pi->max_pdu_size;
+	size +=pi->max_pdu_size;
+	control = 0;
+
+	while (len > 0) {
+		size_t buflen;
+
+		if (len > pi->max_pdu_size) {
+			control |= L2CAP_SDU_CONTINUE;
+			buflen = pi->max_pdu_size;
+		} else {
+			control |= L2CAP_SDU_END;
+			buflen = len;
+		}
+
+		skb = l2cap_create_ertm_pdu(sk, msg, buflen, control, 0);
+		if (IS_ERR(skb)) {
+			skb_queue_purge(&sar_queue);
+			return PTR_ERR(skb);
+		}
+
+		__skb_queue_tail(&sar_queue, skb);
+		len -= buflen;
+		size += buflen;
+		control = 0;
+	}
+	skb_queue_splice_tail(&sar_queue, TX_QUEUE(sk));
+	if (sk->sk_send_head == NULL)
+		sk->sk_send_head = sar_queue.next;
+
+	return size;
+}
+
 static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
@@ -1415,21 +1468,22 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct ms
 
 	case L2CAP_MODE_ERTM:
 		/* Entire SDU fits into one PDU */
-		if (len <= pi->omtu) {
+		if (len <= pi->max_pdu_size) {
 			control = L2CAP_SDU_UNSEGMENTED;
-			skb = l2cap_create_ertm_pdu(sk, msg, len, control);
+			skb = l2cap_create_ertm_pdu(sk, msg, len, control, 0);
 			if (IS_ERR(skb)) {
 				err = PTR_ERR(skb);
 				goto done;
 			}
+			__skb_queue_tail(TX_QUEUE(sk), skb);
+			if (sk->sk_send_head == NULL)
+				sk->sk_send_head = skb;
 		} else {
-			/* FIXME: Segmentation will be added later */
-			err = -EINVAL;
-			goto done;
+		/* Segment SDU into multiples PDUs */
+			err = l2cap_sar_segment_sdu(sk, msg, len);
+			if (err < 0)
+				goto done;
 		}
-		__skb_queue_tail(TX_QUEUE(sk), skb);
-		if (sk->sk_send_head == NULL)
-			sk->sk_send_head = skb;
 
 		err = l2cap_ertm_send(sk);
 		if (!err)
@@ -2007,7 +2061,7 @@ done:
 		rfc.max_transmit    = L2CAP_DEFAULT_MAX_RECEIVE;
 		rfc.retrans_timeout = 0;
 		rfc.monitor_timeout = 0;
-		rfc.max_pdu_size    = cpu_to_le16(L2CAP_DEFAULT_MAX_RX_APDU);
+		rfc.max_pdu_size    = cpu_to_le16(L2CAP_DEFAULT_MAX_PDU_SIZE);
 
 		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC,
 					sizeof(rfc), (unsigned long) &rfc);
@@ -2019,7 +2073,7 @@ done:
 		rfc.max_transmit    = 0;
 		rfc.retrans_timeout = 0;
 		rfc.monitor_timeout = 0;
-		rfc.max_pdu_size    = cpu_to_le16(L2CAP_DEFAULT_MAX_RX_APDU);
+		rfc.max_pdu_size    = cpu_to_le16(L2CAP_DEFAULT_MAX_PDU_SIZE);
 
 		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC,
 					sizeof(rfc), (unsigned long) &rfc);
@@ -2808,6 +2862,86 @@ static inline void l2cap_sig_channel(struct l2cap_conn *conn, struct sk_buff *sk
 	kfree_skb(skb);
 }
 
+static int l2cap_sar_reassembly_sdu(struct sock *sk, struct sk_buff *skb, u16 control)
+{
+	struct l2cap_pinfo *pi = l2cap_pi(sk);
+	struct sk_buff *_skb;
+	int err = -EINVAL;
+
+	switch (control & L2CAP_CTRL_SAR) {
+	case L2CAP_SDU_UNSEGMENTED:
+		if (pi->conn_state & L2CAP_CONN_SAR_SDU) {
+			kfree_skb(pi->sdu);
+			break;
+		}
+
+		err = sock_queue_rcv_skb(sk, skb);
+		if (!err)
+			return 0;
+
+		break;
+
+	case L2CAP_SDU_START:
+		if (pi->conn_state & L2CAP_CONN_SAR_SDU) {
+			kfree_skb(pi->sdu);
+			break;
+		}
+
+		pi->sdu_len = get_unaligned_le16(skb->data);
+		skb_pull(skb, 2);
+
+		pi->sdu = bt_skb_alloc(pi->sdu_len, GFP_ATOMIC);
+		if (!pi->sdu) {
+			err = -ENOMEM;
+			break;
+		}
+
+		memcpy(skb_put(pi->sdu, skb->len), skb->data, skb->len);
+
+		pi->conn_state |= L2CAP_CONN_SAR_SDU;
+		pi->partial_sdu_len = skb->len;
+		err = 0;
+		break;
+
+	case L2CAP_SDU_CONTINUE:
+		if (!(pi->conn_state & L2CAP_CONN_SAR_SDU))
+			break;
+
+		memcpy(skb_put(pi->sdu, skb->len), skb->data, skb->len);
+
+		pi->partial_sdu_len += skb->len;
+		if (pi->partial_sdu_len > pi->sdu_len)
+			kfree_skb(pi->sdu);
+		else
+			err = 0;
+
+		break;
+
+	case L2CAP_SDU_END:
+		if (!(pi->conn_state & L2CAP_CONN_SAR_SDU))
+			break;
+
+		memcpy(skb_put(pi->sdu, skb->len), skb->data, skb->len);
+
+		pi->conn_state &= ~L2CAP_CONN_SAR_SDU;
+		pi->partial_sdu_len += skb->len;
+
+		if (pi->partial_sdu_len == pi->sdu_len) {
+			_skb = skb_clone(pi->sdu, GFP_ATOMIC);
+			err = sock_queue_rcv_skb(sk, _skb);
+			if (err < 0)
+				kfree_skb(_skb);
+		}
+		kfree_skb(pi->sdu);
+		err = 0;
+
+		break;
+	}
+
+	kfree_skb(skb);
+	return err;
+}
+
 static inline int l2cap_data_channel_iframe(struct sock *sk, u16 rx_control, struct sk_buff *skb)
 {
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
@@ -2820,11 +2954,11 @@ static inline int l2cap_data_channel_iframe(struct sock *sk, u16 rx_control, str
 	if (tx_seq != pi->expected_tx_seq)
 		return -EINVAL;
 
-	pi->expected_tx_seq = (pi->expected_tx_seq + 1) % 64;
-	err = sock_queue_rcv_skb(sk, skb);
-	if (err)
+	err = l2cap_sar_reassembly_sdu(sk, skb, rx_control);
+	if (err < 0)
 		return err;
 
+	pi->expected_tx_seq = (pi->expected_tx_seq + 1) % 64;
 	pi->num_to_ack = (pi->num_to_ack + 1) % L2CAP_DEFAULT_NUM_TO_ACK;
 	if (pi->num_to_ack == L2CAP_DEFAULT_NUM_TO_ACK - 1) {
 		tx_control |= L2CAP_CTRL_FRAME_TYPE;
@@ -2860,7 +2994,7 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk_buff *skb)
 {
 	struct sock *sk;
-	u16 control;
+	u16 control, len;
 	int err;
 
 	sk = l2cap_get_chan_by_scid(&conn->chan_list, cid);
@@ -2891,8 +3025,12 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 	case L2CAP_MODE_ERTM:
 		control = get_unaligned_le16(skb->data);
 		skb_pull(skb, 2);
+		len = skb->len;
 
-		if (l2cap_pi(sk)->imtu < skb->len)
+		if (__is_sar_start(control))
+			len -= 2;
+
+		if (len > L2CAP_DEFAULT_MAX_PDU_SIZE)
 			goto drop;
 
 		if (__is_iframe(control))
-- 
1.6.2.5

