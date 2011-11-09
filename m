From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 5/6 v4] macvlan: Add support to for netdev ops to
	set MAC/VLAN filters
Date: Tue, 08 Nov 2011 23:56:01 -0800
Message-ID: <20111109075601.13549.28485.stgit@rhel6.1>
References: <20111109075449.13549.58135.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: chrisw@redhat.com, sri@us.ibm.com, dragos.tatulea@gmail.com,
	kvm@vger.kernel.org, arnd@arndb.de, mst@redhat.com,
	gregory.v.rose@intel.com, mchan@broadcom.com, dwang2@cisco.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com, kaber@trash.net,
	benve@cisco.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-4.cisco.com ([173.36.130.15]:25847 "EHLO
	mtv-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932781Ab1KHX7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 18:59:36 -0500
In-Reply-To: <20111109075449.13549.58135.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support for MAC and VLAN filter netdev ops
on a macvlan interface. It adds support for set_rx_filter_addr and
set_rx_filter_vlan netdev operations. It currently supports only macvlan
PASSTHRU mode. And removes the code that puts the lowerdev in promiscous mode.

For passthru mode,
	For both Address and vlan filters set, lowerdev
	netdev_ops->set_rx_filter_addr and netdev_ops->set_rx_filter_vlan
	are called if the lowerdev supports these ops.

	Else parse the filter data and update the lowerdev filters:
	 - Address filters: macvlan netdev uc and mc lists and flags are
	updated to reflect the addresses and address filter flags that came
	in the filter. Which inturn results in calls to macvlan_set_rx_mode and
	macvlan_change_rx_flags. These functions pass the filter addresses
	and flags to lowerdev netdev. And the lowerdev driver will pass it
	to the hw.

	- VLAN filter: Currently applied vlan bitmap is cached in
	struct macvlan_dev->vlan_filter. This vlan bitmap is updated to
	reflect the new bitmap that came in the netlink vlan filter msg.
	macvlan_vlan_rx_add_vid and macvlan_vlan_rx_kill_vid are called
	to update the vlan ids on the macvlan netdev, which in turn results in
	passing the vlan ids to the lowerdev using netdev_ops
	ndo_vlan_rx_add_vid and ndo_vlan_rx_kill_vid


Note: In future if most lowerdev drivers find use for these ops and start
supporting them, we could remove the local handling of filters for passthru
mode in macvlan

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/macvlan.c      |  331 ++++++++++++++++++++++++++++++++++++++++----
 include/linux/if_macvlan.h |    2 
 2 files changed, 300 insertions(+), 33 deletions(-)


diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 7413497..c2dea97 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -309,30 +309,37 @@ static int macvlan_open(struct net_device *dev)
 	struct net_device *lowerdev = vlan->lowerdev;
 	int err;
 
-	if (vlan->port->passthru) {
-		dev_set_promiscuity(lowerdev, 1);
-		goto hash_add;
-	}
+	if (!vlan->port->passthru) {
+		err = -EBUSY;
+		if (macvlan_addr_busy(vlan->port, dev->dev_addr))
+			goto out;
 
-	err = -EBUSY;
-	if (macvlan_addr_busy(vlan->port, dev->dev_addr))
-		goto out;
+		err = dev_uc_add(lowerdev, dev->dev_addr);
+		if (err < 0)
+			goto out;
+	}
 
-	err = dev_uc_add(lowerdev, dev->dev_addr);
-	if (err < 0)
-		goto out;
 	if (dev->flags & IFF_ALLMULTI) {
 		err = dev_set_allmulti(lowerdev, 1);
 		if (err < 0)
 			goto del_unicast;
 	}
 
-hash_add:
+	if (dev->flags & IFF_PROMISC) {
+		err = dev_set_promiscuity(lowerdev, 1);
+		if (err < 0)
+			goto unset_allmulti;
+	}
+
 	macvlan_hash_add(vlan);
 	return 0;
 
+unset_allmulti:
+	dev_set_allmulti(lowerdev, -1);
+
 del_unicast:
-	dev_uc_del(lowerdev, dev->dev_addr);
+	if (!vlan->port->passthru)
+		dev_uc_del(lowerdev, dev->dev_addr);
 out:
 	return err;
 }
