From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH v2 1/9] tproxy: split off ipv6 defragmentation to a separate
 module
Date: Thu, 21 Oct 2010 12:47:09 +0200
Message-ID: <20101021104709.5192.64336.stgit@este.odu>
References: <20101021104709.5192.31249.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Balazs Scheidler <bazsi@balabit.hu>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20101021104709.5192.31249.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>

Like with IPv4, TProxy needs IPv6 defragmentation but does not
require connection tracking. Since defragmentation was coupled
with conntrack, I split off the two, creating an nf_defrag_ipv6 module,
similar to the already existing nf_defrag_ipv4.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
---
 include/net/netfilter/ipv6/nf_defrag_ipv6.h    |    6 +
 net/ipv6/netfilter/Makefile                    |    5 +
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   78 +-------------
 net/ipv6/netfilter/nf_conntrack_reasm.c        |   12 ++
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  131 ++++++++++++++++++++++++
 5 files changed, 154 insertions(+), 78 deletions(-)
 create mode 100644 include/net/netfilter/ipv6/nf_defrag_ipv6.h
 create mode 100644 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c

diff --git a/include/net/netfilter/ipv6/nf_defrag_ipv6.h b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
new file mode 100644
index 0000000..94dd54d
--- /dev/null
+++ b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
@@ -0,0 +1,6 @@
+#ifndef _NF_DEFRAG_IPV6_H
+#define _NF_DEFRAG_IPV6_H
+
+extern void nf_defrag_ipv6_enable(void);
+
+#endif /* _NF_DEFRAG_IPV6_H */
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index aafbba3..3f8e4a3 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -11,10 +11,11 @@ obj-$(CONFIG_IP6_NF_RAW) += ip6table_raw.o
 obj-$(CONFIG_IP6_NF_SECURITY) += ip6table_security.o
 
 # objects for l3 independent conntrack
-nf_conntrack_ipv6-objs  :=  nf_conntrack_l3proto_ipv6.o nf_conntrack_proto_icmpv6.o nf_conntrack_reasm.o
+nf_conntrack_ipv6-objs  :=  nf_conntrack_l3proto_ipv6.o nf_conntrack_proto_icmpv6.o
+nf_defrag_ipv6-objs := nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o
 
 # l3 independent conntrack
-obj-$(CONFIG_NF_CONNTRACK_IPV6) += nf_conntrack_ipv6.o
+obj-$(CONFIG_NF_CONNTRACK_IPV6) += nf_conntrack_ipv6.o nf_defrag_ipv6.o
 
 # matches
 obj-$(CONFIG_IP6_NF_MATCH_AH) += ip6t_ah.o
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index ff43461..c8af58b 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -16,7 +16,6 @@
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/icmp.h>
-#include <linux/sysctl.h>
 #include <net/ipv6.h>
 #include <net/inet_frag.h>
 
@@ -29,6 +28,7 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
+#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 #include <net/netfilter/nf_log.h>
 
 static bool ipv6_pkt_to_tuple(const struct sk_buff *skb, unsigned int nhoff,
@@ -189,53 +189,6 @@ out:
 	return nf_conntrack_confirm(skb);
 }
 
-static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
-						struct sk_buff *skb)
-{
-	u16 zone = NF_CT_DEFAULT_ZONE;
-
-	if (skb->nfct)
-		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
-
-#ifdef CONFIG_BRIDGE_NETFILTER
-	if (skb->nf_bridge &&
-	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
-		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
-#endif
-	if (hooknum == NF_INET_PRE_ROUTING)
-		return IP6_DEFRAG_CONNTRACK_IN + zone;
-	else
-		return IP6_DEFRAG_CONNTRACK_OUT + zone;
-
-}
-
-static unsigned int ipv6_defrag(unsigned int hooknum,
-				struct sk_buff *skb,
-				const struct net_device *in,
-				const struct net_device *out,
-				int (*okfn)(struct sk_buff *))
-{
-	struct sk_buff *reasm;
-
-	/* Previously seen (loopback)?  */
-	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
-		return NF_ACCEPT;
-
-	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(hooknum, skb));
-	/* queued */
-	if (reasm == NULL)
-		return NF_STOLEN;
-
-	/* error occured or not fragmented */
-	if (reasm == skb)
-		return NF_ACCEPT;
-
-	nf_ct_frag6_output(hooknum, reasm, (struct net_device *)in,
-			   (struct net_device *)out, okfn);
-
-	return NF_STOLEN;
-}
-
 static unsigned int __ipv6_conntrack_in(struct net *net,
 					unsigned int hooknum,
 					struct sk_buff *skb,
@@ -288,13 +241,6 @@ static unsigned int ipv6_conntrack_local(unsigned int hooknum,
 
 static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
 	{
-		.hook		= ipv6_defrag,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_PRE_ROUTING,
-		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
-	},
-	{
 		.hook		= ipv6_conntrack_in,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
@@ -309,13 +255,6 @@ static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
 		.priority	= NF_IP6_PRI_CONNTRACK,
 	},
 	{
-		.hook		= ipv6_defrag,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
-	},
-	{
 		.hook		= ipv6_confirm,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
@@ -387,10 +326,6 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6 __read_mostly = {
 	.nlattr_to_tuple	= ipv6_nlattr_to_tuple,
 	.nla_policy		= ipv6_nla_policy,
 #endif
-#ifdef CONFIG_SYSCTL
-	.ctl_table_path		= nf_net_netfilter_sysctl_path,
-	.ctl_table		= nf_ct_ipv6_sysctl_table,
-#endif
 	.me			= THIS_MODULE,
 };
 
@@ -403,16 +338,12 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	int ret = 0;
 
 	need_conntrack();
+	nf_defrag_ipv6_enable();
 
-	ret = nf_ct_frag6_init();
-	if (ret < 0) {
-		pr_err("nf_conntrack_ipv6: can't initialize frag6.\n");
-		return ret;
-	}
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp6);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv6: can't register tcp.\n");
-		goto cleanup_frag6;
+		return ret;
 	}
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp6);
@@ -450,8 +381,6 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
  cleanup_tcp:
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
- cleanup_frag6:
-	nf_ct_frag6_cleanup();
 	return ret;
 }
 
