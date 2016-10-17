From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 02/15] ethernet/broadcom: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:04 -0400
Message-ID: <20161017195417.48259-3-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Michael Chan <michael.chan@broadcom.com>,
        Sony Chacko <sony.chacko@qlogic.com>,
        Ariel Elior <ariel.elior@qlogic.com>,
        Dept-HSGLinuxNICDev@qlogic.com,
        Siva Reddy Kallam <siva.kallam@broadcom.com>,
        Prashant Sreedharan <prashant@broadcom.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52948 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758729AbcJQTy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 15:54:28 -0400
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3: min_mtu 60, max_mtu 9000/1500

bnxt: min_mtu 60, max_mtu 9000

bnx2x: min_mtu 46, max_mtu 9600
- Fix up ETH_OVREHEAD -> ETH_OVERHEAD while we're in here, remove
  duplicated defines from bnx2x_link.c.

bnx2: min_mtu 46, max_mtu 9000
- Use more standard ETH_* defines while we're at it.

bcm63xx_enet: min_mtu 46, max_mtu 2028
- compute_hw_mtu was made largely pointless, and thus merged back into
  bcm_enet_change_mtu.

b44: min_mtu 60, max_mtu 1500

CC: netdev@vger.kernel.org
CC: Michael Chan <michael.chan@broadcom.com>
CC: Sony Chacko <sony.chacko@qlogic.com>
CC: Ariel Elior <ariel.elior@qlogic.com>
CC: Dept-HSGLinuxNICDev@qlogic.com
CC: Siva Reddy Kallam <siva.kallam@broadcom.com>
CC: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/broadcom/b44.c              |  9 +++---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c     | 35 ++++++++----------------
 drivers/net/ethernet/broadcom/bnx2.c             | 16 +++++------
 drivers/net/ethernet/broadcom/bnx2.h             |  6 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  6 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |  8 +-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 22 ++++++---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  7 +++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.c        |  7 +++--
 drivers/net/ethernet/broadcom/tg3.c              |  9 +++---
 10 files changed, 51 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 17aa33c..1df3048 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -59,8 +59,8 @@
 #define B44_TX_TIMEOUT			(5 * HZ)
 
 /* hardware minimum and maximum for a single frame's data payload */
-#define B44_MIN_MTU			60
-#define B44_MAX_MTU			1500
+#define B44_MIN_MTU			ETH_ZLEN
+#define B44_MAX_MTU			ETH_DATA_LEN
 
 #define B44_RX_RING_SIZE		512
 #define B44_DEF_RX_RING_PENDING		200
@@ -1064,9 +1064,6 @@ static int b44_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	if (new_mtu < B44_MIN_MTU || new_mtu > B44_MAX_MTU)
-		return -EINVAL;
-
 	if (!netif_running(dev)) {
 		/* We'll just catch it later when the
 		 * device is up'd.
@@ -2377,6 +2374,8 @@ static int b44_init_one(struct ssb_device *sdev,
 	dev->netdev_ops = &b44_netdev_ops;
 	netif_napi_add(dev, &bp->napi, b44_poll, 64);
 	dev->watchdog_timeo = B44_TX_TIMEOUT;
+	dev->min_mtu = B44_MIN_MTU;
+	dev->max_mtu = B44_MAX_MTU;
 	dev->irq = sdev->irq;
 	dev->ethtool_ops = &b44_ethtool_ops;
 
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index ae364c7..7e513ca 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1622,20 +1622,19 @@ static int bcm_enet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 }
 
 /*
- * calculate actual hardware mtu
+ * adjust mtu, can't be called while device is running
  */
-static int compute_hw_mtu(struct bcm_enet_priv *priv, int mtu)
+static int bcm_enet_change_mtu(struct net_device *dev, int new_mtu)
 {
-	int actual_mtu;
+	struct bcm_enet_priv *priv = netdev_priv(dev);
+	int actual_mtu = new_mtu;
 
-	actual_mtu = mtu;
+	if (netif_running(dev))
+		return -EBUSY;
 
 	/* add ethernet header + vlan tag size */
 	actual_mtu += VLAN_ETH_HLEN;
 
-	if (actual_mtu < 64 || actual_mtu > BCMENET_MAX_MTU)
-		return -EINVAL;
-
 	/*
 	 * setup maximum size before we get overflow mark in
 	 * descriptor, note that this will not prevent reception of
@@ -1650,22 +1649,7 @@ static int compute_hw_mtu(struct bcm_enet_priv *priv, int mtu)
 	 */
 	priv->rx_skb_size = ALIGN(actual_mtu + ETH_FCS_LEN,
 				  priv->dma_maxburst * 4);
-	return 0;
-}
 
-/*
- * adjust mtu, can't be called while device is running
- */
-static int bcm_enet_change_mtu(struct net_device *dev, int new_mtu)
-{
-	int ret;
-
-	if (netif_running(dev))
-		return -EBUSY;
-
-	ret = compute_hw_mtu(netdev_priv(dev), new_mtu);
-	if (ret)
-		return ret;
 	dev->mtu = new_mtu;
 	return 0;
 }
@@ -1755,7 +1739,7 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	priv->enet_is_sw = false;
 	priv->dma_maxburst = BCMENET_DMA_MAXBURST;
 
-	ret = compute_hw_mtu(priv, dev->mtu);
+	ret = bcm_enet_change_mtu(dev, dev->mtu);
 	if (ret)
 		goto out;
 
@@ -1888,6 +1872,9 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	netif_napi_add(dev, &priv->napi, bcm_enet_poll, 16);
 
 	dev->ethtool_ops = &bcm_enet_ethtool_ops;
+	/* MTU range: 46 - 2028 */
+	dev->min_mtu = ETH_ZLEN - ETH_HLEN;
+	dev->max_mtu = BCMENET_MAX_MTU - VLAN_ETH_HLEN;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	ret = register_netdev(dev);
@@ -2742,7 +2729,7 @@ static int bcm_enetsw_probe(struct platform_device *pdev)
 		priv->dma_chan_width = pd->dma_chan_width;
 	}
 
