From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 5/6] drivers: net: xgene: Using static MSS values
Date: Mon,  9 May 2016 17:04:15 -0700
Message-ID: <1462838656-22043-6-git-send-email-isubramanian@apm.com>
References: <1462838656-22043-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36194 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011AbcEJADz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 20:03:55 -0400
Received: by mail-pf0-f173.google.com with SMTP id c189so83932961pfb.3
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 17:03:54 -0700 (PDT)
In-Reply-To: <1462838656-22043-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to the nature of hardware design for TSO, if the MSS values that are
stored in the register, changes during TSO operation, data corruption may
occur.

This patch fixes the issue by using one of the predefined MSS values.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    |  2 -
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 45 ++++++++++++++++++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  6 +--
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 20 ++++++++--
 5 files changed, 66 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 0050878..2f5638f 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -219,8 +219,6 @@ void xgene_enet_parse_error(struct xgene_enet_desc_ring *ring,
 			    struct xgene_enet_pdata *pdata,
 			    enum xgene_enet_err_code status)
 {
-	struct rtnl_link_stats64 *stats = &pdata->stats;
-
 	switch (status) {
 	case INGRESS_CRC:
 		ring->rx_crc_errors++;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index ecfeffe..a3c12dc 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -227,6 +227,8 @@ enum xgene_enet_rm {
 #define TCPHDR_LEN			6
 #define IPHDR_POS			6
 #define IPHDR_LEN			6
+#define MSS_POS				20
+#define MSS_LEN				2
 #define EC_POS				22	/* Enable checksum */
 #define EC_LEN				1
 #define ET_POS				23	/* Enable TSO */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index d992ae8..af272cb 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -179,6 +179,46 @@ static int xgene_enet_tx_completion(struct xgene_enet_desc_ring *cp_ring,
 	return ret;
 }
 
+static void apm_enet_init_mss_values(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	int i;
+
+	pdata->mss_sw[0] = 64;
+	pdata->mss_sw[1] = 1024;
+	pdata->mss_sw[2] = 1400;
+	pdata->mss_sw[3] = 1446;
+
+	for (i = 0; i < NUM_MSS_REG; i++)
+		pdata->mac_ops->set_mss(pdata, pdata->mss_sw[i], i);
+}
+
+static int apm_enet_get_mss_index(struct net_device *ndev, u32 new_mss)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	int i;
+
+	for (i = NUM_MSS_REG - 1; i >= 0; i--) {
+		if (new_mss >= pdata->mss_sw[i])
+			return i;
+	}
+
+	return -1;
+}
+
+static int xgene_enet_setup_mss(struct net_device *ndev, u64 *hopinfo, u32 mss)
+{
+	int mss_index;
+
+	mss_index = apm_enet_get_mss_index(ndev, mss);
+	if (mss_index < 0)
+		return mss_index;
+
+	*hopinfo |= SET_VAL(MSS, mss_index);
+
+	return 0;
+}
+
 static u64 xgene_enet_work_msg(struct sk_buff *skb)
 {
 	struct net_device *ndev = skb->dev;
@@ -227,6 +267,9 @@ static u64 xgene_enet_work_msg(struct sk_buff *skb)
 			if (!mss || ((skb->len - hdr_len) <= mss))
 				goto out;
 
+			if (xgene_enet_setup_mss(ndev, &hopinfo, mss))
+				return 0;
+
 			hopinfo |= SET_BIT(ET);
 		}
 	} else if (iph->protocol == IPPROTO_UDP) {
@@ -1625,7 +1668,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
 		ndev->features |= NETIF_F_TSO;
-		pdata->mss = XGENE_ENET_MSS;
+		apm_enet_init_mss_values(ndev);
 	}
 	ndev->hw_features = ndev->features;
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 092fbec..20a8b59 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -46,7 +46,7 @@
 #define NUM_PKT_BUF	64
 #define NUM_BUFPOOL	32
 #define MAX_EXP_BUFFS	256
-#define XGENE_ENET_MSS	1448
+#define NUM_MSS_REG	4
 #define XGENE_MIN_ENET_FRAME_SIZE	60
 
 #define XGENE_MAX_ENET_IRQ	16
@@ -141,7 +141,7 @@ struct xgene_mac_ops {
 	void (*tx_disable)(struct xgene_enet_pdata *pdata);
 	void (*rx_disable)(struct xgene_enet_pdata *pdata);
 	void (*set_mac_addr)(struct xgene_enet_pdata *pdata);
-	void (*set_mss)(struct xgene_enet_pdata *pdata);
+	void (*set_mss)(struct xgene_enet_pdata *pdata, u16 mss, u8 index);
 	void (*link_state)(struct work_struct *work);
 };
 
@@ -208,7 +208,7 @@ struct xgene_enet_pdata {
 	u8 eth_bufnum;
 	u8 bp_bufnum;
 	u16 ring_num;
-	u32 mss;
+	u32 mss_sw[NUM_MSS_REG];
 	u8 tx_delay;
 	u8 rx_delay;
 };
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index ba030dc..cb9f681 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -184,9 +184,24 @@ static void xgene_xgmac_set_mac_addr(struct xgene_enet_pdata *pdata)
 	xgene_enet_wr_mac(pdata, HSTMACADR_MSW_ADDR, addr1);
 }
 
-static void xgene_xgmac_set_mss(struct xgene_enet_pdata *pdata)
+static void xgene_xgmac_set_mss(struct xgene_enet_pdata *pdata, u16 mss,
+				u8 index)
 {
-	xgene_enet_wr_csr(pdata, XG_TSIF_MSS_REG0_ADDR, pdata->mss);
+	bool reg_index;
+	u32 data;
+
+	xgene_enet_rd_csr(pdata, XG_TSIF_MSS_REG0_ADDR, &data);
+	reg_index = (index < 2) ? 0 : 1;
+
+	if (!(index & 0x1)) {
+		data &= 0xffff0000;
+		data |= mss;
+	} else {
+		data &= 0xffff;
+		data |= (mss << 16);
+	}
+
+	xgene_enet_wr_csr(pdata, XG_TSIF_MSS_REG0_ADDR + reg_index * 4, data);
 }
 
 static u32 xgene_enet_link_status(struct xgene_enet_pdata *pdata)
@@ -210,7 +225,6 @@ static void xgene_xgmac_init(struct xgene_enet_pdata *pdata)
 	xgene_enet_wr_mac(pdata, AXGMAC_CONFIG_1, data);
 
 	xgene_xgmac_set_mac_addr(pdata);
-	xgene_xgmac_set_mss(pdata);
 
 	xgene_enet_rd_csr(pdata, XG_RSIF_CONFIG_REG_ADDR, &data);
 	data |= CFG_RSIF_FPBUFF_TIMEOUT_EN;
-- 
1.9.1
