From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 09/13] Bluetooth: Proper shutdown ERTM when closing the channel
Date: Thu,  8 Jul 2010 16:59:58 -0300
Message-ID: <8acc61746bee641a437842f4b5f72584cb23c547.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36229 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758596Ab0GHUAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:42 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <padovan@profusion.mobi>

Fix a crash regarding the Monitor Timeout, it was running even after the
shutdown of the ACL connection, which doesn't make sense.

The same code also fixes another issue, before this patch L2CAP was sending
many Disconnections Requests while we have to send only one.

The issues are related to each other, a expired Monitor Timeout can
trigger a Disconnection Request and then we may have a crash if the link
was already deleted.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   59 ++++++++++++++++++++++++++++++------------------
 1 files changed, 37 insertions(+), 22 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 63b0a7d..41c9887 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -272,6 +272,24 @@ static void l2cap_chan_del(struct sock *sk, int err)
 		parent->sk_data_ready(parent, 0);
 	} else
 		sk->sk_state_change(sk);
+
+	skb_queue_purge(TX_QUEUE(sk));
+
+	if (l2cap_pi(sk)->mode == L2CAP_MODE_ERTM) {
+		struct srej_list *l, *tmp;
+
+		del_timer(&l2cap_pi(sk)->retrans_timer);
+		del_timer(&l2cap_pi(sk)->monitor_timer);
+		del_timer(&l2cap_pi(sk)->ack_timer);
+
+		skb_queue_purge(SREJ_QUEUE(sk));
+		skb_queue_purge(BUSY_QUEUE(sk));
+
+		list_for_each_entry_safe(l, tmp, SREJ_LIST(sk), list) {
+			list_del(&l->list);
+			kfree(l);
+		}
+	}
 }
 
 /* Service level security */
@@ -345,8 +363,12 @@ static inline void l2cap_send_sframe(struct l2cap_pinfo *pi, u16 control)
 	struct sk_buff *skb;
 	struct l2cap_hdr *lh;
 	struct l2cap_conn *conn = pi->conn;
+	struct sock *sk = (struct sock *)pi;
 	int count, hlen = L2CAP_HDR_SIZE + 2;
 
+	if (sk->sk_state != BT_CONNECTED)
+		return;
+
 	if (pi->fcs == L2CAP_FCS_CRC16)
 		hlen += 2;
 
@@ -432,10 +454,23 @@ static void l2cap_send_disconn_req(struct l2cap_conn *conn, struct sock *sk)
 {
 	struct l2cap_disconn_req req;
 
+	if (!conn)
+		return;
+
+	skb_queue_purge(TX_QUEUE(sk));
+
+	if (l2cap_pi(sk)->mode == L2CAP_MODE_ERTM) {
+		del_timer(&l2cap_pi(sk)->retrans_timer);
+		del_timer(&l2cap_pi(sk)->monitor_timer);
+		del_timer(&l2cap_pi(sk)->ack_timer);
+	}
+
 	req.dcid = cpu_to_le16(l2cap_pi(sk)->dcid);
 	req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
 	l2cap_send_cmd(conn, l2cap_get_ident(conn),
 			L2CAP_DISCONN_REQ, sizeof(req), &req);
+
+	sk->sk_state = BT_DISCONN;
 }
 
 /* ---- L2CAP connections ---- */
@@ -726,7 +761,6 @@ static void __l2cap_sock_close(struct sock *sk, int reason)
 				sk->sk_type == SOCK_STREAM) {
 			struct l2cap_conn *conn = l2cap_pi(sk)->conn;
 
-			sk->sk_state = BT_DISCONN;
 			l2cap_sock_set_timer(sk, sk->sk_sndtimeo);
 			l2cap_send_disconn_req(conn, sk);
 		} else
@@ -1407,6 +1441,8 @@ static int l2cap_ertm_send(struct sock *sk)
 	u16 control, fcs;
 	int nsent = 0;
 
+	if (sk->sk_state != BT_CONNECTED)
+		return -ENOTCONN;
 
 	while ((skb = sk->sk_send_head) && (!l2cap_tx_window_full(sk))) {
 
@@ -3065,7 +3101,6 @@ static inline int l2cap_config_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 		}
 
 	default:
-		sk->sk_state = BT_DISCONN;
 		sk->sk_err = ECONNRESET;
 		l2cap_sock_set_timer(sk, HZ * 5);
 		l2cap_send_disconn_req(conn, sk);
@@ -3119,16 +3154,6 @@ static inline int l2cap_disconnect_req(struct l2cap_conn *conn, struct l2cap_cmd
 
 	sk->sk_shutdown = SHUTDOWN_MASK;
 
-	skb_queue_purge(TX_QUEUE(sk));
-
-	if (l2cap_pi(sk)->mode == L2CAP_MODE_ERTM) {
-		skb_queue_purge(SREJ_QUEUE(sk));
-		skb_queue_purge(BUSY_QUEUE(sk));
-		del_timer(&l2cap_pi(sk)->retrans_timer);
-		del_timer(&l2cap_pi(sk)->monitor_timer);
-		del_timer(&l2cap_pi(sk)->ack_timer);
-	}
-
 	l2cap_chan_del(sk, ECONNRESET);
 	bh_unlock_sock(sk);
 
@@ -3151,16 +3176,6 @@ static inline int l2cap_disconnect_rsp(struct l2cap_conn *conn, struct l2cap_cmd
 	if (!sk)
 		return 0;
 
-	skb_queue_purge(TX_QUEUE(sk));
-
-	if (l2cap_pi(sk)->mode == L2CAP_MODE_ERTM) {
-		skb_queue_purge(SREJ_QUEUE(sk));
-		skb_queue_purge(BUSY_QUEUE(sk));
-		del_timer(&l2cap_pi(sk)->retrans_timer);
-		del_timer(&l2cap_pi(sk)->monitor_timer);
-		del_timer(&l2cap_pi(sk)->ack_timer);
-	}
-
 	l2cap_chan_del(sk, 0);
 	bh_unlock_sock(sk);
 
-- 
1.7.1.1

