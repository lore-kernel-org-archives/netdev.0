From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/9] netfilter: Make nf_hookfn use nf_hook_state.
Date: Fri, 03 Apr 2015 22:07:53 -0400 (EDT)
Message-ID: <20150403.220753.25647204269047722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Pass the nf_hook_state all the way down into the hook
functions themselves.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netfilter.h                      |  4 +--
 net/bridge/br_netfilter.c                      | 46 +++++++++-----------------
 net/bridge/netfilter/ebtable_filter.c          | 14 ++++----
 net/bridge/netfilter/ebtable_nat.c             | 14 ++++----
 net/bridge/netfilter/nf_tables_bridge.c        | 10 +++---
 net/decnet/netfilter/dn_rtmsg.c                |  4 +--
 net/ipv4/netfilter/arptable_filter.c           |  7 ++--
 net/ipv4/netfilter/ipt_CLUSTERIP.c             | 10 +++---
 net/ipv4/netfilter/ipt_SYNPROXY.c              |  6 ++--
 net/ipv4/netfilter/iptable_filter.c            |  7 ++--
 net/ipv4/netfilter/iptable_mangle.c            | 14 ++++----
 net/ipv4/netfilter/iptable_nat.c               | 28 +++++++---------
 net/ipv4/netfilter/iptable_raw.c               |  8 ++---
 net/ipv4/netfilter/iptable_security.c          |  8 ++---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 20 ++++-------
 net/ipv4/netfilter/nf_defrag_ipv4.c            |  4 +--
 net/ipv4/netfilter/nf_tables_arp.c             |  6 ++--
 net/ipv4/netfilter/nf_tables_ipv4.c            | 12 +++----
 net/ipv4/netfilter/nft_chain_nat_ipv4.c        | 25 +++++---------
 net/ipv4/netfilter/nft_chain_route_ipv4.c      |  6 ++--
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  6 ++--
 net/ipv6/netfilter/ip6table_filter.c           |  7 ++--
 net/ipv6/netfilter/ip6table_mangle.c           | 13 ++++----
 net/ipv6/netfilter/ip6table_nat.c              | 28 +++++++---------
 net/ipv6/netfilter/ip6table_raw.c              |  7 ++--
 net/ipv6/netfilter/ip6table_security.c         |  8 ++---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 20 ++++-------
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  8 ++---
 net/ipv6/netfilter/nf_tables_ipv6.c            | 12 +++----
 net/ipv6/netfilter/nft_chain_nat_ipv6.c        | 24 +++++---------
 net/ipv6/netfilter/nft_chain_route_ipv6.c      |  6 ++--
 net/netfilter/core.c                           |  3 +-
 net/netfilter/ipvs/ip_vs_core.c                | 32 ++++++------------
 security/selinux/hooks.c                       | 28 +++++-----------
 34 files changed, 167 insertions(+), 288 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index aee7ef1..c480c43 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -56,9 +56,7 @@ struct nf_hook_state {
 
 typedef unsigned int nf_hookfn(const struct nf_hook_ops *ops,
 			       struct sk_buff *skb,
-			       const struct net_device *in,
-			       const struct net_device *out,
-			       int (*okfn)(struct sk_buff *));
+			       const struct nf_hook_state *state);
 
 struct nf_hook_ops {
 	struct list_head list;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index f3884a1..7527e94 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -562,9 +562,7 @@ bad:
  * to ip6tables, which doesn't support NAT, so things are fairly simple. */
 static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
 					   struct sk_buff *skb,
-					   const struct net_device *in,
-					   const struct net_device *out,
-					   int (*okfn)(struct sk_buff *))
+					   const struct nf_hook_state *state)
 {
 	const struct ipv6hdr *hdr;
 	u32 pkt_len;
@@ -612,9 +610,7 @@ static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
  * address to be able to detect DNAT afterwards. */
 static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+				      const struct nf_hook_state *state)
 {
 	struct net_bridge_port *p;
 	struct net_bridge *br;
@@ -623,7 +619,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 	if (unlikely(!pskb_may_pull(skb, len)))
 		return NF_DROP;
 
-	p = br_port_get_rcu(in);
+	p = br_port_get_rcu(state->in);
 	if (p == NULL)
 		return NF_DROP;
 	br = p->br;
@@ -633,7 +629,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 			return NF_ACCEPT;
 
 		nf_bridge_pull_encap_header_rcsum(skb);
-		return br_nf_pre_routing_ipv6(ops, skb, in, out, okfn);
+		return br_nf_pre_routing_ipv6(ops, skb, state);
 	}
 
 	if (!brnf_call_iptables && !br->nf_call_iptables)
