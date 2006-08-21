From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] nl80211 + packet injection with it and d80211
Date: Mon, 21 Aug 2006 17:32:19 +0200
Message-ID: <1156174339.3627.12.camel@ux156>
References: <1155824008.3491.7.camel@ux156> <1155912565.5671.1.camel@ux156>
	 <20060820204709.2f46d8c8@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:14467 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751817AbWHUPcD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 11:32:03 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060820204709.2f46d8c8@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's a respun patch hopefully addressing most of Jiri's comments, and
allowing to add/remove virtual interfaces via netlink as well.

I introduced a new notion of 'wiphy' which is just a number handed out
by nl80211 for each registered backend, and I also changed it so that
each backend must register once for each physical device.

Also, drivers wishing to use this to full capacity are required to fill
in ieee80211_ptr in struct net_device for all of their devices,
otherwise the wiphy number is useless!

NB: The new notion of wiphy will be confusing because now nl80211 and
d80211 can hand out different numbers. I expect that either d80211 will
just use the wiphy number nl80211 handed out (will need new API to query
it) or we rename things or whatever. To be shaken out :)

Oh, I also expect there to be a configfs/sysfs interface to nl80211
directly so that backends (d80211...) don't create their sysfs/configfs
dirs but use debugfs for truly not too interesting things like debug
counters, and all the other stuff is in nl80211. Or something like that
anyway :)

With this patch, NL80211_ATTR_IFINDEX of any netdevice attached to a
wiphy can be used in place of NL80211_ATTR_WIPHY, but some calls like
adding a virtual device to a wiphy that has no netdev (something that
cannot happen at the moment due to wmaster) require ATTR_WIPHY for
obvious reasons. Oh and I figured that the list walking is maybe dumb,
but we will never have thousands of wiphys in a single machine...

Anyway, with this patch we ought to be able to get rid of wmaster0
without userspace visible changes (except of course that doing
  wconf dev add xxx0 dev wmaster0
will no longer work and you'll need to do
  wconf dev add xxx0 wiphy 0
or something :)

Hrm, I keep forgetting things :) Another thing that I just remembered:
This relies on the patch by Thomas Graf he posted in
http://marc.theaimsgroup.com/?l=linux-netdev&m=115218779631578&w=2 for
validation of the netdevice name length/null termination.

Patch below. NB: only compiled, not tried this time, want to go home :)

