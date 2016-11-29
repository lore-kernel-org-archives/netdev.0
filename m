From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH v2 net 3/5] l2tp: fix racy socket lookup in l2tp_ip and
 l2tp_ip6 bind()
Date: Tue, 29 Nov 2016 13:09:46 +0100
Message-ID: <61d26b0fb86777c46a29e9fb9d955d80a4de95b8.1480419658.git.g.nault@alphalink.fr>
References: <cover.1480419658.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:42382 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756553AbcK2MKC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 07:10:02 -0500
Content-Disposition: inline
In-Reply-To: <cover.1480419658.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not enough to check for sockets bound to same address at the
beginning of l2tp_ip{,6}_bind(): even if no socket is found at that
time, a socket with the same address could be bound before we take
the l2tp lock again.

This patch moves the lookup right before inserting the new socket, so
that no change can ever happen to the list between address lookup and
socket insertion.

Care is taken to avoid side effects on the socket in case of failure.
That is, modifications of the socket are done after the lookup, when
binding is guaranteed to succeed, and before releasing the l2tp lock,
so that concurrent lookups will always see fully initialised sockets.

For l2tp_ip, 'ret' is set to -EINVAL before checking the SOCK_ZAPPED
bit. Error code was mistakenly set to -EADDRINUSE on error by commit
32c231164b76 ("l2tp: fix racy SOCK_ZAPPED flag check in l2tp_ip{,6}_bind()").
Using -EINVAL restores original behaviour.

For l2tp_ip6, the lookup is now always done with the correct bound
device. Before this patch, when binding to a link-local address, the
lookup was done with the original sk->sk_bound_dev_if, which was later
overwritten with addr->l2tp_scope_id. Lookup is now performed with the
final sk->sk_bound_dev_if value.

Finally, the (addr_len >= sizeof(struct sockaddr_in6)) check has been
dropped: addr is a sockaddr_l2tpip6 not sockaddr_in6 and addr_len has
already been checked at this point (this part of the code seems to have
been copy-pasted from net/ipv6/raw.c).

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ip.c  | 27 ++++++++++++---------------
 net/l2tp/l2tp_ip6.c | 43 ++++++++++++++++++++-----------------------
 2 files changed, 32 insertions(+), 38 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 4d1c942..b517c33 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -257,15 +257,9 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (addr->l2tp_family != AF_INET)
 		return -EINVAL;
 
-	ret = -EADDRINUSE;
-	read_lock_bh(&l2tp_ip_lock);
-	if (__l2tp_ip_bind_lookup(net, addr->l2tp_addr.s_addr,
-				  sk->sk_bound_dev_if, addr->l2tp_conn_id))
-		goto out_in_use;
-
-	read_unlock_bh(&l2tp_ip_lock);
-
 	lock_sock(sk);
+
+	ret = -EINVAL;
 	if (!sock_flag(sk, SOCK_ZAPPED))
 		goto out;
 
@@ -282,14 +276,22 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		inet->inet_rcv_saddr = inet->inet_saddr = addr->l2tp_addr.s_addr;
 	if (chk_addr_ret == RTN_MULTICAST || chk_addr_ret == RTN_BROADCAST)
 		inet->inet_saddr = 0;  /* Use device */
-	sk_dst_reset(sk);
 
+	write_lock_bh(&l2tp_ip_lock);
+	if (__l2tp_ip_bind_lookup(net, addr->l2tp_addr.s_addr,
+				  sk->sk_bound_dev_if, addr->l2tp_conn_id)) {
+		write_unlock_bh(&l2tp_ip_lock);
+		ret = -EADDRINUSE;
+		goto out;
+	}
+
+	sk_dst_reset(sk);
 	l2tp_ip_sk(sk)->conn_id = addr->l2tp_conn_id;
 
-	write_lock_bh(&l2tp_ip_lock);
 	sk_add_bind_node(sk, &l2tp_ip_bind_table);
 	sk_del_node_init(sk);
 	write_unlock_bh(&l2tp_ip_lock);
