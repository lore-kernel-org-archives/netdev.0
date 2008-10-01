From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 12/16] Split Netfilter IPv4 defragmentation into a
	separate module
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.63510.stgit@este>
References: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:53158 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246AbYJAPZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 11:25:45 -0400
In-reply-to: <20081001142431.4893.48078.stgit@este>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netfilter connection tracking requires all IPv4 packets to be defragmented.
Both the socket match and the TPROXY target depend on this functionality, so
this patch separates the Netfilter IPv4 defrag hooks into a separate module.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/netfilter/ipv4/nf_defrag_ipv4.h    |    6 ++
 net/ipv4/netfilter/Kconfig                     |    5 +
 net/ipv4/netfilter/Makefile                    |    3 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   56 +-------------
 net/ipv4/netfilter/nf_defrag_ipv4.c            |   96 ++++++++++++++++++++++++
 5 files changed, 113 insertions(+), 53 deletions(-)

diff --git a/include/net/netfilter/ipv4/nf_defrag_ipv4.h b/include/net/netfilter/ipv4/nf_defrag_ipv4.h
new file mode 100644
index 0000000..6b00ea3
--- /dev/null
+++ b/include/net/netfilter/ipv4/nf_defrag_ipv4.h
@@ -0,0 +1,6 @@
+#ifndef _NF_DEFRAG_IPV4_H
+#define _NF_DEFRAG_IPV4_H
+
+extern void nf_defrag_ipv4_enable(void);
+
+#endif /* _NF_DEFRAG_IPV4_H */
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 90eb7cb..d011677 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -5,10 +5,15 @@
 menu "IP: Netfilter Configuration"
 	depends on INET && NETFILTER
 
+config NF_DEFRAG_IPV4
+	tristate
+	default n
+
 config NF_CONNTRACK_IPV4
 	tristate "IPv4 connection tracking support (required for NAT)"
 	depends on NF_CONNTRACK
 	default m if NETFILTER_ADVANCED=n
+	select NF_DEFRAG_IPV4
 	---help---
 	  Connection tracking keeps a record of what packets have passed
 	  through your machine, in order to figure out how they are related
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 3f31291..dded5e9 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -18,6 +18,9 @@ obj-$(CONFIG_NF_CONNTRACK_IPV4) += nf_conntrack_ipv4.o
 
 obj-$(CONFIG_NF_NAT) += nf_nat.o
 
+# defrag
+obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
+
 # NAT helpers (nf_conntrack)
 obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
 obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 5a955c4..abf82c3 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -1,3 +1,4 @@
+
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
  *
@@ -24,6 +25,7 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/nf_nat_helper.h>
+#include <net/netfilter/ipv4/nf_defrag_ipv4.h>
 
 int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
 			      struct nf_conn *ct,
@@ -63,23 +65,6 @@ static int ipv4_print_tuple(struct seq_file *s,
 			  NIPQUAD(tuple->dst.u3.ip));
 }
 
-/* Returns new sk_buff, or NULL */
-static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
-{
-	int err;
-
-	skb_orphan(skb);
-
-	local_bh_disable();
-	err = ip_defrag(skb, user);
-	local_bh_enable();
-
-	if (!err)
-		ip_send_check(ip_hdr(skb));
-
-	return err;
-}
-
 static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 			    unsigned int *dataoff, u_int8_t *protonum)
 {
@@ -144,28 +129,6 @@ out:
 	return nf_conntrack_confirm(skb);
 }
 
