From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 29/30] netfilter: Use nf_hook_state.net
Date: Tue, 15 Sep 2015 20:04:17 -0500
Message-ID: <1442365458-16349-29-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of saying "net = dev_net(state->in?state->in:state->out)"
just say "state->net".  As that information is now availabe,
much less confusing and much less error prone.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/bridge/netfilter/ebtable_filter.c          | 4 ++--
 net/bridge/netfilter/ebtable_nat.c             | 4 ++--
 net/ipv4/netfilter/arptable_filter.c           | 4 +---
 net/ipv4/netfilter/ip_tables.c                 | 8 ++++----
 net/ipv4/netfilter/ipt_CLUSTERIP.c             | 2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              | 2 +-
 net/ipv4/netfilter/iptable_filter.c            | 6 ++----
 net/ipv4/netfilter/iptable_mangle.c            | 7 +++----
 net/ipv4/netfilter/iptable_nat.c               | 5 ++---
 net/ipv4/netfilter/iptable_raw.c               | 6 ++----
 net/ipv4/netfilter/iptable_security.c          | 5 +----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 4 ++--
 net/ipv6/netfilter/ip6_tables.c                | 8 ++++----
 net/ipv6/netfilter/ip6t_SYNPROXY.c             | 2 +-
 net/ipv6/netfilter/ip6table_filter.c           | 5 ++---
 net/ipv6/netfilter/ip6table_mangle.c           | 6 +++---
 net/ipv6/netfilter/ip6table_nat.c              | 5 ++---
 net/ipv6/netfilter/ip6table_raw.c              | 5 ++---
 net/ipv6/netfilter/ip6table_security.c         | 4 +---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 4 ++--
 net/netfilter/nfnetlink_queue_core.c           | 3 +--
 21 files changed, 41 insertions(+), 58 deletions(-)

diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 8a3f63b2e807..ab20d6ed6e2f 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -61,7 +61,7 @@ ebt_in_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	    const struct nf_hook_state *state)
 {
 	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
-			    dev_net(state->in)->xt.frame_filter);
+			    state->net->xt.frame_filter);
 }
 
 static unsigned int
@@ -69,7 +69,7 @@ ebt_out_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
 	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
-			    dev_net(state->out)->xt.frame_filter);
+			    state->net->xt.frame_filter);
 }
 
 static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index c5ef5b1ab678..ad81a5a65644 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -61,7 +61,7 @@ ebt_nat_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	   const struct nf_hook_state *state)
 {
 	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
-			    dev_net(state->in)->xt.frame_nat);
+			    state->net->xt.frame_nat);
 }
 
 static unsigned int
@@ -69,7 +69,7 @@ ebt_nat_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	    const struct nf_hook_state *state)
 {
 	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
-			    dev_net(state->out)->xt.frame_nat);
+			    state->net->xt.frame_nat);
 }
 
 static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 93876d03120c..d217e4c19645 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -30,10 +30,8 @@ static unsigned int
 arptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	const struct net *net = dev_net(state->in ? state->in : state->out);
-
 	return arpt_do_table(skb, ops->hooknum, state,
-			     net->ipv4.arptable_filter);
+			     state->net->ipv4.arptable_filter);
 }
 
 static struct nf_hook_ops *arpfilter_ops __read_mostly;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index b0a86e73451c..5d514eac4c31 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -246,7 +246,8 @@ get_chainname_rulenum(const struct ipt_entry *s, const struct ipt_entry *e,
 	return 0;
 }
 
