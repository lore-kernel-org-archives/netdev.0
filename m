From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 6/11 net-2.6.26] [INET]: Let inet_csk_ctl_sock_create return sock rather than socket.
Date: Fri, 28 Mar 2008 12:08:53 +0300
Message-ID: <1206695338-5947-6-git-send-email-den@openvz.org>
References: <1206695071.3271.8.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37794 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754296AbYC1JIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:08:32 -0400
In-Reply-To: <1206695071.3271.8.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All upper protocol layers are already use sock internally.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/inet_connection_sock.h |    2 +-
 net/dccp/ipv4.c                    |    4 +---
 net/dccp/ipv6.c                    |    4 +---
 net/ipv4/inet_connection_sock.c    |   12 +++++++-----
 net/ipv4/tcp_ipv4.c                |    4 +---
 net/ipv6/tcp_ipv6.c                |   11 ++++-------
 net/sctp/protocol.c                |    4 +---
 7 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index f00f057..a5d4f05 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -327,7 +327,7 @@ extern void inet_csk_listen_stop(struct sock *sk);
 
 extern void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
 
-extern int inet_csk_ctl_sock_create(struct socket **sock,
+extern int inet_csk_ctl_sock_create(struct sock **sk,
 				    unsigned short family,
 				    unsigned short type,
 				    unsigned char protocol);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 4ee34db..52566ad 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -994,7 +994,6 @@ static struct inet_protosw dccp_v4_protosw = {
 
 static int __init dccp_v4_init(void)
 {
-	struct socket *socket;
 	int err = proto_register(&dccp_v4_prot, 1);
 
 	if (err != 0)
@@ -1006,11 +1005,10 @@ static int __init dccp_v4_init(void)
 
 	inet_register_protosw(&dccp_v4_protosw);
 
-	err = inet_csk_ctl_sock_create(&socket, PF_INET,
+	err = inet_csk_ctl_sock_create(&dccp_v4_ctl_sk, PF_INET,
 				       SOCK_DCCP, IPPROTO_DCCP);
 	if (err)
 		goto out_unregister_protosw;
-	dccp_v4_ctl_sk = socket->sk;
 out:
 	return err;
 out_unregister_protosw:
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 85665d5..a2ffc98 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1176,7 +1176,6 @@ static struct inet_protosw dccp_v6_protosw = {
 
 static int __init dccp_v6_init(void)
 {
-	struct socket *socket;
 	int err = proto_register(&dccp_v6_prot, 1);
 
 	if (err != 0)
@@ -1188,11 +1187,10 @@ static int __init dccp_v6_init(void)
 
 	inet6_register_protosw(&dccp_v6_protosw);
 
-	err = inet_csk_ctl_sock_create(&socket, PF_INET6,
+	err = inet_csk_ctl_sock_create(&dccp_v6_ctl_sk, PF_INET6,
 				       SOCK_DCCP, IPPROTO_DCCP);
 	if (err != 0)
 		goto out_unregister_protosw;
-	dccp_v6_ctl_sk = socket->sk;
 out:
 	return err;
 out_unregister_protosw:
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index a7fcaf2..2cb3552 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -651,19 +651,21 @@ void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
 
 EXPORT_SYMBOL_GPL(inet_csk_addr2sockaddr);
 
-int inet_csk_ctl_sock_create(struct socket **sock, unsigned short family,
+int inet_csk_ctl_sock_create(struct sock **sk, unsigned short family,
 			     unsigned short type, unsigned char protocol)
 {
-	int rc = sock_create_kern(family, type, protocol, sock);
+	struct socket *socket;
+	int rc = sock_create_kern(family, type, protocol, &socket);
 
 	if (rc == 0) {
-		(*sock)->sk->sk_allocation = GFP_ATOMIC;
-		inet_sk((*sock)->sk)->uc_ttl = -1;
+		*sk = socket->sk;
+		(*sk)->sk_allocation = GFP_ATOMIC;
+		inet_sk(*sk)->uc_ttl = -1;
 		/*
 		 * Unhash it so that IP input processing does not even see it,
 		 * we do not wish this socket to see incoming packets.
 		 */
-		(*sock)->sk->sk_prot->unhash((*sock)->sk);
+		(*sk)->sk_prot->unhash(*sk);
 	}
 	return rc;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9d47870..2ee7fb9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2493,11 +2493,9 @@ struct proto tcp_prot = {
 
 void __init tcp_v4_init(void)
 {
-	struct socket *__tcp_socket;
-	if (inet_csk_ctl_sock_create(&__tcp_socket, PF_INET, SOCK_RAW,
+	if (inet_csk_ctl_sock_create(&tcp_sock, PF_INET, SOCK_RAW,
 				     IPPROTO_TCP) < 0)
 		panic("Failed to create the TCP control socket.\n");
-	tcp_sock = __tcp_socket->sk;
 }
 
 EXPORT_SYMBOL(ipv4_specific);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 323c7e0..fdb670f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2202,16 +2202,13 @@ static struct inet_protosw tcpv6_protosw = {
 static int tcpv6_net_init(struct net *net)
 {
 	int err;
-	struct socket *sock;
-	struct sock *sk;
 
-	err = inet_csk_ctl_sock_create(&sock, PF_INET6, SOCK_RAW, IPPROTO_TCP);
+	err = inet_csk_ctl_sock_create(&net->ipv6.tcp_sk,
+				       PF_INET6, SOCK_RAW, IPPROTO_TCP);
 	if (err)
 		return err;
-
-	net->ipv6.tcp_sk = sk = sock->sk;
-	sk_change_net(sk, net);
-	return err;
+	sk_change_net(net->ipv6.tcp_sk, net);
+	return 0;
 }
 
 static void tcpv6_net_exit(struct net *net)
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 2715aca..58c1d84 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -674,21 +674,19 @@ static int sctp_ctl_sock_init(void)
 {
 	int err;
 	sa_family_t family;
-	struct socket *socket;
 
 	if (sctp_get_pf_specific(PF_INET6))
 		family = PF_INET6;
 	else
 		family = PF_INET;
 
-	err = inet_csk_ctl_sock_create(&socket,
+	err = inet_csk_ctl_sock_create(&sctp_ctl_sock,
 				       family, SOCK_SEQPACKET, IPPROTO_SCTP);
 	if (err < 0) {
 		printk(KERN_ERR
 		       "SCTP: Failed to create the SCTP control socket.\n");
 		return err;
 	}
-	sctp_ctl_sock = socket->sk;
 	return 0;
 }
 
-- 
1.5.3.rc5

