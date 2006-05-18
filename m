From: James Morris <jmorris@namei.org>
Subject: [PATCH 06/07] secmark: Add CONNSECMARK xtables target
Date: Thu, 18 May 2006 05:28:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605180527130.569@d.namei>
References: <Pine.LNX.4.64.0605180458130.569@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	Karl MacMillan <kmacmillan@tresys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:1423 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751111AbWERJ2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 05:28:18 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605180458130.569@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new xtables target, CONNSECMARK, which is used to 
specify rules for copying security marks from packets to connections, and 
for copyying security marks back from connections to packets.  This is 
similar to the CONNMARK target, but is more limited in scope in that it 
only allows copying of security marks to and from packets, as this is all 
it needs to do.

A typical scenario would be to apply a security mark to a 'new' packet 
with SECMARK, then copy that to its conntrack via CONNMARK, and then 
restore the security mark from the connection to established and related 
packets on that connection.

Please apply.

Signed-off-by: James Morris <jmorris@namei.org>

---

 include/linux/netfilter/xt_CONNSECMARK.h |   13 ++
 net/netfilter/Kconfig                    |   11 ++
 net/netfilter/Makefile                   |    1 
 net/netfilter/xt_CONNSECMARK.c           |  155 +++++++++++++++++++++++++++++++
 4 files changed, 180 insertions(+)


diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/include/linux/netfilter/xt_CONNSECMARK.h linux-2.6.17-rc4-mm1.w/include/linux/netfilter/xt_CONNSECMARK.h
--- linux-2.6.17-rc4-mm1.p/include/linux/netfilter/xt_CONNSECMARK.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.17-rc4-mm1.w/include/linux/netfilter/xt_CONNSECMARK.h	2006-05-17 19:54:52.000000000 -0400
@@ -0,0 +1,13 @@
+#ifndef _XT_CONNSECMARK_H_target
+#define _XT_CONNSECMARK_H_target
+
+enum {
+	CONNSECMARK_SAVE = 1,
+	CONNSECMARK_RESTORE,
+};
+
+struct xt_connsecmark_target_info {
+	u_int8_t mode;
+};
+
+#endif /*_XT_CONNSECMARK_H_target */
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/net/netfilter/Kconfig linux-2.6.17-rc4-mm1.w/net/netfilter/Kconfig
--- linux-2.6.17-rc4-mm1.p/net/netfilter/Kconfig	2006-05-17 19:54:43.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/net/netfilter/Kconfig	2006-05-17 19:54:52.000000000 -0400
@@ -195,6 +195,17 @@ config NETFILTER_XT_TARGET_SECMARK
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_TARGET_CONNSECMARK
+	tristate '"CONNSECMARK" target support'
+	depends on NETFILTER_XTABLES && (NF_CONNTRACK_SECMARK || IP_NF_CONNTRACK_SECMARK)
+	help
+	  The CONNSECMARK target copies security markings from packets
+	  to connections, and restores security markings from connections
+	  to packets (if the packets are not already marked).  This would
+	  normally be used in conjunction with the SECMARK target.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_COMMENT
 	tristate  '"comment" match support'
 	depends on NETFILTER_XTABLES
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/net/netfilter/Makefile linux-2.6.17-rc4-mm1.w/net/netfilter/Makefile
--- linux-2.6.17-rc4-mm1.p/net/netfilter/Makefile	2006-05-17 19:53:39.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/net/netfilter/Makefile	2006-05-17 19:54:52.000000000 -0400
@@ -29,6 +29,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_MARK) +
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NOTRACK) += xt_NOTRACK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) += xt_SECMARK.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
 
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/net/netfilter/xt_CONNSECMARK.c linux-2.6.17-rc4-mm1.w/net/netfilter/xt_CONNSECMARK.c
--- linux-2.6.17-rc4-mm1.p/net/netfilter/xt_CONNSECMARK.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.17-rc4-mm1.w/net/netfilter/xt_CONNSECMARK.c	2006-05-17 19:55:25.000000000 -0400
@@ -0,0 +1,155 @@
+/*
+ * This module is used to copy security markings from packets
+ * to connections, and restore security markings from connections
+ * back to packets.  This would normally be performed in conjunction
+ * with the SECMARK target and state match.
+ *
+ * Based somewhat on CONNMARK: 
+ *   Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
+ *    by Henrik Nordstrom <hno@marasystems.com>
+ * 
+ * (C) 2006 Red Hat, Inc., James Morris <jmorris@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_CONNSECMARK.h>
+#include <net/netfilter/nf_conntrack_compat.h>
+
+#define PFX "CONNSECMARK: "
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("James Morris <jmorris@redhat.com>");
+MODULE_DESCRIPTION("ip[6]tables CONNSECMARK module");
+MODULE_ALIAS("ipt_CONNSECMARK");
+MODULE_ALIAS("ip6t_CONNSECMARK");
+
+/*
+ * If the packet has a security mark and the connection does not, copy
+ * the security mark from the packet to the connection.
+ */
+static void secmark_save(struct sk_buff *skb)
+{
+	if (skb->secmark) {
+		u32 *connsecmark;
+		enum ip_conntrack_info ctinfo;
+		
+		connsecmark = nf_ct_get_secmark(skb, &ctinfo);
+		if (connsecmark && !*connsecmark)
+			if (*connsecmark != skb->secmark)
+				*connsecmark = skb->secmark;
+	}
+}
+
+/*
+ * If packet has no security mark, and the connection does, restore the
+ * security mark from the connection to the packet.
+ */
+static void secmark_restore(struct sk_buff *skb)
+{
+	if (!skb->secmark) {
+		u32 *connsecmark;
+		enum ip_conntrack_info ctinfo;
+		
+		connsecmark = nf_ct_get_secmark(skb, &ctinfo);
+		if (connsecmark && *connsecmark)
+			if (skb->secmark != *connsecmark)
+				skb->secmark = *connsecmark;
+	}
+}
+
+static unsigned int target(struct sk_buff **pskb, const struct net_device *in,
+			   const struct net_device *out, unsigned int hooknum,
+			   const struct xt_target *target,
+			   const void *targinfo, void *userinfo)
+{
+	struct sk_buff *skb = *pskb;
+	const struct xt_connsecmark_target_info *info = targinfo;
+
+	switch (info->mode) {
+	case CONNSECMARK_SAVE:
+		secmark_save(skb);
+		break;
+		
+	case CONNSECMARK_RESTORE:
+		secmark_restore(skb);
+		break;
+	
+	default:
+		BUG();
+	}
+
+	return XT_CONTINUE;
+}
+
+static int checkentry(const char *tablename, const void *entry,
+		      const struct xt_target *target, void *targinfo,
+		      unsigned int targinfosize, unsigned int hook_mask)
+{
+	struct xt_connsecmark_target_info *info = targinfo;
+
+	switch (info->mode) {
+	case CONNSECMARK_SAVE:
+	case CONNSECMARK_RESTORE:
+		break;
+	
+	default:
+		printk(KERN_INFO PFX "invalid mode: %hu\n", info->mode);
+		return 0;
+	}
+	
+	return 1;
+}
+
+static struct xt_target ipt_connsecmark_reg = {
+	.name		= "CONNSECMARK",
+	.target		= target,
+	.targetsize	= sizeof(struct xt_connsecmark_target_info),
+	.table		= "mangle",
+	.checkentry	= checkentry,
+	.me		= THIS_MODULE,
+	.family		= AF_INET,
+	.revision	= 0,
+};
+
+static struct xt_target ip6t_connsecmark_reg = {
+	.name		= "CONNSECMARK",
+	.target		= target,
+	.targetsize	= sizeof(struct xt_connsecmark_target_info),
+	.table		= "mangle",
+	.checkentry	= checkentry,
+	.me		= THIS_MODULE,
+	.family		= AF_INET6,
+	.revision	= 0,
+};
+
+static int __init xt_connsecmark_init(void)
+{
+	int err;
+
+	need_conntrack();
+
+	err = xt_register_target(&ipt_connsecmark_reg);
+	if (err)
+		return err;
+
+	err = xt_register_target(&ip6t_connsecmark_reg);
+	if (err)
+		xt_unregister_target(&ipt_connsecmark_reg);
+
+	return err;
+}
+
+static void __exit xt_connsecmark_fini(void)
+{
+	xt_unregister_target(&ip6t_connsecmark_reg);
+	xt_unregister_target(&ipt_connsecmark_reg);
+}
+
+module_init(xt_connsecmark_init);
+module_exit(xt_connsecmark_fini);