@@ -671,9 +667,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
  * prevent this from happening. */
 static unsigned int br_nf_local_in(const struct nf_hook_ops *ops,
 				   struct sk_buff *skb,
-				   const struct net_device *in,
-				   const struct net_device *out,
-				   int (*okfn)(struct sk_buff *))
+				   const struct nf_hook_state *state)
 {
 	br_drop_fake_rtable(skb);
 	return NF_ACCEPT;
@@ -710,9 +704,7 @@ static int br_nf_forward_finish(struct sk_buff *skb)
  * bridge ports. */
 static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 				     struct sk_buff *skb,
-				     const struct net_device *in,
-				     const struct net_device *out,
-				     int (*okfn)(struct sk_buff *))
+				     const struct nf_hook_state *state)
 {
 	struct nf_bridge_info *nf_bridge;
 	struct net_device *parent;
@@ -726,7 +718,7 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	if (!nf_bridge_unshare(skb))
 		return NF_DROP;
 
-	parent = bridge_parent(out);
+	parent = bridge_parent(state->out);
 	if (!parent)
 		return NF_DROP;
 
@@ -754,23 +746,21 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	else
 		skb->protocol = htons(ETH_P_IPV6);
 
-	NF_HOOK(pf, NF_INET_FORWARD, skb, brnf_get_logical_dev(skb, in), parent,
-		br_nf_forward_finish);
+	NF_HOOK(pf, NF_INET_FORWARD, skb, brnf_get_logical_dev(skb, state->in),
+		parent,	br_nf_forward_finish);
 
 	return NF_STOLEN;
 }
 
 static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+				      const struct nf_hook_state *state)
 {
 	struct net_bridge_port *p;
 	struct net_bridge *br;
 	struct net_device **d = (struct net_device **)(skb->cb);
 
-	p = br_port_get_rcu(out);
+	p = br_port_get_rcu(state->out);
 	if (p == NULL)
 		return NF_ACCEPT;
 	br = p->br;
@@ -789,9 +779,9 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 			nf_bridge_push_encap_header(skb);
 		return NF_ACCEPT;
 	}
-	*d = (struct net_device *)in;
-	NF_HOOK(NFPROTO_ARP, NF_ARP_FORWARD, skb, (struct net_device *)in,
-		(struct net_device *)out, br_nf_forward_finish);
+	*d = state->in;
+	NF_HOOK(NFPROTO_ARP, NF_ARP_FORWARD, skb, state->in,
+		state->out, br_nf_forward_finish);
 
 	return NF_STOLEN;
 }
@@ -859,9 +849,7 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 /* PF_BRIDGE/POST_ROUTING ********************************************/
 static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
+				       const struct nf_hook_state *state)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct net_device *realoutdev = bridge_parent(skb->dev);
@@ -910,9 +898,7 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
  * for the second time. */
 static unsigned int ip_sabotage_in(const struct nf_hook_ops *ops,
 				   struct sk_buff *skb,
-				   const struct net_device *in,
-				   const struct net_device *out,
-				   int (*okfn)(struct sk_buff *))
+				   const struct nf_hook_state *state)
 {
 	if (skb->nf_bridge &&
 	    !(skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)) {
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index ce205aa..8a3f63b 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -58,20 +58,18 @@ static const struct ebt_table frame_filter = {
 
 static unsigned int
 ebt_in_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
-	    const struct net_device *in, const struct net_device *out,
-	    int (*okfn)(struct sk_buff *))
+	    const struct nf_hook_state *state)
 {
-	return ebt_do_table(ops->hooknum, skb, in, out,
-			    dev_net(in)->xt.frame_filter);
+	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
+			    dev_net(state->in)->xt.frame_filter);
 }
 
 static unsigned int
 ebt_out_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
-	     const struct net_device *in, const struct net_device *out,
-	     int (*okfn)(struct sk_buff *))
+	     const struct nf_hook_state *state)
 {
-	return ebt_do_table(ops->hooknum, skb, in, out,
-			    dev_net(out)->xt.frame_filter);
+	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
+			    dev_net(state->out)->xt.frame_filter);
 }
 
 static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index a0ac298..c5ef5b1 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -58,20 +58,18 @@ static struct ebt_table frame_nat = {
 
 static unsigned int
 ebt_nat_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
-	   const struct net_device *in, const struct net_device *out,
-	   int (*okfn)(struct sk_buff *))
+	   const struct nf_hook_state *state)
 {
-	return ebt_do_table(ops->hooknum, skb, in, out,
-			    dev_net(in)->xt.frame_nat);
+	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
+			    dev_net(state->in)->xt.frame_nat);
 }
 
 static unsigned int
 ebt_nat_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
