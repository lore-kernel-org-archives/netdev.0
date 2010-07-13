From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [PATCH v2] netfilter: xtables: userspace notification target
Date: Tue, 13 Jul 2010 16:57:11 +0200
Message-ID: <20100713145709.GA9809@sortiz-mobl>
References: <20100713001115.GA3751@sortiz-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Luciano Coelho <luciano.coelho@nokia.com>,
	sameo@linux.intel.com, Jan Engelhardt <jengelh@medozas.de>,
	Changli Gao <xiaosuo@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:16109 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753158Ab0GMO5a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jul 2010 10:57:30 -0400
Content-Disposition: inline
In-Reply-To: <20100713001115.GA3751@sortiz-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The userspace notification Xtables target sends a netlink notification
whenever a packet hits the target. Notifications have a label attribute
for userspace to match it against a previously set rule. The rules also
take a --all option to switch between sending a notification for all
packets or for the first one only.
Userspace can also send a netlink message to toggle this switch while the
target is in place. This target uses the nefilter netlink framework.

This target combined with various matches (quota, rateest, etc..) allows
userspace to make decisions on interfaces handling. One could for example
decide to switch between power saving modes depending on estimated rate
thresholds.

Reviewed-by: Luciano Coelho <luciano.coelho@nokia.com>
Signed-off-by: Samuel Ortiz <sameo@linux.intel.com>
---
v2:
- Remove the work structure and make the netlink sending routine atomic.
- Reformat struct nfnotif_tg to get rid of unnecessary padding holes.
---
 include/linux/netfilter/Kbuild             |    1 +
 include/linux/netfilter/nfnetlink.h        |    5 +-
 include/linux/netfilter/nfnetlink_compat.h |    1 +
 include/linux/netfilter/xt_NFNOTIF.h       |   55 ++++++
 net/netfilter/Kconfig                      |   17 ++
 net/netfilter/Makefile                     |    1 +
 net/netfilter/xt_NFNOTIF.c                 |  287 ++++++++++++++++++++++++++++
 7 files changed, 366 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/netfilter/xt_NFNOTIF.h
 create mode 100644 net/netfilter/xt_NFNOTIF.c

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index bb103f4..1b80b27 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -12,6 +12,7 @@ header-y += xt_IDLETIMER.h
 header-y += xt_LED.h
 header-y += xt_MARK.h
 header-y += xt_NFLOG.h
+header-y += xt_NFNOTIF.h
 header-y += xt_NFQUEUE.h
 header-y += xt_RATEEST.h
 header-y += xt_SECMARK.h
diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 361d6b5..e336f03 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -18,6 +18,8 @@ enum nfnetlink_groups {
 #define NFNLGRP_CONNTRACK_EXP_UPDATE	NFNLGRP_CONNTRACK_EXP_UPDATE
 	NFNLGRP_CONNTRACK_EXP_DESTROY,
 #define NFNLGRP_CONNTRACK_EXP_DESTROY	NFNLGRP_CONNTRACK_EXP_DESTROY
+	NFNLGRP_NFNOTIF,
+#define NFNLGRP_NFNOTIF	                NFNLGRP_NFNOTIF
 	__NFNLGRP_MAX,
 };
 #define NFNLGRP_MAX	(__NFNLGRP_MAX - 1)
