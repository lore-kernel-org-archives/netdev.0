From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 10/13] Bluetooth: Fix L2CAP control bit field corruption
Date: Thu,  8 Jul 2010 16:59:59 -0300
Message-ID: <d8d3c1e9b8f3352b9274275aef649138a20cf34b.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36234 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758595Ab0GHUAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:43 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <padovan@profusion.mobi>

When resending an I-frame, ERTM was reusing the control bits from the last
time it was sent, that was causing a corruption in the new control field
due to it dirty fields.

This patches extracts only the SAR bits from the old field and reuse it to
resend the packet, the others bits should be reset and receive the
updated value.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 41c9887..6785e52 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1422,6 +1422,8 @@ static void l2cap_retransmit_one_frame(struct sock *sk, u8 tx_seq)
 	tx_skb = skb_clone(skb, GFP_ATOMIC);
 	bt_cb(skb)->retries++;
 	control = get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
+	control &= L2CAP_CTRL_SAR;
+
 	control |= (pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT)
 			| (tx_seq << L2CAP_CTRL_TXSEQ_SHIFT);
 	put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
@@ -1457,6 +1459,8 @@ static int l2cap_ertm_send(struct sock *sk)
 		bt_cb(skb)->retries++;
 
 		control = get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
+		control &= L2CAP_CTRL_SAR;
+
 		if (pi->conn_state & L2CAP_CONN_SEND_FBIT) {
 			control |= L2CAP_CTRL_FINAL;
 			pi->conn_state &= ~L2CAP_CONN_SEND_FBIT;
-- 
1.7.1.1

