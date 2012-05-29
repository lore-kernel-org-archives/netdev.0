From: James Chapman <jchapman@katalix.com>
Subject: [PATCH] l2tp: fix oops in L2TP IP sockets for connect() AF_UNSPEC case
Date: Tue, 29 May 2012 14:30:42 +0100
Message-ID: <1338298242-22261-1-git-send-email-jchapman@katalix.com>
Cc: levinsasha928@gmail.com, James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:48141 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751810Ab2E2Nav (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 09:30:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An application may call connect() to disconnect a socket using an
address with family AF_UNSPEC. The L2TP IP sockets were not handling
this case when the socket is not bound and an attempt to connect()
using AF_UNSPEC in such cases would result in an oops. This patch
addresses the problem by protecting the sk_prot->disconnect() call
against trying to unhash the socket before it is bound.

The L2TP IPv4 and IPv6 sockets have the same problem. Both are fixed
by this patch.

The patch also adds more checks that the sockaddr supplied to bind()
and connect() calls is valid.

 RIP: 0010:[<ffffffff82e133b0>]  [<ffffffff82e133b0>] inet_unhash+0x50/0xd0
 RSP: 0018:ffff88001989be28  EFLAGS: 00010293
 Stack:
  ffff8800407a8000 0000000000000000 ffff88001989be78 ffffffff82e3a249
  ffffffff82e3a050 ffff88001989bec8 ffff88001989be88 ffff8800407a8000
  0000000000000010 ffff88001989bec8 ffff88001989bea8 ffffffff82e42639
 Call Trace:
 [<ffffffff82e3a249>] udp_disconnect+0x1f9/0x290
 [<ffffffff82e42639>] inet_dgram_connect+0x29/0x80
 [<ffffffff82d012fc>] sys_connect+0x9c/0x100

Reported-by: Sasha Levin <levinsasha928@gmail.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_ip.c  |   24 ++++++++++++++++++++++--
 net/l2tp/l2tp_ip6.c |   18 +++++++++++++++++-
 2 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 889f5d1..70614e7 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -239,9 +239,16 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_l2tpip *addr = (struct sockaddr_l2tpip *) uaddr;
-	int ret = -EINVAL;
+	int ret;
 	int chk_addr_ret;
 
+	if (!sock_flag(sk, SOCK_ZAPPED))
+		return -EINVAL;
+	if (addr_len < sizeof(struct sockaddr_l2tpip))
+		return -EINVAL;
+	if (addr->l2tp_family != AF_INET)
+		return -EINVAL;
+
 	ret = -EADDRINUSE;
 	read_lock_bh(&l2tp_ip_lock);
 	if (__l2tp_ip_bind_lookup(&init_net, addr->l2tp_addr.s_addr, sk->sk_bound_dev_if, addr->l2tp_conn_id))
@@ -272,6 +279,8 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk_del_node_init(sk);
 	write_unlock_bh(&l2tp_ip_lock);
 	ret = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
+
 out:
 	release_sock(sk);
 
@@ -288,6 +297,9 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	struct sockaddr_l2tpip *lsa = (struct sockaddr_l2tpip *) uaddr;
 	int rc;
 
+	if (sock_flag(sk, SOCK_ZAPPED)) /* Must bind first - autobinding does not work */
+		return -EINVAL;
+
 	if (addr_len < sizeof(*lsa))
 		return -EINVAL;
 
@@ -311,6 +323,14 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	return rc;
 }
 
+static int l2tp_ip_disconnect(struct sock *sk, int flags)
+{
+	if (sock_flag(sk, SOCK_ZAPPED))
+		return 0;
+
+	return udp_disconnect(sk, flags);
+}
+
 static int l2tp_ip_getname(struct socket *sock, struct sockaddr *uaddr,
 			   int *uaddr_len, int peer)
 {
@@ -530,7 +550,7 @@ static struct proto l2tp_ip_prot = {
 	.close		   = l2tp_ip_close,
 	.bind		   = l2tp_ip_bind,
 	.connect	   = l2tp_ip_connect,
-	.disconnect	   = udp_disconnect,
+	.disconnect	   = l2tp_ip_disconnect,
 	.ioctl		   = udp_ioctl,
 	.destroy	   = l2tp_ip_destroy_sock,
 	.setsockopt	   = ip_setsockopt,
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 0291d8d..35e1e4b 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -258,6 +258,10 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	int addr_type;
 	int err;
 
+	if (!sock_flag(sk, SOCK_ZAPPED))
+		return -EINVAL;
+	if (addr->l2tp_family != AF_INET6)
+		return -EINVAL;
 	if (addr_len < sizeof(*addr))
 		return -EINVAL;
 
@@ -331,6 +335,7 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk_del_node_init(sk);
 	write_unlock_bh(&l2tp_ip6_lock);
 
+	sock_reset_flag(sk, SOCK_ZAPPED);
 	release_sock(sk);
 	return 0;
 
@@ -354,6 +359,9 @@ static int l2tp_ip6_connect(struct sock *sk, struct sockaddr *uaddr,
 	int	addr_type;
 	int rc;
 
+	if (sock_flag(sk, SOCK_ZAPPED)) /* Must bind first - autobinding does not work */
+		return -EINVAL;
+
 	if (addr_len < sizeof(*lsa))
 		return -EINVAL;
 
@@ -383,6 +391,14 @@ static int l2tp_ip6_connect(struct sock *sk, struct sockaddr *uaddr,
 	return rc;
 }
 
+static int l2tp_ip6_disconnect(struct sock *sk, int flags)
+{
+	if (sock_flag(sk, SOCK_ZAPPED))
+		return 0;
+
+	return udp_disconnect(sk, flags);
+}
+
 static int l2tp_ip6_getname(struct socket *sock, struct sockaddr *uaddr,
 			    int *uaddr_len, int peer)
 {
@@ -689,7 +705,7 @@ static struct proto l2tp_ip6_prot = {
 	.close		   = l2tp_ip6_close,
 	.bind		   = l2tp_ip6_bind,
 	.connect	   = l2tp_ip6_connect,
-	.disconnect	   = udp_disconnect,
+	.disconnect	   = l2tp_ip6_disconnect,
 	.ioctl		   = udp_ioctl,
 	.destroy	   = l2tp_ip6_destroy_sock,
 	.setsockopt	   = ipv6_setsockopt,
-- 
1.7.0.4
