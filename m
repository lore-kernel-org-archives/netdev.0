From: <ganesanr@broadcom.com>
Subject: [PATCH 3/3] Staging: Move all the netdev under single parent device per controller
Date: Wed, 18 Jun 2014 18:43:58 +0530
Message-ID: <eed3de47f0c4955408a3f9913d22da4730a259c9.1403096668.git.ganesanr@broadcom.com>
References: <cover.1403096668.git.ganesanr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ganesan Ramalingam <ganesanr@broadcom.com>,
	<jchandra@broadcom.com>, <linux-mips@linux-mips.org>,
	<ralf@linux-mips.org>, <netdev@vger.kernel.org>
To: <kristina.martsenko@gmail.com>, <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:5057 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966138AbaFRMfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 08:35:43 -0400
In-Reply-To: <cover.1403096668.git.ganesanr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesan Ramalingam <ganesanr@broadcom.com>

XLR and XLS has one and two network controller respectively, each controller
has 4 gmac devices. So changing the per device initialization to per
controller, all devices of a controller are linked to single parent device.

Signed-off-by: Ganesan Ramalingam <ganesanr@broadcom.com>
---
 drivers/staging/netlogic/TODO           |    1 -
 drivers/staging/netlogic/platform_net.c |  213 ++++++++++++----------
 drivers/staging/netlogic/platform_net.h |    7 +-
 drivers/staging/netlogic/xlr_net.c      |  291 +++++++++++++++++--------------
 drivers/staging/netlogic/xlr_net.h      |    8 +-
 5 files changed, 287 insertions(+), 233 deletions(-)

diff --git a/drivers/staging/netlogic/TODO b/drivers/staging/netlogic/TODO
index 08e6d52..8f172b0 100644
--- a/drivers/staging/netlogic/TODO
+++ b/drivers/staging/netlogic/TODO
@@ -1,6 +1,5 @@
 * Implementing 64bit stat counter in software
 * All memory allocation should be changed to DMA allocations
-* All the netdev should be linked to single pdev as parent
 * Changing comments in to linux standred format
 
 Please send patches
diff --git a/drivers/staging/netlogic/platform_net.c b/drivers/staging/netlogic/platform_net.c
index 61f20e1..080e09f 100644
--- a/drivers/staging/netlogic/platform_net.c
+++ b/drivers/staging/netlogic/platform_net.c
@@ -72,116 +72,125 @@ static u32 xlr_gmac_irqs[] = { PIC_GMAC_0_IRQ, PIC_GMAC_1_IRQ,
 	PIC_GMAC_6_IRQ, PIC_GMAC_7_IRQ
 };
 
-static struct xlr_net_data ndata[MAX_NUM_GMAC];
-static struct resource xlr_net_res[8][2];
-static struct platform_device xlr_net_dev[8];
-static u32 __iomem *gmac0_addr;
+static struct resource xlr_net0_res[8];
+static struct resource xlr_net1_res[8];
 static u32 __iomem *gmac4_addr;
 static u32 __iomem *gpio_addr;
 
-static void config_mac(struct xlr_net_data *nd, int phy, u32 __iomem *serdes,
-		u32 __iomem *pcs, int rfr, int tx, int *bkt_size,
-		struct xlr_fmn_info *gmac_fmn_info, int phy_addr)
+static void xlr_resource_init(struct resource *res, int offset, int irq)
 {
-	nd->cpu_mask = nlm_current_node()->coremask;
-	nd->phy_interface = phy;
-	nd->rfr_station = rfr;
-	nd->tx_stnid = tx;
-	nd->mii_addr = gmac0_addr;
-	nd->serdes_addr = serdes;
-	nd->pcs_addr = pcs;
-	nd->gpio_addr = gpio_addr;
-
-	nd->bucket_size = bkt_size;
-	nd->gmac_fmn_info = gmac_fmn_info;
-	nd->phy_addr = phy_addr;
+	res->name = "gmac";
+
+	res->start = CPHYSADDR(nlm_mmio_base(offset));
+	res->end = res->start + 0xfff;
+	res->flags = IORESOURCE_MEM;
+
+	res++;
+	res->name = "gmac";
+	res->start = res->end = irq;
+	res->flags = IORESOURCE_IRQ;
 }
 
