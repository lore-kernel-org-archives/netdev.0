From: Anatolij Gustschin <agust@denx.de>
Subject: [net-next-2.6 PATCH v3 2/3] fs_enet: Add support for MPC512x to fs_enet driver
Date: Fri, 26 Feb 2010 23:00:48 +0100
Message-ID: <1267221649-22754-3-git-send-email-agust@denx.de>
References: <1267221649-22754-1-git-send-email-agust@denx.de>
Cc: linuxppc-dev@ozlabs.org, "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>,
	Detlev Zundel <dzu@denx.de>, Wolfgang Denk <wd@denx.de>,
	John Rigby <jcrigby@gmail.com>,
	Anatolij Gustschin <agust@denx.de>,
	Piotr Ziecik <kosmo@semihalf.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:40179 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966326Ab0BZWBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 17:01:42 -0500
In-Reply-To: <1267221649-22754-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the fs_enet driver to support MPC512x FEC.
Enable it with CONFIG_FS_ENET_MPC5121_FEC option.

Signed-off-by: John Rigby <jcrigby@gmail.com>
Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
Signed-off-by: Wolfgang Denk <wd@denx.de>
Signed-off-by: Anatolij Gustschin <agust@denx.de>
Acked-by: Grant Likely <grant.likely@secretlab.ca>
---
 drivers/net/fs_enet/Kconfig        |   10 +++++--
 drivers/net/fs_enet/fs_enet-main.c |    7 +++++
 drivers/net/fs_enet/fs_enet.h      |   49 +++++++++++++++++++++++++++++++++++-
 drivers/net/fs_enet/mac-fec.c      |   46 ++++++++++++++++++++++-----------
 drivers/net/fs_enet/mii-fec.c      |    4 +-
 5 files changed, 95 insertions(+), 21 deletions(-)

diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/fs_enet/Kconfig
index 562ea68..fc073b5 100644
--- a/drivers/net/fs_enet/Kconfig
+++ b/drivers/net/fs_enet/Kconfig
@@ -1,9 +1,13 @@
 config FS_ENET
        tristate "Freescale Ethernet Driver"
-       depends on CPM1 || CPM2
+       depends on CPM1 || CPM2 || PPC_MPC512x
        select MII
        select PHYLIB
 
+config FS_ENET_MPC5121_FEC
+	def_bool y if (FS_ENET && PPC_MPC512x)
+	select FS_ENET_HAS_FEC
+
 config FS_ENET_HAS_SCC
 	bool "Chip has an SCC usable for ethernet"
 	depends on FS_ENET && (CPM1 || CPM2)
@@ -16,13 +20,13 @@ config FS_ENET_HAS_FCC
 
 config FS_ENET_HAS_FEC
 	bool "Chip has an FEC usable for ethernet"
-	depends on FS_ENET && CPM1
+	depends on FS_ENET && (CPM1 || FS_ENET_MPC5121_FEC)
 	select FS_ENET_MDIO_FEC
 	default y
 
 config FS_ENET_MDIO_FEC
 	tristate "MDIO driver for FEC"
-	depends on FS_ENET && CPM1
+	depends on FS_ENET && (CPM1 || FS_ENET_MPC5121_FEC)
 
 config FS_ENET_MDIO_FCC
 	tristate "MDIO driver for FCC"
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index c34a7e0..4297021 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -1094,11 +1094,18 @@ static struct of_device_id fs_enet_match[] = {
 	},
 #endif
 #ifdef CONFIG_FS_ENET_HAS_FEC
+#ifdef CONFIG_FS_ENET_MPC5121_FEC
+	{
+		.compatible = "fsl,mpc5121-fec",
+		.data = (void *)&fs_fec_ops,
+	},
+#else
 	{
 		.compatible = "fsl,pq1-fec-enet",
 		.data = (void *)&fs_fec_ops,
 	},
 #endif
