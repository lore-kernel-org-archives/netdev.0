From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] nl80211 + packet injection with it and d80211
Date: Thu, 17 Aug 2006 16:13:28 +0200
Message-ID: <1155824008.3491.7.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46991 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965021AbWHQONM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 10:13:12 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

This is a patch laying the groundwork for nl80211. I've decided to
implement it below net/wireless/ so that when we add further things like
configfs support for some things that can just be added there.

Currently, it lays the groundwork for netlink userspace communication.
None of the attribute stuff and configuration stuff I talked about is
implemented yet, nor anything like having wext go over netlink
obviously.

This patch now serves mainly to illustrate how I intend to multiplex
everything. Also, as added bonus, it implements packet injection over
netlink into the d80211 stack :) NB: missing is tx status notification
via netlink. The patch was large enough already.

I'd appreciate any feedback on the implementation.

johannes

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/include/net/nl80211.h	2006-08-17 11:07:18.000000000 +0200
@@ -0,0 +1,55 @@
+#ifndef __NET_NL80211_H
+#define __NET_NL80211_H
+
+#include <linux/netlink.h>
+#include <net/genetlink.h>
+#include <linux/nl80211.h>
+#include <linux/skbuff.h>
+
+/*
+ * 802.11 netlink in-kernel interface
+ *
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ */
+
+/**
+ * struct nl80211_call - backend call for wireless configuration
+ *
+ * An array of pointers to &struct nl80211_call is registered
+ * by each backend (driver or wireless stack) within
+ * &struct nl80211_driver.
+ *
+ * @doit: see &struct genl_ops doit
+ * @dumpit: see &struct genl_ops dumpit
+ */
+struct nl80211_call {
+	int	(*doit)(struct sk_buff *skb,
+			struct genl_info *info);
+	int	(*dumpit)(struct sk_buff *skb,
+			  struct netlink_callback *cb);
+};
+
+/**
+ * struct nl80211_driver - backend description for wireless configuration
+ *
+ * This struct is registered by fullmac card drivers and/or wireless stacks
+ * in order to handle configuration requests on their interfaces.
+ *
+ * @get_calls_for_ifindex: return an array of size NL80211_CMD_MAX
+ *			   with an entry for each 
+ */
+struct nl80211_driver {
+	struct nl80211_call**	(*get_calls_for_ifindex)(int ifindex);
+
+	/* private: */
+	struct list_head driver_list;
+};
+
+extern void nl80211_register_driver(struct nl80211_driver *drv);
+extern void nl80211_unregister_driver(struct nl80211_driver *drv);
+extern void *nl80211hdr_put(struct sk_buff *skb, u32 pid,
+			    u32 seq, int flags, u8 cmd);
+extern void *nl80211msg_new(struct sk_buff **skb, u32 pid,
+			    u32 seq, int flags, u8 cmd);
+
+#endif /* __NET_NL80211_H */
--- wireless-dev.orig/net/Kconfig	2006-08-15 12:27:10.000000000 +0200
+++ wireless-dev/net/Kconfig	2006-08-15 12:30:45.000000000 +0200
@@ -250,6 +250,9 @@
 config WIRELESS_EXT
 	bool
 
+config NETLINK_80211
+	tristate
+
 endif   # if NET
 endmenu # Networking
 
--- wireless-dev.orig/net/Makefile	2006-08-15 12:30:56.000000000 +0200
+++ wireless-dev/net/Makefile	2006-08-15 12:31:13.000000000 +0200
@@ -44,6 +44,7 @@
 obj-$(CONFIG_VLAN_8021Q)	+= 8021q/
 obj-$(CONFIG_IP_DCCP)		+= dccp/
 obj-$(CONFIG_IP_SCTP)		+= sctp/
+obj-$(CONFIG_NETLINK_80211)	+= wireless/
 obj-$(CONFIG_D80211)		+= d80211/
 obj-$(CONFIG_IEEE80211)		+= ieee80211/
 obj-$(CONFIG_TIPC)		+= tipc/
