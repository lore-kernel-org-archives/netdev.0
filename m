From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 08/27] afnetns: factor out inet_allow_bind
Date: Mon, 13 Mar 2017 00:01:32 +0100
Message-ID: <20170312230151.5185-9-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:45411 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935640AbdCLXCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:16 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 64F092067F
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:59 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id D067D240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:58 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet_common.h |  1 +
 net/ipv4/af_inet.c        | 51 ++++++++++++++++++++++++++++++-----------------
 2 files changed, 34 insertions(+), 18 deletions(-)

diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index b7952d55b9c000..4ac8229dca6af4 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -30,6 +30,7 @@ int inet_shutdown(struct socket *sock, int how);
 int inet_listen(struct socket *sock, int backlog);
 void inet_sock_destruct(struct sock *sk);
 int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len);
+int inet_allow_bind(struct sock *sk, __be32 addr);
 int inet_getname(struct socket *sock, struct sockaddr *uaddr, int *uaddr_len,
 		 int peer);
 int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 602d40f43687c9..aee599e23137e7 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -428,6 +428,35 @@ int inet_release(struct socket *sock)
 }
 EXPORT_SYMBOL(inet_release);
 
+int inet_allow_bind(struct sock *sk, __be32 addr)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
+	u32 tb_id = RT_TABLE_LOCAL;
+	int chk_addr_ret;
+
+	tb_id = l3mdev_fib_table_by_index(net, sk->sk_bound_dev_if) ? : tb_id;
+	chk_addr_ret = inet_addr_type_table(net, addr, tb_id);
+
+	/* Not specified by any standard per-se, however it breaks too
+	 * many applications when removed.  It is unfortunate since
+	 * allowing applications to make a non-local bind solves
+	 * several problems with systems using dynamic addressing.
+	 * (ie. your servers still start up even if your ISDN link
+	 *  is temporarily down)
+	 */
+	if (!net->ipv4.sysctl_ip_nonlocal_bind &&
+	    !(inet->freebind || inet->transparent) &&
+	    addr != htonl(INADDR_ANY) &&
+	    chk_addr_ret != RTN_LOCAL &&
+	    chk_addr_ret != RTN_MULTICAST &&
+	    chk_addr_ret != RTN_BROADCAST)
+		return -EADDRNOTAVAIL;
+
+	return chk_addr_ret;
+}
+EXPORT_SYMBOL(inet_allow_bind);
+
 int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
 	struct sockaddr_in *addr = (struct sockaddr_in *)uaddr;
@@ -436,7 +465,6 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct net *net = sock_net(sk);
 	unsigned short snum;
 	int chk_addr_ret;
-	u32 tb_id = RT_TABLE_LOCAL;
 	int err;
 
 	/* If the socket has its own bind function then use it. (RAW) */
@@ -458,24 +486,11 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 	}
 
-	tb_id = l3mdev_fib_table_by_index(net, sk->sk_bound_dev_if) ? : tb_id;
-	chk_addr_ret = inet_addr_type_table(net, addr->sin_addr.s_addr, tb_id);
-
-	/* Not specified by any standard per-se, however it breaks too
-	 * many applications when removed.  It is unfortunate since
-	 * allowing applications to make a non-local bind solves
-	 * several problems with systems using dynamic addressing.
-	 * (ie. your servers still start up even if your ISDN link
-	 *  is temporarily down)
-	 */
-	err = -EADDRNOTAVAIL;
-	if (!net->ipv4.sysctl_ip_nonlocal_bind &&
-	    !(inet->freebind || inet->transparent) &&
-	    addr->sin_addr.s_addr != htonl(INADDR_ANY) &&
-	    chk_addr_ret != RTN_LOCAL &&
-	    chk_addr_ret != RTN_MULTICAST &&
-	    chk_addr_ret != RTN_BROADCAST)
+	chk_addr_ret = inet_allow_bind(sk, addr->sin_addr.s_addr);
+	if (chk_addr_ret < 0) {
+		err = chk_addr_ret;
 		goto out;
+	}
 
 	snum = ntohs(addr->sin_port);
 	err = -EACCES;
-- 
2.9.3
