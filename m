From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 1/5] l2tp: lock socket before checking flags in connect()
Date: Mon, 28 Nov 2016 20:39:56 +0100
Message-ID: <a7cc82ffabf9b5930c68f7a902fe907d906b68b6.1480360512.git.g.nault@alphalink.fr>
References: <cover.1480360512.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:48835 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754043AbcK1TkB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 14:40:01 -0500
Content-Disposition: inline
In-Reply-To: <cover.1480360512.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Socket flags aren't updated atomically, so the socket must be locked
while reading the SOCK_ZAPPED flag.

This issue exists for both l2tp_ip and l2tp_ip6. For IPv6, this patch
also brings error handling for __ip6_datagram_connect() failures.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 include/net/ipv6.h  |  2 ++
 net/ipv6/datagram.c |  4 +++-
 net/l2tp/l2tp_ip.c  | 19 ++++++++++++-------
 net/l2tp/l2tp_ip6.c | 16 +++++++++++-----
 4 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8fed1cd..f11ca83 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -970,6 +970,8 @@ int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,
 int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			   char __user *optval, int __user *optlen);
 
+int __ip6_datagram_connect(struct sock *sk, struct sockaddr *addr,
+			   int addr_len);
 int ip6_datagram_connect(struct sock *sk, struct sockaddr *addr, int addr_len);
 int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *addr,
 				 int addr_len);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 37874e2..ccf4055 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -139,7 +139,8 @@ void ip6_datagram_release_cb(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(ip6_datagram_release_cb);
 
-static int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr,
+			   int addr_len)
 {
 	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
 	struct inet_sock	*inet = inet_sk(sk);
@@ -252,6 +253,7 @@ static int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int a
 out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(__ip6_datagram_connect);
 
 int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 982f6c4..1f57094 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -308,21 +308,24 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	struct sockaddr_l2tpip *lsa = (struct sockaddr_l2tpip *) uaddr;
 	int rc;
 
-	if (sock_flag(sk, SOCK_ZAPPED)) /* Must bind first - autobinding does not work */
-		return -EINVAL;
-
 	if (addr_len < sizeof(*lsa))
 		return -EINVAL;
 
 	if (ipv4_is_multicast(lsa->l2tp_addr.s_addr))
 		return -EINVAL;
 
-	rc = ip4_datagram_connect(sk, uaddr, addr_len);
-	if (rc < 0)
-		return rc;
-
 	lock_sock(sk);
 
+	/* Must bind first - autobinding does not work */
+	if (sock_flag(sk, SOCK_ZAPPED)) {
+		rc = -EINVAL;
+		goto out_sk;
+	}
+
+	rc = __ip4_datagram_connect(sk, uaddr, addr_len);
+	if (rc < 0)
+		goto out_sk;
+
 	l2tp_ip_sk(sk)->peer_conn_id = lsa->l2tp_conn_id;
 
 	write_lock_bh(&l2tp_ip_lock);
@@ -330,7 +333,9 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	sk_add_bind_node(sk, &l2tp_ip_bind_table);
 	write_unlock_bh(&l2tp_ip_lock);
 
+out_sk:
 	release_sock(sk);
+
 	return rc;
 }
 
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 9978d01..af9abff 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -371,9 +371,6 @@ static int l2tp_ip6_connect(struct sock *sk, struct sockaddr *uaddr,
 	int	addr_type;
 	int rc;
 
-	if (sock_flag(sk, SOCK_ZAPPED)) /* Must bind first - autobinding does not work */
-		return -EINVAL;
-
 	if (addr_len < sizeof(*lsa))
 		return -EINVAL;
 
@@ -390,10 +387,18 @@ static int l2tp_ip6_connect(struct sock *sk, struct sockaddr *uaddr,
 			return -EINVAL;
 	}
 
-	rc = ip6_datagram_connect(sk, uaddr, addr_len);
-
 	lock_sock(sk);
 
+	 /* Must bind first - autobinding does not work */
+	if (sock_flag(sk, SOCK_ZAPPED)) {
+		rc = -EINVAL;
+		goto out_sk;
+	}
+
+	rc = __ip6_datagram_connect(sk, uaddr, addr_len);
+	if (rc < 0)
+		goto out_sk;
+
 	l2tp_ip6_sk(sk)->peer_conn_id = lsa->l2tp_conn_id;
 
 	write_lock_bh(&l2tp_ip6_lock);
@@ -401,6 +406,7 @@ static int l2tp_ip6_connect(struct sock *sk, struct sockaddr *uaddr,
 	sk_add_bind_node(sk, &l2tp_ip6_bind_table);
 	write_unlock_bh(&l2tp_ip6_lock);
 
+out_sk:
 	release_sock(sk);
 
 	return rc;
-- 
2.10.2
