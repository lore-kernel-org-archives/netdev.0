From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 12/64] Bluetooth: Support case with F bit set under WAIT_F state.
Date: Mon, 10 May 2010 11:37:02 +0200
Message-ID: <1d8f5d16913d74e428950ee02fe9ff7e6391c120.1273484096.git.marcel@holtmann.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53439 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab0EJJip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:45 -0400
In-Reply-To: <d5392c8f1e9faef089bb7cb66c3314da8bddd1fe.1273484096.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

On receipt of a F=3D1 under WAIT_F state ERTM shall stop monitor timer =
and
start retransmission timer (if there are unacked frames).

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 06687e2..36cd4e4 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3364,6 +3364,13 @@ static inline int l2cap_data_channel_iframe(stru=
ct sock *sk, u16 rx_control, str
=20
 	BT_DBG("sk %p rx_control 0x%4.4x len %d", sk, rx_control, skb->len);
=20
+	if (L2CAP_CTRL_FINAL & rx_control) {
+		del_timer(&pi->monitor_timer);
+		if (pi->unacked_frames > 0)
+			__mod_retrans_timer();
+		pi->conn_state &=3D ~L2CAP_CONN_WAIT_F;
+	}
+
 	pi->expected_ack_seq =3D req_seq;
 	l2cap_drop_acked_frames(sk);
=20
@@ -3453,6 +3460,13 @@ static inline int l2cap_data_channel_sframe(stru=
ct sock *sk, u16 rx_control, str
=20
 	BT_DBG("sk %p rx_control 0x%4.4x len %d", sk, rx_control, skb->len);
=20
+	if (L2CAP_CTRL_FINAL & rx_control) {
+		del_timer(&pi->monitor_timer);
+		if (pi->unacked_frames > 0)
+			__mod_retrans_timer();
+		pi->conn_state &=3D ~L2CAP_CONN_WAIT_F;
+	}
+
 	switch (rx_control & L2CAP_CTRL_SUPERVISE) {
 	case L2CAP_SUPER_RCV_READY:
 		if (rx_control & L2CAP_CTRL_POLL) {
@@ -3472,14 +3486,6 @@ static inline int l2cap_data_channel_sframe(stru=
ct sock *sk, u16 rx_control, str
 				l2cap_ertm_send(sk);
 			}
=20
-			if (!(pi->conn_state & L2CAP_CONN_WAIT_F))
-				break;
-
-			pi->conn_state &=3D ~L2CAP_CONN_WAIT_F;
-			del_timer(&pi->monitor_timer);
-
-			if (pi->unacked_frames > 0)
-				__mod_retrans_timer();
 		} else {
 			pi->expected_ack_seq =3D tx_seq;
 			l2cap_drop_acked_frames(sk);
--=20
1.6.6.1

