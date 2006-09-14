From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 1/3] cfg80211/nl80211 core
Date: Thu, 14 Sep 2006 12:49:23 +0200
Message-ID: <1158230963.2936.49.camel@ux156>
References: <1158230812.2936.46.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	Jiri Benc <jbenc@suse.cz>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49897 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751145AbWINKsn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 06:48:43 -0400
To: netdev@vger.kernel.org
In-Reply-To: <1158230812.2936.46.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds cfg80211/nl80211, a netlink based configuration
system for wireless hardware.

It currently features a few helper commands and commands to
add and remove virtual interfaces and to inject packets.
Support for nl80211 in d80211 is in a follow-up patch.

There should be support for notifications, but we need to figure
out if we remove the sysfs based add/remove virtual interface
thing completely or allow the driver to create a notification
through some new API here.

Modulo file renames and a bit of split ups, it is identical to previous
versions.

It requires the patches in
http://marc.theaimsgroup.com/?l=linux-netdev&m=115625436628696&w=2
and
http://marc.theaimsgroup.com/?l=linux-netdev&m=115625168405439&w=2

(the latter doesn't apply cleanly against wireless-dev, but you can
safely ignore the pieces that don't, at least for wireless testing :) )

It also requires the NLA_PUT_FLAG patch I did:
http://marc.theaimsgroup.com/?l=linux-netdev&m=115650333420169&w=2

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/Kconfig	2006-09-13 22:05:53.359647141 +0200
+++ wireless-dev/net/Kconfig	2006-09-13 22:06:10.529647141 +0200
@@ -250,6 +250,9 @@ source "net/ieee80211/Kconfig"
 config WIRELESS_EXT
 	bool
 
+config CFG80211
+	tristate
+
 endif   # if NET
 endmenu # Networking
 
--- wireless-dev.orig/net/Makefile	2006-09-13 22:05:53.389647141 +0200
+++ wireless-dev/net/Makefile	2006-09-13 22:06:10.529647141 +0200
@@ -44,6 +44,7 @@ obj-$(CONFIG_ECONET)		+= econet/
 obj-$(CONFIG_VLAN_8021Q)	+= 8021q/
 obj-$(CONFIG_IP_DCCP)		+= dccp/
 obj-$(CONFIG_IP_SCTP)		+= sctp/
+obj-$(CONFIG_CFG80211)		+= wireless/
 obj-$(CONFIG_D80211)		+= d80211/
 obj-$(CONFIG_IEEE80211)		+= ieee80211/
 obj-$(CONFIG_TIPC)		+= tipc/
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/Makefile	2006-09-13 22:06:10.529647141 +0200
@@ -0,0 +1,4 @@
+obj-$(CONFIG_CFG80211) += cfg80211.o
+
+cfg80211-objs := \
+	core.o nl80211.o
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/nl80211.c	2006-09-13 22:06:10.529647141 +0200
@@ -0,0 +1,395 @@
+/*
+ * This is the new netlink-based wireless configuration interface.
+ *
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ */
+
+#include <linux/if.h>
+#include <linux/module.h>
+#include <linux/err.h>
+#include <net/genetlink.h>
+#include <net/cfg80211.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include "core.h"
+#include "nl80211.h"
+
+/* the netlink family */
+static struct genl_family nl80211_fam = {
+	.id = GENL_ID_GENERATE,	/* don't bother with a hardcoded ID */
+	.name = "nl80211",	/* have users key off the name instead */
+	.hdrsize = 0,		/* no private header */
+	.version = 1,		/* no particular meaning now */
+	.maxattr = NL80211_ATTR_MAX,
+};
+
+/* policy for the attributes */
+static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
+	[NL80211_ATTR_IFINDEX] = { .type = NLA_U32 },
+	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
+	[NL80211_ATTR_FLAGS] = { .type = NLA_U32 },
+	[NL80211_ATTR_QUEUE] = { .type = NLA_U32 },
+	[NL80211_ATTR_FRAME] = { .type = NLA_STRING,
+				 .len = NL80211_MAX_FRAME_LEN },
+	[NL80211_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ-1 },
+	[NL80211_ATTR_IFTYPE] = { .type = NLA_U32 },
+};
+
+/* netlink command implementations */
+
+#define CHECK_CMD(ptr, cmd)				\
+	if (drv->ops->ptr)				\
+		NLA_PUT_FLAG(msg, NL80211_CMD_##cmd);
+
+static int nl80211_get_cmdlist(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_driver *drv;
+	struct sk_buff *msg;
+	void *hdr;
+	int err;
+	struct nlattr *start;
+
+	drv = cfg80211_get_drv_from_info(info);
+	if (IS_ERR(drv))
+		return PTR_ERR(drv);
+
+	hdr = nl80211msg_new(&msg, info->snd_pid, info->snd_seq, 0,
+			     NL80211_CMD_NEW_CMDLIST);
+	if (IS_ERR(hdr)) {
+		err = PTR_ERR(hdr);
+		goto put_drv;
+	}
+
+	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, drv->wiphy);
+
+	start = nla_nest_start(msg, NL80211_ATTR_CMDS);
+	if (!start)
+		goto nla_put_failure;
+
+	/* unconditionally allow some common commands we handle centrally */
+	NLA_PUT_FLAG(msg, NL80211_CMD_GET_CMDLIST);
+	NLA_PUT_FLAG(msg, NL80211_CMD_GET_WIPHYS);
+	NLA_PUT_FLAG(msg, NL80211_CMD_GET_INTERFACES);
+
+	CHECK_CMD(inject_packet, INJECT);
+	CHECK_CMD(add_virtual_intf, ADD_VIRTUAL_INTERFACE);
+	CHECK_CMD(del_virtual_intf, DEL_VIRTUAL_INTERFACE);
+
+	nla_nest_end(msg, start);
+
+	genlmsg_end(msg, hdr);
+
+	err = genlmsg_unicast(msg, info->snd_pid);
+	goto put_drv;
+
+ nla_put_failure:
+ 	err = -ENOBUFS;
+	nlmsg_free(msg);
+ put_drv:
+	cfg80211_put_drv(drv);
+	return err;
+}
+#undef CHECK_CMD
+
+static int nl80211_get_wiphys(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *msg;
+	void *hdr;
+	struct nlattr *start, *indexstart;
+	struct cfg80211_registered_driver *drv;
+	int idx = 1;
+
+	hdr = nl80211msg_new(&msg, info->snd_pid, info->snd_seq, 0,
+			     NL80211_CMD_NEW_WIPHYS);
+	if (IS_ERR(hdr))
+		return PTR_ERR(hdr);
+
+	start = nla_nest_start(msg, NL80211_ATTR_WIPHY_LIST);
+	if (!start)
+		goto nla_outer_nest_failure;
+
+	mutex_lock(&cfg80211_drv_mutex);
+	list_for_each_entry(drv, &cfg80211_drv_list, list) {
+		indexstart = nla_nest_start(msg, idx++);
+		if (!indexstart)
+			goto nla_put_failure;
+		NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, drv->wiphy);
+		nla_nest_end(msg, indexstart);
+	}
+	mutex_unlock(&cfg80211_drv_mutex);
+
+	nla_nest_end(msg, start);
+
+	genlmsg_end(msg, hdr);
+
+	return genlmsg_unicast(msg, info->snd_pid);
+
+ nla_put_failure:
+	mutex_unlock(&cfg80211_drv_mutex);
+ nla_outer_nest_failure:
+	nlmsg_free(msg);
+	return -ENOBUFS;
+}
+
+struct addifidx_cb {
+	int idx;
+	struct sk_buff *skb;
+};
+
+static int addifidx(void *data, int ifidx)
+{
+	struct addifidx_cb *cb = data;
+	struct net_device *dev = dev_get_by_index(ifidx);
+	int err = -ENOBUFS;
+	struct nlattr *start;
+
+	/* not that this can happen, since the caller
+	 * should hold the device open... */
+	if (!dev)
+		return -ENODEV;
+
+	start = nla_nest_start(cb->skb, cb->idx++);
+	if (!start)
+		goto nla_put_failure;
+
+	NLA_PUT_U32(cb->skb, NL80211_ATTR_IFINDEX, ifidx);
+	NLA_PUT_STRING(cb->skb, NL80211_ATTR_IFNAME, dev->name);
+
+	nla_nest_end(cb->skb, start);
+	err = 0;
+
+ nla_put_failure:
+	dev_put(dev);
+	return err;
+}
+
+static int nl80211_get_intfs(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_driver *drv;
+	struct sk_buff *msg;
+	void *hdr;
+	int err;
+	struct nlattr *start;
+	struct addifidx_cb cb;
+
+	drv = cfg80211_get_drv_from_info(info);
+	if (IS_ERR(drv))
+		return PTR_ERR(drv);
+
+	hdr = nl80211msg_new(&msg, info->snd_pid, info->snd_seq, 0,
+			     NL80211_CMD_GET_INTERFACES);
+	if (IS_ERR(hdr)) {
+		err = PTR_ERR(hdr);
+		goto put_drv;
+	}
+
+	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, drv->wiphy);
+
+	start = nla_nest_start(msg, NL80211_ATTR_INTERFACE_LIST);
+	if (!start) {
+		err = -ENOBUFS;
+		goto msg_free;
+	}
+
+	cb.skb = msg;
+	cb.idx = 1;
+	err = drv->ops->list_interfaces(drv->priv, &cb, addifidx);
+	if (err)
+		goto msg_free;
+
+	nla_nest_end(msg, start);
+
+	genlmsg_end(msg, hdr);
+
+	err = genlmsg_unicast(msg, info->snd_pid);
+	goto put_drv;
+
+ nla_put_failure:
+	err = -ENOBUFS;
+ msg_free:
+	nlmsg_free(msg);
+ put_drv:
+	cfg80211_put_drv(drv);
+	return err;
+}
+
+static int nl80211_do_inject(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_driver *drv;
+	u32 flags = 0;
+	int err, queue = -1;
+
+	if (!info->attrs[NL80211_ATTR_FRAME])
+		return -EINVAL;
+	if (info->attrs[NL80211_ATTR_FLAGS])
+		flags = nla_get_u32(info->attrs[NL80211_ATTR_FLAGS]);
+	if (info->attrs[NL80211_ATTR_QUEUE])
+		queue = (int) nla_get_u32(info->attrs[NL80211_ATTR_QUEUE]);
+
+	drv = cfg80211_get_drv_from_info(info);
+	if (IS_ERR(drv))
+		return PTR_ERR(drv);
+
+	if (!drv->ops->inject_packet) {
+		err = -ENOSYS;
+		goto unlock;
+	}
+
+	err = drv->ops->inject_packet(drv->priv,
+		nla_data(info->attrs[NL80211_ATTR_FRAME]),
+		nla_len(info->attrs[NL80211_ATTR_FRAME]),
+		flags,
+		queue);
+ unlock:
+	cfg80211_put_drv(drv);
+	return err;
+}
+
+static int nl80211_add_virt_intf(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_driver *drv;
+	int err;
+	unsigned int type = NL80211_IFTYPE_UNSPECIFIED;
+
+	if (!info->attrs[NL80211_ATTR_IFNAME])
+		return -EINVAL;
+
+	if (info->attrs[NL80211_ATTR_IFTYPE]) {
+		type = nla_get_u32(info->attrs[NL80211_ATTR_IFTYPE]);
+		if (type > NL80211_IFTYPE_MAX)
+			return -EINVAL;
+	}
+
+	drv = cfg80211_get_drv_from_info(info);
+	if (IS_ERR(drv))
+		return PTR_ERR(drv);
+
+	if (!drv->ops->add_virtual_intf) {
+		err = -ENOSYS;
+		goto unlock;
+	}
+
+	err = drv->ops->add_virtual_intf(drv->priv,
+		nla_data(info->attrs[NL80211_ATTR_IFNAME]), type);
+
+ unlock:
+	cfg80211_put_drv(drv);
+	return err;
+}
+
+static int nl80211_del_virt_intf(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_driver *drv;
+	int ifindex, err;
+
+	if (!info->attrs[NL80211_ATTR_IFINDEX])
+		return -EINVAL;
+
+	ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
+
+	drv = cfg80211_get_drv_from_info(info);
+	if (IS_ERR(drv))
+		return PTR_ERR(drv);
+
+	if (!drv->ops->del_virtual_intf) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	err = drv->ops->del_virtual_intf(drv->priv, ifindex);
+
+ out:
+	cfg80211_put_drv(drv);
+	return err;
+}
+
+static struct genl_ops nl80211_ops[] = {
+	{
+		.cmd = NL80211_CMD_GET_CMDLIST,
+		.doit = nl80211_get_cmdlist,
+		.policy = nl80211_policy,
+	},
+	{
+		.cmd = NL80211_CMD_GET_WIPHYS,
+		.doit = nl80211_get_wiphys,
+		.policy = nl80211_policy,
+	},
+	{
+		.cmd = NL80211_CMD_GET_INTERFACES,
+		.doit = nl80211_get_intfs,
+		.policy = nl80211_policy,
+	},
+	{
+		.cmd = NL80211_CMD_INJECT,
+		.doit = nl80211_do_inject,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_ADD_VIRTUAL_INTERFACE,
+		.doit = nl80211_add_virt_intf,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_DEL_VIRTUAL_INTERFACE,
+		.doit = nl80211_del_virt_intf,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+};
+
+
+/* exported functions */
+
+void *nl80211hdr_put(struct sk_buff *skb, u32 pid, u32 seq, int flags, u8 cmd)
+{
+	/* since there is no private header just add the generic one */
+	return genlmsg_put(skb, pid, seq, nl80211_fam.id, 0,
+			   flags, cmd, nl80211_fam.version);
+}
+EXPORT_SYMBOL_GPL(nl80211hdr_put);
+
+void *nl80211msg_new(struct sk_buff **skb, u32 pid, u32 seq, int flags, u8 cmd)
+{
+	void *hdr;
+
+	*skb = nlmsg_new(NLMSG_GOODSIZE);
+	if (!*skb)
+		return ERR_PTR(-ENOBUFS);
+
+	hdr = nl80211hdr_put(*skb, pid, seq, flags, cmd);
+	if (!hdr) {
+		nlmsg_free(*skb);
+		return ERR_PTR(-ENOBUFS);
+	}
+
+	return hdr;
+}
+EXPORT_SYMBOL_GPL(nl80211msg_new);
+
+/* initialisation/exit functions */
+
+int nl80211_init(void)
+{
+	int err, i;
+
+	err = genl_register_family(&nl80211_fam);
+	if (err)
+		return err;
+
+	for (i = 0; i < ARRAY_SIZE(nl80211_ops); i++) {
+		err = genl_register_ops(&nl80211_fam, &nl80211_ops[i]);
+		if (err)
+			goto err_out;
+	}
+	return 0;
+ err_out:
+ 	genl_unregister_family(&nl80211_fam);
+	return err;
+}
+
+void nl80211_exit(void)
+{
+	genl_unregister_family(&nl80211_fam);
+}
--- wireless-dev.orig/include/linux/Kbuild	2006-09-13 22:05:53.569647141 +0200
+++ wireless-dev/include/linux/Kbuild	2006-09-13 22:06:10.529647141 +0200
@@ -28,7 +28,7 @@ header-y += affs_fs.h affs_hardblocks.h 
 	sound.h stddef.h synclink.h telephony.h termios.h ticable.h	\
 	times.h tiocl.h tipc.h toshiba.h ultrasound.h un.h utime.h	\
 	utsname.h video_decoder.h video_encoder.h videotext.h vt.h	\
-	wavefront.h wireless.h xattr.h x25.h zorro_ids.h
+	wavefront.h wireless.h xattr.h x25.h zorro_ids.h nl80211.h
 
 unifdef-y += acct.h adb.h adfs_fs.h agpgart.h apm_bios.h atalk.h	\
 	atmarp.h atmdev.h atm.h atm_tcp.h audit.h auto_fs.h binfmts.h	\
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/include/linux/nl80211.h	2006-09-13 22:06:10.539647141 +0200
@@ -0,0 +1,137 @@
+#ifndef __LINUX_NL80211_H
+#define __LINUX_NL80211_H
+/*
+ * 802.11 netlink interface public header
+ *
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ */
+
+/* currently supported commands
+ * don't change the order or add anything inbetween, this is ABI! */
+enum {
+	/* There's no technical reason to not use command 0 but malformed
+	 * zeroed messages may have it and this catches that */
+	NL80211_CMD_UNSPEC,
+
+	/* Get supported commands by ifindex,
+	 * uses NL80211_ATTR_CMDS (output) and NL80211_ATTR_IFINDEX (input) */
+	NL80211_CMD_GET_CMDLIST,
+
+	/* Supported commands returned */
+	NL80211_CMD_NEW_CMDLIST,
+
+	/* Inject a frame using NL80211_ATTR_FLAGS and NL80211_ATTR_FRAME.
+	 * If kernel sends this, it's a status notification for the injected
+	 * frame. */
+	NL80211_CMD_INJECT,
+
+	/* add a virtual interface to a group that is identified by any
+	 * other ifindex in the group of a wiphy index, needs the
+	 * NL80211_IF_NAME attribute */
+	NL80211_CMD_ADD_VIRTUAL_INTERFACE,
+
+	/* remove a given (with NL80211_ATTR_IFINDEX) virtual device */
+	NL80211_CMD_DEL_VIRTUAL_INTERFACE,
+
+	/* get list of all wiphys */
+	NL80211_CMD_GET_WIPHYS,
+
+	/* get list of all wiphys */
+	NL80211_CMD_NEW_WIPHYS,
+
+	/* get list of all interfaces belonging to a wiphy */
+	NL80211_CMD_GET_INTERFACES,
+
+	/* get list of all interfaces belonging to a wiphy */
+	NL80211_CMD_NEW_INTERFACES,
+
+	/* add commands here */
+
+	/* used to define NL80211_CMD_MAX below */
+	__NL80211_CMD_AFTER_LAST,
+};
+#define NL80211_CMD_MAX (__NL80211_CMD_AFTER_LAST - 1)
+
+
+/* currently supported attributes.
+ * don't change the order or add anything inbetween, this is ABI! */
+enum {
+	NL80211_ATTR_UNSPEC,
+
+	/* network device (ifindex) to operate on */
+	NL80211_ATTR_IFINDEX,
+
+	/* wiphy index to operate on */
+	NL80211_ATTR_WIPHY,
+
+	/* list of u8 cmds that a given device implements */
+	NL80211_ATTR_CMDS,
+
+	/* flags for injection and other commands, see below */
+	NL80211_ATTR_FLAGS,
+
+	/* which hardware queue to use */
+	NL80211_ATTR_QUEUE,
+
+	/* frame to inject or received frame for mgmt frame subscribers */
+	NL80211_ATTR_FRAME,
+
+	/* interface name */
+	NL80211_ATTR_IFNAME,
+
+	/* type of (virtual) interface */
+	NL80211_ATTR_IFTYPE,
+
+	/* interface list */
+	NL80211_ATTR_INTERFACE_LIST,
+
+	/* wiphy list */
+	NL80211_ATTR_WIPHY_LIST,
+
+	/* add attributes here */
+
+	/* used to define NL80211_ATTR_MAX below */
+	__NL80211_ATTR_AFTER_LAST,
+};
+#define NL80211_ATTR_MAX (__NL80211_ATTR_AFTER_LAST - 1)
+
+/**
+ * NL80211_FLAG_TXSTATUS - send transmit status indication
+ */
+#define NL80211_FLAG_TXSTATUS		(1<<00)
+/**
+ * NL80211_FLAG_ENCRYPT - encrypt this packet
+ * Warning: This looks inside the packet header!
+ */
+#define NL80211_FLAG_ENCRYPT		(1<<01)
+
+/**
+ * maximum length of a frame that can be injected
+ */
+#define NL80211_MAX_FRAME_LEN 2500
+
+/**
+ * &enum nl80211_iftype - (virtual) interface types
+ *
+ * This structure is used with the NL80211_ATTR_IFTYPE
+ * to set the type of an interface.
+ * Note that these are intentionally compatible with
+ * the IW_MODE_* constants except for the removal of
+ * IW_MODE_AUTO.
+ *
+ */
+enum {
+	NL80211_IFTYPE_UNSPECIFIED,
+	NL80211_IFTYPE_ADHOC,
+	NL80211_IFTYPE_STATION,
+	NL80211_IFTYPE_AP,
+	NL80211_IFTYPE_WDS,
+	NL80211_IFTYPE_SECONDARY,
+	NL80211_IFTYPE_MONITOR,
+
+	/* keep last */
+	__NL80211_IFTYPE_AFTER_LAST
+};
+#define NL80211_IFTYPE_MAX (__NL80211_IFTYPE_AFTER_LAST - 1)
+
+#endif /* __LINUX_NL80211_H */
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/include/net/cfg80211.h	2006-09-13 22:06:10.539647141 +0200
@@ -0,0 +1,84 @@
+#ifndef __NET_NL80211_H
+#define __NET_NL80211_H
+
+#include <linux/netlink.h>
+#include <linux/nl80211.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <net/genetlink.h>
+
+/*
+ * 802.11 configuration in-kernel interface
+ *
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ */
+
+/**
+ * struct cfg80211_ops - backend description for wireless configuration
+ *
+ * This struct is registered by fullmac card drivers and/or wireless stacks
+ * in order to handle configuration requests on their interfaces.
+ *
+ * The priv pointer passed to each call is the pointer that was
+ * registered in cfg80211_register_driver().
+ *
+ * All callbacks except where otherwise noted should return 0
+ * on success or a negative error code.
+ *
+ * @list_interfaces: for each interfaces belonging to the wiphy identified
+ *		     by the priv pointer, call the one() function with the
+ *		     given data and the ifindex. This callback is required.
+ *
+ * @inject_packet: inject the given frame with the NL80211_FLAG_*
+ *		   flags onto the given queue.
+ *
+ * @add_virtual_intf: create a new virtual interface with the given name
+ *
+ * @del_virtual_intf: remove the virtual interface determined by ifindex.
+ */
+struct cfg80211_ops {
+	int	(*list_interfaces)(void *priv, void *data,
+				   int (*one)(void *data, int ifindex));
+	int	(*inject_packet)(void *priv, void *frame, int framelen,
+				 u32 flags, int queue);
+
+	int	(*add_virtual_intf)(void *priv, char *name,
+				    unsigned int type);
+	int	(*del_virtual_intf)(void *priv, int ifindex);
+
+	/* more things to be added...
+	 *
+	 * for a (*configure)(...) call I'd probably guess that the
+	 * best bet would be to have one call that returns all
+	 * possible options, one that sets them based on the
+	 * struct genl_info *info, and one for that optimised
+	 * set-at-once thing.
+	 */
+};
+
+/*
+ * register a given method structure with the cfg80211 system
+ * and associate the 'priv' pointer with it.
+ *
+ * Returns a positive wiphy index or a negative error code.
+ *
+ * NOTE: for proper operation, this priv pointer MUST also be
+ * assigned to each &struct net_device's @ieee80211_ptr member!
+ */
+extern int cfg80211_register(struct cfg80211_ops *ops, void *priv);
+
+/*
+ * unregister a device with the given priv pointer.
+ * After this call, no more requests can be made with this priv
+ * pointer, but the call may sleep to wait for an outstanding
+ * request that is being handled.
+ */
+extern void cfg80211_unregister(void *priv);
+
+/* helper functions specific to netlink */
+extern void *nl80211hdr_put(struct sk_buff *skb, u32 pid,
+			    u32 seq, int flags, u8 cmd);
+extern void *nl80211msg_new(struct sk_buff **skb, u32 pid,
+			    u32 seq, int flags, u8 cmd);
+
+#endif /* __NET_NL80211_H */
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/core.c	2006-09-13 22:06:10.539647141 +0200
@@ -0,0 +1,233 @@
+/*
+ * This is the new wireless configuration interface.
+ *
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ */
+
+#include "core.h"
+#include "nl80211.h"
+#include <linux/if.h>
+#include <linux/module.h>
+#include <linux/err.h>
+#include <net/genetlink.h>
+#include <net/cfg80211.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+
+MODULE_AUTHOR("Johannes Berg");
+MODULE_LICENSE("GPL");
+
+/* RCU might be appropriate here since we usually
+ * only read the list, and that can happen quite
+ * often because we need to do it for each command */
+LIST_HEAD(cfg80211_drv_list);
+DEFINE_MUTEX(cfg80211_drv_mutex);
+static int wiphy_counter;
+
+/* requires nl80211_drv_mutex to be held! */
+static struct cfg80211_registered_driver *cfg80211_drv_by_priv(void *priv)
+{
+	struct cfg80211_registered_driver *result = NULL, *drv;
+
+	if (!priv)
+		return NULL;
+
+	list_for_each_entry(drv, &cfg80211_drv_list, list) {
+		if (drv->priv == priv) {
+			result = drv;
+			break;
+		}
+	}
+
+	return result;
+}
+
+/* requires cfg80211_drv_mutex to be held! */
+static struct cfg80211_registered_driver *cfg80211_drv_by_wiphy(int wiphy)
+{
+	struct cfg80211_registered_driver *result = NULL, *drv;
+
+	list_for_each_entry(drv, &cfg80211_drv_list, list) {
+		if (drv->wiphy == wiphy) {
+			result = drv;
+			break;
+		}
+	}
+
+	return result;
+}
+
+/* requires cfg80211_drv_mutex to be held! */
+static struct cfg80211_registered_driver *
+__cfg80211_drv_from_info(struct genl_info *info)
+{
+	int ifindex;
+	struct cfg80211_registered_driver *bywiphy = NULL, *byifidx = NULL;
+	struct net_device *dev;
+	int err = -EINVAL;
+
+	if (info->attrs[NL80211_ATTR_WIPHY]) {
+		bywiphy = cfg80211_drv_by_wiphy(
+				nla_get_u32(info->attrs[NL80211_ATTR_WIPHY]));
+		err = -ENODEV;
+	}
+
+	if (info->attrs[NL80211_ATTR_IFINDEX]) {
+		ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
+		dev = dev_get_by_index(ifindex);
+		if (dev) {
+			byifidx = cfg80211_drv_by_priv(dev->ieee80211_ptr);
+			dev_put(dev);
+		}
+		err = -ENODEV;
+	}
+
+	if (bywiphy && byifidx) {
+		if (bywiphy != byifidx)
+			return ERR_PTR(-EINVAL);
+		else
+			return bywiphy; /* == byifidx */
+	}
+	if (bywiphy)
+		return bywiphy;
+
+	if (byifidx)
+		return byifidx;
+
+	return ERR_PTR(err);
+}
+
+struct cfg80211_registered_driver *
+cfg80211_get_drv_from_info(struct genl_info *info)
+{
+	struct cfg80211_registered_driver *drv;
+
+	mutex_lock(&cfg80211_drv_mutex);
+	drv = __cfg80211_drv_from_info(info);
+
+	/* if it is not an error we grab the lock on
+	 * it to assure it won't be going away while
+	 * we operate on it */
+	if (!IS_ERR(drv))
+		mutex_lock(&drv->mtx);
+
+	mutex_unlock(&cfg80211_drv_mutex);
+
+	return drv;
+}
+
+/* wext will need this */
+struct cfg80211_registered_driver *
+cfg80211_get_drv_from_ifindex(int ifindex)
+{
+	struct cfg80211_registered_driver *drv;
+	struct net_device *dev;
+
+	mutex_lock(&cfg80211_drv_mutex);
+	dev = dev_get_by_index(ifindex);
+	if (!dev)
+		return ERR_PTR(-ENODEV);
+	drv = cfg80211_drv_by_priv(dev->ieee80211_ptr);
+	if (drv)
+		mutex_lock(&drv->mtx);
+	dev_put(dev);
+	if (drv)
+		return drv;
+	return ERR_PTR(-ENODEV);
+}
+
+void cfg80211_put_drv(struct cfg80211_registered_driver *drv)
+{
+	BUG_ON(IS_ERR(drv));
+	mutex_unlock(&drv->mtx);
+}
+
+/* exported functions */
+
+int cfg80211_register(struct cfg80211_ops *ops, void *priv)
+{
+	struct cfg80211_registered_driver *drv;
+	int res;
+
+	if (!priv || !ops->list_interfaces)
+		return -EINVAL;
+
+	mutex_lock(&cfg80211_drv_mutex);
+
+	if (cfg80211_drv_by_priv(priv)) {
+		res = -EALREADY;
+		goto out_unlock;
+	}
+
+	drv = kzalloc(sizeof(struct cfg80211_registered_driver), GFP_KERNEL);
+	if (!drv) {
+		res = -ENOMEM;
+		goto out_unlock;
+	}
+
+	drv->ops = ops;
+	drv->priv = priv;
+
+	if (unlikely(wiphy_counter<0)) {
+		/* ugh, wrapped! */
+		kfree(drv);
+		res = -ENOSPC;
+		goto out_unlock;
+	}
+	mutex_init(&drv->mtx);
+	drv->wiphy = wiphy_counter;
+	list_add(&drv->list, &cfg80211_drv_list);
+	/* return wiphy number */
+	res = drv->wiphy;
+
+	/* now increase counter for the next time */
+	wiphy_counter++;
+
+ out_unlock:
+	mutex_unlock(&cfg80211_drv_mutex);
+	return res;
+}
+EXPORT_SYMBOL_GPL(cfg80211_register);
+
+void cfg80211_unregister(void *priv)
+{
+	struct cfg80211_registered_driver *drv;
+
+	mutex_lock(&cfg80211_drv_mutex);
+	drv = cfg80211_drv_by_priv(priv);
+	if (!drv) {
+		printk(KERN_ERR "deregistering cfg80211 backend that "
+		       " was never registered!\n");
+		mutex_unlock(&cfg80211_drv_mutex);
+		return;
+	}
+
+	/* hold registered driver mutex during list removal as well
+	 * to make sure no commands are in progress at the moment */
+	mutex_lock(&drv->mtx);
+	list_del(&drv->list);
+	mutex_unlock(&drv->mtx);
+
+	mutex_unlock(&cfg80211_drv_mutex);
+
+	mutex_destroy(&drv->mtx);
+	kfree(drv);
+}
+EXPORT_SYMBOL_GPL(cfg80211_unregister);
+
+/* module initialisation/exit functions */
+
+static int cfg80211_init(void)
+{
+	/* possibly need to do more later */
+	return nl80211_init();
+}
+
+static void cfg80211_exit(void)
+{
+	/* possibly need to do more later */
+	nl80211_exit();
+}
+
+module_init(cfg80211_init);
+module_exit(cfg80211_exit);
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/core.h	2006-09-13 22:06:10.539647141 +0200
@@ -0,0 +1,57 @@
+/*
+ * Wireless configuration interface internals.
+ *
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ */
+#ifndef __NET_WIRELESS_CORE_H
+#define __NET_WIRELESS_CORE_H
+#include <net/cfg80211.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <net/genetlink.h>
+
+struct cfg80211_registered_driver {
+	struct cfg80211_ops *ops;
+	int wiphy;
+	void *priv;
+	struct list_head list;
+	/* we hold this mutex during any call so that
+	 * we cannot do multiple calls at once, and also
+	 * to avoid the deregister call to proceed while
+	 * any call is in progress */
+	struct mutex mtx;
+};
+
+extern struct mutex cfg80211_drv_mutex;
+extern struct list_head cfg80211_drv_list;
+
+/*
+ * This function returns a pointer to the driver
+ * that the genl_info item that is passed refers to.
+ * If successful, it returns non-NULL and also locks
+ * the driver's mutex!
+ *
+ * This means that you need to call cfg80211_put_drv()
+ * before being allowed to acquire &cfg80211_drv_mutex!
+ *
+ * This is necessary because we need to lock the global
+ * mutex to get an item off the list safely, and then
+ * we lock the drv mutex so it doesn't go away under us.
+ *
+ * We don't want to keep cfg80211_drv_mutex locked
+ * for all the time in order to allow requests on
+ * other interfaces to go through at the same time.
+ *
+ * The result of this can be a PTR_ERR and hence must
+ * be checked with IS_ERR() for errors.
+ */
+extern struct cfg80211_registered_driver *
+cfg80211_get_drv_from_info(struct genl_info *info);
+
+/* identical to cfg80211_get_drv_from_info but only operate on ifindex */
+extern struct cfg80211_registered_driver *
+cfg80211_get_drv_from_ifindex(int ifindex);
+
+extern void cfg80211_put_drv(struct cfg80211_registered_driver *drv);
+
+#endif /* __NET_WIRELESS_CORE_H */
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/nl80211.h	2006-09-13 22:06:10.539647141 +0200
@@ -0,0 +1,7 @@
+#ifndef __NET_WIRELESS_NL80211_H
+#define __NET_WIRELESS_NL80211_H
+
+extern int nl80211_init(void);
+extern void nl80211_exit(void);
+
+#endif /* __NET_WIRELESS_NL80211_H */

