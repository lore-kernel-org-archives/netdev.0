From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH RFC 1/6] net/ncsi: Resource management
Date: Mon,  9 Nov 2015 11:10:01 +1100
Message-ID: <1447027806-4744-2-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:34760 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbbKIALp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 19:11:45 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Mon, 9 Nov 2015 10:11:43 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 547C62CE8057
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 11:11:40 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tA90BHJC34340980
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:11:25 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tA90B71d028483
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:11:08 +1100
In-Reply-To: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NCSI spec (DSP0222) defined several objects: package, channel,
mode, filter, version and statistics etc. This defines data
structrues to represent those objects and exports interfaces
(functions) to manage them:

   * The user (e.g. netdev driver) dereference NCSI device by
     "struct ncsi_dev", which is embedded to "struct ncsi_dev_priv".
     The later one is used by NCSI stack internally.
   * Every NCSI device can have multiple packages simultaneously,
     up to 8 packages. It's represented by "struct ncsi_package"
     and identified by 3-bits ID.
   * Every NCSI package can have multiple channels, up to 32. It's
     represented by "struct ncsi_channel" and identified by 5-bits
     ID.
   * Every NCSI channel has version, statistics, various modes and
     filters. They're represented by "struct ncsi_channel_version",
     "struct ncsi_channel_stats", "struct ncsi_channel_mode" and
     "struct ncsi_channel_filter" separately.
   * The NCSI stack works in terms of command and response. One
     command, sent over interface to target package/channel, is
     expected to have a response. The same 8-bits ID are put into
     the command and response. This patch abstracts the pair of
     command and response by "struct ncsi_req".
   * "struct ncsi_cmd_arg" is used to tell the specific command
     to be sent over NCSI interface.

This also introduces CONFIG_NET_NCSI to enable NCSI stack.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 include/net/ncsi.h     |  30 ++++
 net/Kconfig            |   1 +
 net/Makefile           |   1 +
 net/ncsi/Kconfig       |  10 ++
 net/ncsi/Makefile      |   4 +
 net/ncsi/internal.h    | 306 +++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-manage.c | 363 +++++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 715 insertions(+)
 create mode 100644 include/net/ncsi.h
 create mode 100644 net/ncsi/Kconfig
 create mode 100644 net/ncsi/Makefile
 create mode 100644 net/ncsi/internal.h
 create mode 100644 net/ncsi/ncsi-manage.c

diff --git a/include/net/ncsi.h b/include/net/ncsi.h
new file mode 100644
index 0000000..2735f19
--- /dev/null
+++ b/include/net/ncsi.h
@@ -0,0 +1,30 @@
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
+	ncsi_dev_state_start		= 0x0200,
+	ncsi_dev_state_config		= 0x0300,
+	ncsi_dev_state_stop		= 0x0400
+};
+
+struct ncsi_dev {
+	int			nd_state;
+	int			nd_link_up;
+	struct net_device	*nd_dev;
+	void			(*nd_handler)(struct ncsi_dev *ndev);
+};
+
+#endif /* __NET_NCSI_H */
diff --git a/net/Kconfig b/net/Kconfig
index 57a7c5a..a92fc73 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -232,6 +232,7 @@ source "net/netlink/Kconfig"
 source "net/mpls/Kconfig"
 source "net/hsr/Kconfig"
 source "net/switchdev/Kconfig"
+source "net/ncsi/Kconfig"
 
 config RPS
 	bool
diff --git a/net/Makefile b/net/Makefile
index 3995613..9c1d4b1 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -74,3 +74,4 @@ obj-$(CONFIG_HSR)		+= hsr/
 ifneq ($(CONFIG_NET_SWITCHDEV),)
 obj-y				+= switchdev/
 endif
