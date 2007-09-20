From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 9/9] fs_enet: sparse fixes
Date: Thu, 20 Sep 2007 17:01:25 -0500
Message-ID: <20070920220125.GI28784@loki.buserror.net>
References: <20070920220043.GA28769@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:47864 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbXITWCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 18:02:06 -0400
Content-Disposition: inline
In-Reply-To: <20070920220043.GA28769@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mostly a bunch of __iomem annotations.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/fs_enet/fs_enet-main.c |   16 +++++-----
 drivers/net/fs_enet/fs_enet.h      |   30 +++++++++---------
 drivers/net/fs_enet/mac-fcc.c      |   60 ++++++++++++++++++++---------------
 drivers/net/fs_enet/mac-fec.c      |   34 ++++++++++----------
 drivers/net/fs_enet/mac-scc.c      |   37 +++++++++++-----------
 drivers/net/fs_enet/mii-fec.c      |    6 ++--
 6 files changed, 96 insertions(+), 87 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 281b7d7..876de8c 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -62,7 +62,7 @@ MODULE_DESCRIPTION("Freescale Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
-int fs_enet_debug = -1;		/* -1 == use FS_ENET_DEF_MSG_ENABLE as value */
+static int fs_enet_debug = -1; /* -1 == use FS_ENET_DEF_MSG_ENABLE as value */
 module_param(fs_enet_debug, int, 0);
 MODULE_PARM_DESC(fs_enet_debug,
 		 "Freescale bitmapped debugging message enable value");
@@ -88,7 +88,7 @@ static int fs_enet_rx_napi(struct net_device *dev, int *budget)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
-	cbd_t *bdp;
+	cbd_t __iomem *bdp;
 	struct sk_buff *skb, *skbn, *skbt;
 	int received = 0;
 	u16 pkt_len, sc;
@@ -240,7 +240,7 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
-	cbd_t *bdp;
+	cbd_t __iomem *bdp;
 	struct sk_buff *skb, *skbn, *skbt;
 	int received = 0;
 	u16 pkt_len, sc;
@@ -365,7 +365,7 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 static void fs_enet_tx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	cbd_t *bdp;
+	cbd_t __iomem *bdp;
 	struct sk_buff *skb;
 	int dirtyidx, do_wake, do_restart;
 	u16 sc;
@@ -513,7 +513,7 @@ fs_enet_interrupt(int irq, void *dev_id)
 void fs_init_bds(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	cbd_t *bdp;
+	cbd_t __iomem *bdp;
 	struct sk_buff *skb;
 	int i;
 
@@ -567,7 +567,7 @@ void fs_cleanup_bds(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	struct sk_buff *skb;
-	cbd_t *bdp;
+	cbd_t __iomem *bdp;
 	int i;
 
 	/*
@@ -608,7 +608,7 @@ void fs_cleanup_bds(struct net_device *dev)
 static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	cbd_t *bdp;
+	cbd_t __iomem *bdp;
 	int curidx;
 	u16 sc;
 	unsigned long flags;
@@ -1144,7 +1144,7 @@ static int fs_cleanup_instance(struct net_device *ndev)
 /**************************************************************************************/
 
 /* handy pointer to the immap */
-void *fs_enet_immap = NULL;
+void __iomem *fs_enet_immap = NULL;
 
 static int setup_immap(void)
 {
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index 14ebba8..4a8a101 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -15,7 +15,7 @@
 #include <asm/commproc.h>
 
 struct fec_info {
-	fec_t *fecp;
+	fec_t __iomem *fecp;
 	u32 mii_speed;
 };
 #endif
@@ -80,14 +80,14 @@ struct fs_enet_private {
 	const struct fs_ops *ops;
 	int rx_ring, tx_ring;
 	dma_addr_t ring_mem_addr;
-	void *ring_base;
+	void __iomem *ring_base;
 	struct sk_buff **rx_skbuff;
 	struct sk_buff **tx_skbuff;
-	cbd_t *rx_bd_base;	/* Address of Rx and Tx buffers.    */
-	cbd_t *tx_bd_base;
-	cbd_t *dirty_tx;	/* ring entries to be free()ed.     */
-	cbd_t *cur_rx;
-	cbd_t *cur_tx;
+	cbd_t __iomem *rx_bd_base;	/* Address of Rx and Tx buffers.    */
+	cbd_t __iomem *tx_bd_base;
+	cbd_t __iomem *dirty_tx;	/* ring entries to be free()ed.     */
+	cbd_t __iomem *cur_rx;
+	cbd_t __iomem *cur_tx;
 	int tx_free;
 	struct net_device_stats stats;
 	struct timer_list phy_timer_list;
@@ -112,23 +112,23 @@ struct fs_enet_private {
 	union {
 		struct {
 			int idx;		/* FEC1 = 0, FEC2 = 1  */
-			void *fecp;		/* hw registers        */
+			void __iomem *fecp;	/* hw registers        */
 			u32 hthi, htlo;		/* state for multicast */
 		} fec;
 
 		struct {
 			int idx;		/* FCC1-3 = 0-2	       */
-			void *fccp;		/* hw registers	       */
-			void *ep;		/* parameter ram       */
-			void *fcccp;		/* hw registers cont.  */
-			void *mem;		/* FCC DPRAM */
+			void __iomem *fccp;	/* hw registers	       */
+			void __iomem *ep;	/* parameter ram       */
+			void __iomem *fcccp;	/* hw registers cont.  */
+			void __iomem *mem;	/* FCC DPRAM */
 			u32 gaddrh, gaddrl;	/* group address       */
 		} fcc;
 
 		struct {
 			int idx;		/* FEC1 = 0, FEC2 = 1  */
-			void *sccp;		/* hw registers        */
-			void *ep;		/* parameter ram       */
+			void __iomem *sccp;	/* hw registers        */
+			void __iomem *ep;	/* parameter ram       */
 			u32 hthi, htlo;		/* state for multicast */
 		} scc;
 
@@ -199,7 +199,7 @@ extern const struct fs_ops fs_scc_ops;
 /*******************************************************************/
 
 /* handy pointer to the immap */
-extern void *fs_enet_immap;
+extern void __iomem *fs_enet_immap;
 
 /*******************************************************************/
 
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index 10e2a2b..fe3e4c3 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -81,8 +81,6 @@
 static inline int fcc_cr_cmd(struct fs_enet_private *fep, u32 op)
 {
 	const struct fs_platform_info *fpi = fep->fpi;
-	cpm2_map_t *immap = fs_enet_immap;
-	cpm_cpm2_t *cpmp = &immap->im_cpm;
 	int i;
 
 	W32(cpmp, cp_cpcr, fpi->cp_command | op | CPM_CR_FLG);
@@ -118,8 +116,8 @@ static int do_pd_setup(struct fs_enet_private *fep)
 	if (!fep->fcc.fcccp)
 		goto out_ep;
 
-	fep->fcc.mem = (void *)cpm_dpalloc(128, 8);
-	fpi->dpram_offset = (u32)cpm2_immr;
+	fep->fcc.mem = (void __iomem *)cpm2_immr;
+	fpi->dpram_offset = cpm_dpalloc(128, 8);
 	if (IS_ERR_VALUE(fpi->dpram_offset)) {
 		ret = fpi->dpram_offset;
 		goto out_fcccp;
@@ -212,7 +210,7 @@ static int allocate_bd(struct net_device *dev)
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
 
-	fep->ring_base = dma_alloc_coherent(fep->dev,
+	fep->ring_base = (void __iomem __force *)dma_alloc_coherent(fep->dev,
 					    (fpi->tx_ring + fpi->rx_ring) *
 					    sizeof(cbd_t), &fep->ring_mem_addr,
 					    GFP_KERNEL);
@@ -230,7 +228,7 @@ static void free_bd(struct net_device *dev)
 	if (fep->ring_base)
 		dma_free_coherent(fep->dev,
 			(fpi->tx_ring + fpi->rx_ring) * sizeof(cbd_t),
-			fep->ring_base, fep->ring_mem_addr);
+			(void __force *)fep->ring_base, fep->ring_mem_addr);
 }
 
 static void cleanup_data(struct net_device *dev)
@@ -241,7 +239,7 @@ static void cleanup_data(struct net_device *dev)
 static void set_promiscuous_mode(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t *fccp = fep->fcc.fccp;
+	fcc_t __iomem *fccp = fep->fcc.fccp;
 
 	S32(fccp, fcc_fpsmr, FCC_PSMR_PRO);
 }
@@ -249,7 +247,7 @@ static void set_promiscuous_mode(struct net_device *dev)
 static void set_multicast_start(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_enet_t *ep = fep->fcc.ep;
+	fcc_enet_t __iomem *ep = fep->fcc.ep;
 
 	W32(ep, fen_gaddrh, 0);
 	W32(ep, fen_gaddrl, 0);
@@ -258,7 +256,7 @@ static void set_multicast_start(struct net_device *dev)
 static void set_multicast_one(struct net_device *dev, const u8 *mac)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_enet_t *ep = fep->fcc.ep;
+	fcc_enet_t __iomem *ep = fep->fcc.ep;
 	u16 taddrh, taddrm, taddrl;
 
 	taddrh = ((u16)mac[5] << 8) | mac[4];
@@ -274,8 +272,8 @@ static void set_multicast_one(struct net_device *dev, const u8 *mac)
 static void set_multicast_finish(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t *fccp = fep->fcc.fccp;
-	fcc_enet_t *ep = fep->fcc.ep;
+	fcc_t __iomem *fccp = fep->fcc.fccp;
+	fcc_enet_t __iomem *ep = fep->fcc.ep;
 
 	/* clear promiscuous always */
 	C32(fccp, fcc_fpsmr, FCC_PSMR_PRO);
@@ -310,12 +308,14 @@ static void restart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
-	fcc_t *fccp = fep->fcc.fccp;
-	fcc_c_t *fcccp = fep->fcc.fcccp;
-	fcc_enet_t *ep = fep->fcc.ep;
+	fcc_t __iomem *fccp = fep->fcc.fccp;
+	fcc_c_t __iomem *fcccp = fep->fcc.fcccp;
+	fcc_enet_t __iomem *ep = fep->fcc.ep;
 	dma_addr_t rx_bd_base_phys, tx_bd_base_phys;
 	u16 paddrh, paddrm, paddrl;
+#ifndef CONFIG_PPC_CPM_NEW_BINDING
 	u16 mem_addr;
+#endif
 	const unsigned char *mac;
 	int i;
 
@@ -347,14 +347,22 @@ static void restart(struct net_device *dev)
 	 * this area.
 	 */
 
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+	W16(ep, fen_genfcc.fcc_riptr, fpi->dpram_offset);
+	W16(ep, fen_genfcc.fcc_tiptr, fpi->dpram_offset + 32);
+
+	W16(ep, fen_padptr, fpi->dpram_offset + 64);
+#else
 	mem_addr = (u32) fep->fcc.mem;	/* de-fixup dpram offset */
 
 	W16(ep, fen_genfcc.fcc_riptr, (mem_addr & 0xffff));
 	W16(ep, fen_genfcc.fcc_tiptr, ((mem_addr + 32) & 0xffff));
+
 	W16(ep, fen_padptr, mem_addr + 64);
+#endif
 
 	/* fill with special symbol...  */
-	memset(fep->fcc.mem + fpi->dpram_offset + 64, 0x88, 32);
+	memset_io(fep->fcc.mem + fpi->dpram_offset + 64, 0x88, 32);
 
 	W32(ep, fen_genfcc.fcc_rbptr, 0);
 	W32(ep, fen_genfcc.fcc_tbptr, 0);
@@ -470,7 +478,7 @@ static void restart(struct net_device *dev)
 static void stop(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t *fccp = fep->fcc.fccp;
+	fcc_t __iomem *fccp = fep->fcc.fccp;
 
 	/* stop ethernet */
 	C32(fccp, fcc_gfmr, FCC_GFMR_ENR | FCC_GFMR_ENT);
@@ -497,7 +505,7 @@ static void post_free_irq(struct net_device *dev, int irq)
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t *fccp = fep->fcc.fccp;
+	fcc_t __iomem *fccp = fep->fcc.fccp;
 
 	W16(fccp, fcc_fcce, FCC_NAPI_RX_EVENT_MSK);
 }
@@ -505,7 +513,7 @@ static void napi_clear_rx_event(struct net_device *dev)
 static void napi_enable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t *fccp = fep->fcc.fccp;
+	fcc_t __iomem *fccp = fep->fcc.fccp;
 
 	S16(fccp, fcc_fccm, FCC_NAPI_RX_EVENT_MSK);
 }
@@ -513,7 +521,7 @@ static void napi_enable_rx(struct net_device *dev)
 static void napi_disable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t *fccp = fep->fcc.fccp;
+	fcc_t __iomem *fccp = fep->fcc.fccp;
 
 	C16(fccp, fcc_fccm, FCC_NAPI_RX_EVENT_MSK);
 }
@@ -526,7 +534,7 @@ static void rx_bd_done(struct net_device *dev)
 static void tx_kickstart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t *fccp = fep->fcc.fccp;
+	fcc_t __iomem *fccp = fep->fcc.fccp;
 
 	S16(fccp, fcc_ftodr, 0x8000);
 }
@@ -534,7 +542,7 @@ static void tx_kickstart(struct net_device *dev)
 static u32 get_int_events(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t *fccp = fep->fcc.fccp;
+	fcc_t __iomem *fccp = fep->fcc.fccp;
 
 	return (u32)R16(fccp, fcc_fcce);
 }
@@ -542,7 +550,7 @@ static u32 get_int_events(struct net_device *dev)
 static void clear_int_events(struct net_device *dev, u32 int_events)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t *fccp = fep->fcc.fccp;
+	fcc_t __iomem *fccp = fep->fcc.fccp;
 
 	W16(fccp, fcc_fcce, int_events & 0xffff);
 }
@@ -553,7 +561,7 @@ static void ev_error(struct net_device *dev, u32 int_events)
 	       ": %s FS_ENET ERROR(s) 0x%x\n", dev->name, int_events);
 }
 
-int get_regs(struct net_device *dev, void *p, int *sizep)
+static int get_regs(struct net_device *dev, void *p, int *sizep)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 
@@ -570,7 +578,7 @@ int get_regs(struct net_device *dev, void *p, int *sizep)
 	return 0;
 }
 
-int get_regs_len(struct net_device *dev)
+static int get_regs_len(struct net_device *dev)
 {
 	return sizeof(fcc_t) + sizeof(fcc_enet_t) + 1;
 }
@@ -583,10 +591,10 @@ int get_regs_len(struct net_device *dev)
  * CPM37, we must disable and then re-enable the transmitter
  * following a Late Collision, Underrun, or Retry Limit error.
  */
-void tx_restart(struct net_device *dev)
+static void tx_restart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t *fccp = fep->fcc.fccp;
+	fcc_t __iomem *fccp = fep->fcc.fccp;
 
 	C32(fccp, fcc_gfmr, FCC_GFMR_ENT);
 	udelay(10);
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 9a02312..4af6858 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -83,7 +83,7 @@
  */
 #define FEC_RESET_DELAY		50
 
-static int whack_reset(fec_t * fecp)
+static int whack_reset(fec_t __iomem *fecp)
 {
 	int i;
 
@@ -159,7 +159,7 @@ static int allocate_bd(struct net_device *dev)
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
 	
-	fep->ring_base = dma_alloc_coherent(fep->dev,
+	fep->ring_base = (void __force __iomem *)dma_alloc_coherent(fep->dev,
 					    (fpi->tx_ring + fpi->rx_ring) *
 					    sizeof(cbd_t), &fep->ring_mem_addr,
 					    GFP_KERNEL);
@@ -177,7 +177,7 @@ static void free_bd(struct net_device *dev)
 	if(fep->ring_base)
 		dma_free_coherent(fep->dev, (fpi->tx_ring + fpi->rx_ring)
 					* sizeof(cbd_t),
-					fep->ring_base,
+					(void __force *)fep->ring_base,
 					fep->ring_mem_addr);
 }
 
@@ -189,7 +189,7 @@ static void cleanup_data(struct net_device *dev)
 static void set_promiscuous_mode(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t *fecp = fep->fec.fecp;
+	fec_t __iomem *fecp = fep->fec.fecp;
 
 	FS(fecp, r_cntrl, FEC_RCNTRL_PROM);
 }
@@ -237,7 +237,7 @@ static void set_multicast_one(struct net_device *dev, const u8 *mac)
 static void set_multicast_finish(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t *fecp = fep->fec.fecp;
+	fec_t __iomem *fecp = fep->fec.fecp;
 
 	/* if all multi or too many multicasts; just enable all */
 	if ((dev->flags & IFF_ALLMULTI) != 0 ||
@@ -271,7 +271,7 @@ static void restart(struct net_device *dev)
 	u32 cptr;
 #endif
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t *fecp = fep->fec.fecp;
+	fec_t __iomem *fecp = fep->fec.fecp;
 	const struct fs_platform_info *fpi = fep->fpi;
 	dma_addr_t rx_bd_base_phys, tx_bd_base_phys;
 	int r;
@@ -399,7 +399,7 @@ static void stop(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
-	fec_t *fecp = fep->fec.fecp;
+	fec_t __iomem *fecp = fep->fec.fecp;
 
 	struct fec_info* feci= fep->phydev->bus->priv;
 
@@ -461,7 +461,7 @@ static void post_free_irq(struct net_device *dev, int irq)
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t *fecp = fep->fec.fecp;
+	fec_t __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, ievent, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -469,7 +469,7 @@ static void napi_clear_rx_event(struct net_device *dev)
 static void napi_enable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t *fecp = fep->fec.fecp;
+	fec_t __iomem *fecp = fep->fec.fecp;
 
 	FS(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -477,7 +477,7 @@ static void napi_enable_rx(struct net_device *dev)
 static void napi_disable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t *fecp = fep->fec.fecp;
+	fec_t __iomem *fecp = fep->fec.fecp;
 
 	FC(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -485,7 +485,7 @@ static void napi_disable_rx(struct net_device *dev)
 static void rx_bd_done(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t *fecp = fep->fec.fecp;
+	fec_t __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, r_des_active, 0x01000000);
 }
@@ -493,7 +493,7 @@ static void rx_bd_done(struct net_device *dev)
 static void tx_kickstart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t *fecp = fep->fec.fecp;
+	fec_t __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, x_des_active, 0x01000000);
 }
@@ -501,7 +501,7 @@ static void tx_kickstart(struct net_device *dev)
 static u32 get_int_events(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t *fecp = fep->fec.fecp;
+	fec_t __iomem *fecp = fep->fec.fecp;
 
 	return FR(fecp, ievent) & FR(fecp, imask);
 }
@@ -509,7 +509,7 @@ static u32 get_int_events(struct net_device *dev)
 static void clear_int_events(struct net_device *dev, u32 int_events)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t *fecp = fep->fec.fecp;
+	fec_t __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, ievent, int_events);
 }
@@ -520,7 +520,7 @@ static void ev_error(struct net_device *dev, u32 int_events)
 	       ": %s FEC ERROR(s) 0x%x\n", dev->name, int_events);
 }
 
-int get_regs(struct net_device *dev, void *p, int *sizep)
+static int get_regs(struct net_device *dev, void *p, int *sizep)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 
@@ -532,12 +532,12 @@ int get_regs(struct net_device *dev, void *p, int *sizep)
 	return 0;
 }
 
-int get_regs_len(struct net_device *dev)
+static int get_regs_len(struct net_device *dev)
 {
 	return sizeof(fec_t);
 }
 
-void tx_restart(struct net_device *dev)
+static void tx_restart(struct net_device *dev)
 {
 	/* nothing */
 }
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index 7352c61..880471f 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -191,7 +191,8 @@ static int allocate_bd(struct net_device *dev)
 	if (IS_ERR_VALUE(fep->ring_mem_addr))
 		return -ENOMEM;
 
-	fep->ring_base = cpm_dpram_addr(fep->ring_mem_addr);
+	fep->ring_base = (void __iomem __force*)
+		cpm_dpram_addr(fep->ring_mem_addr);
 
 	return 0;
 }
