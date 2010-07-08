From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 08/13] Bluetooth: Fix bug with ERTM minimum packet length
Date: Thu,  8 Jul 2010 16:59:57 -0300
Message-ID: <7730428bde06701143b314d73ba1e9a142bc6c47.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36227 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758595Ab0GHUAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:40 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Holstein <nathan@lampreynetworks.com>

ERTM and streaming mode L2CAP sockets have no minimum packet length. Only
basic mode connections have minimum length.

Instead, validate the packet containing all necessary control, FCS,
and SAR fields.

The patch fixes the drop of valid packets with length lower than 4.

Signed-off-by: Nathan Holstein <ngh@isomerica.net>
Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index df21cdc..63b0a7d 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -4085,9 +4085,9 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 {
 	struct sock *sk;
 	struct l2cap_pinfo *pi;
-	u16 control, len;
+	u16 control;
 	u8 tx_seq, req_seq;
-	int next_tx_seq_offset, req_seq_offset;
+	int len, next_tx_seq_offset, req_seq_offset;
 
 	sk = l2cap_get_chan_by_scid(&conn->chan_list, cid);
 	if (!sk) {
@@ -4157,7 +4157,7 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 		}
 
 		if (__is_iframe(control)) {
-			if (len < 4) {
+			if (len < 0) {
 				l2cap_send_disconn_req(pi->conn, sk);
 				goto drop;
 			}
@@ -4185,7 +4185,7 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 		if (pi->fcs == L2CAP_FCS_CRC16)
 			len -= 2;
 
-		if (len > pi->mps || len < 4 || __is_sframe(control))
+		if (len > pi->mps || len < 0 || __is_sframe(control))
 			goto drop;
 
 		if (l2cap_check_fcs(pi, skb))
-- 
1.7.1.1

