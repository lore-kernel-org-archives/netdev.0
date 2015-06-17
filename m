From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 42/43] netfilter bridge: Make the sysctl knobs per network namespace
Date: Wed, 17 Jun 2015 10:28:51 -0500
Message-ID: <1434554932-4552-42-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W Biederman <ebiederm@xmission.com>

This patch replaces the global brnf_call_* variables to make them per
network namespace.

Based on an early patch by Pablo Neira Ayuso <pablo@netfilter.org>

Signed-off-by: Eric W Biederman <ebiederm@xmission.com>
---
 include/net/netns/netfilter.h |  11 +++
 net/bridge/br_netfilter.c     | 151 +++++++++++++++++++++++++-----------------
 2 files changed, 103 insertions(+), 59 deletions(-)

diff --git a/include/net/netns/netfilter.h b/include/net/netns/netfilter.h
index 38aa4983e2a9..181b13e1390f 100644
--- a/include/net/netns/netfilter.h
+++ b/include/net/netns/netfilter.h
@@ -15,5 +15,16 @@ struct netns_nf {
 	struct ctl_table_header *nf_log_dir_header;
 #endif
 	struct list_head hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+	int brnf_call_iptables;
+	int brnf_call_ip6tables;
+	int brnf_call_arptables;
+	int brnf_filter_vlan_tagged;
+	int brnf_filter_pppoe_tagged;
+	int brnf_pass_vlan_indev;
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header *brnf_sysctl_header;
+#endif
+#endif
 };
 #endif
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index c6acff3a94ec..33d264b18853 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -44,23 +44,6 @@
 #include <linux/sysctl.h>
 #endif
 
-#ifdef CONFIG_SYSCTL
-static struct ctl_table_header *brnf_sysctl_header;
-static int brnf_call_iptables __read_mostly = 1;
-static int brnf_call_ip6tables __read_mostly = 1;
-static int brnf_call_arptables __read_mostly = 1;
-static int brnf_filter_vlan_tagged __read_mostly = 0;
-static int brnf_filter_pppoe_tagged __read_mostly = 0;
-static int brnf_pass_vlan_indev __read_mostly = 0;
-#else
-#define brnf_call_iptables 1
-#define brnf_call_ip6tables 1
-#define brnf_call_arptables 1
-#define brnf_filter_vlan_tagged 0
-#define brnf_filter_pppoe_tagged 0
-#define brnf_pass_vlan_indev 0
-#endif
-
 #define IS_IP(skb) \
 	(!skb_vlan_tag_present(skb) && skb->protocol == htons(ETH_P_IP))
 
@@ -80,17 +63,17 @@ static inline __be16 vlan_proto(const struct sk_buff *skb)
 		return 0;
 }
 
-#define IS_VLAN_IP(skb) \
+#define IS_VLAN_IP(skb, net) \
 	(vlan_proto(skb) == htons(ETH_P_IP) && \
-	 brnf_filter_vlan_tagged)
+	 net->nf.brnf_filter_vlan_tagged)
 
-#define IS_VLAN_IPV6(skb) \
+#define IS_VLAN_IPV6(skb, net) \
 	(vlan_proto(skb) == htons(ETH_P_IPV6) && \
-	 brnf_filter_vlan_tagged)
+	 net->nf.brnf_filter_vlan_tagged)
 
-#define IS_VLAN_ARP(skb) \
+#define IS_VLAN_ARP(skb, net) \
 	(vlan_proto(skb) == htons(ETH_P_ARP) &&	\
-	 brnf_filter_vlan_tagged)
+	 net->nf.brnf_filter_vlan_tagged)
 
 static inline __be16 pppoe_proto(const struct sk_buff *skb)
 {
@@ -98,15 +81,15 @@ static inline __be16 pppoe_proto(const struct sk_buff *skb)
 			    sizeof(struct pppoe_hdr)));
 }
 
-#define IS_PPPOE_IP(skb) \
+#define IS_PPPOE_IP(skb, net) \
 	(skb->protocol == htons(ETH_P_PPP_SES) && \
 	 pppoe_proto(skb) == htons(PPP_IP) && \
-	 brnf_filter_pppoe_tagged)
+	 net->nf.brnf_filter_pppoe_tagged)
 
-#define IS_PPPOE_IPV6(skb) \
+#define IS_PPPOE_IPV6(skb, net) \
 	(skb->protocol == htons(ETH_P_PPP_SES) && \
 	 pppoe_proto(skb) == htons(PPP_IPV6) && \
-	 brnf_filter_pppoe_tagged)
+	 net->nf.brnf_filter_pppoe_tagged)
 
 /* largest possible L2 header, see br_nf_dev_queue_xmit() */
 #define NF_BRIDGE_MAX_MAC_HEADER_LENGTH (PPPOE_SES_HLEN + ETH_HLEN)
