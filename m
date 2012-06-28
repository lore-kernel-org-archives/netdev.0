From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 2/4] tcp: pass fl6 to inet6_csk_route_req()
Date: Thu, 28 Jun 2012 15:34:19 -0700
Message-ID: <1340922861-11684-2-git-send-email-ncardwell@google.com>
References: <1340922861-11684-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:53884 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab2F1Xpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 19:45:35 -0400
Received: by vbnl22 with SMTP id l22so268730vbn.1
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 16:45:34 -0700 (PDT)
In-Reply-To: <1340922861-11684-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit changes inet_csk_route_req() so that it uses a pointer to
a struct flowi6, rather than allocating its own on the stack. This
brings its behavior in line with its IPv4 cousin,
inet_csk_route_req(), and allows a follow-on patch to fix a dst leak.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/net/inet6_connection_sock.h |    1 +
 net/ipv6/inet6_connection_sock.c    |   24 ++++++++++++------------
 net/ipv6/tcp_ipv6.c                 |    9 ++++++---
 3 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 1866a67..df2a857 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -26,6 +26,7 @@ extern int inet6_csk_bind_conflict(const struct sock *sk,
 				   const struct inet_bind_bucket *tb, bool relax);
 
 extern struct dst_entry* inet6_csk_route_req(struct sock *sk,
+					     struct flowi6 *fl6,
 					     const struct request_sock *req);
 
 extern struct request_sock *inet6_csk_search_req(const struct sock *sk,
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index e23d354..bceb144 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -55,26 +55,26 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 EXPORT_SYMBOL_GPL(inet6_csk_bind_conflict);
 
 struct dst_entry *inet6_csk_route_req(struct sock *sk,
+				      struct flowi6 *fl6,
 				      const struct request_sock *req)
 {
 	struct inet6_request_sock *treq = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_addr *final_p, final;
 	struct dst_entry *dst;
-	struct flowi6 fl6;
-
-	memset(&fl6, 0, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_TCP;
-	fl6.daddr = treq->rmt_addr;
-	final_p = fl6_update_dst(&fl6, np->opt, &final);
-	fl6.saddr = treq->loc_addr;
-	fl6.flowi6_oif = treq->iif;
-	fl6.flowi6_mark = sk->sk_mark;
-	fl6.fl6_dport = inet_rsk(req)->rmt_port;
-	fl6.fl6_sport = inet_rsk(req)->loc_port;
-	security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
-	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
+	memset(fl6, 0, sizeof(*fl6));
+	fl6->flowi6_proto = IPPROTO_TCP;
+	fl6->daddr = treq->rmt_addr;
+	final_p = fl6_update_dst(fl6, np->opt, &final);
+	fl6->saddr = treq->loc_addr;
+	fl6->flowi6_oif = treq->iif;
+	fl6->flowi6_mark = sk->sk_mark;
+	fl6->fl6_dport = inet_rsk(req)->rmt_port;
+	fl6->fl6_sport = inet_rsk(req)->loc_port;
+	security_req_classify_flow(req, flowi6_to_flowi(fl6));
+
+	dst = ip6_dst_lookup_flow(sk, fl6, final_p, false);
 	if (IS_ERR(dst))
 		return NULL;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 26a8862..3b79e94 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -477,7 +477,8 @@ out:
 }
 
 
-static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
+static int tcp_v6_send_synack(struct sock *sk,
+			      struct request_sock *req,
 			      struct request_values *rvp,
 			      u16 queue_mapping)
 {
@@ -1058,6 +1059,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 isn = TCP_SKB_CB(skb)->when;
 	struct dst_entry *dst = NULL;
+	struct flowi6 fl6;
 	bool want_cookie = false;
 
 	if (skb->protocol == htons(ETH_P_IP))
@@ -1177,7 +1179,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (tmp_opt.saw_tstamp &&
 		    tcp_death_row.sysctl_tw_recycle &&
-		    (dst = inet6_csk_route_req(sk, req)) != NULL &&
+		    (dst = inet6_csk_route_req(sk, &fl6, req)) != NULL &&
 		    (peer = rt6_get_peer((struct rt6_info *)dst)) != NULL &&
 		    ipv6_addr_equal((struct in6_addr *)peer->daddr.addr.a6,
 				    &treq->rmt_addr)) {
@@ -1246,6 +1248,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
 #endif
+	struct flowi6 fl6;
 
 	if (skb->protocol == htons(ETH_P_IP)) {
 		/*
@@ -1308,7 +1311,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		goto out_overflow;
 
 	if (!dst) {
-		dst = inet6_csk_route_req(sk, req);
+		dst = inet6_csk_route_req(sk, &fl6, req);
 		if (!dst)
 			goto out;
 	}
-- 
1.7.4.1