-	    const struct net_device *in, const struct net_device *out,
-	    int (*okfn)(struct sk_buff *))
+	    const struct nf_hook_state *state)
 {
-	return ebt_do_table(ops->hooknum, skb, in, out,
-			    dev_net(out)->xt.frame_nat);
+	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
+			    dev_net(state->out)->xt.frame_nat);
 }
 
 static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 19473a9..2c46a47 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -93,21 +93,19 @@ static inline void nft_bridge_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 static unsigned int
 nft_do_chain_bridge(const struct nf_hook_ops *ops,
 		    struct sk_buff *skb,
-		    const struct net_device *in,
-		    const struct net_device *out,
-		    int (*okfn)(struct sk_buff *))
+		    const struct nf_hook_state *state)
 {
 	struct nft_pktinfo pkt;
 
 	switch (eth_hdr(skb)->h_proto) {
 	case htons(ETH_P_IP):
-		nft_bridge_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
+		nft_bridge_set_pktinfo_ipv4(&pkt, ops, skb, state->in, state->out);
 		break;
 	case htons(ETH_P_IPV6):
-		nft_bridge_set_pktinfo_ipv6(&pkt, ops, skb, in, out);
+		nft_bridge_set_pktinfo_ipv6(&pkt, ops, skb, state->in, state->out);
 		break;
 	default:
-		nft_set_pktinfo(&pkt, ops, skb, in, out);
+		nft_set_pktinfo(&pkt, ops, skb, state->in, state->out);
 		break;
 	}
 
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index e4d9560..af34fc9 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -89,9 +89,7 @@ static void dnrmg_send_peer(struct sk_buff *skb)
 
 static unsigned int dnrmg_hook(const struct nf_hook_ops *ops,
 			struct sk_buff *skb,
-			const struct net_device *in,
-			const struct net_device *out,
-			int (*okfn)(struct sk_buff *))
+			const struct nf_hook_state *state)
 {
 	dnrmg_send_peer(skb);
 	return NF_ACCEPT;
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 802ddec..6a641cb 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -28,12 +28,11 @@ static const struct xt_table packet_filter = {
 /* The work comes in here from netfilter.c */
 static unsigned int
 arptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		     const struct net_device *in, const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     const struct nf_hook_state *state)
 {
-	const struct net *net = dev_net((in != NULL) ? in : out);
+	const struct net *net = dev_net(state->in ? state->in : state->out);
 
-	return arpt_do_table(skb, ops->hooknum, in, out,
+	return arpt_do_table(skb, ops->hooknum, state->in, state->out,
 			     net->ipv4.arptable_filter);
 }
 
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index f75e9df..771ab3d 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -504,14 +504,12 @@ static void arp_print(struct arp_payload *payload)
 static unsigned int
 arp_mangle(const struct nf_hook_ops *ops,
 	   struct sk_buff *skb,
-	   const struct net_device *in,
-	   const struct net_device *out,
-	   int (*okfn)(struct sk_buff *))
+	   const struct nf_hook_state *state)
 {
 	struct arphdr *arp = arp_hdr(skb);
 	struct arp_payload *payload;
 	struct clusterip_config *c;
-	struct net *net = dev_net(in ? in : out);
+	struct net *net = dev_net(state->in ? state->in : state->out);
 
 	/* we don't care about non-ethernet and non-ipv4 ARP */
 	if (arp->ar_hrd != htons(ARPHRD_ETHER) ||
@@ -536,10 +534,10 @@ arp_mangle(const struct nf_hook_ops *ops,
 	 * addresses on different interfacs.  However, in the CLUSTERIP case
 	 * this wouldn't work, since we didn't subscribe the mcast group on
 	 * other interfaces */
-	if (c->dev != out) {
+	if (c->dev != state->out) {
 		pr_debug("not mangling arp reply on different "
 			 "interface: cip'%s'-skb'%s'\n",
-			 c->dev->name, out->name);
+			 c->dev->name, state->out->name);
 		clusterip_config_put(c);
 		return NF_ACCEPT;
 	}
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index a313c3f..e9e6779 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -300,11 +300,9 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 
 static unsigned int ipv4_synproxy_hook(const struct nf_hook_ops *ops,
 				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
+				       const struct nf_hook_state *nhs)
 {
-	struct synproxy_net *snet = synproxy_pernet(dev_net(in ? : out));
+	struct synproxy_net *snet = synproxy_pernet(dev_net(nhs->in ? : nhs->out));
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
 	struct nf_conn_synproxy *synproxy;
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index e08a74a..1df0d42 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -34,8 +34,7 @@ static const struct xt_table packet_filter = {
 
 static unsigned int
 iptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		    const struct net_device *in, const struct net_device *out,
-		    int (*okfn)(struct sk_buff *))
+		    const struct nf_hook_state *state)
 {
 	const struct net *net;
 
@@ -45,8 +44,8 @@ iptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		/* root is playing with raw sockets. */
 		return NF_ACCEPT;
 
-	net = dev_net((in != NULL) ? in : out);
-	return ipt_do_table(skb, ops->hooknum, in, out,
+	net = dev_net(state->in ? state->in : state->out);
+	return ipt_do_table(skb, ops->hooknum, state->in, state->out,
 			    net->ipv4.iptable_filter);
 }
 
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 6a5079c..7a825e7 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -81,18 +81,16 @@ ipt_mangle_out(struct sk_buff *skb, const struct net_device *out)
 static unsigned int
 iptable_mangle_hook(const struct nf_hook_ops *ops,
 		     struct sk_buff *skb,
-		     const struct net_device *in,
-		     const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     const struct nf_hook_state *state)
 {
 	if (ops->hooknum == NF_INET_LOCAL_OUT)
-		return ipt_mangle_out(skb, out);
+		return ipt_mangle_out(skb, state->out);
 	if (ops->hooknum == NF_INET_POST_ROUTING)
-		return ipt_do_table(skb, ops->hooknum, in, out,
-				    dev_net(out)->ipv4.iptable_mangle);
+		return ipt_do_table(skb, ops->hooknum, state->in, state->out,
+				    dev_net(state->out)->ipv4.iptable_mangle);
 	/* PREROUTING/INPUT/FORWARD: */
-	return ipt_do_table(skb, ops->hooknum, in, out,
-			    dev_net(in)->ipv4.iptable_mangle);
+	return ipt_do_table(skb, ops->hooknum, state->in, state->out,
+			    dev_net(state->in)->ipv4.iptable_mangle);
 }
 
 static struct nf_hook_ops *mangle_ops __read_mostly;
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 6b67d7e..7a7fea4 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -41,38 +41,34 @@ static unsigned int iptable_nat_do_chain(const struct nf_hook_ops *ops,
 
 static unsigned int iptable_nat_ipv4_fn(const struct nf_hook_ops *ops,
 					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
-					int (*okfn)(struct sk_buff *))
+					const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_fn(ops, skb, in, out, iptable_nat_do_chain);
+	return nf_nat_ipv4_fn(ops, skb, state->in, state->out,
+			      iptable_nat_do_chain);
 }
 
 static unsigned int iptable_nat_ipv4_in(const struct nf_hook_ops *ops,
 					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
-					int (*okfn)(struct sk_buff *))
+					const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_in(ops, skb, in, out, iptable_nat_do_chain);
+	return nf_nat_ipv4_in(ops, skb, state->in, state->out,
+			      iptable_nat_do_chain);
 }
 
 static unsigned int iptable_nat_ipv4_out(const struct nf_hook_ops *ops,
 					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
-					 int (*okfn)(struct sk_buff *))
+					 const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_out(ops, skb, in, out, iptable_nat_do_chain);
+	return nf_nat_ipv4_out(ops, skb, state->in, state->out,
+			       iptable_nat_do_chain);
 }
 
 static unsigned int iptable_nat_ipv4_local_fn(const struct nf_hook_ops *ops,
 					      struct sk_buff *skb,
-					      const struct net_device *in,
-					      const struct net_device *out,
-					      int (*okfn)(struct sk_buff *))
+					      const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_local_fn(ops, skb, in, out, iptable_nat_do_chain);
+	return nf_nat_ipv4_local_fn(ops, skb, state->in, state->out,
+				    iptable_nat_do_chain);
 }
 
 static struct nf_hook_ops nf_nat_ipv4_ops[] __read_mostly = {
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index b2f7e8f..fac8f60 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -21,8 +21,7 @@ static const struct xt_table packet_raw = {
 /* The work comes in here from netfilter.c. */
 static unsigned int
 iptable_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		 const struct net_device *in, const struct net_device *out,
-		 int (*okfn)(struct sk_buff *))
+		 const struct nf_hook_state *state)
 {
 	const struct net *net;
 
@@ -32,8 +31,9 @@ iptable_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		/* root is playing with raw sockets. */
 		return NF_ACCEPT;
 
-	net = dev_net((in != NULL) ? in : out);
-	return ipt_do_table(skb, ops->hooknum, in, out, net->ipv4.iptable_raw);
+	net = dev_net(state->in ? state->in : state->out);
+	return ipt_do_table(skb, ops->hooknum, state->in, state->out,
+			    net->ipv4.iptable_raw);
 }
 
 static struct nf_hook_ops *rawtable_ops __read_mostly;
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index c86647e..d9ad60a 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -38,9 +38,7 @@ static const struct xt_table security_table = {
 
 static unsigned int
 iptable_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		      const struct net_device *in,
-		      const struct net_device *out,
-		      int (*okfn)(struct sk_buff *))
+		      const struct nf_hook_state *state)
 {
 	const struct net *net;
 
@@ -50,8 +48,8 @@ iptable_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		/* Somebody is playing with raw sockets. */
 		return NF_ACCEPT;
 
-	net = dev_net((in != NULL) ? in : out);
-	return ipt_do_table(skb, ops->hooknum, in, out,
+	net = dev_net(state->in ? state->in : state->out);
+	return ipt_do_table(skb, ops->hooknum, state->in, state->out,
 			    net->ipv4.iptable_security);
 }
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 8c8d664..30ad955 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -94,9 +94,7 @@ static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 
 static unsigned int ipv4_helper(const struct nf_hook_ops *ops,
 				struct sk_buff *skb,
-				const struct net_device *in,
-				const struct net_device *out,
-				int (*okfn)(struct sk_buff *))
+				const struct nf_hook_state *state)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -123,9 +121,7 @@ static unsigned int ipv4_helper(const struct nf_hook_ops *ops,
 
 static unsigned int ipv4_confirm(const struct nf_hook_ops *ops,
 				 struct sk_buff *skb,
-				 const struct net_device *in,
-				 const struct net_device *out,
-				 int (*okfn)(struct sk_buff *))
+				 const struct nf_hook_state *state)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -149,24 +145,20 @@ out:
 
 static unsigned int ipv4_conntrack_in(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+				      const struct nf_hook_state *state)
 {
-	return nf_conntrack_in(dev_net(in), PF_INET, ops->hooknum, skb);
+	return nf_conntrack_in(dev_net(state->in), PF_INET, ops->hooknum, skb);
 }
 
 static unsigned int ipv4_conntrack_local(const struct nf_hook_ops *ops,
 					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
-					 int (*okfn)(struct sk_buff *))
+					 const struct nf_hook_state *state)
 {
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
-	return nf_conntrack_in(dev_net(out), PF_INET, ops->hooknum, skb);
+	return nf_conntrack_in(dev_net(state->out), PF_INET, ops->hooknum, skb);
 }
 
 /* Connection tracking may drop packets, but never alters them, so
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 7e5ca6f..c88b7d4 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -63,9 +63,7 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 
 static unsigned int ipv4_conntrack_defrag(const struct nf_hook_ops *ops,
 					  struct sk_buff *skb,
-					  const struct net_device *in,
-					  const struct net_device *out,
-					  int (*okfn)(struct sk_buff *))
+					  const struct nf_hook_state *state)
 {
 	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(skb->sk);
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 19412a4..fceb50e 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -17,13 +17,11 @@
 static unsigned int
 nft_do_chain_arp(const struct nf_hook_ops *ops,
 		  struct sk_buff *skb,
-		  const struct net_device *in,
-		  const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
+		  const struct nf_hook_state *state)
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo(&pkt, ops, skb, in, out);
+	nft_set_pktinfo(&pkt, ops, skb, state->in, state->out);
 
 	return nft_do_chain(&pkt, ops);
 }
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index 6820c8c..708e388 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -20,22 +20,18 @@
 
 static unsigned int nft_do_chain_ipv4(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+				      const struct nf_hook_state *state)
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
+	nft_set_pktinfo_ipv4(&pkt, ops, skb, state->in, state->out);
 
 	return nft_do_chain(&pkt, ops);
 }
 
 static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
-				    const struct net_device *in,
-				    const struct net_device *out,
-				    int (*okfn)(struct sk_buff *))
+				    const struct nf_hook_state *state)
 {
 	if (unlikely(skb->len < sizeof(struct iphdr) ||
 		     ip_hdr(skb)->ihl < sizeof(struct iphdr) / 4)) {
@@ -45,7 +41,7 @@ static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 	}
 
-	return nft_do_chain_ipv4(ops, skb, in, out, okfn);
+	return nft_do_chain_ipv4(ops, skb, state);
 }
 
 struct nft_af_info nft_af_ipv4 __read_mostly = {
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index df547bf..d08db6b 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -41,38 +41,31 @@ static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
 
 static unsigned int nft_nat_ipv4_fn(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
-				    const struct net_device *in,
-				    const struct net_device *out,
-				    int (*okfn)(struct sk_buff *))
+				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_fn(ops, skb, in, out, nft_nat_do_chain);
+	return nf_nat_ipv4_fn(ops, skb, state->in, state->out, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv4_in(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
-				    const struct net_device *in,
-				    const struct net_device *out,
-				    int (*okfn)(struct sk_buff *))
+				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_in(ops, skb, in, out, nft_nat_do_chain);
+	return nf_nat_ipv4_in(ops, skb, state->in, state->out, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv4_out(const struct nf_hook_ops *ops,
 				     struct sk_buff *skb,
-				     const struct net_device *in,
-				     const struct net_device *out,
-				     int (*okfn)(struct sk_buff *))
+				     const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_out(ops, skb, in, out, nft_nat_do_chain);
+	return nf_nat_ipv4_out(ops, skb, state->in, state->out, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv4_local_fn(const struct nf_hook_ops *ops,
 					  struct sk_buff *skb,
-					  const struct net_device *in,
-					  const struct net_device *out,
-					  int (*okfn)(struct sk_buff *))
+					  const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_local_fn(ops, skb, in, out, nft_nat_do_chain);
+	return nf_nat_ipv4_local_fn(ops, skb, state->in, state->out,
+				    nft_nat_do_chain);
 }
 
 static const struct nf_chain_type nft_chain_nat_ipv4 = {
diff --git a/net/ipv4/netfilter/nft_chain_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
index 125b667..073d077 100644
--- a/net/ipv4/netfilter/nft_chain_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -23,9 +23,7 @@
 
 static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
-					int (*okfn)(struct sk_buff *))
+					const struct nf_hook_state *state)
 {
 	unsigned int ret;
 	struct nft_pktinfo pkt;
@@ -39,7 +37,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
+	nft_set_pktinfo_ipv4(&pkt, ops, skb, state->in, state->out);
 
 	mark = skb->mark;
 	iph = ip_hdr(skb);
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index a0d1727..6edb7b1 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -315,11 +315,9 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 
 static unsigned int ipv6_synproxy_hook(const struct nf_hook_ops *ops,
 				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
+				       const struct nf_hook_state *nhs)
 {
-	struct synproxy_net *snet = synproxy_pernet(dev_net(in ? : out));
+	struct synproxy_net *snet = synproxy_pernet(dev_net(nhs->in ? : nhs->out));
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
 	struct nf_conn_synproxy *synproxy;
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index ca7f6c1..eb9ef09 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -33,12 +33,11 @@ static const struct xt_table packet_filter = {
 /* The work comes in here from netfilter.c. */
 static unsigned int
 ip6table_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		     const struct net_device *in, const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     const struct nf_hook_state *state)
 {
-	const struct net *net = dev_net((in != NULL) ? in : out);
+	const struct net *net = dev_net(state->in ? state->in : state->out);
 
-	return ip6t_do_table(skb, ops->hooknum, in, out,
+	return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
 			     net->ipv6.ip6table_filter);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 307bbb7..e713b8d 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -77,17 +77,16 @@ ip6t_mangle_out(struct sk_buff *skb, const struct net_device *out)
 /* The work comes in here from netfilter.c. */
 static unsigned int
 ip6table_mangle_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		     const struct net_device *in, const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     const struct nf_hook_state *state)
 {
 	if (ops->hooknum == NF_INET_LOCAL_OUT)
-		return ip6t_mangle_out(skb, out);
+		return ip6t_mangle_out(skb, state->out);
 	if (ops->hooknum == NF_INET_POST_ROUTING)
-		return ip6t_do_table(skb, ops->hooknum, in, out,
-				     dev_net(out)->ipv6.ip6table_mangle);
+		return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
+				     dev_net(state->out)->ipv6.ip6table_mangle);
 	/* INPUT/FORWARD */
