From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC take3] make d80211 use nl80211
Date: Fri, 25 Aug 2006 13:02:17 +0200
Message-ID: <1156503738.4090.16.camel@ux156>
References: <1156254813.3825.2.camel@ux156>
	 <1156435657.10283.10.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:8116 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964877AbWHYLBo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 07:01:44 -0400
To: netdev <netdev@vger.kernel.org>
In-Reply-To: <1156435657.10283.10.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes d80211 partially configurable using the
infrastructure that nl80211 provides. So far, it allows
packet injection and adding/removing virtual interfaces.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/Kconfig	2006-08-25 11:31:01.000000000 +0200
+++ wireless-dev/net/d80211/Kconfig	2006-08-25 11:32:38.000000000 +0200
@@ -3,6 +3,7 @@ config D80211
 	select CRYPTO
 	select CRYPTO_ARC4
 	select CRYPTO_AES
+	select NETLINK_80211
 	---help---
 	This option enables the hardware independent IEEE 802.11
 	networking stack.
--- wireless-dev.orig/net/d80211/Makefile	2006-08-25 11:31:01.000000000 +0200
+++ wireless-dev/net/d80211/Makefile	2006-08-25 11:32:38.000000000 +0200
@@ -8,6 +8,7 @@ obj-$(CONFIG_D80211) += 80211.o rate_con
 	sta_info.o \
 	wep.o \
 	wpa.o \
+	ieee80211_cfg.o \
 	ieee80211_scan.o \
 	ieee80211_sta.o \
 	ieee80211_dev.o \
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-25 11:31:01.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-25 11:32:38.000000000 +0200
@@ -20,6 +20,7 @@
 #include <net/iw_handler.h>
 #include <linux/compiler.h>
 #include <linux/bitmap.h>
+#include <linux/nl80211.h>
 
 #include <net/d80211.h>
 #include <net/d80211_common.h>
@@ -32,6 +33,7 @@
 #include "wme.h"
 #include "aes_ccm.h"
 #include "ieee80211_led.h"
+#include "ieee80211_cfg.h"
 
 /* See IEEE 802.1H for LLC/SNAP encapsulation/decapsulation */
 /* Ethernet-II snap header (RFC1042 for most EtherTypes) */
