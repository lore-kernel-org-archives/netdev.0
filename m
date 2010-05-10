From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 18/64] Bluetooth: Split l2cap_data_channel_sframe()
Date: Mon, 10 May 2010 11:37:08 +0200
Message-ID: <e072745f4adb01b909bd08a0cfc8f79348f4d2c6.1273484096.git.marcel@holtmann.org>
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
 <d5392c8f1e9faef089bb7cb66c3314da8bddd1fe.1273484096.git.marcel@holtmann.org>
 <1d8f5d16913d74e428950ee02fe9ff7e6391c120.1273484096.git.marcel@holtmann.org>
 <277ffbe362823d18a17792fbd8e507010e666299.1273484096.git.marcel@holtmann.org>
 <36f2fd585f43199f006a3b5ff84e95815102cd31.1273484096.git.marcel@holtmann.org>
 <9e917af13d59182f95bbb5483dc0c4254dfb7944.1273484096.git.marcel@holtmann.org>
 <f0946ccfc7da403a46b7ff7cb2e3deffac108742.1273484096.git.marcel@holtmann.org>
 <73edaa9933219e25d6733b78d1e2c881025705e2.1273484096.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53446 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755733Ab0EJJiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:50 -0400
In-Reply-To: <73edaa9933219e25d6733b78d1e2c881025705e2.1273484096.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

Create a function for each type fo S-frame and avoid a lot of nested
code.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |  204 +++++++++++++++++++++++++++--------------=
-------
 1 files changed, 115 insertions(+), 89 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index e5cd64a..068edf7 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3475,120 +3475,146 @@ expected:
 	return 0;
 }