-	return ip6t_do_table(skb, ops->hooknum, in, out,
-			     dev_net(in)->ipv6.ip6table_mangle);
+	return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
+			     dev_net(state->in)->ipv6.ip6table_mangle);
 }
 
 static struct nf_hook_ops *mangle_ops __read_mostly;
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index b0634ac..e32b0d0 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -43,38 +43,34 @@ static unsigned int ip6table_nat_do_chain(const struct nf_hook_ops *ops,
 
 static unsigned int ip6table_nat_fn(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
-				    const struct net_device *in,
-				    const struct net_device *out,
-				    int (*okfn)(struct sk_buff *))
+				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_fn(ops, skb, in, out, ip6table_nat_do_chain);
+	return nf_nat_ipv6_fn(ops, skb, state->in, state->out,
+			      ip6table_nat_do_chain);
 }
 
 static unsigned int ip6table_nat_in(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
-				    const struct net_device *in,
-				    const struct net_device *out,
-				    int (*okfn)(struct sk_buff *))
+				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_in(ops, skb, in, out, ip6table_nat_do_chain);
+	return nf_nat_ipv6_in(ops, skb, state->in, state->out,
+			      ip6table_nat_do_chain);
 }
 
 static unsigned int ip6table_nat_out(const struct nf_hook_ops *ops,
 				     struct sk_buff *skb,
-				     const struct net_device *in,
-				     const struct net_device *out,
-				     int (*okfn)(struct sk_buff *))
+				     const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_out(ops, skb, in, out, ip6table_nat_do_chain);
+	return nf_nat_ipv6_out(ops, skb, state->in, state->out,
+			       ip6table_nat_do_chain);
 }
 
 static unsigned int ip6table_nat_local_fn(const struct nf_hook_ops *ops,
 					  struct sk_buff *skb,
-					  const struct net_device *in,
-					  const struct net_device *out,
-					  int (*okfn)(struct sk_buff *))
+					  const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_local_fn(ops, skb, in, out, ip6table_nat_do_chain);
+	return nf_nat_ipv6_local_fn(ops, skb, state->in, state->out,
+				    ip6table_nat_do_chain);
 }
 
 static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 5274740..937908e 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -20,12 +20,11 @@ static const struct xt_table packet_raw = {
 /* The work comes in here from netfilter.c. */
 static unsigned int
 ip6table_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		  const struct net_device *in, const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
+		  const struct nf_hook_state *state)
 {
-	const struct net *net = dev_net((in != NULL) ? in : out);
+	const struct net *net = dev_net(state->in ? state->in : state->out);
 
-	return ip6t_do_table(skb, ops->hooknum, in, out,
+	return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
 			     net->ipv6.ip6table_raw);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index ab3b021..f33b41e 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -37,13 +37,11 @@ static const struct xt_table security_table = {
 
 static unsigned int
 ip6table_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		       const struct net_device *in,
-		       const struct net_device *out,
-		       int (*okfn)(struct sk_buff *))
+		       const struct nf_hook_state *state)
 {
-	const struct net *net = dev_net((in != NULL) ? in : out);
+	const struct net *net = dev_net(state->in ? state->in : state->out);
 
-	return ip6t_do_table(skb, ops->hooknum, in, out,
+	return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
 			     net->ipv6.ip6table_security);
 }
 
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index fba91c6..4ba0c34 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -97,9 +97,7 @@ static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 
 static unsigned int ipv6_helper(const struct nf_hook_ops *ops,
 				struct sk_buff *skb,
-				const struct net_device *in,
-				const struct net_device *out,
-				int (*okfn)(struct sk_buff *))
+				const struct nf_hook_state *state)
 {
 	struct nf_conn *ct;
 	const struct nf_conn_help *help;
@@ -135,9 +133,7 @@ static unsigned int ipv6_helper(const struct nf_hook_ops *ops,
 
 static unsigned int ipv6_confirm(const struct nf_hook_ops *ops,
 				 struct sk_buff *skb,
-				 const struct net_device *in,
-				 const struct net_device *out,
-				 int (*okfn)(struct sk_buff *))
+				 const struct nf_hook_state *state)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -171,25 +167,21 @@ out:
 
 static unsigned int ipv6_conntrack_in(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+				      const struct nf_hook_state *state)
 {
-	return nf_conntrack_in(dev_net(in), PF_INET6, ops->hooknum, skb);
+	return nf_conntrack_in(dev_net(state->in), PF_INET6, ops->hooknum, skb);
 }
 
 static unsigned int ipv6_conntrack_local(const struct nf_hook_ops *ops,
 					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
-					 int (*okfn)(struct sk_buff *))
+					 const struct nf_hook_state *state)
 {
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct ipv6hdr)) {
 		net_notice_ratelimited("ipv6_conntrack_local: packet too short\n");
 		return NF_ACCEPT;
 	}