+#endif
 	{}
 };
 MODULE_DEVICE_TABLE(of, fs_enet_match);
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index ef01e09..1ece4b1 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -13,9 +13,56 @@
 
 #ifdef CONFIG_CPM1
 #include <asm/cpm1.h>
+#endif
+
+#if defined(CONFIG_FS_ENET_HAS_FEC)
+#include <asm/cpm.h>
+
+#if defined(CONFIG_FS_ENET_MPC5121_FEC)
+/* MPC5121 FEC has different register layout */
+struct fec {
+	u32 fec_reserved0;
+	u32 fec_ievent;			/* Interrupt event reg */
+	u32 fec_imask;			/* Interrupt mask reg */
+	u32 fec_reserved1;
+	u32 fec_r_des_active;		/* Receive descriptor reg */
+	u32 fec_x_des_active;		/* Transmit descriptor reg */
+	u32 fec_reserved2[3];
+	u32 fec_ecntrl;			/* Ethernet control reg */
+	u32 fec_reserved3[6];
+	u32 fec_mii_data;		/* MII manage frame reg */
+	u32 fec_mii_speed;		/* MII speed control reg */
+	u32 fec_reserved4[7];
+	u32 fec_mib_ctrlstat;		/* MIB control/status reg */
+	u32 fec_reserved5[7];
+	u32 fec_r_cntrl;		/* Receive control reg */
+	u32 fec_reserved6[15];
+	u32 fec_x_cntrl;		/* Transmit Control reg */
+	u32 fec_reserved7[7];
+	u32 fec_addr_low;		/* Low 32bits MAC address */
+	u32 fec_addr_high;		/* High 16bits MAC address */
+	u32 fec_opd;			/* Opcode + Pause duration */
+	u32 fec_reserved8[10];
+	u32 fec_hash_table_high;	/* High 32bits hash table */
+	u32 fec_hash_table_low;		/* Low 32bits hash table */
+	u32 fec_grp_hash_table_high;	/* High 32bits hash table */
+	u32 fec_grp_hash_table_low;	/* Low 32bits hash table */
+	u32 fec_reserved9[7];
+	u32 fec_x_wmrk;			/* FIFO transmit water mark */
+	u32 fec_reserved10;
+	u32 fec_r_bound;		/* FIFO receive bound reg */
+	u32 fec_r_fstart;		/* FIFO receive start reg */
+	u32 fec_reserved11[11];
+	u32 fec_r_des_start;		/* Receive descriptor ring */
+	u32 fec_x_des_start;		/* Transmit descriptor ring */
+	u32 fec_r_buff_size;		/* Maximum receive buff size */
+	u32 fec_reserved12[26];
+	u32 fec_dma_control;		/* DMA Endian and other ctrl */
+};
+#endif
 
 struct fec_info {
-	fec_t __iomem *fecp;
+	struct fec __iomem *fecp;
 	u32 mii_speed;
 };
 #endif
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 8a632f6..cd2c6cc 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -80,7 +80,7 @@
  */
 #define FEC_RESET_DELAY		50
 
