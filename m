From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/50] netfilter: defrag: only register defrag functionality if needed
Date: Wed,  7 Dec 2016 22:52:25 +0100
Message-ID: <1481147576-5690-20-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60222 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933355AbcLGVxk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:40 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 804BCC0B54
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 68B7EDA853
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 071F9DA863
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:33 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

nf_defrag modules for ipv4 and ipv6 export an empty stub function.
Any module that needs the defragmentation hooks registered simply 'calls'
this empty function to create a phony module dependency -- modprobe will
then load the defrag module too.

This extends netfilter ipv4/ipv6 defragmentation modules to delay the hook
registration until the functionality is requested within a network namespace
instead of module load time for all namespaces.

Hooks are only un-registered on module unload or when a namespace that used
such defrag functionality exits.

We have to use struct net for this as the register hooks can be called
before netns initialization here from the ipv4/ipv6 conntrack module
init path.

There is no unregister functionality support, defrag will always be
active once it was requested inside a net namespace.

The reason is that defrag has impact on nft and iptables rulesets
(without defrag we might see framents).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_defrag_ipv4.h    |  3 +-
 include/net/netfilter/ipv6/nf_defrag_ipv6.h    |  3 +-
 include/net/netns/netfilter.h                  |  6 ++++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  7 ++++-
 net/ipv4/netfilter/nf_defrag_ipv4.c            | 41 +++++++++++++++++++++++--
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  7 ++++-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      | 42 +++++++++++++++++++++++---
 net/netfilter/xt_TPROXY.c                      | 15 ++++++---
 net/netfilter/xt_socket.c                      | 33 +++++++++++++++++---
 9 files changed, 136 insertions(+), 21 deletions(-)

diff --git a/include/net/netfilter/ipv4/nf_defrag_ipv4.h b/include/net/netfilter/ipv4/nf_defrag_ipv4.h
index f01ef208dff6..db405f70e538 100644
--- a/include/net/netfilter/ipv4/nf_defrag_ipv4.h
+++ b/include/net/netfilter/ipv4/nf_defrag_ipv4.h
@@ -1,6 +1,7 @@
 #ifndef _NF_DEFRAG_IPV4_H
 #define _NF_DEFRAG_IPV4_H
 
-void nf_defrag_ipv4_enable(void);
+struct net;
+int nf_defrag_ipv4_enable(struct net *);
 
 #endif /* _NF_DEFRAG_IPV4_H */
diff --git a/include/net/netfilter/ipv6/nf_defrag_ipv6.h b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
index ddf162f7966f..7664efe37974 100644
--- a/include/net/netfilter/ipv6/nf_defrag_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
@@ -1,7 +1,8 @@
 #ifndef _NF_DEFRAG_IPV6_H
 #define _NF_DEFRAG_IPV6_H
 
-void nf_defrag_ipv6_enable(void);
+struct net;
+int nf_defrag_ipv6_enable(struct net *);
 
 int nf_ct_frag6_init(void);
 void nf_ct_frag6_cleanup(void);
diff --git a/include/net/netns/netfilter.h b/include/net/netns/netfilter.h
index 58487b1cc99a..cea396b53a60 100644
--- a/include/net/netns/netfilter.h
+++ b/include/net/netns/netfilter.h
@@ -17,5 +17,11 @@ struct netns_nf {
 	struct ctl_table_header *nf_log_dir_header;
 #endif
 	struct nf_hook_entry __rcu *hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
+	bool			defrag_ipv4;
+#endif
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
+	bool			defrag_ipv6;
+#endif
 };
 #endif
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 6f375443a74b..fcfd071f4705 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -325,6 +325,12 @@ static int ipv4_hooks_register(struct net *net)
 	if (cnet->users > 1)
 		goto out_unlock;
 
+	err = nf_defrag_ipv4_enable(net);
+	if (err) {
+		cnet->users = 0;
+		goto out_unlock;
+	}
+
 	err = nf_register_net_hooks(net, ipv4_conntrack_ops,
 				    ARRAY_SIZE(ipv4_conntrack_ops));
 
@@ -422,7 +428,6 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 	int ret = 0;
 
 	need_conntrack();