-	return nf_conntrack_in(dev_net(out), PF_INET6, ops->hooknum, skb);
+	return nf_conntrack_in(dev_net(state->out), PF_INET6, ops->hooknum, skb);
 }
 
 static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index e70382e..e2b8820 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -54,9 +54,7 @@ static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 
 static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
 				struct sk_buff *skb,
-				const struct net_device *in,
-				const struct net_device *out,
-				int (*okfn)(struct sk_buff *))
+				const struct nf_hook_state *state)
 {
 	struct sk_buff *reasm;
 
@@ -78,8 +76,8 @@ static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
 	nf_ct_frag6_consume_orig(reasm);
 
 	NF_HOOK_THRESH(NFPROTO_IPV6, ops->hooknum, reasm,
-		       (struct net_device *) in, (struct net_device *) out,
-		       okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
+		       state->in, state->out,
+		       state->okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
 
 	return NF_STOLEN;
 }
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 0d812b3..224bc89 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -18,14 +18,12 @@
 
 static unsigned int nft_do_chain_ipv6(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+				      const struct nf_hook_state *state)
 {
 	struct nft_pktinfo pkt;
 
 	/* malformed packet, drop it */
-	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out) < 0)
+	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, state->in, state->out) < 0)
 		return NF_DROP;
 
 	return nft_do_chain(&pkt, ops);