@@ -342,18 +349,16 @@ static int macvlan_stop(struct net_device *dev)
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
-	if (vlan->port->passthru) {
-		dev_set_promiscuity(lowerdev, -1);
-		goto hash_del;
-	}
-
+	dev_uc_unsync(lowerdev, dev);
 	dev_mc_unsync(lowerdev, dev);
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(lowerdev, -1);
+	if (dev->flags & IFF_PROMISC)
+		dev_set_promiscuity(lowerdev, -1);
 
-	dev_uc_del(lowerdev, dev->dev_addr);
+	if (!vlan->port->passthru)
+		dev_uc_del(lowerdev, dev->dev_addr);
 
-hash_del:
 	macvlan_hash_del(vlan, !dev->dismantle);
 	return 0;
 }
@@ -394,12 +399,16 @@ static void macvlan_change_rx_flags(struct net_device *dev, int change)
 
 	if (change & IFF_ALLMULTI)
 		dev_set_allmulti(lowerdev, dev->flags & IFF_ALLMULTI ? 1 : -1);
+	if (change & IFF_PROMISC)
+		dev_set_promiscuity(lowerdev,
+			dev->flags & IFF_PROMISC ? 1 : -1);
 }
 
-static void macvlan_set_multicast_list(struct net_device *dev)
+static void macvlan_set_rx_mode(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
+	dev_uc_sync(vlan->lowerdev, dev);
 	dev_mc_sync(vlan->lowerdev, dev);
 }
 
@@ -542,6 +551,257 @@ static void macvlan_vlan_rx_kill_vid(struct net_device *dev,
 		ops->ndo_vlan_rx_kill_vid(lowerdev, vid);
 }
 
