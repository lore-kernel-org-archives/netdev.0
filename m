From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 12/18] Bluetooth: Fix sending ReqSeq on I-frames
Date: Thu,  3 Dec 2009 19:45:49 +0100
Message-ID: <9f121a5a80b4417c6db5a35e26d2e79c29c3fc0d.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
 <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
 <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
 <7e21addcd0ad87696c17409399e56e874931da57.1259865280.git.marcel@holtmann.org>
 <76bca88012e1d27de794f32cc551d6314d38b6d9.1259865280.git.marcel@holtmann.org>
 <c78ae283145d3a8799b2fb01650166a66af3bff8.1259865280.git.marcel@holtmann.org>
 <cde9f807f003676862178a6f28b52c7d431511ed.1259865280.git.marcel@holtmann.org>
 <0565c1c24af94130b891f989fa608faddfadc52c.1259865280.git.marcel@holtmann.org>
 <889a3ca466018ab68363c3168993793bc2d984f1.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37648 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756535AbZLCSqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:46:01 -0500
In-Reply-To: <889a3ca466018ab68363c3168993793bc2d984f1.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

As specified by ERTM spec an ERTM channel can acknowledge received
I-frames(the data frames) by sending an I-frame with the proper ReqSeq
value (i.e. ReqSeq is set to BufferSeq).  Until now we aren't setting the
ReqSeq value on I-frame control bits. That way we can save sending
S-frames(Supervise frames) only to acknowledge receipt of I-frames. It
is very helpful to the full-duplex channel.
ReqSeq is the packet sequence number sent in an acknowledgement frame to
acknowledge receipt of frames up to (ReqSeq - 1).
BufferSeq controls the receiver buffer, it is used to delay
acknowledgement of new frames to not cause buffer overflow. BufferSeq
value is not increased until frames are pulled by reassembly function.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    1 -
 net/bluetooth/l2cap.c         |    8 ++++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 9516f4b..327eb57 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -324,7 +324,6 @@ struct l2cap_pinfo {
 
 	__u8		next_tx_seq;
 	__u8		expected_ack_seq;
-	__u8		req_seq;
 	__u8		expected_tx_seq;
 	__u8		buffer_seq;
 	__u8		buffer_seq_srej;
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 2d5d375..78ab881 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1333,7 +1333,7 @@ static int l2cap_retransmit_frame(struct sock *sk, u8 tx_seq)
 		tx_skb = skb_clone(skb, GFP_ATOMIC);
 		bt_cb(skb)->retries++;
 		control = get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
-		control |= (pi->req_seq << L2CAP_CTRL_REQSEQ_SHIFT)
+		control |= (pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT)
 				| (tx_seq << L2CAP_CTRL_TXSEQ_SHIFT);
 		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
 
@@ -1375,7 +1375,7 @@ static int l2cap_ertm_send(struct sock *sk)
 		bt_cb(skb)->retries++;
 
 		control = get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
-		control |= (pi->req_seq << L2CAP_CTRL_REQSEQ_SHIFT)
+		control |= (pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT)
 				| (pi->next_tx_seq << L2CAP_CTRL_TXSEQ_SHIFT);
 		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
 
@@ -3298,12 +3298,16 @@ static inline int l2cap_data_channel_iframe(struct sock *sk, u16 rx_control, str
 {
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
 	u8 tx_seq = __get_txseq(rx_control);
+	u8 req_seq = __get_reqseq(rx_control);
 	u16 tx_control = 0;
 	u8 sar = rx_control >> L2CAP_CTRL_SAR_SHIFT;
 	int err = 0;
 
 	BT_DBG("sk %p rx_control 0x%4.4x len %d", sk, rx_control, skb->len);
 
+	pi->expected_ack_seq = req_seq;
+	l2cap_drop_acked_frames(sk);
+
 	if (tx_seq == pi->expected_tx_seq)
 		goto expected;
 
-- 
1.6.5.2

