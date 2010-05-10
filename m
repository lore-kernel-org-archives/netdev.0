From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 11/64] Bluetooth: Implement 'Send IorRRorRNR' event
Date: Mon, 10 May 2010 11:37:01 +0200
Message-ID: <d5392c8f1e9faef089bb7cb66c3314da8bddd1fe.1273484096.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
 <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
 <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
 <0d861d8b8edd139a9b291cb262d08dec8dc3922d.1273484095.git.marcel@holtmann.org>
 <b9dbdbc1f4404cba2e64939c30c87d59c9796e4e.1273484095.git.marcel@holtmann.org>
 <c69163e9ed5048407cc84f439cbfecc53f6f7131.1273484095.git.marcel@holtmann.org>
 <faaebd192ec9c3febcab98149d1309199a5b886c.1273484095.git.marcel@holtmann.org>
 <7dffe4210233a2860c3f41477c40b3252edf2b7d.1273484095.git.marcel@holtmann.org>
 <d1daa091e8612f3aab14d28b5836375fafe155e1.1273484096.git.marcel@holtmann.org>
 <e8235c6bdd1c7ffbaa7eb8dcdbb46c51f1e5d72e.1273484096.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53431 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755739Ab0EJJip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:45 -0400
In-Reply-To: <e8235c6bdd1c7ffbaa7eb8dcdbb46c51f1e5d72e.1273484096.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

After receive a RR with P bit set ERTM shall use this funcion to choose
what type of frame to reply with F bit =3D 1.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |   20 ++++++++++--------
 net/bluetooth/l2cap.c         |   43 +++++++++++++++++++++++++++++++++=
++++---
 2 files changed, 50 insertions(+), 13 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2ca=
