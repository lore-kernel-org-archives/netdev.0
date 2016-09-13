From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next 2/3] net: ethernet: mediatek: add ethtool functions to configure RX flows of HW LRO
Date: Tue, 13 Sep 2016 21:54:25 +0800
Message-ID: <1473774866-3156-3-git-send-email-nelson.chang@mediatek.com>
References: <1473774866-3156-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:8026 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751488AbcIMNyj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 09:54:39 -0400
In-Reply-To: <1473774866-3156-1-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The codes add ethtool functions to set RX flows for HW LRO. Because the
HW LRO hardware can only recognize the destination IP of TCP/IP RX flows,
the ethtool command to add HW LRO flow is as below:
ethtool -N [devname] flow-type tcp4 dst-ip [ip_addr] loc [0~1]

Otherwise, cause the hardware can set total four destination IPs, each
GMAC (GMAC1/GMAC2) can set two IPs separately at most.

Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 218 ++++++++++++++++++++++++++++
 1 file changed, 218 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index ed35e0f..8245841 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1344,6 +1344,165 @@ static void mtk_hwlro_rx_uninit(struct mtk_eth *eth)
 	mtk_w32(eth, 0, MTK_PDMA_LRO_CTRL_DW0);
 }
 
+static void mtk_hwlro_val_ipaddr(struct mtk_eth *eth, int idx, __be32 ip)
+{
+	u32 reg_val;
+
+	reg_val = mtk_r32(eth, MTK_LRO_CTRL_DW2_CFG(idx));
+
+	/* invalidate the IP setting */
+	mtk_w32(eth, (reg_val & ~MTK_RING_MYIP_VLD), MTK_LRO_CTRL_DW2_CFG(idx));
+
+	mtk_w32(eth, ip, MTK_LRO_DIP_DW0_CFG(idx));
+
+	/* validate the IP setting */
+	mtk_w32(eth, (reg_val | MTK_RING_MYIP_VLD), MTK_LRO_CTRL_DW2_CFG(idx));
+}
+
+static void mtk_hwlro_inval_ipaddr(struct mtk_eth *eth, int idx)
+{
+	u32 reg_val;
+
+	reg_val = mtk_r32(eth, MTK_LRO_CTRL_DW2_CFG(idx));
+
+	/* invalidate the IP setting */
+	mtk_w32(eth, (reg_val & ~MTK_RING_MYIP_VLD), MTK_LRO_CTRL_DW2_CFG(idx));
+
+	mtk_w32(eth, 0, MTK_LRO_DIP_DW0_CFG(idx));
+}
+
+static int mtk_hwlro_get_ip_cnt(struct mtk_mac *mac)
+{
+	int cnt = 0;
+	int i;
+
+	for (i = 0; i < MTK_MAX_LRO_IP_CNT; i++) {
+		if (mac->hwlro_ip[i])
+			cnt++;
+	}
+
+	return cnt;
+}
+
+static int mtk_hwlro_add_ipaddr(struct net_device *dev,
+				struct ethtool_rxnfc *cmd)
+{
+	struct ethtool_rx_flow_spec *fsp =
+		(struct ethtool_rx_flow_spec *)&cmd->fs;
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	int hwlro_idx;
+
+	if ((fsp->flow_type != TCP_V4_FLOW) ||
+	    (!fsp->h_u.tcp_ip4_spec.ip4dst) ||
+	    (fsp->location > 1))
+		return -EINVAL;
+
+	mac->hwlro_ip[fsp->location] = htonl(fsp->h_u.tcp_ip4_spec.ip4dst);
+	hwlro_idx = (mac->id * MTK_MAX_LRO_IP_CNT) + fsp->location;
+
+	mac->hwlro_ip_cnt = mtk_hwlro_get_ip_cnt(mac);
+
+	mtk_hwlro_val_ipaddr(eth, hwlro_idx, mac->hwlro_ip[fsp->location]);
+
+	return 0;
+}
+
+static int mtk_hwlro_del_ipaddr(struct net_device *dev,
+				struct ethtool_rxnfc *cmd)
+{
+	struct ethtool_rx_flow_spec *fsp =
+		(struct ethtool_rx_flow_spec *)&cmd->fs;
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	int hwlro_idx;
+
+	if (fsp->location > 1)
+		return -EINVAL;
+
+	mac->hwlro_ip[fsp->location] = 0;
+	hwlro_idx = (mac->id * MTK_MAX_LRO_IP_CNT) + fsp->location;
+
+	mac->hwlro_ip_cnt = mtk_hwlro_get_ip_cnt(mac);
+
+	mtk_hwlro_inval_ipaddr(eth, hwlro_idx);
+
+	return 0;
+}
+
+static void mtk_hwlro_netdev_disable(struct net_device *dev)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	int i, hwlro_idx;
+
+	for (i = 0; i < MTK_MAX_LRO_IP_CNT; i++) {
+		mac->hwlro_ip[i] = 0;
+		hwlro_idx = (mac->id * MTK_MAX_LRO_IP_CNT) + i;
+
+		mtk_hwlro_inval_ipaddr(eth, hwlro_idx);
+	}
+
+	mac->hwlro_ip_cnt = 0;
+}
+
+static int mtk_hwlro_get_fdir_entry(struct net_device *dev,
+				    struct ethtool_rxnfc *cmd)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct ethtool_rx_flow_spec *fsp =
+		(struct ethtool_rx_flow_spec *)&cmd->fs;
+
+	/* only tcp dst ipv4 is meaningful, others are meaningless */
+	fsp->flow_type = TCP_V4_FLOW;
+	fsp->h_u.tcp_ip4_spec.ip4dst = ntohl(mac->hwlro_ip[fsp->location]);
+	fsp->m_u.tcp_ip4_spec.ip4dst = 0;
+
+	fsp->h_u.tcp_ip4_spec.ip4src = 0;
+	fsp->m_u.tcp_ip4_spec.ip4src = 0xffffffff;
+	fsp->h_u.tcp_ip4_spec.psrc = 0;
+	fsp->m_u.tcp_ip4_spec.psrc = 0xffff;
+	fsp->h_u.tcp_ip4_spec.pdst = 0;
+	fsp->m_u.tcp_ip4_spec.pdst = 0xffff;
+	fsp->h_u.tcp_ip4_spec.tos = 0;
+	fsp->m_u.tcp_ip4_spec.tos = 0xff;
+
+	return 0;
+}
+
+static int mtk_hwlro_get_fdir_all(struct net_device *dev,
+				  struct ethtool_rxnfc *cmd,
+				  u32 *rule_locs)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	int cnt = 0;
+	int i;
+
+	for (i = 0; i < MTK_MAX_LRO_IP_CNT; i++) {
+		if (mac->hwlro_ip[i]) {
+			rule_locs[cnt] = i;
+			cnt++;
+		}
+	}
+
+	cmd->rule_cnt = cnt;
+
+	return 0;
+}
+
+static int mtk_set_features(struct net_device *dev, netdev_features_t features)
+{
+	int err = 0;
+
+	if (!((dev->features ^ features) & NETIF_F_LRO))
+		return 0;
+
+	if (!(features & NETIF_F_LRO))
+		mtk_hwlro_netdev_disable(dev);
+
+	return err;
+}
+
 /* wait for DMA to finish whatever it is doing before we start using it again */
 static int mtk_dma_busy_wait(struct mtk_eth *eth)
 {
@@ -1863,6 +2022,62 @@ static void mtk_get_ethtool_stats(struct net_device *dev,
 	} while (u64_stats_fetch_retry_irq(&hwstats->syncp, start));
 }
 