-	nf_defrag_ipv4_enable();
 
 	ret = nf_register_sockopt(&so_getorigdst);
 	if (ret < 0) {
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index d88da36b383c..49bd6a54404f 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -11,6 +11,7 @@
 #include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
+#include <net/netns/generic.h>
 #include <net/route.h>
 #include <net/ip.h>
 
@@ -22,6 +23,8 @@
 #endif
 #include <net/netfilter/nf_conntrack_zones.h>
 
+static DEFINE_MUTEX(defrag4_mutex);
+
 static int nf_ct_ipv4_gather_frags(struct net *net, struct sk_buff *skb,
 				   u_int32_t user)
 {
@@ -102,18 +105,50 @@ static struct nf_hook_ops ipv4_defrag_ops[] = {
 	},
 };
 
+static void __net_exit defrag4_net_exit(struct net *net)
+{
+	if (net->nf.defrag_ipv4) {
+		nf_unregister_net_hooks(net, ipv4_defrag_ops,
+					ARRAY_SIZE(ipv4_defrag_ops));
+		net->nf.defrag_ipv4 = false;
+	}
+}
+
+static struct pernet_operations defrag4_net_ops = {
+	.exit = defrag4_net_exit,
+};
+
 static int __init nf_defrag_init(void)
 {
-	return nf_register_hooks(ipv4_defrag_ops, ARRAY_SIZE(ipv4_defrag_ops));
+	return register_pernet_subsys(&defrag4_net_ops);
 }
 
 static void __exit nf_defrag_fini(void)
 {
-	nf_unregister_hooks(ipv4_defrag_ops, ARRAY_SIZE(ipv4_defrag_ops));
+	unregister_pernet_subsys(&defrag4_net_ops);
 }
 
-void nf_defrag_ipv4_enable(void)
+int nf_defrag_ipv4_enable(struct net *net)
 {
+	int err = 0;
+
+	might_sleep();
+
+	if (net->nf.defrag_ipv4)
+		return 0;
+
+	mutex_lock(&defrag4_mutex);
+	if (net->nf.defrag_ipv4)
+		goto out_unlock;
+
+	err = nf_register_net_hooks(net, ipv4_defrag_ops,
+				    ARRAY_SIZE(ipv4_defrag_ops));
+	if (err == 0)
+		net->nf.defrag_ipv4 = true;
+
+ out_unlock:
+	mutex_unlock(&defrag4_mutex);
+	return err;
 }
 EXPORT_SYMBOL_GPL(nf_defrag_ipv4_enable);
 
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 72fe48075b7f..4e3402486833 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -325,6 +325,12 @@ static int ipv6_hooks_register(struct net *net)
 	if (cnet->users > 1)
 		goto out_unlock;
 
+	err = nf_defrag_ipv6_enable(net);
+	if (err < 0) {
+		cnet->users = 0;
+		goto out_unlock;
+	}
+
 	err = nf_register_net_hooks(net, ipv6_conntrack_ops,
 				    ARRAY_SIZE(ipv6_conntrack_ops));
 	if (err)
@@ -427,7 +433,6 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	int ret = 0;
 
 	need_conntrack();
-	nf_defrag_ipv6_enable();
 
 	ret = nf_register_sockopt(&so_getorigdst6);
 	if (ret < 0) {
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index f06b0471f39f..8e0bdd058787 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -30,6 +30,8 @@
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 
+static DEFINE_MUTEX(defrag6_mutex);
+
 static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 						struct sk_buff *skb)
 {
@@ -87,6 +89,19 @@ static struct nf_hook_ops ipv6_defrag_ops[] = {
 	},
 };
 
+static void __net_exit defrag6_net_exit(struct net *net)
+{
+	if (net->nf.defrag_ipv6) {
+		nf_unregister_net_hooks(net, ipv6_defrag_ops,
+					ARRAY_SIZE(ipv6_defrag_ops));
+		net->nf.defrag_ipv6 = false;
+	}
+}
+
+static struct pernet_operations defrag6_net_ops = {
+	.exit = defrag6_net_exit,
+};
+
 static int __init nf_defrag_init(void)
 {
 	int ret = 0;
@@ -96,9 +111,9 @@ static int __init nf_defrag_init(void)
 		pr_err("nf_defrag_ipv6: can't initialize frag6.\n");
 		return ret;
 	}
-	ret = nf_register_hooks(ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
+	ret = register_pernet_subsys(&defrag6_net_ops);
 	if (ret < 0) {
-		pr_err("nf_defrag_ipv6: can't register hooks\n");
+		pr_err("nf_defrag_ipv6: can't register pernet ops\n");
 		goto cleanup_frag6;
 	}
 	return ret;
@@ -111,12 +126,31 @@ static int __init nf_defrag_init(void)
 
 static void __exit nf_defrag_fini(void)
 {
-	nf_unregister_hooks(ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
+	unregister_pernet_subsys(&defrag6_net_ops);
 	nf_ct_frag6_cleanup();
 }
 
-void nf_defrag_ipv6_enable(void)
+int nf_defrag_ipv6_enable(struct net *net)
 {
+	int err = 0;
+
+	might_sleep();
+
+	if (net->nf.defrag_ipv6)
+		return 0;
+
+	mutex_lock(&defrag6_mutex);
+	if (net->nf.defrag_ipv6)
+		goto out_unlock;
+
+	err = nf_register_net_hooks(net, ipv6_defrag_ops,
+				    ARRAY_SIZE(ipv6_defrag_ops));
+	if (err == 0)
+		net->nf.defrag_ipv6 = true;
+
+ out_unlock:
+	mutex_unlock(&defrag6_mutex);
+	return err;
 }
 EXPORT_SYMBOL_GPL(nf_defrag_ipv6_enable);
 
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index dbd72cc40e42..80cb7babeb64 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -531,6 +531,11 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 static int tproxy_tg6_check(const struct xt_tgchk_param *par)
 {
 	const struct ip6t_ip6 *i = par->entryinfo;
+	int err;
+
+	err = nf_defrag_ipv6_enable(par->net);
+	if (err)
+		return err;
 
 	if ((i->proto == IPPROTO_TCP || i->proto == IPPROTO_UDP) &&
 	    !(i->invflags & IP6T_INV_PROTO))
@@ -545,6 +550,11 @@ static int tproxy_tg6_check(const struct xt_tgchk_param *par)
 static int tproxy_tg4_check(const struct xt_tgchk_param *par)
 {
 	const struct ipt_ip *i = par->entryinfo;
+	int err;
+
+	err = nf_defrag_ipv4_enable(par->net);
+	if (err)
+		return err;
 
 	if ((i->proto == IPPROTO_TCP || i->proto == IPPROTO_UDP)
 	    && !(i->invflags & IPT_INV_PROTO))
@@ -596,11 +606,6 @@ static struct xt_target tproxy_tg_reg[] __read_mostly = {
 
 static int __init tproxy_tg_init(void)
 {
-	nf_defrag_ipv4_enable();
-#ifdef XT_TPROXY_HAVE_IPV6
-	nf_defrag_ipv6_enable();
-#endif
-
 	return xt_register_targets(tproxy_tg_reg, ARRAY_SIZE(tproxy_tg_reg));
 }
 
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 2198914707f5..770bbec878f1 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -147,9 +147,28 @@ socket_mt6_v1_v2_v3(const struct sk_buff *skb, struct xt_action_param *par)
 }
 #endif
 
+static int socket_mt_enable_defrag(struct net *net, int family)
+{
+	switch (family) {
+	case NFPROTO_IPV4:
+		return nf_defrag_ipv4_enable(net);
+#ifdef XT_SOCKET_HAVE_IPV6
+	case NFPROTO_IPV6:
+		return nf_defrag_ipv6_enable(net);
+#endif
+	}
+	WARN_ONCE(1, "Unknown family %d\n", family);
+	return 0;
+}
+
 static int socket_mt_v1_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
+	int err;
+
+	err = socket_mt_enable_defrag(par->net, par->family);
+	if (err)
+		return err;
 
 	if (info->flags & ~XT_SOCKET_FLAGS_V1) {
 		pr_info("unknown flags 0x%x\n", info->flags & ~XT_SOCKET_FLAGS_V1);
@@ -161,6 +180,11 @@ static int socket_mt_v1_check(const struct xt_mtchk_param *par)
 static int socket_mt_v2_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_socket_mtinfo2 *info = (struct xt_socket_mtinfo2 *) par->matchinfo;
+	int err;
+
+	err = socket_mt_enable_defrag(par->net, par->family);
+	if (err)
+		return err;
 
 	if (info->flags & ~XT_SOCKET_FLAGS_V2) {
 		pr_info("unknown flags 0x%x\n", info->flags & ~XT_SOCKET_FLAGS_V2);
@@ -173,7 +197,11 @@ static int socket_mt_v3_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_socket_mtinfo3 *info =
 				    (struct xt_socket_mtinfo3 *)par->matchinfo;
+	int err;
 
+	err = socket_mt_enable_defrag(par->net, par->family);
+	if (err)
+		return err;
 	if (info->flags & ~XT_SOCKET_FLAGS_V3) {
 		pr_info("unknown flags 0x%x\n",
 			info->flags & ~XT_SOCKET_FLAGS_V3);
@@ -268,11 +296,6 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 
 static int __init socket_mt_init(void)
 {
-	nf_defrag_ipv4_enable();
-#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
-	nf_defrag_ipv6_enable();
-#endif
-
 	return xt_register_matches(socket_mt_reg, ARRAY_SIZE(socket_mt_reg));
 }
 
-- 
2.1.4