-	ret = compute_hw_mtu(priv, dev->mtu);
+	ret = bcm_enet_change_mtu(dev, dev->mtu);
 	if (ret)
 		goto out;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 27f11a5..2a5df3f 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2298,7 +2298,7 @@ bnx2_init_5706s_phy(struct bnx2 *bp, int reset_phy)
 	if (BNX2_CHIP(bp) == BNX2_CHIP_5706)
 		BNX2_WR(bp, BNX2_MISC_GP_HW_CTL0, 0x300);
 
-	if (bp->dev->mtu > 1500) {
+	if (bp->dev->mtu > ETH_DATA_LEN) {
 		u32 val;
 
 		/* Set extended packet length bit */
@@ -2352,7 +2352,7 @@ bnx2_init_copper_phy(struct bnx2 *bp, int reset_phy)
 		bnx2_write_phy(bp, MII_BNX2_DSP_RW_PORT, val);
 	}
 
-	if (bp->dev->mtu > 1500) {
+	if (bp->dev->mtu > ETH_DATA_LEN) {
 		/* Set extended packet length bit */
 		bnx2_write_phy(bp, 0x18, 0x7);
 		bnx2_read_phy(bp, 0x18, &val);
@@ -4985,12 +4985,12 @@ bnx2_init_chip(struct bnx2 *bp)
 	/* Program the MTU.  Also include 4 bytes for CRC32. */
 	mtu = bp->dev->mtu;
 	val = mtu + ETH_HLEN + ETH_FCS_LEN;
-	if (val > (MAX_ETHERNET_PACKET_SIZE + 4))
+	if (val > (MAX_ETHERNET_PACKET_SIZE + ETH_HLEN + 4))
 		val |= BNX2_EMAC_RX_MTU_SIZE_JUMBO_ENA;
 	BNX2_WR(bp, BNX2_EMAC_RX_MTU_SIZE, val);
 
-	if (mtu < 1500)
-		mtu = 1500;
+	if (mtu < ETH_DATA_LEN)
+		mtu = ETH_DATA_LEN;
 
 	bnx2_reg_wr_ind(bp, BNX2_RBUF_CONFIG, BNX2_RBUF_CONFIG_VAL(mtu));
 	bnx2_reg_wr_ind(bp, BNX2_RBUF_CONFIG2, BNX2_RBUF_CONFIG2_VAL(mtu));
@@ -7896,10 +7896,6 @@ bnx2_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 
-	if (((new_mtu + ETH_HLEN) > MAX_ETHERNET_JUMBO_PACKET_SIZE) ||
-		((new_mtu + ETH_HLEN) < MIN_ETHERNET_PACKET_SIZE))
-		return -EINVAL;
-
 	dev->mtu = new_mtu;
 	return bnx2_change_ring_size(bp, bp->rx_ring_size, bp->tx_ring_size,
 				     false);
@@ -8589,6 +8585,8 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 	dev->features |= dev->hw_features;
 	dev->priv_flags |= IFF_UNICAST_FLT;
+	dev->min_mtu = MIN_ETHERNET_PACKET_SIZE;
+	dev->max_mtu = MAX_ETHERNET_JUMBO_PACKET_SIZE;
 
 	if (!(bp->flags & BNX2_FLAG_CAN_KEEP_VLAN))
 		dev->hw_features &= ~NETIF_F_HW_VLAN_CTAG_RX;
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index 380234d..a09ec47 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6530,9 +6530,9 @@ struct l2_fhdr {
 #define MII_BNX2_AER_AER_AN_MMD			   0x3800
 #define MII_BNX2_BLK_ADDR_COMBO_IEEEB0		 0xffe0
 
-#define MIN_ETHERNET_PACKET_SIZE	60
-#define MAX_ETHERNET_PACKET_SIZE	1514
-#define MAX_ETHERNET_JUMBO_PACKET_SIZE	9014
+#define MIN_ETHERNET_PACKET_SIZE	(ETH_ZLEN - ETH_HLEN)
+#define MAX_ETHERNET_PACKET_SIZE	ETH_DATA_LEN
+#define MAX_ETHERNET_JUMBO_PACKET_SIZE	9000
 
 #define BNX2_RX_COPY_THRESH		128
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 7dd7490..0a23034 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1396,9 +1396,9 @@ struct bnx2x {
 	int			tx_ring_size;
 
 /* L2 header size + 2*VLANs (8 bytes) + LLC SNAP (8 bytes) */
-#define ETH_OVREHEAD		(ETH_HLEN + 8 + 8)
-#define ETH_MIN_PACKET_SIZE		60
-#define ETH_MAX_PACKET_SIZE		1500
+#define ETH_OVERHEAD		(ETH_HLEN + 8 + 8)
+#define ETH_MIN_PACKET_SIZE		(ETH_ZLEN - ETH_HLEN)
+#define ETH_MAX_PACKET_SIZE		ETH_DATA_LEN
 #define ETH_MAX_JUMBO_PACKET_SIZE	9600
 /* TCP with Timestamp Option (32) + IPv6 (40) */
 #define ETH_MAX_TPA_HEADER_SIZE		72
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 0a9108c..ed42c10 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2023,7 +2023,7 @@ static void bnx2x_set_rx_buf_size(struct bnx2x *bp)
 			mtu = bp->dev->mtu;
 		fp->rx_buf_size = BNX2X_FW_RX_ALIGN_START +
 				  IP_HEADER_ALIGNMENT_PADDING +
-				  ETH_OVREHEAD +
+				  ETH_OVERHEAD +
 				  mtu +
 				  BNX2X_FW_RX_ALIGN_END;
 		/* Note : rx_buf_size doesn't take into account NET_SKB_PAD */
@@ -4855,12 +4855,6 @@ int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 		return -EAGAIN;
 	}
 
-	if ((new_mtu > ETH_MAX_JUMBO_PACKET_SIZE) ||
-	    ((new_mtu + ETH_HLEN) < ETH_MIN_PACKET_SIZE)) {
-		BNX2X_ERR("Can't support requested MTU size\n");
-		return -EINVAL;
-	}
-
 	/* This does not race with packet allocation
 	 * because the actual alloc size is
 	 * only updated as part of load
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 1fb8010..05356ef 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -34,12 +34,6 @@ typedef int (*read_sfp_module_eeprom_func_p)(struct bnx2x_phy *phy,
 					     u8 dev_addr, u16 addr, u8 byte_cnt,
 					     u8 *o_buf, u8);
 /********************************************************/
-#define ETH_HLEN			14
-/* L2 header size + 2*VLANs (8 bytes) + LLC SNAP (8 bytes) */
-#define ETH_OVREHEAD			(ETH_HLEN + 8 + 8)
-#define ETH_MIN_PACKET_SIZE		60
-#define ETH_MAX_PACKET_SIZE		1500
-#define ETH_MAX_JUMBO_PACKET_SIZE	9600
 #define MDIO_ACCESS_TIMEOUT		1000
 #define WC_LANE_MAX			4
 #define I2C_SWITCH_WIDTH		2
@@ -1917,7 +1911,7 @@ static int bnx2x_emac_enable(struct link_params *params,
 	/* Enable emac for jumbo packets */
 	EMAC_WR(bp, EMAC_REG_EMAC_RX_MTU_SIZE,
 		(EMAC_RX_MTU_SIZE_JUMBO_ENA |
-		 (ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD)));
+		 (ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVERHEAD)));
 
 	/* Strip CRC */
 	REG_WR(bp, NIG_REG_NIG_INGRESS_EMAC0_NO_CRC + port*4, 0x1);
@@ -2314,19 +2308,19 @@ static int bnx2x_bmac1_enable(struct link_params *params,
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL, wb_data, 2);
 
 	/* Set rx mtu */
-	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
+	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVERHEAD;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_MAX_SIZE, wb_data, 2);
 
 	bnx2x_update_pfc_bmac1(params, vars);
 
 	/* Set tx mtu */
-	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
+	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVERHEAD;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_MAX_SIZE, wb_data, 2);
 
 	/* Set cnt max size */
-	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
+	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVERHEAD;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_CNT_MAX_SIZE, wb_data, 2);
 
