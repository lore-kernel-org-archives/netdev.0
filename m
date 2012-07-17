From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/5] ipv6: Add helper inet6_csk_update_pmtu().
Date: Tue, 17 Jul 2012 06:14:24 -0700 (PDT)
Message-ID: <20120717.061424.234357317313461113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811Ab2GQNOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 09:14:24 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 984715837B5
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 06:14:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the ipv6 version of inet_csk_update_pmtu().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet6_connection_sock.h |    2 ++
 net/dccp/ipv6.c                     |   35 +++----------------------
 net/ipv6/inet6_connection_sock.c    |   49 +++++++++++++++++++++++++----------
 net/ipv6/tcp_ipv6.c                 |   37 +++-----------------------
 4 files changed, 45 insertions(+), 78 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index df2a857..04642c9 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -43,4 +43,6 @@ extern void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
 extern void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
 
 extern int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl);
+
+extern struct dst_entry *inet6_csk_update_pmtu(struct sock *sk, u32 mtu);
 #endif /* _INET6_CONNECTION_SOCK_H */
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 090c080..3ee0342 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -145,39 +145,12 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		if ((1 << sk->sk_state) & (DCCPF_LISTEN | DCCPF_CLOSED))
 			goto out;
 
-		/* icmp should have updated the destination cache entry */
-		dst = __sk_dst_check(sk, np->dst_cookie);
-		if (dst == NULL) {
-			struct inet_sock *inet = inet_sk(sk);
-			struct flowi6 fl6;
-
-			/* BUGGG_FUTURE: Again, it is not clear how
-			   to handle rthdr case. Ignore this complexity
-			   for now.
-			 */
-			memset(&fl6, 0, sizeof(fl6));
-			fl6.flowi6_proto = IPPROTO_DCCP;
-			fl6.daddr = np->daddr;
-			fl6.saddr = np->saddr;
-			fl6.flowi6_oif = sk->sk_bound_dev_if;
-			fl6.fl6_dport = inet->inet_dport;
-			fl6.fl6_sport = inet->inet_sport;
-			security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
-
-			dst = ip6_dst_lookup_flow(sk, &fl6, NULL, false);
-			if (IS_ERR(dst)) {
-				sk->sk_err_soft = -PTR_ERR(dst);
-				goto out;
-			}
-		} else
-			dst_hold(dst);
-
-		dst->ops->update_pmtu(dst, ntohl(info));
+		dst = inet6_csk_update_pmtu(sk, ntohl(info));
+		if (!dst)
+			goto out;
 
-		if (inet_csk(sk)->icsk_pmtu_cookie > dst_mtu(dst)) {
+		if (inet_csk(sk)->icsk_pmtu_cookie > dst_mtu(dst))
 			dccp_sync_mss(sk, dst_mtu(dst));
-		} /* else let the usual retransmit timer handle it */
-		dst_release(dst);
 		goto out;
 	}
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index bceb144..62539a4 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -203,15 +203,13 @@ struct dst_entry *__inet6_csk_dst_check(struct sock *sk, u32 cookie)
 	return dst;
 }
 
-int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
+static struct dst_entry *inet6_csk_route_socket(struct sock *sk)
 {
-	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct flowi6 fl6;
-	struct dst_entry *dst;
 	struct in6_addr *final_p, final;
-	int res;
+	struct dst_entry *dst;
+	struct flowi6 fl6;
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_proto = sk->sk_protocol;
@@ -228,18 +226,29 @@ int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
 	final_p = fl6_update_dst(&fl6, np->opt, &final);
 
 	dst = __inet6_csk_dst_check(sk, np->dst_cookie);
-
-	if (dst == NULL) {
+	if (!dst) {
 		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
 
-		if (IS_ERR(dst)) {
-			sk->sk_err_soft = -PTR_ERR(dst);
-			sk->sk_route_caps = 0;
-			kfree_skb(skb);
-			return PTR_ERR(dst);
-		}
+		if (!IS_ERR(dst))
+			__inet6_csk_dst_store(sk, dst, NULL, NULL);
+	}
+	return dst;
+}
 
-		__inet6_csk_dst_store(sk, dst, NULL, NULL);
+int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
+{
+	struct sock *sk = skb->sk;
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct flowi6 fl6;
+	struct dst_entry *dst;
+	int res;
+
+	dst = inet6_csk_route_socket(sk);
+	if (IS_ERR(dst)) {
+		sk->sk_err_soft = -PTR_ERR(dst);
+		sk->sk_route_caps = 0;
+		kfree_skb(skb);
+		return PTR_ERR(dst);
 	}
 
 	rcu_read_lock();
@@ -253,3 +262,15 @@ int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
 	return res;
 }
 EXPORT_SYMBOL_GPL(inet6_csk_xmit);
+
+struct dst_entry *inet6_csk_update_pmtu(struct sock *sk, u32 mtu)
+{
+	struct dst_entry *dst = inet6_csk_route_socket(sk);
+
+	if (IS_ERR(dst))
+		return NULL;
+	dst->ops->update_pmtu(dst, mtu);
+
+	return inet6_csk_route_socket(sk);
+}
+EXPORT_SYMBOL_GPL(inet6_csk_update_pmtu);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3071f37..ecdf241 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -378,43 +378,14 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		if ((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE))
 			goto out;
 
-		/* icmp should have updated the destination cache entry */
-		dst = __sk_dst_check(sk, np->dst_cookie);
-
-		if (dst == NULL) {
-			struct inet_sock *inet = inet_sk(sk);
-			struct flowi6 fl6;
-
-			/* BUGGG_FUTURE: Again, it is not clear how
-			   to handle rthdr case. Ignore this complexity
-			   for now.
-			 */
-			memset(&fl6, 0, sizeof(fl6));
-			fl6.flowi6_proto = IPPROTO_TCP;
-			fl6.daddr = np->daddr;
-			fl6.saddr = np->saddr;
-			fl6.flowi6_oif = sk->sk_bound_dev_if;
-			fl6.flowi6_mark = sk->sk_mark;
-			fl6.fl6_dport = inet->inet_dport;
-			fl6.fl6_sport = inet->inet_sport;
-			security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
-
-			dst = ip6_dst_lookup_flow(sk, &fl6, NULL, false);
-			if (IS_ERR(dst)) {
-				sk->sk_err_soft = -PTR_ERR(dst);
-				goto out;
-			}
-
-		} else
-			dst_hold(dst);
-
-		dst->ops->update_pmtu(dst, ntohl(info));
+		dst = inet6_csk_update_pmtu(sk, ntohl(info));
+		if (!dst)
+			goto out;
 
 		if (inet_csk(sk)->icsk_pmtu_cookie > dst_mtu(dst)) {
 			tcp_sync_mss(sk, dst_mtu(dst));
 			tcp_simple_retransmit(sk);
-		} /* else let the usual retransmit timer handle it */
-		dst_release(dst);
+		}
 		goto out;
 	}
 
-- 
1.7.10.4
