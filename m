From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 22/43] netfilter: Add a struct net parameter to nf_register_hook[s]
Date: Wed, 17 Jun 2015 10:28:31 -0500
Message-ID: <1434554932-4552-22-git-send-email-ebiederm@xmission.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39949 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757482AbbFQPia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:30 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W Biederman <ebiederm@xmission.com>

This is needed to support per network namespace netfilter hooks.

Since network namespace support is temporarily disabled all
of the callers can be modified to just pass init_net, without
changing their behavior.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter.h                      | 4 ++--
 net/bridge/br_netfilter.c                      | 2 +-
 net/bridge/netfilter/ebtable_filter.c          | 3 ++-
 net/bridge/netfilter/ebtable_nat.c             | 3 ++-
 net/decnet/netfilter/dn_rtmsg.c                | 2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             | 2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              | 2 +-
 net/ipv4/netfilter/iptable_nat.c               | 3 ++-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 2 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c            | 3 ++-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             | 2 +-
 net/ipv6/netfilter/ip6table_nat.c              | 3 ++-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 2 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      | 3 ++-
 net/netfilter/core.c                           | 6 +++---
 net/netfilter/ipvs/ip_vs_core.c                | 2 +-
 net/netfilter/nf_queue.c                       | 2 +-
 net/netfilter/nf_tables_api.c                  | 2 +-
 net/netfilter/x_tables.c                       | 2 +-
 security/selinux/hooks.c                       | 3 ++-
 security/smack/smack_netfilter.c               | 3 ++-
 21 files changed, 32 insertions(+), 24 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index f23e121f372b..6e83def032fa 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -121,9 +121,9 @@ struct nf_sockopt_ops {
 };
 
 /* Function to register/unregister hook points. */
-int nf_register_hook(struct nf_hook_ops *reg);
+int nf_register_hook(struct net *net, struct nf_hook_ops *reg);
 void nf_unregister_hook(struct nf_hook_ops *reg);