@@ -33,9 +31,7 @@ static unsigned int nft_do_chain_ipv6(const struct nf_hook_ops *ops,
 
 static unsigned int nft_ipv6_output(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
-				    const struct net_device *in,
-				    const struct net_device *out,
-				    int (*okfn)(struct sk_buff *))
+				    const struct nf_hook_state *state)
 {
 	if (unlikely(skb->len < sizeof(struct ipv6hdr))) {
 		if (net_ratelimit())
@@ -44,7 +40,7 @@ static unsigned int nft_ipv6_output(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 	}
 
-	return nft_do_chain_ipv6(ops, skb, in, out, okfn);
+	return nft_do_chain_ipv6(ops, skb, state);
 }
 
 struct nft_af_info nft_af_ipv6 __read_mostly = {
diff --git a/net/ipv6/netfilter/nft_chain_nat_ipv6.c b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
index 1c4b75d..f73f4ae 100644
--- a/net/ipv6/netfilter/nft_chain_nat_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
@@ -39,38 +39,30 @@ static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
 
 static unsigned int nft_nat_ipv6_fn(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
-				    const struct net_device *in,
-				    const struct net_device *out,
-				    int (*okfn)(struct sk_buff *))
+				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_fn(ops, skb, in, out, nft_nat_do_chain);
+	return nf_nat_ipv6_fn(ops, skb, state->in, state->out, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv6_in(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
-				    const struct net_device *in,
-				    const struct net_device *out,
-				    int (*okfn)(struct sk_buff *))
+				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_in(ops, skb, in, out, nft_nat_do_chain);
+	return nf_nat_ipv6_in(ops, skb, state->in, state->out, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv6_out(const struct nf_hook_ops *ops,
 				     struct sk_buff *skb,
-				     const struct net_device *in,
-				     const struct net_device *out,
-				     int (*okfn)(struct sk_buff *))
+				     const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_out(ops, skb, in, out, nft_nat_do_chain);
+	return nf_nat_ipv6_out(ops, skb, state->in, state->out, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv6_local_fn(const struct nf_hook_ops *ops,
 					  struct sk_buff *skb,
-					  const struct net_device *in,
-					  const struct net_device *out,
-					  int (*okfn)(struct sk_buff *))
+					  const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_local_fn(ops, skb, in, out, nft_nat_do_chain);
+	return nf_nat_ipv6_local_fn(ops, skb, state->in, state->out, nft_nat_do_chain);
 }
 
 static const struct nf_chain_type nft_chain_nat_ipv6 = {
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index 4203129..c826c3c 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -24,9 +24,7 @@
 
 static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
-					int (*okfn)(struct sk_buff *))
+					const struct nf_hook_state *state)
 {
 	unsigned int ret;
 	struct nft_pktinfo pkt;
@@ -35,7 +33,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	u32 mark, flowlabel;
 
 	/* malformed packet, drop it */
-	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out) < 0)
+	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, state->in, state->out) < 0)
 		return NF_DROP;
 
 	/* save source/dest address, mark, hoplimit, flowlabel, priority */
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 11d04eb..e616301 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -136,8 +136,7 @@ unsigned int nf_iterate(struct list_head *head,
 		/* Optimization: we don't need to hold module
 		   reference here, since function can't sleep. --RR */
 repeat:
-		verdict = (*elemp)->hook(*elemp, skb, state->in, state->out,
-					 state->okfn);
+		verdict = (*elemp)->hook(*elemp, skb, state);
 		if (verdict != NF_ACCEPT) {
 #ifdef CONFIG_NETFILTER_DEBUG
 			if (unlikely((verdict & NF_VERDICT_MASK)
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 04dbd9c..5d2b806 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1272,8 +1272,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
  */
 static unsigned int
 ip_vs_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
-	     const struct net_device *in, const struct net_device *out,
-	     int (*okfn)(struct sk_buff *))
+	     const struct nf_hook_state *state)
 {
 	return ip_vs_out(ops->hooknum, skb, AF_INET);
 }
@@ -1284,8 +1283,7 @@ ip_vs_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  */
 static unsigned int
 ip_vs_local_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		   const struct net_device *in, const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
+		   const struct nf_hook_state *state)
 {
 	return ip_vs_out(ops->hooknum, skb, AF_INET);
 }
@@ -1299,8 +1297,7 @@ ip_vs_local_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  */
 static unsigned int
 ip_vs_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
-	     const struct net_device *in, const struct net_device *out,
-	     int (*okfn)(struct sk_buff *))
+	     const struct nf_hook_state *state)
 {
 	return ip_vs_out(ops->hooknum, skb, AF_INET6);
 }