@@ -212,7 +213,7 @@ static void cleanup_data(struct net_device *dev)
 static void set_promiscuous_mode(struct net_device *dev)
 {				
 	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t *sccp = fep->scc.sccp;
+	scc_t __iomem *sccp = fep->scc.sccp;
 
 	S16(sccp, scc_psmr, SCC_PSMR_PRO);
 }
@@ -220,7 +221,7 @@ static void set_promiscuous_mode(struct net_device *dev)
 static void set_multicast_start(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_enet_t *ep = fep->scc.ep;
+	scc_enet_t __iomem *ep = fep->scc.ep;
 
 	W16(ep, sen_gaddr1, 0);
 	W16(ep, sen_gaddr2, 0);
@@ -231,7 +232,7 @@ static void set_multicast_start(struct net_device *dev)
 static void set_multicast_one(struct net_device *dev, const u8 * mac)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_enet_t *ep = fep->scc.ep;
+	scc_enet_t __iomem *ep = fep->scc.ep;
 	u16 taddrh, taddrm, taddrl;
 
 	taddrh = ((u16) mac[5] << 8) | mac[4];
@@ -247,8 +248,8 @@ static void set_multicast_one(struct net_device *dev, const u8 * mac)
 static void set_multicast_finish(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t *sccp = fep->scc.sccp;
-	scc_enet_t *ep = fep->scc.ep;
+	scc_t __iomem *sccp = fep->scc.sccp;
+	scc_enet_t __iomem *ep = fep->scc.ep;
 
 	/* clear promiscuous always */
 	C16(sccp, scc_psmr, SCC_PSMR_PRO);
@@ -285,8 +286,8 @@ static void set_multicast_list(struct net_device *dev)
 static void restart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t *sccp = fep->scc.sccp;
-	scc_enet_t *ep = fep->scc.ep;
+	scc_t __iomem *sccp = fep->scc.sccp;
+	scc_enet_t __iomem *ep = fep->scc.ep;
 	const struct fs_platform_info *fpi = fep->fpi;
 	u16 paddrh, paddrm, paddrl;
 	const unsigned char *mac;
@@ -296,7 +297,7 @@ static void restart(struct net_device *dev)
 
 	/* clear everything (slow & steady does it) */
 	for (i = 0; i < sizeof(*ep); i++)
-		__fs_out8((char *)ep + i, 0);
+		__fs_out8((u8 __iomem *)ep + i, 0);
 
 	/* point to bds */
 	W16(ep, sen_genscc.scc_rbase, fep->ring_mem_addr);
@@ -397,7 +398,7 @@ static void restart(struct net_device *dev)
 static void stop(struct net_device *dev)	
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t *sccp = fep->scc.sccp;
+	scc_t __iomem *sccp = fep->scc.sccp;
 	int i;
 
 	for (i = 0; (R16(sccp, scc_sccm) == 0) && i < SCC_RESET_DELAY; i++)
@@ -441,7 +442,7 @@ static void post_free_irq(struct net_device *dev, int irq)
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t *sccp = fep->scc.sccp;
+	scc_t __iomem *sccp = fep->scc.sccp;
 
 	W16(sccp, scc_scce, SCC_NAPI_RX_EVENT_MSK);
 }
@@ -449,7 +450,7 @@ static void napi_clear_rx_event(struct net_device *dev)
 static void napi_enable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t *sccp = fep->scc.sccp;
+	scc_t __iomem *sccp = fep->scc.sccp;
 
 	S16(sccp, scc_sccm, SCC_NAPI_RX_EVENT_MSK);
 }
