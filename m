From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 5/8 RFC v2] macvlan: Add support to set MAC/VLAN
	filter rtnl link operations
Date: Tue, 18 Oct 2011 23:26:20 -0700
Message-ID: <20111019062620.7242.88569.stgit@savbu-pc100.cisco.com>
References: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dragos.tatulea@gmail.com, arnd@arndb.de,
	kvm@vger.kernel.org, mst@redhat.com, davem@davemloft.net,
	mchan@broadcom.com, dwang2@cisco.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com, kaber@trash.net, benve@cisco.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-2.cisco.com ([173.36.130.13]:44420 "EHLO
	mtv-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469Ab1JSG0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 02:26:21 -0400
In-Reply-To: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support to set MAC and VLAN filter rtnl_link_ops
on a macvlan interface. It adds support for set_rx_addr_filter and
set_rx_vlan_filter rtnl link operations. It currently supports
only macvlan PASSTHRU mode.

For passthru mode,
	 - Address filters: macvlan netdev uc and mc lists are
	updated to reflect the addresses in the filter.

	- VLAN filter: Currently applied vlan bitmap is maintained in
	struct macvlan_dev->vlan_filter. This vlan bitmap is updated to
	reflect the new bitmap that came in the netlink msg.
	lowerdev hw vlan filter is updated using macvlan netdev operations
	ndo_vlan_rx_add_vid and ndo_vlan_rx_kill_vid (which inturn call
	lowerdev vlan add/kill netdev ops)

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/macvlan.c      |  296 ++++++++++++++++++++++++++++++++++++++++----
 include/linux/if_macvlan.h |    8 +
 2 files changed, 279 insertions(+), 25 deletions(-)


diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 24cf942..dbb2e30 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -299,30 +299,36 @@ static int macvlan_open(struct net_device *dev)
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
+	if (dev->flags & IFF_PROMISC) {
+		err = dev_set_promiscuity(lowerdev, 1);
+		if (err < 0)
+			goto unset_allmulti;
+	}
 
-hash_add:
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
@@ -332,18 +338,16 @@ static int macvlan_stop(struct net_device *dev)
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
@@ -384,12 +388,16 @@ static void macvlan_change_rx_flags(struct net_device *dev, int change)
 
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
 
@@ -562,7 +570,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_change_mtu		= macvlan_change_mtu,
 	.ndo_change_rx_flags	= macvlan_change_rx_flags,
 	.ndo_set_mac_address	= macvlan_set_mac_address,
-	.ndo_set_rx_mode	= macvlan_set_multicast_list,
+	.ndo_set_rx_mode	= macvlan_set_rx_mode,
 	.ndo_get_stats64	= macvlan_dev_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_vlan_rx_add_vid	= macvlan_vlan_rx_add_vid,
@@ -574,6 +582,7 @@ void macvlan_common_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->priv_flags	       &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
+	dev->priv_flags	       |= IFF_UNICAST_FLT;
 	dev->netdev_ops		= &macvlan_netdev_ops;
 	dev->destructor		= free_netdev;
 	dev->header_ops		= &macvlan_hard_header_ops,
@@ -701,6 +710,8 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	if (data && data[IFLA_MACVLAN_MODE])
 		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
 
+	memset(vlan->vlan_filter, 0, VLAN_BITMAP_SIZE);
+
 	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
 		if (port->count)
 			return -EINVAL;
@@ -770,6 +781,239 @@ nla_put_failure:
 	return -EMSGSIZE;
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
+static int macvlan_set_rx_vlan_filter_passthru(struct net_device *dev,
+					       unsigned long *vlans)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	u16 vid;
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
+int macvlan_set_rx_vlan_filter(struct net_device *dev,
+	struct nlattr *tb[])
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	int err;
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		if (tb[IFLA_VLAN_BITMAP])
+			return macvlan_set_rx_vlan_filter_passthru(dev,
+					nla_data(tb[IFLA_VLAN_BITMAP]));
+		break;
+	default:
+		err = -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(macvlan_set_rx_vlan_filter);
+
+static int macvlan_addr_in_hw_list(struct netdev_hw_addr_list *list,
+	u8 *addr, int addrlen)
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
+	int addrlen)
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
+	struct netdev_hw_addr_list *curr_addr_list, int addr_list_type,
+	struct nlattr *new_addr_attrs)
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
+static int macvlan_set_rx_addr_filter_passthru(struct net_device *dev,
+	struct nlattr *filter_flags, struct nlattr *uc_list,
+	struct nlattr *mc_list)
+{
+	unsigned int flags, flags_changed;
+	int err;
+
+	if (filter_flags) {
+		flags = nla_get_u32(filter_flags);
+
+		flags_changed = (dev->flags ^ flags) & RX_FILTER_FLAGS;
+		if (flags_changed)
+			dev_change_flags(dev, dev->flags ^ flags_changed);
+	}
+
+	if (uc_list) {
+		err = macvlan_update_hw_addr_list(dev, &dev->uc,
+					NETDEV_HW_ADDR_T_UNICAST, uc_list);
+		if (err)
+			return err;
+	}
+
+	if (mc_list) {
+		err = macvlan_update_hw_addr_list(dev, &dev->mc,
+					NETDEV_HW_ADDR_T_MULTICAST, mc_list);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int macvlan_validate_rx_addr_filter(struct net_device *dev,
+	struct nlattr *tb[])
+{
+	struct nlattr *addr_attr;
+	int addr_rem;
+
+	if (tb[IFLA_ADDR_FILTER_UC_LIST]) {
+		nla_for_each_nested(addr_attr, tb[IFLA_ADDR_FILTER_UC_LIST],
+				    addr_rem) {
+			if ((nla_type(addr_attr) != IFLA_ADDR_LIST_ENTRY) ||
+				!is_unicast_ether_addr(nla_data(addr_attr)))
+				return -EINVAL;
+		}
+	}
+
+	if (tb[IFLA_ADDR_FILTER_MC_LIST]) {
+		nla_for_each_nested(addr_attr, tb[IFLA_ADDR_FILTER_MC_LIST],
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
+int macvlan_set_rx_addr_filter(struct net_device *dev,
+	struct nlattr *tb[])
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	int err;
+
+	err = macvlan_validate_rx_addr_filter(dev, tb);
+	if (err)
+		return err;
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		return macvlan_set_rx_addr_filter_passthru(dev,
+			tb[IFLA_ADDR_FILTER_FLAGS],
+			tb[IFLA_ADDR_FILTER_UC_LIST],
+			tb[IFLA_ADDR_FILTER_MC_LIST]);
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(macvlan_set_rx_addr_filter);
+
 static const struct nla_policy macvlan_policy[IFLA_MACVLAN_MAX + 1] = {
 	[IFLA_MACVLAN_MODE] = { .type = NLA_U32 },
 };
@@ -790,10 +1034,12 @@ int macvlan_link_register(struct rtnl_link_ops *ops)
 EXPORT_SYMBOL_GPL(macvlan_link_register);
 
 static struct rtnl_link_ops macvlan_link_ops = {
-	.kind		= "macvlan",
-	.setup		= macvlan_setup,
-	.newlink	= macvlan_newlink,
-	.dellink	= macvlan_dellink,
+	.kind				= "macvlan",
+	.setup				= macvlan_setup,
+	.newlink			= macvlan_newlink,
+	.dellink			= macvlan_dellink,
+	.set_rx_addr_filter		= macvlan_set_rx_addr_filter,
+	.set_rx_vlan_filter		= macvlan_set_rx_vlan_filter,
 };
 
 static int macvlan_device_event(struct notifier_block *unused,
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index e28b2e4..d203293 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -7,6 +7,7 @@
 #include <linux/netlink.h>
 #include <net/netlink.h>
 #include <linux/u64_stats_sync.h>
+#include <linux/if_vlan.h>
 
 #if defined(CONFIG_MACVTAP) || defined(CONFIG_MACVTAP_MODULE)
 struct socket *macvtap_get_socket(struct file *);
@@ -64,6 +65,7 @@ struct macvlan_dev {
 	int (*forward)(struct net_device *dev, struct sk_buff *skb);
 	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
 	int			numvtaps;
+	unsigned long		vlan_filter[BITS_TO_LONGS(VLAN_N_VID)];
 };
 
 static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
@@ -104,4 +106,10 @@ extern int macvlan_link_register(struct rtnl_link_ops *ops);
 extern netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev);
 
+extern int macvlan_set_rx_addr_filter(struct net_device *dev,
+				      struct nlattr *tb[]);
+
+extern int macvlan_set_rx_vlan_filter(struct net_device *dev,
+				      struct nlattr *tb[]);
+
 #endif /* _LINUX_IF_MACVLAN_H */
