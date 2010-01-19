From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH 01/11] fs_enet: Add support for MPC512x to fs_enet driver
Date: Tue, 19 Jan 2010 21:24:03 +0100
Message-ID: <1263932653-3634-2-git-send-email-agust@denx.de>
References: <1263932653-3634-1-git-send-email-agust@denx.de>
Cc: dzu@denx.de, wd@denx.de, Anatolij Gustschin <agust@denx.de>,
	John Rigby <jrigby@freescale.com>,
	Piotr Ziecik <kosmo@semihalf.com>, <netdev@vger.kernel.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	John Rigby <jcrigby@gmail.com>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:41954 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327Ab0ASUYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 15:24:20 -0500
In-Reply-To: <1263932653-3634-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    drivers/net/fs_enet/*
        Enable fs_enet driver to work 5121 FEC
        Enable it with CONFIG_FS_ENET_MPC5121_FEC

Signed-off-by: John Rigby <jrigby@freescale.com>
Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
Signed-off-by: Wolfgang Denk <wd@denx.de>
Signed-off-by: Anatolij Gustschin <agust@denx.de>
Cc: <netdev@vger.kernel.org>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: John Rigby <jcrigby@gmail.com>
---
 drivers/net/fs_enet/Kconfig        |   10 ++-
 drivers/net/fs_enet/fs_enet-main.c |    4 +
 drivers/net/fs_enet/fs_enet.h      |   40 +++++++++++-
 drivers/net/fs_enet/mac-fec.c      |  132 +++++++++++++++++++++++++++++-------
 drivers/net/fs_enet/mii-fec.c      |   55 +++++++++++-----
 drivers/net/fs_enet/mpc5121_fec.h  |   64 +++++++++++++++++
 drivers/net/fs_enet/mpc8xx_fec.h   |   37 ++++++++++
 7 files changed, 297 insertions(+), 45 deletions(-)
 create mode 100644 drivers/net/fs_enet/mpc5121_fec.h
 create mode 100644 drivers/net/fs_enet/mpc8xx_fec.h

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
index ec2f503..909b78d 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -1104,6 +1104,10 @@ static struct of_device_id fs_enet_match[] = {
 #endif
 #ifdef CONFIG_FS_ENET_HAS_FEC
 	{
+		.compatible = "fsl,mpc5121-fec",
+		.data = (void *)&fs_fec_ops,
+	},
+	{
 		.compatible = "fsl,pq1-fec-enet",
 		.data = (void *)&fs_fec_ops,
 	},
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index ef01e09..577a352 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -13,11 +13,47 @@
 
 #ifdef CONFIG_CPM1
 #include <asm/cpm1.h>
+#endif
+
+#if defined(CONFIG_FS_ENET_HAS_FEC)
+#include <asm/cpm.h>
+#include "mpc8xx_fec.h"
+#include "mpc5121_fec.h"
 
 struct fec_info {
-	fec_t __iomem *fecp;
+	void __iomem *fecp;
+	void __iomem *fec_r_cntrl;
+	void __iomem *fec_ecntrl;
+	void __iomem *fec_ievent;
+	void __iomem *fec_mii_data;
+	void __iomem *fec_mii_speed;
 	u32 mii_speed;
 };
+
+struct reg_tbl {
+	void __iomem *fec_ievent;
+	void __iomem *fec_imask;
+	void __iomem *fec_r_des_active;
+	void __iomem *fec_x_des_active;
+	void __iomem *fec_r_des_start;
+	void __iomem *fec_x_des_start;
+	void __iomem *fec_r_cntrl;
+	void __iomem *fec_ecntrl;
+	void __iomem *fec_ivec;
+	void __iomem *fec_mii_speed;
+	void __iomem *fec_addr_low;
+	void __iomem *fec_addr_high;
+	void __iomem *fec_hash_table_high;
+	void __iomem *fec_hash_table_low;
+	void __iomem *fec_r_buff_size;
+	void __iomem *fec_r_bound;
+	void __iomem *fec_r_fstart;
+	void __iomem *fec_x_fstart;
+	void __iomem *fec_fun_code;
+	void __iomem *fec_r_hash;
+	void __iomem *fec_x_cntrl;
+	void __iomem *fec_dma_control;
+};
 #endif
 
 #ifdef CONFIG_CPM2
@@ -113,7 +149,9 @@ struct fs_enet_private {
 		struct {
 			int idx;		/* FEC1 = 0, FEC2 = 1  */
 			void __iomem *fecp;	/* hw registers        */