-static int whack_reset(fec_t __iomem *fecp)
+static int whack_reset(struct fec __iomem *fecp)
 {
 	int i;
 
@@ -168,7 +168,7 @@ static void cleanup_data(struct net_device *dev)
 static void set_promiscuous_mode(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FS(fecp, r_cntrl, FEC_RCNTRL_PROM);
 }
@@ -216,7 +216,7 @@ static void set_multicast_one(struct net_device *dev, const u8 *mac)
 static void set_multicast_finish(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	/* if all multi or too many multicasts; just enable all */
 	if ((dev->flags & IFF_ALLMULTI) != 0 ||
@@ -246,7 +246,7 @@ static void set_multicast_list(struct net_device *dev)
 static void restart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 	const struct fs_platform_info *fpi = fep->fpi;
 	dma_addr_t rx_bd_base_phys, tx_bd_base_phys;
 	int r;
@@ -280,7 +280,11 @@ static void restart(struct net_device *dev)
 	 * Set maximum receive buffer size.
 	 */
 	FW(fecp, r_buff_size, PKT_MAXBLR_SIZE);
+#ifdef CONFIG_FS_ENET_MPC5121_FEC
+	FW(fecp, r_cntrl, PKT_MAXBUF_SIZE << 16);
+#else
 	FW(fecp, r_hash, PKT_MAXBUF_SIZE);
+#endif
 
 	/* get physical address */
 	rx_bd_base_phys = fep->ring_mem_addr;
@@ -297,7 +301,11 @@ static void restart(struct net_device *dev)
 	/*
 	 * Enable big endian and don't care about SDMA FC.
 	 */
+#ifdef CONFIG_FS_ENET_MPC5121_FEC
+	FS(fecp, dma_control, 0xC0000000);
+#else
 	FW(fecp, fun_code, 0x78000000);
+#endif
 
 	/*
 	 * Set MII speed.
@@ -308,9 +316,17 @@ static void restart(struct net_device *dev)
 	 * Clear any outstanding interrupt.
 	 */
 	FW(fecp, ievent, 0xffc0);
+#ifndef CONFIG_FS_ENET_MPC5121_FEC
 	FW(fecp, ivec, (virq_to_hw(fep->interrupt) / 2) << 29);
 
 	FW(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);	/* MII enable */
+#else
+	/*
+	 * Only set MII mode - do not touch maximum frame length
+	 * configured before.
+	 */
+	FS(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);
+#endif
 	/*
 	 * adjust to duplex mode
 	 */
@@ -339,7 +355,7 @@ static void stop(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	struct fec_info* feci= fep->phydev->bus->priv;
 
@@ -375,7 +391,7 @@ static void stop(struct net_device *dev)
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, ievent, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -383,7 +399,7 @@ static void napi_clear_rx_event(struct net_device *dev)
 static void napi_enable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FS(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -391,7 +407,7 @@ static void napi_enable_rx(struct net_device *dev)
 static void napi_disable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FC(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -399,7 +415,7 @@ static void napi_disable_rx(struct net_device *dev)
 static void rx_bd_done(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, r_des_active, 0x01000000);
 }
@@ -407,7 +423,7 @@ static void rx_bd_done(struct net_device *dev)
 static void tx_kickstart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, x_des_active, 0x01000000);
 }
@@ -415,7 +431,7 @@ static void tx_kickstart(struct net_device *dev)
 static u32 get_int_events(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	return FR(fecp, ievent) & FR(fecp, imask);
 }
@@ -423,7 +439,7 @@ static u32 get_int_events(struct net_device *dev)
 static void clear_int_events(struct net_device *dev, u32 int_events)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, ievent, int_events);
 }
@@ -439,17 +455,17 @@ static int get_regs(struct net_device *dev, void *p, int *sizep)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 
-	if (*sizep < sizeof(fec_t))
+	if (*sizep < sizeof(struct fec))
 		return -EINVAL;
 
-	memcpy_fromio(p, fep->fec.fecp, sizeof(fec_t));
+	memcpy_fromio(p, fep->fec.fecp, sizeof(struct fec));
 
 	return 0;
 }
 
 static int get_regs_len(struct net_device *dev)
 {
-	return sizeof(fec_t);
+	return sizeof(struct fec);
 }
 
 static void tx_restart(struct net_device *dev)
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 96eba42..5944b65 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -52,7 +52,7 @@
 static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 {
 	struct fec_info* fec = bus->priv;
-	fec_t __iomem *fecp = fec->fecp;
+	struct fec __iomem *fecp = fec->fecp;
 	int i, ret = -1;
 
 	BUG_ON((in_be32(&fecp->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0);
@@ -75,7 +75,7 @@ static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location, u16 val)
 {
 	struct fec_info* fec = bus->priv;
-	fec_t __iomem *fecp = fec->fecp;
+	struct fec __iomem *fecp = fec->fecp;
 	int i;
 
 	/* this must never happen */
-- 
1.6.3.3

