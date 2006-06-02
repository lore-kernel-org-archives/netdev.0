From: akpm@osdl.org
Subject: [patch 10/17] secmark: Add xtables SECMARK target
Date: Thu, 01 Jun 2006 20:32:30 -0700
Message-ID: <200606020328.k523SBwn028832@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:1717 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751206AbWFBD2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:19 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: James Morris <jmorris@namei.org>

Add a SECMARK target to xtables, allowing the admin to apply security marks to
packets via both iptables and ip6tables.

The target currently handles SELinux security marking, but can be extended
for other purposes as needed.

Signed-off-by: James Morris <jmorris@namei.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/linux/netfilter/xt_SECMARK.h |   26 ++++
 net/netfilter/Kconfig                |    9 +
 net/netfilter/Makefile               |    1 
 net/netfilter/xt_SECMARK.c           |  156 +++++++++++++++++++++++++
 4 files changed, 192 insertions(+)

diff -puN /dev/null include/linux/netfilter/xt_SECMARK.h
--- /dev/null	2006-06-01 17:04:03.273681250 -0700
+++ devel-akpm/include/linux/netfilter/xt_SECMARK.h	2006-06-01 20:31:50.000000000 -0700
@@ -0,0 +1,26 @@
+#ifndef _XT_SECMARK_H_target
+#define _XT_SECMARK_H_target
+
+/*
+ * This is intended for use by various security subsystems (but not
+ * at the same time).
+ *
+ * 'mode' refers to the specific security subsystem which the
+ * packets are being marked for.
+ */
+#define SECMARK_MODE_SEL	0x01		/* SELinux */
+#define SECMARK_SELCTX_MAX	256
+
+struct xt_secmark_target_selinux_info {
+	u_int32_t selsid;
+	char selctx[SECMARK_SELCTX_MAX];
+};
+
+struct xt_secmark_target_info {
+	u_int8_t mode;
+	union {
+		struct xt_secmark_target_selinux_info sel;
+	} u;
+};
+
+#endif /*_XT_SECMARK_H_target */
diff -puN net/netfilter/Kconfig~secmark-add-xtables-secmark-target net/netfilter/Kconfig
--- devel/net/netfilter/Kconfig~secmark-add-xtables-secmark-target	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/net/netfilter/Kconfig	2006-06-01 20:31:50.000000000 -0700
@@ -174,6 +174,15 @@ config NETFILTER_XT_TARGET_NOTRACK
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/modules.txt>.  If unsure, say `N'.
 
+config NETFILTER_XT_TARGET_SECMARK
+	tristate '"SECMARK" target support'
+	depends on NETFILTER_XTABLES && NETWORK_SECMARK
+	help
+	  The SECMARK target allows security marking of network
+	  packets, for use with security subsystems.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_COMMENT
 	tristate  '"comment" match support'
 	depends on NETFILTER_XTABLES
diff -puN net/netfilter/Makefile~secmark-add-xtables-secmark-target net/netfilter/Makefile
--- devel/net/netfilter/Makefile~secmark-add-xtables-secmark-target	2006-06-01 20:31:50.000000000 -0700
+++ devel-akpm/net/netfilter/Makefile	2006-06-01 20:31:50.000000000 -0700
@@ -28,6 +28,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNMAR
 obj-$(CONFIG_NETFILTER_XT_TARGET_MARK) += xt_MARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NOTRACK) += xt_NOTRACK.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) += xt_SECMARK.o
 
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
diff -puN /dev/null net/netfilter/xt_SECMARK.c
--- /dev/null	2006-06-01 17:04:03.273681250 -0700
+++ devel-akpm/net/netfilter/xt_SECMARK.c	2006-06-01 20:31:50.000000000 -0700
@@ -0,0 +1,156 @@
+/*
+ * Module for modifying the secmark field of the skb, for use by
+ * security subsystems.
+ *
+ * Based on the nfmark match by:
+ * (C) 1999-2001 Marc Boucher <marc@mbsi.ca>
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
+#include <linux/selinux.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_SECMARK.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("James Morris <jmorris@redhat.com>");
+MODULE_DESCRIPTION("ip[6]tables SECMARK modification module");
+MODULE_ALIAS("ipt_SECMARK");
+MODULE_ALIAS("ip6t_SECMARK");
+
+#define PFX "SECMARK: "
+
+static u8 mode;
+
+static unsigned int target(struct sk_buff **pskb, const struct net_device *in,
+			   const struct net_device *out, unsigned int hooknum,
+			   const struct xt_target *target,
+			   const void *targinfo, void *userinfo)
+{
+	u32 secmark = 0;
+	const struct xt_secmark_target_info *info = targinfo;
+
+	BUG_ON(info->mode != mode);
+
+	switch (mode) {
+	case SECMARK_MODE_SEL:
+		secmark = info->u.sel.selsid;
+		break;
+
+	default:
+		BUG();
+	}
+
+	if ((*pskb)->secmark != secmark)
+		(*pskb)->secmark = secmark;
+
+	return XT_CONTINUE;
+}
+
+static int checkentry_selinux(struct xt_secmark_target_info *info)
+{
+	int err;
+	struct xt_secmark_target_selinux_info *sel = &info->u.sel;
+
+	err = selinux_string_to_sid(sel->selctx, &sel->selsid);
+	if (err) {
+		if (err == -EINVAL)
+			printk(KERN_INFO PFX "invalid SELinux context \'%s\'\n",
+			       sel->selctx);
+		return 0;
+	}
+
+	if (!sel->selsid) {
+		printk(KERN_INFO PFX "unable to map SELinux context \'%s\'\n",
+		       sel->selctx);
+		return 0;
+	}
+
+	err = selinux_relabel_packet_permission(sel->selsid);
+	if (err) {
+		printk(KERN_INFO PFX "unable to obtain relabeling permission\n");
+		return 0;
+	}
+
+	return 1;
+}
+
+static int checkentry(const char *tablename, const void *entry,
+		      const struct xt_target *target, void *targinfo,
+		      unsigned int targinfosize, unsigned int hook_mask)
+{
+	struct xt_secmark_target_info *info = targinfo;
+
+	if (mode && mode != info->mode) {
+		printk(KERN_INFO PFX "mode already set to %hu cannot mix with "
+		       "rules for mode %hu\n", mode, info->mode);
+		return 0;
+	}
+
+	switch (info->mode) {
+	case SECMARK_MODE_SEL:
+		if (!checkentry_selinux(info))
+			return 0;
+		break;
+
+	default:
+		printk(KERN_INFO PFX "invalid mode: %hu\n", info->mode);
+		return 0;
+	}
+
+	if (!mode)
+		mode = info->mode;
+	return 1;
+}
+
+static struct xt_target ipt_secmark_reg = {
+	.name		= "SECMARK",
+	.target		= target,
+	.targetsize	= sizeof(struct xt_secmark_target_info),
+	.table		= "mangle",
+	.checkentry	= checkentry,
+	.me		= THIS_MODULE,
+	.family		= AF_INET,
+	.revision	= 0,
+};
+
+static struct xt_target ip6t_secmark_reg = {
+	.name		= "SECMARK",
+	.target		= target,
+	.targetsize	= sizeof(struct xt_secmark_target_info),
+	.table		= "mangle",
+	.checkentry	= checkentry,
+	.me		= THIS_MODULE,
+	.family		= AF_INET6,
+	.revision	= 0,
+};
+
+static int __init xt_secmark_init(void)
+{
+	int err;
+
+	err = xt_register_target(&ipt_secmark_reg);
+	if (err)
+		return err;
+
+	err = xt_register_target(&ip6t_secmark_reg);
+	if (err)
+		xt_unregister_target(&ipt_secmark_reg);
+
+	return err;
+}
+
+static void __exit xt_secmark_fini(void)
+{
+	xt_unregister_target(&ip6t_secmark_reg);
+	xt_unregister_target(&ipt_secmark_reg);
+}
+
+module_init(xt_secmark_init);
+module_exit(xt_secmark_fini);
_
