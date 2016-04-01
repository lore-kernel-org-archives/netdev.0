From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [RESEND PATCH net-next 03/13] stmmac: rework synopsys id read, moved to dwmac setup
Date: Fri, 1 Apr 2016 11:37:27 +0200
Message-ID: <1459503457-22569-4-git-send-email-alexandre.torgue@st.com>
References: <1459503457-22569-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lars Persson <lars.persson@axis.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:2883 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754250AbcDAJiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 05:38:02 -0400
In-Reply-To: <1459503457-22569-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

synopsys_uid is only used once after setup, to get synopsys_id
by using shitf/mask operation. It's no longer used then.
So, remove this temporary variable and directly compute
synopsys_id from setup routine.

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 6cea61b..66e132f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -498,7 +498,6 @@ struct mac_device_info {
 	const struct stmmac_hwtimestamp *ptp;
 	struct mii_regs mii;	/* MII register Addresses */
 	struct mac_link link;
-	unsigned int synopsys_uid;
 	void __iomem *pcsr;     /* vpointer to device CSRs */
 	int multicast_filter_bins;
 	int unicast_filter_entries;
@@ -507,8 +506,10 @@ struct mac_device_info {
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
-					int perfect_uc_entries);
-struct mac_device_info *dwmac100_setup(void __iomem *ioaddr);
+					int perfect_uc_entries,
+					int *synopsys_id);
+struct mac_device_info *dwmac100_setup(void __iomem *ioaddr, int *synopsys_id);
+
 
 void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 			 unsigned int high, unsigned int low);
@@ -521,4 +522,24 @@ void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
 extern const struct stmmac_mode_ops ring_mode_ops;
 extern const struct stmmac_mode_ops chain_mode_ops;
 
+/**
+ * stmmac_get_synopsys_id - return the SYINID.
+ * @priv: driver private structure
+ * Description: this simple function is to decode and return the SYINID
+ * starting from the HW core register.
+ */
+static inline u32 stmmac_get_synopsys_id(u32 hwid)
+{
+	/* Check Synopsys Id (not available on old chips) */
+	if (likely(hwid)) {
+		u32 uid = ((hwid & 0x0000ff00) >> 8);
+		u32 synid = (hwid & 0x000000ff);
+
+		pr_info("stmmac - user ID: 0x%x, Synopsys ID: 0x%x\n",
+			uid, synid);
+
+		return synid;
+	}
+	return 0;
+}
 #endif /* __COMMON_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index c294117..fb1eb57 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -491,7 +491,8 @@ static const struct stmmac_ops dwmac1000_ops = {
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
-					int perfect_uc_entries)
+					int perfect_uc_entries,
+					int *synopsys_id)
 {
 	struct mac_device_info *mac;
 	u32 hwid = readl(ioaddr + GMAC_VERSION);
@@ -516,7 +517,9 @@ struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
 	mac->link.speed = GMAC_CONTROL_FES;
 	mac->mii.addr = GMAC_MII_ADDR;
 	mac->mii.data = GMAC_MII_DATA;
-	mac->synopsys_uid = hwid;
+
+	/* Get and dump the chip ID */
+	*synopsys_id = stmmac_get_synopsys_id(hwid);
 
 	return mac;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index f8dd773..6418b2e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -173,7 +173,7 @@ static const struct stmmac_ops dwmac100_ops = {
 	.get_umac_addr = dwmac100_get_umac_addr,
 };
 
-struct mac_device_info *dwmac100_setup(void __iomem *ioaddr)
+struct mac_device_info *dwmac100_setup(void __iomem *ioaddr, int *synopsys_id)
 {
 	struct mac_device_info *mac;
 
@@ -192,7 +192,8 @@ struct mac_device_info *dwmac100_setup(void __iomem *ioaddr)
 	mac->link.speed = 0;
 	mac->mii.addr = MAC_MII_ADDR;
 	mac->mii.data = MAC_MII_DATA;
-	mac->synopsys_uid = 0;
+	/* Synopsys Id is not available on old chips */
+	*synopsys_id = 0;
 
 	return mac;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8103527..2ebee81 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1468,29 +1468,6 @@ static void stmmac_mmc_setup(struct stmmac_priv *priv)
 }
 
 /**
- * stmmac_get_synopsys_id - return the SYINID.
- * @priv: driver private structure
- * Description: this simple function is to decode and return the SYINID
- * starting from the HW core register.
- */
-static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
-{
-	u32 hwid = priv->hw->synopsys_uid;
-
-	/* Check Synopsys Id (not available on old chips) */
-	if (likely(hwid)) {
-		u32 uid = ((hwid & 0x0000ff00) >> 8);
-		u32 synid = (hwid & 0x000000ff);
-
-		pr_info("stmmac - user ID: 0x%x, Synopsys ID: 0x%x\n",
-			uid, synid);
-
-		return synid;
-	}
-	return 0;
-}
-
-/**
  * stmmac_selec_desc_mode - to select among: normal/alternate/extend descriptors
  * @priv: driver private structure
  * Description: select the Enhanced/Alternate or Normal descriptors.
@@ -2763,18 +2740,16 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 		priv->dev->priv_flags |= IFF_UNICAST_FLT;
 		mac = dwmac1000_setup(priv->ioaddr,
 				      priv->plat->multicast_filter_bins,
-				      priv->plat->unicast_filter_entries);
+				      priv->plat->unicast_filter_entries,
+				      &priv->synopsys_id);
 	} else {
-		mac = dwmac100_setup(priv->ioaddr);
+		mac = dwmac100_setup(priv->ioaddr, &priv->synopsys_id);
 	}
 	if (!mac)
 		return -ENOMEM;
 
 	priv->hw = mac;
 
-	/* Get and dump the chip ID */
-	priv->synopsys_id = stmmac_get_synopsys_id(priv);
-
 	/* To use the chained or ring mode */
 	if (chain_mode) {
 		priv->hw->mode = &chain_mode_ops;
-- 
1.9.1
