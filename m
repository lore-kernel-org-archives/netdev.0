From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 11/13] Bluetooth: Check L2CAP pending status before sending connect request
Date: Thu,  8 Jul 2010 17:00:00 -0300
Message-ID: <19fee7ea365d2835b1640de893baaab99e778dde.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36239 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758596Ab0GHUAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:52 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Emeltchenko <andrei.emeltchenko@nokia.com>

Due to race condition in L2CAP state machine L2CAP Connection Request
may be sent twice for SDP with the same source channel id. Problems
reported connecting to Apple products, some carkit, Blackberry phones.

...
2010-06-07 21:18:03.651031 < ACL data: handle 1 flags 0x02 dlen 12
    L2CAP(s): Connect req: psm 1 scid 0x0040
2010-06-07 21:18:03.653473 > HCI Event: Number of Completed Packets (0x13) plen 5
    handle 1 packets 1
2010-06-07 21:18:03.653808 > HCI Event: Auth Complete (0x06) plen 3
    status 0x00 handle 1
2010-06-07 21:18:03.653869 < ACL data: handle 1 flags 0x02 dlen 12
    L2CAP(s): Connect req: psm 1 scid 0x0040
...

Patch uses L2CAP_CONF_CONNECT_PEND flag to mark that L2CAP Connection
Request has been sent already.

Modified version of patch from Ville Tervo.

Signed-off-by: Andrei Emeltchenko <andrei.emeltchenko@nokia.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 6785e52..c2fb26d 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -417,6 +417,11 @@ static inline void l2cap_send_rr_or_rnr(struct l2cap_pinfo *pi, u16 control)
 	l2cap_send_sframe(pi, control);
 }
 
+static inline int __l2cap_no_conn_pending(struct sock *sk)
+{
+	return !(l2cap_pi(sk)->conf_state & L2CAP_CONF_CONNECT_PEND);
+}
+
 static void l2cap_do_start(struct sock *sk)
 {
 	struct l2cap_conn *conn = l2cap_pi(sk)->conn;
@@ -425,12 +430,13 @@ static void l2cap_do_start(struct sock *sk)
 		if (!(conn->info_state & L2CAP_INFO_FEAT_MASK_REQ_DONE))
 			return;
 
-		if (l2cap_check_security(sk)) {
+		if (l2cap_check_security(sk) && __l2cap_no_conn_pending(sk)) {
 			struct l2cap_conn_req req;
 			req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
 			req.psm  = l2cap_pi(sk)->psm;
 
 			l2cap_pi(sk)->ident = l2cap_get_ident(conn);
+			l2cap_pi(sk)->conf_state |= L2CAP_CONF_CONNECT_PEND;
 
 			l2cap_send_cmd(conn, l2cap_pi(sk)->ident,
 					L2CAP_CONN_REQ, sizeof(req), &req);
@@ -493,12 +499,14 @@ static void l2cap_conn_start(struct l2cap_conn *conn)
 		}
 
 		if (sk->sk_state == BT_CONNECT) {
-			if (l2cap_check_security(sk)) {
+			if (l2cap_check_security(sk) &&
+					__l2cap_no_conn_pending(sk)) {
 				struct l2cap_conn_req req;
 				req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
 				req.psm  = l2cap_pi(sk)->psm;
 
 				l2cap_pi(sk)->ident = l2cap_get_ident(conn);
+				l2cap_pi(sk)->conf_state |= L2CAP_CONF_CONNECT_PEND;
 
 				l2cap_send_cmd(conn, l2cap_pi(sk)->ident,
 					L2CAP_CONN_REQ, sizeof(req), &req);
@@ -2948,7 +2956,6 @@ static inline int l2cap_connect_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hd
 		l2cap_pi(sk)->ident = 0;
 		l2cap_pi(sk)->dcid = dcid;
 		l2cap_pi(sk)->conf_state |= L2CAP_CONF_REQ_SENT;
-
 		l2cap_pi(sk)->conf_state &= ~L2CAP_CONF_CONNECT_PEND;
 
 		l2cap_send_cmd(conn, l2cap_get_ident(conn), L2CAP_CONF_REQ,
@@ -4430,6 +4437,7 @@ static int l2cap_security_cfm(struct hci_conn *hcon, u8 status, u8 encrypt)
 				req.psm  = l2cap_pi(sk)->psm;
 
 				l2cap_pi(sk)->ident = l2cap_get_ident(conn);
+				l2cap_pi(sk)->conf_state |= L2CAP_CONF_CONNECT_PEND;
 
 				l2cap_send_cmd(conn, l2cap_pi(sk)->ident,
 					L2CAP_CONN_REQ, sizeof(req), &req);
-- 
1.7.1.1