@@ -457,7 +458,7 @@ static void napi_enable_rx(struct net_device *dev)
 static void napi_disable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t *sccp = fep->scc.sccp;
+	scc_t __iomem *sccp = fep->scc.sccp;
 
 	C16(sccp, scc_sccm, SCC_NAPI_RX_EVENT_MSK);
 }
@@ -475,7 +476,7 @@ static void tx_kickstart(struct net_device *dev)
 static u32 get_int_events(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t *sccp = fep->scc.sccp;
+	scc_t __iomem *sccp = fep->scc.sccp;
 
 	return (u32) R16(sccp, scc_scce);
 }
@@ -483,7 +484,7 @@ static u32 get_int_events(struct net_device *dev)
 static void clear_int_events(struct net_device *dev, u32 int_events)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t *sccp = fep->scc.sccp;
+	scc_t __iomem *sccp = fep->scc.sccp;
 
 	W16(sccp, scc_scce, int_events & 0xffff);
 }
@@ -498,20 +499,20 @@ static int get_regs(struct net_device *dev, void *p, int *sizep)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 
-	if (*sizep < sizeof(scc_t) + sizeof(scc_enet_t))
+	if (*sizep < sizeof(scc_t) + sizeof(scc_enet_t __iomem *))
 		return -EINVAL;
 
 	memcpy_fromio(p, fep->scc.sccp, sizeof(scc_t));
 	p = (char *)p + sizeof(scc_t);
 