--- wireless-dev.orig/net/d80211/Kconfig	2006-08-16 15:39:44.000000000 +0200
+++ wireless-dev/net/d80211/Kconfig	2006-08-16 15:39:48.000000000 +0200
@@ -3,6 +3,7 @@
 	select CRYPTO
 	select CRYPTO_ARC4
 	select CRYPTO_AES
+	select NETLINK_80211
 	---help---
 	This option enables the hardware independent IEEE 802.11
 	networking stack.
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/Makefile	2006-08-15 14:43:42.000000000 +0200
@@ -0,0 +1,4 @@
+obj-$(CONFIG_NETLINK_80211) += cfg80211.o
+
+cfg80211-objs := \
+	nl80211.o
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/nl80211.c	2006-08-17 15:32:13.000000000 +0200
@@ -0,0 +1,209 @@
+/*
+ * This is the new netlink-based wireless configuration interface.
+ *
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ */
+
+#include <linux/module.h>
+#include <net/genetlink.h>
+#include <net/nl80211.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+
+MODULE_AUTHOR("Johannes Berg");
+MODULE_LICENSE("GPL");
+
+static LIST_HEAD(nl80211_drv_list);
+static DEFINE_MUTEX(nl80211_drv_mutex);
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
+	[NL80211_ATTR_FLAGS] = { .type = NLA_U32 },
+	[NL80211_ATTR_CMDS] = { .type = NLA_STRING },
+	[NL80211_ATTR_QUEUE] = { .type = NLA_U32 },
+	[NL80211_ATTR_FRAME] = { .type = NLA_STRING },
+};
+
+static struct nl80211_call **nl80211_cmdvec_by_ifindex(int ifindex)
+{
+	struct nl80211_driver *drv;
+	struct nl80211_call **vec = NULL;
+
+	mutex_lock(&nl80211_drv_mutex);
+	list_for_each_entry(drv, &nl80211_drv_list, driver_list) {
+		vec = drv->get_calls_for_ifindex(ifindex);
+		if (vec)
+			break;
+	}
+	mutex_unlock(&nl80211_drv_mutex);
+
+	return vec;
+}
+
+/* this must be change when we introduce another lookup attribute */
+static struct nl80211_call **nl80211_cmdvec_from_info(struct genl_info *info)
+{
+	int ifindex;
+
+	if (!info->attrs[NL80211_ATTR_IFINDEX])
+		return NULL;
+	
+	ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
+	return nl80211_cmdvec_by_ifindex(ifindex);
+}
+
+static int nl80211_get_commands(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nl80211_call **vec = nl80211_cmdvec_from_info(info);
+	struct sk_buff *msg;
+	void *hdr;
+	int cmdidx, err;
+	struct nlattr *start;
+	u8 *data;
+
+	if (!vec)
+		return -EINVAL;
+
+	hdr = nl80211msg_new(&msg, info->snd_pid, info->snd_seq, 0, NL80211_CMD_GET_COMMANDS);
+	if (IS_ERR(hdr))
+		return PTR_ERR(hdr);
+
+	start = nla_nest_start(msg, NL80211_ATTR_CMDS);
+	if (!start)
+		goto nla_put_failure;
+	data = nla_data(start);
+
+	/* unconditionally allow NL80211_CMD_GET_COMMANDS */
+	skb_put(skb, 1);
+	*data++ = NL80211_CMD_GET_COMMANDS;
+
+	for (cmdidx = 0; cmdidx <= NL80211_CMD_MAX; cmdidx++)
+		if (vec[cmdidx]) {
+		}
+
+	nla_nest_end(msg, start);
+
+	err = genlmsg_end(msg, hdr);
+	if (err)
+		goto msg_free;
+
+	return genlmsg_unicast(msg, info->snd_pid);
+ nla_put_failure:
+	err = genlmsg_cancel(skb, hdr);
+ msg_free:
+	nlmsg_free(skb);
+	return err;
+}
+
+static int nl80211_do_cmd(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nl80211_call **vec;
+	
+	vec = nl80211_cmdvec_from_info(info);
+	if (!vec)
+		return -EINVAL;
+
+	if (!vec[info->genlhdr->cmd])
+		return -ENOSYS;
+	if (!vec[info->genlhdr->cmd]->doit)
+		return -ENOSYS;
+
+	return vec[info->genlhdr->cmd]->doit(skb, info);
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
+		.doit = nl80211_do_cmd,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+};
+
+
+/* exported functions */
+
+void nl80211_register_driver(struct nl80211_driver *drv)
+{
+	mutex_lock(&nl80211_drv_mutex);
+	list_add(&drv->driver_list, &nl80211_drv_list);
+	mutex_unlock(&nl80211_drv_mutex);
+}
+EXPORT_SYMBOL_GPL(nl80211_register_driver);
+
+void nl80211_unregister_driver(struct nl80211_driver *drv)
+{
+	mutex_lock(&nl80211_drv_mutex);
+	list_del(&drv->driver_list);
+	mutex_unlock(&nl80211_drv_mutex);
+}
+EXPORT_SYMBOL_GPL(nl80211_unregister_driver);
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
--- wireless-dev.orig/include/linux/Kbuild	2006-08-16 15:58:31.000000000 +0200
+++ wireless-dev/include/linux/Kbuild	2006-08-16 15:59:36.000000000 +0200
@@ -28,7 +28,7 @@
 	sound.h stddef.h synclink.h telephony.h termios.h ticable.h	\
 	times.h tiocl.h tipc.h toshiba.h ultrasound.h un.h utime.h	\
 	utsname.h video_decoder.h video_encoder.h videotext.h vt.h	\
