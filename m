From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 6/8 RFC v2] macvlan: Add support to get MAC/VLAN
	filter rtnl link operations
Date: Tue, 18 Oct 2011 23:26:25 -0700
Message-ID: <20111019062625.7242.72184.stgit@savbu-pc100.cisco.com>
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
	with ESMTP id S1751469Ab1JSG00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 02:26:26 -0400
In-Reply-To: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support to get MAC and VLAN filter rtnl_link_ops
on a macvlan interface. It adds support for get_rx_addr_filter_size,
get_rx_vlan_filter_size, fill_rx_addr_filter and fill_rx_vlan_filter
rtnl link operations.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/macvlan.c      |  126 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_macvlan.h |   10 +++
 2 files changed, 136 insertions(+), 0 deletions(-)


diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index dbb2e30..23636e6 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1014,6 +1014,128 @@ int macvlan_set_rx_addr_filter(struct net_device *dev,
 }
 EXPORT_SYMBOL(macvlan_set_rx_addr_filter);
 
+static size_t macvlan_get_rx_addr_filter_passthru_size(
+				const struct net_device *dev)
+{
+	size_t size;
+
+	/* IFLA_ADDR_FILTER_FLAGS */
+	size = nla_total_size(sizeof(u32));
+
+	if (netdev_uc_count(dev))
+		/* IFLA_ADDR_FILTER_UC_LIST */
+		size += nla_total_size(netdev_uc_count(dev) *
+				       ETH_ALEN * sizeof(struct nlattr));
+
+	if (netdev_mc_count(dev))
+		/* IFLA_ADDR_FILTER_MC_LIST */
+		size += nla_total_size(netdev_mc_count(dev) *
+				       ETH_ALEN * sizeof(struct nlattr));
+
+	return size;
+}
+
+size_t macvlan_get_rx_addr_filter_size(const struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		return macvlan_get_rx_addr_filter_passthru_size(dev);
+	default:
+		return 0;
+	}
+}
+EXPORT_SYMBOL(macvlan_get_rx_addr_filter_size);
+
+size_t macvlan_get_rx_vlan_filter_size(const struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		/* IFLA_VLAN_BITMAP */
+		return nla_total_size(VLAN_BITMAP_SIZE);
+	default:
+		return 0;
+	}
+}
+EXPORT_SYMBOL(macvlan_get_rx_vlan_filter_size);
+
+static int macvlan_fill_rx_addr_filter_passthru(struct sk_buff *skb,
+						const struct net_device *dev)
+{
+	struct nlattr *uninitialized_var(uc_list), *mc_list;
+	struct netdev_hw_addr *ha;
+
+	NLA_PUT_U32(skb, IFLA_ADDR_FILTER_FLAGS, dev->flags & RX_FILTER_FLAGS);
+
+	if (netdev_uc_count(dev)) {
+		uc_list = nla_nest_start(skb, IFLA_ADDR_FILTER_UC_LIST);
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
+		mc_list = nla_nest_start(skb, IFLA_ADDR_FILTER_MC_LIST);
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
+int macvlan_fill_rx_addr_filter(struct sk_buff *skb,
+				const struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		return macvlan_fill_rx_addr_filter_passthru(skb, dev);
+	default:
+		return -ENODATA; /* No data to Fill */
+	}
+}
+EXPORT_SYMBOL(macvlan_fill_rx_addr_filter);
+
+int macvlan_fill_rx_vlan_filter(struct sk_buff *skb,
+				const struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	switch (vlan->mode) {
+	case MACVLAN_MODE_PASSTHRU:
+		NLA_PUT(skb, IFLA_VLAN_BITMAP, VLAN_BITMAP_SIZE,
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
+EXPORT_SYMBOL(macvlan_fill_rx_vlan_filter);
+
 static const struct nla_policy macvlan_policy[IFLA_MACVLAN_MAX + 1] = {
 	[IFLA_MACVLAN_MODE] = { .type = NLA_U32 },
 };
@@ -1040,6 +1162,10 @@ static struct rtnl_link_ops macvlan_link_ops = {
 	.dellink			= macvlan_dellink,
 	.set_rx_addr_filter		= macvlan_set_rx_addr_filter,
 	.set_rx_vlan_filter		= macvlan_set_rx_vlan_filter,
+	.get_rx_addr_filter_size	= macvlan_get_rx_addr_filter_size,
+	.get_rx_vlan_filter_size	= macvlan_get_rx_vlan_filter_size,
+	.fill_rx_addr_filter		= macvlan_fill_rx_addr_filter,
+	.fill_rx_vlan_filter		= macvlan_fill_rx_vlan_filter,
 };
 
 static int macvlan_device_event(struct notifier_block *unused,
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index d203293..700db8b 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -112,4 +112,14 @@ extern int macvlan_set_rx_addr_filter(struct net_device *dev,
 extern int macvlan_set_rx_vlan_filter(struct net_device *dev,
 				      struct nlattr *tb[]);
 
+extern int macvlan_fill_rx_addr_filter(struct sk_buff *skb,
+				       const struct net_device *dev);
+
+extern int macvlan_fill_rx_vlan_filter(struct sk_buff *skb,
+				       const struct net_device *dev);
+
+extern size_t macvlan_get_rx_addr_filter_size(const struct net_device *dev);
+
+extern size_t macvlan_get_rx_vlan_filter_size(const struct net_device *dev);
+
 #endif /* _LINUX_IF_MACVLAN_H */
