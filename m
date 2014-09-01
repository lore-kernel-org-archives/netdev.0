From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/2] stmmac: fix the rx csum feature
Date: Mon, 1 Sep 2014 09:17:52 +0200
Message-ID: <1409555873-5478-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:51094 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752730AbaIAHSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 03:18:03 -0400
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s817D2hn004537
	for <netdev@vger.kernel.org>; Mon, 1 Sep 2014 09:18:00 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1p4dthhh52-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 01 Sep 2014 09:18:00 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id EC4F031
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 07:17:47 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 097372CA0C
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 07:17:58 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For new GMACs it is possible to turn-on/off the COE.
In the current driver, when disabled the Rx-checksum
via ethtool, the tool reported that csum was disabled
but the HW continued to set the IPC. Indeed this is
because the fix_features allows this. So the patch
fixes this problem by adding the set_features.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    1 +
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |    6 +++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   27 ++++++++++++++++++-
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index bd54238..a2aba1f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -445,6 +445,7 @@ struct mac_device_info {
 	int multicast_filter_bins;
 	int unicast_filter_entries;
 	int mcast_bits_log2;
+	unsigned int rx_csum;
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index d8ef187..5efe60e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -58,7 +58,11 @@ static int dwmac1000_rx_ipc_enable(struct mac_device_info *hw)
 	void __iomem *ioaddr = hw->pcsr;
 	u32 value = readl(ioaddr + GMAC_CONTROL);
 
-	value |= GMAC_CONTROL_IPC;
+	if (hw->rx_csum)
+		value |= GMAC_CONTROL_IPC;
+	else
+		value &= ~GMAC_CONTROL_IPC;
+
 	writel(value, ioaddr + GMAC_CONTROL);
 
 	value = readl(ioaddr + GMAC_CONTROL);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index df15f00..56e5c1b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1669,6 +1669,7 @@ static int stmmac_hw_setup(struct net_device *dev)
 	if (!ret) {
 		pr_warn(" RX IPC Checksum Offload disabled\n");
 		priv->plat->rx_coe = STMMAC_RX_COE_NONE;
+		priv->hw->rx_csum = 0;
 	}
 
 	/* Enable the MAC Rx/Tx */
@@ -2107,7 +2108,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	unsigned int entry = priv->cur_rx % rxsize;
 	unsigned int next_entry;
 	unsigned int count = 0;
-	int coe = priv->plat->rx_coe;
+	int coe = priv->hw->rx_csum;
 
 	if (netif_msg_rx_status(priv)) {
 		pr_debug("%s: descriptor ring:\n", __func__);
@@ -2330,6 +2331,7 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
 		features &= ~NETIF_F_RXCSUM;
 	else if (priv->plat->rx_coe == STMMAC_RX_COE_TYPE1)
 		features &= ~NETIF_F_IPV6_CSUM;
+
 	if (!priv->plat->tx_coe)
 		features &= ~NETIF_F_ALL_CSUM;
 
@@ -2344,6 +2346,24 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
 	return features;
 }
 
+static int stmmac_set_features(struct net_device *netdev,
+			       netdev_features_t features)
+{
+	struct stmmac_priv *priv = netdev_priv(netdev);
+
+	/* Keep the COE Type in case of csum is supporting */
+	if (features & NETIF_F_RXCSUM)
+		priv->hw->rx_csum = priv->plat->rx_coe;
+	else
+		priv->hw->rx_csum = 0;
+	/* No check needed because rx_coe has been set before and it will be
+	 * fixed in case of issue.
+	 */
+	priv->hw->mac->rx_ipc(priv->hw);
+
+	return 0;
+}
+
 /**
  *  stmmac_interrupt - main ISR
  *  @irq: interrupt number.
@@ -2624,6 +2644,7 @@ static const struct net_device_ops stmmac_netdev_ops = {
 	.ndo_stop = stmmac_release,
 	.ndo_change_mtu = stmmac_change_mtu,
 	.ndo_fix_features = stmmac_fix_features,
+	.ndo_set_features = stmmac_set_features,
 	.ndo_set_rx_mode = stmmac_set_rx_mode,
 	.ndo_tx_timeout = stmmac_tx_timeout,
 	.ndo_do_ioctl = stmmac_ioctl,
@@ -2700,9 +2721,11 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	/* To use alternate (extended) or normal descriptor structures */
 	stmmac_selec_desc_mode(priv);
 
-	if (priv->plat->rx_coe)
+	if (priv->plat->rx_coe) {
+		priv->hw->rx_csum = priv->plat->rx_coe;
 		pr_info(" RX Checksum Offload Engine supported (type %d)\n",
 			priv->plat->rx_coe);
+	}
 	if (priv->plat->tx_coe)
 		pr_info(" TX Checksum insertion supported\n");
 
-- 
1.7.4.4
