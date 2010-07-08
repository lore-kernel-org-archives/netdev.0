From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 07/13] Bluetooth: Fix SREJ_QUEUE corruption in L2CAP
Date: Thu,  8 Jul 2010 16:59:56 -0300
Message-ID: <33a4a7e57747cdca0e4c24cff011d6c29c3290fe.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36225 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758591Ab0GHUAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:38 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>

Since all TxSeq values are modulo, we shall not compare them directly. =
We
have to compare their offset inside the TxWindow instead.

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Acked-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 4df5473..df21cdc 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3387,6 +3387,8 @@ static inline void l2cap_send_i_or_rr_or_rnr(stru=
ct sock *sk)
 static int l2cap_add_to_srej_queue(struct sock *sk, struct sk_buff *sk=
b, u8 tx_seq, u8 sar)
 {
 	struct sk_buff *next_skb;
+	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
+	int tx_seq_offset, next_tx_seq_offset;
=20
 	bt_cb(skb)->tx_seq =3D tx_seq;
 	bt_cb(skb)->sar =3D sar;
@@ -3397,11 +3399,20 @@ static int l2cap_add_to_srej_queue(struct sock =
*sk, struct sk_buff *skb, u8 tx_s
 		return 0;
 	}
=20
+	tx_seq_offset =3D (tx_seq - pi->buffer_seq) % 64;
+	if (tx_seq_offset < 0)
+		tx_seq_offset +=3D 64;
+
 	do {
 		if (bt_cb(next_skb)->tx_seq =3D=3D tx_seq)
 			return -EINVAL;
=20
-		if (bt_cb(next_skb)->tx_seq > tx_seq) {
+		next_tx_seq_offset =3D (bt_cb(next_skb)->tx_seq -
+						pi->buffer_seq) % 64;
+		if (next_tx_seq_offset < 0)
+			next_tx_seq_offset +=3D 64;
+
+		if (next_tx_seq_offset > tx_seq_offset) {
 			__skb_queue_before(SREJ_QUEUE(sk), next_skb, skb);
 			return 0;
 		}
--=20
1.7.1.1