@@ -354,6 +356,16 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
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
@@ -759,6 +771,13 @@ ieee80211_tx_h_misc(struct ieee80211_txr
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
@@ -884,6 +903,9 @@ ieee80211_tx_h_check_assoc(struct ieee80
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	u32 sta_flags;
 
+	if (unlikely(tx->dev == tx->local->mdev))
+		return TXRX_CONTINUE;
+
 	if (unlikely(tx->local->sta_scanning != 0) &&
 	    ((tx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_MGMT ||
 	     (tx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_PROBE_REQ))
@@ -987,6 +1009,12 @@ static void purge_old_ps_buffers(struct 
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
@@ -1414,11 +1442,12 @@ static int ieee80211_master_start_xmit(s
 
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
@@ -1594,8 +1623,10 @@ static int ieee80211_subif_start_xmit(st
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
@@ -1646,11 +1677,12 @@ ieee80211_mgmt_start_xmit(struct sk_buff
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
@@ -1660,12 +1692,13 @@ ieee80211_mgmt_start_xmit(struct sk_buff
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
@@ -2715,7 +2748,7 @@ static int ap_sta_ps_end(struct net_devi
 	while ((skb = skb_dequeue(&sta->tx_filtered)) != NULL) {
 		pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 		sent++;
-		pkt_data->requeue = 1;
+		pkt_data->internal_flags |= TX_FLAG_REQUEUE;
 		dev_queue_xmit(skb);
 	}
 	while ((skb = skb_dequeue(&sta->ps_tx_buf)) != NULL) {
@@ -2727,7 +2760,7 @@ static int ap_sta_ps_end(struct net_devi
 		       "since STA not sleeping anymore\n", dev->name,
 		       MAC_ARG(sta->addr), sta->aid);
 #endif /* CONFIG_D80211_VERBOSE_PS_DEBUG */
-		pkt_data->requeue = 1;
+		pkt_data->internal_flags |= TX_FLAG_REQUEUE;
 		dev_queue_xmit(skb);
 	}
 
@@ -3958,12 +3991,19 @@ static void ieee80211_remove_tx_extra(st
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
@@ -4422,6 +4462,9 @@ int ieee80211_register_hw(struct net_dev
 	if (result < 0)
 		return -1;
 
+	if (ieee80211_cfg_init(local) < 0)
+		goto fail_nl80211;
+
 	local->class_dev.dev = dev->class_dev.dev;
 	result = ieee80211_dev_sysfs_add(local);
 	if (result < 0)
@@ -4508,6 +4551,8 @@ fail_dev:
 fail_sta_info:
 	ieee80211_dev_sysfs_del(local);
 fail_sysfs:
+	ieee80211_cfg_exit(local);
+fail_nl80211:
 	ieee80211_dev_free_index(local);
 	return result;
 }
@@ -4589,6 +4634,8 @@ void ieee80211_unregister_hw(struct net_
 				  &local->class_dev.kobj);
 	ieee80211_dev_sysfs_del(local);
 
+	ieee80211_cfg_exit(local);
+
 	for (i = 0; i < NUM_IEEE80211_MODES; i++) {
 		kfree(local->supp_rates[i]);
 		kfree(local->basic_rates[i]);
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/ieee80211_cfg.c	2006-08-25 11:32:38.000000000 +0200
@@ -0,0 +1,144 @@
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
+static int ieee80211_interfaces(void *priv, void *data,
+				int (*one)(void *data, int ifindex))
+{
+	struct ieee80211_local *local = priv;
+	struct ieee80211_sub_if_data *sdata;
+	int err = 0;
+
+	spin_lock_bh(&local->sub_if_lock);
+	list_for_each_entry(sdata, &local->sub_if_list, list) {
+		err = one(data, sdata->dev->ifindex);
+		if (err)
+			break;
+	}
+	spin_unlock_bh(&local->sub_if_lock);
+	return err;
+}
+
+static int ieee80211_inject(void *priv, void *frame, int framelen, u32 flags,
+			    int queue)
+{
+	struct ieee80211_local *local = priv;
+	struct ieee80211_tx_packet_data *pkt_data;
+	struct sk_buff *skb;
+
+	skb = alloc_skb(framelen, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	memcpy(skb_put(skb, framelen), frame, framelen);
+
+	pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
+	pkt_data->ifindex = local->mdev->ifindex;
+	pkt_data->internal_flags = TX_FLAG_INJECTED;
+	pkt_data->flags = flags;
+	/* FIXME: never used, I think? Or could be invalid? */
+	pkt_data->queue = queue;
+
+	/* FIXME */
+	skb->priority = 20; /* use hardcoded priority for mgmt TX queue */
+
+	skb->dev = local->mdev;
+	dev_queue_xmit(skb);
+
+	return 0;
+}
+
+static int ieee80211_add_virtual_intf(void *priv, char *name,
+				      unsigned int type)
+{
+	struct ieee80211_local *local = priv;
+	struct net_device *new_dev;
+	int res, itype;
+
+	switch (type) {
+	case NL80211_IFTYPE_UNSPECIFIED:
+		itype = IEEE80211_IF_TYPE_STA;
+		break;
+	case NL80211_IFTYPE_ADHOC:
+		itype = IEEE80211_IF_TYPE_IBSS;
+		break;
+	case NL80211_IFTYPE_STATION:
+		itype = IEEE80211_IF_TYPE_STA;
+		break;
+	case NL80211_IFTYPE_AP:
+		itype = IEEE80211_IF_TYPE_AP;
+		break;
+	case NL80211_IFTYPE_WDS:
+		itype = IEEE80211_IF_TYPE_WDS;
+		break;
+	case NL80211_IFTYPE_MONITOR:
+		itype = IEEE80211_IF_TYPE_MNTR;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	res = rtnl_lock_local(local);
+	if (res)
+		return res;
+
+	res = ieee80211_if_add(local->mdev, name, 0, &new_dev);
+	if (res == 0)
+		ieee80211_if_set_type(new_dev, itype);
+	rtnl_unlock();
+	return res;
+}
+
+static int ieee80211_del_virtual_intf(void *priv, int ifindex)
+{
+	struct ieee80211_local *local = priv;
+	int res;
+	struct net_device *dev;
+	char *name;
+
+	res = rtnl_lock_local(local);
+	if (res)
+		return res;
+	dev = dev_get_by_index(ifindex);
+	name = dev->name;
+	dev_put(dev);
+
+	res = ieee80211_if_remove(local->mdev, name, -1);
+	rtnl_unlock();
+	return res;
+}
+
+static struct nl80211_ops d80211nl = {
+	.list_interfaces = ieee80211_interfaces,
+	.inject_packet = ieee80211_inject,
+	.add_virtual_intf = ieee80211_add_virtual_intf,
+	.del_virtual_intf = ieee80211_del_virtual_intf,
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
+++ wireless-dev/net/d80211/ieee80211_cfg.h	2006-08-25 11:32:38.000000000 +0200
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
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-08-25 11:31:01.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-08-25 11:32:38.000000000 +0200
@@ -153,12 +153,13 @@ struct ieee80211_txrx_data {
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
--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-08-25 11:29:01.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-08-25 11:32:38.000000000 +0200
@@ -21,6 +21,7 @@
 #include <linux/if_arp.h>
 #include <linux/wireless.h>
 #include <linux/random.h>
+#include <linux/nl80211.h>
 #include <net/iw_handler.h>
 #include <asm/types.h>
 #include <asm/delay.h>
@@ -396,10 +397,12 @@ static void ieee80211_sta_tx(struct net_
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
--- wireless-dev.orig/net/d80211/wme.c	2006-08-25 11:29:01.000000000 +0200
+++ wireless-dev/net/d80211/wme.c	2006-08-25 11:32:38.000000000 +0200
@@ -11,6 +11,7 @@
 #include <linux/module.h>
 #include <linux/if_arp.h>
 #include <linux/types.h>
+#include <linux/nl80211.h>
 #include <net/ip.h>
 #include <net/pkt_sched.h>
 
@@ -190,7 +191,8 @@ static inline int classify80211(struct s
 		return IEEE80211_TX_QUEUE_DATA0;
 	}
 
-	if (unlikely(pkt_data->mgmt_iface)) {
+	/* FIXME: this needs to be revisited for more generic injection */
+	if (unlikely(pkt_data->internal_flags & TX_FLAG_INJECTED)) {
 		/* Data frames from hostapd (mainly, EAPOL) use AC_VO
 		* and they will include QoS control fields if
 		* the target STA is using WME. */
@@ -236,7 +238,7 @@ static int wme_qdiscop_enqueue(struct sk
 	struct Qdisc *qdisc;
 	int err, queue;
 
-	if (pkt_data->requeue) {
+	if (pkt_data->internal_flags & TX_FLAG_REQUEUE) {
 		skb_queue_tail(&q->requeued[pkt_data->queue], skb);
 		return 0;
 	}