+			struct reg_tbl *rtbl;	/* used registers table */
 			u32 hthi, htlo;		/* state for multicast */
+			u32 fec_id;
 		} fec;
 
 		struct {
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index ca7bcb8..4a5d5ca 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -64,10 +64,10 @@
 #endif
 
 /* write */
-#define FW(_fecp, _reg, _v) __fs_out32(&(_fecp)->fec_ ## _reg, (_v))
+#define FW(_fecp, _reg, _v) __fs_out32((_fecp)->fec_ ## _reg, (_v))
 
 /* read */
-#define FR(_fecp, _reg)	__fs_in32(&(_fecp)->fec_ ## _reg)
+#define FR(_fecp, _reg)	__fs_in32((_fecp)->fec_ ## _reg)
 
 /* set bits */
 #define FS(_fecp, _reg, _v) FW(_fecp, _reg, FR(_fecp, _reg) | (_v))
@@ -75,12 +75,23 @@
 /* clear bits */
 #define FC(_fecp, _reg, _v) FW(_fecp, _reg, FR(_fecp, _reg) & ~(_v))
 
+/* register address macros */
+#define fec_reg_addr(_type, _reg) \
+	(fep->fec.rtbl->fec_##_reg = \
+		fep->fec.fecp + (int)&((__typeof__(_type) *)NULL)->fec_##_reg)
+
+#define fec_reg_mpc8xx(_reg) \
+	fec_reg_addr(struct mpc8xx_fec, _reg)
+
+#define fec_reg_mpc5121(_reg) \
+	fec_reg_addr(struct mpc5121_fec, _reg)
+
 /*
  * Delay to wait for FEC reset command to complete (in us)
  */
 #define FEC_RESET_DELAY		50
 
-static int whack_reset(fec_t __iomem *fecp)
+static int whack_reset(struct reg_tbl *fecp)
 {
 	int i;
 
@@ -106,6 +117,50 @@ static int do_pd_setup(struct fs_enet_private *fep)
 	if (!fep->fcc.fccp)
 		return -EINVAL;
 
+	fep->fec.rtbl = kzalloc(sizeof(*fep->fec.rtbl), GFP_KERNEL);
+	if (!fep->fec.rtbl) {
+		iounmap(fep->fec.fecp);
+		return -ENOMEM;
+	}
+
+	if (of_device_is_compatible(ofdev->node, "fsl,mpc5121-fec")) {
+		fep->fec.fec_id = FS_ENET_MPC5121_FEC;
+		fec_reg_mpc5121(ievent);
+		fec_reg_mpc5121(imask);
+		fec_reg_mpc5121(r_cntrl);
+		fec_reg_mpc5121(ecntrl);
+		fec_reg_mpc5121(r_des_active);
+		fec_reg_mpc5121(x_des_active);
+		fec_reg_mpc5121(r_des_start);
+		fec_reg_mpc5121(x_des_start);
+		fec_reg_mpc5121(addr_low);
+		fec_reg_mpc5121(addr_high);
+		fec_reg_mpc5121(hash_table_high);
+		fec_reg_mpc5121(hash_table_low);
+		fec_reg_mpc5121(r_buff_size);
+		fec_reg_mpc5121(mii_speed);
+		fec_reg_mpc5121(x_cntrl);
+		fec_reg_mpc5121(dma_control);
+	} else {
+		fec_reg_mpc8xx(ievent);
+		fec_reg_mpc8xx(imask);
+		fec_reg_mpc8xx(r_cntrl);
+		fec_reg_mpc8xx(ecntrl);
+		fec_reg_mpc8xx(mii_speed);
+		fec_reg_mpc8xx(r_des_active);
+		fec_reg_mpc8xx(x_des_active);
+		fec_reg_mpc8xx(r_des_start);
+		fec_reg_mpc8xx(x_des_start);
+		fec_reg_mpc8xx(ivec);
+		fec_reg_mpc8xx(addr_low);
+		fec_reg_mpc8xx(addr_high);
+		fec_reg_mpc8xx(hash_table_high);
+		fec_reg_mpc8xx(hash_table_low);
+		fec_reg_mpc8xx(r_buff_size);
+		fec_reg_mpc8xx(x_fstart);
+		fec_reg_mpc8xx(r_hash);
+		fec_reg_mpc8xx(x_cntrl);
+	}
 	return 0;
 }
 
@@ -162,13 +217,15 @@ static void free_bd(struct net_device *dev)
 
 static void cleanup_data(struct net_device *dev)
 {
-	/* nothing */
+	struct fs_enet_private *fep = netdev_priv(dev);
+
+	kfree(fep->fec.rtbl);
 }
 
 static void set_promiscuous_mode(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct reg_tbl *fecp = fep->fec.rtbl;
 
 	FS(fecp, r_cntrl, FEC_RCNTRL_PROM);
 }
@@ -216,7 +273,7 @@ static void set_multicast_one(struct net_device *dev, const u8 *mac)
 static void set_multicast_finish(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct reg_tbl *fecp = fep->fec.rtbl;
 
 	/* if all multi or too many multicasts; just enable all */
 	if ((dev->flags & IFF_ALLMULTI) != 0 ||
@@ -246,7 +303,7 @@ static void set_multicast_list(struct net_device *dev)
 static void restart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct reg_tbl *fecp = fep->fec.rtbl;
 	const struct fs_platform_info *fpi = fep->fpi;
 	dma_addr_t rx_bd_base_phys, tx_bd_base_phys;
 	int r;
@@ -255,7 +312,7 @@ static void restart(struct net_device *dev)
 	struct mii_bus* mii = fep->phydev->bus;
 	struct fec_info* fec_inf = mii->priv;
 
-	r = whack_reset(fep->fec.fecp);
+	r = whack_reset(fecp);
 	if (r != 0)
 		printk(KERN_ERR DRV_MODULE_NAME
 				": %s FEC Reset FAILED!\n", dev->name);
@@ -281,7 +338,10 @@ static void restart(struct net_device *dev)
 	 * Set maximum receive buffer size.
 	 */
 	FW(fecp, r_buff_size, PKT_MAXBLR_SIZE);
-	FW(fecp, r_hash, PKT_MAXBUF_SIZE);
+	if (fep->fec.fec_id == FS_ENET_MPC5121_FEC)
+		FW(fecp, r_cntrl, PKT_MAXBUF_SIZE << 16);
+	else
+		FW(fecp, r_hash, PKT_MAXBUF_SIZE);
 
 	/* get physical address */
 	rx_bd_base_phys = fep->ring_mem_addr;
@@ -296,9 +356,13 @@ static void restart(struct net_device *dev)
 	fs_init_bds(dev);
 
 	/*
-	 * Enable big endian and don't care about SDMA FC.
+	 * Enable big endian.
 	 */
-	FW(fecp, fun_code, 0x78000000);
+	if (fep->fec.fec_id == FS_ENET_MPC5121_FEC)
+		FS(fecp, dma_control, 0xC0000000);
+	else
+		/* Don't care about SDMA Function Code. */
+		FW(fecp, fun_code, 0x78000000);
 
 	/*
 	 * Set MII speed.
@@ -309,9 +373,20 @@ static void restart(struct net_device *dev)
 	 * Clear any outstanding interrupt.
 	 */
 	FW(fecp, ievent, 0xffc0);
-	FW(fecp, ivec, (virq_to_hw(fep->interrupt) / 2) << 29);
+	if (fep->fec.fec_id != FS_ENET_MPC5121_FEC)
+		FW(fecp, ivec, (virq_to_hw(fep->interrupt) / 2) << 29);
+
+	/* MII enable */
+	if (fep->fec.fec_id == FS_ENET_MPC5121_FEC) {
+		/*
+		 * Only set requested bit - do not touch maximum packet
+		 * size configured earlier.
+		 */
+		FS(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);
+	} else {
+		FW(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);
+	}
 
-	FW(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);	/* MII enable */
 	/*
 	 * adjust to duplex mode
 	 */
@@ -340,7 +415,7 @@ static void stop(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct reg_tbl *fecp = fep->fec.rtbl;
 
 	struct fec_info* feci= fep->phydev->bus->priv;
 
@@ -378,7 +453,7 @@ static void stop(struct net_device *dev)
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct reg_tbl *fecp = fep->fec.rtbl;
 
 	FW(fecp, ievent, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -386,7 +461,7 @@ static void napi_clear_rx_event(struct net_device *dev)
 static void napi_enable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct reg_tbl *fecp = fep->fec.rtbl;
 
 	FS(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -394,7 +469,7 @@ static void napi_enable_rx(struct net_device *dev)
 static void napi_disable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct reg_tbl *fecp = fep->fec.rtbl;
 
 	FC(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -402,7 +477,7 @@ static void napi_disable_rx(struct net_device *dev)
 static void rx_bd_done(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct reg_tbl *fecp = fep->fec.rtbl;
 
 	FW(fecp, r_des_active, 0x01000000);
 }
@@ -410,7 +485,7 @@ static void rx_bd_done(struct net_device *dev)
 static void tx_kickstart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct reg_tbl *fecp = fep->fec.rtbl;
 
 	FW(fecp, x_des_active, 0x01000000);
 }
@@ -418,7 +493,7 @@ static void tx_kickstart(struct net_device *dev)
 static u32 get_int_events(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct reg_tbl *fecp = fep->fec.rtbl;
 
 	return FR(fecp, ievent) & FR(fecp, imask);
 }
@@ -426,7 +501,7 @@ static u32 get_int_events(struct net_device *dev)
 static void clear_int_events(struct net_device *dev, u32 int_events)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct reg_tbl *fecp = fep->fec.rtbl;
 
 	FW(fecp, ievent, int_events);
 }
@@ -440,18 +515,26 @@ static void ev_error(struct net_device *dev, u32 int_events)
 static int get_regs(struct net_device *dev, void *p, int *sizep)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
+	int size;
 
-	if (*sizep < sizeof(fec_t))
+	size = fep->fec.fec_id ? sizeof(struct mpc5121_fec) :
+				 sizeof(struct mpc8xx_fec);
+	if (*sizep < size)
 		return -EINVAL;
 
-	memcpy_fromio(p, fep->fec.fecp, sizeof(fec_t));
+	memcpy_fromio(p, fep->fec.fecp, size);
 
 	return 0;
 }
 
 static int get_regs_len(struct net_device *dev)
 {
-	return sizeof(fec_t);
+	struct fs_enet_private *fep = netdev_priv(dev);
+
+	if (fep->fec.fec_id == FS_ENET_MPC5121_FEC)
+		return sizeof(struct mpc5121_fec);
+	else
+		return sizeof(struct mpc8xx_fec);
 }
 
 static void tx_restart(struct net_device *dev)
@@ -481,4 +564,3 @@ const struct fs_ops fs_fec_ops = {
 	.allocate_bd		= allocate_bd,
 	.free_bd		= free_bd,
 };
-
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 96eba42..1ea10de 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -49,24 +49,33 @@
 
 #define FEC_MII_LOOPS	10000
 
+#define fec_reg_addr(_type, _reg) \
+	(fec->fec_##_reg = \
+		fec->fecp + (int)&((__typeof__(_type) *)NULL)->fec_##_reg)
+
+#define fec_reg_mpc8xx(_reg) \
+	fec_reg_addr(struct mpc8xx_fec, _reg)
+
+#define fec_reg_mpc5121(_reg) \
+	fec_reg_addr(struct mpc5121_fec, _reg)
+
 static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 {
 	struct fec_info* fec = bus->priv;
-	fec_t __iomem *fecp = fec->fecp;
 	int i, ret = -1;
 
-	BUG_ON((in_be32(&fecp->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0);
+	BUG_ON((in_be32(fec->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0);
 
 	/* Add PHY address to register command.  */
-	out_be32(&fecp->fec_mii_data, (phy_id << 23) | mk_mii_read(location));
+	out_be32(fec->fec_mii_data, (phy_id << 23) | mk_mii_read(location));
 
 	for (i = 0; i < FEC_MII_LOOPS; i++)
-		if ((in_be32(&fecp->fec_ievent) & FEC_ENET_MII) != 0)
+		if ((in_be32(fec->fec_ievent) & FEC_ENET_MII) != 0)
 			break;
 
 	if (i < FEC_MII_LOOPS) {
-		out_be32(&fecp->fec_ievent, FEC_ENET_MII);
-		ret = in_be32(&fecp->fec_mii_data) & 0xffff;
+		out_be32(fec->fec_ievent, FEC_ENET_MII);
+		ret = in_be32(fec->fec_mii_data) & 0xffff;
 	}
 
 	return ret;
@@ -75,21 +84,21 @@ static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location, u16 val)
 {
 	struct fec_info* fec = bus->priv;
-	fec_t __iomem *fecp = fec->fecp;
 	int i;
 
 	/* this must never happen */
-	BUG_ON((in_be32(&fecp->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0);
+	BUG_ON((in_be32(fec->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0);
 
 	/* Add PHY address to register command.  */
-	out_be32(&fecp->fec_mii_data, (phy_id << 23) | mk_mii_write(location, val));
+	out_be32(fec->fec_mii_data, (phy_id << 23) |
+				    mk_mii_write(location, val));
 
 	for (i = 0; i < FEC_MII_LOOPS; i++)
-		if ((in_be32(&fecp->fec_ievent) & FEC_ENET_MII) != 0)
+		if ((in_be32(fec->fec_ievent) & FEC_ENET_MII) != 0)
 			break;
 
 	if (i < FEC_MII_LOOPS)
-		out_be32(&fecp->fec_ievent, FEC_ENET_MII);
+		out_be32(fec->fec_ievent, FEC_ENET_MII);
 
 	return 0;
 
@@ -134,6 +143,20 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 	if (!fec->fecp)
 		goto out_fec;
 
+	if (of_device_is_compatible(ofdev->node, "fsl,mpc5121-fec-mdio")) {
+		fec_reg_mpc5121(ecntrl);
+		fec_reg_mpc5121(ievent);
+		fec_reg_mpc5121(mii_data);
+		fec_reg_mpc5121(mii_speed);
+		fec_reg_mpc5121(r_cntrl);
+	} else {
+		fec_reg_mpc8xx(ecntrl);
+		fec_reg_mpc8xx(ievent);
+		fec_reg_mpc8xx(mii_data);
+		fec_reg_mpc8xx(mii_speed);
+		fec_reg_mpc8xx(r_cntrl);
+	}
+
 	if (get_bus_freq) {
 		clock = get_bus_freq(ofdev->node);
 		if (!clock) {
@@ -158,11 +181,11 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 
 	fec->mii_speed = speed << 1;
 
-	setbits32(&fec->fecp->fec_r_cntrl, FEC_RCNTRL_MII_MODE);
-	setbits32(&fec->fecp->fec_ecntrl, FEC_ECNTRL_PINMUX |
-	                                  FEC_ECNTRL_ETHER_EN);
-	out_be32(&fec->fecp->fec_ievent, FEC_ENET_MII);
-	clrsetbits_be32(&fec->fecp->fec_mii_speed, 0x7E, fec->mii_speed);
+	setbits32(fec->fec_r_cntrl, FEC_RCNTRL_MII_MODE);
+	setbits32(fec->fec_ecntrl, FEC_ECNTRL_PINMUX |
+				   FEC_ECNTRL_ETHER_EN);
+	out_be32(fec->fec_ievent, FEC_ENET_MII);
+	clrsetbits_be32(fec->fec_mii_speed, 0x7E, fec->mii_speed);
 
 	new_bus->phy_mask = ~0;
 	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
diff --git a/drivers/net/fs_enet/mpc5121_fec.h b/drivers/net/fs_enet/mpc5121_fec.h
new file mode 100644
index 0000000..18d4fb3
--- /dev/null
+++ b/drivers/net/fs_enet/mpc5121_fec.h
@@ -0,0 +1,64 @@
+/*
+ * Copyright (C) 2007,2008 Freescale Semiconductor, Inc. All rights reserved.
+ *
+ * Author: John Rigby, <jrigby@freescale.com>
+ *
+ * Modified version of drivers/net/fec.h:
+ *
+ *	fec.h  --  Fast Ethernet Controller for Motorola ColdFire SoC
+ *		   processors.
+ *
+ *	(C) Copyright 2000-2005, Greg Ungerer (gerg@snapgear.com)
+ *	(C) Copyright 2000-2001, Lineo (www.lineo.com)
+ *
+ * This is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#ifndef MPC5121_FEC_H
+#define MPC5121_FEC_H
+
+struct mpc5121_fec {
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
+
+#define FS_ENET_MPC5121_FEC	0x1
+
+#endif /* MPC5121_FEC_H */
diff --git a/drivers/net/fs_enet/mpc8xx_fec.h b/drivers/net/fs_enet/mpc8xx_fec.h
new file mode 100644
index 0000000..aa78445
--- /dev/null
+++ b/drivers/net/fs_enet/mpc8xx_fec.h
@@ -0,0 +1,37 @@
+/* MPC860T Fast Ethernet Controller.  It isn't part of the CPM, but
+ * it fits within the address space.
+ */
+
+struct mpc8xx_fec {
+	uint	fec_addr_low;		/* lower 32 bits of station address */
+	ushort	fec_addr_high;		/* upper 16 bits of station address */
+	ushort	res1;			/* reserved			    */
+	uint	fec_hash_table_high;	/* upper 32-bits of hash table	    */
+	uint	fec_hash_table_low;	/* lower 32-bits of hash table	    */
+	uint	fec_r_des_start;	/* beginning of Rx descriptor ring  */
+	uint	fec_x_des_start;	/* beginning of Tx descriptor ring  */
+	uint	fec_r_buff_size;	/* Rx buffer size		    */
+	uint	res2[9];		/* reserved			    */
+	uint	fec_ecntrl;		/* ethernet control register	    */
+	uint	fec_ievent;		/* interrupt event register	    */
+	uint	fec_imask;		/* interrupt mask register	    */
+	uint	fec_ivec;		/* interrupt level and vector status */
+	uint	fec_r_des_active;	/* Rx ring updated flag		    */
+	uint	fec_x_des_active;	/* Tx ring updated flag		    */
+	uint	res3[10];		/* reserved			    */
+	uint	fec_mii_data;		/* MII data register		    */
+	uint	fec_mii_speed;		/* MII speed control register	    */
+	uint	res4[17];		/* reserved			    */
+	uint	fec_r_bound;		/* end of RAM (read-only)	    */
+	uint	fec_r_fstart;		/* Rx FIFO start address	    */
+	uint	res5[6];		/* reserved			    */
+	uint	fec_x_fstart;		/* Tx FIFO start address	    */
+	uint	res6[17];		/* reserved			    */
+	uint	fec_fun_code;		/* fec SDMA function code	    */
+	uint	res7[3];		/* reserved			    */
+	uint	fec_r_cntrl;		/* Rx control register		    */
+	uint	fec_r_hash;		/* Rx hash register		    */
+	uint	res8[14];		/* reserved			    */
+	uint	fec_x_cntrl;		/* Tx control register		    */
+	uint	res9[0x1e];		/* reserved			    */
+};
-- 
1.5.6.3

