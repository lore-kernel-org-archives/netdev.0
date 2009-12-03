From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 13/18] Bluetooth: Implement RejActioned flag
Date: Thu,  3 Dec 2009 19:45:50 +0100
Message-ID: <4ec10d9720ef78cd81d8bcc30a3238665744569f.1259865280.git.marcel@holtmann.org>
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
 <9f121a5a80b4417c6db5a35e26d2e79c29c3fc0d.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37647 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756531AbZLCSqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:46:01 -0500
In-Reply-To: <9f121a5a80b4417c6db5a35e26d2e79c29c3fc0d.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

RejActioned is used to prevent retransmission when a entity is on the
WAIT_F state, i.e., waiting for a frame with F-bit set due local busy
condition or a expired retransmission timer. (When these two events raise
they send a frame with the Poll bit set and enters in the WAIT_F state to
wait for a frame with the Final bit set.)
The local entity doesn't send I-frames(the data frames) until the receipt
of a frame with F-bit set. When that happens it also set RejActioned to false.
RejActioned is a mandatory feature of ERTM spec.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    1 +
 net/bluetooth/l2cap.c         |   38 +++++++++++++++++++++++++++++++++++---
 2 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 327eb57..17a689f 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -374,6 +374,7 @@ struct l2cap_pinfo {
 #define L2CAP_CONN_SEND_PBIT       0x10
 #define L2CAP_CONN_REMOTE_BUSY     0x20
 #define L2CAP_CONN_LOCAL_BUSY      0x40
+#define L2CAP_CONN_REJ_ACT         0x80
 
 #define __mod_retrans_timer() mod_timer(&l2cap_pi(sk)->retrans_timer, \
 		jiffies +  msecs_to_jiffies(L2CAP_DEFAULT_RETRANS_TO));
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 78ab881..73bda0a 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3362,6 +3362,16 @@ expected:
 		return 0;
 	}
 
+	if (rx_control & L2CAP_CTRL_FINAL) {
+		if (pi->conn_state & L2CAP_CONN_REJ_ACT)
+			pi->conn_state &= ~L2CAP_CONN_REJ_ACT;
+		else {
+			sk->sk_send_head = TX_QUEUE(sk)->next;
+			pi->next_tx_seq = pi->expected_ack_seq;
+			l2cap_ertm_send(sk);
+		}
+	}
+
 	pi->buffer_seq = (pi->buffer_seq + 1) % 64;
 
 	err = l2cap_sar_reassembly_sdu(sk, skb, rx_control);
@@ -3398,6 +3408,14 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 			pi->expected_ack_seq = tx_seq;
 			l2cap_drop_acked_frames(sk);
 
+			if (pi->conn_state & L2CAP_CONN_REJ_ACT)
+				pi->conn_state &= ~L2CAP_CONN_REJ_ACT;
+			else {
+				sk->sk_send_head = TX_QUEUE(sk)->next;
+				pi->next_tx_seq = pi->expected_ack_seq;
+				l2cap_ertm_send(sk);
+			}
+
 			if (!(pi->conn_state & L2CAP_CONN_WAIT_F))
 				break;
 
@@ -3425,10 +3443,24 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 		pi->expected_ack_seq = __get_reqseq(rx_control);
 		l2cap_drop_acked_frames(sk);
 
-		sk->sk_send_head = TX_QUEUE(sk)->next;
-		pi->next_tx_seq = pi->expected_ack_seq;
+		if (rx_control & L2CAP_CTRL_FINAL) {
+			if (pi->conn_state & L2CAP_CONN_REJ_ACT)
+				pi->conn_state &= ~L2CAP_CONN_REJ_ACT;
+			else {
+				sk->sk_send_head = TX_QUEUE(sk)->next;
+				pi->next_tx_seq = pi->expected_ack_seq;
+				l2cap_ertm_send(sk);
+			}
+		} else {
+			sk->sk_send_head = TX_QUEUE(sk)->next;
+			pi->next_tx_seq = pi->expected_ack_seq;
+			l2cap_ertm_send(sk);
 
-		l2cap_ertm_send(sk);
+			if (pi->conn_state & L2CAP_CONN_WAIT_F) {
+				pi->srej_save_reqseq = tx_seq;
+				pi->conn_state |= L2CAP_CONN_REJ_ACT;
+			}
+		}
 
 		break;
 
-- 
1.6.5.2