-	wavefront.h wireless.h xattr.h x25.h zorro_ids.h
+	wavefront.h wireless.h xattr.h x25.h zorro_ids.h nl80211.h
 
 unifdef-y += acct.h adb.h adfs_fs.h agpgart.h apm_bios.h atalk.h	\
 	atmarp.h atmdev.h atm.h atm_tcp.h audit.h auto_fs.h binfmts.h	\
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/include/linux/nl80211.h	2006-08-17 12:11:27.000000000 +0200
@@ -0,0 +1,79 @@
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
+/**
+ * NL80211_FLAG_REQUEUE - WME requeue
+ * (what exactly is this?)
+ */
+#define NL80211_FLAG_REQUEUE		(1<<02)
+/**
+ * NL80211_FLAG_PROBE_RESPONSE - injected packet is a probe response
+ */
+#define NL80211_FLAG_PROBE_RESPONSE	(1<<03)
+
+#endif /* __LINUX_NL80211_H */
--- wireless-dev.orig/net/d80211/Makefile	2006-08-17 11:05:52.000000000 +0200
+++ wireless-dev/net/d80211/Makefile	2006-08-17 11:06:02.000000000 +0200
@@ -15,7 +15,8 @@
 	michael.o \
 	tkip.o \
 	aes_ccm.o \
-	wme.o
+	wme.o \
+	ieee80211_cfg.o
 
 ifeq ($(CONFIG_NET_SCHED),)
   80211-objs += fifo_qdisc.o
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-17 10:46:05.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-17 15:25:01.000000000 +0200
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
+		(pkt_data->flags & NL80211_FLAG_PROBE_RESPONSE) ?
+                	PKT_PROBE_RESP : PKT_NORMAL;
+	control.requeue = !!(pkt_data->flags & NL80211_FLAG_REQUEUE);
 	control.queue = pkt_data->queue;
 
 	ret = ieee80211_tx(odev, skb, &control,
@@ -1600,8 +1628,9 @@
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
 	pkt_data->ifindex = sdata->dev->ifindex;
-	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->do_not_encrypt = no_encrypt;
+	pkt_data->injected = (sdata->type == IEEE80211_IF_TYPE_MGMT);
+	if (!no_encrypt)
+		pkt_data->flags |= NL80211_FLAG_ENCRYPT;
 
 	skb->dev = sdata->master;
 	sdata->stats.tx_packets++;
@@ -1652,11 +1681,11 @@
 	pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
         pkt_data->ifindex = sdata->dev->ifindex;
-	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
+	pkt_data->injected = (sdata->type == IEEE80211_IF_TYPE_MGMT);
 
 	if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT &&
 	    (fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP)
-		pkt_data->pkt_probe_resp = 1;
+		pkt_data->flags |= NL80211_FLAG_PROBE_RESPONSE;
 
 	skb->priority = 20; /* use hardcoded priority for mgmt TX queue */
 	skb->dev = sdata->master;
@@ -1666,12 +1695,13 @@
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
@@ -2725,7 +2755,7 @@
 	while ((skb = skb_dequeue(&sta->tx_filtered)) != NULL) {
 		pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 		sent++;
-		pkt_data->requeue = 1;
+		pkt_data->flags |= NL80211_FLAG_REQUEUE;
 		dev_queue_xmit(skb);
 	}
 	while ((skb = skb_dequeue(&sta->ps_tx_buf)) != NULL) {
@@ -2737,7 +2767,7 @@
 		       "since STA not sleeping anymore\n", dev->name,
 		       MAC_ARG(sta->addr), sta->aid);
 #endif /* IEEE80211_VERBOSE_DEBUG_PS */
-		pkt_data->requeue = 1;
+		pkt_data->flags |= NL80211_FLAG_REQUEUE;
 		dev_queue_xmit(skb);
 	}
 