@@ -47,7 +49,8 @@ struct nfgenmsg {
 #define NFNL_SUBSYS_QUEUE		3
 #define NFNL_SUBSYS_ULOG		4
 #define NFNL_SUBSYS_OSF			5
-#define NFNL_SUBSYS_COUNT		6
+#define NFNL_SUBSYS_NFNOTIF		6
+#define NFNL_SUBSYS_COUNT		7
 
 #ifdef __KERNEL__
 
diff --git a/include/linux/netfilter/nfnetlink_compat.h b/include/linux/netfilter/nfnetlink_compat.h
index ffb9503..dca8ab2 100644
--- a/include/linux/netfilter/nfnetlink_compat.h
+++ b/include/linux/netfilter/nfnetlink_compat.h
@@ -13,6 +13,7 @@
 #define NF_NETLINK_CONNTRACK_EXP_NEW		0x00000008
 #define NF_NETLINK_CONNTRACK_EXP_UPDATE		0x00000010
 #define NF_NETLINK_CONNTRACK_EXP_DESTROY	0x00000020
+#define NF_NETLINK_NFNOTIF			0x00000040
 
 /* Generic structure for encapsulation optional netfilter information.
  * It is reminiscent of sockaddr, but with sa_family replaced
diff --git a/include/linux/netfilter/xt_NFNOTIF.h b/include/linux/netfilter/xt_NFNOTIF.h
new file mode 100644
index 0000000..8fae827
--- /dev/null
+++ b/include/linux/netfilter/xt_NFNOTIF.h
@@ -0,0 +1,55 @@
+/*
+ * linux/include/linux/netfilter/xt_NFNOTIF.h
+ *
+ * Header file for Xtables notification target module.
+ *
+ * Copyright (C) 2010 Intel Corporation
+ * Samuel Ortiz <samuel.ortiz@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA.
+ */
+
+#ifndef _XT_NFNOTIF_H
+#define _XT_NFNOTIF_H
+
+#include <linux/types.h>
+
+enum nfnotif_msg_type {
+	NFNOTIF_TG_MSG_PACKETS,
+
+	NFNOTIF_TG_MSG_MAX
+};
+
+enum nfnotif_attr_type {
+	NFNOTIF_TG_ATTR_UNSPEC,
+	NFNOTIF_TG_ATTR_LABEL,
+	NFNOTIF_TG_ATTR_SEND_NOTIF,
+
+	__NFNOTIF_TG_ATTR_AFTER_LAST
+};
+#define NFNOTIF_TG_ATTR_MAX (__NFNOTIF_TG_ATTR_AFTER_LAST - 1)
+
+#define MAX_NFNOTIF_LABEL_SIZE 31
+
+struct nfnotif_tg_info {
+	__u8 all_packets;
+
+	char label[MAX_NFNOTIF_LABEL_SIZE];
+
+	/* for kernel module internal use only */
+	struct nfnotif_tg *notif __attribute((aligned(8)));
+};
+
+#endif
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index aa2f106..0e2de36 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -469,6 +469,23 @@ config NETFILTER_XT_TARGET_NFQUEUE
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_TARGET_NFNOTIF
+	tristate '"NFNOTIF" target Support'
+	depends on NETFILTER_ADVANCED
+	select NETFILTER_NETLINK
+	help
+
+	  This option adds the `NFNOTIF' target, which allows to send
+	  netfilter netlink messages when packets hit the target.
+
+	  This target comes with an option to specify if one wants all
+	  packets hitting the target to trigger the netlink message
+	  transmission, or only the first one.
+	  It also listen on its netfilter netlink subsystem for messages
+	  allowing to reset the above option.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_TARGET_NOTRACK
 	tristate  '"NOTRACK" target support'
 	depends on IP_NF_RAW || IP6_NF_RAW
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index e28420a..5d9c9e9 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -62,6 +62,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP) += xt_TCPOPTSTRIP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TEE) += xt_TEE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TRACE) += xt_TRACE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_IDLETIMER) += xt_IDLETIMER.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_NFNOTIF) += xt_NFNOTIF.o
 
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) += xt_cluster.o
diff --git a/net/netfilter/xt_NFNOTIF.c b/net/netfilter/xt_NFNOTIF.c
new file mode 100644
index 0000000..75ddeba
--- /dev/null
+++ b/net/netfilter/xt_NFNOTIF.c
@@ -0,0 +1,287 @@
+/*
+ * linux/net/netfilter/xt_NFNOTIF.c
+ *
+ * Copyright (C) 2010 Intel Corporation
+ * Samuel Ortiz <samuel.ortiz@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA.
+ *
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/xt_NFNOTIF.h>
+
+struct nfnotif_tg {
+	struct list_head entry;
+
+	char *label;
+	struct net *net;
+	unsigned int refcnt;
+	__u8 all_packets;
+	__u8 send_notif;
+};
+
+static LIST_HEAD(nfnotif_tg_list);
+static DEFINE_MUTEX(list_mutex);
+
+static int __nfnotif_tg_netlink_send(struct nfnotif_tg *nfnotif)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	struct sk_buff *skb;
+	struct net *net = nfnotif->net;
+	unsigned int type;
+	int flags;
+
+	type = NFNL_SUBSYS_NFNOTIF << 8;
+	flags = NLM_F_CREATE;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
+	if (skb == NULL)
+		goto error_out;
+
+	nlh = nlmsg_put(skb, 0, 0, type, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_put_failure;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->version	    = NFNETLINK_V0;
+	nfmsg->res_id	    = 0;
+
+	NLA_PUT_STRING(skb, NFNOTIF_TG_ATTR_LABEL, nfnotif->label);
+
+	nlmsg_end(skb, nlh);
+
+	return nfnetlink_send(skb, net, 0, NFNLGRP_NFNOTIF, 0, GFP_ATOMIC);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+
+nlmsg_put_failure:
+	kfree_skb(skb);
+
+error_out:
+	return nfnetlink_set_err(net, 0, 0, -ENOBUFS);
+}
+
+static struct nfnotif_tg *__nfnotif_tg_find_by_label(const char *label)
+{
+	struct nfnotif_tg *entry;
+
+	BUG_ON(!label);
+
+	list_for_each_entry(entry, &nfnotif_tg_list, entry) {
+		if (!strcmp(label, entry->label))
+			return entry;
+	}
+
+	return NULL;
+}
+
+static int nfnotif_tg_create(struct nfnotif_tg_info *info)
+{
+	info->notif = kmalloc(sizeof(*info->notif), GFP_KERNEL);
+	if (!info->notif) {
+		pr_debug("Couldn't allocate notification\n");
+		return -ENOMEM;
+	}
+
+	info->notif->label = kstrdup(info->label, GFP_KERNEL);
+	if (!info->notif->label) {
+		pr_debug("Couldn't allocate label\n");
+		kfree(info->notif);
+		return -ENOMEM;
+	}
+
+	info->notif->all_packets = info->all_packets;
+	info->notif->send_notif = 1;
+
+	list_add(&info->notif->entry, &nfnotif_tg_list);
+
+	info->notif->refcnt = 1;
+
+	return 0;
+}
+
+static unsigned int nfnotif_tg_target(struct sk_buff *skb,
+				      const struct xt_action_param *par)
+{
+	const struct nfnotif_tg_info *info = par->targinfo;
+
+	BUG_ON(!info->notif);
+
+	if (!info->notif->send_notif)
+		return XT_CONTINUE;
+
+	pr_debug("Sending notification for %s\n", info->label);
+
+	if (__nfnotif_tg_netlink_send(info->notif) < 0)
+		pr_debug("Could not send notification");
+
+	if (!info->notif->all_packets)
+		info->notif->send_notif = 0;
+
+	return XT_CONTINUE;
+}
+
+static int nfnotif_tg_checkentry(const struct xt_tgchk_param *par)
+{
+	struct nfnotif_tg_info *info = par->targinfo;
+	int ret;
+
+	pr_debug("Checkentry targinfo %s\n", info->label);
+
+	if (info->label[0] == '\0' ||
+	    strnlen(info->label,
+		    MAX_NFNOTIF_LABEL_SIZE) == MAX_NFNOTIF_LABEL_SIZE) {
+		pr_debug("Label is empty or not nul-terminated\n");
+		return -EINVAL;
+	}
+
+	mutex_lock(&list_mutex);
+
+	info->notif = __nfnotif_tg_find_by_label(info->label);
+	if (info->notif) {
+		info->notif->refcnt++;
+
+		pr_debug("Increased refcnt for %s to %u\n",
+			 info->label, info->notif->refcnt);
+	} else {
+		ret = nfnotif_tg_create(info);
+		if (ret < 0) {
+			pr_debug("Failed to create notification\n");
+			mutex_unlock(&list_mutex);
+			return ret;
+		}
+	}
+
+	info->notif->net = par->net;
+
+	mutex_unlock(&list_mutex);
+	return 0;
+}
+
+static void nfnotif_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	const struct nfnotif_tg_info *info = par->targinfo;
+
+	pr_debug("Destroy targinfo %s\n", info->label);
+
+	mutex_lock(&list_mutex);
+
+	if (--info->notif->refcnt == 0) {
+		pr_debug("Deleting notification %s\n", info->label);
+
+		list_del(&info->notif->entry);
+		kfree(info->notif->label);
+		kfree(info->notif);
+	}
+
+	mutex_unlock(&list_mutex);
+}
+
+static struct xt_target nfnotif_tg __read_mostly = {
+	.name		= "NFNOTIF",
+	.family		= NFPROTO_UNSPEC,
+	.target		= nfnotif_tg_target,
+	.targetsize     = sizeof(struct nfnotif_tg_info),
+	.checkentry	= nfnotif_tg_checkentry,
+	.destroy        = nfnotif_tg_destroy,
+	.me		= THIS_MODULE,
+};
+
+static int nfnotif_msg_send_notif(struct sock *nfnl, struct sk_buff *skb,
+				  const struct nlmsghdr *nlh,
+				  const struct nlattr * const attrs[])
+{
+	struct nfnotif_tg *notif;
+	char *label;
+	u8 send_notif;
+
+	if (attrs[NFNOTIF_TG_ATTR_LABEL] == NULL ||
+	    attrs[NFNOTIF_TG_ATTR_SEND_NOTIF] == NULL)
+		return -EINVAL;
+
+	label = nla_data(attrs[NFNOTIF_TG_ATTR_LABEL]);
+	send_notif = nla_get_u8(attrs[NFNOTIF_TG_ATTR_SEND_NOTIF]);
+
+	pr_debug("Label %s send %d\n", label, send_notif);
+
+	notif = __nfnotif_tg_find_by_label(label);
+	if (notif == NULL)
+		return -EINVAL;
+
+	notif->send_notif = send_notif;
+
+	return 0;
+}
+
+
+static const struct nla_policy nfnotif_nla_policy[NFNOTIF_TG_ATTR_MAX + 1] = {
+	[NFNOTIF_TG_ATTR_LABEL]            = { .type = NLA_NUL_STRING },
+	[NFNOTIF_TG_ATTR_SEND_NOTIF]	   = { .type = NLA_U8 },
+};
+
+static const struct nfnl_callback nfnotif_cb[NFNOTIF_TG_MSG_MAX] = {
+	[NFNOTIF_TG_MSG_PACKETS]   = { .call = nfnotif_msg_send_notif,
+				       .attr_count = NFNOTIF_TG_ATTR_MAX,
+				       .policy = nfnotif_nla_policy },
+};
+
+static const struct nfnetlink_subsystem nfnotif_subsys = {
+	.name				= "nfnotif",
+	.subsys_id			= NFNL_SUBSYS_NFNOTIF,
+	.cb_count			= NFNOTIF_TG_MSG_MAX,
+	.cb				= nfnotif_cb,
+};
+
+static int __init nfnotif_tg_init(void)
+{
+	int ret;
+
+	ret = nfnetlink_subsys_register(&nfnotif_subsys);
+	if (ret < 0) {
+		pr_err("%s: Cannot register with nfnetlink\n", __func__);
+		return ret;
+	}
+
+	ret = xt_register_target(&nfnotif_tg);
+	if (ret < 0) {
+		pr_err("%s: Cannot register target\n", __func__);
+		nfnetlink_subsys_unregister(&nfnotif_subsys);
+	}
+
+	return ret;
+}
+
+static void __exit nfnotif_tg_exit(void)
+{
+	nfnetlink_subsys_unregister(&nfnotif_subsys);
+	xt_unregister_target(&nfnotif_tg);
+}
+
+module_init(nfnotif_tg_init);
+module_exit(nfnotif_tg_exit);
+
+MODULE_AUTHOR("Samuel Ortiz <samuel.ortiz@intel.com>");
+MODULE_DESCRIPTION("Xtables: userspace notification");
+MODULE_LICENSE("GPL v2");
-- 
1.7.1

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