johannes

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/include/net/nl80211.h	2006-08-21 17:19:04.000000000 +0200
@@ -0,0 +1,74 @@
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
+ * 802.11 netlink in-kernel interface
+ *
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ */
+
+/**
+ * struct nl80211_ops - backend description for wireless configuration
+ *
+ * This struct is registered by fullmac card drivers and/or wireless stacks
+ * in order to handle configuration requests on their interfaces.
+ *
+ * The priv pointer passed to each call is the pointer that was
+ * registered in nl80211_register_driver().
+ *
+ * All callbacks except where otherwise noted should return 0
+ * on success or a negative error code.
+ *
+ * @inject_packet: inject the given frame with the NL80211_FLAG_*
+ *		   flags onto the given queue.
+ *
+ * @add_virtual_intf: create a new virtual interface with the given name
+ *
+ * @del_virtual_intf: remove the given virtual interface (during the call,
+ *                    one reference to the interface is held)
+ */
+struct nl80211_ops {
+	int	(*inject_packet)(void *priv, void *frame, int framelen,
+				 u32 flags, int queue);
+
+	int	(*add_virtual_intf)(void *priv, char *name);
+	int	(*del_virtual_intf)(void *priv, struct net_device *dev);
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
+ * register a given method structure with the nl80211 system
+ * and associate the 'priv' pointer with it.
+ * NOTE: for proper operation, this priv pointer MUST also be
+ * assigned to each &struct net_device's @ieee80211_ptr member!
+ */
+extern int nl80211_register(struct nl80211_ops *ops, void *priv);
+/*
+ * unregister a device with the given priv pointer.
+ * After this call, no more requests can be made with this priv
+ * pointer, but the call may sleep to wait for an outstanding
+ * request that is being handled.
+ */
+extern void nl80211_unregister(void *priv);
+
+/* helper functions */
+extern void *nl80211hdr_put(struct sk_buff *skb, u32 pid,
+			    u32 seq, int flags, u8 cmd);
+extern void *nl80211msg_new(struct sk_buff **skb, u32 pid,
+			    u32 seq, int flags, u8 cmd);
+
+#endif /* __NET_NL80211_H */
--- wireless-dev.orig/net/Kconfig	2006-08-21 17:16:24.000000000 +0200
+++ wireless-dev/net/Kconfig	2006-08-21 17:16:42.000000000 +0200
@@ -250,6 +250,9 @@
 config WIRELESS_EXT
 	bool
 
+config NETLINK_80211
+	tristate
+
 endif   # if NET
 endmenu # Networking
 
--- wireless-dev.orig/net/Makefile	2006-08-21 17:16:24.000000000 +0200
+++ wireless-dev/net/Makefile	2006-08-21 17:16:42.000000000 +0200
@@ -44,6 +44,7 @@
 obj-$(CONFIG_VLAN_8021Q)	+= 8021q/
 obj-$(CONFIG_IP_DCCP)		+= dccp/
 obj-$(CONFIG_IP_SCTP)		+= sctp/
+obj-$(CONFIG_NETLINK_80211)	+= wireless/
 obj-$(CONFIG_D80211)		+= d80211/
 obj-$(CONFIG_IEEE80211)		+= ieee80211/
 obj-$(CONFIG_TIPC)		+= tipc/
--- wireless-dev.orig/net/d80211/Kconfig	2006-08-21 17:16:24.000000000 +0200
+++ wireless-dev/net/d80211/Kconfig	2006-08-21 17:16:42.000000000 +0200
@@ -3,6 +3,7 @@
 	select CRYPTO
 	select CRYPTO_ARC4
 	select CRYPTO_AES
+	select NETLINK_80211
 	---help---
 	This option enables the hardware independent IEEE 802.11
 	networking stack.
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/Makefile	2006-08-21 17:16:42.000000000 +0200
@@ -0,0 +1,4 @@
+obj-$(CONFIG_NETLINK_80211) += cfg80211.o
+
+cfg80211-objs := \
+	nl80211.o
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/nl80211.c	2006-08-21 17:16:42.000000000 +0200
@@ -0,0 +1,447 @@
+/*
+ * This is the new netlink-based wireless configuration interface.
+ *
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ */
+
+#include <linux/if.h>
+#include <linux/module.h>
+#include <net/genetlink.h>
+#include <net/nl80211.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+
+MODULE_AUTHOR("Johannes Berg");
+MODULE_LICENSE("GPL");
+
+struct nl80211_registered_driver {
+	struct nl80211_ops *ops;
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
+/* RCU might be appropriate here since we usually
+ * only read the list, and that can happen quite
+ * often because we need to do it for each command */
+static LIST_HEAD(nl80211_drv_list);
+static DEFINE_MUTEX(nl80211_drv_mutex);
+static unsigned int wiphy_counter;
+
+static struct genl_family nl80211_fam = {
+	.id = GENL_ID_GENERATE,	/* don't bother with a hardcoded ID */
+	.name = "nl80211",	/* have users key off the name instead */
+	.hdrsize = 0,		/* no private header */
+	.version = 1,		/* no particular meaning now */
+	.maxattr = NL80211_ATTR_MAX,
+};
+
+static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
+	[NL80211_ATTR_IFINDEX] = { .type = NLA_U32 },
+	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
+	[NL80211_ATTR_FLAGS] = { .type = NLA_U32 },
+	[NL80211_ATTR_CMDS] = { .type = NLA_STRING },
+	[NL80211_ATTR_QUEUE] = { .type = NLA_U32 },
+	[NL80211_ATTR_FRAME] = { .type = NLA_STRING },
+	[NL80211_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ },
+};
+
+static struct nl80211_registered_driver *nl80211_drv_by_priv_locked(void *priv)
+{
+	struct nl80211_registered_driver *result = NULL, *drv;
+
+	if (!priv)
+		return NULL;
+
+	list_for_each_entry(drv, &nl80211_drv_list, list) {
+		if (drv->priv == priv) {
+			result = drv;
+			break;
+		}
+	}
+
+	return result;
+}
+
+static struct nl80211_registered_driver *nl80211_drv_by_wiphy_locked(int wiphy)
+{
+	struct nl80211_registered_driver *result = NULL, *drv;
+
+	list_for_each_entry(drv, &nl80211_drv_list, list) {
+		if (drv->wiphy == wiphy) {
+			result = drv;
+			break;
+		}
+	}
+
+	return result;
+}
+
+/* requires nl80211_drv_mutex to be held! */
+static struct nl80211_registered_driver *
+nl80211_drv_from_info_locked(struct genl_info *info)
+{
+	int ifindex;
+	struct nl80211_registered_driver *result = NULL;
+	struct net_device *dev;
+
+	if (info->attrs[NL80211_ATTR_WIPHY]) {
+		result = nl80211_drv_by_wiphy_locked(
+				nla_get_u32(info->attrs[NL80211_ATTR_WIPHY]));
+		if (result)
+			return result;
+	}
+
+	if (info->attrs[NL80211_ATTR_IFINDEX]) {
+		ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
+		dev = dev_get_by_index(ifindex);
+		result = nl80211_drv_by_priv_locked(dev->ieee80211_ptr);
+		dev_put(dev);
+		if (result)
+			return result;
+	}
+
+	return NULL;
+}
+
+/* This function returns a pointer to the driver
+ * that the genl_info item that is passed refers to.
+ * If successful, it returns non-NULL and also LOCKS
+ * the driver's mutex!
+ * DON'T EVER ACQUIRE nl80211_drv_mutex AFTER THIS!
+ *
+ * This is necessary because we need to lock the global
+ * mutex to get an item off the list safely, and then
+ * we lock the drv mutex so it doesn't go away under us.
+ *
+ * We don't want to keep nl80211_drv_mutex locked
+ * for all the time in order to allow requests on
+ * other interfaces to go through at the same time. */
+static struct nl80211_registered_driver *
+nl80211_drv_from_info_with_locking(struct genl_info *info)
+{
+	struct nl80211_registered_driver *drv;
+
+	mutex_lock(&nl80211_drv_mutex);
+	drv = nl80211_drv_from_info_locked(info);
+	if (!drv) {
+		mutex_unlock(&nl80211_drv_mutex);
+		return NULL;
+	}
+	mutex_lock(&drv->mtx);
+	mutex_unlock(&nl80211_drv_mutex);
+
+	return drv;
+}
+
+#define CHECK_CMD(ptr, cmd)			\
+	if (drv->ops->ptr) {			\
+		skb_put(msg, 1);		\
+		*data++ = NL80211_CMD_##cmd;	\
+	}
+
+static int nl80211_get_commands(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nl80211_registered_driver *drv;
+	struct sk_buff *msg;
+	void *hdr;
+	int err;
+	struct nlattr *start;
+	u8 *data;
+
+	drv = nl80211_drv_from_info_with_locking(info);
+	if (!drv)
+		return -EINVAL;
+
+	hdr = nl80211msg_new(&msg, info->snd_pid, info->snd_seq, 0,
+			     NL80211_CMD_GET_COMMANDS);
+	if (IS_ERR(hdr)) {
+		err = PTR_ERR(hdr);
+		goto unlock;
+	}
+
+	start = nla_nest_start(msg, NL80211_ATTR_CMDS);
+	if (!start)
+		goto nla_nest_failure;
+	data = nla_data(start);
+
+	/* unconditionally allow NL80211_CMD_GET_COMMANDS */
+	skb_put(msg, 1);
+	*data++ = NL80211_CMD_GET_COMMANDS;
+
+	CHECK_CMD(inject_packet, INJECT);
+	CHECK_CMD(add_virtual_intf, ADD_VIRTUAL_INTERFACE);
+	CHECK_CMD(del_virtual_intf, DEL_VIRTUAL_INTERFACE);
+
+	nla_nest_end(msg, start);
+
+	err = genlmsg_end(msg, hdr);
+	if (err)
+		goto msg_free;
+
+	err = genlmsg_unicast(msg, info->snd_pid);
+	goto unlock;
+
+ nla_nest_failure:
+	err = genlmsg_cancel(skb, hdr);
+ msg_free:
+	nlmsg_free(skb);
+ unlock:
+	mutex_unlock(&drv->mtx);
+	return err;
+}
+#undef CHECK_CMD
+
+static int nl80211_do_inject(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nl80211_registered_driver *drv;
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
+	drv = nl80211_drv_from_info_with_locking(info);
+	if (!drv)
+		return -EINVAL;
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
+	mutex_unlock(&drv->mtx);
+	return err;
+}
+
+static int nl80211_add_virt_intf(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nl80211_registered_driver *drv;
+	int err;
+
+	if (!info->attrs[NL80211_ATTR_IFNAME])
+		return -EINVAL;
+
+	drv = nl80211_drv_from_info_with_locking(info);
+	if (!drv)
+		return -EINVAL;
+
+	if (!drv->ops->add_virtual_intf) {
+		err = -ENOSYS;
+		goto unlock;
+	}
+
+	err = drv->ops->add_virtual_intf(drv->priv,
+		nla_data(info->attrs[NL80211_ATTR_IFNAME]));
+
+ unlock:
+	mutex_unlock(&drv->mtx);
+	return err;
+}
+
+static int nl80211_del_virt_intf(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nl80211_registered_driver *drv;
+	int ifindex, err;
+	struct net_device *dev;
+
+	if (!info->attrs[NL80211_ATTR_IFINDEX])
+		return -EINVAL;
+
+	ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
+
+	dev = dev_get_by_index(ifindex);
+	if (!dev)
+		return -EINVAL;
+
+	/* need to act on that ifindex */
+	mutex_lock(&nl80211_drv_mutex);
+	drv = nl80211_drv_by_priv_locked(dev->ieee80211_ptr);
+	if (!drv) {
+		mutex_unlock(&nl80211_drv_mutex);
+		return -EINVAL;
+	}
+	mutex_lock(&drv->mtx);
+	mutex_unlock(&nl80211_drv_mutex);
+
+	if (!drv->ops->del_virtual_intf) {
+		err = -ENOSYS;
+		goto unlock;
+	}
+
+	err = drv->ops->del_virtual_intf(drv->priv, dev);
+
+	dev_put(dev);
+
+ unlock:
+	mutex_unlock(&drv->mtx);
+	return err;
+}
+
+static struct genl_ops nl80211_ops[] = {
+	{
+		.cmd = NL80211_CMD_GET_COMMANDS,
+		.doit = nl80211_get_commands,
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
+int nl80211_register(struct nl80211_ops *ops, void *priv)
+{
+	struct nl80211_registered_driver *drv;
+	int err;
+
+	if (!priv)
+		return -EINVAL;
+
+	mutex_lock(&nl80211_drv_mutex);
+
+	if (nl80211_drv_by_priv_locked(priv)) {
+		err = -EALREADY;
+		goto out_unlock;
+	}
+
+	drv = kzalloc(sizeof(struct nl80211_registered_driver), GFP_KERNEL);
+	if (!drv) {
+		err = -ENOMEM;
+		goto out_unlock;
+	}
+
+	drv->ops = ops;
+	drv->priv = priv;
+
+	wiphy_counter++;
+	if (unlikely(!wiphy_counter)) {
+		/* ugh, wrapped! */
+		kfree(drv);
+		err = -ENOSPC;
+		goto out_unlock;
+	}
+	mutex_init(&drv->mtx);
+	drv->wiphy = wiphy_counter;
+	list_add(&drv->list, &nl80211_drv_list);
+	err = 0;
+
+ out_unlock:
+	mutex_unlock(&nl80211_drv_mutex);
+	return err;
+}
+EXPORT_SYMBOL_GPL(nl80211_register);
+
+void nl80211_unregister(void *priv)
+{
+	struct nl80211_registered_driver *drv;
+
+	mutex_lock(&nl80211_drv_mutex);
+	drv = nl80211_drv_by_priv_locked(priv);
+	if (!drv) {
+		printk(KERN_ERR "deregistering nl80211 backend that "
+		       " was never registered!\n");
+		mutex_unlock(&nl80211_drv_mutex);
+		return;
+	}
+
+	/* hold registered driver mutex during list removal as well
+	 * to make sure no commands are in progress at the moment */
+	mutex_lock(&drv->mtx);
+	list_del(&drv->list);
+	mutex_unlock(&drv->mtx);
+
+	mutex_unlock(&nl80211_drv_mutex);
+
+	mutex_destroy(&drv->mtx);
+	kfree(drv);
+}
+EXPORT_SYMBOL_GPL(nl80211_unregister);
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
+		/* what would be a good error here? */
+		return ERR_PTR(-EINVAL);
+	}
+
+	return hdr;
+}
+EXPORT_SYMBOL_GPL(nl80211msg_new);
+
+/* module initialisation/exit functions */
+
+static int nl80211_init(void)
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
+static void nl80211_exit(void)
+{
+	genl_unregister_family(&nl80211_fam);
+}
+
+module_init(nl80211_init);
+module_exit(nl80211_exit);
--- wireless-dev.orig/include/linux/Kbuild	2006-08-21 17:16:24.000000000 +0200
+++ wireless-dev/include/linux/Kbuild	2006-08-21 17:16:42.000000000 +0200
@@ -28,7 +28,7 @@
 	sound.h stddef.h synclink.h telephony.h termios.h ticable.h	\
 	times.h tiocl.h tipc.h toshiba.h ultrasound.h un.h utime.h	\
 	utsname.h video_decoder.h video_encoder.h videotext.h vt.h	\
-	wavefront.h wireless.h xattr.h x25.h zorro_ids.h
+	wavefront.h wireless.h xattr.h x25.h zorro_ids.h nl80211.h
 
 unifdef-y += acct.h adb.h adfs_fs.h agpgart.h apm_bios.h atalk.h	\
 	atmarp.h atmdev.h atm.h atm_tcp.h audit.h auto_fs.h binfmts.h	\
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/include/linux/nl80211.h	2006-08-21 17:16:42.000000000 +0200
@@ -0,0 +1,84 @@
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
+	NL80211_CMD_GET_COMMANDS,
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
+	/* interface name for adding a virtual interface */
+	NL80211_ATTR_IFNAME,
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
+#endif /* __LINUX_NL80211_H */
--- wireless-dev.orig/net/d80211/Makefile	2006-08-21 17:16:24.000000000 +0200
+++ wireless-dev/net/d80211/Makefile	2006-08-21 17:16:42.000000000 +0200
@@ -15,7 +15,8 @@
 	michael.o \
 	tkip.o \
 	aes_ccm.o \
-	wme.o
+	wme.o \
+	ieee80211_cfg.o
 
 ifeq ($(CONFIG_NET_SCHED),)
   80211-objs += fifo_qdisc.o
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-21 17:16:24.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-21 17:16:42.000000000 +0200
@@ -20,6 +20,7 @@
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
 #include <linux/compiler.h>
+#include <linux/nl80211.h>
 
 #include <net/d80211.h>
 #include <net/d80211_common.h>
@@ -31,7 +32,7 @@
 #include "tkip.h"
 #include "wme.h"
 #include "aes_ccm.h"
-
+#include "ieee80211_cfg.h"
 
 /* See IEEE 802.1H for LLC/SNAP encapsulation/decapsulation */
 /* Ethernet-II snap header (RFC1042 for most EtherTypes) */
@@ -354,6 +355,16 @@
 {
 	struct rate_control_extra extra;
 
+	/* FIXME
+	if (tx->dev == tx->local->mdev &&
+	    (inject rate set)) {
+		a
+		tx->u.tx.rate = ...
+		etc etc
+		return TXRX_CONTINUE;
+	}
+	*/
+
 	memset(&extra, 0, sizeof(extra));
 	extra.mgmt_data = tx->sdata &&
 		tx->sdata->type == IEEE80211_IF_TYPE_MGMT;
@@ -761,6 +772,13 @@
 	u16 dur;
 	struct ieee80211_tx_control *control = tx->u.tx.control;
 
+	/* FIXME
+	if (tx->dev == tx->local->mdev) {
+		set up retry limit, ...
+		based on injection parameters
+	}
+	*/
+
 	if (!is_multicast_ether_addr(hdr->addr1)) {
 		if (tx->skb->len + FCS_LEN > tx->local->rts_threshold &&
 		    tx->local->rts_threshold < IEEE80211_MAX_RTS_THRESHOLD) {
@@ -886,6 +904,9 @@
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	u32 sta_flags;
 
+	if (unlikely(tx->dev == tx->local->mdev))
+		return TXRX_CONTINUE;
+
 	if (unlikely(tx->local->sta_scanning != 0) &&
 	    ((tx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_MGMT ||
 	     (tx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_PROBE_REQ))
@@ -989,6 +1010,12 @@
 static inline ieee80211_txrx_result
 ieee80211_tx_h_multicast_ps_buf(struct ieee80211_txrx_data *tx)
 {
+	/* FIXME
+	if (unlikely(tx->dev == tx->local->mdev &&
+	    (inject flags) & NL80211_FLAG_NOBUFFER))
+		return TXRX_CONTINUE;
+	*/
+
 	/* broadcast/multicast frame */
 	/* If any of the associated stations is in power save mode,
 	 * the frame is buffered to be sent after DTIM beacon frame */
@@ -1420,11 +1447,12 @@
 
 	control.ifindex = odev->ifindex;
 	control.type = osdata->type;
-	control.req_tx_status = pkt_data->req_tx_status;
-	control.do_not_encrypt = pkt_data->do_not_encrypt;
+	control.req_tx_status = !!(pkt_data->flags & NL80211_FLAG_TXSTATUS);
+	control.do_not_encrypt = !(pkt_data->flags & NL80211_FLAG_ENCRYPT);
 	control.pkt_type =
-		pkt_data->pkt_probe_resp ? PKT_PROBE_RESP : PKT_NORMAL;
-	control.requeue = pkt_data->requeue;
+		(pkt_data->internal_flags & TX_FLAG_PROBERESP) ?
+                	PKT_PROBE_RESP : PKT_NORMAL;
+	control.requeue = !!(pkt_data->internal_flags & TX_FLAG_REQUEUE);
 	control.queue = pkt_data->queue;
 
 	ret = ieee80211_tx(odev, skb, &control,
@@ -1600,8 +1628,10 @@
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
 	pkt_data->ifindex = sdata->dev->ifindex;
-	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->do_not_encrypt = no_encrypt;
+	if (sdata->type == IEEE80211_IF_TYPE_MGMT)
+		pkt_data->internal_flags |= TX_FLAG_INJECTED;
+	if (!no_encrypt)
+		pkt_data->flags |= NL80211_FLAG_ENCRYPT;
 
 	skb->dev = sdata->master;
 	sdata->stats.tx_packets++;
@@ -1652,11 +1682,12 @@
 	pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
         pkt_data->ifindex = sdata->dev->ifindex;
-	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
+	if (sdata->type == IEEE80211_IF_TYPE_MGMT)
+		pkt_data->internal_flags |= TX_FLAG_INJECTED;
 
 	if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT &&
 	    (fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP)
-		pkt_data->pkt_probe_resp = 1;
+		pkt_data->internal_flags |= TX_FLAG_PROBERESP;
 
 	skb->priority = 20; /* use hardcoded priority for mgmt TX queue */
 	skb->dev = sdata->master;
@@ -1666,12 +1697,13 @@
 	 * to request TX callback for hostapd. BIT(1) is checked.
 	 */
 	if ((fc & BIT(1)) == BIT(1)) {
-		pkt_data->req_tx_status = 1;
+		pkt_data->flags |= NL80211_FLAG_TXSTATUS;
 		fc &= ~BIT(1);
 		hdr->frame_control = cpu_to_le16(fc);
 	}
 
-	pkt_data->do_not_encrypt = !(fc & IEEE80211_FCTL_PROTECTED);
+	if (fc & IEEE80211_FCTL_PROTECTED)
+		pkt_data->flags |= NL80211_FLAG_ENCRYPT;
 
 	sdata->stats.tx_packets++;
         sdata->stats.tx_bytes += skb->len;
@@ -2725,7 +2757,7 @@
 	while ((skb = skb_dequeue(&sta->tx_filtered)) != NULL) {
 		pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 		sent++;
-		pkt_data->requeue = 1;
+		pkt_data->internal_flags |= TX_FLAG_REQUEUE;
 		dev_queue_xmit(skb);
 	}
 	while ((skb = skb_dequeue(&sta->ps_tx_buf)) != NULL) {
@@ -2737,7 +2769,7 @@
 		       "since STA not sleeping anymore\n", dev->name,
 		       MAC_ARG(sta->addr), sta->aid);
 #endif /* IEEE80211_VERBOSE_DEBUG_PS */
-		pkt_data->requeue = 1;
+		pkt_data->internal_flags |= TX_FLAG_REQUEUE;
 		dev_queue_xmit(skb);
 	}
 
@@ -3969,12 +4001,19 @@
 	struct ieee80211_tx_packet_data *pkt_data;
 
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
+	pkt_data->flags = 0;
+	pkt_data->internal_flags = 0;
 	pkt_data->ifindex = control->ifindex;
-	pkt_data->mgmt_iface = (control->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->req_tx_status = control->req_tx_status;
-	pkt_data->do_not_encrypt = control->do_not_encrypt;
-	pkt_data->pkt_probe_resp = (control->pkt_type == PKT_PROBE_RESP);
-	pkt_data->requeue = control->requeue;
+	if (control->type == IEEE80211_IF_TYPE_MGMT)
+		pkt_data->internal_flags |= TX_FLAG_INJECTED;
+	if (control->req_tx_status)
+		pkt_data->flags |= NL80211_FLAG_TXSTATUS;
+	if (!control->do_not_encrypt)
+		pkt_data->flags |= NL80211_FLAG_ENCRYPT;
+	if (control->pkt_type == PKT_PROBE_RESP)
+		pkt_data->internal_flags |= TX_FLAG_PROBERESP;
+	if (control->requeue)
+		pkt_data->internal_flags |= TX_FLAG_REQUEUE;
 	pkt_data->queue = control->queue;
 
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
@@ -4334,6 +4373,7 @@
 	priv_size = ((sizeof(struct ieee80211_sub_if_data) +
 		      NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST) +
 		    priv_data_len;
+
 	mdev = alloc_netdev(priv_size, "wmaster%d", ether_setup);
 	if (mdev == NULL) {
 		ieee80211_dev_free(local);
@@ -4436,6 +4476,9 @@
 	if (result < 0)
 		return -1;
 
+	if (ieee80211_cfg_init(local))
+		goto fail_nl80211;
+
 	local->class_dev.dev = dev->class_dev.dev;
 	result = ieee80211_dev_sysfs_add(local);
 	if (result < 0)
@@ -4513,6 +4556,8 @@
 fail_sta_info:
 	ieee80211_dev_sysfs_del(local);
 fail_sysfs:
+	ieee80211_cfg_exit(local);
+fail_nl80211:
 	ieee80211_dev_free_index(local);
 	return result;
 }
@@ -4591,6 +4636,8 @@
 				  &local->class_dev.kobj);
 	ieee80211_dev_sysfs_del(local);
 
+	ieee80211_cfg_exit(local);
+
 	for (i = 0; i < NUM_IEEE80211_MODES; i++) {
 		kfree(local->supp_rates[i]);
 		kfree(local->basic_rates[i]);
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/ieee80211_cfg.c	2006-08-21 17:16:42.000000000 +0200
@@ -0,0 +1,97 @@
+/*
+ * nl80211-based configuration for d80211
+ *
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ */
+#include <net/nl80211.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include "ieee80211_cfg.h"
+#include "ieee80211_i.h"
+
+/* copied from ieee80211_sysfs.c for now ... */
+static inline int rtnl_lock_local(struct ieee80211_local *local)
+{
+	rtnl_lock();
+	if (unlikely(local->reg_state != IEEE80211_DEV_REGISTERED)) {
+		rtnl_unlock();
+		return -ENODEV;
+	}
+	return 0;
+}
+
+static int d80211_inject(void *priv, void *frame, int framelen, u32 flags,
+			 int queue)
+{
+	struct ieee80211_local *local = priv;
+	struct ieee80211_tx_packet_data *pkt_data;
+	struct sk_buff *pkt;
+	void *pktdata;
+
+	pkt = alloc_skb(framelen, GFP_KERNEL);
+	pktdata = skb_put(pkt, framelen);
+	memcpy(pktdata, frame, framelen);
+
+	pkt_data = (struct ieee80211_tx_packet_data *) pkt->cb;
+	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
+	pkt_data->ifindex = local->mdev->ifindex;
+	pkt_data->internal_flags = TX_FLAG_INJECTED;
+	pkt_data->flags = flags;
+	/* FIXME: never used, I think? Or could be invalid? */
+	pkt_data->queue = queue;
+
+	/* FIXME */
+	pkt->priority = 20; /* use hardcoded priority for mgmt TX queue */
+
+	pkt->dev = local->mdev;
+	dev_queue_xmit(pkt);
+
+	return 0;
+}
+
+static int d80211_add_virtual_intf(void *priv, char *name)
+{
+	struct ieee80211_local *local = priv;
+	struct net_device *new_dev;
+	int res;
+
+	res = rtnl_lock_local(local);
+	if (res)
+		return res;
+
+	res = ieee80211_if_add(local->mdev, name, 0, &new_dev);
+	if (res == 0)
+		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_STA);
+	rtnl_unlock();
+	return res;
+}
+
+static int d80211_del_virtual_intf(void *priv, struct net_device *dev)
+{
+	struct ieee80211_local *local = priv;
+	int res;
+
+	res = rtnl_lock_local(local);
+	if (res)
+		return res;
+
+	res = ieee80211_if_remove(local->mdev, dev->name, -1);
+	rtnl_unlock();
+	return res;
+}
+
+static struct nl80211_ops d80211nl = {
+	.inject_packet = d80211_inject,
+	.add_virtual_intf = d80211_add_virtual_intf,
+	.del_virtual_intf = d80211_del_virtual_intf,
+};
+
+int ieee80211_cfg_init(struct ieee80211_local *local)
+{
+	return nl80211_register(&d80211nl, local);
+}
+
+void ieee80211_cfg_exit(struct ieee80211_local *local)
+{
+	nl80211_unregister(local);
+}
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/ieee80211_cfg.h	2006-08-21 17:16:42.000000000 +0200
@@ -0,0 +1,9 @@
+#ifndef __IEEE80211_CFG_H
+#define __IEEE80211_CFG_H
+
+#include "ieee80211_i.h"
+
+extern int ieee80211_cfg_init(struct ieee80211_local *local);
+extern void ieee80211_cfg_exit(struct ieee80211_local *local);
+
+#endif /* __IEEE80211_CFG_H */
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-08-21 17:16:24.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-08-21 17:16:42.000000000 +0200
@@ -151,12 +151,13 @@
 struct ieee80211_tx_packet_data {
 	int ifindex;
 	unsigned long jiffies;
-	unsigned int req_tx_status:1;
-	unsigned int do_not_encrypt:1;
-	unsigned int pkt_probe_resp:1;
-	unsigned int requeue:1;
-	unsigned int queue:4;
-	unsigned int mgmt_iface:1;
+/* we simply re-use NL80211_FLAG_* here */
+	unsigned int flags;
+	unsigned int queue;
+#define TX_FLAG_INJECTED	(1<<0)
+#define TX_FLAG_REQUEUE		(1<<1)
+#define TX_FLAG_PROBERESP	(1<<2)
+	unsigned int internal_flags;
 };
 
 struct ieee80211_tx_stored_packet {
--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-08-21 17:16:24.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-08-21 17:16:42.000000000 +0200
@@ -23,6 +23,7 @@
 #include <linux/if_arp.h>
 #include <linux/wireless.h>
 #include <linux/random.h>
+#include <linux/nl80211.h>
 #include <net/iw_handler.h>
 #include <asm/types.h>
 #include <asm/delay.h>
@@ -400,10 +401,12 @@
 	pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
 	pkt_data->ifindex = sdata->dev->ifindex;
-	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->do_not_encrypt = !encrypt;
+	if (sdata->type == IEEE80211_IF_TYPE_MGMT)
+		pkt_data->internal_flags |= TX_FLAG_INJECTED;
+	if (encrypt)
+		pkt_data->flags |= NL80211_FLAG_ENCRYPT;
 	if (probe_resp)
-		pkt_data->pkt_probe_resp = 1;
+		pkt_data->internal_flags |= TX_FLAG_PROBERESP;
 
 	dev_queue_xmit(skb);
 }
--- wireless-dev.orig/net/d80211/wme.c	2006-08-21 17:16:24.000000000 +0200
+++ wireless-dev/net/d80211/wme.c	2006-08-21 17:16:42.000000000 +0200
@@ -12,6 +12,7 @@
 #include <linux/skbuff.h>
 #include <linux/module.h>
 #include <linux/if_arp.h>
+#include <linux/nl80211.h>
 #include <net/ip.h>
 
 #include <net/d80211.h>
@@ -190,7 +191,8 @@
 		return IEEE80211_TX_QUEUE_DATA0;
 	}
 
-	if (unlikely(pkt_data->mgmt_iface)) {
+	/* FIXME: this needs to be revisited for more generic injection */
+	if (unlikely(pkt_data->internal_flags & TX_FLAG_INJECTED)) {
 		/* Data frames from hostapd (mainly, EAPOL) use AC_VO
 		* and they will include QoS control fields if
 		* the target STA is using WME. */
@@ -236,7 +238,7 @@
 	struct Qdisc *qdisc;
 	int err, queue;
 
-	if (pkt_data->requeue) {
+	if (pkt_data->internal_flags & TX_FLAG_REQUEUE) {
 		skb_queue_tail(&q->requeued[pkt_data->queue], skb);
 		return 0;
 	}

