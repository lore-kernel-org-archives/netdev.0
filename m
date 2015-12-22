From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: [RFC PATCH 12/17] ipv6: Allow request socks to contain IPv6 options.
Date: Tue, 22 Dec 2015 11:46:48 +0000
Message-ID: <1450784813-18304-13-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

If set, these will that precedence over the parent's options during
both sending and child creation.  If they're not set, the parent's
options (if any) will be used.

This is to allow the security_inet_conn_request() hook to modify the
IPv6 options in just the same way that it already may do for IPv4.

Signed-off-by: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
---
 include/net/inet_sock.h |  7 ++++++-
 net/dccp/ipv6.c         | 12 +++++++++---
 net/ipv4/tcp_input.c    |  3 +++
 net/ipv6/tcp_ipv6.c     | 12 +++++++++---
 4 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 625bdf9..39bbe8d 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -96,7 +96,12 @@ struct inet_request_sock {
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
index 9c6d050..8bb1c3a 100644
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
index 2d656ee..af91a95 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6094,6 +6094,9 @@ struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
 
 		kmemcheck_annotate_bitfield(ireq, flags);
 		ireq->opt = NULL;
+#if IS_ENABLED(CONFIG_IPV6)
+		ireq->pktopts = NULL;
+#endif
 		atomic64_set(&ireq->ir_cookie, 0);
 		ireq->ireq_state = TCP_NEW_SYN_RECV;
 		write_pnet(&ireq->ireq_net, sock_net(sk_listener));
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6b8a8a9..a9041b2 100644
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
@@ -462,8 +463,10 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 		if (np->repflow && ireq->pktopts)
 			fl6->flowlabel = ip6_flowlabel(ipv6_hdr(ireq->pktopts));
 
-		err = ip6_xmit(sk, skb, fl6, rcu_dereference(np->opt),
-			       np->tclass);
+		opt = ireq->ipv6_opt;
+		if (!opt)
+			opt = rcu_dereference(np->opt);
+		err = ip6_xmit(sk, skb, fl6, opt, np->tclass);
 		err = net_xmit_eval(err);
 	}
 
@@ -474,6 +477,7 @@ done:
 
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
 {
+	kfree(inet_rsk(req)->ipv6_opt);
 	kfree_skb(inet_rsk(req)->pktopts);
 }
 
@@ -1101,7 +1105,9 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
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
1.8.0

_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
