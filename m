From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 3/3] inet_diag: factorize code in new inet_diag_msg_common_fill() helper
Date: Fri, 13 Mar 2015 15:51:12 -0700
Message-ID: <1426287072-22175-4-git-send-email-edumazet@google.com>
References: <1426287072-22175-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:33890 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbbCMWvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 18:51:39 -0400
Received: by pdev10 with SMTP id v10so7736308pde.1
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 15:51:39 -0700 (PDT)
In-Reply-To: <1426287072-22175-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the three type of sockets share a common base, we can factorize
code in inet_diag_msg_common_fill().

inet_diag_entry no longer requires saddr_storage & daddr_storage
and the extra copies.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c | 148 ++++++++++++++++-----------------------------------
 1 file changed, 47 insertions(+), 101 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index d827fe2e3ce0..ac7b5c909fe7 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -44,10 +44,6 @@ struct inet_diag_entry {
 	u16 dport;
 	u16 family;
 	u16 userlocks;
-#if IS_ENABLED(CONFIG_IPV6)
-	struct in6_addr saddr_storage;	/* for IPv4-mapped-IPv6 addresses */
-	struct in6_addr daddr_storage;	/* for IPv4-mapped-IPv6 addresses */
-#endif
 };
 
 static DEFINE_MUTEX(inet_diag_table_mutex);
@@ -70,6 +66,30 @@ static void inet_diag_unlock_handler(const struct inet_diag_handler *handler)
 	mutex_unlock(&inet_diag_table_mutex);
 }
 
+static void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
+{
+	r->idiag_family = sk->sk_family;
+
+	r->id.idiag_sport = htons(sk->sk_num);
+	r->id.idiag_dport = sk->sk_dport;
+	r->id.idiag_if = sk->sk_bound_dev_if;
+	sock_diag_save_cookie(sk, r->id.idiag_cookie);
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family == AF_INET6) {
+		*(struct in6_addr *)r->id.idiag_src = sk->sk_v6_rcv_saddr;
+		*(struct in6_addr *)r->id.idiag_dst = sk->sk_v6_daddr;
+	} else
+#endif
+	{
+	memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
+	memset(&r->id.idiag_dst, 0, sizeof(r->id.idiag_dst));
+
+	r->id.idiag_src[0] = sk->sk_rcv_saddr;
+	r->id.idiag_dst[0] = sk->sk_daddr;
+	}
+}
+
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		      struct sk_buff *skb, const struct inet_diag_req_v2 *req,
 		      struct user_namespace *user_ns,
@@ -95,22 +115,11 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	r = nlmsg_data(nlh);
 	BUG_ON((1 << sk->sk_state) & (TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV));
 
-	r->idiag_family = sk->sk_family;
+	inet_diag_msg_common_fill(r, sk);
 	r->idiag_state = sk->sk_state;
 	r->idiag_timer = 0;
 	r->idiag_retrans = 0;
 
-	r->id.idiag_if = sk->sk_bound_dev_if;
-	sock_diag_save_cookie(sk, r->id.idiag_cookie);
-
-	r->id.idiag_sport = inet->inet_sport;
-	r->id.idiag_dport = inet->inet_dport;
-
-	memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
-	memset(&r->id.idiag_dst, 0, sizeof(r->id.idiag_dst));
-
-	r->id.idiag_src[0] = inet->inet_rcv_saddr;
-	r->id.idiag_dst[0] = inet->inet_daddr;
 
 	if (nla_put_u8(skb, INET_DIAG_SHUTDOWN, sk->sk_shutdown))
 		goto errout;
@@ -124,9 +133,6 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 
 #if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
-		*(struct in6_addr *)r->id.idiag_src = sk->sk_v6_rcv_saddr;
-		*(struct in6_addr *)r->id.idiag_dst = sk->sk_v6_daddr;
-
 		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
 			if (nla_put_u8(skb, INET_DIAG_TCLASS,
 				       inet6_sk(sk)->tclass) < 0)
