From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 01/10] net/ncsi: Resource management
Date: Sun,  3 Jul 2016 15:32:24 +1000
Message-ID: <1467523953-18998-2-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	weixue@trustnetic.com, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:64170 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750935AbcGCFco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 01:32:44 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u635TKSJ135689
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 01:32:43 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23x9sy6ytj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 01:32:42 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Sun, 3 Jul 2016 15:32:39 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 56C003578052
	for <netdev@vger.kernel.org>; Sun,  3 Jul 2016 15:32:37 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u635Wb3m7012760
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:32:37 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u635WahB031438
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:32:37 +1000
In-Reply-To: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NCSI spec (DSP0222) defines several objects: package, channel, mode,
filter, version and statistics etc. This introduces the data structs
to represent those objects and implement functions to manage them.
Also, this introduces CONFIG_NET_NCSI for the newly implemented NCSI
stack.

   * The user (e.g. netdev driver) dereference NCSI device by
     "struct ncsi_dev", which is embedded to "struct ncsi_dev_priv".
     The later one is used by NCSI stack internally.
   * Every NCSI device can have multiple packages simultaneously, up
     to 8 packages. It's represented by "struct ncsi_package" and
     identified by 3-bits ID.
   * Every NCSI package can have multiple channels, up to 32. It's
     represented by "struct ncsi_channel" and identified by 5-bits ID.
   * Every NCSI channel has version, statistics, various modes and
     filters. They are represented by "struct ncsi_channel_version",
     "struct ncsi_channel_stats", "struct ncsi_channel_mode" and
     "struct ncsi_channel_filter" separately.
   * Apart from AEN (Asynchronous Event Notification), the NCSI stack
     works in terms of command and response. This introduces "struct
     ncsi_req" to represent a complete NCSI transaction made of NCSI
     request and response.

link: http://www.dmtf.org/sites/default/files/standards/documents/DSP0222_1.0.0.pdf
Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 include/net/ncsi.h     |  46 ++++++
 net/Kconfig            |   1 +
 net/Makefile           |   1 +
 net/ncsi/Kconfig       |  12 ++
 net/ncsi/Makefile      |   4 +
 net/ncsi/internal.h    | 255 ++++++++++++++++++++++++++++++
 net/ncsi/ncsi-manage.c | 422 +++++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 741 insertions(+)
 create mode 100644 include/net/ncsi.h
 create mode 100644 net/ncsi/Kconfig
 create mode 100644 net/ncsi/Makefile
 create mode 100644 net/ncsi/internal.h
 create mode 100644 net/ncsi/ncsi-manage.c

diff --git a/include/net/ncsi.h b/include/net/ncsi.h
new file mode 100644
index 0000000..70d14ee
--- /dev/null
+++ b/include/net/ncsi.h
@@ -0,0 +1,46 @@
+#ifndef __NET_NCSI_H
+#define __NET_NCSI_H
+
+/*
+ * The NCSI device states seen from external. More NCSI device states are
+ * only visible internally (in net/ncsi/internal.h). When the NCSI device
+ * is registered, it's in ncsi_dev_state_registered state. The state
+ * ncsi_dev_state_start is used to drive to choose active package and
+ * channel. After that, its state is changed to ncsi_dev_state_functional.
+ *
+ * The state ncsi_dev_state_stop helps to shut down the currently active
+ * package and channel while ncsi_dev_state_config helps to reconfigure
+ * them.
+ */
+enum {
+	ncsi_dev_state_registered	= 0x0000,
+	ncsi_dev_state_functional	= 0x0100,
+	ncsi_dev_state_probe		= 0x0200,
+	ncsi_dev_state_config		= 0x0300,
+	ncsi_dev_state_suspend		= 0x0400,
+};
+
+struct ncsi_dev {
+	int               state;
+	int		  link_up;
+	struct net_device *dev;
+	void		  (*handler)(struct ncsi_dev *ndev);
+};
+
+#ifdef CONFIG_NET_NCSI
+struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
+				   void (*notifier)(struct ncsi_dev *nd));
+void ncsi_unregister_dev(struct ncsi_dev *nd);
+#else /* !CONFIG_NET_NCSI */
+static inline struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
+					void (*notifier)(struct ncsi_dev *nd))
+{
+	return NULL;
+}
+
+static inline void ncsi_unregister_dev(struct ncsi_dev *nd)
+{
+}
+#endif /* CONFIG_NET_NCSI */
+
+#endif /* __NET_NCSI_H */
diff --git a/net/Kconfig b/net/Kconfig
index ff40562..c2cdbce 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -237,6 +237,7 @@ source "net/hsr/Kconfig"
 source "net/switchdev/Kconfig"
 source "net/l3mdev/Kconfig"
 source "net/qrtr/Kconfig"