-int nf_register_hooks(struct nf_hook_ops *reg, unsigned int n);
+int nf_register_hooks(struct net *net, struct nf_hook_ops *reg, unsigned int n);
 void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n);
 
 /* Functions to register get/setsockopt ranges (non-inclusive).  You
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 46005603a4da..9267b58d6375 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -1250,7 +1250,7 @@ static int __init br_netfilter_init(void)
 {
 	int ret;
 
-	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	ret = nf_register_hooks(&init_net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
 	if (ret < 0)
 		return ret;
 
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index f9242dffa65e..b68662c34315 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -117,7 +117,8 @@ static int __init ebtable_filter_init(void)
 	ret = register_pernet_subsys(&frame_filter_net_ops);
 	if (ret < 0)
 		return ret;
-	ret = nf_register_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
+	ret = nf_register_hooks(&init_net, ebt_ops_filter,
+				ARRAY_SIZE(ebt_ops_filter));
 	if (ret < 0)
 		unregister_pernet_subsys(&frame_filter_net_ops);
 	return ret;
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 4bbefe03ab58..50d27183afec 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -117,7 +117,8 @@ static int __init ebtable_nat_init(void)
 	ret = register_pernet_subsys(&frame_nat_net_ops);
 	if (ret < 0)
 		return ret;
-	ret = nf_register_hooks(ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
+	ret = nf_register_hooks(&init_net, ebt_ops_nat,
+				ARRAY_SIZE(ebt_ops_nat));
 	if (ret < 0)
 		unregister_pernet_subsys(&frame_nat_net_ops);
 	return ret;
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 85f2fdc360c2..f18562975430 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -134,7 +134,7 @@ static int __init dn_rtmsg_init(void)
 		return -ENOMEM;
 	}
 
-	rv = nf_register_hook(&dnrmg_ops);
+	rv = nf_register_hook(&init_net, &dnrmg_ops);
 	if (rv) {
 		netlink_kernel_release(dnrmg);
 	}
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 3f32c03e8b2e..531ee65d8cc1 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -767,7 +767,7 @@ static int __init clusterip_tg_init(void)
 	if (ret < 0)
 		goto cleanup_subsys;
 
-	ret = nf_register_hook(&cip_arp_ops);
+	ret = nf_register_hook(&init_net, &cip_arp_ops);
 	if (ret < 0)
 		goto cleanup_target;
 
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 72b606bc73fe..3e97074cde51 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -450,7 +450,7 @@ static int __init synproxy_tg4_init(void)
 {
 	int err;
 
-	err = nf_register_hooks(ipv4_synproxy_ops,
+	err = nf_register_hooks(&init_net, ipv4_synproxy_ops,
 				ARRAY_SIZE(ipv4_synproxy_ops));
 	if (err < 0)
 		goto err1;
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 3a2e4d830a0b..fa5de3731680 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -129,7 +129,8 @@ static int __init iptable_nat_init(void)
 	if (err < 0)
 		goto err1;
 
-	err = nf_register_hooks(nf_nat_ipv4_ops, ARRAY_SIZE(nf_nat_ipv4_ops));
+	err = nf_register_hooks(&init_net, nf_nat_ipv4_ops,
+				ARRAY_SIZE(nf_nat_ipv4_ops));
 	if (err < 0)
 		goto err2;
 	return 0;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index df96b18a6162..f802f76104ff 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -467,7 +467,7 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 		goto cleanup_sockopt;
 	}
 
-	ret = nf_register_hooks(ipv4_conntrack_ops,
+	ret = nf_register_hooks(&init_net, ipv4_conntrack_ops,
 				ARRAY_SIZE(ipv4_conntrack_ops));
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv4: can't register hooks.\n");
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 835e166e69ea..a91c1b96b104 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -111,7 +111,8 @@ static struct nf_hook_ops ipv4_defrag_ops[] = {
 
 static int __init nf_defrag_init(void)
 {
-	return nf_register_hooks(ipv4_defrag_ops, ARRAY_SIZE(ipv4_defrag_ops));
+	return nf_register_hooks(&init_net, ipv4_defrag_ops,
+				 ARRAY_SIZE(ipv4_defrag_ops));
 }
 
 static void __exit nf_defrag_fini(void)
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 9976fd648811..1ec9e1531e17 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -473,7 +473,7 @@ static int __init synproxy_tg6_init(void)
 {
 	int err;
 
-	err = nf_register_hooks(ipv6_synproxy_ops,
+	err = nf_register_hooks(&init_net, ipv6_synproxy_ops,
 				ARRAY_SIZE(ipv6_synproxy_ops));
 	if (err < 0)
 		goto err1;
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index abea175d5853..57d1fbc71943 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -131,7 +131,8 @@ static int __init ip6table_nat_init(void)
 	if (err < 0)
 		goto err1;
 
-	err = nf_register_hooks(nf_nat_ipv6_ops, ARRAY_SIZE(nf_nat_ipv6_ops));
+	err = nf_register_hooks(&init_net, nf_nat_ipv6_ops,
+				ARRAY_SIZE(nf_nat_ipv6_ops));
 	if (err < 0)
 		goto err2;
 	return 0;
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index dcc0536cf61d..0e74254180aa 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -407,7 +407,7 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	if (ret < 0)
 		goto cleanup_sockopt;
 
-	ret = nf_register_hooks(ipv6_conntrack_ops,
+	ret = nf_register_hooks(&init_net, ipv6_conntrack_ops,
 				ARRAY_SIZE(ipv6_conntrack_ops));
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv6: can't register pre-routing defrag "
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 140112c6f867..922088fd6e32 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -109,7 +109,8 @@ static int __init nf_defrag_init(void)
 		pr_err("nf_defrag_ipv6: can't initialize frag6.\n");
 		return ret;
 	}
-	ret = nf_register_hooks(ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
+	ret = nf_register_hooks(&init_net, ipv6_defrag_ops,
+				ARRAY_SIZE(ipv6_defrag_ops));
 	if (ret < 0) {
 		pr_err("nf_defrag_ipv6: can't register hooks\n");
 		goto cleanup_frag6;
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 798f6308d7df..e673eb8df49a 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -62,7 +62,7 @@ EXPORT_SYMBOL(nf_hooks_needed);
 
 static DEFINE_MUTEX(nf_hook_mutex);
 
-int nf_register_hook(struct nf_hook_ops *reg)
+int nf_register_hook(struct net *net, struct nf_hook_ops *reg)
 {
 	struct list_head *nf_hook_list;
 	struct nf_hook_ops *elem;
@@ -121,13 +121,13 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
 }
 EXPORT_SYMBOL(nf_unregister_hook);
 
-int nf_register_hooks(struct nf_hook_ops *reg, unsigned int n)
+int nf_register_hooks(struct net *net, struct nf_hook_ops *reg, unsigned int n)
 {
 	unsigned int i;
 	int err = 0;
 
 	for (i = 0; i < n; i++) {
-		err = nf_register_hook(&reg[i]);
+		err = nf_register_hook(net, &reg[i]);
 		if (err)
 			goto err;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 10633d1e602d..6f548ff08925 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2088,7 +2088,7 @@ static int __init ip_vs_init(void)
 	if (ret < 0)
 		goto cleanup_sub;
 
-	ret = nf_register_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
+	ret = nf_register_hooks(&init_net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	if (ret < 0) {
 		pr_err("can't register hooks.\n");
 		goto cleanup_dev;
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 2e88032cd5ad..ab077fe4c1b8 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -196,7 +196,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 
 	if (verdict == NF_ACCEPT) {
 	next_hook:
-		verdict = nf_iterate(&nf_hooks[entry->state.pf][entry->state.hook],
+		verdict = nf_iterate(entry->state.hook_list,
 				     skb, &entry->state, &elem);
 	}
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index cfe636808541..d444526b39f9 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -133,7 +133,7 @@ int nft_register_basechain(struct nft_base_chain *basechain,
 	if (basechain->flags & NFT_BASECHAIN_DISABLED)
 		return 0;
 
-	return nf_register_hooks(basechain->ops, hook_nops);
+	return nf_register_hooks(&init_net, basechain->ops, hook_nops);
 }
 EXPORT_SYMBOL_GPL(nft_register_basechain);
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index d324fe71260c..c8ab3e6231c4 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1193,7 +1193,7 @@ struct nf_hook_ops *xt_hook_link(const struct xt_table *table, nf_hookfn *fn)
 		++i;
 	}
 
-	ret = nf_register_hooks(ops, num_hooks);
+	ret = nf_register_hooks(&init_net, ops, num_hooks);
 	if (ret < 0) {
 		kfree(ops);
 		return ERR_PTR(ret);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5dbfc32601fb..74876587b34e 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -6156,7 +6156,8 @@ static int __init selinux_nf_ip_init(void)
 
 	printk(KERN_DEBUG "SELinux:  Registering netfilter hooks\n");
 
-	err = nf_register_hooks(selinux_nf_ops, ARRAY_SIZE(selinux_nf_ops));
+	err = nf_register_hooks(&init_net, selinux_nf_ops,
+				ARRAY_SIZE(selinux_nf_ops));
 	if (err)
 		panic("SELinux: nf_register_hooks: error %d\n", err);
 
diff --git a/security/smack/smack_netfilter.c b/security/smack/smack_netfilter.c
index a9e41da05d28..0646fe5eda77 100644
--- a/security/smack/smack_netfilter.c
+++ b/security/smack/smack_netfilter.c
@@ -82,7 +82,8 @@ static int __init smack_nf_ip_init(void)
 
 	printk(KERN_DEBUG "Smack: Registering netfilter hooks\n");
 
-	err = nf_register_hooks(smack_nf_ops, ARRAY_SIZE(smack_nf_ops));
+	err = nf_register_hooks(&init_net, smack_nf_ops,
+				ARRAY_SIZE(smack_nf_ops));
 	if (err)
 		pr_info("Smack: nf_register_hooks: error %d\n", err);
 
-- 
2.2.1