+static inline void macvlan_set_filter_vlan(struct net_device *dev, int vid)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	set_bit(vid, vlan->vlan_filter);
+	macvlan_vlan_rx_add_vid(dev, vid);
+}
+
+static inline void macvlan_clear_filter_vlan(struct net_device *dev, int vid)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	clear_bit(vid, vlan->vlan_filter);
+	macvlan_vlan_rx_kill_vid(dev, vid);
+}
+
+static int macvlan_set_rx_filter_vlan_passthru(struct net_device *dev, int vf,
+					       struct nlattr *tb[])
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+	const struct net_device_ops *ops = lowerdev->netdev_ops;
+	unsigned long *vlans;
+	u16 vid;
+
+	if (ops->ndo_set_rx_filter_vlan)
+		return ops->ndo_set_rx_filter_vlan(dev, vf, tb);
+
+	if (!tb[IFLA_RX_FILTER_VLAN_BITMAP])
+		return -EINVAL;
+
+	vlans = nla_data(tb[IFLA_RX_FILTER_VLAN_BITMAP]);
+
+	/*
+	 *	Clear vlans that are not present in the new filter
+	 */
+	for_each_set_bit(vid, vlan->vlan_filter, VLAN_N_VID) {
+		if (!test_bit(vid, vlans))
+			macvlan_clear_filter_vlan(dev, vid);
+	}
+
+	/*
+	 *	Set new vlans that came in the filter
+	 */
+	for_each_set_bit(vid, vlans, VLAN_N_VID) {
+		if (!test_bit(vid, vlan->vlan_filter))
+			macvlan_set_filter_vlan(dev, vid);
+	}
+
+	return 0;
+}
+
+static int macvlan_set_rx_filter_vlan(struct net_device *dev, int vf,
+				      struct nlattr *tb[])
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	int err;
+
+	if (vf != SELF_VF)
+		return -EINVAL;
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		return macvlan_set_rx_filter_vlan_passthru(dev, vf, tb);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static int macvlan_addr_in_hw_list(struct netdev_hw_addr_list *list,
+				   u8 *addr, int addrlen)
+{
+	struct netdev_hw_addr *ha;
+
+	netdev_hw_addr_list_for_each(ha, list) {
+		if (!memcmp(ha->addr, addr, addrlen))
+			return 1;
+	}
+
+	return 0;
+}
+
+static int macvlan_addr_in_attrs(struct nlattr *addr_list, u8 *addr,
+				 int addrlen)
+{
+	struct nlattr *addr_attr;
+	int addr_rem;
+
+	nla_for_each_nested(addr_attr, addr_list, addr_rem) {
+		if (!memcmp(nla_data(addr_attr), addr, addrlen))
+			return 1;
+	}
+
+	return 0;
+}
+
+static int macvlan_update_hw_addr_list(struct net_device *dev,
+				struct netdev_hw_addr_list *curr_addr_list,
+				int addr_list_type,
+				struct nlattr *new_addr_attrs)
+{
+	struct nlattr *addr_attr;
+	int addr_rem;
+	u8 *addr;
+	int alen, i;
+	int err = 0;
+
+	if (!netdev_hw_addr_list_empty(curr_addr_list)) {
+		struct netdev_hw_addr *ha;
+		u8 *del_addrlist;
+		int del_addr_count = 0;
+
+		alen = ETH_ALEN * netdev_hw_addr_list_count(curr_addr_list);
+		del_addrlist = kmalloc(alen, GFP_KERNEL);
+		if (!del_addrlist) {
+			err = -ENOMEM;
+			goto err_out;
+		}
+
+		/*
+		 *	Get the addresses that need to be deleted
+		 */
+		netdev_hw_addr_list_for_each(ha, curr_addr_list) {
+			if (!macvlan_addr_in_attrs(new_addr_attrs, ha->addr,
+				ETH_ALEN))
+				memcpy(del_addrlist + (del_addr_count++ *
+					ETH_ALEN), ha->addr, ETH_ALEN);
+		}
+
+		/*
+		 * Delete addresses
+		 */
+		for (i = 0, addr = del_addrlist; i < del_addr_count && addr;
+			i++, addr += ETH_ALEN) {
+			if (addr_list_type == NETDEV_HW_ADDR_T_UNICAST)
+				dev_uc_del(dev, addr);
+			else if (addr_list_type == NETDEV_HW_ADDR_T_MULTICAST)
+				dev_mc_del(dev, addr);
+		}
+		kfree(del_addrlist);
+	}
+
+	/* Add new addresses */
+	nla_for_each_nested(addr_attr, new_addr_attrs, addr_rem) {
+		if (!macvlan_addr_in_hw_list(curr_addr_list,
+			nla_data(addr_attr), ETH_ALEN)) {
+			if (addr_list_type == NETDEV_HW_ADDR_T_UNICAST)
+				dev_uc_add(dev, nla_data(addr_attr));
+			else if (addr_list_type == NETDEV_HW_ADDR_T_MULTICAST)
+				dev_mc_add(dev, nla_data(addr_attr));
+		}
+	}
+
+	return 0;
+
+err_out:
+	return err;
+}
+
+static int macvlan_set_rx_filter_addr_passthru(struct net_device *dev,
+					       int vf, struct nlattr *tb[])
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+	const struct net_device_ops *ops = lowerdev->netdev_ops;
+	unsigned int flags, flags_changed;
+	int err;
+
+	if (ops->ndo_set_rx_filter_addr)
+		return ops->ndo_set_rx_filter_addr(vlan->lowerdev, vf, tb);
+
+	if (tb[IFLA_RX_FILTER_ADDR_FLAGS]) {
+		flags = nla_get_u32(tb[IFLA_RX_FILTER_ADDR_FLAGS]);
+
+		flags_changed = (dev->flags ^ flags) & RX_FILTER_FLAGS;
+		if (flags_changed)
+			dev_change_flags(dev, dev->flags ^ flags_changed);
+	}
+
+	if (tb[IFLA_RX_FILTER_ADDR_UC_LIST]) {
+		err = macvlan_update_hw_addr_list(dev, &dev->uc,
+				NETDEV_HW_ADDR_T_UNICAST,
+				tb[IFLA_RX_FILTER_ADDR_UC_LIST]);
+		if (err)
+			return err;
+	}
+
+	if (tb[IFLA_RX_FILTER_ADDR_MC_LIST]) {
+		err = macvlan_update_hw_addr_list(dev, &dev->mc,
+				NETDEV_HW_ADDR_T_MULTICAST,
+				tb[IFLA_RX_FILTER_ADDR_MC_LIST]);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int macvlan_validate_rx_filter_addr(struct net_device *dev, int vf,
+					   struct nlattr *tb[])
+{
+	struct nlattr *addr_attr;
+	int addr_rem;
+
+	if (vf != SELF_VF)
+		return -EINVAL;
+
+	if (tb[IFLA_RX_FILTER_ADDR_UC_LIST]) {
+		nla_for_each_nested(addr_attr, tb[IFLA_RX_FILTER_ADDR_UC_LIST],
+				    addr_rem) {
+			if ((nla_type(addr_attr) != IFLA_ADDR_LIST_ENTRY) ||
+				!is_unicast_ether_addr(nla_data(addr_attr)))
+				return -EINVAL;
+		}
+	}
+
+	if (tb[IFLA_RX_FILTER_ADDR_MC_LIST]) {
+		nla_for_each_nested(addr_attr, tb[IFLA_RX_FILTER_ADDR_MC_LIST],
+				    addr_rem) {
+			if ((nla_type(addr_attr) != IFLA_ADDR_LIST_ENTRY) ||
+				!is_multicast_ether_addr(nla_data(addr_attr)))
+				return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+static int macvlan_set_rx_filter_addr(struct net_device *dev, int vf,
+				      struct nlattr *tb[])
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	int err;
+
+	err = macvlan_validate_rx_filter_addr(dev, vf, tb);
+	if (err)
+		return err;
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		return macvlan_set_rx_filter_addr_passthru(dev, vf, tb);
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
 static void macvlan_ethtool_get_drvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *drvinfo)
 {
@@ -564,19 +824,21 @@ static const struct ethtool_ops macvlan_ethtool_ops = {
 };
 
 static const struct net_device_ops macvlan_netdev_ops = {
-	.ndo_init		= macvlan_init,
-	.ndo_uninit		= macvlan_uninit,
-	.ndo_open		= macvlan_open,
-	.ndo_stop		= macvlan_stop,
-	.ndo_start_xmit		= macvlan_start_xmit,
-	.ndo_change_mtu		= macvlan_change_mtu,
-	.ndo_change_rx_flags	= macvlan_change_rx_flags,
-	.ndo_set_mac_address	= macvlan_set_mac_address,
-	.ndo_set_rx_mode	= macvlan_set_multicast_list,
-	.ndo_get_stats64	= macvlan_dev_get_stats64,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_vlan_rx_add_vid	= macvlan_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid	= macvlan_vlan_rx_kill_vid,
+	.ndo_init			= macvlan_init,
+	.ndo_uninit			= macvlan_uninit,
+	.ndo_open			= macvlan_open,
+	.ndo_stop			= macvlan_stop,
+	.ndo_start_xmit			= macvlan_start_xmit,
+	.ndo_change_mtu			= macvlan_change_mtu,
+	.ndo_change_rx_flags		= macvlan_change_rx_flags,
+	.ndo_set_mac_address		= macvlan_set_mac_address,
+	.ndo_set_rx_mode		= macvlan_set_rx_mode,
+	.ndo_get_stats64		= macvlan_dev_get_stats64,
+	.ndo_validate_addr		= eth_validate_addr,
+	.ndo_vlan_rx_add_vid		= macvlan_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid		= macvlan_vlan_rx_kill_vid,
+	.ndo_set_rx_filter_addr		= macvlan_set_rx_filter_addr,
+	.ndo_set_rx_filter_vlan		= macvlan_set_rx_filter_vlan,
 };
 
 void macvlan_common_setup(struct net_device *dev)
@@ -584,6 +846,7 @@ void macvlan_common_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->priv_flags	       &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
+	dev->priv_flags	       |= IFF_UNICAST_FLT;
 	dev->netdev_ops		= &macvlan_netdev_ops;
 	dev->destructor		= free_netdev;
 	dev->header_ops		= &macvlan_hard_header_ops,
@@ -711,6 +974,8 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	if (data && data[IFLA_MACVLAN_MODE])
 		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
 
+	memset(vlan->vlan_filter, 0, VLAN_BITMAP_SIZE);
+
 	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
 		if (port->count)
 			return -EINVAL;
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index d103dca..c0d84a5 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -7,6 +7,7 @@
 #include <linux/netlink.h>
 #include <net/netlink.h>
 #include <linux/u64_stats_sync.h>
+#include <linux/if_vlan.h>
 
 #if defined(CONFIG_MACVTAP) || defined(CONFIG_MACVTAP_MODULE)
 struct socket *macvtap_get_socket(struct file *);
@@ -65,6 +66,7 @@ struct macvlan_dev {
 	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
 	int			numvtaps;
 	int			minor;
+	unsigned long		vlan_filter[BITS_TO_LONGS(VLAN_N_VID)];
 };
 
 static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
