From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 6/6 RFC v3] macvlan: Add support to get MAC/VLAN
	filter netdev ops
Date: Fri, 28 Oct 2011 19:34:35 -0700
Message-ID: <20111029023435.5198.78831.stgit@rhel6.1>
References: <20111029023159.5198.60245.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dragos.tatulea@gmail.com, kvm@vger.kernel.org,
	arnd@arndb.de, mst@redhat.com, davem@davemloft.net,
	gregory.v.rose@intel.com, mchan@broadcom.com, dwang2@cisco.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com, kaber@trash.net,
	benve@cisco.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-4.cisco.com ([173.36.130.15]:47426 "EHLO
	mtv-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932187Ab1J1Sh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 14:37:27 -0400
In-Reply-To: <20111029023159.5198.60245.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support to get MAC and VLAN filter netdev ops
on a macvlan interface. It adds support for get_rx_filter_addr_size,
get_rx_filter_vlan_size, fill_rx_filter_addr and fill_rx_filter_vlan
netdev ops

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/macvlan.c |  158 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 158 insertions(+), 0 deletions(-)


diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9d8cbe3..15dd7de 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -616,6 +616,55 @@ static int macvlan_set_rx_filter_vlan(struct net_device *dev, int vf,
 	return 0;
 }
 
+static size_t macvlan_get_rx_filter_vlan_size(const struct net_device *dev,
+					      int vf)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+	const struct net_device_ops *ops = lowerdev->netdev_ops;
+
+	if (vf != SELF_VF)
+		return -EINVAL;
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		if (ops->ndo_get_rx_filter_vlan_size)
+			return ops->ndo_get_rx_filter_vlan_size(dev, vf);
+		/* IFLA_RX_FILTER_VLAN_BITMAP */
+		return nla_total_size(VLAN_BITMAP_SIZE);
+	default:
+		return 0;
+	}
+}
+
+static int macvlan_get_rx_filter_vlan(const struct net_device *dev, int vf,
+				      struct sk_buff *skb)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+	const struct net_device_ops *ops = lowerdev->netdev_ops;
+
+	if (vf != SELF_VF)
+		return -EINVAL;
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		if (ops->ndo_get_rx_filter_vlan)
+			return ops->ndo_get_rx_filter_vlan(dev, vf, skb);
+
+		NLA_PUT(skb, IFLA_RX_FILTER_VLAN_BITMAP, VLAN_BITMAP_SIZE,
+			vlan->vlan_filter);
+		break;
+	default:
+		return -ENODATA; /* No data to Fill */
+	}
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
 static int macvlan_addr_in_hw_list(struct netdev_hw_addr_list *list,
 				   u8 *addr, int addrlen)
 {
@@ -795,6 +844,111 @@ static int macvlan_set_rx_filter_addr(struct net_device *dev, int vf,
 	return 0;
 }
 
+static size_t macvlan_get_rx_filter_addr_passthru_size(
+			const struct net_device *dev, int vf)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+	const struct net_device_ops *ops = lowerdev->netdev_ops;
+	size_t size;
+
+	if (ops->ndo_get_rx_filter_addr_size)
+		return ops->ndo_get_rx_filter_addr_size(dev, vf);
+
+	/* IFLA_RX_FILTER_ADDR_FLAGS */
+	size = nla_total_size(sizeof(u32));
+
+	if (netdev_uc_count(dev))
+		/* IFLA_RX_FILTER_ADDR_UC_LIST */
+		size += nla_total_size(netdev_uc_count(dev) *
+				       ETH_ALEN * sizeof(struct nlattr));
+
+	if (netdev_mc_count(dev))
+		/* IFLA_RX_FILTER_ADDR_MC_LIST */
+		size += nla_total_size(netdev_mc_count(dev) *
+				       ETH_ALEN * sizeof(struct nlattr));
+
+	return size;
+}
+
+static size_t macvlan_get_rx_filter_addr_size(const struct net_device *dev,
+					      int vf)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	if (vf != SELF_VF)
+		return -EINVAL;
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		return macvlan_get_rx_filter_addr_passthru_size(dev, vf);
+	default:
+		return 0;
+	}
+}
+
+static int macvlan_get_rx_filter_addr_passthru(const struct net_device *dev,
+					       int vf, struct sk_buff *skb)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+	const struct net_device_ops *ops = lowerdev->netdev_ops;
+	struct nlattr *uninitialized_var(uc_list), *mc_list;
+	struct netdev_hw_addr *ha;
+
+	if (ops->ndo_get_rx_filter_addr)
+		return ops->ndo_get_rx_filter_addr(dev, vf, skb);
+
+	NLA_PUT_U32(skb, IFLA_RX_FILTER_ADDR_FLAGS,
+		dev->flags & RX_FILTER_FLAGS);
+
+	if (netdev_uc_count(dev)) {
+		uc_list = nla_nest_start(skb, IFLA_RX_FILTER_ADDR_UC_LIST);
+		if (uc_list == NULL)
+			goto nla_put_failure;
+
+		netdev_for_each_uc_addr(ha, dev) {
+			NLA_PUT(skb, IFLA_ADDR_LIST_ENTRY, ETH_ALEN, ha->addr);
+		}
+		nla_nest_end(skb, uc_list);
+	}
+
+	if (netdev_mc_count(dev)) {
+		mc_list = nla_nest_start(skb, IFLA_RX_FILTER_ADDR_MC_LIST);
+		if (mc_list == NULL)
+			goto nla_uc_list_cancel;
+
+		netdev_for_each_mc_addr(ha, dev) {
+			NLA_PUT(skb, IFLA_ADDR_LIST_ENTRY, ETH_ALEN, ha->addr);
+		}
+		nla_nest_end(skb, mc_list);
+	}
+
+	return 0;
+
+nla_uc_list_cancel:
+	if (netdev_uc_count(dev))
+		nla_nest_cancel(skb, uc_list);
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int macvlan_get_rx_filter_addr(const struct net_device *dev, int vf,
+				      struct sk_buff *skb)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	if (vf != SELF_VF)
+		return -EINVAL;
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		return macvlan_get_rx_filter_addr_passthru(dev, vf, skb);
+	default:
+		return -ENODATA; /* No data to Fill */
+	}
+}
+
 static void macvlan_ethtool_get_drvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *drvinfo)
 {
@@ -831,7 +985,11 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_vlan_rx_add_vid		= macvlan_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid		= macvlan_vlan_rx_kill_vid,
 	.ndo_set_rx_filter_addr		= macvlan_set_rx_filter_addr,
+	.ndo_get_rx_filter_addr_size	= macvlan_get_rx_filter_addr_size,
+	.ndo_get_rx_filter_addr		= macvlan_get_rx_filter_addr,
 	.ndo_set_rx_filter_vlan		= macvlan_set_rx_filter_vlan,
+	.ndo_get_rx_filter_vlan_size	= macvlan_get_rx_filter_vlan_size,
+	.ndo_get_rx_filter_vlan		= macvlan_get_rx_filter_vlan,
 };
 
 void macvlan_common_setup(struct net_device *dev)