+static int mtk_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
+			 u32 *rule_locs)
+{
+	int ret = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXRINGS:
+		if (dev->features & NETIF_F_LRO) {
+			cmd->data = MTK_MAX_RX_RING_NUM;
+			ret = 0;
+		}
+		break;
+	case ETHTOOL_GRXCLSRLCNT:
+		if (dev->features & NETIF_F_LRO) {
+			struct mtk_mac *mac = netdev_priv(dev);
+
+			cmd->rule_cnt = mac->hwlro_ip_cnt;
+			ret = 0;
+		}
+		break;
+	case ETHTOOL_GRXCLSRULE:
+		if (dev->features & NETIF_F_LRO)
+			ret = mtk_hwlro_get_fdir_entry(dev, cmd);
+		break;
+	case ETHTOOL_GRXCLSRLALL:
+		if (dev->features & NETIF_F_LRO)
+			ret = mtk_hwlro_get_fdir_all(dev, cmd,
+						     rule_locs);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+static int mtk_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
+{
+	int ret = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_SRXCLSRLINS:
+		if (dev->features & NETIF_F_LRO)
+			ret = mtk_hwlro_add_ipaddr(dev, cmd);
+		break;
+	case ETHTOOL_SRXCLSRLDEL:
+		if (dev->features & NETIF_F_LRO)
+			ret = mtk_hwlro_del_ipaddr(dev, cmd);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
 static const struct ethtool_ops mtk_ethtool_ops = {
 	.get_settings		= mtk_get_settings,
 	.set_settings		= mtk_set_settings,
@@ -1874,6 +2089,8 @@ static const struct ethtool_ops mtk_ethtool_ops = {
 	.get_strings		= mtk_get_strings,
 	.get_sset_count		= mtk_get_sset_count,
 	.get_ethtool_stats	= mtk_get_ethtool_stats,
+	.get_rxnfc		= mtk_get_rxnfc,
+	.set_rxnfc              = mtk_set_rxnfc,
 };
 
 static const struct net_device_ops mtk_netdev_ops = {
@@ -1888,6 +2105,7 @@ static const struct net_device_ops mtk_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_tx_timeout		= mtk_tx_timeout,
 	.ndo_get_stats64        = mtk_get_stats64,
+	.ndo_set_features	= mtk_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= mtk_poll_controller,
 #endif
-- 
1.9.1