+obj-$(CONFIG_NET_NCSI)		+= ncsi/
diff --git a/net/ncsi/Kconfig b/net/ncsi/Kconfig
new file mode 100644
index 0000000..723f0eb
--- /dev/null
+++ b/net/ncsi/Kconfig
@@ -0,0 +1,10 @@
+#
+# Configuration for NCSI support
+#
+
+config NET_NCSI
+	bool "NCSI interface support (EXPERIMENTAL)"
+	depends on INET
+	---help---
+	  This module provides NCSI (Network Controller Sideband Interface)
+	  support.
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
index 0000000..958fd69
--- /dev/null
+++ b/net/ncsi/internal.h
@@ -0,0 +1,306 @@
+#ifndef __NCSI_INTERNAL_H__
+#define __NCSI_INTERNAL_H__
+
+/* NCSI channel capabilities */
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
+	NCSI_CAP_MC_DHCPv6	= 0x04,	/* DHCPv6 filtering           */
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
+/* NCSI channel mode */
+enum {
+	NCSI_MODE_BASE		= 0,
+	NCSI_MODE_ENABLE	= 0,	/* Channel enabled or disabled */
+	NCSI_MODE_TX_ENABLE,		/* Tx enabled or disabled      */ 
+	NCSI_MODE_LINK,			/* Link mode                   */
+	NCSI_MODE_VLAN,			/* VLAN filtering mode         */
+	NCSI_MODE_BC,			/* Broadcom filtering mode     */
+	NCSI_MODE_MC,			/* Multicast filtering mode    */
+	NCSI_MODE_AEN,			/* AEN enabled or disabled     */
+	NCSI_MODE_FC,			/* Flow control mode           */
+	NCSI_MODE_MAX
+};
+
+/* NCSI channel filters */
+enum {
+	NCSI_FILTER_BASE	= 0,
+	NCSI_FILTER_VLAN	= 0,
+	NCSI_FILTER_UC,
+	NCSI_FILTER_MC,
+	NCSI_FILTER_MIXED,
+	NCSI_FILTER_MAX
+};
+
+/* NCSI channel version */
+struct ncsi_channel_version {
+	unsigned int	ncv_version;		/* BCD encoded NCSI version */
+	unsigned int	ncv_alpha2;		/* BCD encoded NCSI version */
+	unsigned char	ncv_fw_name[12];	/* Firware name string      */
+	unsigned int	ncv_fw_version;		/* Firmware version         */
+	unsigned short	ncv_pci_ids[4];		/* PCI identification       */
+	unsigned int	ncv_mf_id;		/* Manufacture ID           */
+};
+
+/* NCSI channel capability */
+struct ncsi_channel_cap {
+	unsigned int	ncc_cap;	/* NCSI channel capability */
+};
+
+/* NCSI channel mode */
+struct ncsi_channel_mode {
+	unsigned int	ncm_enable;	/* Enabled or disabled         */
+	unsigned int	ncm_size;	/* Valid entries in ncm_data[] */
+	unsigned int	ncm_data[8];	/* Specific data for the mode  */
+};
+
+/*
+ * NCSI channel filter. According to NCSI spec, the total number
+ * of filters can't exceed 32. So it's enough to use 32 bits to
+ * track their usage
+ */
+struct ncsi_channel_filter {
+	unsigned int	ncf_total;	/* Total entries in the filter table */
+	unsigned int	ncf_entry_size;	/* Number of bytes per entry         */
+	unsigned int	ncf_bitmap;	/* Bitmap of valid entries           */
+	unsigned char	ncf_data[];	/* Data for the valid entries        */
+};
+
+/* NCSI channel statistics */
+struct ncsi_channel_stats {
+	unsigned int	ncs_hnc_cnt_hi;		/* Counter cleared            */
+	unsigned int	ncs_hnc_cnt_lo;		/* Counter cleared            */
+	unsigned int	ncs_hnc_rx_bytes;	/* Rx bytes                   */
+	unsigned int	ncs_hnc_tx_bytes;	/* Tx bytes                   */
+	unsigned int	ncs_hnc_rx_uc_pkts;	/* Rx UC packets              */
+	unsigned int	ncs_hnc_rx_mc_pkts;	/* Rx MC packets              */
+	unsigned int	ncs_hnc_rx_bc_pkts;	/* Rx BC packets              */
+	unsigned int	ncs_hnc_tx_uc_pkts;	/* Tx UC packets              */
+	unsigned int	ncs_hnc_tx_mc_pkts;	/* Tx MC packets              */
+	unsigned int	ncs_hnc_tx_bc_pkts;	/* Tx BC packets              */
+	unsigned int	ncs_hnc_fcs_err;	/* FCS errors                 */
+	unsigned int	ncs_hnc_align_err;	/* Alignment errors           */
+	unsigned int	ncs_hnc_false_carrier;	/* False carrier detection    */
+	unsigned int	ncs_hnc_runt_pkts;	/* Rx runt packets            */
+	unsigned int	ncs_hnc_jabber_pkts;	/* Rx jabber packets          */
+	unsigned int	ncs_hnc_rx_pause_xon;	/* Rx pause XON frames        */
+	unsigned int	ncs_hnc_rx_pause_xoff;	/* Rx XOFF frames             */
+	unsigned int	ncs_hnc_tx_pause_xon;	/* Tx XON frames              */
+	unsigned int	ncs_hnc_tx_pause_xoff;	/* Tx XOFF frames             */
+	unsigned int	ncs_hnc_tx_s_collision;	/* Single collision frames    */
+	unsigned int	ncs_hnc_tx_m_collision;	/* Multiple collision frames  */
+	unsigned int	ncs_hnc_l_collision;	/* Late collision frames      */
+	unsigned int	ncs_hnc_e_collision;	/* Excessive collision frames */
+	unsigned int	ncs_hnc_rx_ctl_frames;	/* Rx control frames          */
+	unsigned int	ncs_hnc_rx_64_frames;	/* Rx 64-bytes frames         */
+	unsigned int	ncs_hnc_rx_127_frames;	/* Rx 65-127 bytes frames     */
+	unsigned int	ncs_hnc_rx_255_frames;	/* Rx 128-255 bytes frames    */
+	unsigned int	ncs_hnc_rx_511_frames;	/* Rx 256-511 bytes frames    */
+	unsigned int	ncs_hnc_rx_1023_frames;	/* Rx 512-1023 bytes frames   */
+	unsigned int	ncs_hnc_rx_1522_frames;	/* Rx 1024-1522 bytes frames  */
+	unsigned int	ncs_hnc_rx_9022_frames;	/* Rx 1523-9022 bytes frames  */
+	unsigned int	ncs_hnc_tx_64_frames;	/* Tx 64-bytes frames         */
+	unsigned int	ncs_hnc_tx_127_frames;	/* Tx 65-127 bytes frames     */
+	unsigned int	ncs_hnc_tx_255_frames;	/* Tx 128-255 bytes frames    */
+	unsigned int	ncs_hnc_tx_511_frames;	/* Tx 256-511 bytes frames    */
+	unsigned int	ncs_hnc_tx_1023_frames;	/* Tx 512-1023 bytes frames   */
+	unsigned int	ncs_hnc_tx_1522_frames;	/* Tx 1024-1522 bytes frames  */
+	unsigned int	ncs_hnc_tx_9022_frames;	/* Tx 1523-9022 bytes frames  */
+	unsigned int	ncs_hnc_rx_valid_bytes;	/* Rx valid bytes             */
+	unsigned int	ncs_hnc_rx_runt_pkts;	/* Rx error runt packets      */
+	unsigned int	ncs_hnc_rx_jabber_pkts;	/* Rx error jabber packets    */
+	unsigned int	ncs_ncsi_rx_cmds;	/* Rx NCSI commands           */
+	unsigned int	ncs_ncsi_dropped_cmds;	/* Dropped commands           */
+	unsigned int	ncs_ncsi_cmd_type_errs;	/* Command type errors        */
+	unsigned int	ncs_ncsi_cmd_csum_errs;	/* Command checksum errors    */
+	unsigned int	ncs_ncsi_rx_pkts;	/* Rx NCSI packets            */
+	unsigned int	ncs_ncsi_tx_pkts;	/* Tx NCSI packets            */
+	unsigned int	ncs_ncsi_tx_aen_pkts;	/* Tx AEN packets             */
+	unsigned int	ncs_pt_tx_pkts;		/* Tx packets                 */
+	unsigned int	ncs_pt_tx_dropped;	/* Tx dropped packets         */
+	unsigned int	ncs_pt_tx_channel_err;	/* Tx channel errors          */
+	unsigned int	ncs_pt_tx_us_err;	/* Tx undersize errors        */
+	unsigned int	ncs_pt_rx_pkts;		/* Rx packets                 */
+	unsigned int	ncs_pt_rx_dropped;	/* Rx dropped packets         */
+	unsigned int	ncs_pt_rx_channel_err;	/* Rx channel errors          */
+	unsigned int	ncs_pt_rx_us_err;	/* Rx undersize errors        */
+	unsigned int	ncs_pt_rx_os_err;	/* Rx oversize errors         */
+};
+
+/* NCSI channel state */
+enum {
+	ncsi_channel_state_deselected_initial,
+	ncsi_channel_state_selected_initial,
+	ncsi_channel_state_deselected_ready,
+	ncsi_channel_state_selected_ready,
+};
+
+struct ncsi_package;
+struct ncsi_dev_priv;
+struct ncsi_channel {
+	unsigned char			nc_id;
+	int				nc_state;
+	struct ncsi_package		*nc_package;
+	struct ncsi_channel_version	nc_version;
+	struct ncsi_channel_cap		nc_caps[NCSI_CAP_MAX];
+	struct ncsi_channel_mode	nc_modes[NCSI_MODE_MAX];
+	struct ncsi_channel_filter	*nc_filters[NCSI_FILTER_MAX];
+	struct ncsi_channel_stats	nc_stats;
+	struct list_head		nc_node;
+};
+
+struct ncsi_package {
+	unsigned char		np_id;
+	struct ncsi_dev_priv	*np_ndp;
+	atomic_t		np_channel_num;
+	spinlock_t		np_channel_lock;
+	struct list_head	np_channels;
+	struct list_head	np_node;
+};
+
+struct ncsi_req {
+	unsigned char		nr_id;
+	bool			nr_used;
+	struct ncsi_dev_priv	*nr_ndp;
+	struct sk_buff		*nr_cmd;
+	struct sk_buff		*nr_rsp;
+	struct timer_list	nr_timer;
+	bool			nr_timer_enabled;
+};
+
+/*
+ * The NCSI device state is made up of major and minor states.
+ * The major state is driven by the public APIs. The minor states
+ * are for internal usage to complete the function in that API.
+ */
+enum {
+	ncsi_dev_state_major		= 0xff00,
+	ncsi_dev_state_minor		= 0x00ff,
+	ncsi_dev_state_start_deselect	= 0x0201,
+	ncsi_dev_state_start_package,
+	ncsi_dev_state_start_channel,
+	ncsi_dev_state_start_sp,
+	ncsi_dev_state_start_cis,
+	ncsi_dev_state_start_gvi,
+	ncsi_dev_state_start_gc,
+	ncsi_dev_state_start_dp,
+	ncsi_dev_state_start_active,
+	ncsi_dev_state_config_sp	= 0x0301,
+	ncsi_dev_state_config_cis,
+	ncsi_dev_state_config_sma,
+	ncsi_dev_state_config_ebf,
+	ncsi_dev_state_config_ecnt,
+	ncsi_dev_state_config_ec,
+	ncsi_dev_state_config_gls,
+	ncsi_dev_state_config_done,
+	ncsi_dev_state_stop_select	= 0x0401,
+	ncsi_dev_state_stop_dcnt,
+	ncsi_dev_state_stop_dc,
+	ncsi_dev_state_stop_deselect,
+	ncsi_dev_state_stop_done
+};
+
+struct ncsi_dev_priv {
+	struct ncsi_dev		ndp_ndev;
+#define NCSI_DEV_FLAG_CHANGE_ACTIVE	0x1
+	int			ndp_flags;
+	struct ncsi_package	*ndp_active_package;
+	struct ncsi_channel	*ndp_active_channel;
+	atomic_t		ndp_package_num;
+	spinlock_t		ndp_package_lock;
+	struct list_head	ndp_packages;
+	atomic_t		ndp_pending_reqs;
+	atomic_t		ndp_last_req_idx;
+	spinlock_t		ndp_req_lock;
+#define NCSI_DEV_MAX_REQ	256
+	struct ncsi_req		ndp_reqs[NCSI_DEV_MAX_REQ];
+	struct work_struct	ndp_work;
+	struct packet_type	ndp_ptype;
+	struct list_head	ndp_node;
+};
+
+struct ncsi_cmd_arg {
+	struct ncsi_dev_priv    *nca_ndp;
+	unsigned char		nca_type;
+	unsigned char		nca_id;
+	unsigned char		nca_package;
+	unsigned char		nca_channel;
+	unsigned short		nca_payload;
+	unsigned int		nca_portid;
+	union {
+		unsigned char   nca_bytes[16];
+		unsigned short  nca_words[8];
+		unsigned int    nca_dwords[4];
+	};
+};
+
+extern struct net *ncsi_net;
+extern struct list_head ncsi_dev_list;
+extern spinlock_t ncsi_dev_lock;
+
+#define NCSI_PACKAGE_INDEX(c)	(((c) >> 5) & 0x7)
+#define NCSI_CHANNEL_INDEX(c)	((c) & 0x1ffff)
+#define NCSI_TO_CHANNEL(p, c)	((((p) & 0x7) << 5) | ((c) & 0x1ffff))
+
+#define TO_NCSI_DEV_PRIV(nd) \
+	container_of(nd, struct ncsi_dev_priv, ndp_ndev)
+#define NCSI_FOR_EACH_DEV(ndp) \
+	list_for_each_entry_rcu(ndp, &ncsi_dev_list, ndp_node)
+#define NCSI_FOR_EACH_PACKAGE(ndp, np) \
+	list_for_each_entry_rcu(np, &ndp->ndp_packages, np_node)
+#define NCSI_FOR_EACH_CHANNEL(np, nc) \
+	list_for_each_entry_rcu(nc, &np->np_channels, nc_node)
+
+/* Resource management */
+int ncsi_find_channel_filter(struct ncsi_channel *nc, int table, void *data);
+int ncsi_add_channel_filter(struct ncsi_channel *nc, int table, void *data);
+int ncsi_del_channel_filter(struct ncsi_channel *nc, int table, int index);
+struct ncsi_channel *ncsi_add_channel(struct ncsi_package *np,
+				      unsigned char id);
+struct ncsi_channel *ncsi_find_channel(struct ncsi_package *np,
+				       unsigned char id);
+struct ncsi_package *ncsi_add_package(struct ncsi_dev_priv *ndp,
+				      unsigned char id);
+struct ncsi_package *ncsi_find_package(struct ncsi_dev_priv *ndp,
+				       unsigned char id);
+void ncsi_release_package(struct ncsi_package *np);
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
index 0000000..eb23222
--- /dev/null
+++ b/net/ncsi/ncsi-manage.c
@@ -0,0 +1,363 @@
+/*
+ * Copyright Gavin Shan, IBM Corporation 2015.
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
+int ncsi_find_channel_filter(struct ncsi_channel *nc, int table, void *data)
+{
+	struct ncsi_channel_filter *ncf;
+	int idx, entry_size;
+	void *bitmap;
+
+	switch (table) {
+	case NCSI_FILTER_VLAN:
+		entry_size = 2;
+		break;
+	case NCSI_FILTER_UC:
+	case NCSI_FILTER_MC:
+	case NCSI_FILTER_MIXED:
+		entry_size = 6;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	/* Check if the filter table has been initialized */
+	ncf = nc->nc_filters[table];
+	if (!ncf)
+		return -ENODEV;
+
+	/* Check the valid entries one by one */
+	bitmap = (void *)&ncf->ncf_bitmap;
+	idx = -1;
+	while ((idx = find_next_bit(bitmap, ncf->ncf_total, idx+1))
+		< ncf->ncf_total) {
+		if (!memcmp(ncf->ncf_data + entry_size * idx, data, entry_size))
+			return idx;
+	}
+
+	return -ENOENT;
+}
+
+int ncsi_add_channel_filter(struct ncsi_channel *nc, int table, void *data)
+{
+	struct ncsi_channel_filter *ncf;
+	int idx, entry_size;
+	void *bitmap;
+
+	/* Needn't add it if it's already existing */
+	idx = ncsi_find_channel_filter(nc, table, data);
+	if (idx >= 0)
+		return idx;
+
+	switch (table) {
+	case NCSI_FILTER_VLAN:
+		entry_size = 2;
+		break;
+	case NCSI_FILTER_UC:
+	case NCSI_FILTER_MC:
+	case NCSI_FILTER_MIXED:
+		entry_size = 6;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	/* Check if the filter table has been initialized */
+	ncf = nc->nc_filters[table];
+	if (!ncf)
+		return -ENODEV;
+
+	/* Propagate the filter */
+	bitmap = (void *)&ncf->ncf_bitmap;
+	do {
+		idx = find_next_zero_bit(bitmap, ncf->ncf_total, 0);
+		if (idx >= ncf->ncf_total)
+			return -ENOSPC;
+	} while (test_and_set_bit(idx, bitmap));
+
+	memcpy(ncf->ncf_data + entry_size * idx, data, entry_size);
+	return idx;
+}
+
+int ncsi_del_channel_filter(struct ncsi_channel *nc, int table, int index)
+{
+	struct ncsi_channel_filter *ncf;
+	int entry_size;
+	void *bitmap;
+
+	switch (table) {
+	case NCSI_FILTER_VLAN:
+		entry_size = 2;
+		break;
+	case NCSI_FILTER_UC:
+	case NCSI_FILTER_MC:
+	case NCSI_FILTER_MIXED:
+		entry_size = 6;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	/* Check if the filter table has been initialized */
+	ncf = nc->nc_filters[table];
+	if (!ncf || index >= ncf->ncf_total)
+		return -ENODEV;
+
+	/* Check if the entry is valid */
+	bitmap = (void *)&ncf->ncf_bitmap;
+	if (test_and_clear_bit(index, bitmap))
+		memset(ncf->ncf_data + entry_size * index, 0, entry_size);
+
+	return 0;
+}
+
+struct ncsi_channel *ncsi_add_channel(struct ncsi_package *np, unsigned char id)
+{
+	struct ncsi_channel *nc, *tmp;
+
+	nc = kzalloc(sizeof(*nc), GFP_ATOMIC);
+	if (!nc) {
+		pr_warn("%s: Out of memory !\n", __func__);
+		return NULL;
+	}
+
+	nc->nc_package = np;
+	nc->nc_id = id;
+
+	spin_lock(&np->np_channel_lock);
+	tmp = ncsi_find_channel(np, id);
+	if (tmp) {
+		spin_unlock(&np->np_channel_lock);
+		kfree(nc);
+		return tmp;
+	}
+	list_add_tail_rcu(&nc->nc_node, &np->np_channels);
+	spin_unlock(&np->np_channel_lock);
+
+	atomic_inc(&np->np_channel_num);
+	return nc;
+}
+
+struct ncsi_channel *ncsi_find_channel(struct ncsi_package *np,
+				       unsigned char id)
+{
+	struct ncsi_channel *nc;
+
+	NCSI_FOR_EACH_CHANNEL(np, nc) {
+		if (nc->nc_id == id)
+			return nc;
+	}
+
+	return NULL;
+}
+
+static void ncsi_release_channel(struct ncsi_channel *nc)
+{
+	struct ncsi_dev_priv *ndp = nc->nc_package->np_ndp;
+	struct ncsi_package *np = nc->nc_package;
+	struct ncsi_channel_filter *ncf;
+	int i;
+
+	/* Release filters */
+	for (i = 0; i < NCSI_FILTER_MAX; i++) {
+		ncf = nc->nc_filters[i];
+		if (!ncf)
+			continue;
+
+		nc->nc_filters[i] = NULL;
+		kfree(ncf);
+	}
+
+	/* Update active channel if necessary */
+	if (ndp->ndp_active_channel == nc) {
+		ndp->ndp_active_package = NULL;
+		ndp->ndp_active_channel = NULL;
+	}
+
+	/* Remove and free channel */
+	list_del_rcu(&nc->nc_node);
+	kfree(nc);
+	BUG_ON(atomic_dec_return(&np->np_channel_num) < 0);
+}
+
+struct ncsi_package *ncsi_add_package(struct ncsi_dev_priv *ndp,
+				      unsigned char id)
+{
+	struct ncsi_package *np, *tmp;
+
+	np = kzalloc(sizeof(*np), GFP_ATOMIC);
+	if (!np) {
+		pr_warn("%s: Out of memory !\n", __func__);
+		return NULL;
+	}
+
+	np->np_id = id;
+	np->np_ndp = ndp;
+	spin_lock_init(&np->np_channel_lock);
+	INIT_LIST_HEAD(&np->np_channels);
+
+	spin_lock(&ndp->ndp_package_lock);
+	tmp = ncsi_find_package(ndp, id);
+	if (tmp) {
+		spin_unlock(&ndp->ndp_package_lock);
+		kfree(np);
+		return tmp;
+	}
+	list_add_tail_rcu(&np->np_node, &ndp->ndp_packages);
+	spin_unlock(&ndp->ndp_package_lock);
+
+	atomic_inc(&ndp->ndp_package_num);
+	return np;
+}
+
+struct ncsi_package *ncsi_find_package(struct ncsi_dev_priv *ndp,
+				       unsigned char id)
+{
+	struct ncsi_package *np;
+
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		if (np->np_id == id)
+			return np;
+	}
+
+	return NULL;
+}
+
+void ncsi_release_package(struct ncsi_package *np)
+{
+	struct ncsi_dev_priv *ndp = np->np_ndp;
+	struct ncsi_channel *nc, *tmp;
+
+	/* Release all child channels */
+	spin_lock(&np->np_channel_lock);
+	list_for_each_entry_safe(nc, tmp, &np->np_channels, nc_node)
+		ncsi_release_channel(nc);
+	spin_unlock(&np->np_channel_lock);
+
+	/* Clear active package if necessary */
+	if (ndp->ndp_active_package == np) {
+		ndp->ndp_active_package = NULL;
+		ndp->ndp_active_channel = NULL;
+	}
+
+	/* Remove and free package */
+	list_del_rcu(&np->np_node);
+	kfree(np);
+
+	/* Decrease number of packages */
+	BUG_ON(atomic_dec_return(&ndp->ndp_package_num) < 0);
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
+/*
+ * For two consective NCSI commands, the packet IDs shouldn't be
+ * same. Otherwise, the bogus response might be replied. So the
+ * available IDs are allocated in round-robin fasion.
+ */
+struct ncsi_req *ncsi_alloc_req(struct ncsi_dev_priv *ndp)
+{
+	struct ncsi_req *nr = NULL;
+	int idx, limit = 256;
+
+	spin_lock(&ndp->ndp_req_lock);
+
+	/* Check if there is one available request until the ceiling */
+	for (idx = atomic_read(&ndp->ndp_last_req_idx);
+	     !nr && idx < limit; idx++) {
+		if (ndp->ndp_reqs[idx].nr_used)
+			continue;
+
+		ndp->ndp_reqs[idx].nr_used = true;
+		nr = &ndp->ndp_reqs[idx];
+		atomic_inc(&ndp->ndp_last_req_idx);
+		if (atomic_read(&ndp->ndp_last_req_idx) >= limit)
+			atomic_set(&ndp->ndp_last_req_idx, 0);
+	}
+
+	/* Fail back to check from the starting cursor */
+	for (idx = 0; !nr && idx < atomic_read(&ndp->ndp_last_req_idx); idx++) {
+		if (ndp->ndp_reqs[idx].nr_used)
+			continue;
+
+		ndp->ndp_reqs[idx].nr_used = true;
+		nr = &ndp->ndp_reqs[idx];
+		atomic_inc(&ndp->ndp_last_req_idx);
+		if (atomic_read(&ndp->ndp_last_req_idx) >= limit)
+			atomic_set(&ndp->ndp_last_req_idx, 0);
+	}
+
+	spin_unlock(&ndp->ndp_req_lock);
+	return nr;
+}
+
+void ncsi_free_req(struct ncsi_req *nr, bool check, bool timeout)
+{
+	struct ncsi_dev_priv *ndp = nr->nr_ndp;
+	struct sk_buff *cmd, *rsp;
+
+	if (nr->nr_timer_enabled) {
+		nr->nr_timer_enabled = false;
+		del_timer_sync(&nr->nr_timer);
+	}
+
+	spin_lock(&ndp->ndp_req_lock);
+	cmd = nr->nr_cmd;
+	rsp = nr->nr_rsp;
+	nr->nr_cmd = NULL;
+	nr->nr_rsp = NULL;
+	nr->nr_used = false;
+	spin_unlock(&ndp->ndp_req_lock);
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
+		if (ndp->ndp_ndev.nd_dev == dev)
+			return &ndp->ndp_ndev;
+	}
+
+	return NULL;
+}
-- 
2.1.0
