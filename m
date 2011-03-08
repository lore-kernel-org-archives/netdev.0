From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH v2 3/6] net: sh_eth: remove almost #ifdef of SH7763
Date: Tue, 08 Mar 2011 16:59:38 +0900
Message-ID: <4D75E1EA.50006@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SH7763 has GETHER. So the specification of some registers differs than
other CPUs. This patch removes almost #ifdef of CONFIG_CPU_SUBTYPE_SH7763.
Then we are able to add other CPU's GETHER easily.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 This patch are based on net-next-2.6.git.

 drivers/net/sh_eth.c |   72 +++++++++++++++++++++++++++++--------------------
 drivers/net/sh_eth.h |   14 +++-------
 2 files changed, 47 insertions(+), 39 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index c7abcc5..6734311 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -157,7 +157,7 @@ static void sh_eth_reset(struct net_device *ndev)
 	int cnt = 100;

 	sh_eth_write(ndev, EDSR_ENALL, EDSR);
-	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST, EDMR);
+	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER, EDMR);
 	while (cnt > 0) {
 		if (!(sh_eth_read(ndev, EDMR) & 0x3))
 			break;
@@ -285,9 +285,9 @@ static void sh_eth_set_default_cpu_data(struct sh_eth_cpu_data *cd)
 /* Chip Reset */
 static void sh_eth_reset(struct net_device *ndev)
 {
-	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST, EDMR);
+	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_ETHER, EDMR);
 	mdelay(3);
-	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) & ~EDMR_SRST, EDMR);
+	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) & ~EDMR_SRST_ETHER, EDMR);
 }
 #endif

@@ -365,6 +365,22 @@ static void read_mac_address(struct net_device *ndev, unsigned char *mac)
 	}
 }

+static int sh_eth_is_gether(struct sh_eth_private *mdp)
+{
+	if (mdp->reg_offset == sh_eth_offset_gigabit)
+		return 1;
+	else
+		return 0;
+}
+
+static unsigned long sh_eth_get_edtrr_trns(struct sh_eth_private *mdp)
+{
+	if (sh_eth_is_gether(mdp))
+		return EDTRR_TRNS_GETHER;
+	else
+		return EDTRR_TRNS_ETHER;
+}
+
 struct bb_info {
 	struct mdiobb_ctrl ctrl;
 	u32 addr;
@@ -504,9 +520,8 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		/* Rx descriptor address set */
 		if (i == 0) {
 			sh_eth_write(ndev, mdp->rx_desc_dma, RDLAR);
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-			sh_eth_write(ndev, mdp->rx_desc_dma, RDFAR);
-#endif
+			if (sh_eth_is_gether(mdp))
+				sh_eth_write(ndev, mdp->rx_desc_dma, RDFAR);
 		}
 	}

@@ -526,9 +541,8 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		if (i == 0) {
 			/* Tx descriptor address set */
 			sh_eth_write(ndev, mdp->tx_desc_dma, TDLAR);
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-			sh_eth_write(ndev, mdp->tx_desc_dma, TDFAR);
-#endif
+			if (sh_eth_is_gether(mdp))
+				sh_eth_write(ndev, mdp->tx_desc_dma, TDFAR);
 		}
 	}

@@ -940,9 +954,9 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		sh_eth_txfree(ndev);

 		/* SH7712 BUG */
-		if (edtrr ^ EDTRR_TRNS) {
+		if (edtrr ^ sh_eth_get_edtrr_trns(mdp)) {
 			/* tx dma start */
-			sh_eth_write(ndev, EDTRR_TRNS, EDTRR);
+			sh_eth_write(ndev, sh_eth_get_edtrr_trns(mdp), EDTRR);
 		}
 		/* wakeup */
 		netif_wake_queue(ndev);
@@ -1347,8 +1361,8 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)

 	mdp->cur_tx++;

-	if (!(sh_eth_read(ndev, EDTRR) & EDTRR_TRNS))
-		sh_eth_write(ndev, EDTRR_TRNS, EDTRR);
+	if (!(sh_eth_read(ndev, EDTRR) & sh_eth_get_edtrr_trns(mdp)))
+		sh_eth_write(ndev, sh_eth_get_edtrr_trns(mdp), EDTRR);

 	return NETDEV_TX_OK;
 }
