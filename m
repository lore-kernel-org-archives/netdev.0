From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 05/10] l2tp: pppol2tp_connect() handles ipv6 sockaddr variants
Date: Fri, 20 Apr 2012 10:02:48 +0100
Message-ID: <1334912573-28804-6-git-send-email-jchapman@katalix.com>
References: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
Cc: bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:56664 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752048Ab2DTJDB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 05:03:01 -0400
In-Reply-To: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace uses connect() to associate a pppol2tp socket with a tunnel
socket. This needs to allow the caller to supply the new IPv6
sockaddr_pppol2tp structures if IPv6 is used.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_ppp.c |   36 ++++++++++++++++++++++++++++--------
 1 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 27b9dec..9f2c421 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -628,7 +628,6 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_pppol2tp *sp = (struct sockaddr_pppol2tp *) uservaddr;
-	struct sockaddr_pppol2tpv3 *sp3 = (struct sockaddr_pppol2tpv3 *) uservaddr;
 	struct pppox_sock *po = pppox_sk(sk);
 	struct l2tp_session *session = NULL;
 	struct l2tp_tunnel *tunnel;
@@ -657,7 +656,13 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	if (sk->sk_user_data)
 		goto end; /* socket is already attached */
 
-	/* Get params from socket address. Handle L2TPv2 and L2TPv3 */
+	/* Get params from socket address. Handle L2TPv2 and L2TPv3.
+	 * This is nasty because there are different sockaddr_pppol2tp
+	 * structs for L2TPv2, L2TPv3, over IPv4 and IPv6. We use
+	 * the sockaddr size to determine which structure the caller
+	 * is using.
+	 */
+	peer_tunnel_id = 0;
 	if (sockaddr_len == sizeof(struct sockaddr_pppol2tp)) {
 		fd = sp->pppol2tp.fd;
 		tunnel_id = sp->pppol2tp.s_tunnel;
@@ -665,12 +670,31 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 		session_id = sp->pppol2tp.s_session;
 		peer_session_id = sp->pppol2tp.d_session;
 	} else if (sockaddr_len == sizeof(struct sockaddr_pppol2tpv3)) {
+		struct sockaddr_pppol2tpv3 *sp3 =
+			(struct sockaddr_pppol2tpv3 *) sp;
 		ver = 3;
 		fd = sp3->pppol2tp.fd;
 		tunnel_id = sp3->pppol2tp.s_tunnel;
 		peer_tunnel_id = sp3->pppol2tp.d_tunnel;
 		session_id = sp3->pppol2tp.s_session;
 		peer_session_id = sp3->pppol2tp.d_session;
+	} else if (sockaddr_len == sizeof(struct sockaddr_pppol2tpin6)) {
+		struct sockaddr_pppol2tpin6 *sp6 =
+			(struct sockaddr_pppol2tpin6 *) sp;
+		fd = sp6->pppol2tp.fd;
+		tunnel_id = sp6->pppol2tp.s_tunnel;
+		peer_tunnel_id = sp6->pppol2tp.d_tunnel;
+		session_id = sp6->pppol2tp.s_session;
+		peer_session_id = sp6->pppol2tp.d_session;
+	} else if (sockaddr_len == sizeof(struct sockaddr_pppol2tpv3in6)) {
+		struct sockaddr_pppol2tpv3in6 *sp6 =
+			(struct sockaddr_pppol2tpv3in6 *) sp;
+		ver = 3;
+		fd = sp6->pppol2tp.fd;
+		tunnel_id = sp6->pppol2tp.s_tunnel;
+		peer_tunnel_id = sp6->pppol2tp.d_tunnel;
+		session_id = sp6->pppol2tp.s_session;
+		peer_session_id = sp6->pppol2tp.d_session;
 	} else {
 		error = -EINVAL;
 		goto end; /* bad socket address */
@@ -711,12 +735,8 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	if (tunnel->recv_payload_hook == NULL)
 		tunnel->recv_payload_hook = pppol2tp_recv_payload_hook;
 
-	if (tunnel->peer_tunnel_id == 0) {
-		if (ver == 2)
-			tunnel->peer_tunnel_id = sp->pppol2tp.d_tunnel;
-		else
-			tunnel->peer_tunnel_id = sp3->pppol2tp.d_tunnel;
-	}
+	if (tunnel->peer_tunnel_id == 0)
+		tunnel->peer_tunnel_id = peer_tunnel_id;
 
 	/* Create session if it doesn't already exist. We handle the
 	 * case where a session was previously created by the netlink
-- 
1.7.0.4