@@ -628,7 +611,8 @@ static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct
 	struct net_device *vlan, *br;
 
 	br = bridge_parent(dev);
-	if (brnf_pass_vlan_indev == 0 || !skb_vlan_tag_present(skb))
+	if (dev_net(dev)->nf.brnf_pass_vlan_indev == 0 ||
+	    !skb_vlan_tag_present(skb))
 		return br;
 
 	vlan = __vlan_find_dev_deep_rcu(br, skb->vlan_proto,
@@ -712,18 +696,23 @@ static unsigned int br_nf_pre_routing(void *priv,
 		return NF_DROP;
 	br = p->br;
 
-	if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb)) {
-		if (!brnf_call_ip6tables && !br->nf_call_ip6tables)
+	if (IS_IPV6(skb) ||
+	    IS_VLAN_IPV6(skb, state->net) ||
+	    IS_PPPOE_IPV6(skb, state->net)) {
+		if (!state->net->nf.brnf_call_ip6tables &&
+		    !br->nf_call_ip6tables)
 			return NF_ACCEPT;
 
 		nf_bridge_pull_encap_header_rcsum(skb);
 		return br_nf_pre_routing_ipv6(skb, state);
 	}
 
-	if (!brnf_call_iptables && !br->nf_call_iptables)
+	if (!state->net->nf.brnf_call_iptables && !br->nf_call_iptables)
 		return NF_ACCEPT;
 
-	if (!IS_IP(skb) && !IS_VLAN_IP(skb) && !IS_PPPOE_IP(skb))
+	if (!IS_IP(skb) &&
+	    !IS_VLAN_IP(skb, state->net) &&
+	    !IS_PPPOE_IP(skb, state->net))
 		return NF_ACCEPT;
 
 	nf_bridge_pull_encap_header_rcsum(skb);
@@ -772,7 +761,7 @@ static int br_nf_forward_finish(struct sock *sk, struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	struct net_device *in;
 
-	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb)) {
+	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb, net)) {
 
 		if (skb->protocol == htons(ETH_P_IP))
 			nf_bridge->frag_max_size = IPCB(skb)->frag_max_size;
@@ -827,9 +816,13 @@ static unsigned int br_nf_forward_ip(void *priv,
 	if (!parent)
 		return NF_DROP;
 
-	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb))
+	if (IS_IP(skb) ||
+	    IS_VLAN_IP(skb, state->net) ||
+	    IS_PPPOE_IP(skb, state->net))
 		pf = NFPROTO_IPV4;
-	else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb))
+	else if (IS_IPV6(skb) ||
+		 IS_VLAN_IPV6(skb, state->net) ||
+		 IS_PPPOE_IPV6(skb, state->net))
 		pf = NFPROTO_IPV6;
 	else
 		return NF_ACCEPT;
@@ -879,17 +872,17 @@ static unsigned int br_nf_forward_arp(void *priv,
 		return NF_ACCEPT;
 	br = p->br;
 
-	if (!brnf_call_arptables && !br->nf_call_arptables)
+	if (!state->net->nf.brnf_call_arptables && !br->nf_call_arptables)
 		return NF_ACCEPT;
 
 	if (!IS_ARP(skb)) {
-		if (!IS_VLAN_ARP(skb))
+		if (!IS_VLAN_ARP(skb, state->net))
 			return NF_ACCEPT;
 		nf_bridge_pull_encap_header(skb);
 	}
 
 	if (arp_hdr(skb)->ar_pln != 4) {
-		if (IS_VLAN_ARP(skb))
+		if (IS_VLAN_ARP(skb, state->net))
 			nf_bridge_push_encap_header(skb);
 		return NF_ACCEPT;
 	}
@@ -1044,9 +1037,13 @@ static unsigned int br_nf_post_routing(void *priv,
 	if (!realoutdev)
 		return NF_DROP;
 
-	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb))
+	if (IS_IP(skb) ||
+	    IS_VLAN_IP(skb, state->net) ||
+	    IS_PPPOE_IP(skb, state->net))
 		pf = NFPROTO_IPV4;
-	else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb))
+	else if (IS_IPV6(skb) ||
+		 IS_VLAN_IPV6(skb, state->net) ||
+		 IS_PPPOE_IPV6(skb, state->net))
 		pf = NFPROTO_IPV6;
 	else
 		return NF_ACCEPT;
