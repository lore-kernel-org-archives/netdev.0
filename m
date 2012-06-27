From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/7] inet_diag: Do not use RTA_PUT() macros
Date: Wed, 27 Jun 2012 11:36:12 +0200
Message-ID: <59e528d77658c9155b93c65be6bdeb22f63a9037.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755941Ab2F0JgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 05:36:23 -0400
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, no need to trim on nlmsg_put() failure, nothing has been added
yet.  We also want to use nlmsg_end(), nlmsg_new() and nlmsg_free().

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/inet_diag.c |  112 +++++++++++++++++++++++--------------------------
 1 files changed, 53 insertions(+), 59 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 27640e7..38064a2 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -46,9 +46,6 @@ struct inet_diag_entry {
 	u16 userlocks;
 };
 
-#define INET_DIAG_PUT(skb, attrtype, attrlen) \
-	RTA_DATA(__RTA_PUT(skb, attrtype, attrlen))
-
 static DEFINE_MUTEX(inet_diag_table_mutex);
 
 static const struct inet_diag_handler *inet_diag_lock_handler(int proto)
@@ -78,28 +75,22 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	const struct inet_sock *inet = inet_sk(sk);
 	struct inet_diag_msg *r;
 	struct nlmsghdr  *nlh;
+	struct nlattr *attr;
 	void *info = NULL;
-	struct inet_diag_meminfo  *minfo = NULL;
-	unsigned char	 *b = skb_tail_pointer(skb);
 	const struct inet_diag_handler *handler;
 	int ext = req->idiag_ext;
 
 	handler = inet_diag_table[req->sdiag_protocol];
 	BUG_ON(handler == NULL);
 
-	nlh = nlmsg_put(skb, pid, seq, unlh->nlmsg_type, sizeof(*r), 0);
-	if (!nlh) {
-		nlmsg_trim(skb, b);
+	nlh = nlmsg_put(skb, pid, seq, unlh->nlmsg_type, sizeof(*r),
+			nlmsg_flags);
+	if (!nlh)
 		return -EMSGSIZE;
-	}
-	nlh->nlmsg_flags = nlmsg_flags;
 
 	r = nlmsg_data(nlh);
 	BUG_ON(sk->sk_state == TCP_TIME_WAIT);
 
-	if (ext & (1 << (INET_DIAG_MEMINFO - 1)))
-		minfo = INET_DIAG_PUT(skb, INET_DIAG_MEMINFO, sizeof(*minfo));
-
 	r->idiag_family = sk->sk_family;
 	r->idiag_state = sk->sk_state;
 	r->idiag_timer = 0;
@@ -117,7 +108,8 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	 * hence this needs to be included regardless of socket family.
 	 */
 	if (ext & (1 << (INET_DIAG_TOS - 1)))
-		RTA_PUT_U8(skb, INET_DIAG_TOS, inet->tos);
+		if (nla_put_u8(skb, INET_DIAG_TOS, inet->tos) < 0)
+			goto errout;
 
 #if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
@@ -125,24 +117,31 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 
 		*(struct in6_addr *)r->id.idiag_src = np->rcv_saddr;
 		*(struct in6_addr *)r->id.idiag_dst = np->daddr;
+
 		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
-			RTA_PUT_U8(skb, INET_DIAG_TCLASS, np->tclass);
+			if (nla_put_u8(skb, INET_DIAG_TCLASS, np->tclass) < 0)
+				goto errout;
 	}
 #endif
 
 	r->idiag_uid = sock_i_uid(sk);
 	r->idiag_inode = sock_i_ino(sk);
 