@@ -2384,18 +2378,18 @@ static int bnx2x_bmac2_enable(struct link_params *params,
 	udelay(30);
 
 	/* Set RX MTU */
-	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
+	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVERHEAD;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_MAX_SIZE, wb_data, 2);
 	udelay(30);
 
 	/* Set TX MTU */
-	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
+	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVERHEAD;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_MAX_SIZE, wb_data, 2);
 	udelay(30);
 	/* Set cnt max size */
-	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD - 2;
+	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVERHEAD - 2;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_CNT_MAX_SIZE, wb_data, 2);
 	udelay(30);
@@ -2516,7 +2510,7 @@ static int bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 
 	} else {
 		u32 thresh = (ETH_MAX_JUMBO_PACKET_SIZE +
-			      ETH_OVREHEAD)/16;
+			      ETH_OVERHEAD)/16;
 		REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + port*4, 0);
 		/* Update threshold */
 		REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, thresh);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 20fe6a8..67b6180 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12080,8 +12080,7 @@ static int bnx2x_get_hwinfo(struct bnx2x *bp)
 					   mtu_size, mtu);
 
 					/* if valid: update device mtu */
-					if (((mtu_size + ETH_HLEN) >=
-					     ETH_MIN_PACKET_SIZE) &&
+					if ((mtu_size >= ETH_MIN_PACKET_SIZE) &&
 					    (mtu_size <=
 					     ETH_MAX_JUMBO_PACKET_SIZE))
 						bp->dev->mtu = mtu_size;
@@ -13315,6 +13314,10 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 	dev->dcbnl_ops = &bnx2x_dcbnl_ops;
 #endif
 
+	/* MTU range, 46 - 9600 */
+	dev->min_mtu = ETH_MIN_PACKET_SIZE;
+	dev->max_mtu = ETH_MAX_JUMBO_PACKET_SIZE;
+
 	/* get_port_hwinfo() will set prtad and mmds properly */
 	bp->mdio.prtad = MDIO_PRTAD_NONE;
 	bp->mdio.mmds = 0;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index a9f9f37..a042da1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6290,9 +6290,6 @@ static int bnxt_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
-	if (new_mtu < 60 || new_mtu > 9500)
-		return -EINVAL;
-
 	if (netif_running(dev))
 		bnxt_close_nic(bp, false, false);
 
@@ -6870,6 +6867,10 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->features |= dev->hw_features | NETIF_F_HIGHDMA;
 	dev->priv_flags |= IFF_UNICAST_FLT;
 
+	/* MTU range: 60 - 9500 */
+	dev->min_mtu = ETH_ZLEN;
+	dev->max_mtu = 9500;
+
 #ifdef CONFIG_BNXT_SRIOV
 	init_waitqueue_head(&bp->sriov_cfg_wait);
 #endif
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a927a73..185e9e0 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -124,7 +124,7 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 #define TG3_TX_TIMEOUT			(5 * HZ)
 
 /* hardware minimum and maximum for a single frame's data payload */
-#define TG3_MIN_MTU			60
+#define TG3_MIN_MTU			ETH_ZLEN
 #define TG3_MAX_MTU(tp)	\
 	(tg3_flag(tp, JUMBO_CAPABLE) ? 9000 : 1500)
 
@@ -14199,9 +14199,6 @@ static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 	int err;
 	bool reset_phy = false;
 
-	if (new_mtu < TG3_MIN_MTU || new_mtu > TG3_MAX_MTU(tp))
-		return -EINVAL;
-
 	if (!netif_running(dev)) {
 		/* We'll just catch it later when the
 		 * device is up'd.
@@ -17799,6 +17796,10 @@ static int tg3_init_one(struct pci_dev *pdev,
 	dev->hw_features |= features;
 	dev->priv_flags |= IFF_UNICAST_FLT;
 
+	/* MTU range: 60 - 9000 or 1500, depending on hardware */
+	dev->min_mtu = TG3_MIN_MTU;
+	dev->max_mtu = TG3_MAX_MTU(tp);
+
 	if (tg3_chip_rev_id(tp) == CHIPREV_ID_5705_A1 &&
 	    !tg3_flag(tp, TSO_CAPABLE) &&
 	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {
-- 
2.10.0