@@ -1202,42 +1199,42 @@ int brnf_sysctl_call_tables(struct ctl_table *ctl, int write,
 static struct ctl_table brnf_table[] = {
 	{
 		.procname	= "bridge-nf-call-arptables",
-		.data		= &brnf_call_arptables,
+		.data		= &init_net.nf.brnf_call_arptables,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= brnf_sysctl_call_tables,
 	},
 	{
 		.procname	= "bridge-nf-call-iptables",
-		.data		= &brnf_call_iptables,
+		.data		= &init_net.nf.brnf_call_iptables,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= brnf_sysctl_call_tables,
 	},
 	{
 		.procname	= "bridge-nf-call-ip6tables",
-		.data		= &brnf_call_ip6tables,
+		.data		= &init_net.nf.brnf_call_ip6tables,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= brnf_sysctl_call_tables,
 	},
 	{
 		.procname	= "bridge-nf-filter-vlan-tagged",
-		.data		= &brnf_filter_vlan_tagged,
+		.data		= &init_net.nf.brnf_filter_vlan_tagged,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= brnf_sysctl_call_tables,
 	},
 	{
 		.procname	= "bridge-nf-filter-pppoe-tagged",
-		.data		= &brnf_filter_pppoe_tagged,
+		.data		= &init_net.nf.brnf_filter_pppoe_tagged,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= brnf_sysctl_call_tables,
 	},
 	{
 		.procname	= "bridge-nf-pass-vlan-input-dev",
-		.data		= &brnf_pass_vlan_indev,
+		.data		= &init_net.nf.brnf_pass_vlan_indev,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= brnf_sysctl_call_tables,
@@ -1248,11 +1245,58 @@ static struct ctl_table brnf_table[] = {
 
 static int __net_init br_nf_net_init(struct net *net)
 {
-	return nf_register_hooks(net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
+#ifdef CONFIG_SYSCTL
+	struct ctl_table *table;
+	int i;
+#endif
+	int ret;
+
+	net->nf.brnf_call_arptables      = 1;
+	net->nf.brnf_call_iptables       = 1;
+	net->nf.brnf_call_ip6tables      = 1;
+	net->nf.brnf_filter_vlan_tagged  = 0;
+	net->nf.brnf_filter_pppoe_tagged = 0;
+	net->nf.brnf_pass_vlan_indev     = 0;
+
+	ret = nf_register_hooks(net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	if (ret < 0)
+		goto err_hooks_reg;
+
+#ifdef CONFIG_SYSCTL
+	ret = -ENOMEM;
+	table = kmemdup(brnf_table, sizeof(brnf_table), GFP_KERNEL);
+	if (!table)
+		goto err_sysctl_alloc;
+
+	/* Update the variables to point into the current struct net */
+	for (i = 0; i < ARRAY_SIZE(brnf_table) - 1; i++)
+		table[i].data += (void *)net - (void *)&init_net;
+
+	net->nf.brnf_sysctl_header = register_net_sysctl(net, "net/bridge", table);
+	if (net->nf.brnf_sysctl_header == NULL)
+		goto err_sysctl_reg;
+#endif
+
+	return 0;
+
+#ifdef CONFIG_SYSCTL
+err_sysctl_reg:
+	printk(KERN_WARNING "br_netfiter: can't register to sysctl.\n");
+	kfree(table);
+err_sysctl_alloc:
+	nf_unregister_hooks(net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
+#endif
+err_hooks_reg:
+	return ret;
 }
 
 static void __net_exit br_nf_net_exit(struct net *net)
 {
+#ifdef CONFIG_SYSCTL
+	struct ctl_table *table = net->nf.brnf_sysctl_header->ctl_table_arg;
+	unregister_net_sysctl_table(net->nf.brnf_sysctl_header);
+	kfree(table);
+#endif
 	nf_unregister_hooks(net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
 }
 
@@ -1269,15 +1313,6 @@ static int __init br_netfilter_init(void)
 	if (ret < 0)
 		return ret;
 
-#ifdef CONFIG_SYSCTL
-	brnf_sysctl_header = register_net_sysctl(&init_net, "net/bridge", brnf_table);
-	if (brnf_sysctl_header == NULL) {
-		printk(KERN_WARNING
-		       "br_netfilter: can't register to sysctl.\n");
-		nf_unregister_hooks(&init_net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
-		return -ENOMEM;
-	}
-#endif
 	RCU_INIT_POINTER(nf_br_ops, &br_ops);
 	printk(KERN_NOTICE "Bridge firewalling registered\n");
 	return 0;
@@ -1286,9 +1321,7 @@ static int __init br_netfilter_init(void)
 static void __exit br_netfilter_fini(void)
 {
 	RCU_INIT_POINTER(nf_br_ops, NULL);
-#ifdef CONFIG_SYSCTL
-	unregister_net_sysctl_table(brnf_sysctl_header);
-#endif
+	unregister_pernet_subsys(&br_nf_net_ops);
 }
 
 module_init(br_netfilter_init);
-- 
2.2.1