-static void net_device_init(int id, struct resource *res, int offset, int irq)
+static struct platform_device *gmac_controller2_init(void *gmac0_addr)
 {
-	res[0].name = "gmac";
-	res[0].start = CPHYSADDR(nlm_mmio_base(offset));
-	res[0].end = res[0].start + 0xfff;
-	res[0].flags = IORESOURCE_MEM;
-
-	res[1].name = "gmac";
-	res[1].start = irq;
-	res[1].end = irq;
-	res[1].flags = IORESOURCE_IRQ;
-
-	xlr_net_dev[id].name = "xlr-net";
-	xlr_net_dev[id].id = id;
-	xlr_net_dev[id].num_resources = 2;
-	xlr_net_dev[id].resource = res;
-	xlr_net_dev[id].dev.platform_data = &ndata[id];
+	int mac;
+	static struct xlr_net_data ndata1 = {
+		.phy_interface	= PHY_INTERFACE_MODE_SGMII,
+		.rfr_station	= FMN_STNID_GMAC1_FR_0,
+		.bucket_size	= xlr_board_fmn_config.bucket_size,
+		.gmac_fmn_info	= &xlr_board_fmn_config.gmac[1],
+	};
+
+	static struct platform_device xlr_net_dev1 = {
+		.name		= "xlr-net",
+		.id		= 1,
+		.dev.platform_data = &ndata1,
+	};
+
+	gmac4_addr = ioremap(CPHYSADDR(
+		nlm_mmio_base(NETLOGIC_IO_GMAC_4_OFFSET)), 0xfff);
+	ndata1.serdes_addr = gmac4_addr;
+	ndata1.pcs_addr	= gmac4_addr;
+	ndata1.mii_addr	= gmac0_addr;
+	ndata1.gpio_addr = gpio_addr;
+	ndata1.cpu_mask = nlm_current_node()->coremask;
+
+	xlr_net_dev1.resource = xlr_net1_res;
+
+	for (mac = 0; mac < 4; mac++) {
+		ndata1.tx_stnid[mac] = FMN_STNID_GMAC1_TX0 + mac;
+		ndata1.phy_addr[mac] = mac + 4 + 0x10;
+
+		xlr_resource_init(&xlr_net1_res[mac * 2],
+				xlr_gmac_offsets[mac + 4],
+				xlr_gmac_irqs[mac + 4]);
+	}
+	xlr_net_dev1.num_resources = 8;
+
+	return &xlr_net_dev1;
 }
 
 static void xls_gmac_init(void)
 {
 	int mac;
+	struct platform_device *xlr_net_dev1;
+	void __iomem *gmac0_addr = ioremap(CPHYSADDR(
+		nlm_mmio_base(NETLOGIC_IO_GMAC_0_OFFSET)), 0xfff);
 
-	gmac4_addr = ioremap(CPHYSADDR(
-		nlm_mmio_base(NETLOGIC_IO_GMAC_4_OFFSET)), 0xfff);
-	/* Passing GPIO base for serdes init. Only needed on sgmii ports*/
+	static struct xlr_net_data ndata0 = {
+		.rfr_station	= FMN_STNID_GMACRFR_0,
+		.bucket_size	= xlr_board_fmn_config.bucket_size,
+		.gmac_fmn_info	= &xlr_board_fmn_config.gmac[0],
+	};
+
+	static struct platform_device xlr_net_dev0 = {
+		.name		= "xlr-net",
+		.id		= 0,
+	};
+	xlr_net_dev0.dev.platform_data = &ndata0;
+	ndata0.serdes_addr = gmac0_addr;
+	ndata0.pcs_addr	= gmac0_addr;
+	ndata0.mii_addr	= gmac0_addr;
+
+	/* Passing GPIO base for serdes init. Only needed on sgmii ports */
 	gpio_addr = ioremap(CPHYSADDR(
 		nlm_mmio_base(NETLOGIC_IO_GPIO_OFFSET)), 0xfff);
+	ndata0.gpio_addr = gpio_addr;
+	ndata0.cpu_mask = nlm_current_node()->coremask;
+
+	xlr_net_dev0.resource = xlr_net0_res;
 
 	switch (nlm_prom_info.board_major_version) {
 	case 12:
 		/* first block RGMII or XAUI, use RGMII */
-		config_mac(&ndata[0],
-			PHY_INTERFACE_MODE_RGMII,
-			gmac0_addr,	/* serdes */
-			gmac0_addr,	/* pcs */
-			FMN_STNID_GMACRFR_0,
-			FMN_STNID_GMAC0_TX0,
-			xlr_board_fmn_config.bucket_size,
-			&xlr_board_fmn_config.gmac[0],
-			0);
-
-		net_device_init(0, xlr_net_res[0], xlr_gmac_offsets[0],
+		ndata0.phy_interface = PHY_INTERFACE_MODE_RGMII,
+		ndata0.tx_stnid[0] = FMN_STNID_GMAC0_TX0;
+		ndata0.phy_addr[0] = 0;
+
+		xlr_net_dev0.num_resources = 2;
+
+		xlr_resource_init(&xlr_net0_res[0], xlr_gmac_offsets[0],
 				xlr_gmac_irqs[0]);
-		platform_device_register(&xlr_net_dev[0]);
+		platform_device_register(&xlr_net_dev0);
 
 		/* second block is XAUI, not supported yet */
 		break;
 	default:
 		/* default XLS config, all ports SGMII */
+		ndata0.phy_interface = PHY_INTERFACE_MODE_SGMII;
 		for (mac = 0; mac < 4; mac++) {
-			config_mac(&ndata[mac],
-				PHY_INTERFACE_MODE_SGMII,
-				gmac0_addr,	/* serdes */
-				gmac0_addr,	/* pcs */
-				FMN_STNID_GMACRFR_0,
-				FMN_STNID_GMAC0_TX0 + mac,
-				xlr_board_fmn_config.bucket_size,
-				&xlr_board_fmn_config.gmac[0],
-				/* PHY address according to chip/board */
-				mac + 0x10);
-
-			net_device_init(mac, xlr_net_res[mac],
-					xlr_gmac_offsets[mac],
-					xlr_gmac_irqs[mac]);
-			platform_device_register(&xlr_net_dev[mac]);
-		}
+			ndata0.tx_stnid[mac] = FMN_STNID_GMAC0_TX0 + mac;
+			ndata0.phy_addr[mac] = mac + 0x10;
 
-		for (mac = 4; mac < MAX_NUM_XLS_GMAC; mac++) {
-			config_mac(&ndata[mac],
-				PHY_INTERFACE_MODE_SGMII,
-				gmac4_addr,	/* serdes */
-				gmac4_addr,	/* pcs */
-				FMN_STNID_GMAC1_FR_0,
-				FMN_STNID_GMAC1_TX0 + mac - 4,
-				xlr_board_fmn_config.bucket_size,
-				&xlr_board_fmn_config.gmac[1],
-				/* PHY address according to chip/board */
-				mac + 0x10);
-
-			net_device_init(mac, xlr_net_res[mac],
+			xlr_resource_init(&xlr_net0_res[mac * 2],
 					xlr_gmac_offsets[mac],
 					xlr_gmac_irqs[mac]);
-			platform_device_register(&xlr_net_dev[mac]);
 		}
+		xlr_net_dev0.num_resources = 8;
+		platform_device_register(&xlr_net_dev0);
+
+		xlr_net_dev1 = gmac_controller2_init(gmac0_addr);
+		platform_device_register(xlr_net_dev1);
 	}
 }
 
@@ -190,28 +199,41 @@ static void xlr_gmac_init(void)
 	int mac;
 
 	/* assume all GMACs for now */
+	static struct xlr_net_data ndata0 = {
+		.phy_interface	= PHY_INTERFACE_MODE_RGMII,
+		.serdes_addr	= NULL,
+		.pcs_addr	= NULL,
+		.rfr_station	= FMN_STNID_GMACRFR_0,
+		.bucket_size	= xlr_board_fmn_config.bucket_size,
+		.gmac_fmn_info	= &xlr_board_fmn_config.gmac[0],
+		.gpio_addr	= NULL,
+	};
+
+
+	static struct platform_device xlr_net_dev0 = {
+		.name		= "xlr-net",
+		.id		= 0,
+		.dev.platform_data = &ndata0,
+	};
+	ndata0.mii_addr = ioremap(CPHYSADDR(
+		nlm_mmio_base(NETLOGIC_IO_GMAC_0_OFFSET)), 0xfff);
+
+	ndata0.cpu_mask = nlm_current_node()->coremask;
+
 	for (mac = 0; mac < MAX_NUM_XLR_GMAC; mac++) {
-		config_mac(&ndata[mac],
-			PHY_INTERFACE_MODE_RGMII,
-			0,
-			0,
-			FMN_STNID_GMACRFR_0,
-			FMN_STNID_GMAC0_TX0,
-			xlr_board_fmn_config.bucket_size,
-			&xlr_board_fmn_config.gmac[0],
-			mac);
-
-		net_device_init(mac, xlr_net_res[mac], xlr_gmac_offsets[mac],
+		ndata0.tx_stnid[mac] = FMN_STNID_GMAC0_TX0 + mac;
+		ndata0.phy_addr[mac] = mac;
+		xlr_resource_init(&xlr_net0_res[mac * 2], xlr_gmac_offsets[mac],
 				xlr_gmac_irqs[mac]);
-		platform_device_register(&xlr_net_dev[mac]);
 	}
+	xlr_net_dev0.num_resources = 8;
+	xlr_net_dev0.resource = xlr_net0_res;
+
+	platform_device_register(&xlr_net_dev0);
 }
 
 static int __init xlr_net_init(void)
 {
-	gmac0_addr = ioremap(CPHYSADDR(
-		nlm_mmio_base(NETLOGIC_IO_GMAC_0_OFFSET)), 0xfff);
-
 	if (nlm_chip_is_xls())
 		xls_gmac_init();
 	else
@@ -221,3 +243,4 @@ static int __init xlr_net_init(void)
 }
 
 arch_initcall(xlr_net_init);
+
diff --git a/drivers/staging/netlogic/platform_net.h b/drivers/staging/netlogic/platform_net.h
index 29deeea..e1b27f6 100644
--- a/drivers/staging/netlogic/platform_net.h
+++ b/drivers/staging/netlogic/platform_net.h
@@ -31,6 +31,9 @@
  * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
  * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
+
+#define PORTS_PER_CONTROLLER		4
+
 struct xlr_net_data {
 	int cpu_mask;
 	u32 __iomem *mii_addr;
@@ -39,8 +42,8 @@ struct xlr_net_data {
 	u32 __iomem *gpio_addr;
 	int phy_interface;
 	int rfr_station;
-	int tx_stnid;
+	int tx_stnid[PORTS_PER_CONTROLLER];
 	int *bucket_size;
-	int phy_addr;
+	int phy_addr[PORTS_PER_CONTROLLER];
 	struct xlr_fmn_info *gmac_fmn_info;
 };
diff --git a/drivers/staging/netlogic/xlr_net.c b/drivers/staging/netlogic/xlr_net.c
index 6d7a6a7..ee0a3e6 100644
--- a/drivers/staging/netlogic/xlr_net.c
+++ b/drivers/staging/netlogic/xlr_net.c
@@ -78,39 +78,7 @@ static inline void xlr_reg_update(u32 *base_addr,
 	xlr_nae_wreg(base_addr, off, (tmp & ~mask) | (val & mask));
 }
 
-/*
- * Table of net_device pointers indexed by port, this will be used to
- * lookup the net_device corresponding to a port by the message ring handler.
- *
- * Maximum ports in XLR/XLS is 8(8 GMAC on XLS, 4 GMAC + 2 XGMAC on XLR)
- */
-static struct net_device *mac_to_ndev[8];
-
-static inline struct sk_buff *mac_get_skb_back_ptr(void *addr)
-{
-	struct sk_buff **back_ptr;
-
-	/*
-	 * this function should be used only for newly allocated packets.
-	 * It assumes the first cacheline is for the back pointer related
-	 * book keeping info.
-	 */
-	back_ptr = (struct sk_buff **)(addr - MAC_SKB_BACK_PTR_SIZE);
-	return *back_ptr;
-}
-
-static inline void mac_put_skb_back_ptr(struct sk_buff *skb)
-{
-	struct sk_buff **back_ptr = (struct sk_buff **)skb->data;
-
-	/*
-	 * this function should be used only for newly allocated packets.
-	 * It assumes the first cacheline is for the back pointer related
-	 * book keeping info.
-	 */
-	skb_reserve(skb, MAC_SKB_BACK_PTR_SIZE);
-	*back_ptr = skb;
-}
+#define MAC_SKB_BACK_PTR_SIZE SMP_CACHE_BYTES
 
 static int send_to_rfr_fifo(struct xlr_net_priv *priv, void *addr)
 {
@@ -136,9 +104,11 @@ static int send_to_rfr_fifo(struct xlr_net_priv *priv, void *addr)
 	return ret;
 }
 
-static inline struct sk_buff *xlr_alloc_skb(void)
+static inline unsigned char *xlr_alloc_skb(void)
 {
 	struct sk_buff *skb;
+	int buf_len = sizeof(struct sk_buff *);
+	unsigned char *skb_data;
 
 	/* skb->data is cache aligned */
 	skb = alloc_skb(XLR_RX_BUF_SIZE, GFP_ATOMIC);
@@ -146,31 +116,41 @@ static inline struct sk_buff *xlr_alloc_skb(void)
 		pr_err("SKB allocation failed\n");
 		return NULL;
 	}
-	mac_put_skb_back_ptr(skb);
-	return skb;
+	skb_data = skb->data;
+	skb_put(skb, MAC_SKB_BACK_PTR_SIZE);
+	skb_pull(skb, MAC_SKB_BACK_PTR_SIZE);
+	memcpy(skb_data, &skb, buf_len);
+
+	return skb->data;
 }
 
 static void xlr_net_fmn_handler(int bkt, int src_stnid, int size,
 		int code, struct nlm_fmn_msg *msg, void *arg)
 {
-	struct sk_buff *skb, *skb_new = NULL;
+	struct sk_buff *skb;
+	void *skb_data = NULL;
 	struct net_device *ndev;
 	struct xlr_net_priv *priv;
-	u64 length, port;
-	void *addr;
+	u32 port, length;
+	unsigned char *addr;
+	struct xlr_adapter *adapter = (struct xlr_adapter *) arg;
 
 	length = (msg->msg0 >> 40) & 0x3fff;
 	if (length == 0) {
 		addr = bus_to_virt(msg->msg0 & 0xffffffffffULL);
-		dev_kfree_skb_any(addr);
-	} else if (length) {
-		addr = bus_to_virt(msg->msg0 & 0xffffffffe0ULL);
+		addr = addr - MAC_SKB_BACK_PTR_SIZE;
+		skb = (struct sk_buff *) *(unsigned long *)addr;
+		dev_kfree_skb_any((struct sk_buff *)addr);
+	} else {
+		addr = (unsigned char *)
+			bus_to_virt(msg->msg0 & 0xffffffffe0ULL);
 		length = length - BYTE_OFFSET - MAC_CRC_LEN;
-		port = msg->msg0 & 0x0f;
-		if (src_stnid == FMN_STNID_GMAC1)
-			port = port + 4;
-		skb = mac_get_skb_back_ptr(addr);
-		skb->dev = mac_to_ndev[port];
+		port = ((int)msg->msg0) & 0x0f;
+		addr = addr - MAC_SKB_BACK_PTR_SIZE;
+		skb = (struct sk_buff *) *(unsigned long *)addr;
+		skb->dev = adapter->netdev[port];
+		if (skb->dev == NULL)
+			return;
 		ndev = skb->dev;
 		priv = netdev_priv(ndev);
 
@@ -181,14 +161,16 @@ static void xlr_net_fmn_handler(int bkt, int src_stnid, int size,
 		skb->dev->last_rx = jiffies;
 		netif_rx(skb);
 		/* Fill rx ring */
-		skb_new = xlr_alloc_skb();
-		if (skb_new)
-			send_to_rfr_fifo(priv, skb_new->data);
+		skb_data = xlr_alloc_skb();
+		if (skb_data)
+			send_to_rfr_fifo(priv, skb_data);
 	}
 	return;
 }
 
-/* Ethtool operation */
+/*
+ * Ethtool operation
+ */
 static int xlr_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 {
 	struct xlr_net_priv *priv = netdev_priv(ndev);
@@ -198,7 +180,6 @@ static int xlr_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 		return -ENODEV;
 	return phy_ethtool_gset(phydev, ecmd);
 }
-
 static int xlr_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 {
 	struct xlr_net_priv *priv = netdev_priv(ndev);
@@ -214,18 +195,23 @@ static struct ethtool_ops xlr_ethtool_ops = {
 	.set_settings = xlr_set_settings,
 };
 
-/* Net operations */
+
+/*
+ * Net operations
+ */
 static int xlr_net_fill_rx_ring(struct net_device *ndev)
 {
-	struct sk_buff *skb;
+	void *skb_data;
 	struct xlr_net_priv *priv = netdev_priv(ndev);
 	int i;
 
-	for (i = 0; i < MAX_FRIN_SPILL/2; i++) {
-		skb = xlr_alloc_skb();
-		if (!skb)
+	for (i = 0; i < MAX_FRIN_SPILL/4; i++) {
+		skb_data = xlr_alloc_skb();
+		if (!skb_data) {
+			pr_err("SKB allocation failed\n");
 			return -ENOMEM;
-		send_to_rfr_fifo(priv, skb->data);
+		}
+		send_to_rfr_fifo(priv, skb_data);
 	}
 	pr_info("Rx ring setup done\n");
 	return 0;
@@ -237,6 +223,7 @@ static int xlr_net_open(struct net_device *ndev)
 	struct xlr_net_priv *priv = netdev_priv(ndev);
 	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
 
+
 	/* schedule a link state check */
 	phy_start(phydev);
 
@@ -245,10 +232,11 @@ static int xlr_net_open(struct net_device *ndev)
 		pr_err("Autoneg failed\n");
 		return err;
 	}
-
 	/* Setup the speed from PHY to internal reg*/
 	xlr_set_gmac_speed(priv);
+
 	netif_tx_start_all_queues(ndev);
+
 	return 0;
 }
 
@@ -300,7 +288,7 @@ static netdev_tx_t xlr_net_start_xmit(struct sk_buff *skb,
 
 	xlr_make_tx_desc(&msg, virt_to_phys(skb->data), skb);
 	flags = nlm_cop2_enable_irqsave();
-	ret = nlm_fmn_send(2, 0, priv->nd->tx_stnid, &msg);
+	ret = nlm_fmn_send(2, 0, priv->tx_stnid, &msg);
 	nlm_cop2_disable_irqrestore(flags);
 	if (ret)
 		dev_kfree_skb_any(skb);
@@ -433,7 +421,9 @@ static struct net_device_ops xlr_netdev_ops = {
 	.ndo_get_stats64 = xlr_get_stats64,
 };
 
-/* Gmac init */
+/*
+ * Gmac init
+ */
 static void *xlr_config_spill(struct xlr_net_priv *priv, int reg_start_0,
 		int reg_start_1, int reg_size, int size)
 {
@@ -539,13 +529,13 @@ static void xlr_config_pde(struct xlr_net_priv *priv)
  * Setup the Message ring credits, bucket size and other
  * common configuration
  */
-static void xlr_config_common(struct xlr_net_priv *priv)
+static int xlr_config_common(struct xlr_net_priv *priv)
 {
 	struct xlr_fmn_info *gmac = priv->nd->gmac_fmn_info;
 	int start_stn_id = gmac->start_stn_id;
 	int end_stn_id = gmac->end_stn_id;
 	int *bucket_size = priv->nd->bucket_size;
-	int i, j;
+	int i, j, err;
 
 	/* Setting non-core MsgBktSize(0x321 - 0x325) */
 	for (i = start_stn_id; i <= end_stn_id; i++) {
@@ -572,9 +562,12 @@ static void xlr_config_common(struct xlr_net_priv *priv)
 	xlr_nae_wreg(priv->base_addr, R_DMACR3, 0xffffffff);
 	xlr_nae_wreg(priv->base_addr, R_FREEQCARVE, 0);
 
-	xlr_net_fill_rx_ring(priv->ndev);
+	err = xlr_net_fill_rx_ring(priv->ndev);
+	if (err)
+		return err;
 	nlm_register_fmn_handler(start_stn_id, end_stn_id, xlr_net_fmn_handler,
-					NULL);
+			priv->adapter);
+	return 0;
 }
 
 static void xlr_config_translate_table(struct xlr_net_priv *priv)
@@ -775,6 +768,7 @@ static void xlr_sgmii_init(struct xlr_net_priv *priv)
 	xlr_nae_wreg(priv->gpio_addr, 0x22, 0x7e6802);
 	xlr_nae_wreg(priv->gpio_addr, 0x21, 0x7104);
 
+
 	/* enable autoneg - more magic */
 	phy = priv->phy_addr % 4 + 27;
 	xlr_phy_write(priv->pcs_addr, phy, 0, 0x1000);
@@ -790,7 +784,6 @@ void xlr_set_gmac_speed(struct xlr_net_priv *priv)
 		xlr_sgmii_init(priv);
 
 	if (phydev->speed != priv->phy_speed) {
-		pr_info("change %d to %d\n", priv->phy_speed, phydev->speed);
 		speed = phydev->speed;
 		if (speed == SPEED_1000) {
 			/* Set interface to Byte mode */
@@ -832,12 +825,12 @@ static void xlr_gmac_link_adjust(struct net_device *ndev)
 	intreg = xlr_nae_rdreg(priv->base_addr, R_INTREG);
 	if (phydev->link) {
 		if (phydev->speed != priv->phy_speed) {
-			pr_info("gmac%d : Link up\n", priv->port_id);
 			xlr_set_gmac_speed(priv);
+			pr_info("gmac%d : Link up\n", priv->port_id);
 		}
 	} else {
-		pr_info("gmac%d : Link down\n", priv->port_id);
 		xlr_set_gmac_speed(priv);
+		pr_info("gmac%d : Link down\n", priv->port_id);
 	}
 }
 
@@ -877,7 +870,6 @@ static int xlr_setup_mdio(struct xlr_net_priv *priv,
 {
 	int err;
 
-	priv->phy_addr = priv->nd->phy_addr;
 	priv->mii_bus = mdiobus_alloc();
 	if (!priv->mii_bus) {
 		pr_err("mdiobus alloc failed\n");
@@ -897,6 +889,7 @@ static int xlr_setup_mdio(struct xlr_net_priv *priv,
 		mdiobus_free(priv->mii_bus);
 		return -ENOMEM;
 	}
+
 	priv->mii_bus->irq[priv->phy_addr] = priv->ndev->irq;
 
 	/* Scan only the enabled address */
@@ -967,7 +960,9 @@ static void xlr_port_disable(struct xlr_net_priv *priv)
 		1 << O_RX_CONTROL__RxEnable, 0);
 }
 
-/* Initialization of gmac */
+/*
+ * Initialization of gmac
+ */
 static int xlr_gmac_init(struct xlr_net_priv *priv,
 		struct platform_device *pdev)
 {
@@ -976,6 +971,7 @@ static int xlr_gmac_init(struct xlr_net_priv *priv,
 	pr_info("Initializing the gmac%d\n", priv->port_id);
 
 	xlr_port_disable(priv);
+
 	xlr_nae_wreg(priv->base_addr, R_DESC_PACK_CTRL,
 			(1 << O_DESC_PACK_CTRL__MaxEntry)
 			| (BYTE_OFFSET << O_DESC_PACK_CTRL__ByteOffset)
@@ -1004,8 +1000,8 @@ static int xlr_gmac_init(struct xlr_net_priv *priv,
 	/* Clear all stats */
 	xlr_reg_update(priv->base_addr, R_STATCTRL,
 		0, 1 << O_STATCTRL__ClrCnt);
-	xlr_reg_update(priv->base_addr, R_STATCTRL,
-		1 << O_STATCTRL__ClrCnt, 1 << O_STATCTRL__ClrCnt);
+	xlr_reg_update(priv->base_addr, R_STATCTRL, 1 << 2,
+		1 << 2);
 	return 0;
 }
 
@@ -1014,87 +1010,114 @@ static int xlr_net_probe(struct platform_device *pdev)
 	struct xlr_net_priv *priv = NULL;
 	struct net_device *ndev;
 	struct resource *res;
-	int mac, err;
+	struct xlr_adapter *adapter;
+	int err, port;
 
-	mac = pdev->id;
-	ndev = alloc_etherdev_mq(sizeof(struct xlr_net_priv), 32);
-	if (!ndev) {
-		pr_err("Allocation of Ethernet device failed\n");
-		return -ENOMEM;
-	}
+	pr_info("XLR/XLS Ethernet Driver controller %d\n", pdev->id);
 
-	priv = netdev_priv(ndev);
-	priv->pdev = pdev;
-	priv->ndev = ndev;
-	priv->port_id = mac;
-	priv->nd = (struct xlr_net_data *)pdev->dev.platform_data;
-
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (res == NULL) {
-		pr_err("No memory resource for MAC %d\n", mac);
-		err = -ENODEV;
-		goto err_gmac;
+	/*
+	 * Allocate our adapter data structure and attach it to the device.
+	 */
+	adapter = (struct xlr_adapter *)
+		devm_kzalloc(&pdev->dev, sizeof(adapter), GFP_KERNEL);
+	if (!adapter) {
+		err = -ENOMEM;
+		return err;
 	}
 
-	ndev->base_addr = (unsigned long) devm_ioremap_resource
-		(&pdev->dev, res);
-	if (IS_ERR_VALUE(ndev->base_addr)) {
-		err = ndev->base_addr;
-		goto err_gmac;
-	}
+	/*
+	 * XLR and XLS have 1 and 2 NAE controller respectively
+	 * Each controller has 4 gmac ports, mapping each controller
+	 * under one parent device, 4 gmac ports under one device.
+	 */
+	for (port = 0; port < pdev->num_resources/2; port++) {
+		ndev = alloc_etherdev_mq(sizeof(struct xlr_net_priv), 32);
+		if (!ndev) {
+			pr_err("Allocation of Ethernet device failed\n");
+			return -ENOMEM;
+		}
 
-	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (res == NULL) {
-		pr_err("No irq resource for MAC %d\n", mac);
-		err = -ENODEV;
-		goto err_gmac;
-	}
-	ndev->irq = res->start;
+		priv = netdev_priv(ndev);
+		priv->pdev = pdev;
+		priv->ndev = ndev;
+		priv->port_id = (pdev->id * 4) + port;
+		priv->nd = (struct xlr_net_data *)pdev->dev.platform_data;
+		res = platform_get_resource(pdev, IORESOURCE_MEM, port);
+
+		if (res == NULL) {
+			pr_err("No memory resource for MAC %d\n",
+					priv->port_id);
+			err = -ENODEV;
+			goto err_gmac;
+		}
 
-	priv->mii_addr = priv->nd->mii_addr;
-	priv->serdes_addr = priv->nd->serdes_addr;
-	priv->pcs_addr = priv->nd->pcs_addr;
-	priv->gpio_addr = priv->nd->gpio_addr;
-	priv->base_addr = (u32 *) ndev->base_addr;
+		priv->base_addr = devm_ioremap_resource(&pdev->dev, res);
+		if (IS_ERR(priv->base_addr)) {
+			err = PTR_ERR(priv->base_addr);
+			goto err_gmac;
+		}
 
-	mac_to_ndev[mac] = ndev;
-	ndev->netdev_ops = &xlr_netdev_ops;
-	ndev->watchdog_timeo = HZ;
+		priv->adapter = adapter;
+		adapter->netdev[port] = ndev;
 
-	/* Setup Mac address and Rx mode */
-	eth_hw_addr_random(ndev);
-	xlr_hw_set_mac_addr(ndev);
-	xlr_set_rx_mode(ndev);
+		res = platform_get_resource(pdev, IORESOURCE_IRQ, port);
+		if (res == NULL) {
+			pr_err("No irq resource for MAC %d\n", priv->port_id);
+			err = -ENODEV;
+			goto err_gmac;
+		}
 
-	priv->num_rx_desc += MAX_NUM_DESC_SPILL;
-	SET_ETHTOOL_OPS(ndev, &xlr_ethtool_ops);
-	SET_NETDEV_DEV(ndev, &pdev->dev);
+		ndev->irq = res->start;
+
+		priv->phy_addr = priv->nd->phy_addr[port];
+		priv->tx_stnid = priv->nd->tx_stnid[port];
+		priv->mii_addr = priv->nd->mii_addr;
+		priv->serdes_addr = priv->nd->serdes_addr;
+		priv->pcs_addr = priv->nd->pcs_addr;
+		priv->gpio_addr = priv->nd->gpio_addr;
+
+		ndev->netdev_ops = &xlr_netdev_ops;
+		ndev->watchdog_timeo = HZ;
+
+		/* Setup Mac address and Rx mode */
+		eth_hw_addr_random(ndev);
+		xlr_hw_set_mac_addr(ndev);
+		xlr_set_rx_mode(ndev);
+
+		priv->num_rx_desc += MAX_NUM_DESC_SPILL;
+		SET_ETHTOOL_OPS(ndev, &xlr_ethtool_ops);
+		SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	/* Common registers, do one time initialization */
-	if (mac == 0 || mac == 4) {
 		xlr_config_fifo_spill_area(priv);
 		/* Configure PDE to Round-Robin pkt distribution */
 		xlr_config_pde(priv);
 		xlr_config_parser(priv);
-	}
-	/* Call init with respect to port */
-	if (strcmp(res->name, "gmac") == 0) {
-		err = xlr_gmac_init(priv, pdev);
+
+		/* Call init with respect to port */
+		if (strcmp(res->name, "gmac") == 0) {
+			err = xlr_gmac_init(priv, pdev);
+			if (err) {
+				pr_err("gmac%d init failed\n", priv->port_id);
+				goto err_gmac;
+			}
+		}
+
+		if (priv->port_id == 0 || priv->port_id == 4) {
+			err = xlr_config_common(priv);
+			if (err)
+				goto err_netdev;
+		}
+
+		err = register_netdev(ndev);
 		if (err) {
-			pr_err("gmac%d init failed\n", mac);
-			goto err_gmac;
+			pr_err("Registering netdev failed for gmac%d\n",
+					priv->port_id);
+			goto err_netdev;
 		}
+		platform_set_drvdata(pdev, priv);
 	}
 
-	if (mac == 0 || mac == 4)
-		xlr_config_common(priv);
-
-	err = register_netdev(ndev);
-	if (err)
-		goto err_netdev;
-	platform_set_drvdata(pdev, priv);
 	return 0;
-
 err_netdev:
 	mdiobus_free(priv->mii_bus);
 err_gmac:
diff --git a/drivers/staging/netlogic/xlr_net.h b/drivers/staging/netlogic/xlr_net.h
index cea7966..13e03f0 100644
--- a/drivers/staging/netlogic/xlr_net.h
+++ b/drivers/staging/netlogic/xlr_net.h
@@ -1069,14 +1069,20 @@ enum tsv_rsv_reg {
 	CARRY_REG_2 = 0x4d,
 };
 
+struct xlr_adapter {
+	struct net_device *netdev[4];
+};
+
 struct xlr_net_priv {
 	u32 __iomem *base_addr;
 	struct net_device *ndev;
+	struct xlr_adapter *adapter;
 	struct mii_bus *mii_bus;
 	int num_rx_desc;
 	int phy_addr;	/* PHY addr on MDIO bus */
 	int pcs_id;	/* PCS id on MDIO bus */
 	int port_id;	/* Port(gmac/xgmac) number, i.e 0-7 */
+	int tx_stnid;
 	u32 __iomem *mii_addr;
 	u32 __iomem *serdes_addr;
 	u32 __iomem *pcs_addr;
@@ -1096,4 +1102,4 @@ struct xlr_net_priv {
 	u64 *class_3_spill;
 };
 
-void xlr_set_gmac_speed(struct xlr_net_priv *priv);
+extern void xlr_set_gmac_speed(struct xlr_net_priv *priv);
-- 
1.7.9.5