p.h
index 17a689f..d9c20c3 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -320,7 +320,7 @@ struct l2cap_pinfo {
 	__u8		conf_req[64];
 	__u8		conf_len;
 	__u8		conf_state;
-	__u8		conn_state;
+	__u16		conn_state;
=20
 	__u8		next_tx_seq;
 	__u8		expected_ack_seq;
@@ -328,6 +328,7 @@ struct l2cap_pinfo {
 	__u8		buffer_seq;
 	__u8		buffer_seq_srej;
 	__u8		srej_save_reqseq;
+	__u8		frames_sent;
 	__u8		unacked_frames;
 	__u8		retry_count;
 	__u8		num_to_ack;
@@ -367,14 +368,15 @@ struct l2cap_pinfo {
 #define L2CAP_CONF_MAX_CONF_REQ 2
 #define L2CAP_CONF_MAX_CONF_RSP 2
=20
-#define L2CAP_CONN_SAR_SDU         0x01
-#define L2CAP_CONN_SREJ_SENT       0x02
-#define L2CAP_CONN_WAIT_F          0x04
-#define L2CAP_CONN_SREJ_ACT        0x08
-#define L2CAP_CONN_SEND_PBIT       0x10
-#define L2CAP_CONN_REMOTE_BUSY     0x20
-#define L2CAP_CONN_LOCAL_BUSY      0x40
-#define L2CAP_CONN_REJ_ACT         0x80
+#define L2CAP_CONN_SAR_SDU         0x0001
+#define L2CAP_CONN_SREJ_SENT       0x0002
+#define L2CAP_CONN_WAIT_F          0x0004
+#define L2CAP_CONN_SREJ_ACT        0x0008
+#define L2CAP_CONN_SEND_PBIT       0x0010
+#define L2CAP_CONN_REMOTE_BUSY     0x0020
+#define L2CAP_CONN_LOCAL_BUSY      0x0040
+#define L2CAP_CONN_REJ_ACT         0x0080
+#define L2CAP_CONN_SEND_FBIT       0x0100
=20
 #define __mod_retrans_timer() mod_timer(&l2cap_pi(sk)->retrans_timer, =
\
 		jiffies +  msecs_to_jiffies(L2CAP_DEFAULT_RETRANS_TO));
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index a9c152a..06687e2 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1383,6 +1383,10 @@ static int l2cap_ertm_send(struct sock *sk)
 		bt_cb(skb)->retries++;
=20
 		control =3D get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
+		if (pi->conn_state & L2CAP_CONN_SEND_FBIT) {
+			control |=3D L2CAP_CTRL_FINAL;
+			pi->conn_state &=3D ~L2CAP_CONN_SEND_FBIT;
+		}
 		control |=3D (pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT)
 				| (pi->next_tx_seq << L2CAP_CTRL_TXSEQ_SHIFT);
 		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
@@ -1404,6 +1408,7 @@ static int l2cap_ertm_send(struct sock *sk)
 		pi->next_tx_seq =3D (pi->next_tx_seq + 1) % 64;
=20
 		pi->unacked_frames++;
+		pi->frames_sent++;
=20
 		if (skb_queue_is_last(TX_QUEUE(sk), skb))
 			sk->sk_send_head =3D NULL;
@@ -2191,6 +2196,7 @@ static inline void l2cap_ertm_init(struct sock *s=
k)
 	l2cap_pi(sk)->unacked_frames =3D 0;
 	l2cap_pi(sk)->buffer_seq =3D 0;
 	l2cap_pi(sk)->num_to_ack =3D 0;
+	l2cap_pi(sk)->frames_sent =3D 0;
=20
 	setup_timer(&l2cap_pi(sk)->retrans_timer,
 			l2cap_retrans_timeout, (unsigned long) sk);
@@ -3148,6 +3154,38 @@ static int l2cap_check_fcs(struct l2cap_pinfo *p=
i,  struct sk_buff *skb)
 	return 0;
 }
=20
+static inline void l2cap_send_i_or_rr_or_rnr(struct sock *sk)
+{
+	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
+	u16 control =3D 0;
+
+	pi->frames_sent =3D 0;
+	pi->conn_state |=3D L2CAP_CONN_SEND_FBIT;
+
+	control |=3D pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT;
+
+	if (pi->conn_state & L2CAP_CONN_LOCAL_BUSY) {
+		control |=3D L2CAP_SUPER_RCV_NOT_READY | L2CAP_CTRL_FINAL;
+		l2cap_send_sframe(pi, control);
+		pi->conn_state &=3D ~L2CAP_CONN_SEND_FBIT;
+	}
+
+	if (pi->conn_state & L2CAP_CONN_REMOTE_BUSY && pi->unacked_frames > 0=
)
+		__mod_retrans_timer();
+
+	l2cap_ertm_send(sk);
+
+	if (!(pi->conn_state & L2CAP_CONN_LOCAL_BUSY) &&
+			pi->frames_sent =3D=3D 0) {
+		control |=3D L2CAP_SUPER_RCV_READY;
+		if (pi->conn_state & L2CAP_CONN_SEND_FBIT) {
+			control |=3D L2CAP_CTRL_FINAL;
+			pi->conn_state &=3D ~L2CAP_CONN_SEND_FBIT;
+		}
+		l2cap_send_sframe(pi, control);
+	}
+}
+
 static void l2cap_add_to_srej_queue(struct sock *sk, struct sk_buff *s=
kb, u8 tx_seq, u8 sar)
 {
 	struct sk_buff *next_skb;
@@ -3418,10 +3456,7 @@ static inline int l2cap_data_channel_sframe(stru=
ct sock *sk, u16 rx_control, str
 	switch (rx_control & L2CAP_CTRL_SUPERVISE) {
 	case L2CAP_SUPER_RCV_READY:
 		if (rx_control & L2CAP_CTRL_POLL) {
-			u16 control =3D L2CAP_CTRL_FINAL;
-			control |=3D L2CAP_SUPER_RCV_READY |
-				(pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT);
-			l2cap_send_sframe(l2cap_pi(sk), control);
+			l2cap_send_i_or_rr_or_rnr(sk);
 			pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
=20
 		} else if (rx_control & L2CAP_CTRL_FINAL) {
--=20
1.6.6.1

