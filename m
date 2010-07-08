From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 04/13] Bluetooth: Fix bug with ERTM vars increment
Date: Thu,  8 Jul 2010 16:59:53 -0300
Message-ID: <7d99c9191ea5b787b449cfc4c1fc6becef0c9ecc.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36217 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758583Ab0GHUAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:33 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

All ERTM operations regarding the txWindow should be modulo 64,
otherwise we confuse the ERTM logic and connections will break.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index b08731d..bca8c41 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3741,7 +3741,7 @@ static void l2cap_check_srej_gap(struct sock *sk,=
 u8 tx_seq)
 		l2cap_ertm_reassembly_sdu(sk, skb, control);
 		l2cap_pi(sk)->buffer_seq_srej =3D
 			(l2cap_pi(sk)->buffer_seq_srej + 1) % 64;
-		tx_seq++;
+		tx_seq =3D (tx_seq + 1) % 64;
 	}
 }
=20
@@ -3777,10 +3777,11 @@ static void l2cap_send_srejframe(struct sock *s=
k, u8 tx_seq)
 		l2cap_send_sframe(pi, control);
=20
 		new =3D kzalloc(sizeof(struct srej_list), GFP_ATOMIC);
-		new->tx_seq =3D pi->expected_tx_seq++;
+		new->tx_seq =3D pi->expected_tx_seq;
+		pi->expected_tx_seq =3D (pi->expected_tx_seq + 1) % 64;
 		list_add_tail(&new->list, SREJ_LIST(sk));
 	}
-	pi->expected_tx_seq++;
+	pi->expected_tx_seq =3D (pi->expected_tx_seq + 1) % 64;
 }
=20
 static inline int l2cap_data_channel_iframe(struct sock *sk, u16 rx_co=
ntrol, struct sk_buff *skb)
--=20
1.7.1.1

