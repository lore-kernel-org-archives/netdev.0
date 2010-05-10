From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 15/64] Bluetooth: Implement SendAck() Action on ERTM.
Date: Mon, 10 May 2010 11:37:05 +0200
Message-ID: <9e917af13d59182f95bbb5483dc0c4254dfb7944.1273484096.git.marcel@holtmann.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53446 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755790Ab0EJJis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:48 -0400
In-Reply-To: <36f2fd585f43199f006a3b5ff84e95815102cd31.1273484096.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

Shall be used to ack received frames, It must decide type of
acknowledgment between a RR frame, a RNR frame or transmission of
pending I-frames.
It also modifies l2cap_ertm_send() to report the number of frames sent.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   41 +++++++++++++++++++++++++++++------------
 1 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 2e354d2..0a739ef 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -352,6 +352,11 @@ static inline int l2cap_send_sframe(struct l2cap_p=
info *pi, u16 control)
 	count =3D min_t(unsigned int, conn->mtu, hlen);
 	control |=3D L2CAP_CTRL_FRAME_TYPE;
=20
+	if (pi->conn_state & L2CAP_CONN_SEND_FBIT) {
+		control |=3D L2CAP_CTRL_FINAL;
+		pi->conn_state &=3D ~L2CAP_CONN_SEND_FBIT;
+	}
+
 	skb =3D bt_skb_alloc(count, GFP_ATOMIC);
 	if (!skb)
 		return -ENOMEM;
@@ -1364,7 +1369,7 @@ static int l2cap_ertm_send(struct sock *sk)
 	struct sk_buff *skb, *tx_skb;
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
 	u16 control, fcs;
-	int err;
+	int err, nsent =3D 0;
=20
 	if (pi->conn_state & L2CAP_CONN_WAIT_F)
 		return 0;
@@ -1414,8 +1419,27 @@ static int l2cap_ertm_send(struct sock *sk)
 			sk->sk_send_head =3D NULL;
 		else
 			sk->sk_send_head =3D skb_queue_next(TX_QUEUE(sk), skb);
+
+		nsent++;
 	}
=20
+	return nsent;
+}
+
+static int l2cap_send_ack(struct l2cap_pinfo *pi)
+{
+	struct sock *sk =3D (struct sock *)pi;
+	u16 control =3D 0;
+
+	control |=3D pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT;
+
+	if (pi->conn_state & L2CAP_CONN_LOCAL_BUSY) {
+		control |=3D L2CAP_SUPER_RCV_NOT_READY;
+		return l2cap_send_sframe(pi, control);
+	} else if (l2cap_ertm_send(sk) =3D=3D 0) {
+		control |=3D L2CAP_SUPER_RCV_READY;
+		return l2cap_send_sframe(pi, control);
+	}
 	return 0;
 }
=20
@@ -1678,7 +1702,7 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb,=
 struct socket *sock, struct ms
 		else
 			err =3D l2cap_ertm_send(sk);
=20
-		if (!err)
+		if (err >=3D 0)
 			err =3D len;
 		break;
=20
@@ -3178,10 +3202,6 @@ static inline void l2cap_send_i_or_rr_or_rnr(str=
uct sock *sk)
 	if (!(pi->conn_state & L2CAP_CONN_LOCAL_BUSY) &&
 			pi->frames_sent =3D=3D 0) {
 		control |=3D L2CAP_SUPER_RCV_READY;
-		if (pi->conn_state & L2CAP_CONN_SEND_FBIT) {
-			control |=3D L2CAP_CTRL_FINAL;
-			pi->conn_state &=3D ~L2CAP_CONN_SEND_FBIT;
-		}
 		l2cap_send_sframe(pi, control);
 	}
 }
@@ -3362,7 +3382,6 @@ static inline int l2cap_data_channel_iframe(struc=
t sock *sk, u16 rx_control, str
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
 	u8 tx_seq =3D __get_txseq(rx_control);
 	u8 req_seq =3D __get_reqseq(rx_control);
-	u16 tx_control =3D 0;
 	u8 sar =3D rx_control >> L2CAP_CTRL_SAR_SHIFT;
 	int err =3D 0;
=20
@@ -3449,11 +3468,9 @@ expected:
 		return err;
=20
 	pi->num_to_ack =3D (pi->num_to_ack + 1) % L2CAP_DEFAULT_NUM_TO_ACK;
-	if (pi->num_to_ack =3D=3D L2CAP_DEFAULT_NUM_TO_ACK - 1) {
-		tx_control |=3D L2CAP_SUPER_RCV_READY;
-		tx_control |=3D pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT;
-		l2cap_send_sframe(pi, tx_control);
-	}
+	if (pi->num_to_ack =3D=3D L2CAP_DEFAULT_NUM_TO_ACK - 1)
+		l2cap_send_ack(pi);
+
 	return 0;
 }
=20
--=20
1.6.6.1

