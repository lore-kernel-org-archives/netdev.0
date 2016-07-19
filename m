From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next v3 01/10] net/ncsi: Resource management
Date: Tue, 19 Jul 2016 11:54:16 +1000
Message-ID: <1468893265-10635-2-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	gerlitz.or@gmail.com, weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:28915 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752307AbcGSByx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 21:54:53 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6J1sJFC013912
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:53 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2495r802cd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:52 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 19 Jul 2016 11:54:49 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 901F52BB0045
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:28 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6J1sSSJ22806656
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:28 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6J1sRQJ018403
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:28 +1000
In-Reply-To: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
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

link: https://www.dmtf.org/sites/default/files/standards/documents/DSP0222_1.1.0.pdf
Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 include/net/ncsi.h     |  46 ++++++
 net/Kconfig            |   1 +
 net/Makefile           |   1 +
 net/ncsi/Kconfig       |  12 ++
 net/ncsi/Makefile      |   4 +
 net/ncsi/internal.h    | 256 +++++++++++++++++++++++++++++
 net/ncsi/ncsi-manage.c | 436 +++++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 756 insertions(+)
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
index 0000000..89028e1
--- /dev/null
+++ b/net/ncsi/internal.h
@@ -0,0 +1,256 @@
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
+	NCSI_CAP_GENERIC_HWA             = 0x01, /* HW arbitration           */
+	NCSI_CAP_GENERIC_HDS             = 0x02, /* HNC driver status change */
+	NCSI_CAP_GENERIC_FC              = 0x04, /* HNC to MC flow control   */
+	NCSI_CAP_GENERIC_FC1             = 0x08, /* MC to HNC flow control   */
+	NCSI_CAP_GENERIC_MC              = 0x10, /* Global MC filtering      */
+	NCSI_CAP_GENERIC_HWA_UNKNOWN     = 0x00, /* Unknown HW arbitration   */
+	NCSI_CAP_GENERIC_HWA_SUPPORT     = 0x20, /* Supported HW arbitration */
+	NCSI_CAP_GENERIC_HWA_NOT_SUPPORT = 0x40, /* No HW arbitration        */
+	NCSI_CAP_GENERIC_HWA_RESERVED    = 0x60, /* Reserved HW arbitration  */
+	NCSI_CAP_GENERIC_HWA_MASK        = 0x60, /* Mask for HW arbitration  */
+	NCSI_CAP_GENERIC_MASK            = 0x7f,
+	NCSI_CAP_BC_ARP                  = 0x01, /* ARP packet filtering     */
+	NCSI_CAP_BC_DHCPC                = 0x02, /* DHCP client filtering    */
+	NCSI_CAP_BC_DHCPS                = 0x04, /* DHCP server filtering    */
+	NCSI_CAP_BC_NETBIOS              = 0x08, /* NetBIOS packet filtering */
+	NCSI_CAP_BC_MASK                 = 0x0f,
+	NCSI_CAP_MC_IPV6_NEIGHBOR        = 0x01, /* IPv6 neighbor filtering  */
+	NCSI_CAP_MC_IPV6_ROUTER          = 0x02, /* IPv6 router filering     */
+	NCSI_CAP_MC_DHCPV6_RELAY         = 0x04, /* DHCPv6 relay / server MC */
+	NCSI_CAP_MC_DHCPV6_WELL_KNOWN    = 0x08, /* DHCPv6 well-known MC     */
+	NCSI_CAP_MC_IPV6_MLD             = 0x10, /* IPv6 MLD filtering       */
+	NCSI_CAP_MC_IPV6_NEIGHBOR_S      = 0x20, /* IPv6 neighbour filtering */
+	NCSI_CAP_MC_MASK                 = 0x3f,
+	NCSI_CAP_AEN_LSC                 = 0x01, /* Link status change       */
+	NCSI_CAP_AEN_CR                  = 0x02, /* Configuration required   */
+	NCSI_CAP_AEN_HDS                 = 0x04, /* HNC driver status        */
+	NCSI_CAP_AEN_MASK                = 0x07,
+	NCSI_CAP_VLAN_ONLY               = 0x01, /* Filter VLAN packet only  */
+	NCSI_CAP_VLAN_NO                 = 0x02, /* Filter VLAN and non-VLAN */
+	NCSI_CAP_VLAN_ANY                = 0x04, /* Filter Any-and-non-VLAN  */
+	NCSI_CAP_VLAN_MASK               = 0x07
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
+struct ncsi_channel {
+	unsigned char               id;
+	int                         state;
+#define NCSI_CHANNEL_INACTIVE		1
+#define NCSI_CHANNEL_ACTIVE		2
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
+	unsigned char        id;          /* NCSI 3-bits package ID */
+	unsigned char        uuid[16];    /* UUID                   */
+	struct ncsi_dev_priv *ndp;        /* NCSI device            */
+	spinlock_t           lock;        /* Protect the package    */
+	unsigned int         channel_num; /* Number of channels     */
+	struct list_head     channels;    /* List of chanels        */
+	struct list_head     node;        /* Form list of packages  */
+};
+
+struct ncsi_request {
+	unsigned char        id;      /* Request ID - 0 to 255           */
+	bool                 used;    /* Request that has been assigned  */
+	bool                 driven;  /* Drive state machine             */
+	struct ncsi_dev_priv *ndp;    /* Associated NCSI device          */
+	struct sk_buff       *cmd;    /* Associated NCSI command packet  */
+	struct sk_buff       *rsp;    /* Associated NCSI response packet */
+	struct timer_list    timer;   /* Timer on waiting for response   */
+	bool                 enabled; /* Time has been enabled or not    */
+};
+
+struct ncsi_dev_priv {
+	struct ncsi_dev     ndev;            /* Associated NCSI device     */
+	unsigned int        flags;           /* NCSI device flags          */
+	spinlock_t          lock;            /* Protect the NCSI device    */
+	unsigned int        package_num;     /* Number of packages         */
+	struct list_head    packages;        /* List of packages           */
+	struct ncsi_request requests[256];   /* Request table              */
+	unsigned int        request_id;      /* Last used request ID       */
+	struct list_head    node;            /* Form NCSI device list      */
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
+struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp, bool driven);
+void ncsi_free_request(struct ncsi_request *nr);
+struct ncsi_dev *ncsi_find_dev(struct net_device *dev);
+
+#endif /* __NCSI_INTERNAL_H__ */
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
new file mode 100644
index 0000000..0e28ed8
--- /dev/null
+++ b/net/ncsi/ncsi-manage.c
@@ -0,0 +1,436 @@
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
+	unsigned long flags;
+
+	ncf = nc->filters[table];
+	if (!ncf)
+		return -ENXIO;
+
+	size = ncsi_filter_size(table);
+	if (size < 0)
+		return size;
+
+	spin_lock_irqsave(&nc->lock, flags);
+	bitmap = (void *)&ncf->bitmap;
+	index = -1;
+	while ((index = find_next_bit(bitmap, ncf->total, index + 1))
+	       < ncf->total) {
+		if (!memcmp(ncf->data + size * index, data, size)) {
+			spin_unlock_irqrestore(&nc->lock, flags);
+			return index;
+		}
+	}
+	spin_unlock_irqrestore(&nc->lock, flags);
+
+	return -ENOENT;
+}
+
+int ncsi_add_filter(struct ncsi_channel *nc, int table, void *data)
+{
+	struct ncsi_channel_filter *ncf;
+	int index, size;
+	void *bitmap;
+	unsigned long flags;
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
+	spin_lock_irqsave(&nc->lock, flags);
+	bitmap = (void *)&ncf->bitmap;
+	do {
+		index = find_next_zero_bit(bitmap, ncf->total, 0);
+		if (index >= ncf->total) {
+			spin_unlock_irqrestore(&nc->lock, flags);
+			return -ENOSPC;
+		}
+	} while (test_and_set_bit(index, bitmap));
+
+	memcpy(ncf->data + size * index, data, size);
+	spin_unlock_irqrestore(&nc->lock, flags);
+
+	return index;
+}
+
+int ncsi_remove_filter(struct ncsi_channel *nc, int table, int index)
+{
+	struct ncsi_channel_filter *ncf;
+	int size;
+	void *bitmap;
+	unsigned long flags;
+
+	size = ncsi_filter_size(table);
+	if (size < 0)
+		return size;
+
+	ncf = nc->filters[table];
+	if (!ncf || index >= ncf->total)
+		return -ENODEV;
+
+	spin_lock_irqsave(&nc->lock, flags);
+	bitmap = (void *)&ncf->bitmap;
+	if (test_and_clear_bit(index, bitmap))
+		memset(ncf->data + size * index, 0, size);
+	spin_unlock_irqrestore(&nc->lock, flags);
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
+	unsigned long flags;
+
+	nc = kzalloc(sizeof(*nc), GFP_ATOMIC);
+	if (!nc)
+		return NULL;
+
+	nc->id = id;
+	nc->package = np;
+	nc->state = NCSI_CHANNEL_INACTIVE;
+	spin_lock_init(&nc->lock);
+	for (index = 0; index < NCSI_CAP_MAX; index++)
+		nc->caps[index].index = index;
+	for (index = 0; index < NCSI_MODE_MAX; index++)
+		nc->modes[index].index = index;
+
+	spin_lock_irqsave(&np->lock, flags);
+	tmp = ncsi_find_channel(np, id);
+	if (tmp) {
+		spin_unlock_irqrestore(&np->lock, flags);
+		kfree(nc);
+		return tmp;
+	}
+
+	list_add_tail_rcu(&nc->node, &np->channels);
+	np->channel_num++;
+	spin_unlock_irqrestore(&np->lock, flags);
+
+	return nc;
+}
+
+static void ncsi_remove_channel(struct ncsi_channel *nc)
+{
+	struct ncsi_package *np = nc->package;
+	struct ncsi_channel_filter *ncf;
+	unsigned long flags;
+	int i;
+
+	/* Release filters */
+	spin_lock_irqsave(&nc->lock, flags);
+	for (i = 0; i < NCSI_FILTER_MAX; i++) {
+		ncf = nc->filters[i];
+		if (!ncf)
+			continue;
+
+		nc->filters[i] = NULL;
+		kfree(ncf);
+	}
+
+	nc->state = NCSI_CHANNEL_INACTIVE;
+	spin_unlock_irqrestore(&nc->lock, flags);
+
+	/* Remove and free channel */
+	spin_lock_irqsave(&np->lock, flags);
+	list_del_rcu(&nc->node);
+	np->channel_num--;
+	spin_unlock_irqrestore(&np->lock, flags);
+
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
+	unsigned long flags;
+
+	np = kzalloc(sizeof(*np), GFP_ATOMIC);
+	if (!np)
+		return NULL;
+
+	np->id = id;
+	np->ndp = ndp;
+	spin_lock_init(&np->lock);
+	INIT_LIST_HEAD(&np->channels);
+
+	spin_lock_irqsave(&ndp->lock, flags);
+	tmp = ncsi_find_package(ndp, id);
+	if (tmp) {
+		spin_unlock_irqrestore(&ndp->lock, flags);
+		kfree(np);
+		return tmp;
+	}
+
+	list_add_tail_rcu(&np->node, &ndp->packages);
+	ndp->package_num++;
+	spin_unlock_irqrestore(&ndp->lock, flags);
+
+	return np;
+}
+
+void ncsi_remove_package(struct ncsi_package *np)
+{
+	struct ncsi_dev_priv *ndp = np->ndp;
+	struct ncsi_channel *nc, *tmp;
+	unsigned long flags;
+
+	/* Release all child channels */
+	list_for_each_entry_safe(nc, tmp, &np->channels, node)
+		ncsi_remove_channel(nc);
+
+	/* Remove and free package */
+	spin_lock_irqsave(&ndp->lock, flags);
+	list_del_rcu(&np->node);
+	ndp->package_num--;
+	spin_unlock_irqrestore(&ndp->lock, flags);
+
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
+struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp, bool driven)
+{
+	struct ncsi_request *nr = NULL;
+	int i, limit = ARRAY_SIZE(ndp->requests);
+	unsigned long flags;
+
+	/* Check if there is one available request until the ceiling */
+	spin_lock_irqsave(&ndp->lock, flags);
+	for (i = ndp->request_id; !nr && i < limit; i++) {
+		if (ndp->requests[i].used)
+			continue;
+
+		nr = &ndp->requests[i];
+		nr->used = true;
+		nr->driven = driven;
+		if (++ndp->request_id >= limit)
+			ndp->request_id = 0;
+	}
+
+	/* Fail back to check from the starting cursor */
+	for (i = 0; !nr && i < ndp->request_id; i++) {
+		if (ndp->requests[i].used)
+			continue;
+
+		nr = &ndp->requests[i];
+		nr->used = true;
+		nr->driven = driven;
+		if (++ndp->request_id >= limit)
+			ndp->request_id = 0;
+	}
+	spin_unlock_irqrestore(&ndp->lock, flags);
+
+	return nr;
+}
+
+void ncsi_free_request(struct ncsi_request *nr)
+{
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct sk_buff *cmd, *rsp;
+	unsigned long flags;
+
+	if (nr->enabled) {
+		nr->enabled = false;
+		del_timer_sync(&nr->timer);
+	}
+
+	spin_lock_irqsave(&ndp->lock, flags);
+	cmd = nr->cmd;
+	rsp = nr->rsp;
+	nr->cmd = NULL;
+	nr->rsp = NULL;
+	nr->used = false;
+	spin_unlock_irqrestore(&ndp->lock, flags);
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
+static void ncsi_request_timeout(unsigned long data)
+{
+	struct ncsi_request *nr = (struct ncsi_request *)data;
+	struct ncsi_dev_priv *ndp = nr->ndp;
+	unsigned long flags;
+
+	/* If the request already had associated response,
+	 * let the response handler to release it.
+	 */
+	spin_lock_irqsave(&ndp->lock, flags);
+	nr->enabled = false;
+	if (nr->rsp || !nr->cmd) {
+		spin_unlock_irqrestore(&ndp->lock, flags);
+		return;
+	}
+	spin_unlock_irqrestore(&ndp->lock, flags);
+
+	/* Release the request */
+	ncsi_free_request(nr);
+}
+
+struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
+				   void (*handler)(struct ncsi_dev *ndev))
+{
+	struct ncsi_dev_priv *ndp;
+	struct ncsi_dev *nd;
+	unsigned long flags;
+	int i;
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
+	spin_lock_init(&ndp->lock);
+	INIT_LIST_HEAD(&ndp->packages);
+	ndp->request_id = 0;
+	for (i = 0; i < ARRAY_SIZE(ndp->requests); i++) {
+		ndp->requests[i].id = i;
+		ndp->requests[i].ndp = ndp;
+		setup_timer(&ndp->requests[i].timer,
+			    ncsi_request_timeout,
+			    (unsigned long)&ndp->requests[i]);
+	}
+
+	spin_lock_irqsave(&ncsi_dev_lock, flags);
+	list_add_tail_rcu(&ndp->node, &ncsi_dev_list);
+	spin_unlock_irqrestore(&ncsi_dev_lock, flags);
+
+	return nd;
+}
+EXPORT_SYMBOL_GPL(ncsi_register_dev);
+
+void ncsi_unregister_dev(struct ncsi_dev *nd)
+{
+	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
+	struct ncsi_package *np, *tmp;
+	unsigned long flags;
+
+	list_for_each_entry_safe(np, tmp, &ndp->packages, node)
+		ncsi_remove_package(np);
+
+	spin_lock_irqsave(&ncsi_dev_lock, flags);
+	list_del_rcu(&ndp->node);
+	spin_unlock_irqrestore(&ncsi_dev_lock, flags);
+
+	kfree(ndp);
+}
+EXPORT_SYMBOL_GPL(ncsi_unregister_dev);
-- 
2.1.0