+source "net/ncsi/Kconfig"
 
 config RPS
 	bool
diff --git a/net/Makefile b/net/Makefile
index bdd1455..9bd20bb 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -79,3 +79,4 @@ ifneq ($(CONFIG_NET_L3_MASTER_DEV),)
 obj-y				+= l3mdev/
 endif
 obj-$(CONFIG_QRTR)		+= qrtr/
+obj-$(CONFIG_NET_NCSI)		+= ncsi/
diff --git a/net/ncsi/Kconfig b/net/ncsi/Kconfig
new file mode 100644
index 0000000..08a8a60
--- /dev/null
+++ b/net/ncsi/Kconfig
@@ -0,0 +1,12 @@
+#
+# Configuration for NCSI support
+#
+
+config NET_NCSI
+	bool "NCSI interface support"
+	depends on INET
+	---help---
+	  This module provides NCSI (Network Controller Sideband Interface)
+	  support. Enable this only if your system connects to a network
+	  device via NCSI and the ethernet driver you're using supports
+	  the protocol explicitly.
diff --git a/net/ncsi/Makefile b/net/ncsi/Makefile
new file mode 100644
index 0000000..07b5625
--- /dev/null
+++ b/net/ncsi/Makefile
@@ -0,0 +1,4 @@
+#
+# Makefile for NCSI API
+#
+obj-$(CONFIG_NET_NCSI) += ncsi-manage.o
diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
new file mode 100644
index 0000000..6875b58
--- /dev/null
+++ b/net/ncsi/internal.h
@@ -0,0 +1,255 @@
+/*
+ * Copyright Gavin Shan, IBM Corporation 2016.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __NCSI_INTERNAL_H__
+#define __NCSI_INTERNAL_H__
+
+enum {
+	NCSI_CAP_BASE		= 0,
+	NCSI_CAP_GENERIC	= 0,
+	NCSI_CAP_BC,
+	NCSI_CAP_MC,
+	NCSI_CAP_BUFFER,
+	NCSI_CAP_AEN,
+	NCSI_CAP_VLAN,
+	NCSI_CAP_MAX
+};
+
+enum {
+	NCSI_CAP_GENERIC_HWA	= 0x01,	/* HW arbitration             */
+	NCSI_CAP_GENERIC_HDS	= 0x02,	/* HNC driver status change   */
+	NCSI_CAP_GENERIC_FC	= 0x04,	/* HNC to MC flow control     */
+	NCSI_CAP_GENERIC_FC1	= 0x08,	/* MC to HNC flow control     */
+	NCSI_CAP_GENERIC_MC	= 0x10,	/* Global multicast filtering */
+	NCSI_CAP_GENERIC_MASK	= 0x1f,
+	NCSI_CAP_BC_ARP		= 0x01,	/* ARP packet filtering       */
+	NCSI_CAP_BC_DHCPC	= 0x02,	/* DHCP client filtering      */
+	NCSI_CAP_BC_DHCPS	= 0x04,	/* DHCP server filtering      */
+	NCSI_CAP_BC_NETBIOS	= 0x08,	/* NetBIOS packet filtering   */
+	NCSI_CAP_BC_MASK	= 0x0f,
+	NCSI_CAP_MC_NEIGHBOR	= 0x01,	/* IPv6 neighbor filtering    */
+	NCSI_CAP_MC_ROUTER	= 0x02,	/* IPv6 router filering       */
+	NCSI_CAP_MC_DHCPV6	= 0x04,	/* DHCPv6 filtering           */
+	NCSI_CAP_MC_MASK	= 0x07,
+	NCSI_CAP_AEN_LSC	= 0x01,	/* Link status change AEN     */
+	NCSI_CAP_AEN_CR		= 0x02,	/* Configuration required AEN */
+	NCSI_CAP_AEN_HDS	= 0x04,	/* HNC driver status AEN      */
+	NCSI_CAP_AEN_MASK	= 0x07,
+	NCSI_CAP_VLAN_ONLY	= 0x01,	/* VLAN is supported          */
+	NCSI_CAP_VLAN_NO	= 0x02,	/* Filter VLAN and non-VLAN   */
+	NCSI_CAP_VLAN_ANY	= 0x04,	/* Filter Any-and-non-VLAN    */
+	NCSI_CAP_VLAN_MASK	= 0x07
+};
+
+enum {
+	NCSI_MODE_BASE		= 0,
+	NCSI_MODE_ENABLE	= 0,
+	NCSI_MODE_TX_ENABLE,
+	NCSI_MODE_LINK,
+	NCSI_MODE_VLAN,
+	NCSI_MODE_BC,
+	NCSI_MODE_MC,
+	NCSI_MODE_AEN,
+	NCSI_MODE_FC,
+	NCSI_MODE_MAX
+};
+
+enum {
+	NCSI_FILTER_BASE	= 0,
+	NCSI_FILTER_VLAN	= 0,
+	NCSI_FILTER_UC,
+	NCSI_FILTER_MC,
+	NCSI_FILTER_MIXED,
+	NCSI_FILTER_MAX
+};
+
+struct ncsi_channel_version {
+	u32 version;		/* Supported BCD encoded NCSI version */
+	u32 alpha2;		/* Supported BCD encoded NCSI version */
+	u8  fw_name[12];	/* Firware name string                */
+	u32 fw_version;		/* Firmware version                   */
+	u16 pci_ids[4];		/* PCI identification                 */
+	u32 mf_id;		/* Manufacture ID                     */
+};
+
+struct ncsi_channel_cap {
+	u32 index;	/* Index of channel capabilities */
+	u32 cap;	/* NCSI channel capability       */
+};
+
+struct ncsi_channel_mode {
+	u32 index;	/* Index of channel modes      */
+	u32 enable;	/* Enabled or disabled         */
+	u32 size;	/* Valid entries in ncm_data[] */
+	u32 data[8];	/* Data entries                */
+};
+
+struct ncsi_channel_filter {
+	u32 index;	/* Index of channel filters          */
+	u32 total;	/* Total entries in the filter table */
+	u64 bitmap;	/* Bitmap of valid entries           */
+	u32 data[];	/* Data for the valid entries        */
+};
+
+struct ncsi_channel_stats {
+	u32 hnc_cnt_hi;		/* Counter cleared            */
+	u32 hnc_cnt_lo;		/* Counter cleared            */
+	u32 hnc_rx_bytes;	/* Rx bytes                   */
+	u32 hnc_tx_bytes;	/* Tx bytes                   */
+	u32 hnc_rx_uc_pkts;	/* Rx UC packets              */
+	u32 hnc_rx_mc_pkts;     /* Rx MC packets              */
+	u32 hnc_rx_bc_pkts;	/* Rx BC packets              */
+	u32 hnc_tx_uc_pkts;	/* Tx UC packets              */
+	u32 hnc_tx_mc_pkts;	/* Tx MC packets              */
+	u32 hnc_tx_bc_pkts;	/* Tx BC packets              */
+	u32 hnc_fcs_err;	/* FCS errors                 */
+	u32 hnc_align_err;	/* Alignment errors           */
+	u32 hnc_false_carrier;	/* False carrier detection    */
+	u32 hnc_runt_pkts;	/* Rx runt packets            */
+	u32 hnc_jabber_pkts;	/* Rx jabber packets          */
+	u32 hnc_rx_pause_xon;	/* Rx pause XON frames        */
+	u32 hnc_rx_pause_xoff;	/* Rx XOFF frames             */
+	u32 hnc_tx_pause_xon;	/* Tx XON frames              */
+	u32 hnc_tx_pause_xoff;	/* Tx XOFF frames             */
+	u32 hnc_tx_s_collision;	/* Single collision frames    */
+	u32 hnc_tx_m_collision;	/* Multiple collision frames  */
+	u32 hnc_l_collision;	/* Late collision frames      */
+	u32 hnc_e_collision;	/* Excessive collision frames */
+	u32 hnc_rx_ctl_frames;	/* Rx control frames          */
+	u32 hnc_rx_64_frames;	/* Rx 64-bytes frames         */
+	u32 hnc_rx_127_frames;	/* Rx 65-127 bytes frames     */
+	u32 hnc_rx_255_frames;	/* Rx 128-255 bytes frames    */
+	u32 hnc_rx_511_frames;	/* Rx 256-511 bytes frames    */
+	u32 hnc_rx_1023_frames;	/* Rx 512-1023 bytes frames   */
+	u32 hnc_rx_1522_frames;	/* Rx 1024-1522 bytes frames  */
+	u32 hnc_rx_9022_frames;	/* Rx 1523-9022 bytes frames  */
+	u32 hnc_tx_64_frames;	/* Tx 64-bytes frames         */
+	u32 hnc_tx_127_frames;	/* Tx 65-127 bytes frames     */
+	u32 hnc_tx_255_frames;	/* Tx 128-255 bytes frames    */
+	u32 hnc_tx_511_frames;	/* Tx 256-511 bytes frames    */
+	u32 hnc_tx_1023_frames;	/* Tx 512-1023 bytes frames   */
+	u32 hnc_tx_1522_frames;	/* Tx 1024-1522 bytes frames  */
+	u32 hnc_tx_9022_frames;	/* Tx 1523-9022 bytes frames  */
+	u32 hnc_rx_valid_bytes;	/* Rx valid bytes             */
+	u32 hnc_rx_runt_pkts;	/* Rx error runt packets      */
+	u32 hnc_rx_jabber_pkts;	/* Rx error jabber packets    */
+	u32 ncsi_rx_cmds;	/* Rx NCSI commands           */
+	u32 ncsi_dropped_cmds;	/* Dropped commands           */
+	u32 ncsi_cmd_type_errs;	/* Command type errors        */
+	u32 ncsi_cmd_csum_errs;	/* Command checksum errors    */
+	u32 ncsi_rx_pkts;	/* Rx NCSI packets            */
+	u32 ncsi_tx_pkts;	/* Tx NCSI packets            */
+	u32 ncsi_tx_aen_pkts;	/* Tx AEN packets             */
+	u32 pt_tx_pkts;		/* Tx packets                 */
+	u32 pt_tx_dropped;	/* Tx dropped packets         */
+	u32 pt_tx_channel_err;	/* Tx channel errors          */
+	u32 pt_tx_us_err;	/* Tx undersize errors        */
+	u32 pt_rx_pkts;		/* Rx packets                 */
+	u32 pt_rx_dropped;	/* Rx dropped packets         */
+	u32 pt_rx_channel_err;	/* Rx channel errors          */
+	u32 pt_rx_us_err;	/* Rx undersize errors        */
+	u32 pt_rx_os_err;	/* Rx oversize errors         */
+};
+
+struct ncsi_dev_priv;
+struct ncsi_package;
+
+#define NCSI_PACKAGE_SHIFT	5
+#define NCSI_PACKAGE_INDEX(c)	(((c) >> NCSI_PACKAGE_SHIFT) & 0x7)
+#define NCSI_CHANNEL_INDEX(c)	((c) & ((1 << NCSI_PACKAGE_SHIFT) - 1))
+#define NCSI_TO_CHANNEL(p, c)	(((p) << NCSI_PACKAGE_SHIFT) | (c))
+
+/* Channel state */
+enum {
+	ncsi_channel_state_deselected_initial,
+	ncsi_channel_state_selected_initial,
+	ncsi_channel_state_deselected_ready,
+	ncsi_channel_state_selected_ready,
+};
+
+struct ncsi_channel {
+	unsigned char               id;
+	int                         state;
+	spinlock_t                  lock;	/* Protect filters etc */
+	struct ncsi_package         *package;
+	struct ncsi_channel_version version;
+	struct ncsi_channel_cap	    caps[NCSI_CAP_MAX];
+	struct ncsi_channel_mode    modes[NCSI_MODE_MAX];
+	struct ncsi_channel_filter  *filters[NCSI_FILTER_MAX];
+	struct ncsi_channel_stats   stats;
+	struct list_head            node;
+};
+
+struct ncsi_package {
+	unsigned char        id;		/* NCSI package ID          */
+	struct ncsi_dev_priv *ndp;		/* NCSI device              */
+	atomic_t             channel_num;	/* Number of channels       */
+	spinlock_t           channel_lock;	/* Protect list of channels */
+	struct list_head     channels;		/* List of chanels          */
+	struct list_head     node;
+};
+
+struct ncsi_req {
+	unsigned char        id;		/* Request ID          */
+	bool                 used;		/* Request used or not */
+	struct ncsi_dev_priv *ndp;		/* NCSI device         */
+	struct sk_buff       *cmd;		/* Command packet      */
+	struct sk_buff       *rsp;		/* Response packet     */
+	struct timer_list    timer;		/* Associated timer    */
+	bool                 timer_enabled;	/* Timer was started   */
+};
+
+struct ncsi_dev_priv {
+	struct ncsi_dev     ndev;		/* NCSI device              */
+	int                 flags;		/* NCSI device flags        */
+	struct ncsi_package *active_package;	/* Active NCSI package      */
+	struct ncsi_channel *active_channel;	/* Active NCSI channel      */
+	atomic_t            package_num;	/* Number of packages       */
+	spinlock_t          package_lock;	/* Protect list of packages */
+	struct list_head    packages;		/* List of packages         */
+	spinlock_t          req_lock;		/* Protect request table    */
+	struct ncsi_req     reqs[256];		/* Request table            */
+	int                 last_req_idx;	/* Last used request ID     */
+	struct list_head    node;
+};
+
+extern struct list_head ncsi_dev_list;
+extern spinlock_t ncsi_dev_lock;
+
+#define TO_NCSI_DEV_PRIV(nd) \
+	container_of(nd, struct ncsi_dev_priv, ndev)
+#define NCSI_FOR_EACH_DEV(ndp) \
+	list_for_each_entry_rcu(ndp, &ncsi_dev_list, node)
+#define NCSI_FOR_EACH_PACKAGE(ndp, np) \
+	list_for_each_entry_rcu(np, &ndp->packages, node)
+#define NCSI_FOR_EACH_CHANNEL(np, nc) \
+	list_for_each_entry_rcu(nc, &np->channels, node)
+
+/* Resources */
+int ncsi_find_filter(struct ncsi_channel *nc, int table, void *data);
+int ncsi_add_filter(struct ncsi_channel *nc, int table, void *data);
+int ncsi_remove_filter(struct ncsi_channel *nc, int table, int index);
+struct ncsi_channel *ncsi_find_channel(struct ncsi_package *np,
+				       unsigned char id);
+struct ncsi_channel *ncsi_add_channel(struct ncsi_package *np,
+				      unsigned char id);
+struct ncsi_package *ncsi_find_package(struct ncsi_dev_priv *ndp,
+				       unsigned char id);
+struct ncsi_package *ncsi_add_package(struct ncsi_dev_priv *ndp,
+				      unsigned char id);
+void ncsi_remove_package(struct ncsi_package *np);
+void ncsi_find_package_and_channel(struct ncsi_dev_priv *ndp,
+				   unsigned char id,
+				   struct ncsi_package **np,
+				   struct ncsi_channel **nc);
+struct ncsi_req *ncsi_alloc_req(struct ncsi_dev_priv *ndp);
+void ncsi_free_req(struct ncsi_req *nr, bool check, bool timeout);
+struct ncsi_dev *ncsi_find_dev(struct net_device *dev);
+
+#endif /* __NCSI_INTERNAL_H__ */
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
new file mode 100644
index 0000000..b36e93d
--- /dev/null
+++ b/net/ncsi/ncsi-manage.c
@@ -0,0 +1,422 @@
+/*
+ * Copyright Gavin Shan, IBM Corporation 2016.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/netlink.h>
+
+#include <net/ncsi.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
+
+#include "internal.h"
+
+LIST_HEAD(ncsi_dev_list);
+DEFINE_SPINLOCK(ncsi_dev_lock);
+
+static inline int ncsi_filter_size(int table)
+{
+	int sizes[] = { 2, 6, 6, 6 };
+
+	BUILD_BUG_ON(ARRAY_SIZE(sizes) != NCSI_FILTER_MAX);
+	if (table < NCSI_FILTER_BASE || table >= NCSI_FILTER_MAX)
+		return -EINVAL;
+
+	return sizes[table];
+}
+
+int ncsi_find_filter(struct ncsi_channel *nc, int table, void *data)
+{
+	struct ncsi_channel_filter *ncf;
+	void *bitmap;
+	int index, size;
+
+	ncf = nc->filters[table];
+	if (!ncf)
+		return -ENXIO;
+
+	size = ncsi_filter_size(table);
+	if (size < 0)
+		return size;
+
+	spin_lock(&nc->lock);
+	bitmap = (void *)&ncf->bitmap;
+	index = -1;
+	while ((index = find_next_bit(bitmap, ncf->total, index + 1))
+	       < ncf->total) {
+		if (!memcmp(ncf->data + size * index, data, size)) {
+			spin_unlock(&nc->lock);
+			return index;
+		}
+	}
+
+	spin_unlock(&nc->lock);
+	return -ENOENT;
+}
+
+int ncsi_add_filter(struct ncsi_channel *nc, int table, void *data)
+{
+	struct ncsi_channel_filter *ncf;
+	int index, size;
+	void *bitmap;
+
+	size = ncsi_filter_size(table);
+	if (size < 0)
+		return size;
+
+	index = ncsi_find_filter(nc, table, data);
+	if (index >= 0)
+		return index;
+
+	ncf = nc->filters[table];
+	if (!ncf)
+		return -ENODEV;
+
+	spin_lock(&nc->lock);
+	bitmap = (void *)&ncf->bitmap;
+	do {
+		index = find_next_zero_bit(bitmap, ncf->total, 0);
+		if (index >= ncf->total) {
+			spin_unlock(&nc->lock);
+			return -ENOSPC;
+		}
+	} while (test_and_set_bit(index, bitmap));
+
+	memcpy(ncf->data + size * index, data, size);
+	spin_unlock(&nc->lock);
+
+	return index;
+}
+
+int ncsi_remove_filter(struct ncsi_channel *nc, int table, int index)
+{
+	struct ncsi_channel_filter *ncf;
+	int size;
+	void *bitmap;
+
+	size = ncsi_filter_size(table);
+	if (size < 0)
+		return size;
+
+	ncf = nc->filters[table];
+	if (!ncf || index >= ncf->total)
+		return -ENODEV;
+
+	spin_lock(&nc->lock);
+	bitmap = (void *)&ncf->bitmap;
+	if (test_and_clear_bit(index, bitmap))
+		memset(ncf->data + size * index, 0, size);
+	spin_unlock(&nc->lock);
+
+	return 0;
+}
+
+struct ncsi_channel *ncsi_find_channel(struct ncsi_package *np,
+				       unsigned char id)
+{
+	struct ncsi_channel *nc;
+
+	NCSI_FOR_EACH_CHANNEL(np, nc) {
+		if (nc->id == id)
+			return nc;
+	}
+
+	return NULL;
+}
+
+struct ncsi_channel *ncsi_add_channel(struct ncsi_package *np, unsigned char id)
+{
+	struct ncsi_channel *nc, *tmp;
+	int index;
+
+	nc = kzalloc(sizeof(*nc), GFP_ATOMIC);
+	if (!nc)
+		return NULL;
+
+	nc->id = id;
+	nc->package = np;
+	spin_lock_init(&nc->lock);
+	for (index = 0; index < NCSI_CAP_MAX; index++)
+		nc->caps[index].index = index;
+	for (index = 0; index < NCSI_MODE_MAX; index++)
+		nc->modes[index].index = index;
+
+	spin_lock(&np->channel_lock);
+	tmp = ncsi_find_channel(np, id);
+	if (tmp) {
+		spin_unlock(&np->channel_lock);
+		kfree(nc);
+		return tmp;
+	}
+	list_add_tail_rcu(&nc->node, &np->channels);
+	spin_unlock(&np->channel_lock);
+
+	atomic_inc(&np->channel_num);
+	return nc;
+}
+
+static void ncsi_remove_channel(struct ncsi_channel *nc)
+{
+	struct ncsi_dev_priv *ndp = nc->package->ndp;
+	struct ncsi_channel_filter *ncf;
+	int i;
+
+	/* Release filters */
+	for (i = 0; i < NCSI_FILTER_MAX; i++) {
+		ncf = nc->filters[i];
+		if (!ncf)
+			continue;
+
+		nc->filters[i] = NULL;
+		kfree(ncf);
+	}
+
+	/* Update active channel if necessary */
+	if (ndp->active_channel == nc) {
+		ndp->active_package = NULL;
+		ndp->active_channel = NULL;
+	}
+
+	/* Remove and free channel */
+	list_del_rcu(&nc->node);
+	kfree(nc);
+}
+
+struct ncsi_package *ncsi_find_package(struct ncsi_dev_priv *ndp,
+				       unsigned char id)
+{
+	struct ncsi_package *np;
+
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		if (np->id == id)
+			return np;
+	}
+
+	return NULL;
+}
+
+struct ncsi_package *ncsi_add_package(struct ncsi_dev_priv *ndp,
+				      unsigned char id)
+{
+	struct ncsi_package *np, *tmp;
+
+	np = kzalloc(sizeof(*np), GFP_ATOMIC);
+	if (!np)
+		return NULL;
+
+	np->id = id;
+	np->ndp = ndp;
+	spin_lock_init(&np->channel_lock);
+	INIT_LIST_HEAD(&np->channels);
+
+	spin_lock(&ndp->package_lock);
+	tmp = ncsi_find_package(ndp, id);
+	if (tmp) {
+		spin_unlock(&ndp->package_lock);
+		kfree(np);
+		return tmp;
+	}
+
+	list_add_tail_rcu(&np->node, &ndp->packages);
+	spin_unlock(&ndp->package_lock);
+
+	atomic_inc(&ndp->package_num);
+	return np;
+}
+
+void ncsi_remove_package(struct ncsi_package *np)
+{
+	struct ncsi_dev_priv *ndp = np->ndp;
+	struct ncsi_channel *nc, *tmp;
+
+	/* Release all child channels */
+	spin_lock(&np->channel_lock);
+	list_for_each_entry_safe(nc, tmp, &np->channels, node)
+		ncsi_remove_channel(nc);
+	spin_unlock(&np->channel_lock);
+
+	/* Clear active package if necessary */
+	if (ndp->active_package == np) {
+		ndp->active_package = NULL;
+		ndp->active_channel = NULL;
+	}
+
+	/* Remove and free package */
+	list_del_rcu(&np->node);
+	kfree(np);
+}
+
+void ncsi_find_package_and_channel(struct ncsi_dev_priv *ndp,
+				   unsigned char id,
+				   struct ncsi_package **np,
+				   struct ncsi_channel **nc)
+{
+	struct ncsi_package *p;
+	struct ncsi_channel *c;
+
+	p = ncsi_find_package(ndp, NCSI_PACKAGE_INDEX(id));
+	c = p ? ncsi_find_channel(p, NCSI_CHANNEL_INDEX(id)) : NULL;
+
+	if (np)
+		*np = p;
+	if (nc)
+		*nc = c;
+}
+
+/* For two consecutive NCSI commands, the packet IDs shouldn't
+ * be same. Otherwise, the bogus response might be replied. So
+ * the available IDs are allocated in round-robin fashion.
+ */
+struct ncsi_req *ncsi_alloc_req(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_req *nr = NULL;
+	int idx, limit = ARRAY_SIZE(ndp->reqs);
+	unsigned long flags;
+
+	spin_lock_irqsave(&ndp->req_lock, flags);
+
+	/* Check if there is one available request until the ceiling */
+	for (idx = ndp->last_req_idx; !nr && idx < limit; idx++) {
+		if (ndp->reqs[idx].used)
+			continue;
+
+		ndp->reqs[idx].used = true;
+		nr = &ndp->reqs[idx];
+		if (++ndp->last_req_idx >= limit)
+			ndp->last_req_idx = 0;
+	}
+
+	/* Fail back to check from the starting cursor */
+	for (idx = 0; !nr && idx < ndp->last_req_idx; idx++) {
+		if (ndp->reqs[idx].used)
+			continue;
+
+		ndp->reqs[idx].used = true;
+		nr = &ndp->reqs[idx];
+		if (++ndp->last_req_idx >= limit)
+			ndp->last_req_idx = 0;
+	}
+
+	spin_unlock_irqrestore(&ndp->req_lock, flags);
+	return nr;
+}
+
+void ncsi_free_req(struct ncsi_req *nr, bool check, bool timeout)
+{
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct sk_buff *cmd, *rsp;
+	unsigned long flags;
+
+	if (nr->timer_enabled) {
+		nr->timer_enabled = false;
+		del_timer_sync(&nr->timer);
+	}
+
+	spin_lock_irqsave(&ndp->req_lock, flags);
+	cmd = nr->cmd;
+	rsp = nr->rsp;
+	nr->cmd = NULL;
+	nr->rsp = NULL;
+	nr->used = false;
+	spin_unlock_irqrestore(&ndp->req_lock, flags);
+
+	/* Release command and response */
+	consume_skb(cmd);
+	consume_skb(rsp);
+}
+
+struct ncsi_dev *ncsi_find_dev(struct net_device *dev)
+{
+	struct ncsi_dev_priv *ndp;
+
+	NCSI_FOR_EACH_DEV(ndp) {
+		if (ndp->ndev.dev == dev)
+			return &ndp->ndev;
+	}
+
+	return NULL;
+}
+
+static void ncsi_req_timeout(unsigned long data)
+{
+	struct ncsi_req *nr = (struct ncsi_req *)data;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	unsigned long flags;
+
+	/* If the request already had associated response,
+	 * let the response handler to release it.
+	 */
+	spin_lock_irqsave(&ndp->req_lock, flags);
+	nr->timer_enabled = false;
+	if (nr->rsp || !nr->cmd) {
+		spin_unlock_irqrestore(&ndp->req_lock, flags);
+		return;
+	}
+	spin_unlock_irqrestore(&ndp->req_lock, flags);
+
+	/* Release the request */
+	ncsi_free_req(nr, true, true);
+}
+
+struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
+				   void (*handler)(struct ncsi_dev *ndev))
+{
+	struct ncsi_dev_priv *ndp;
+	struct ncsi_dev *nd;
+	int idx;
+
+	/* Check if the device has been registered or not */
+	nd = ncsi_find_dev(dev);
+	if (nd)
+		return nd;
+
+	/* Create NCSI device */
+	ndp = kzalloc(sizeof(*ndp), GFP_ATOMIC);
+	if (!ndp)
+		return NULL;
+
+	nd = &ndp->ndev;
+	nd->state = ncsi_dev_state_registered;
+	nd->dev = dev;
+	nd->handler = handler;
+
+	/* Initialize private NCSI device */
+	spin_lock_init(&ndp->package_lock);
+	INIT_LIST_HEAD(&ndp->packages);
+	spin_lock_init(&ndp->req_lock);
+	ndp->last_req_idx = 0;
+	for (idx = 0; idx < ARRAY_SIZE(ndp->reqs); idx++) {
+		ndp->reqs[idx].id = idx;
+		ndp->reqs[idx].ndp = ndp;
+		setup_timer(&ndp->reqs[idx].timer, ncsi_req_timeout,
+			    (unsigned long)&ndp->reqs[idx]);
+	}
+
+	spin_lock(&ncsi_dev_lock);
+	list_add_tail_rcu(&ndp->node, &ncsi_dev_list);
+	spin_unlock(&ncsi_dev_lock);
+
+	return nd;
+}
+EXPORT_SYMBOL_GPL(ncsi_register_dev);
+
+void ncsi_unregister_dev(struct ncsi_dev *nd)
+{
+	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
+	struct ncsi_package *np, *tmp;
+
+	spin_lock(&ndp->package_lock);
+	list_for_each_entry_safe(np, tmp, &ndp->packages, node)
+		ncsi_remove_package(np);
+	spin_unlock(&ndp->package_lock);
+}
+EXPORT_SYMBOL_GPL(ncsi_unregister_dev);
-- 
2.1.0