-static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
-					  struct sk_buff *skb,
-					  const struct net_device *in,
-					  const struct net_device *out,
-					  int (*okfn)(struct sk_buff *))
-{
-	/* Previously seen (loopback)?  Ignore.  Do this before
-	   fragment check. */
-	if (skb->nfct)
-		return NF_ACCEPT;
-
-	/* Gather fragments. */
-	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		if (nf_ct_ipv4_gather_frags(skb,
-					    hooknum == NF_INET_PRE_ROUTING ?
-					    IP_DEFRAG_CONNTRACK_IN :
-					    IP_DEFRAG_CONNTRACK_OUT))
-			return NF_STOLEN;
-	}
-	return NF_ACCEPT;
-}
-
 static unsigned int ipv4_conntrack_in(unsigned int hooknum,
 				      struct sk_buff *skb,
 				      const struct net_device *in,
@@ -195,13 +158,6 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
    make it the first hook. */
 static struct nf_hook_ops ipv4_conntrack_ops[] __read_mostly = {
 	{
-		.hook		= ipv4_conntrack_defrag,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
-		.hooknum	= NF_INET_PRE_ROUTING,
-		.priority	= NF_IP_PRI_CONNTRACK_DEFRAG,
-	},
-	{
 		.hook		= ipv4_conntrack_in,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
@@ -209,13 +165,6 @@ static struct nf_hook_ops ipv4_conntrack_ops[] __read_mostly = {
 		.priority	= NF_IP_PRI_CONNTRACK,
 	},
 	{
-		.hook           = ipv4_conntrack_defrag,
-		.owner          = THIS_MODULE,
-		.pf             = PF_INET,
-		.hooknum        = NF_INET_LOCAL_OUT,
-		.priority       = NF_IP_PRI_CONNTRACK_DEFRAG,
-	},
-	{
 		.hook		= ipv4_conntrack_local,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
@@ -422,6 +371,7 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 	int ret = 0;
 
 	need_conntrack();
+	nf_defrag_ipv4_enable();
 
 	ret = nf_register_sockopt(&so_getorigdst);
 	if (ret < 0) {
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
new file mode 100644
index 0000000..aa2c50a
--- /dev/null
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -0,0 +1,96 @@
+/* (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/types.h>
+#include <linux/ip.h>
+#include <linux/netfilter.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/route.h>
+#include <net/ip.h>
+
+#include <linux/netfilter_ipv4.h>
+#include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+
+/* Returns new sk_buff, or NULL */
+static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
+{
+	int err;
+
+	skb_orphan(skb);
+
+	local_bh_disable();
+	err = ip_defrag(skb, user);
+	local_bh_enable();
+
+	if (!err)
+		ip_send_check(ip_hdr(skb));
+
+	return err;
+}
+
+static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
+					  struct sk_buff *skb,
+					  const struct net_device *in,
+					  const struct net_device *out,
+					  int (*okfn)(struct sk_buff *))
+{
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	/* Previously seen (loopback)?  Ignore.  Do this before
+	   fragment check. */
+	if (skb->nfct)
+		return NF_ACCEPT;
+#endif
+
+	/* Gather fragments. */
+	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
+		if (nf_ct_ipv4_gather_frags(skb,
+					    hooknum == NF_INET_PRE_ROUTING ?
+					    IP_DEFRAG_CONNTRACK_IN :
+					    IP_DEFRAG_CONNTRACK_OUT))
+			return NF_STOLEN;
+	}
+	return NF_ACCEPT;
+}
+
+static struct nf_hook_ops ipv4_defrag_ops[] = {
+	{
+		.hook		= ipv4_conntrack_defrag,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum	= NF_INET_PRE_ROUTING,
+		.priority	= NF_IP_PRI_CONNTRACK_DEFRAG,
+	},
+	{
+		.hook           = ipv4_conntrack_defrag,
+		.owner          = THIS_MODULE,
+		.pf             = PF_INET,
+		.hooknum        = NF_INET_LOCAL_OUT,
+		.priority       = NF_IP_PRI_CONNTRACK_DEFRAG,
+	},
+};
+
+static int __init nf_defrag_init(void)
+{
+	return nf_register_hooks(ipv4_defrag_ops, ARRAY_SIZE(ipv4_defrag_ops));
+}
+
+static void __exit nf_defrag_fini(void)
+{
+	nf_unregister_hooks(ipv4_defrag_ops, ARRAY_SIZE(ipv4_defrag_ops));
+}
+
+void nf_defrag_ipv4_enable(void)
+{
+}
+EXPORT_SYMBOL_GPL(nf_defrag_ipv4_enable);
+
+module_init(nf_defrag_init);
+module_exit(nf_defrag_fini);
+
+MODULE_LICENSE("GPL");


