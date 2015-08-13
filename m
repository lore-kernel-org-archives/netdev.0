From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/3] lwt: Add support to redirect dst.input
Date: Thu, 13 Aug 2015 09:54:01 -0700
Message-ID: <1439484843-3848061-2-git-send-email-tom@herbertland.com>
References: <1439484843-3848061-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tgraf@suug.ch>, <roopa@cumulusnetworks.com>, <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36256 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753344AbbHMQyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 12:54:41 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7DGox4R002502
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 09:54:40 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1w8x8bg4kq-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 09:54:40 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 fbbddcce41db11e581990002c992ebde-22ff12b0 for <netdev@vger.kernel.org>;	Thu,
 13 Aug 2015 09:54:38 -0700
In-Reply-To: <1439484843-3848061-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the capability to redirect dst input in the same way
that dst output is redirected by LWT.

Also, save the original dst.input and and dst.out when setting up
lwtunnel redirection. These can be called by the client as a pass-
through.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/lwtunnel.h | 25 ++++++++++++++++++++++-
 net/core/lwtunnel.c    | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/route.c       |  8 +++++++-
 net/ipv6/route.c       |  8 +++++++-
 4 files changed, 93 insertions(+), 3 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 33bd309..3db87d7 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -11,12 +11,15 @@
 #define LWTUNNEL_HASH_SIZE   (1 << LWTUNNEL_HASH_BITS)
 
 /* lw tunnel state flags */
-#define LWTUNNEL_STATE_OUTPUT_REDIRECT 0x1
+#define LWTUNNEL_STATE_OUTPUT_REDIRECT	BIT(0)
+#define LWTUNNEL_STATE_INPUT_REDIRECT	BIT(1)
 
 struct lwtunnel_state {
 	__u16		type;
 	__u16		flags;
 	atomic_t	refcnt;
+	int		(*orig_output)(struct sock *sk, struct sk_buff *skb);
+	int		(*orig_input)(struct sk_buff *);
 	int             len;
 	__u8            data[0];
 };
@@ -25,6 +28,7 @@ struct lwtunnel_encap_ops {
 	int (*build_state)(struct net_device *dev, struct nlattr *encap,
 			   struct lwtunnel_state **ts);
 	int (*output)(struct sock *sk, struct sk_buff *skb);
+	int (*input)(struct sk_buff *skb);
 	int (*fill_encap)(struct sk_buff *skb,
 			  struct lwtunnel_state *lwtstate);
 	int (*get_encap_size)(struct lwtunnel_state *lwtstate);
@@ -58,6 +62,13 @@ static inline bool lwtunnel_output_redirect(struct lwtunnel_state *lwtstate)
 	return false;
 }
 
+static inline bool lwtunnel_input_redirect(struct lwtunnel_state *lwtstate)
+{
+	if (lwtstate && (lwtstate->flags & LWTUNNEL_STATE_INPUT_REDIRECT))
+		return true;
+
+	return false;
+}
 int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *op,
 			   unsigned int num);
 int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
@@ -72,6 +83,8 @@ struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len);
 int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b);
 int lwtunnel_output(struct sock *sk, struct sk_buff *skb);
 int lwtunnel_output6(struct sock *sk, struct sk_buff *skb);
+int lwtunnel_input(struct sk_buff *skb);
+int lwtunnel_input6(struct sk_buff *skb);
 
 #else
 
@@ -142,6 +155,16 @@ static inline int lwtunnel_output6(struct sock *sk, struct sk_buff *skb)
 	return -EOPNOTSUPP;
 }
 
+static inline int lwtunnel_input(struct sock *sk, struct sk_buff *skb)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int lwtunnel_input6(struct sock *sk, struct sk_buff *skb)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif
 
 #endif /* __NET_LWTUNNEL_H */
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 5d6d8e3..3331585 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -241,3 +241,58 @@ int lwtunnel_output(struct sock *sk, struct sk_buff *skb)
 	return __lwtunnel_output(sk, skb, lwtstate);
 }
 EXPORT_SYMBOL(lwtunnel_output);
+
+int __lwtunnel_input(struct sk_buff *skb,
+		     struct lwtunnel_state *lwtstate)
+{
+	const struct lwtunnel_encap_ops *ops;
+	int ret = -EINVAL;
+
+	if (!lwtstate)
+		goto drop;
+
+	if (lwtstate->type == LWTUNNEL_ENCAP_NONE ||
+	    lwtstate->type > LWTUNNEL_ENCAP_MAX)
+		return 0;
+
+	ret = -EOPNOTSUPP;
+	rcu_read_lock();
+	ops = rcu_dereference(lwtun_encaps[lwtstate->type]);
+	if (likely(ops && ops->input))
+		ret = ops->input(skb);
+	rcu_read_unlock();
+
+	if (ret == -EOPNOTSUPP)
+		goto drop;
+
+	return ret;
+
+drop:
+	kfree_skb(skb);
+
+	return ret;
+}
+
+int lwtunnel_input6(struct sk_buff *skb)
+{
+	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
+	struct lwtunnel_state *lwtstate = NULL;
+
+	if (rt)
+		lwtstate = rt->rt6i_lwtstate;
+
+	return __lwtunnel_input(skb, lwtstate);
+}
+EXPORT_SYMBOL(lwtunnel_input6);
+
+int lwtunnel_input(struct sk_buff *skb)
+{
+	struct rtable *rt = (struct rtable *)skb_dst(skb);
+	struct lwtunnel_state *lwtstate = NULL;
+
+	if (rt)
+		lwtstate = rt->rt_lwtstate;
+
+	return __lwtunnel_input(skb, lwtstate);
+}
+EXPORT_SYMBOL(lwtunnel_input);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 18fd7c9..051d834 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1630,8 +1630,14 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.output = ip_output;
 
 	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
-	if (lwtunnel_output_redirect(rth->rt_lwtstate))
+	if (lwtunnel_output_redirect(rth->rt_lwtstate)) {
+		rth->rt_lwtstate->orig_output = rth->dst.output;
 		rth->dst.output = lwtunnel_output;
+	}
+	if (lwtunnel_input_redirect(rth->rt_lwtstate)) {
+		rth->rt_lwtstate->orig_input = rth->dst.input;
+		rth->dst.input = lwtunnel_input;
+	}
 	skb_dst_set(skb, &rth->dst);
 out:
 	err = 0;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 54fccf0..b01a437 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1779,8 +1779,14 @@ int ip6_route_add(struct fib6_config *cfg)
 		if (err)
 			goto out;
 		rt->rt6i_lwtstate = lwtstate_get(lwtstate);
-		if (lwtunnel_output_redirect(rt->rt6i_lwtstate))
+		if (lwtunnel_output_redirect(rt->rt6i_lwtstate)) {
+			rt->rt6i_lwtstate->orig_output = rt->dst.output;
 			rt->dst.output = lwtunnel_output6;
+		}
+		if (lwtunnel_input_redirect(rt->rt6i_lwtstate)) {
+			rt->rt6i_lwtstate->orig_input = rt->dst.input;
+			rt->dst.input = lwtunnel_input6;
+		}
 	}
 
 	ipv6_addr_prefix(&rt->rt6i_dst.addr, &cfg->fc_dst, cfg->fc_dst_len);
-- 
1.8.1