@@ -1406,15 +1420,15 @@ static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
 	sh_eth_write(ndev, 0, CDCR);	/* (write clear) */
 	mdp->stats.tx_carrier_errors += sh_eth_read(ndev, LCCR);
 	sh_eth_write(ndev, 0, LCCR);	/* (write clear) */
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-	mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CERCR);/* CERCR */
-	sh_eth_write(ndev, 0, CERCR);	/* (write clear) */
-	mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CEECR);/* CEECR */
-	sh_eth_write(ndev, 0, CEECR);	/* (write clear) */
-#else
-	mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CNDCR);
-	sh_eth_write(ndev, 0, CNDCR);	/* (write clear) */
-#endif
+	if (sh_eth_is_gether(mdp)) {
+		mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CERCR);
+		sh_eth_write(ndev, 0, CERCR);	/* (write clear) */
+		mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CEECR);
+		sh_eth_write(ndev, 0, CEECR);	/* (write clear) */
+	} else {
+		mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CNDCR);
+		sh_eth_write(ndev, 0, CNDCR);	/* (write clear) */
+	}
 	pm_runtime_put_sync(&mdp->pdev->dev);

 	return &mdp->stats;
@@ -1465,13 +1479,13 @@ static void sh_eth_tsu_init(struct sh_eth_private *mdp)
 	sh_eth_tsu_write(mdp, 0, TSU_FWSL0);
 	sh_eth_tsu_write(mdp, 0, TSU_FWSL1);
 	sh_eth_tsu_write(mdp, TSU_FWSLC_POSTENU | TSU_FWSLC_POSTENL, TSU_FWSLC);
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-	sh_eth_tsu_write(mdp, 0, TSU_QTAG0);	/* Disable QTAG(0->1) */
-	sh_eth_tsu_write(mdp, 0, TSU_QTAG1);	/* Disable QTAG(1->0) */
-#else
-	sh_eth_tsu_write(mdp, 0, TSU_QTAGM0);	/* Disable QTAG(0->1) */
-	sh_eth_tsu_write(mdp, 0, TSU_QTAGM1);	/* Disable QTAG(1->0) */
-#endif
+	if (sh_eth_is_gether(mdp)) {
+		sh_eth_tsu_write(mdp, 0, TSU_QTAG0);	/* Disable QTAG(0->1) */
+		sh_eth_tsu_write(mdp, 0, TSU_QTAG1);	/* Disable QTAG(1->0) */
+	} else {
+		sh_eth_tsu_write(mdp, 0, TSU_QTAGM0);	/* Disable QTAG(0->1) */
+		sh_eth_tsu_write(mdp, 0, TSU_QTAGM1);	/* Disable QTAG(1->0) */
+	}
 	sh_eth_tsu_write(mdp, 0, TSU_FWSR);	/* all interrupt status clear */
 	sh_eth_tsu_write(mdp, 0, TSU_FWINMK);	/* Disable all interrupt */
 	sh_eth_tsu_write(mdp, 0, TSU_TEN);	/* Disable all CAM entry */
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index 35a3adb..b349c5e 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -400,20 +400,14 @@ enum GECMR_BIT {
 enum DMAC_M_BIT {
 	EDMR_EL = 0x40, /* Litte endian */
 	EDMR_DL1 = 0x20, EDMR_DL0 = 0x10,
-#ifdef CONFIG_CPU_SUBTYPE_SH7763
-	EDMR_SRST = 0x03,
-#else /* CONFIG_CPU_SUBTYPE_SH7763 */
-	EDMR_SRST = 0x01,
-#endif
+	EDMR_SRST_GETHER = 0x03,
+	EDMR_SRST_ETHER = 0x01,
 };

 /* EDTRR */
 enum DMAC_T_BIT {
-#ifdef CONFIG_CPU_SUBTYPE_SH7763
-	EDTRR_TRNS = 0x03,
-#else
-	EDTRR_TRNS = 0x01,
-#endif
+	EDTRR_TRNS_GETHER = 0x03,
+	EDTRR_TRNS_ETHER = 0x01,
 };

 /* EDRRR*/
-- 
1.7.1
