From: James Chapman <jchapman@katalix.com>
Subject: [PATCH stable] l2tp: fix oops in L2TP IP sockets for connect() AF_UNSPEC case
Date: Wed, 30 May 2012 10:13:23 +0100
Message-ID: <1338369203-729-1-git-send-email-jchapman@katalix.com>
Cc: levinsasha928@gmail.com, James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:42022 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932423Ab2E3JN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2012 05:13:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An application may call connect() to disconnect a socket using an
address with family AF_UNSPEC. The L2TP IP sockets were not handling
this case when the socket is not bound and an attempt to connect()
using AF_UNSPEC in such cases would result in an oops. This patch
addresses the problem by protecting the sk_prot->disconnect() call
against trying to unhash the socket before it is bound.

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
A version of this patch is already applied to the net tree.

 net/l2tp/l2tp_ip.c |   30 ++++++++++++++++++++++++------
 1 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 6274f0b..cc8ad7b 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -251,9 +251,16 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
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
@@ -284,6 +291,8 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk_del_node_init(sk);
 	write_unlock_bh(&l2tp_ip_lock);
 	ret = 0;
+	sock_reset_flag(sk, SOCK_ZAPPED);
+
 out:
 	release_sock(sk);
 
@@ -304,13 +313,14 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	__be32 saddr;
 	int oif, rc;
 
-	rc = -EINVAL;
+	if (sock_flag(sk, SOCK_ZAPPED)) /* Must bind first - autobinding does not work */
+		return -EINVAL;
+
 	if (addr_len < sizeof(*lsa))
-		goto out;
+		return -EINVAL;
 
-	rc = -EAFNOSUPPORT;
 	if (lsa->l2tp_family != AF_INET)
-		goto out;
+		return -EAFNOSUPPORT;
 
 	lock_sock(sk);
 
@@ -364,6 +374,14 @@ out:
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
@@ -599,7 +617,7 @@ static struct proto l2tp_ip_prot = {
 	.close		   = l2tp_ip_close,
 	.bind		   = l2tp_ip_bind,
 	.connect	   = l2tp_ip_connect,
-	.disconnect	   = udp_disconnect,
+	.disconnect	   = l2tp_ip_disconnect,
 	.ioctl		   = udp_ioctl,
 	.destroy	   = l2tp_ip_destroy_sock,
 	.setsockopt	   = ip_setsockopt,
-- 
1.7.0.4