@@ -3969,12 +3999,17 @@
 	struct ieee80211_tx_packet_data *pkt_data;
 
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
+	pkt_data->flags = 0;
 	pkt_data->ifindex = control->ifindex;
-	pkt_data->mgmt_iface = (control->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->req_tx_status = control->req_tx_status;
-	pkt_data->do_not_encrypt = control->do_not_encrypt;
-	pkt_data->pkt_probe_resp = (control->pkt_type == PKT_PROBE_RESP);
-	pkt_data->requeue = control->requeue;
+	pkt_data->injected = (control->type == IEEE80211_IF_TYPE_MGMT);
+	if (control->req_tx_status)
+		pkt_data->flags |= NL80211_FLAG_TXSTATUS;
+	if (!control->do_not_encrypt)
+		pkt_data->flags |= NL80211_FLAG_ENCRYPT;
+	if (control->pkt_type == PKT_PROBE_RESP)
+		pkt_data->flags |= NL80211_FLAG_PROBE_RESPONSE;
+	if (control->requeue)
+		pkt_data->flags |= NL80211_FLAG_REQUEUE;
 	pkt_data->queue = control->queue;
 
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
@@ -4795,12 +4830,15 @@
 		}
 	}
 
+	ieee80211_cfg_init();
+
 	return 0;
 }
 
 
 static void __exit ieee80211_exit(void)
 {
+	ieee80211_cfg_exit();
 	ieee80211_wme_unregister();
 	ieee80211_sysfs_deinit();
 }
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/ieee80211_cfg.c	2006-08-17 15:41:03.000000000 +0200
@@ -0,0 +1,97 @@
+/*
+ * nl80211-based configuration for d80211
+ *
+ * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ */
+#include <net/nl80211.h>
+#include <linux/netdevice.h>
+#include "ieee80211_cfg.h"
+#include "ieee80211_i.h"
+
+/* currently only supports injection by ifindex */
+static int d80211_inject(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *dev;
+	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_tx_packet_data *pkt_data;
+	struct sk_buff *pkt;
+	unsigned char *pktdata;
+	u32 flags = 0;
+
+	if (!info->attrs[NL80211_ATTR_IFINDEX])
+		return -EINVAL;
+	if (!info->attrs[NL80211_ATTR_FRAME])
+		return -EINVAL;
+	if (nla_len(info->attrs[NL80211_ATTR_FRAME]) < 10)
+		return -EINVAL;
+	if (info->attrs[NL80211_ATTR_FLAGS])
+		flags = nla_get_u32(info->attrs[NL80211_ATTR_FLAGS]);
+	
+	dev = dev_get_by_index(nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]));
+	if (!dev)
+		return -EINVAL;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	pkt = alloc_skb(nla_len(info->attrs[NL80211_ATTR_FRAME]), GFP_KERNEL);
+	pktdata = skb_put(pkt, nla_len(info->attrs[NL80211_ATTR_FRAME]));
+	memcpy(pktdata, nla_data(info->attrs[NL80211_ATTR_FRAME]),
+	       nla_len(info->attrs[NL80211_ATTR_FRAME]));
+
+	pkt_data = (struct ieee80211_tx_packet_data *) pkt->cb;
+	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
+	pkt_data->ifindex = sdata->local->mdev->ifindex;
+	pkt_data->injected = 1;
+	pkt_data->flags = flags;
+
+	/* FIXME */
+	pkt->priority = 20; /* use hardcoded priority for mgmt TX queue */
+
+	sdata->stats.tx_packets++;
+	sdata->stats.tx_bytes += pkt->len;
+
+	pkt->dev = sdata->master;
+	dev_queue_xmit(pkt);
+
+	dev_put(dev);
+	
+	return 0;
+}
+
+static struct nl80211_call d80211_inject_call = {
+	.doit = d80211_inject,
+};
+
+static struct nl80211_call* d80211_calls[NL80211_CMD_MAX+1] = {
+	[NL80211_CMD_INJECT] = &d80211_inject_call,
+};
+
+static struct nl80211_call** d80211_calls_for_ifindex(int ifindex)
+{
+	struct net_device *dev = dev_get_by_index(ifindex);
+
+	if (!dev)
+		return NULL;
+
+	if (dev->ieee80211_ptr) {
+		dev_put(dev);
+		return d80211_calls;
+	}
+
+	dev_put(dev);
+	return NULL;
+}
+
+static struct nl80211_driver d80211nl = {
+	.get_calls_for_ifindex = d80211_calls_for_ifindex,
+};
+
+void ieee80211_cfg_init(void)
+{
+	nl80211_register_driver(&d80211nl);
+}
+
+void ieee80211_cfg_exit(void)
+{
+	nl80211_unregister_driver(&d80211nl);
+}
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/ieee80211_cfg.h	2006-08-17 11:05:43.000000000 +0200
@@ -0,0 +1,7 @@
+#ifndef __IEEE80211_CFG_H
+#define __IEEE80211_CFG_H
+
+extern void ieee80211_cfg_init(void);
+extern void ieee80211_cfg_exit(void);
+
+#endif /* __IEEE80211_CFG_H */
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-08-17 11:48:34.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-08-17 12:17:56.000000000 +0200
@@ -151,12 +151,10 @@
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
+	unsigned int injected;
 };
 
 struct ieee80211_tx_stored_packet {
--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-08-17 12:27:46.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-08-17 12:28:37.000000000 +0200
@@ -23,6 +23,7 @@
 #include <linux/if_arp.h>
 #include <linux/wireless.h>
 #include <linux/random.h>
+#include <linux/nl80211.h>
 #include <net/iw_handler.h>
 #include <asm/types.h>
 #include <asm/delay.h>
@@ -400,10 +401,11 @@
 	pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
 	pkt_data->ifindex = sdata->dev->ifindex;
-	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->do_not_encrypt = !encrypt;
+	pkt_data->injected = (sdata->type == IEEE80211_IF_TYPE_MGMT);
+	if (encrypt)
+		pkt_data->flags |= NL80211_FLAG_ENCRYPT;
 	if (probe_resp)
-		pkt_data->pkt_probe_resp = 1;
+		pkt_data->flags |= NL80211_FLAG_PROBE_RESPONSE;
 
 	dev_queue_xmit(skb);
 }
--- wireless-dev.orig/net/d80211/wme.c	2006-08-17 12:28:47.000000000 +0200
+++ wireless-dev/net/d80211/wme.c	2006-08-17 12:30:30.000000000 +0200
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
+	if (unlikely(pkt_data->injected)) {
 		/* Data frames from hostapd (mainly, EAPOL) use AC_VO
 		* and they will include QoS control fields if
 		* the target STA is using WME. */
@@ -236,7 +238,7 @@
 	struct Qdisc *qdisc;
 	int err, queue;
 
-	if (pkt_data->requeue) {
+	if (pkt_data->flags & NL80211_FLAG_REQUEUE) {
 		skb_queue_tail(&q->requeued[pkt_data->queue], skb);
 		return 0;
 	}