-	memcpy_fromio(p, fep->scc.ep, sizeof(scc_enet_t));
+	memcpy_fromio(p, fep->scc.ep, sizeof(scc_enet_t __iomem *));
 
 	return 0;
 }
 
 static int get_regs_len(struct net_device *dev)
 {
-	return sizeof(scc_t) + sizeof(scc_enet_t);
+	return sizeof(scc_t) + sizeof(scc_enet_t __iomem *);
 }
 
 static void tx_restart(struct net_device *dev)
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index f91c38d..c46ca8f 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -70,7 +70,7 @@ static int match_has_phy (struct device *dev, void* data)
 static int fs_mii_fec_init(struct fec_info* fec, struct fs_mii_fec_platform_info *fmpi)
 {
 	struct resource *r;
-	fec_t *fecp;
+	fec_t __iomem *fecp;
 	char* name = "fsl-cpm-fec";
 
 	/* we need fec in order to be useful */
@@ -100,7 +100,7 @@ static int fs_mii_fec_init(struct fec_info* fec, struct fs_mii_fec_platform_info
 static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 {
 	struct fec_info* fec = bus->priv;
-	fec_t *fecp = fec->fecp;
+	fec_t __iomem *fecp = fec->fecp;
 	int i, ret = -1;
 
 	if ((in_be32(&fecp->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0)
@@ -124,7 +124,7 @@ static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location, u16 val)
 {
 	struct fec_info* fec = bus->priv;
-	fec_t *fecp = fec->fecp;
+	fec_t __iomem *fecp = fec->fecp;
 	int i;
 
 	/* this must never happen */
-- 
1.5.3.1