@@ -1311,8 +1308,7 @@ ip_vs_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
  */
 static unsigned int
 ip_vs_local_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		   const struct net_device *in, const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
+		   const struct nf_hook_state *state)
 {
 	return ip_vs_out(ops->hooknum, skb, AF_INET6);
 }
@@ -1769,9 +1765,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
  */
 static unsigned int
 ip_vs_remote_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		      const struct net_device *in,
-		      const struct net_device *out,
-		      int (*okfn)(struct sk_buff *))
+		      const struct nf_hook_state *state)
 {
 	return ip_vs_in(ops->hooknum, skb, AF_INET);
 }
@@ -1782,8 +1776,7 @@ ip_vs_remote_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  */
 static unsigned int
 ip_vs_local_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		     const struct net_device *in, const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     const struct nf_hook_state *state)
 {
 	return ip_vs_in(ops->hooknum, skb, AF_INET);
 }
@@ -1796,9 +1789,7 @@ ip_vs_local_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  */
 static unsigned int
 ip_vs_remote_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		      const struct net_device *in,
-		      const struct net_device *out,
-		      int (*okfn)(struct sk_buff *))
+		      const struct nf_hook_state *state)
 {
 	return ip_vs_in(ops->hooknum, skb, AF_INET6);
 }
@@ -1809,8 +1800,7 @@ ip_vs_remote_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
  */
 static unsigned int
 ip_vs_local_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		     const struct net_device *in, const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     const struct nf_hook_state *state)
 {
 	return ip_vs_in(ops->hooknum, skb, AF_INET6);
 }
