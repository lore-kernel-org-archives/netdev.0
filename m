From: James Morris <jmorris@namei.org>
Subject: [RFC][SECMARK 03/08] Add xtables SECMARK target
Date: Sun, 7 May 2006 11:35:19 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605071134250.8588@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@lists.samba.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:26601 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932184AbWEGPfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 11:35:22 -0400
To: selinux@tycho.nsa.gov
In-Reply-To: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a SECMARK target to xtables, allowing
the admin to apply security marks to packets via both
iptables and ip6tables.

The target currently handles SELinux security marking,
but can be extended for other purposes as needed.


Signed-off-by: James Morris <jmorris@namei.org>

---

 include/linux/netfilter/xt_SECMARK.h |   26 ++++++
 net/netfilter/Kconfig                |    9 ++
 net/netfilter/Makefile               |    1 
 net/netfilter/xt_SECMARK.c           |  150 +++++++++++++++++++++++++++++++++++
 4 files changed, 186 insertions(+)

diff -purN -X dontdiff linux-2.6.17-rc2.p/include/linux/netfilter/xt_SECMARK.h linux-2.6.17-rc2.w/include/linux/netfilter/xt_SECMARK.h
--- linux-2.6.17-rc2.p/include/linux/netfilter/xt_SECMARK.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.17-rc2.w/include/linux/netfilter/xt_SECMARK.h	2006-04-25 02:35:45.000000000 -0400
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
diff -purN -X dontdiff linux-2.6.17-rc2.p/net/netfilter/Kconfig linux-2.6.17-rc2.w/net/netfilter/Kconfig
--- linux-2.6.17-rc2.p/net/netfilter/Kconfig	2006-04-19 23:31:25.000000000 -0400
+++ linux-2.6.17-rc2.w/net/netfilter/Kconfig	2006-04-25 00:22:27.000000000 -0400
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
diff -purN -X dontdiff linux-2.6.17-rc2.p/net/netfilter/Makefile linux-2.6.17-rc2.w/net/netfilter/Makefile
--- linux-2.6.17-rc2.p/net/netfilter/Makefile	2006-04-19 23:31:25.000000000 -0400
+++ linux-2.6.17-rc2.w/net/netfilter/Makefile	2006-04-25 00:22:27.000000000 -0400
@@ -28,6 +28,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNMAR
 obj-$(CONFIG_NETFILTER_XT_TARGET_MARK) += xt_MARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NOTRACK) += xt_NOTRACK.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) += xt_SECMARK.o
 
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
diff -purN -X dontdiff linux-2.6.17-rc2.p/net/netfilter/xt_SECMARK.c linux-2.6.17-rc2.w/net/netfilter/xt_SECMARK.c
--- linux-2.6.17-rc2.p/net/netfilter/xt_SECMARK.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.17-rc2.w/net/netfilter/xt_SECMARK.c	2006-04-25 02:45:58.000000000 -0400
@@ -0,0 +1,150 @@
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
+		printk(KERN_INFO PFX "mode already set to %hhu cannot mix with "
+		       "rules for mode %hhu\n", mode, info->mode);
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
+		printk(KERN_INFO PFX "invalid mode: %hhu\n", info->mode);
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