=20
-static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_co=
ntrol, struct sk_buff *skb)
+static inline void l2cap_data_channel_rrframe(struct sock *sk, u16 rx_=
control)
 {
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
 	u8 tx_seq =3D __get_reqseq(rx_control);
=20
-	BT_DBG("sk %p rx_control 0x%4.4x len %d", sk, rx_control, skb->len);
-
-	if (L2CAP_CTRL_FINAL & rx_control) {
-		del_timer(&pi->monitor_timer);
-		if (pi->unacked_frames > 0)
-			__mod_retrans_timer();
-		pi->conn_state &=3D ~L2CAP_CONN_WAIT_F;
-	}
+	if (rx_control & L2CAP_CTRL_POLL) {
+		l2cap_send_i_or_rr_or_rnr(sk);
+		pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
=20
-	switch (rx_control & L2CAP_CTRL_SUPERVISE) {
-	case L2CAP_SUPER_RCV_READY:
-		if (rx_control & L2CAP_CTRL_POLL) {
-			l2cap_send_i_or_rr_or_rnr(sk);
-			pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
-
-		} else if (rx_control & L2CAP_CTRL_FINAL) {
-			pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
-			pi->expected_ack_seq =3D tx_seq;
-			l2cap_drop_acked_frames(sk);
-
-			if (pi->conn_state & L2CAP_CONN_REJ_ACT)
-				pi->conn_state &=3D ~L2CAP_CONN_REJ_ACT;
-			else {
-				sk->sk_send_head =3D TX_QUEUE(sk)->next;
-				pi->next_tx_seq =3D pi->expected_ack_seq;
-				l2cap_ertm_send(sk);
-			}
+	} else if (rx_control & L2CAP_CTRL_FINAL) {
+		pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
+		pi->expected_ack_seq =3D tx_seq;
+		l2cap_drop_acked_frames(sk);
=20
-		} else {
-			pi->expected_ack_seq =3D tx_seq;
-			l2cap_drop_acked_frames(sk);
+		if (pi->conn_state & L2CAP_CONN_REJ_ACT)
+			pi->conn_state &=3D ~L2CAP_CONN_REJ_ACT;
+		else {
+			sk->sk_send_head =3D TX_QUEUE(sk)->next;
+			pi->next_tx_seq =3D pi->expected_ack_seq;
+			l2cap_ertm_send(sk);
+		}
=20
-			if ((pi->conn_state & L2CAP_CONN_REMOTE_BUSY) &&
-			    (pi->unacked_frames > 0))
-				__mod_retrans_timer();
+	} else {
+		pi->expected_ack_seq =3D tx_seq;
+		l2cap_drop_acked_frames(sk);
=20
-			pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
-			if (pi->conn_state & L2CAP_CONN_SREJ_SENT)
-				l2cap_send_ack(pi);
-			else
-				l2cap_ertm_send(sk);
-		}
-		break;
+		if ((pi->conn_state & L2CAP_CONN_REMOTE_BUSY) &&
+				(pi->unacked_frames > 0))
+			__mod_retrans_timer();
=20
-	case L2CAP_SUPER_REJECT:
 		pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
+		if (pi->conn_state & L2CAP_CONN_SREJ_SENT)
+			l2cap_send_ack(pi);
+		else
+			l2cap_ertm_send(sk);
+	}
+}
=20
-		pi->expected_ack_seq =3D __get_reqseq(rx_control);
-		l2cap_drop_acked_frames(sk);
+static inline void l2cap_data_channel_rejframe(struct sock *sk, u16 rx=
_control)
+{
+	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
+	u8 tx_seq =3D __get_reqseq(rx_control);
=20
-		if (rx_control & L2CAP_CTRL_FINAL) {
-			if (pi->conn_state & L2CAP_CONN_REJ_ACT)
-				pi->conn_state &=3D ~L2CAP_CONN_REJ_ACT;
-			else {
-				sk->sk_send_head =3D TX_QUEUE(sk)->next;
-				pi->next_tx_seq =3D pi->expected_ack_seq;
-				l2cap_ertm_send(sk);
-			}
-		} else {
+	pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
+
+	pi->expected_ack_seq =3D __get_reqseq(rx_control);
+	l2cap_drop_acked_frames(sk);
+
+	if (rx_control & L2CAP_CTRL_FINAL) {
+		if (pi->conn_state & L2CAP_CONN_REJ_ACT)
+			pi->conn_state &=3D ~L2CAP_CONN_REJ_ACT;
+		else {
 			sk->sk_send_head =3D TX_QUEUE(sk)->next;
 			pi->next_tx_seq =3D pi->expected_ack_seq;
 			l2cap_ertm_send(sk);
-
-			if (pi->conn_state & L2CAP_CONN_WAIT_F) {
-				pi->srej_save_reqseq =3D tx_seq;
-				pi->conn_state |=3D L2CAP_CONN_REJ_ACT;
-			}
 		}
+	} else {
+		sk->sk_send_head =3D TX_QUEUE(sk)->next;
+		pi->next_tx_seq =3D pi->expected_ack_seq;
+		l2cap_ertm_send(sk);
=20
-		break;
+		if (pi->conn_state & L2CAP_CONN_WAIT_F) {
+			pi->srej_save_reqseq =3D tx_seq;
+			pi->conn_state |=3D L2CAP_CONN_REJ_ACT;
+		}
+	}
+}
+static inline void l2cap_data_channel_srejframe(struct sock *sk, u16 r=
x_control)
+{
+	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
+	u8 tx_seq =3D __get_reqseq(rx_control);
=20
-	case L2CAP_SUPER_SELECT_REJECT:
-		pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
+	pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
=20
-		if (rx_control & L2CAP_CTRL_POLL) {
-			pi->expected_ack_seq =3D tx_seq;
-			l2cap_drop_acked_frames(sk);
-			l2cap_retransmit_frame(sk, tx_seq);
-			l2cap_ertm_send(sk);
-			if (pi->conn_state & L2CAP_CONN_WAIT_F) {
-				pi->srej_save_reqseq =3D tx_seq;
-				pi->conn_state |=3D L2CAP_CONN_SREJ_ACT;
-			}
-		} else if (rx_control & L2CAP_CTRL_FINAL) {
-			if ((pi->conn_state & L2CAP_CONN_SREJ_ACT) &&
-					pi->srej_save_reqseq =3D=3D tx_seq)
-				pi->conn_state &=3D ~L2CAP_CONN_SREJ_ACT;
-			else
-				l2cap_retransmit_frame(sk, tx_seq);
+	if (rx_control & L2CAP_CTRL_POLL) {
+		pi->expected_ack_seq =3D tx_seq;
+		l2cap_drop_acked_frames(sk);
+		l2cap_retransmit_frame(sk, tx_seq);
+		l2cap_ertm_send(sk);
+		if (pi->conn_state & L2CAP_CONN_WAIT_F) {
+			pi->srej_save_reqseq =3D tx_seq;
+			pi->conn_state |=3D L2CAP_CONN_SREJ_ACT;
 		}
-		else {
+	} else if (rx_control & L2CAP_CTRL_FINAL) {
+		if ((pi->conn_state & L2CAP_CONN_SREJ_ACT) &&
+				pi->srej_save_reqseq =3D=3D tx_seq)
+			pi->conn_state &=3D ~L2CAP_CONN_SREJ_ACT;
+		else
 			l2cap_retransmit_frame(sk, tx_seq);
-			if (pi->conn_state & L2CAP_CONN_WAIT_F) {
-				pi->srej_save_reqseq =3D tx_seq;
-				pi->conn_state |=3D L2CAP_CONN_SREJ_ACT;
-			}
+	} else {
+		l2cap_retransmit_frame(sk, tx_seq);
+		if (pi->conn_state & L2CAP_CONN_WAIT_F) {
+			pi->srej_save_reqseq =3D tx_seq;
+			pi->conn_state |=3D L2CAP_CONN_SREJ_ACT;
 		}
+	}
+}
+
+static inline void l2cap_data_channel_rnrframe(struct sock *sk, u16 rx=
_control)
+{
+	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
+	u8 tx_seq =3D __get_reqseq(rx_control);
+
+	pi->conn_state |=3D L2CAP_CONN_REMOTE_BUSY;
+	pi->expected_ack_seq =3D tx_seq;
+	l2cap_drop_acked_frames(sk);
+
+	del_timer(&pi->retrans_timer);
+	if (rx_control & L2CAP_CTRL_POLL) {
+		u16 control =3D L2CAP_CTRL_FINAL;
+		l2cap_send_rr_or_rnr(pi, control);
+	}
+}
+
+static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_co=
ntrol, struct sk_buff *skb)
+{
+	BT_DBG("sk %p rx_control 0x%4.4x len %d", sk, rx_control, skb->len);
+
+	if (L2CAP_CTRL_FINAL & rx_control) {
+		del_timer(&l2cap_pi(sk)->monitor_timer);
+		if (l2cap_pi(sk)->unacked_frames > 0)
+			__mod_retrans_timer();
+		l2cap_pi(sk)->conn_state &=3D ~L2CAP_CONN_WAIT_F;
+	}
+
+	switch (rx_control & L2CAP_CTRL_SUPERVISE) {
+	case L2CAP_SUPER_RCV_READY:
+		l2cap_data_channel_rrframe(sk, rx_control);
 		break;
=20
-	case L2CAP_SUPER_RCV_NOT_READY:
-		pi->conn_state |=3D L2CAP_CONN_REMOTE_BUSY;
-		pi->expected_ack_seq =3D tx_seq;
-		l2cap_drop_acked_frames(sk);
+	case L2CAP_SUPER_REJECT:
+		l2cap_data_channel_rejframe(sk, rx_control);
+		break;
=20
-		del_timer(&pi->retrans_timer);
-		if (rx_control & L2CAP_CTRL_POLL) {
-			u16 control =3D L2CAP_CTRL_FINAL;
-			l2cap_send_rr_or_rnr(pi, control);
-		}
+	case L2CAP_SUPER_SELECT_REJECT:
+		l2cap_data_channel_srejframe(sk, rx_control);
+		break;
+
+	case L2CAP_SUPER_RCV_NOT_READY:
+		l2cap_data_channel_rnrframe(sk, rx_control);
 		break;
 	}
=20
--=20
1.6.6.1

