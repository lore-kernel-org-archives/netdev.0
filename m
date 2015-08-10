From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/9] net: Introduce VRF related flags and helpers
Date: Mon, 10 Aug 2015 11:50:28 -0600
Message-ID: <1439229037-79213-2-git-send-email-dsa@cumulusnetworks.com>
References: <1439229037-79213-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37164 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115AbbHJRvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 13:51:45 -0400
Received: by igbpg9 with SMTP id pg9so74530866igb.0
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 10:51:44 -0700 (PDT)
In-Reply-To: <1439229037-79213-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a VRF_MASTER flag for interfaces and helper functions for determining
if a device is a VRF_MASTER.

Add link attribute for passing VRF_TABLE id.

Add vrf_ptr to netdevice.

Add various macros for determining if a device is a VRF device, the index
of the master VRF device and table associated with VRF device.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/netdevice.h    |  20 +++++++
 include/net/vrf.h            | 139 +++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h |   9 +++
 3 files changed, 168 insertions(+)
 create mode 100644 include/net/vrf.h

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 607b5f41f46f..f7a6ef2fae3a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1289,6 +1289,7 @@ enum netdev_priv_flags {
 	IFF_XMIT_DST_RELEASE_PERM	= 1<<22,
 	IFF_IPVLAN_MASTER		= 1<<23,
 	IFF_IPVLAN_SLAVE		= 1<<24,
+	IFF_VRF_MASTER			= 1<<25,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1316,6 +1317,7 @@ enum netdev_priv_flags {
 #define IFF_XMIT_DST_RELEASE_PERM	IFF_XMIT_DST_RELEASE_PERM
 #define IFF_IPVLAN_MASTER		IFF_IPVLAN_MASTER
 #define IFF_IPVLAN_SLAVE		IFF_IPVLAN_SLAVE
+#define IFF_VRF_MASTER			IFF_VRF_MASTER
 
 /**
  *	struct net_device - The DEVICE structure.
@@ -1432,6 +1434,7 @@ enum netdev_priv_flags {
  *	@dn_ptr:	DECnet specific data
  *	@ip6_ptr:	IPv6 specific data
  *	@ax25_ptr:	AX.25 specific data
+ *	@vrf_ptr:	VRF specific data
  *	@ieee80211_ptr:	IEEE 802.11 specific data, assign before registering
  *
  *	@last_rx:	Time of last Rx
@@ -1650,6 +1653,7 @@ struct net_device {
 	struct dn_dev __rcu     *dn_ptr;
 	struct inet6_dev __rcu	*ip6_ptr;
 	void			*ax25_ptr;
+	struct net_vrf_dev __rcu *vrf_ptr;
 	struct wireless_dev	*ieee80211_ptr;
 	struct wpan_dev		*ieee802154_ptr;
 #if IS_ENABLED(CONFIG_MPLS_ROUTING)
@@ -3808,6 +3812,22 @@ static inline bool netif_supports_nofcs(struct net_device *dev)
 	return dev->priv_flags & IFF_SUPP_NOFCS;
 }
 
+static inline bool netif_is_vrf(const struct net_device *dev)
+{
+	return dev->priv_flags & IFF_VRF_MASTER;
+}
+
+static inline bool netif_index_is_vrf(struct net *net, int ifindex)
+{
+	struct net_device *dev = dev_get_by_index_rcu(net, ifindex);
+	bool rc = false;
+
+	if (dev)
+		rc = netif_is_vrf(dev);
+
+	return rc;
+}
+
 /* This device needs to keep skb dst for qdisc enqueue or ndo_start_xmit() */
 static inline void netif_keep_dst(struct net_device *dev)
 {
diff --git a/include/net/vrf.h b/include/net/vrf.h
new file mode 100644
index 000000000000..25c709fdb98f
--- /dev/null
+++ b/include/net/vrf.h
@@ -0,0 +1,139 @@
+/*
+ * include/net/net_vrf.h - adds vrf dev structure definitions
+ * Copyright (c) 2015 Cumulus Networks
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __LINUX_NET_VRF_H
+#define __LINUX_NET_VRF_H
+
+struct net_vrf_dev {
+	struct rcu_head		rcu;
+	int                     ifindex; /* ifindex of master dev */
+	u32                     tb_id;   /* table id for VRF */
+};
+
+struct slave {
+	struct list_head	list;
+	struct net_device	*dev;
+};
+
+struct slave_queue {
+	struct list_head	all_slaves;
+	int			num_slaves;
+};
+
+struct net_vrf {
+	struct slave_queue	queue;
+	struct rtable           *rth;
+	u32			tb_id;
+};
+
+
+#if IS_ENABLED(CONFIG_NET_VRF)
+/* called with rcu_read_lock() */
+static inline int vrf_master_ifindex_rcu(const struct net_device *dev)
+{
+	struct net_vrf_dev *vrf_ptr;
+	int ifindex = 0;
+
+	if (!dev)
+		return 0;
+
+	if (netif_is_vrf(dev))
+		ifindex = dev->ifindex;
+	else {
+		vrf_ptr = rcu_dereference(dev->vrf_ptr);
+		if (vrf_ptr)
+			ifindex = vrf_ptr->ifindex;
+	}
+
+	return ifindex;
+}
+
+/* called with rcu_read_lock */
+static inline int vrf_dev_table_rcu(const struct net_device *dev)
+{
+	int tb_id = 0;
+
+	if (dev) {
+		struct net_vrf_dev *vrf_ptr;
+
+		vrf_ptr = rcu_dereference(dev->vrf_ptr);
+		if (vrf_ptr)
+			tb_id = vrf_ptr->tb_id;
+	}
+	return tb_id;
+}
+
+static inline int vrf_dev_table(const struct net_device *dev)
+{
+	int tb_id = 0;
+
+	rcu_read_lock();
+	tb_id = vrf_dev_table_rcu(dev);
+	rcu_read_unlock();
+
+	return tb_id;
+}
+
+/* called with rtnl */
+static inline int vrf_dev_table_rtnl(const struct net_device *dev)
+{
+	int tb_id = 0;
+
+	if (dev) {
+		struct net_vrf_dev *vrf_ptr;
+
+		vrf_ptr = rtnl_dereference(dev->vrf_ptr);
+		if (vrf_ptr)
+			tb_id = vrf_ptr->tb_id;
+	}
+	return tb_id;
+}
+
+/* caller has already checked netif_is_vrf(dev) */
+static inline struct rtable *vrf_dev_get_rth(const struct net_device *dev)
+{
+	struct rtable *rth = ERR_PTR(-ENETUNREACH);
+	struct net_vrf *vrf = netdev_priv(dev);
+
+	if (vrf) {
+		rth = vrf->rth;
+		atomic_inc(&rth->dst.__refcnt);
+	}
+	return rth;
+}
+
+#else
+static inline int vrf_master_ifindex_rcu(const struct net_device *dev)
+{
+	return 0;
+}
+
+static inline int vrf_dev_table_rcu(const struct net_device *dev)
+{
+	return 0;
+}
+
+static inline int vrf_dev_table(const struct net_device *dev)
+{
+	return 0;
+}
+
+static inline int vrf_dev_table_rtnl(const struct net_device *dev)
+{
+	return 0;
+}
+
+static inline struct rtable *vrf_dev_get_rth(const struct net_device *dev)
+{
+	return ERR_PTR(-ENETUNREACH);
+}
+#endif
+
+#endif /* __LINUX_NET_VRF_H */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index f24ec99a2262..f43ebb949f2c 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -340,6 +340,15 @@ enum macvlan_macaddr_mode {
 
 #define MACVLAN_FLAG_NOPROMISC	1
 
+/* VRF section */
+enum {
+	IFLA_VRF_UNSPEC,
+	IFLA_VRF_TABLE,
+	__IFLA_VRF_MAX
+};
+
+#define IFLA_VRF_MAX (__IFLA_VRF_MAX - 1)
+
 /* IPVLAN section */
 enum {
 	IFLA_IPVLAN_UNSPEC,
-- 
2.3.2 (Apple Git-55)