@@ -463,7 +392,6 @@ static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
-	nf_ct_frag6_cleanup();
 }
 
 module_init(nf_conntrack_l3proto_ipv6_init);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 138a8b3..bb669b4 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -73,7 +73,7 @@ static struct inet_frags nf_frags;
 static struct netns_frags nf_init_frags;
 
 #ifdef CONFIG_SYSCTL
-struct ctl_table nf_ct_ipv6_sysctl_table[] = {
+struct ctl_table nf_ct_frag6_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_frag6_timeout",
 		.data		= &nf_init_frags.timeout,
@@ -97,6 +97,8 @@ struct ctl_table nf_ct_ipv6_sysctl_table[] = {
 	},
 	{ }
 };
+
+static struct ctl_table_header *nf_ct_frag6_sysctl_header;
 #endif
 
 static unsigned int nf_hashfn(struct inet_frag_queue *q)
@@ -623,11 +625,19 @@ int nf_ct_frag6_init(void)
 	inet_frags_init_net(&nf_init_frags);
 	inet_frags_init(&nf_frags);
 
+	nf_ct_frag6_sysctl_header = register_sysctl_paths(nf_net_netfilter_sysctl_path,
+							  nf_ct_frag6_sysctl_table);
+	if (!nf_ct_frag6_sysctl_header)
+		return -ENOMEM;
+
 	return 0;
 }
 
 void nf_ct_frag6_cleanup(void)
 {
+	unregister_sysctl_table(nf_ct_frag6_sysctl_header);
+	nf_ct_frag6_sysctl_header = NULL;
+
 	inet_frags_fini(&nf_frags);
 
 	nf_init_frags.low_thresh = 0;
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
new file mode 100644
index 0000000..99abfb5
--- /dev/null
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -0,0 +1,131 @@
+/* (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/types.h>
+#include <linux/ipv6.h>
+#include <linux/in6.h>
+#include <linux/netfilter.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/icmp.h>
+#include <linux/sysctl.h>
+#include <net/ipv6.h>
+#include <net/inet_frag.h>
+
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter_bridge.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_l4proto.h>
+#include <net/netfilter/nf_conntrack_l3proto.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_zones.h>
+#include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
+#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
+
+static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
+						struct sk_buff *skb)
+{
+	u16 zone = NF_CT_DEFAULT_ZONE;
+
+	if (skb->nfct)
+		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
+
+#ifdef CONFIG_BRIDGE_NETFILTER
+	if (skb->nf_bridge &&
+	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
+		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
+#endif
+	if (hooknum == NF_INET_PRE_ROUTING)
+		return IP6_DEFRAG_CONNTRACK_IN + zone;
+	else
+		return IP6_DEFRAG_CONNTRACK_OUT + zone;
+
+}
+
+static unsigned int ipv6_defrag(unsigned int hooknum,
+				struct sk_buff *skb,
+				const struct net_device *in,
+				const struct net_device *out,
+				int (*okfn)(struct sk_buff *))
+{
+	struct sk_buff *reasm;
+
+	/* Previously seen (loopback)?	*/
+	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
+		return NF_ACCEPT;
+
+	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(hooknum, skb));
+	/* queued */
+	if (reasm == NULL)
+		return NF_STOLEN;
+
+	/* error occured or not fragmented */
+	if (reasm == skb)
+		return NF_ACCEPT;
+
+	nf_ct_frag6_output(hooknum, reasm, (struct net_device *)in,
+			   (struct net_device *)out, okfn);
+
+	return NF_STOLEN;
+}
+
+static struct nf_hook_ops ipv6_defrag_ops[] = {
+	{
+		.hook		= ipv6_defrag,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_PRE_ROUTING,
+		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
+	},
+	{
+		.hook		= ipv6_defrag,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_LOCAL_OUT,
+		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
+	},
+};
+
+static int __init nf_defrag_init(void)
+{
+	int ret = 0;
+
+	ret = nf_ct_frag6_init();
+	if (ret < 0) {
+		pr_err("nf_defrag_ipv6: can't initialize frag6.\n");
+		return ret;
+	}
+	ret = nf_register_hooks(ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
+	if (ret < 0) {
+		pr_err("nf_defrag_ipv6: can't register hooks\n");
+		goto cleanup_frag6;
+	}
+	return ret;
+
+cleanup_frag6:
+	nf_ct_frag6_cleanup();
+	return ret;
+
+}
+
+static void __exit nf_defrag_fini(void)
+{
+	nf_unregister_hooks(ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
+	nf_ct_frag6_cleanup();
+}
+
+void nf_defrag_ipv6_enable(void)
+{
+}
+EXPORT_SYMBOL_GPL(nf_defrag_ipv6_enable);
+
+module_init(nf_defrag_init);
+module_exit(nf_defrag_fini);
+
+MODULE_LICENSE("GPL");