-static void trace_packet(const struct sk_buff *skb,
+static void trace_packet(struct net *net,
+			 const struct sk_buff *skb,
 			 unsigned int hook,
 			 const struct net_device *in,
 			 const struct net_device *out,
@@ -258,7 +259,6 @@ static void trace_packet(const struct sk_buff *skb,
 	const char *hookname, *chainname, *comment;
 	const struct ipt_entry *iter;
 	unsigned int rulenum = 0;
-	struct net *net = dev_net(in ? in : out);
 
 	root = get_entry(private->entries, private->hook_entry[hook]);
 
@@ -378,8 +378,8 @@ ipt_do_table(struct sk_buff *skb,
 #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 		/* The packet is traced: log it */
 		if (unlikely(skb->nf_trace))
-			trace_packet(skb, hook, state->in, state->out,
-				     table->name, private, e);
+			trace_packet(state->net, skb, hook, state->in,
+				     state->out, table->name, private, e);
 #endif
 		/* Standard target? */
 		if (!t->u.kernel.target->target) {
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 45cb16a6a4a3..69157d8eba95 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -514,7 +514,7 @@ arp_mangle(const struct nf_hook_ops *ops,
 	struct arphdr *arp = arp_hdr(skb);
 	struct arp_payload *payload;
 	struct clusterip_config *c;
-	struct net *net = dev_net(state->in ? state->in : state->out);
+	struct net *net = state->net;
 
 	/* we don't care about non-ethernet and non-ipv4 ARP */
 	if (arp->ar_hrd != htons(ARPHRD_ETHER) ||
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 95ea633e8356..f471a0628c75 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -303,7 +303,7 @@ static unsigned int ipv4_synproxy_hook(const struct nf_hook_ops *ops,
 				       struct sk_buff *skb,
 				       const struct nf_hook_state *nhs)
 {
-	struct synproxy_net *snet = synproxy_pernet(dev_net(nhs->in ? : nhs->out));
+	struct synproxy_net *snet = synproxy_pernet(nhs->net);
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
 	struct nf_conn_synproxy *synproxy;
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index a0f3beca52d2..32feff32b116 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -36,16 +36,14 @@ static unsigned int
 iptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		    const struct nf_hook_state *state)
 {
-	const struct net *net;
-
 	if (ops->hooknum == NF_INET_LOCAL_OUT &&
 	    (skb->len < sizeof(struct iphdr) ||
 	     ip_hdrlen(skb) < sizeof(struct iphdr)))
 		/* root is playing with raw sockets. */
 		return NF_ACCEPT;
 
-	net = dev_net(state->in ? state->in : state->out);
-	return ipt_do_table(skb, ops->hooknum, state, net->ipv4.iptable_filter);
+	return ipt_do_table(skb, ops->hooknum, state,
+			    state->net->ipv4.iptable_filter);
 }
 
 static struct nf_hook_ops *filter_ops __read_mostly;
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 62cbb8c5f4a8..4a5150fc9510 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -39,7 +39,6 @@ static const struct xt_table packet_mangler = {
 static unsigned int
 ipt_mangle_out(struct sk_buff *skb, const struct nf_hook_state *state)
 {
-	struct net_device *out = state->out;
 	unsigned int ret;
 	const struct iphdr *iph;
 	u_int8_t tos;
@@ -60,7 +59,7 @@ ipt_mangle_out(struct sk_buff *skb, const struct nf_hook_state *state)
 	tos = iph->tos;
 
 	ret = ipt_do_table(skb, NF_INET_LOCAL_OUT, state,
-			   dev_net(out)->ipv4.iptable_mangle);
+			   state->net->ipv4.iptable_mangle);
 	/* Reroute for ANY change. */
 	if (ret != NF_DROP && ret != NF_STOLEN) {
 		iph = ip_hdr(skb);
@@ -88,10 +87,10 @@ iptable_mangle_hook(const struct nf_hook_ops *ops,
 		return ipt_mangle_out(skb, state);
 	if (ops->hooknum == NF_INET_POST_ROUTING)
 		return ipt_do_table(skb, ops->hooknum, state,
-				    dev_net(state->out)->ipv4.iptable_mangle);
+				    state->net->ipv4.iptable_mangle);
 	/* PREROUTING/INPUT/FORWARD: */
 	return ipt_do_table(skb, ops->hooknum, state,
-			    dev_net(state->in)->ipv4.iptable_mangle);
+			    state->net->ipv4.iptable_mangle);
 }
 
 static struct nf_hook_ops *mangle_ops __read_mostly;
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 0d4d9cdf98a4..4f4c64f81169 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -33,9 +33,8 @@ static unsigned int iptable_nat_do_chain(const struct nf_hook_ops *ops,
 					 const struct nf_hook_state *state,
 					 struct nf_conn *ct)
 {
-	struct net *net = nf_ct_net(ct);
-
-	return ipt_do_table(skb, ops->hooknum, state, net->ipv4.nat_table);
+	return ipt_do_table(skb, ops->hooknum, state,
+			    state->net->ipv4.nat_table);
 }
 
 static unsigned int iptable_nat_ipv4_fn(const struct nf_hook_ops *ops,
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 0356e6da4bb7..20126e469ffb 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -23,16 +23,14 @@ static unsigned int
 iptable_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		 const struct nf_hook_state *state)
 {
-	const struct net *net;
-
 	if (ops->hooknum == NF_INET_LOCAL_OUT &&
 	    (skb->len < sizeof(struct iphdr) ||
 	     ip_hdrlen(skb) < sizeof(struct iphdr)))
 		/* root is playing with raw sockets. */
 		return NF_ACCEPT;
 
-	net = dev_net(state->in ? state->in : state->out);
-	return ipt_do_table(skb, ops->hooknum, state, net->ipv4.iptable_raw);
+	return ipt_do_table(skb, ops->hooknum, state,
+			    state->net->ipv4.iptable_raw);
 }
 
 static struct nf_hook_ops *rawtable_ops __read_mostly;
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index 4bce3980ccd9..82fefd609b85 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -40,17 +40,14 @@ static unsigned int
 iptable_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	const struct net *net;
-
 	if (ops->hooknum == NF_INET_LOCAL_OUT &&
 	    (skb->len < sizeof(struct iphdr) ||
 	     ip_hdrlen(skb) < sizeof(struct iphdr)))
 		/* Somebody is playing with raw sockets. */
 		return NF_ACCEPT;
 
-	net = dev_net(state->in ? state->in : state->out);
 	return ipt_do_table(skb, ops->hooknum, state,
-			    net->ipv4.iptable_security);
+			    state->net->ipv4.iptable_security);
 }
 
 static struct nf_hook_ops *sectbl_ops __read_mostly;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 8a2caaf3940b..9564684876c9 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -147,7 +147,7 @@ static unsigned int ipv4_conntrack_in(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state)
 {
-	return nf_conntrack_in(dev_net(state->in), PF_INET, ops->hooknum, skb);
+	return nf_conntrack_in(state->net, PF_INET, ops->hooknum, skb);
 }
 
 static unsigned int ipv4_conntrack_local(const struct nf_hook_ops *ops,
@@ -158,7 +158,7 @@ static unsigned int ipv4_conntrack_local(const struct nf_hook_ops *ops,
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
-	return nf_conntrack_in(dev_net(state->out), PF_INET, ops->hooknum, skb);
+	return nf_conntrack_in(state->net, PF_INET, ops->hooknum, skb);
 }
 
 /* Connection tracking may drop packets, but never alters them, so
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 0771991ed812..cd9b401231d3 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -275,7 +275,8 @@ get_chainname_rulenum(const struct ip6t_entry *s, const struct ip6t_entry *e,
 	return 0;
 }
 
-static void trace_packet(const struct sk_buff *skb,
+static void trace_packet(struct net *net,
+			 const struct sk_buff *skb,
 			 unsigned int hook,
 			 const struct net_device *in,
 			 const struct net_device *out,
@@ -287,7 +288,6 @@ static void trace_packet(const struct sk_buff *skb,
 	const char *hookname, *chainname, *comment;
 	const struct ip6t_entry *iter;
 	unsigned int rulenum = 0;
-	struct net *net = dev_net(in ? in : out);
 
 	root = get_entry(private->entries, private->hook_entry[hook]);
 
@@ -401,8 +401,8 @@ ip6t_do_table(struct sk_buff *skb,
 #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 		/* The packet is traced: log it */
 		if (unlikely(skb->nf_trace))
-			trace_packet(skb, hook, state->in, state->out,
-				     table->name, private, e);
+			trace_packet(state->net, skb, hook, state->in,
+				     state->out, table->name, private, e);
 #endif
 		/* Standard target? */
 		if (!t->u.kernel.target->target) {
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 1e4bf99ed16e..4c9f3e79d75f 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -320,7 +320,7 @@ static unsigned int ipv6_synproxy_hook(const struct nf_hook_ops *ops,
 				       struct sk_buff *skb,
 				       const struct nf_hook_state *nhs)
 {
-	struct synproxy_net *snet = synproxy_pernet(dev_net(nhs->in ? : nhs->out));
+	struct synproxy_net *snet = synproxy_pernet(nhs->net);
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
 	struct nf_conn_synproxy *synproxy;
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 5c33d8abc077..2449005fb5dc 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -35,9 +35,8 @@ static unsigned int
 ip6table_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	const struct net *net = dev_net(state->in ? state->in : state->out);
-
-	return ip6t_do_table(skb, ops->hooknum, state, net->ipv6.ip6table_filter);
+	return ip6t_do_table(skb, ops->hooknum, state,
+			     state->net->ipv6.ip6table_filter);
 }
 
 static struct nf_hook_ops *filter_ops __read_mostly;
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index b551f5b79fe2..a46dbf097d29 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -58,7 +58,7 @@ ip6t_mangle_out(struct sk_buff *skb, const struct nf_hook_state *state)
 	flowlabel = *((u_int32_t *)ipv6_hdr(skb));
 
 	ret = ip6t_do_table(skb, NF_INET_LOCAL_OUT, state,
-			    dev_net(state->out)->ipv6.ip6table_mangle);
+			    state->net->ipv6.ip6table_mangle);
 
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (!ipv6_addr_equal(&ipv6_hdr(skb)->saddr, &saddr) ||
@@ -83,10 +83,10 @@ ip6table_mangle_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		return ip6t_mangle_out(skb, state);
 	if (ops->hooknum == NF_INET_POST_ROUTING)
 		return ip6t_do_table(skb, ops->hooknum, state,
-				     dev_net(state->out)->ipv6.ip6table_mangle);
+				     state->net->ipv6.ip6table_mangle);
 	/* INPUT/FORWARD */
 	return ip6t_do_table(skb, ops->hooknum, state,
-			     dev_net(state->in)->ipv6.ip6table_mangle);
+			     state->net->ipv6.ip6table_mangle);
 }
 
 static struct nf_hook_ops *mangle_ops __read_mostly;
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index c3a7f7af0ed4..a56451de127f 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -35,9 +35,8 @@ static unsigned int ip6table_nat_do_chain(const struct nf_hook_ops *ops,
 					  const struct nf_hook_state *state,
 					  struct nf_conn *ct)
 {
-	struct net *net = nf_ct_net(ct);
-
-	return ip6t_do_table(skb, ops->hooknum, state, net->ipv6.ip6table_nat);
+	return ip6t_do_table(skb, ops->hooknum, state,
+			     state->net->ipv6.ip6table_nat);
 }
 
 static unsigned int ip6table_nat_fn(const struct nf_hook_ops *ops,
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 0b33caad2b69..18e831e35782 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -22,9 +22,8 @@ static unsigned int
 ip6table_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		  const struct nf_hook_state *state)
 {
-	const struct net *net = dev_net(state->in ? state->in : state->out);
-
-	return ip6t_do_table(skb, ops->hooknum, state, net->ipv6.ip6table_raw);
+	return ip6t_do_table(skb, ops->hooknum, state,
+			     state->net->ipv6.ip6table_raw);
 }
 
 static struct nf_hook_ops *rawtable_ops __read_mostly;
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index fcef83c25f7b..83bc96ae5d73 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -39,10 +39,8 @@ static unsigned int
 ip6table_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		       const struct nf_hook_state *state)
 {
-	const struct net *net = dev_net(state->in ? state->in : state->out);
-
 	return ip6t_do_table(skb, ops->hooknum, state,
-			     net->ipv6.ip6table_security);
+			     state->net->ipv6.ip6table_security);
 }
 
 static struct nf_hook_ops *sectbl_ops __read_mostly;
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 7302900c321a..1ef1b79def56 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -169,7 +169,7 @@ static unsigned int ipv6_conntrack_in(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state)
 {
-	return nf_conntrack_in(dev_net(state->in), PF_INET6, ops->hooknum, skb);
+	return nf_conntrack_in(state->net, PF_INET6, ops->hooknum, skb);
 }
 
 static unsigned int ipv6_conntrack_local(const struct nf_hook_ops *ops,
@@ -181,7 +181,7 @@ static unsigned int ipv6_conntrack_local(const struct nf_hook_ops *ops,
 		net_notice_ratelimited("ipv6_conntrack_local: packet too short\n");
 		return NF_ACCEPT;
 	}
-	return nf_conntrack_in(dev_net(state->out), PF_INET6, ops->hooknum, skb);
+	return nf_conntrack_in(state->net, PF_INET6, ops->hooknum, skb);
 }
 
 static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index a5cd6d90b78b..41583e30051b 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -670,8 +670,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	struct nfqnl_instance *queue;
 	struct sk_buff *skb, *segs;
 	int err = -ENOBUFS;
-	struct net *net = dev_net(entry->state.in ?
-				  entry->state.in : entry->state.out);
+	struct net *net = entry->state.net;
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 
 	/* rcu_read_lock()ed by nf_hook_slow() */
-- 
2.2.1

