From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/9] netfilter: Pass nf_hook_state through ipt_do_table().
Date: Fri, 03 Apr 2015 22:08:03 -0400 (EDT)
Message-ID: <20150403.220803.1764329204300549767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582AbbDDCIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 22:08:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netfilter_ipv4/ip_tables.h |  3 +--
 net/ipv4/netfilter/ip_tables.c           | 13 ++++++-------
 net/ipv4/netfilter/iptable_filter.c      |  3 +--
 net/ipv4/netfilter/iptable_mangle.c      | 11 ++++++-----
 net/ipv4/netfilter/iptable_nat.c         |  3 +--
 net/ipv4/netfilter/iptable_raw.c         |  3 +--
 net/ipv4/netfilter/iptable_security.c    |  2 +-
 7 files changed, 17 insertions(+), 21 deletions(-)

diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 901e84d..4073510 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -65,8 +65,7 @@ struct ipt_error {
 extern void *ipt_alloc_initial_table(const struct xt_table *);
 extern unsigned int ipt_do_table(struct sk_buff *skb,
 				 unsigned int hook,
-				 const struct net_device *in,
-				 const struct net_device *out,
+				 const struct nf_hook_state *state,
 				 struct xt_table *table);
 
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index cf5e82f..c69db7f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -288,8 +288,7 @@ struct ipt_entry *ipt_next_entry(const struct ipt_entry *entry)
 unsigned int
 ipt_do_table(struct sk_buff *skb,
 	     unsigned int hook,
-	     const struct net_device *in,
-	     const struct net_device *out,
+	     const struct nf_hook_state *state,
 	     struct xt_table *table)
 {
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
@@ -306,8 +305,8 @@ ipt_do_table(struct sk_buff *skb,
 
 	/* Initialization */
 	ip = ip_hdr(skb);
-	indev = in ? in->name : nulldevname;
-	outdev = out ? out->name : nulldevname;
+	indev = state->in ? state->in->name : nulldevname;
+	outdev = state->out ? state->out->name : nulldevname;
 	/* We handle fragments by dealing with the first fragment as
 	 * if it was a normal packet.  All other fragments are treated
 	 * normally, except that they will NEVER match rules that ask
@@ -317,8 +316,8 @@ ipt_do_table(struct sk_buff *skb,
 	acpar.fragoff = ntohs(ip->frag_off) & IP_OFFSET;
 	acpar.thoff   = ip_hdrlen(skb);
 	acpar.hotdrop = false;
-	acpar.in      = in;
-	acpar.out     = out;
+	acpar.in      = state->in;
+	acpar.out     = state->out;
 	acpar.family  = NFPROTO_IPV4;
 	acpar.hooknum = hook;
 
@@ -370,7 +369,7 @@ ipt_do_table(struct sk_buff *skb,
 #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 		/* The packet is traced: log it */
 		if (unlikely(skb->nf_trace))
-			trace_packet(skb, hook, in, out,
+			trace_packet(skb, hook, state->in, state->out,
 				     table->name, private, e);
 #endif
 		/* Standard target? */
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 1df0d42..a0f3bec 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -45,8 +45,7 @@ iptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	net = dev_net(state->in ? state->in : state->out);
-	return ipt_do_table(skb, ops->hooknum, state->in, state->out,
-			    net->ipv4.iptable_filter);
+	return ipt_do_table(skb, ops->hooknum, state, net->ipv4.iptable_filter);
 }
 
 static struct nf_hook_ops *filter_ops __read_mostly;
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 7a825e7..62cbb8c 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -37,8 +37,9 @@ static const struct xt_table packet_mangler = {
 };
 
 static unsigned int
-ipt_mangle_out(struct sk_buff *skb, const struct net_device *out)
+ipt_mangle_out(struct sk_buff *skb, const struct nf_hook_state *state)
 {
+	struct net_device *out = state->out;
 	unsigned int ret;
 	const struct iphdr *iph;
 	u_int8_t tos;
@@ -58,7 +59,7 @@ ipt_mangle_out(struct sk_buff *skb, const struct net_device *out)
 	daddr = iph->daddr;
 	tos = iph->tos;
 
-	ret = ipt_do_table(skb, NF_INET_LOCAL_OUT, NULL, out,
+	ret = ipt_do_table(skb, NF_INET_LOCAL_OUT, state,
 			   dev_net(out)->ipv4.iptable_mangle);
 	/* Reroute for ANY change. */
 	if (ret != NF_DROP && ret != NF_STOLEN) {
@@ -84,12 +85,12 @@ iptable_mangle_hook(const struct nf_hook_ops *ops,
 		     const struct nf_hook_state *state)
 {
 	if (ops->hooknum == NF_INET_LOCAL_OUT)
-		return ipt_mangle_out(skb, state->out);
+		return ipt_mangle_out(skb, state);
 	if (ops->hooknum == NF_INET_POST_ROUTING)
-		return ipt_do_table(skb, ops->hooknum, state->in, state->out,
+		return ipt_do_table(skb, ops->hooknum, state,
 				    dev_net(state->out)->ipv4.iptable_mangle);
 	/* PREROUTING/INPUT/FORWARD: */
-	return ipt_do_table(skb, ops->hooknum, state->in, state->out,
+	return ipt_do_table(skb, ops->hooknum, state,
 			    dev_net(state->in)->ipv4.iptable_mangle);
 }
 
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 086e231..0d4d9cd 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -35,8 +35,7 @@ static unsigned int iptable_nat_do_chain(const struct nf_hook_ops *ops,
 {
 	struct net *net = nf_ct_net(ct);
 
-	return ipt_do_table(skb, ops->hooknum, state->in, state->out,
-			    net->ipv4.nat_table);
+	return ipt_do_table(skb, ops->hooknum, state, net->ipv4.nat_table);
 }
 
 static unsigned int iptable_nat_ipv4_fn(const struct nf_hook_ops *ops,
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index fac8f60..0356e6d 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -32,8 +32,7 @@ iptable_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	net = dev_net(state->in ? state->in : state->out);
-	return ipt_do_table(skb, ops->hooknum, state->in, state->out,
-			    net->ipv4.iptable_raw);
+	return ipt_do_table(skb, ops->hooknum, state, net->ipv4.iptable_raw);
 }
 
 static struct nf_hook_ops *rawtable_ops __read_mostly;
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index d9ad60a..4bce398 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -49,7 +49,7 @@ iptable_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	net = dev_net(state->in ? state->in : state->out);
-	return ipt_do_table(skb, ops->hooknum, state->in, state->out,
+	return ipt_do_table(skb, ops->hooknum, state,
 			    net->ipv4.iptable_security);
 }
 
-- 
2.1.0
