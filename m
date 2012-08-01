From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 07/12] net/eipoib: Add private header file
Date: Wed,  1 Aug 2012 20:09:30 +0300
Message-ID: <1343840975-3252-8-git-send-email-ogerlitz@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:35601 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753658Ab2HARKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 13:10:11 -0400
In-Reply-To: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.co.il>

The header file includes all structures, macros and non-static
functions which are of use by the driver.

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/eipoib/eth_ipoib.h |  215 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 215 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/eipoib/eth_ipoib.h

diff --git a/drivers/net/eipoib/eth_ipoib.h b/drivers/net/eipoib/eth_ipoib.h
new file mode 100644
index 0000000..9a23f7d
--- /dev/null
+++ b/drivers/net/eipoib/eth_ipoib.h
@@ -0,0 +1,215 @@
+/*
+ * Copyright (c) 2012 Mellanox Technologies. All rights reserved
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * openfabric.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef _LINUX_ETH_IPOIB_H
+#define _LINUX_ETH_IPOIB_H
+
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <net/arp.h>
+#include <linux/if_vlan.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <linux/if_infiniband.h>
+#include <rdma/ib_verbs.h>
+
+#include <rdma/e_ipoib.h>
+
+/* macros and definitions */
+#define DRV_VERSION		"1.0.0"
+#define DRV_RELDATE		"June 1, 2012"
+#define DRV_NAME		"eth_ipoib"
+#define SDRV_NAME		"ipoib"
+#define DRV_DESCRIPTION		"IP-over-InfiniBand Para Virtualized Driver"
+#define EIPOIB_ABI_VER	1
+
+#undef  pr_fmt
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#define GID_LEN			16
+#define GUID_LEN		8
+
+#define PARENT_VLAN_FEATURES (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX)
+
+#define parent_for_each_slave(_parent, slave)		\
+		list_for_each_entry(slave, &(_parent)->slave_list, list)\
+
+#define PARENT_IS_OK(_parent)				\
+		(((_parent)->dev->flags & IFF_UP) &&	\
+		 netif_running((_parent)->dev)    &&	\
+		 ((_parent)->slave_cnt > 0))
+
+#define IS_E_IPOIB_PROTO(_proto)			\
+		 (((_proto) == htons(ETH_P_ARP)) ||	\
+		 ((_proto) == htons(ETH_P_RARP)) ||	\
+		 ((_proto) == htons(ETH_P_IP)))
+
+enum eipoib_emac_guest_info {
+	VALID,
+	MIGRATED_OUT,
+	INVALID,
+};
+
+/* structs */
+struct eth_arp_data {
+	u8 arp_sha[ETH_ALEN];
+	__be32 arp_sip;
+	u8 arp_dha[ETH_ALEN];
+	__be32 arp_dip;
+} __packed;
+
+struct ipoib_arp_data {
+	u8 arp_sha[INFINIBAND_ALEN];
+	__be32 arp_sip;
+	u8 arp_dha[INFINIBAND_ALEN];
+	__be32 arp_dip;
+} __packed;
+
+/* live migration support structures: */
+struct ip_member {
+	__be32 ip;
+	struct list_head list;
+};
+
+/*
+ * for each slave (emac) saves all the ip over that mac.
+ * the parent keeps that list for live migration.
+ */
+struct guest_emac_info {
+	u8 emac[ETH_ALEN];
+	u16 vlan;
+	struct list_head ip_list;
+	struct list_head list;
+	enum eipoib_emac_guest_info rec_state;
+	int num_of_retries;
+};
+
+struct neigh {
+	struct list_head list;
+	u8 emac[ETH_ALEN];
+	u8 imac[INFINIBAND_ALEN];
+	/* this part is used for neigh_add_list */
+	char cmd[PAGE_SIZE];
+};
+
+struct slave {
+	struct net_device *dev;
+	struct list_head list;
+	u16    pkey;
+	u16    vlan;
+	u8     emac[ETH_ALEN];
+	u8     imac[INFINIBAND_ALEN];
+	struct list_head neigh_list;
+};
+
+struct port_stats {
+	/* update PORT_STATS_LEN (number of stat fields)accordingly */
+	uint64_t tx_parent_dropped;
+	uint64_t tx_vif_miss;
+	uint64_t tx_neigh_miss;
+	uint64_t tx_vlan;
+	uint64_t tx_shared;
+	uint64_t tx_proto_errors;
+	uint64_t tx_skb_errors;
+	uint64_t tx_slave_err;
+
+	uint64_t rx_parent_dropped;
+	uint64_t rx_vif_miss;
+	uint64_t rx_neigh_miss;
+	uint64_t rx_vlan;
+	uint64_t rx_shared;
+	uint64_t rx_proto_errors;
+	uint64_t rx_skb_errors;
+	uint64_t rx_slave_err;
+};
+
+struct parent {
+	struct   net_device *dev;
+	int      index;
+	struct   neigh_parms nparms;
+	struct   list_head slave_list;
+	/* never change this value outside the attach/detach wrappers */
+	s32      slave_cnt;
+	rwlock_t lock;
+	struct   port_stats port_stats;
+	struct   list_head parent_list;
+	u16      flags;
+	struct   workqueue_struct *wq;
+	s8       kill_timers;
+	struct   delayed_work neigh_learn_work;
+	struct   delayed_work vif_learn_work;
+	struct   list_head neigh_add_list;
+	union    ib_gid gid;
+	char     ipoib_main_interface[IFNAMSIZ];
+	/* live migration and bonding support */
+	struct   list_head emac_ip_list;
+	struct   delayed_work emac_ip_work;
+	struct   delayed_work migrate_out_work;
+};
+
+#define eipoib_slave_get_rcu(dev) \
+	((struct slave *) rcu_dereference(dev->rx_handler_data))
+
+/* name space support for sys/fs */
+struct eipoib_net {
+	struct net	*net;	/* Associated network namespace */
+	struct class_attribute class_attr_eipoib_interfaces;
+};
+
+/* exported from main.c */
+extern int eipoib_net_id;
+extern struct list_head parent_dev_list;
+
+/* functions prototypes */
+int mod_create_sysfs(struct eipoib_net *eipoib_n);
+void mod_destroy_sysfs(struct eipoib_net *eipoib_n);
+void parent_destroy_sysfs_entry(struct parent *parent);
+int parent_create_sysfs_entry(struct parent *parent);
+int create_slave_symlinks(struct net_device *master,
+			  struct net_device *slave);
+void destroy_slave_symlinks(struct net_device *master,
+			    struct net_device *slave);
+int parent_enslave(struct net_device *parent_dev,
+		   struct net_device *slave_dev);
+int parent_release_slave(struct net_device *parent_dev,
+			 struct net_device *slave_dev);
+struct neigh *parent_get_neigh_cmd(char op, char *ifname,
+				   u8 *remac, u8 *rimac);
+struct slave *parent_get_vif_cmd(char op, char *ifname, u8 *lemac);
+ssize_t __parent_store_neighs(struct device *d,
+			      struct device_attribute *attr,
+			      const char *buffer, size_t count);
+void parent_set_ethtool_ops(struct net_device *dev);
+
+#endif /* _LINUX_ETH_IPOIB_H */
-- 
1.7.1