@@ -244,21 +250,9 @@ static int inet_twsk_diag_fill(struct sock *sk,
 	if (tmo < 0)
 		tmo = 0;
 
-	r->idiag_family	      = tw->tw_family;
+	inet_diag_msg_common_fill(r, sk);
 	r->idiag_retrans      = 0;
 
-	r->id.idiag_if	      = tw->tw_bound_dev_if;
-	sock_diag_save_cookie(sk, r->id.idiag_cookie);
-
-	r->id.idiag_sport     = tw->tw_sport;
-	r->id.idiag_dport     = tw->tw_dport;
-
-	memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
-	memset(&r->id.idiag_dst, 0, sizeof(r->id.idiag_dst));
-
-	r->id.idiag_src[0]    = tw->tw_rcv_saddr;
-	r->id.idiag_dst[0]    = tw->tw_daddr;
-
 	r->idiag_state	      = tw->tw_substate;
 	r->idiag_timer	      = 3;
 	r->idiag_expires      = jiffies_to_msecs(tmo);
@@ -266,12 +260,6 @@ static int inet_twsk_diag_fill(struct sock *sk,
 	r->idiag_wqueue	      = 0;
 	r->idiag_uid	      = 0;
 	r->idiag_inode	      = 0;
-#if IS_ENABLED(CONFIG_IPV6)
-	if (tw->tw_family == AF_INET6) {
-		*(struct in6_addr *)r->id.idiag_src = tw->tw_v6_rcv_saddr;
-		*(struct in6_addr *)r->id.idiag_dst = tw->tw_v6_daddr;
-	}
-#endif
 
 	nlmsg_end(skb, nlh);
 	return 0;
@@ -485,6 +473,23 @@ static int inet_diag_bc_run(const struct nlattr *_bc,
 	return len == 0;
 }
 
+/* This helper is available for all sockets (ESTABLISH, TIMEWAIT, SYN_RECV)
+ */
+static void entry_fill_addrs(struct inet_diag_entry *entry,
+			     const struct sock *sk)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family == AF_INET6) {
+		entry->saddr = sk->sk_v6_rcv_saddr.s6_addr32;
+		entry->daddr = sk->sk_v6_daddr.s6_addr32;
+	} else
+#endif
+	{
+		entry->saddr = &sk->sk_rcv_saddr;
+		entry->daddr = &sk->sk_daddr;
+	}
+}
+
 int inet_diag_bc_sk(const struct nlattr *bc, struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -494,16 +499,7 @@ int inet_diag_bc_sk(const struct nlattr *bc, struct sock *sk)
 		return 1;
 
 	entry.family = sk->sk_family;
-#if IS_ENABLED(CONFIG_IPV6)
-	if (entry.family == AF_INET6) {
-		entry.saddr = sk->sk_v6_rcv_saddr.s6_addr32;
-		entry.daddr = sk->sk_v6_daddr.s6_addr32;
-	} else
-#endif
-	{
-		entry.saddr = &inet->inet_rcv_saddr;
-		entry.daddr = &inet->inet_daddr;
-	}
+	entry_fill_addrs(&entry, sk);
 	entry.sport = inet->inet_num;
 	entry.dport = ntohs(inet->inet_dport);
 	entry.userlocks = (sk->sk_state != TCP_TIME_WAIT) ? sk->sk_userlocks : 0;
@@ -681,36 +677,6 @@ static int inet_twsk_diag_dump(struct sock *sk,
 				   cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
 
-/* Get the IPv4, IPv6, or IPv4-mapped-IPv6 local and remote addresses
- * from a request_sock. For IPv4-mapped-IPv6 we must map IPv4 to IPv6.
- */
-static void inet_diag_req_addrs(const struct sock *sk,
-				const struct request_sock *req,
-				struct inet_diag_entry *entry)
-{
-	const struct inet_request_sock *ireq = inet_rsk(req);
-
-#if IS_ENABLED(CONFIG_IPV6)
-	if (sk->sk_family == AF_INET6) {
-		if (req->rsk_ops->family == AF_INET6) {
-			entry->saddr = ireq->ir_v6_loc_addr.s6_addr32;
-			entry->daddr = ireq->ir_v6_rmt_addr.s6_addr32;
-		} else if (req->rsk_ops->family == AF_INET) {
-			ipv6_addr_set_v4mapped(ireq->ir_loc_addr,
-					       &entry->saddr_storage);
-			ipv6_addr_set_v4mapped(ireq->ir_rmt_addr,
-					       &entry->daddr_storage);
-			entry->saddr = entry->saddr_storage.s6_addr32;
-			entry->daddr = entry->daddr_storage.s6_addr32;
-		}
-	} else
-#endif
-	{
-		entry->saddr = &ireq->ir_loc_addr;
-		entry->daddr = &ireq->ir_rmt_addr;
-	}
-}
-
 static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 			      struct request_sock *req,
 			      struct user_namespace *user_ns,
@@ -728,44 +694,23 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 		return -EMSGSIZE;
 
 	r = nlmsg_data(nlh);
-	r->idiag_family = ireq->ireq_family;
+	inet_diag_msg_common_fill(r, (struct sock *)ireq);
 	r->idiag_state = TCP_SYN_RECV;
 	r->idiag_timer = 1;
 	r->idiag_retrans = req->num_retrans;
 
-	r->id.idiag_if = ireq->ir_iif;
-
 	BUILD_BUG_ON(offsetof(struct inet_request_sock, ir_cookie) !=
 		     offsetof(struct sock, sk_cookie));
-	sock_diag_save_cookie((struct sock *)ireq, r->id.idiag_cookie);
 
 	tmo = req->expires - jiffies;
 	if (tmo < 0)
 		tmo = 0;
 
-	r->id.idiag_sport = htons(ireq->ir_num);
-	r->id.idiag_dport = ireq->ir_rmt_port;
-
-	memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
-	memset(&r->id.idiag_dst, 0, sizeof(r->id.idiag_dst));
-
-	r->id.idiag_src[0] = ireq->ir_loc_addr;
-	r->id.idiag_dst[0] = ireq->ir_rmt_addr;
-
 	r->idiag_expires = jiffies_to_msecs(tmo);
 	r->idiag_rqueue = 0;
 	r->idiag_wqueue = 0;
 	r->idiag_uid = from_kuid_munged(user_ns, sock_i_uid(sk));
 	r->idiag_inode = 0;
-#if IS_ENABLED(CONFIG_IPV6)
-	if (r->idiag_family == AF_INET6) {
-		struct inet_diag_entry entry;
-
-		inet_diag_req_addrs(sk, req, &entry);
-		memcpy(r->id.idiag_src, entry.saddr, sizeof(struct in6_addr));
-		memcpy(r->id.idiag_dst, entry.daddr, sizeof(struct in6_addr));
-	}
-#endif
 
 	nlmsg_end(skb, nlh);
 	return 0;
@@ -816,7 +761,8 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 				continue;
 
 			if (bc) {
-				inet_diag_req_addrs(sk, req, &entry);
+				/* Note: entry.sport and entry.userlocks are already set */
+				entry_fill_addrs(&entry, (struct sock *)req);
 				entry.dport = ntohs(ireq->ir_rmt_port);
 
 				if (!inet_diag_bc_run(bc, &entry))
-- 
2.2.0.rc0.207.ga3a616c
