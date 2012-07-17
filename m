From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/5] ipv4: Add helper inet_csk_update_pmtu().
Date: Tue, 17 Jul 2012 06:14:21 -0700 (PDT)
Message-ID: <20120717.061421.1350317664358200700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811Ab2GQNOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 09:14:21 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C2A925837B5
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 06:14:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This abstracts away the call to dst_ops->update_pmtu() so that we can
transparently handle the fact that, in the future, the dst itself can
be invalidated by the PMTU update (when we have non-host routes cached
in sockets).

So we try to rebuild the socket cached route after the method
invocation if necessary.

This isn't used by SCTP because it needs to cache dsts per-transport,
and thus will need it's own local version of this helper.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet_connection_sock.h |    2 ++
 net/dccp/ipv4.c                    |   11 ++-------
 net/ipv4/inet_connection_sock.c    |   46 ++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c                |   11 ++-------
 4 files changed, 52 insertions(+), 18 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 291e7ce..2cf44b4 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -337,4 +337,6 @@ extern int inet_csk_compat_getsockopt(struct sock *sk, int level, int optname,
 				      char __user *optval, int __user *optlen);
 extern int inet_csk_compat_setsockopt(struct sock *sk, int level, int optname,
 				      char __user *optval, unsigned int optlen);
+
+extern struct dst_entry *inet_csk_update_pmtu(struct sock *sk, u32 mtu);
 #endif /* _INET_CONNECTION_SOCK_H */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 129ed8f..683902f 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -161,17 +161,10 @@ static inline void dccp_do_pmtu_discovery(struct sock *sk,
 	if (sk->sk_state == DCCP_LISTEN)
 		return;
 
-	/* We don't check in the destentry if pmtu discovery is forbidden
-	 * on this route. We just assume that no packet_to_big packets
-	 * are send back when pmtu discovery is not active.
-	 * There is a small race when the user changes this flag in the
-	 * route, but I think that's acceptable.
-	 */
-	if ((dst = __sk_dst_check(sk, 0)) == NULL)
+	dst = inet_csk_update_pmtu(sk, mtu);
+	if (!dst)
 		return;
 
-	dst->ops->update_pmtu(dst, mtu);
-
 	/* Something is about to be wrong... Remember soft error
 	 * for the case, if this connection will not able to recover.
 	 */
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 76825be..200d218 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -803,3 +803,49 @@ int inet_csk_compat_setsockopt(struct sock *sk, int level, int optname,
 }
 EXPORT_SYMBOL_GPL(inet_csk_compat_setsockopt);
 #endif
+
+static struct dst_entry *inet_csk_rebuild_route(struct sock *sk, struct flowi *fl)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct ip_options_rcu *inet_opt;
+	__be32 daddr = inet->inet_daddr;
+	struct flowi4 *fl4;
+	struct rtable *rt;
+
+	rcu_read_lock();
+	inet_opt = rcu_dereference(inet->inet_opt);
+	if (inet_opt && inet_opt->opt.srr)
+		daddr = inet_opt->opt.faddr;
+	fl4 = &fl->u.ip4;
+	rt = ip_route_output_ports(sock_net(sk), fl4, sk, daddr,
+				   inet->inet_saddr, inet->inet_dport,
+				   inet->inet_sport, sk->sk_protocol,
+				   RT_CONN_FLAGS(sk), sk->sk_bound_dev_if);
+	if (IS_ERR(rt))
+		rt = NULL;
+	if (rt)
+		sk_setup_caps(sk, &rt->dst);
+	rcu_read_unlock();
+
+	return &rt->dst;
+}
+
+struct dst_entry *inet_csk_update_pmtu(struct sock *sk, u32 mtu)
+{
+	struct dst_entry *dst = __sk_dst_check(sk, 0);
+	struct inet_sock *inet = inet_sk(sk);
+
+	if (!dst) {
+		dst = inet_csk_rebuild_route(sk, &inet->cork.fl);
+		if (!dst)
+			goto out;
+	}
+	dst->ops->update_pmtu(dst, mtu);
+
+	dst = __sk_dst_check(sk, 0);
+	if (!dst)
+		dst = inet_csk_rebuild_route(sk, &inet->cork.fl);
+out:
+	return dst;
+}
+EXPORT_SYMBOL_GPL(inet_csk_update_pmtu);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7a0062c..b8e7e05 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -289,17 +289,10 @@ static void do_pmtu_discovery(struct sock *sk, const struct iphdr *iph, u32 mtu)
 	if (sk->sk_state == TCP_LISTEN)
 		return;
 
-	/* We don't check in the destentry if pmtu discovery is forbidden
-	 * on this route. We just assume that no packet_to_big packets
-	 * are send back when pmtu discovery is not active.
-	 * There is a small race when the user changes this flag in the
-	 * route, but I think that's acceptable.
-	 */
-	if ((dst = __sk_dst_check(sk, 0)) == NULL)
+	dst = inet_csk_update_pmtu(sk, mtu);
+	if (!dst)
 		return;
 
-	dst->ops->update_pmtu(dst, mtu);
-
 	/* Something is about to be wrong... Remember soft error
 	 * for the case, if this connection will not able to recover.
 	 */
-- 
1.7.10.4
