From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 30/47] Bluetooth: Create separate l2cap_send_disconn_req() function
Date: Sun, 30 Aug 2009 01:50:44 -0700
Message-ID: <22121fc9152ca8f25a2d790860832ccb6a414c4d.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
 <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
 <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
 <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
 <9666fb356da78a5ec28403197d72e8cd6aa16424.1251621661.git.marcel@holtmann.org>
 <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
 <91d697302b291205171840bfe84c1563e171acb2.1251621661.git.marcel@holtmann.org>
 <e0721f99ba33d13a88746732be2d74ca805abf55.1251621661.git.marcel@holtmann.org>
 <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
 <3318b2362bf0528be77123c480249663557dfbfc.1251621661.git.marcel@holtmann.org>
 <5959809ded86e267c1a95fb44738a224c30d3434.1251621661.git.marcel@holtmann.org>
 <a6a67efd7088702fdbbb780c5a3f8e1a74e77b63.1251621661.git.marcel@holtmann.org>
 <52d18347dfb61519aa0f58fe1759edd3ad8c4e36.1251621661.git.marcel@holtmann.org>
 <44dd46de325c4d47abfd1361e5d84a548edb8e42.1251621661.git.marcel@holtmann.org>
 <c6b03cf986eab00e20d0dbc852b233bb83472138.1251621661.git.marcel@holtmann.org>
 <65c7c4918450f8c4545ccb02a9c7a3d77e073535.1251621661.git.marcel@holtmann.org>
 <f2fcfcd670257236ebf2088bbdf26f6a8ef459fe.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53315 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026AbZH3Iw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:26 -0400
In-Reply-To: <f2fcfcd670257236ebf2088bbdf26f6a8ef459fe.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

The code for sending a disconnect request was repeated several times
within L2CAP source code. So move this into its own function.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   46 ++++++++++++++++------------------------------
 1 files changed, 16 insertions(+), 30 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index af0fbf9..c1b5620 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -366,6 +366,16 @@ static void l2cap_do_start(struct sock *sk)
 	}
 }
 
+static void l2cap_send_disconn_req(struct l2cap_conn *conn, struct sock *sk)
+{
+	struct l2cap_disconn_req req;
+
+	req.dcid = cpu_to_le16(l2cap_pi(sk)->dcid);
+	req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
+	l2cap_send_cmd(conn, l2cap_get_ident(conn),
+			L2CAP_DISCONN_REQ, sizeof(req), &req);
+}
+
 /* ---- L2CAP connections ---- */
 static void l2cap_conn_start(struct l2cap_conn *conn)
 {
@@ -650,15 +660,10 @@ static void __l2cap_sock_close(struct sock *sk, int reason)
 	case BT_CONFIG:
 		if (sk->sk_type == SOCK_SEQPACKET) {
 			struct l2cap_conn *conn = l2cap_pi(sk)->conn;
-			struct l2cap_disconn_req req;
 
 			sk->sk_state = BT_DISCONN;
 			l2cap_sock_set_timer(sk, sk->sk_sndtimeo);
-
-			req.dcid = cpu_to_le16(l2cap_pi(sk)->dcid);
-			req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
-			l2cap_send_cmd(conn, l2cap_get_ident(conn),
-					L2CAP_DISCONN_REQ, sizeof(req), &req);
+			l2cap_send_disconn_req(conn, sk);
 		} else
 			l2cap_chan_del(sk, reason);
 		break;
@@ -1786,13 +1791,8 @@ static int l2cap_build_conf_req(struct sock *sk, void *data)
 	case L2CAP_MODE_STREAMING:
 	case L2CAP_MODE_ERTM:
 		pi->conf_state |= L2CAP_CONF_STATE2_DEVICE;
-		if (!l2cap_mode_supported(pi->mode, pi->conn->feat_mask)) {
-			struct l2cap_disconn_req req;
-			req.dcid = cpu_to_le16(pi->dcid);
-			req.scid = cpu_to_le16(pi->scid);
-			l2cap_send_cmd(pi->conn, l2cap_get_ident(pi->conn),
-					L2CAP_DISCONN_REQ, sizeof(req), &req);
-		}
+		if (!l2cap_mode_supported(pi->mode, pi->conn->feat_mask))
+			l2cap_send_disconn_req(pi->conn, sk);
 		break;
 	default:
 		pi->mode = l2cap_select_mode(rfc.mode, pi->conn->feat_mask);
@@ -2286,11 +2286,7 @@ static inline int l2cap_config_req(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 	/* Complete config. */
 	len = l2cap_parse_conf_req(sk, rsp);
 	if (len < 0) {
-		struct l2cap_disconn_req req;
-		req.dcid = cpu_to_le16(l2cap_pi(sk)->dcid);
-		req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
-		l2cap_send_cmd(conn, l2cap_get_ident(conn),
-					L2CAP_DISCONN_REQ, sizeof(req), &req);
+		l2cap_send_disconn_req(conn, sk);
 		goto unlock;
 	}
 
@@ -2352,11 +2348,7 @@ static inline int l2cap_config_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 			len = l2cap_parse_conf_rsp(sk, rsp->data,
 							len, req, &result);
 			if (len < 0) {
-				struct l2cap_disconn_req req;
-				req.dcid = cpu_to_le16(l2cap_pi(sk)->dcid);
-				req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
-				l2cap_send_cmd(conn, l2cap_get_ident(conn),
-					L2CAP_DISCONN_REQ, sizeof(req), &req);
+				l2cap_send_disconn_req(conn, sk);
 				goto done;
 			}
 
@@ -2372,13 +2364,7 @@ static inline int l2cap_config_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 		sk->sk_state = BT_DISCONN;
 		sk->sk_err = ECONNRESET;
 		l2cap_sock_set_timer(sk, HZ * 5);
-		{
-			struct l2cap_disconn_req req;
-			req.dcid = cpu_to_le16(l2cap_pi(sk)->dcid);
-			req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
-			l2cap_send_cmd(conn, l2cap_get_ident(conn),
-					L2CAP_DISCONN_REQ, sizeof(req), &req);
-		}
+		l2cap_send_disconn_req(conn, sk);
 		goto done;
 	}
 
-- 
1.6.2.5

