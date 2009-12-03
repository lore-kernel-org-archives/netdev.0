From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 10/18] Bluetooth: Initialize variables and timers for both channel's sides
Date: Thu,  3 Dec 2009 19:45:47 +0100
Message-ID: <0565c1c24af94130b891f989fa608faddfadc52c.1259865280.git.marcel@holtmann.org>
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
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37648 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756526AbZLCSp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:45:59 -0500
In-Reply-To: <cde9f807f003676862178a6f28b52c7d431511ed.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

Fix ERTM's full-duplex channel to work as specified by ERTM spec. ERTM
needs to handle state vars, timers and counters to send and receive
I-frames(the data frames), i.e., for both sides of data communication.
We initialize all of them to the default values here.
Full-duplex channel is a mandatory feature of ERTM spec.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   54 ++++++++++++++++++++++++++++++++----------------
 1 files changed, 36 insertions(+), 18 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 54992f7..dfd0327 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2173,6 +2173,21 @@ static void l2cap_add_conf_opt(void **ptr, u8 type, u8 len, unsigned long val)
 	*ptr += L2CAP_CONF_OPT_SIZE + len;
 }
 
+static inline void l2cap_ertm_init(struct sock *sk)
+{
+	l2cap_pi(sk)->expected_ack_seq = 0;
+	l2cap_pi(sk)->unacked_frames = 0;
+	l2cap_pi(sk)->buffer_seq = 0;
+	l2cap_pi(sk)->num_to_ack = 0;
+
+	setup_timer(&l2cap_pi(sk)->retrans_timer,
+			l2cap_retrans_timeout, (unsigned long) sk);
+	setup_timer(&l2cap_pi(sk)->monitor_timer,
+			l2cap_monitor_timeout, (unsigned long) sk);
+
+	__skb_queue_head_init(SREJ_QUEUE(sk));
+}
+
 static int l2cap_mode_supported(__u8 mode, __u32 feat_mask)
 {
 	u32 local_feat_mask = l2cap_feat_mask;
@@ -2761,17 +2776,13 @@ static inline int l2cap_config_req(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 			l2cap_pi(sk)->fcs = L2CAP_FCS_CRC16;
 
 		sk->sk_state = BT_CONNECTED;
-		l2cap_pi(sk)->next_tx_seq = 0;
-		l2cap_pi(sk)->expected_ack_seq = 0;
-		l2cap_pi(sk)->unacked_frames = 0;
-
-		setup_timer(&l2cap_pi(sk)->retrans_timer,
-				l2cap_retrans_timeout, (unsigned long) sk);
-		setup_timer(&l2cap_pi(sk)->monitor_timer,
-				l2cap_monitor_timeout, (unsigned long) sk);
 
+		l2cap_pi(sk)->next_tx_seq = 0;
+		l2cap_pi(sk)->expected_tx_seq = 0;
 		__skb_queue_head_init(TX_QUEUE(sk));
-		__skb_queue_head_init(SREJ_QUEUE(sk));
+		if (l2cap_pi(sk)->mode == L2CAP_MODE_ERTM)
+			l2cap_ertm_init(sk);
+
 		l2cap_chan_ready(sk);
 		goto unlock;
 	}
@@ -2850,11 +2861,12 @@ static inline int l2cap_config_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 			l2cap_pi(sk)->fcs = L2CAP_FCS_CRC16;
 
 		sk->sk_state = BT_CONNECTED;
+		l2cap_pi(sk)->next_tx_seq = 0;
 		l2cap_pi(sk)->expected_tx_seq = 0;
-		l2cap_pi(sk)->buffer_seq = 0;
-		l2cap_pi(sk)->num_to_ack = 0;
 		__skb_queue_head_init(TX_QUEUE(sk));
-		__skb_queue_head_init(SREJ_QUEUE(sk));
+		if (l2cap_pi(sk)->mode ==  L2CAP_MODE_ERTM)
+			l2cap_ertm_init(sk);
+
 		l2cap_chan_ready(sk);
 	}
 
@@ -2886,9 +2898,12 @@ static inline int l2cap_disconnect_req(struct l2cap_conn *conn, struct l2cap_cmd
 	sk->sk_shutdown = SHUTDOWN_MASK;
 
 	skb_queue_purge(TX_QUEUE(sk));
-	skb_queue_purge(SREJ_QUEUE(sk));
-	del_timer(&l2cap_pi(sk)->retrans_timer);
-	del_timer(&l2cap_pi(sk)->monitor_timer);
+
+	if (l2cap_pi(sk)->mode == L2CAP_MODE_ERTM) {
+		skb_queue_purge(SREJ_QUEUE(sk));
+		del_timer(&l2cap_pi(sk)->retrans_timer);
+		del_timer(&l2cap_pi(sk)->monitor_timer);
+	}
 
 	l2cap_chan_del(sk, ECONNRESET);
 	bh_unlock_sock(sk);
@@ -2913,9 +2928,12 @@ static inline int l2cap_disconnect_rsp(struct l2cap_conn *conn, struct l2cap_cmd
 		return 0;
 
 	skb_queue_purge(TX_QUEUE(sk));
-	skb_queue_purge(SREJ_QUEUE(sk));
-	del_timer(&l2cap_pi(sk)->retrans_timer);
-	del_timer(&l2cap_pi(sk)->monitor_timer);
+
+	if (l2cap_pi(sk)->mode == L2CAP_MODE_ERTM) {
+		skb_queue_purge(SREJ_QUEUE(sk));
+		del_timer(&l2cap_pi(sk)->retrans_timer);
+		del_timer(&l2cap_pi(sk)->monitor_timer);
+	}
 
 	l2cap_chan_del(sk, 0);
 	bh_unlock_sock(sk);
-- 
1.6.5.2