+
 	ret = 0;
 	sock_reset_flag(sk, SOCK_ZAPPED);
 
@@ -297,11 +299,6 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	release_sock(sk);
 
 	return ret;
-
-out_in_use:
-	read_unlock_bh(&l2tp_ip_lock);
-
-	return ret;
 }
 
 static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index e3fc778..5f2ae61 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -267,6 +267,7 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	struct sockaddr_l2tpip6 *addr = (struct sockaddr_l2tpip6 *) uaddr;
 	struct net *net = sock_net(sk);
 	__be32 v4addr = 0;
+	int bound_dev_if;
 	int addr_type;
 	int err;
 
@@ -285,13 +286,6 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (addr_type & IPV6_ADDR_MULTICAST)
 		return -EADDRNOTAVAIL;
 
-	err = -EADDRINUSE;
-	read_lock_bh(&l2tp_ip6_lock);
-	if (__l2tp_ip6_bind_lookup(net, &addr->l2tp_addr,
-				   sk->sk_bound_dev_if, addr->l2tp_conn_id))
-		goto out_in_use;
-	read_unlock_bh(&l2tp_ip6_lock);
-
 	lock_sock(sk);
 
 	err = -EINVAL;
@@ -301,28 +295,25 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (sk->sk_state != TCP_CLOSE)
 		goto out_unlock;
 
+	bound_dev_if = sk->sk_bound_dev_if;
+
 	/* Check if the address belongs to the host. */
 	rcu_read_lock();
 	if (addr_type != IPV6_ADDR_ANY) {
 		struct net_device *dev = NULL;
 
 		if (addr_type & IPV6_ADDR_LINKLOCAL) {
-			if (addr_len >= sizeof(struct sockaddr_in6) &&
-			    addr->l2tp_scope_id) {
-				/* Override any existing binding, if another
-				 * one is supplied by user.
-				 */
-				sk->sk_bound_dev_if = addr->l2tp_scope_id;
-			}
+			if (addr->l2tp_scope_id)
+				bound_dev_if = addr->l2tp_scope_id;
 
 			/* Binding to link-local address requires an
-			   interface */
-			if (!sk->sk_bound_dev_if)
+			 * interface.
+			 */
+			if (!bound_dev_if)
 				goto out_unlock_rcu;
 
 			err = -ENODEV;
-			dev = dev_get_by_index_rcu(sock_net(sk),
-						   sk->sk_bound_dev_if);
+			dev = dev_get_by_index_rcu(sock_net(sk), bound_dev_if);
 			if (!dev)
 				goto out_unlock_rcu;
 		}
@@ -337,13 +328,22 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 	rcu_read_unlock();
 
-	inet->inet_rcv_saddr = inet->inet_saddr = v4addr;
+	write_lock_bh(&l2tp_ip6_lock);
+	if (__l2tp_ip6_bind_lookup(net, &addr->l2tp_addr, bound_dev_if,
+				   addr->l2tp_conn_id)) {
+		write_unlock_bh(&l2tp_ip6_lock);
+		err = -EADDRINUSE;
+		goto out_unlock;
+	}
+
+	inet->inet_saddr = v4addr;
+	inet->inet_rcv_saddr = v4addr;
+	sk->sk_bound_dev_if = bound_dev_if;
 	sk->sk_v6_rcv_saddr = addr->l2tp_addr;
 	np->saddr = addr->l2tp_addr;
 
 	l2tp_ip6_sk(sk)->conn_id = addr->l2tp_conn_id;
 
-	write_lock_bh(&l2tp_ip6_lock);
 	sk_add_bind_node(sk, &l2tp_ip6_bind_table);
 	sk_del_node_init(sk);
 	write_unlock_bh(&l2tp_ip6_lock);
@@ -356,10 +356,7 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	rcu_read_unlock();
 out_unlock:
 	release_sock(sk);
-	return err;
 
-out_in_use:
-	read_unlock_bh(&l2tp_ip6_lock);
 	return err;
 }
 
-- 
2.10.2
