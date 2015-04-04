From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/9] netfilter: Pass nf_hook_state through ip6t_do_table().
Date: Fri, 03 Apr 2015 22:08:13 -0400 (EDT)
Message-ID: <20150403.220813.1483708092455791106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netfilter_ipv6/ip6_tables.h |  3 +--
 net/ipv6/netfilter/ip6_tables.c           | 13 ++++++-------
 net/ipv6/netfilter/ip6table_filter.c      |  3 +--
 net/ipv6/netfilter/ip6table_mangle.c      | 12 ++++++------
 net/ipv6/netfilter/ip6table_nat.c         |  3 +--
 net/ipv6/netfilter/ip6table_raw.c         |  3 +--
 net/ipv6/netfilter/ip6table_security.c    |  2 +-
 7 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 610208b1..b40d2b6 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -31,8 +31,7 @@ extern struct xt_table *ip6t_register_table(struct net *net,
 extern void ip6t_unregister_table(struct net *net, struct xt_table *table);
 extern unsigned int ip6t_do_table(struct sk_buff *skb,
 				  unsigned int hook,
-				  const struct net_device *in,
-				  const struct net_device *out,
+				  const struct nf_hook_state *state,
 				  struct xt_table *table);
 
 /* Check for an extension */
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 83f59dc..1a732a1 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -317,8 +317,7 @@ ip6t_next_entry(const struct ip6t_entry *entry)
 unsigned int
 ip6t_do_table(struct sk_buff *skb,
 	      unsigned int hook,
-	      const struct net_device *in,
-	      const struct net_device *out,
+	      const struct nf_hook_state *state,
 	      struct xt_table *table)
 {
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
@@ -333,8 +332,8 @@ ip6t_do_table(struct sk_buff *skb,
 	unsigned int addend;
 
 	/* Initialization */
-	indev = in ? in->name : nulldevname;
-	outdev = out ? out->name : nulldevname;
+	indev = state->in ? state->in->name : nulldevname;
+	outdev = state->out ? state->out->name : nulldevname;
 	/* We handle fragments by dealing with the first fragment as
 	 * if it was a normal packet.  All other fragments are treated
 	 * normally, except that they will NEVER match rules that ask
@@ -342,8 +341,8 @@ ip6t_do_table(struct sk_buff *skb,
 	 * rule is also a fragment-specific rule, non-fragments won't
 	 * match it. */
 	acpar.hotdrop = false;
-	acpar.in      = in;
-	acpar.out     = out;
+	acpar.in      = state->in;
+	acpar.out     = state->out;
 	acpar.family  = NFPROTO_IPV6;
 	acpar.hooknum = hook;
 
@@ -393,7 +392,7 @@ ip6t_do_table(struct sk_buff *skb,
 #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 		/* The packet is traced: log it */
 		if (unlikely(skb->nf_trace))
-			trace_packet(skb, hook, in, out,
+			trace_packet(skb, hook, state->in, state->out,
 				     table->name, private, e);
 #endif
 		/* Standard target? */
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index eb9ef09..5c33d8a 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -37,8 +37,7 @@ ip6table_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 {
 	const struct net *net = dev_net(state->in ? state->in : state->out);
 
-	return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
-			     net->ipv6.ip6table_filter);
+	return ip6t_do_table(skb, ops->hooknum, state, net->ipv6.ip6table_filter);
 }
 
 static struct nf_hook_ops *filter_ops __read_mostly;
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index e713b8d..b551f5b 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -32,7 +32,7 @@ static const struct xt_table packet_mangler = {
 };
 
 static unsigned int
-ip6t_mangle_out(struct sk_buff *skb, const struct net_device *out)
+ip6t_mangle_out(struct sk_buff *skb, const struct nf_hook_state *state)
 {
 	unsigned int ret;
 	struct in6_addr saddr, daddr;
@@ -57,8 +57,8 @@ ip6t_mangle_out(struct sk_buff *skb, const struct net_device *out)
 	/* flowlabel and prio (includes version, which shouldn't change either */
 	flowlabel = *((u_int32_t *)ipv6_hdr(skb));
 
-	ret = ip6t_do_table(skb, NF_INET_LOCAL_OUT, NULL, out,
-			    dev_net(out)->ipv6.ip6table_mangle);
+	ret = ip6t_do_table(skb, NF_INET_LOCAL_OUT, state,
+			    dev_net(state->out)->ipv6.ip6table_mangle);
 
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (!ipv6_addr_equal(&ipv6_hdr(skb)->saddr, &saddr) ||
@@ -80,12 +80,12 @@ ip6table_mangle_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
 	if (ops->hooknum == NF_INET_LOCAL_OUT)
-		return ip6t_mangle_out(skb, state->out);
+		return ip6t_mangle_out(skb, state);
 	if (ops->hooknum == NF_INET_POST_ROUTING)
-		return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
+		return ip6t_do_table(skb, ops->hooknum, state,
 				     dev_net(state->out)->ipv6.ip6table_mangle);
 	/* INPUT/FORWARD */
-	return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
+	return ip6t_do_table(skb, ops->hooknum, state,
 			     dev_net(state->in)->ipv6.ip6table_mangle);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index d78f69c..c3a7f7a 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -37,8 +37,7 @@ static unsigned int ip6table_nat_do_chain(const struct nf_hook_ops *ops,
 {
 	struct net *net = nf_ct_net(ct);
 
-	return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
-			     net->ipv6.ip6table_nat);
+	return ip6t_do_table(skb, ops->hooknum, state, net->ipv6.ip6table_nat);
 }
 
 static unsigned int ip6table_nat_fn(const struct nf_hook_ops *ops,
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 937908e..0b33caa 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -24,8 +24,7 @@ ip6table_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 {
 	const struct net *net = dev_net(state->in ? state->in : state->out);
 
-	return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
-			     net->ipv6.ip6table_raw);
+	return ip6t_do_table(skb, ops->hooknum, state, net->ipv6.ip6table_raw);
 }
 
 static struct nf_hook_ops *rawtable_ops __read_mostly;
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index f33b41e..fcef83c 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -41,7 +41,7 @@ ip6table_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 {
 	const struct net *net = dev_net(state->in ? state->in : state->out);
 
-	return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
+	return ip6t_do_table(skb, ops->hooknum, state,
 			     net->ipv6.ip6table_security);
 }
 
-- 
2.1.0