@@ -1829,8 +1819,7 @@ ip_vs_local_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
  */
 static unsigned int
 ip_vs_forward_icmp(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		   const struct net_device *in, const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
+		   const struct nf_hook_state *state)
 {
 	int r;
 	struct net *net;
@@ -1851,8 +1840,7 @@ ip_vs_forward_icmp(const struct nf_hook_ops *ops, struct sk_buff *skb,
 #ifdef CONFIG_IP_VS_IPV6
 static unsigned int
 ip_vs_forward_icmp_v6(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		      const struct net_device *in, const struct net_device *out,
-		      int (*okfn)(struct sk_buff *))
+		      const struct nf_hook_state *state)
 {
 	int r;
 	struct net *net;
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index edc66de..7e392ed 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4852,21 +4852,17 @@ static unsigned int selinux_ip_forward(struct sk_buff *skb,
 
 static unsigned int selinux_ipv4_forward(const struct nf_hook_ops *ops,
 					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
-					 int (*okfn)(struct sk_buff *))
+					 const struct nf_hook_state *state)
 {
-	return selinux_ip_forward(skb, in, PF_INET);
+	return selinux_ip_forward(skb, state->in, PF_INET);
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static unsigned int selinux_ipv6_forward(const struct nf_hook_ops *ops,
 					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
-					 int (*okfn)(struct sk_buff *))
+					 const struct nf_hook_state *state)
 {
-	return selinux_ip_forward(skb, in, PF_INET6);
+	return selinux_ip_forward(skb, state->in, PF_INET6);
 }
 #endif	/* IPV6 */
 
@@ -4914,9 +4910,7 @@ static unsigned int selinux_ip_output(struct sk_buff *skb,
 
 static unsigned int selinux_ipv4_output(const struct nf_hook_ops *ops,
 					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
-					int (*okfn)(struct sk_buff *))
+					const struct nf_hook_state *state)
 {
 	return selinux_ip_output(skb, PF_INET);
 }
@@ -5091,21 +5085,17 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb,
 
 static unsigned int selinux_ipv4_postroute(const struct nf_hook_ops *ops,
 					   struct sk_buff *skb,
-					   const struct net_device *in,
-					   const struct net_device *out,
-					   int (*okfn)(struct sk_buff *))
+					   const struct nf_hook_state *state)
 {
-	return selinux_ip_postroute(skb, out, PF_INET);
+	return selinux_ip_postroute(skb, state->out, PF_INET);
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static unsigned int selinux_ipv6_postroute(const struct nf_hook_ops *ops,
 					   struct sk_buff *skb,
-					   const struct net_device *in,
-					   const struct net_device *out,
-					   int (*okfn)(struct sk_buff *))
+					   const struct nf_hook_state *state)
 {
-	return selinux_ip_postroute(skb, out, PF_INET6);
+	return selinux_ip_postroute(skb, state->out, PF_INET6);
 }
 #endif	/* IPV6 */
 
-- 
2.1.0