-	if (minfo) {
-		minfo->idiag_rmem = sk_rmem_alloc_get(sk);
-		minfo->idiag_wmem = sk->sk_wmem_queued;
-		minfo->idiag_fmem = sk->sk_forward_alloc;
-		minfo->idiag_tmem = sk_wmem_alloc_get(sk);
+	if (ext & (1 << (INET_DIAG_MEMINFO - 1))) {
+		struct inet_diag_meminfo minfo = {
+			.idiag_rmem = sk_rmem_alloc_get(sk),
+			.idiag_wmem = sk->sk_wmem_queued,
+			.idiag_fmem = sk->sk_forward_alloc,
+			.idiag_tmem = sk_wmem_alloc_get(sk),
+		};
+
+		if (nla_put(skb, INET_DIAG_MEMINFO, sizeof(minfo), &minfo) < 0)
+			goto errout;
 	}
 
 	if (ext & (1 << (INET_DIAG_SKMEMINFO - 1)))
 		if (sock_diag_put_meminfo(sk, skb, INET_DIAG_SKMEMINFO))
-			goto rtattr_failure;
+			goto errout;
 
 	if (icsk == NULL) {
 		handler->idiag_get_info(sk, r, NULL);
@@ -169,16 +168,20 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	}
 #undef EXPIRES_IN_MS
 
-	if (ext & (1 << (INET_DIAG_INFO - 1)))
-		info = INET_DIAG_PUT(skb, INET_DIAG_INFO, sizeof(struct tcp_info));
+	if (ext & (1 << (INET_DIAG_INFO - 1))) {
+		attr = nla_reserve(skb, INET_DIAG_INFO,
+				   sizeof(struct tcp_info));
+		if (!attr)
+			goto errout;
 
-	if ((ext & (1 << (INET_DIAG_CONG - 1))) && icsk->icsk_ca_ops) {
-		const size_t len = strlen(icsk->icsk_ca_ops->name);
-
-		strcpy(INET_DIAG_PUT(skb, INET_DIAG_CONG, len + 1),
-		       icsk->icsk_ca_ops->name);
+		info = nla_data(attr);
 	}
 
+	if ((ext & (1 << (INET_DIAG_CONG - 1))) && icsk->icsk_ca_ops)
+		if (nla_put_string(skb, INET_DIAG_CONG,
+				   icsk->icsk_ca_ops->name) < 0)
+			goto errout;
+
 	handler->idiag_get_info(sk, r, info);
 
 	if (sk->sk_state < TCP_TIME_WAIT &&
@@ -186,11 +189,10 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		icsk->icsk_ca_ops->get_info(sk, ext, skb);
 
 out:
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 
-rtattr_failure:
-	nlmsg_trim(skb, b);
+errout:
+	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
 }
 EXPORT_SYMBOL_GPL(inet_sk_diag_fill);
@@ -211,20 +213,16 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 {
 	long tmo;
 	struct inet_diag_msg *r;
-	const unsigned char *previous_tail = skb_tail_pointer(skb);
-	struct nlmsghdr *nlh = nlmsg_put(skb, pid, seq,
-					 unlh->nlmsg_type, sizeof(*r), 0);
+	struct nlmsghdr *nlh;
 
-	if (!nlh) {
-		nlmsg_trim(skb, previous_tail);
+	nlh = nlmsg_put(skb, pid, seq, unlh->nlmsg_type, sizeof(*r),
+			nlmsg_flags);
+	if (!nlh)
 		return -EMSGSIZE;
-	}
 
 	r = nlmsg_data(nlh);
 	BUG_ON(tw->tw_state != TCP_TIME_WAIT);
 
-	nlh->nlmsg_flags = nlmsg_flags;
-
 	tmo = tw->tw_ttd - jiffies;
 	if (tmo < 0)
 		tmo = 0;
@@ -253,8 +251,8 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 		*(struct in6_addr *)r->id.idiag_dst = tw6->tw_v6_daddr;
 	}
 #endif
-	nlh->nlmsg_len = skb_tail_pointer(skb) - previous_tail;
-	return skb->len;
+
+	return nlmsg_end(skb, nlh);
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
@@ -303,20 +301,20 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_s
 	if (err)
 		goto out;
 
-	err = -ENOMEM;
-	rep = alloc_skb(NLMSG_SPACE((sizeof(struct inet_diag_msg) +
-				     sizeof(struct inet_diag_meminfo) +
-				     sizeof(struct tcp_info) + 64)),
-			GFP_KERNEL);
-	if (!rep)
+	rep = nlmsg_new(sizeof(struct inet_diag_msg) +
+			sizeof(struct inet_diag_meminfo) +
+			sizeof(struct tcp_info) + 64, GFP_KERNEL);
+	if (!rep) {
+		err = -ENOMEM;
 		goto out;
+	}
 
 	err = sk_diag_fill(sk, rep, req,
 			   NETLINK_CB(in_skb).pid,
 			   nlh->nlmsg_seq, 0, nlh);
 	if (err < 0) {
 		WARN_ON(err == -EMSGSIZE);
-		kfree_skb(rep);
+		nlmsg_free(rep);
 		goto out;
 	}
 	err = netlink_unicast(sock_diag_nlsk, rep, NETLINK_CB(in_skb).pid,
@@ -597,19 +595,16 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct inet_sock *inet = inet_sk(sk);
-	unsigned char *b = skb_tail_pointer(skb);
 	struct inet_diag_msg *r;
 	struct nlmsghdr *nlh;
 	long tmo;
 
-	nlh = nlmsg_put(skb, pid, seq, unlh->nlmsg_type, sizeof(*r), 0);
-	if (!nlh) {
-		nlmsg_trim(skb, b);
-		return -1;
-	}
-	nlh->nlmsg_flags = NLM_F_MULTI;
-	r = nlmsg_data(nlh);
+	nlh = nlmsg_put(skb, pid, seq, unlh->nlmsg_type, sizeof(*r),
+			NLM_F_MULTI);
+	if (!nlh)
+		return -EMSGSIZE;
 
+	r = nlmsg_data(nlh);
 	r->idiag_family = sk->sk_family;
 	r->idiag_state = TCP_SYN_RECV;
 	r->idiag_timer = 1;
@@ -637,9 +632,8 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 		*(struct in6_addr *)r->id.idiag_dst = inet6_rsk(req)->rmt_addr;
 	}
 #endif
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 
-	return skb->len;
+	return nlmsg_end(skb, nlh);
 }
 
 static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
-- 
1.7.7.6
