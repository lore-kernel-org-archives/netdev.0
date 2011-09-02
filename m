From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 6/9] stmmac: rework the code to get the Synopsys ID (v3)
Date: Fri,  2 Sep 2011 09:51:40 +0200
Message-ID: <1314949903-26137-7-git-send-email-peppe.cavallaro@st.com>
References: <1314949903-26137-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:39606 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757973Ab1IBHwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 03:52:36 -0400
In-Reply-To: <1314949903-26137-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Synopsys ID is now passed from the MAC core
to the main. This info will be used for managing
the HW cap register (supported in the new GMAC
generations).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/common.h         |    1 +
 drivers/net/stmmac/dwmac1000_core.c |    6 ++----
 drivers/net/stmmac/dwmac100_core.c  |    1 +
 drivers/net/stmmac/stmmac_main.c    |   20 +++++++++++++++++++-
 4 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index e08fee8..65b1e56 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -230,6 +230,7 @@ struct mac_device_info {
 	const struct stmmac_dma_ops	*dma;
 	struct mii_regs mii;	/* MII register Addresses */
 	struct mac_link link;
+	unsigned int synopsys_uid;
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr);
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index 9ba9cae..b1c48b9 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -224,10 +224,7 @@ static const struct stmmac_ops dwmac1000_ops = {
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
 {
 	struct mac_device_info *mac;
-	u32 uid = readl(ioaddr + GMAC_VERSION);
-
-	pr_info("\tDWMAC1000 - user ID: 0x%x, Synopsys ID: 0x%x\n",
-		((uid & 0x0000ff00) >> 8), (uid & 0x000000ff));
+	u32 hwid = readl(ioaddr + GMAC_VERSION);
 
 	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
 	if (!mac)
@@ -241,6 +238,7 @@ struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
 	mac->link.speed = GMAC_CONTROL_FES;
 	mac->mii.addr = GMAC_MII_ADDR;
 	mac->mii.data = GMAC_MII_DATA;
+	mac->synopsys_uid = hwid;
 
 	return mac;
 }
diff --git a/drivers/net/stmmac/dwmac100_core.c b/drivers/net/stmmac/dwmac100_core.c
index aacfc6e..138fb8d 100644
--- a/drivers/net/stmmac/dwmac100_core.c
+++ b/drivers/net/stmmac/dwmac100_core.c
@@ -188,6 +188,7 @@ struct mac_device_info *dwmac100_setup(void __iomem *ioaddr)
 	mac->link.speed = 0;
 	mac->mii.addr = MAC_MII_ADDR;
 	mac->mii.data = MAC_MII_DATA;
+	mac->synopsys_uid = 0;
 
 	return mac;
 }
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 1319b4c..f9ba0f7 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -762,6 +762,23 @@ static void stmmac_mmc_setup(struct stmmac_priv *priv)
 	memset(&priv->mmc, 0, sizeof(struct stmmac_counters));
 }
 
+static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
+{
+	u32 hwid = priv->hw->synopsys_uid;
+
+	/* Only check valid Synopsys Id because old MAC chips
+	 * have no HW registers where get the ID */
+	if (likely(hwid)) {
+		u32 uid = ((hwid & 0x0000ff00) >> 8);
+		u32 synid = (hwid & 0x000000ff);
+
+		pr_info("STMMAC - user ID: 0x%x, Synopsys ID: 0x%x\n",
+			uid, synid);
+
+		return synid;
+	}
+	return 0;
+}
 /**
  *  stmmac_open - open entry point of the driver
  *  @dev : pointer to the device structure.
@@ -834,7 +851,8 @@ static int stmmac_open(struct net_device *dev)
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->ioaddr);
 
-	priv->rx_coe = priv->hw->mac->rx_coe(priv->ioaddr);
+	stmmac_get_synopsys_id(priv);
+
 	if (priv->rx_coe)
 		pr_info("stmmac: Rx Checksum Offload Engine supported\n");
 	if (priv->plat->tx_coe)
-- 
1.7.4.4
