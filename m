From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 06/13] Bluetooth: Fix bug in l2cap_ertm_send() behavior
Date: Thu,  8 Jul 2010 16:59:55 -0300
Message-ID: <0808eb79b486a9730b3423d94ed6568544422a3f.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36223 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758543Ab0GHUAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:36 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

This patch makes l2cap_ertm_send() similar to the Send-Data action of
the ERTM spec. We shall not check for RemoteBusy or WAIT_F state
inside l2cap_ertm_send().

Such checks were causing a bug in the retransmission logic of ERTM and
making ERTM stalls until the ACL is dropped.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index fa842cc..4df5473 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1407,11 +1407,8 @@ static int l2cap_ertm_send(struct sock *sk)
 	u16 control, fcs;
 	int nsent =3D 0;
=20
-	if (pi->conn_state & L2CAP_CONN_WAIT_F)
-		return 0;
=20
-	while ((skb =3D sk->sk_send_head) && (!l2cap_tx_window_full(sk)) &&
-			!(pi->conn_state & L2CAP_CONN_REMOTE_BUSY)) {
+	while ((skb =3D sk->sk_send_head) && (!l2cap_tx_window_full(sk))) {
=20
 		if (pi->remote_max_tx &&
 				bt_cb(skb)->retries =3D=3D pi->remote_max_tx) {
@@ -1784,6 +1781,11 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb=
, struct socket *sock, struct ms
 		if (pi->mode =3D=3D L2CAP_MODE_STREAMING) {
 			err =3D l2cap_streaming_send(sk);
 		} else {
+			if (pi->conn_state & L2CAP_CONN_REMOTE_BUSY &&
+					pi->conn_state && L2CAP_CONN_WAIT_F) {
+				err =3D len;
+				break;
+			}
 			spin_lock_bh(&pi->send_lock);
 			err =3D l2cap_ertm_send(sk);
 			spin_unlock_bh(&pi->send_lock);
@@ -3371,8 +3373,6 @@ static inline void l2cap_send_i_or_rr_or_rnr(stru=
ct sock *sk)
 	if (pi->conn_state & L2CAP_CONN_REMOTE_BUSY && pi->unacked_frames > 0=
)
 		__mod_retrans_timer();
=20
-	pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
-
 	spin_lock_bh(&pi->send_lock);
 	l2cap_ertm_send(sk);
 	spin_unlock_bh(&pi->send_lock);
--=20
1.7.1.1

