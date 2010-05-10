From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 20/64] Bluetooth: Group the ack of I-frames into l2cap_data_channel_rrframe()
Date: Mon, 10 May 2010 11:37:10 +0200
Message-ID: <6e3a59819fac19006fe4255b87928e5a12c54532.1273484096.git.marcel@holtmann.org>
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
 <e072745f4adb01b909bd08a0cfc8f79348f4d2c6.1273484096.git.marcel@holtmann.org>
 <99b0d4b7b09edeacf4542bced5c01239375b51a9.1273484096.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53431 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab0EJJiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:51 -0400
In-Reply-To: <99b0d4b7b09edeacf4542bced5c01239375b51a9.1273484096.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

It also fix a bug: we weren't acknowledging I-frames when P=3D1.
Note that when F=3D1 we are acknowledging packets before setting
RemoteBusy to False. The spec says we should do that in the opposite
order, but acknowledment of packets doesn't care about RemoteBusy flag
so we can do that in the order we want.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 8937a84..d096c7c 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3494,7 +3494,9 @@ expected:
 static inline void l2cap_data_channel_rrframe(struct sock *sk, u16 rx_=
control)
 {
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
-	u8 tx_seq =3D __get_reqseq(rx_control);
+
+	pi->expected_ack_seq =3D __get_reqseq(rx_control);
+	l2cap_drop_acked_frames(sk);
=20
 	if (rx_control & L2CAP_CTRL_POLL) {
 		l2cap_send_i_or_rr_or_rnr(sk);
@@ -3502,8 +3504,6 @@ static inline void l2cap_data_channel_rrframe(str=
uct sock *sk, u16 rx_control)
=20
 	} else if (rx_control & L2CAP_CTRL_FINAL) {
 		pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
-		pi->expected_ack_seq =3D tx_seq;
-		l2cap_drop_acked_frames(sk);
=20
 		if (pi->conn_state & L2CAP_CONN_REJ_ACT)
 			pi->conn_state &=3D ~L2CAP_CONN_REJ_ACT;
@@ -3514,9 +3514,6 @@ static inline void l2cap_data_channel_rrframe(str=
uct sock *sk, u16 rx_control)
 		}
=20
 	} else {
-		pi->expected_ack_seq =3D tx_seq;
-		l2cap_drop_acked_frames(sk);
-
 		if ((pi->conn_state & L2CAP_CONN_REMOTE_BUSY) &&
 				(pi->unacked_frames > 0))
 			__mod_retrans_timer();
--=20
1.6.6.1

