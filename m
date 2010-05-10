From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 13/64] Bluetooth: Check the minimum {I,S}-frame size into L2CAP
Date: Mon, 10 May 2010 11:37:03 +0200
Message-ID: <277ffbe362823d18a17792fbd8e507010e666299.1273484096.git.marcel@holtmann.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53441 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755765Ab0EJJiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:46 -0400
In-Reply-To: <1d8f5d16913d74e428950ee02fe9ff7e6391c120.1273484096.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

All packets with size fewer than the minimum specified is dropped.
Note that the size of the l2cap basic header, FCS and SAR fields are
already subtracted of len at the moment of the size check.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 36cd4e4..ac00f5f 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3627,10 +3627,17 @@ static inline int l2cap_data_channel(struct l2c=
ap_conn *conn, u16 cid, struct sk
 		if (l2cap_check_fcs(pi, skb))
 			goto drop;
=20
-		if (__is_iframe(control))
+		if (__is_iframe(control)) {
+			if (len < 4)
+				goto drop;
+
 			l2cap_data_channel_iframe(sk, control, skb);
-		else
+		} else {
+			if (len !=3D 0)
+				goto drop;
+
 			l2cap_data_channel_sframe(sk, control, skb);
+		}
=20
 		goto done;
=20
@@ -3645,7 +3652,8 @@ static inline int l2cap_data_channel(struct l2cap=
_conn *conn, u16 cid, struct sk
 		if (pi->fcs =3D=3D L2CAP_FCS_CRC16)
 			len -=3D 2;
=20
-		if (len > L2CAP_DEFAULT_MAX_PDU_SIZE || __is_sframe(control))
+		if (len > L2CAP_DEFAULT_MAX_PDU_SIZE || len < 4
+				|| __is_sframe(control))
 			goto drop;
=20
 		if (l2cap_check_fcs(pi, skb))
--=20
1.6.6.1

