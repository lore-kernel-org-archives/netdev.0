From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 02/12] l2tp: add udp encap socket destroy handler
Date: Tue, 19 Mar 2013 16:11:13 +0000
Message-ID: <1363709483-24021-3-git-send-email-tparkin@katalix.com>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36142 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932717Ab3CSQLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:30 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L2TP sessions hold a reference to the tunnel socket to prevent it going away
while sessions are still active.  However, since tunnel destruction is handled
by the sock sk_destruct callback there is a catch-22: a tunnel with sessions
cannot be deleted since each session holds a reference to the tunnel socket.
If userspace closes a managed tunnel socket, or dies, the tunnel will persist
and it will be neccessary to individually delete the sessions using netlink
commands.  This is ugly.

To prevent this occuring, this patch leverages the udp encapsulation socket
destroy callback to gain early notification when the tunnel socket is closed.
This allows us to safely close the sessions running in the tunnel, dropping
the tunnel socket references in the process.  The tunnel socket is then
destroyed as normal, and the tunnel resources deallocated in sk_destruct.

While we're at it, ensure that l2tp_tunnel_closeall correctly drops session
references to allow the sessions to be deleted rather than leaking.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index d36875f..ee726a7 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1282,6 +1282,7 @@ static void l2tp_tunnel_destruct(struct sock *sk)
 		/* No longer an encapsulation socket. See net/ipv4/udp.c */
 		(udp_sk(sk))->encap_type = 0;
 		(udp_sk(sk))->encap_rcv = NULL;
+		(udp_sk(sk))->encap_destroy = NULL;
 		break;
 	case L2TP_ENCAPTYPE_IP:
 		break;
@@ -1360,6 +1361,8 @@ again:
 			if (session->deref != NULL)
 				(*session->deref)(session);
 
+			l2tp_session_dec_refcount(session);
+
 			write_lock_bh(&tunnel->hlist_lock);
 
 			/* Now restart from the beginning of this hash
@@ -1373,6 +1376,16 @@ again:
 	write_unlock_bh(&tunnel->hlist_lock);
 }
 
+/* Tunnel socket destroy hook for UDP encapsulation */
+static void l2tp_udp_encap_destroy(struct sock *sk)
+{
+	struct l2tp_tunnel *tunnel = l2tp_sock_to_tunnel(sk);
+	if (tunnel) {
+		l2tp_tunnel_closeall(tunnel);
+		sock_put(sk);
+	}
+}
+
 /* Really kill the tunnel.
  * Come here only when all sessions have been cleared from the tunnel.
  */
@@ -1668,6 +1681,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 		/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
 		udp_sk(sk)->encap_type = UDP_ENCAP_L2TPINUDP;
 		udp_sk(sk)->encap_rcv = l2tp_udp_encap_recv;
+		udp_sk(sk)->encap_destroy = l2tp_udp_encap_destroy;
 #if IS_ENABLED(CONFIG_IPV6)
 		if (sk->sk_family == PF_INET6)
 			udpv6_encap_enable();
-- 
1.7.9.5
