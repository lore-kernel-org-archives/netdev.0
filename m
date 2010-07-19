From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [RFC 2/2] netfilter: xtables: implement CONDITION target
Date: Mon, 19 Jul 2010 17:15:47 +0300
Message-ID: <1279548947-10470-3-git-send-email-luciano.coelho@nokia.com>
References: <1279548947-10470-1-git-send-email-luciano.coelho@nokia.com>
Cc: netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	sameo@linux.intel.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:27858 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934078Ab0GSOQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 10:16:08 -0400
In-Reply-To: <1279548947-10470-1-git-send-email-luciano.coelho@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luciano Coelho <coelho@testbed>

This patch implements a condition target, which let's the user set
netfilter rules that enable/disable the conditions used by the
condition match.  Originally, the condition match only allowed the
variable to be changed via procfs.  This new target makes it easy to
enable or disable the condition depending on the rules set.

Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
---
 include/linux/netfilter/Kbuild         |    1 +
 include/linux/netfilter/xt_CONDITION.h |   39 +++++++++++
 net/netfilter/Kconfig                  |   12 ++++
 net/netfilter/Makefile                 |    1 +
 net/netfilter/xt_CONDITION.c           |  112 ++++++++++++++++++++++++++++++++
 5 files changed, 165 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_CONDITION.h
 create mode 100644 net/netfilter/xt_CONDITION.c

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index c57e099..72eff3a 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -4,6 +4,7 @@ header-y += nfnetlink_conntrack.h
 header-y += nfnetlink_log.h
 header-y += nfnetlink_queue.h
 header-y += xt_CLASSIFY.h
+header-y += xt_CONDITION.h
 header-y += xt_CONNMARK.h
 header-y += xt_CONNSECMARK.h
 header-y += xt_CT.h
diff --git a/include/linux/netfilter/xt_CONDITION.h b/include/linux/netfilter/xt_CONDITION.h
new file mode 100644
index 0000000..cbffe3f
--- /dev/null
+++ b/include/linux/netfilter/xt_CONDITION.h
@@ -0,0 +1,39 @@
+/*
+ * linux/include/linux/netfilter/xt_CONDITION.h
+ *
+ * Header file for Xtables timer target module.
+ *
+ * Copyright (C) 2010 Nokia Corporation
+ *
+ * Contact: Luciano Coelho <luciano.coelho@nokia.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#ifndef _XT_CONDITION_TG_H
+#define _XT_CONDITION_TG_H
+
+#include <linux/types.h>
+#include <linux/netfilter/xt_condition.h>
+
+struct condition_tg_info {
+	char name[XT_CONDITION_MAX_NAME_SIZE + 1];
+	__u8 enabled;
+
+	/* Used internally by the kernel */
+	void *condvar __attribute__((aligned(8)));
+};
+
+#endif
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index e54e216..1877c6a 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -310,6 +310,18 @@ config NETFILTER_XT_MARK
 	"Use netfilter MARK value as routing key") and can also be used by
 	other subsystems to change their behavior.
 
+config NETFILTER_XT_TARGET_CONDITION
+	tristate  "'CONDITION' target support"
+	depends on NETFILTER_ADVANCED
+	select NETFILTER_XT_MATCH_CONDITION
+	help
+
+	  Allows changing the condition match value in procfs from the
+	  netfilter tables, without requiring userspace to change the
+	  condition value.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_CONNMARK
 	tristate 'ctmark target and match support'
 	depends on NF_CONNTRACK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 474dd06..9237a67 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -46,6 +46,7 @@ obj-$(CONFIG_NETFILTER_XT_CONNMARK) += xt_connmark.o
 
 # targets
 obj-$(CONFIG_NETFILTER_XT_TARGET_CLASSIFY) += xt_CLASSIFY.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_CONDITION) += xt_CONDITION.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CT) += xt_CT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) += xt_DSCP.o
diff --git a/net/netfilter/xt_CONDITION.c b/net/netfilter/xt_CONDITION.c
new file mode 100644
index 0000000..8150352
--- /dev/null
+++ b/net/netfilter/xt_CONDITION.c
@@ -0,0 +1,112 @@
+/*
+ * linux/net/netfilter/xt_CONDITION.c
+ *
+ * Netfilter module to trigger a timer when packet matches.
+ * After timer expires a kevent will be sent.
+ *
+ * Copyright (C) 2010 Nokia Corporation
+ *
+ * Contact: Luciano Coelho <luciano.coelho@nokia.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_CONDITION.h>
+
+static unsigned int condition_tg_target(struct sk_buff *skb,
+					 const struct xt_action_param *par)
+{
+	const struct condition_tg_info *info = par->targinfo;
+
+	pr_debug("setting condition %s, enabled %d\n",
+		 info->name, info->enabled);
+
+	xt_condition_set(info->condvar, info->enabled);
+
+	return XT_CONTINUE;
+}
+
+static int condition_tg_checkentry(const struct xt_tgchk_param *par)
+{
+	struct condition_tg_info *info = par->targinfo;
+	struct condition_variable *var;
+
+	pr_debug("checkentry %s\n", info->name);
+
+	/* Forbid certain names */
+	if (*info->name == '\0' || *info->name == '.' ||
+	    info->name[sizeof(info->name)-1] != '\0' ||
+	    memchr(info->name, '/', sizeof(info->name)) != NULL) {
+		pr_info("name not allowed or too long: \"%.*s\"\n",
+			(unsigned int)sizeof(info->name), info->name);
+		return -EINVAL;
+	}
+
+	var = xt_condition_insert(info->name);
+	if (var == NULL)
+		return -ENOMEM;
+
+	info->condvar = var;
+	return 0;
+}
+
+static void condition_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	const struct condition_tg_info *info = par->targinfo;
+
+	pr_debug("destroy %s\n", info->name);
+
+	xt_condition_put(info->condvar);
+}
+
+static struct xt_target condition_tg __read_mostly = {
+	.name		= "CONDITION",
+	.family		= NFPROTO_UNSPEC,
+	.target		= condition_tg_target,
+	.targetsize     = sizeof(struct condition_tg_info),
+	.checkentry	= condition_tg_checkentry,
+	.destroy        = condition_tg_destroy,
+	.me		= THIS_MODULE,
+};
+
+static int __init condition_tg_init(void)
+{
+	int err;
+
+	err =  xt_register_target(&condition_tg);
+	if (err < 0) {
+		pr_debug("couldn't register xt target\n");
+		return err;
+	}
+
+	return 0;
+}
+
+static void __exit condition_tg_exit(void)
+{
+	xt_unregister_target(&condition_tg);
+}
+
+module_init(condition_tg_init);
+module_exit(condition_tg_exit);
+
+MODULE_AUTHOR("Luciano Coelho <luciano.coelho@nokia.com>");
+MODULE_DESCRIPTION("Xtables: condition target");
+MODULE_LICENSE("GPL v2");
-- 
1.7.0.4

