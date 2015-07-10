From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 05/22] lwtunnel: support dst output redirect function
Date: Fri, 10 Jul 2015 16:19:07 +0200
Message-ID: <2f6cd624b20ed0b9bc12b7b490f86f415e5643f3.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40440 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932643AbbGJOTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:35 -0400
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch introduces lwtunnel_output function to call corresponding
lwtunnels output function to xmit the packet.

It adds two variants lwtunnel_output and lwtunnel_output6 for ipv4 and
ipv6 respectively today. But this is subject to change when lwtstate will
reside in dst or dst_metadata (as per upstream discussions).

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/lwtunnel.h | 12 +++++++++++
 net/core/lwtunnel.c    | 56 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index df24b36..918e03c 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -69,6 +69,8 @@ int lwtunnel_fill_encap(struct sk_buff *skb,
 int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate);
 struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len);
 int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b);
+int lwtunnel_output(struct sock *sk, struct sk_buff *skb);
+int lwtunnel_output6(struct sock *sk, struct sk_buff *skb);
 
 #else
 
@@ -127,6 +129,16 @@ static inline int lwtunnel_cmp_encap(struct lwtunnel_state *a,
 	return 0;
 }
 
+static inline int lwtunnel_output(struct sock *sk, struct sk_buff *skb)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int lwtunnel_output6(struct sock *sk, struct sk_buff *skb)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif
 
 #endif /* __NET_LWTUNNEL_H */
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index ae876d1..55e7e03 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -25,6 +25,7 @@
 
 #include <net/lwtunnel.h>
 #include <net/rtnetlink.h>
+#include <net/ip6_fib.h>
 
 struct lwtunnel_state *lwtunnel_state_alloc(int encap_len)
 {
@@ -170,3 +171,58 @@ int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b)
 	return 0;
 }
 EXPORT_SYMBOL(lwtunnel_cmp_encap);
+
+int __lwtunnel_output(struct sock *sk, struct sk_buff *skb,
+		      struct lwtunnel_state *lwtstate)
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
+	if (likely(ops && ops->output))
+		ret = ops->output(sk, skb);
+	rcu_read_unlock();
+
+	if (ret == -EOPNOTSUPP)
+		goto drop;
+
+	return ret;
+
+drop:
+	kfree(skb);
+
+	return ret;
+}
+
+int lwtunnel_output6(struct sock *sk, struct sk_buff *skb)
+{
+	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
+	struct lwtunnel_state *lwtstate = NULL;
+
+	if (rt)
+		lwtstate = rt->rt6i_lwtstate;
+
+	return __lwtunnel_output(sk, skb, lwtstate);
+}
+EXPORT_SYMBOL(lwtunnel_output6);
+
+int lwtunnel_output(struct sock *sk, struct sk_buff *skb)
+{
+	struct rtable *rt = (struct rtable *)skb_dst(skb);
+	struct lwtunnel_state *lwtstate = NULL;
+
+	if (rt)
+		lwtstate = rt->rt_lwtstate;
+
+	return __lwtunnel_output(sk, skb, lwtstate);
+}
+EXPORT_SYMBOL(lwtunnel_output);
-- 
2.4.3
