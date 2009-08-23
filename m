From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 04/13] TProxy: split off ipv6 defragmentation to a separate
 module
Date: Sun, 23 Aug 2009 11:11:15 +0200
Message-ID: <1253548005.12519.4.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Like with IPv4, TProxy needs IP defragmentation but does not
require connection tracking. Since defragmentation was coupled
with conntrack, I split off the two, creating an nf_defrag_ipv6 module,
similar to the already existing nf_defrag_ipv4.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 include/net/netfilter/ipv6/nf_defrag_ipv6.h    |    6 ++
 net/ipv6/netfilter/Makefile                    |    5 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   58 +------------
 net/ipv6/netfilter/nf_conntrack_reasm.c        |   12 ++-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  109 ++++++++++++++++++++++++
 5 files changed, 131 insertions(+), 59 deletions(-)
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
index aafbba3..a78ee59 100644
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
index 2a15c2d..158d14c 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -27,6 +27,7 @@
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
+#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 
 static bool ipv6_pkt_to_tuple(const struct sk_buff *skb, unsigned int nhoff,
 			      struct nf_conntrack_tuple *tuple)
@@ -183,34 +184,6 @@ out:
 	return nf_conntrack_confirm(skb);
 }
 
-static unsigned int ipv6_defrag(unsigned int hooknum,
-				struct sk_buff *skb,
-				const struct net_device *in,
-				const struct net_device *out,
-				int (*okfn)(struct sk_buff *))
-{
-	struct sk_buff *reasm;
-
-	/* Previously seen (loopback)?  */
-	if (skb->nfct)
-		return NF_ACCEPT;
-
-	reasm = nf_ct_frag6_gather(skb);
-
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
@@ -263,13 +236,6 @@ static unsigned int ipv6_conntrack_local(unsigned int hooknum,
 
 static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
 	{
-		.hook		= ipv6_defrag,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
-		.hooknum	= NF_INET_PRE_ROUTING,
-		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
-	},
-	{
 		.hook		= ipv6_conntrack_in,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
@@ -284,13 +250,6 @@ static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
 		.priority	= NF_IP6_PRI_CONNTRACK,
 	},
 	{
-		.hook		= ipv6_defrag,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
-		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
-	},
-	{
 		.hook		= ipv6_confirm,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
@@ -362,10 +321,6 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6 __read_mostly = {
 	.nlattr_to_tuple	= ipv6_nlattr_to_tuple,
 	.nla_policy		= ipv6_nla_policy,
 #endif
-#ifdef CONFIG_SYSCTL
-	.ctl_table_path		= nf_net_netfilter_sysctl_path,
-	.ctl_table		= nf_ct_ipv6_sysctl_table,
-#endif
 	.me			= THIS_MODULE,
 };
 
@@ -378,16 +333,12 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	int ret = 0;
 
 	need_conntrack();
+	nf_defrag_ipv6_enable();
 
-	ret = nf_ct_frag6_init();
-	if (ret < 0) {
-		printk("nf_conntrack_ipv6: can't initialize frag6.\n");
-		return ret;
-	}
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp6);
 	if (ret < 0) {
 		printk("nf_conntrack_ipv6: can't register tcp.\n");
-		goto cleanup_frag6;
+                return ret;
 	}
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp6);
@@ -425,8 +376,6 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
  cleanup_tcp:
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
- cleanup_frag6:
-	nf_ct_frag6_cleanup();
 	return ret;
 }
 
@@ -438,7 +387,6 @@ static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
-	nf_ct_frag6_cleanup();
 }
 
 module_init(nf_conntrack_l3proto_ipv6_init);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index f3aba25..b7b08fe 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -73,8 +73,8 @@ struct nf_ct_frag6_queue
 static struct inet_frags nf_frags;
 static struct netns_frags nf_init_frags;
 
-#ifdef CONFIG_SYSCTL
-struct ctl_table nf_ct_ipv6_sysctl_table[] = {
+#if defined(CONFIG_SYSCTL)
+struct ctl_table nf_ct_frag6_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_frag6_timeout",
 		.data		= &nf_init_frags.timeout,
@@ -100,6 +100,8 @@ struct ctl_table nf_ct_ipv6_sysctl_table[] = {
 	},
 	{ .ctl_name = 0 }
 };
+
+static struct ctl_table_header *nf_ct_frag6_sysctl_header = NULL;
 #endif
 
 static unsigned int nf_hashfn(struct inet_frag_queue *q)
@@ -675,11 +677,17 @@ int nf_ct_frag6_init(void)
 	inet_frags_init_net(&nf_init_frags);
 	inet_frags_init(&nf_frags);
 
+        if (!(nf_ct_frag6_sysctl_header = register_sysctl_paths(nf_net_netfilter_sysctl_path, nf_ct_frag6_sysctl_table))) {
+		return -ENOMEM;
+	}
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
index 0000000..6f07971
--- /dev/null
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -0,0 +1,109 @@
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
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_l4proto.h>
+#include <net/netfilter/nf_conntrack_l3proto.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
+#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
+
+static unsigned int ipv6_defrag(unsigned int hooknum,
+				struct sk_buff *skb,
+				const struct net_device *in,
+				const struct net_device *out,
+				int (*okfn)(struct sk_buff *))
+{
+	struct sk_buff *reasm;
+
+	/* Previously seen (loopback)?  */
+	if (skb->nfct)
+		return NF_ACCEPT;
+
+	reasm = nf_ct_frag6_gather(skb);
+
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
+		.pf		= PF_INET6,
+		.hooknum	= NF_INET_PRE_ROUTING,
+		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
+	},
+	{
+		.hook		= ipv6_defrag,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum	= NF_INET_LOCAL_OUT,
+		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
+	},
+};
+
+static int __init nf_defrag_init(void)
+{
+        int ret = 0;
+
+	ret = nf_ct_frag6_init();
+	if (ret < 0) {
+		printk("nf_conntrack_ipv6: can't initialize frag6.\n");
+		return ret;
+	}
+	ret = nf_register_hooks(ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
+	if (ret < 0) {
+	        printk("nf_defrag_ipv6: can't register hooks\n");
+	        goto cleanup_frag6;
+	}
+	return ret;
+ cleanup_frag6:
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
-- 
1.6.0.4

