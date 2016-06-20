From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 12/19] ipv6: Allow request socks to contain IPv6 options.
Date: Mon, 20 Jun 2016 14:36:52 +0100
Message-ID: <1466429819-12707-13-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codeweavers.com ([216.251.189.131]:49027 "EHLO
	mail.codeweavers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282AbcFTNxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 09:53:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If set, these will take precedence over the parent's options during
both sending and child creation.  If they're not set, the parent's
options (if any) will be used.

This is to allow the security_inet_conn_request() hook to modify the
IPv6 options in just the same way that it already may do for IPv4.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 include/net/inet_sock.h |  7 ++++++-
 net/dccp/ipv6.c         | 12 +++++++++---
 net/ipv4/tcp_input.c    |  3 +++
 net/ipv6/tcp_ipv6.c     | 12 +++++++++---
 4 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 012b1f9..236a810 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -97,7 +97,12 @@ struct inet_request_sock {
 	u32                     ir_mark;
 	union {
 		struct ip_options_rcu	*opt;
-		struct sk_buff		*pktopts;
+#if IS_ENABLED(CONFIG_IPV6)
+		struct {
+			struct ipv6_txoptions	*ipv6_opt;
+			struct sk_buff		*pktopts;
+		};
+#endif
 	};
 };
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4663a01..3381748 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -216,14 +216,17 @@ static int dccp_v6_send_response(const struct sock *sk, struct request_sock *req
 	skb = dccp_make_response(sk, dst, req);
 	if (skb != NULL) {
 		struct dccp_hdr *dh = dccp_hdr(skb);
+		struct ipv6_txoptions *opt;
 
 		dh->dccph_checksum = dccp_v6_csum_finish(skb,
 							 &ireq->ir_v6_loc_addr,
 							 &ireq->ir_v6_rmt_addr);
 		fl6.daddr = ireq->ir_v6_rmt_addr;
 		rcu_read_lock();
-		err = ip6_xmit(sk, skb, &fl6, rcu_dereference(np->opt),
-			       np->tclass);
+		opt = ireq->ipv6_opt;
+		if (!opt)
+			opt = rcu_dereference(np->opt);
+		err = ip6_xmit(sk, skb, &fl6, opt, np->tclass);
 		rcu_read_unlock();
 		err = net_xmit_eval(err);
 	}
@@ -236,6 +239,7 @@ done:
 static void dccp_v6_reqsk_destructor(struct request_sock *req)
 {
 	dccp_feat_list_purge(&dccp_rsk(req)->dreq_featneg);
+	kfree(inet_rsk(req)->ipv6_opt);
 	kfree_skb(inet_rsk(req)->pktopts);
 }
 
@@ -494,7 +498,9 @@ static struct sock *dccp_v6_request_recv_sock(const struct sock *sk,
 	 * Yes, keeping reference count would be much more clever, but we make
 	 * one more one thing there: reattach optmem to newsk.
 	 */
-	opt = rcu_dereference(np->opt);
+	opt = ireq->ipv6_opt;
+	if (!opt)
+		opt = rcu_dereference(np->opt);
 	if (opt) {
 		opt = ipv6_dup_options(newsk, opt);
 		RCU_INIT_POINTER(newnp->opt, opt);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c124c3c..f76b4ae 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6148,6 +6148,9 @@ struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
 
 		kmemcheck_annotate_bitfield(ireq, flags);
 		ireq->opt = NULL;
+#if IS_ENABLED(CONFIG_IPV6)
+		ireq->pktopts = NULL;
+#endif
 		atomic64_set(&ireq->ir_cookie, 0);
 		ireq->ireq_state = TCP_NEW_SYN_RECV;
 		write_pnet(&ireq->ireq_net, sock_net(sk_listener));
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f443c6b..cb7407f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -443,6 +443,7 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct ipv6_txoptions *opt;
 	struct flowi6 *fl6 = &fl->u.ip6;
 	struct sk_buff *skb;
 	int err = -ENOMEM;
@@ -463,8 +464,10 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 			fl6->flowlabel = ip6_flowlabel(ipv6_hdr(ireq->pktopts));
 
 		rcu_read_lock();
-		err = ip6_xmit(sk, skb, fl6, rcu_dereference(np->opt),
-			       np->tclass);
+		opt = ireq->ipv6_opt;
+		if (!opt)
+			opt = rcu_dereference(np->opt);
+		err = ip6_xmit(sk, skb, fl6, opt, np->tclass);
 		rcu_read_unlock();
 		err = net_xmit_eval(err);
 	}
@@ -476,6 +479,7 @@ done:
 
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
 {
+	kfree(inet_rsk(req)->ipv6_opt);
 	kfree_skb(inet_rsk(req)->pktopts);
 }
 
@@ -1112,7 +1116,9 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 	   but we make one more one thing there: reattach optmem
 	   to newsk.
 	 */
-	opt = rcu_dereference(np->opt);
+	opt = ireq->ipv6_opt;
+	if (!opt)
+		opt = rcu_dereference(np->opt);
 	if (opt) {
 		opt = ipv6_dup_options(newsk, opt);
 		RCU_INIT_POINTER(newnp->opt, opt);
-- 
2.7.4
