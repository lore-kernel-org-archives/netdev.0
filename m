From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 23/27] afnetns: use user_ns from afnetns for checking for binding to port < 1024
Date: Mon, 13 Mar 2017 00:01:47 +0100
Message-ID: <20170312230151.5185-24-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39683 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935675AbdCLXCW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:22 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id E5AE8206F7
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:14 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 58C0E240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:14 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet_common.h |  2 +-
 net/ipv4/af_inet.c        | 37 ++++++++++++++++++++++---------------
 net/ipv6/af_inet6.c       |  2 +-
 3 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 4ac8229dca6af4..16dfbb02296be6 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -30,7 +30,7 @@ int inet_shutdown(struct socket *sock, int how);
 int inet_listen(struct socket *sock, int backlog);
 void inet_sock_destruct(struct sock *sk);
 int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len);
-int inet_allow_bind(struct sock *sk, __be32 addr);
+int inet_allow_bind(struct sock *sk, __be32 addr, unsigned short snum);
 int inet_getname(struct socket *sock, struct sockaddr *uaddr, int *uaddr_len,
 		 int peer);
 int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5f11399bafd16f..da7e6299073743 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -428,12 +428,14 @@ int inet_release(struct socket *sock)
 }
 EXPORT_SYMBOL(inet_release);
 
-int inet_allow_bind(struct sock *sk, __be32 addr)
+int inet_allow_bind(struct sock *sk, __be32 addr, unsigned short snum)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct net *net = sock_net(sk);
+	struct afnetns *afnetns = NULL;
 	u32 tb_id = RT_TABLE_LOCAL;
 	int chk_addr_ret;
+	int err = 0;
 
 	tb_id = l3mdev_fib_table_by_index(net, sk->sk_bound_dev_if) ? : tb_id;
 	chk_addr_ret = inet_addr_type_table(net, addr, tb_id);
@@ -453,18 +455,29 @@ int inet_allow_bind(struct sock *sk, __be32 addr)
 	    chk_addr_ret != RTN_BROADCAST)
 		return -EADDRNOTAVAIL;
 
+	rcu_read_lock();
 	if (chk_addr_ret == RTN_LOCAL &&
 	    net_afnetns(net) != sock_afnetns(sk)) {
-		struct afnetns *afnetns;
-
-		rcu_read_lock();
 		afnetns = ifa_find_afnetns_rcu(net, addr);
 		if (afnetns != sock_afnetns(sk))
-			chk_addr_ret = -EADDRNOTAVAIL;
-		rcu_read_unlock();
+			err = -EADDRNOTAVAIL;
+	}
+
+	if (!err && snum && snum < inet_prot_sock(net)) {
+		struct user_namespace *user_ns;
+
+#if IS_ENABLED(CONFIG_AFNETNS)
+		user_ns = afnetns ? afnetns->user_ns : net->user_ns;
+#else
+		user_ns = net->user_ns;
+#endif
+		if (!ns_capable(user_ns, CAP_NET_BIND_SERVICE))
+			err = -EACCES;
 	}
 
-	return chk_addr_ret;
+	rcu_read_unlock();
+
+	return err;
 }
 EXPORT_SYMBOL(inet_allow_bind);
 
@@ -473,7 +486,6 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct sockaddr_in *addr = (struct sockaddr_in *)uaddr;
 	struct sock *sk = sock->sk;
 	struct inet_sock *inet = inet_sk(sk);
-	struct net *net = sock_net(sk);
 	unsigned short snum;
 	int chk_addr_ret;
 	int err;
@@ -497,18 +509,13 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 	}
 
-	chk_addr_ret = inet_allow_bind(sk, addr->sin_addr.s_addr);
+	snum = ntohs(addr->sin_port);
+	chk_addr_ret = inet_allow_bind(sk, addr->sin_addr.s_addr, snum);
 	if (chk_addr_ret < 0) {
 		err = chk_addr_ret;
 		goto out;
 	}
 
-	snum = ntohs(addr->sin_port);
-	err = -EACCES;
-	if (snum && snum < inet_prot_sock(net) &&
-	    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
-		goto out;
-
 	/*      We keep a pair of addresses. rcv_saddr is the one
 	 *      used by hash lookups, and saddr is used for transmit.
 	 *
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index ffb116297c0950..30aff01eba5be0 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -324,7 +324,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 		}
 
-		err = inet_allow_bind(sk, addr->sin6_addr.s6_addr32[3]);
+		err = inet_allow_bind(sk, addr->sin6_addr.s6_addr32[3], snum);
 		if (err < 0)
 			goto out;
 		else
-- 
2.9.3
