From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH RESEND net 8/9] net/8390: Fix redundant code
Date: Mon,  2 Oct 2017 21:07:18 -0400 (EDT)
Message-ID: <985d85bdd036b130f117fd11e4bcb0241464ddcd.1506992619.git.fthain@telegraphics.com.au>
References: <cover.1506992619.git.fthain@telegraphics.com.au>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Russell King <linux@armlinux.org.uk>,
        linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1506992619.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch which introduced the 8390 core module parameter 'msg_enable'
failed to do anything useful with it: it merely causes an ancient
version string to be logged.

Remove the other code that logs the same string. Use the msg_enable
module parameter as the default value for ei_local->msg_enable.
Otherwise, some 8390 modules have no way to set ei_local->msg_enable.

Also fix two more issues arising from the same patch: indentation
mistakes and pointless static variables.

Fixes: c45f812f0280 ("8390 : Replace ei_debug with msg_enable/NETIF_MSG_* feature")
Cc: Russell King <linux@armlinux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org
Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
---
 drivers/net/ethernet/8390/ax88796.c   |  3 ---
 drivers/net/ethernet/8390/axnet_cs.c  |  2 --
 drivers/net/ethernet/8390/etherh.c    | 17 -----------------
 drivers/net/ethernet/8390/hydra.c     |  4 ----
 drivers/net/ethernet/8390/lib8390.c   |  2 ++
 drivers/net/ethernet/8390/mac8390.c   |  7 -------
 drivers/net/ethernet/8390/mcf8390.c   |  4 ----
 drivers/net/ethernet/8390/pcnet_cs.c  |  4 ----
 drivers/net/ethernet/8390/zorro8390.c |  5 -----
 9 files changed, 2 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index 05d9d3e2e92e..28aa79d2f16c 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -77,8 +77,6 @@ static unsigned char version[] = "ax88796.c: Copyright 2005,2007 Simtec Electron
 
 #define AX_GPOC_PPDSET	BIT(6)
 
-static u32 ax_msg_enable;
-
 /* device private data */
 
 struct ax_device {
@@ -747,7 +745,6 @@ static int ax_init_dev(struct net_device *dev)
 	ei_local->block_output = &ax_block_output;
 	ei_local->get_8390_hdr = &ax_get_8390_hdr;
 	ei_local->priv = 0;
-	ei_local->msg_enable = ax_msg_enable;
 
 	dev->netdev_ops = &ax_netdev_ops;
 	dev->ethtool_ops = &ax_ethtool_ops;
diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index 3da1fc539ef9..91e76dc1e6e1 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -104,7 +104,6 @@ static void AX88190_init(struct net_device *dev, int startp);
 static int ax_open(struct net_device *dev);
 static int ax_close(struct net_device *dev);
 static irqreturn_t ax_interrupt(int irq, void *dev_id);
-static u32 axnet_msg_enable;
 
 /*====================================================================*/
 
@@ -151,7 +150,6 @@ static int axnet_probe(struct pcmcia_device *link)
 	return -ENOMEM;
 
     ei_local = netdev_priv(dev);
-    ei_local->msg_enable = axnet_msg_enable;
     spin_lock_init(&ei_local->page_lock);
 
     info = PRIV(dev);
diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
index 11cbf22ad201..32e9627e3880 100644
--- a/drivers/net/ethernet/8390/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -64,8 +64,6 @@ static char version[] =
 
 #include "lib8390.c"
 
-static u32 etherh_msg_enable;
-
 struct etherh_priv {
 	void __iomem	*ioc_fast;
 	void __iomem	*memc;
@@ -502,18 +500,6 @@ etherh_close(struct net_device *dev)
 }
 
 /*
- * Initialisation
- */
-
-static void __init etherh_banner(void)
-{
-	static int version_printed;
-
-	if ((etherh_msg_enable & NETIF_MSG_DRV) && (version_printed++ == 0))
-		pr_info("%s", version);
-}
-
-/*
  * Read the ethernet address string from the on board rom.
  * This is an ascii string...
  */
@@ -671,8 +657,6 @@ etherh_probe(struct expansion_card *ec, const struct ecard_id *id)
 	struct etherh_priv *eh;
 	int ret;
 
-	etherh_banner();
-
 	ret = ecard_request_resources(ec);
 	if (ret)
 		goto out;
@@ -757,7 +741,6 @@ etherh_probe(struct expansion_card *ec, const struct ecard_id *id)
 	ei_local->block_output  = etherh_block_output;
 	ei_local->get_8390_hdr  = etherh_get_header;
 	ei_local->interface_num = 0;
-	ei_local->msg_enable = etherh_msg_enable;
 
 	etherh_reset(dev);
 	__NS8390_init(dev, 0);
diff --git a/drivers/net/ethernet/8390/hydra.c b/drivers/net/ethernet/8390/hydra.c
index 8ae249195301..941754ea78ec 100644
--- a/drivers/net/ethernet/8390/hydra.c
+++ b/drivers/net/ethernet/8390/hydra.c
@@ -66,7 +66,6 @@ static void hydra_block_input(struct net_device *dev, int count,
 static void hydra_block_output(struct net_device *dev, int count,
 			       const unsigned char *buf, int start_page);
 static void hydra_remove_one(struct zorro_dev *z);
-static u32 hydra_msg_enable;
 
 static struct zorro_device_id hydra_zorro_tbl[] = {
     { ZORRO_PROD_HYDRA_SYSTEMS_AMIGANET },
@@ -119,7 +118,6 @@ static int hydra_init(struct zorro_dev *z)
     int start_page, stop_page;
     int j;
     int err;
-    struct ei_device *ei_local;
 
     static u32 hydra_offsets[16] = {
 	0x00, 0x02, 0x04, 0x06, 0x08, 0x0a, 0x0c, 0x0e,
@@ -138,8 +136,6 @@ static int hydra_init(struct zorro_dev *z)
     start_page = NESM_START_PG;
     stop_page = NESM_STOP_PG;
 
-    ei_local = netdev_priv(dev);
-    ei_local->msg_enable = hydra_msg_enable;
     dev->base_addr = ioaddr;
     dev->irq = IRQ_AMIGA_PORTS;
 
diff --git a/drivers/net/ethernet/8390/lib8390.c b/drivers/net/ethernet/8390/lib8390.c
index 60f8e2c8e726..5d9bbde9fe68 100644
--- a/drivers/net/ethernet/8390/lib8390.c
+++ b/drivers/net/ethernet/8390/lib8390.c
@@ -975,6 +975,8 @@ static void ethdev_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	spin_lock_init(&ei_local->page_lock);
+
+	ei_local->msg_enable = msg_enable;
 }
 
 /**
diff --git a/drivers/net/ethernet/8390/mac8390.c b/drivers/net/ethernet/8390/mac8390.c
index 9497f18eaba0..1bfc66f37971 100644
--- a/drivers/net/ethernet/8390/mac8390.c
+++ b/drivers/net/ethernet/8390/mac8390.c
@@ -167,7 +167,6 @@ static void slow_sane_block_output(struct net_device *dev, int count,
 				   const unsigned char *buf, int start_page);
 static void word_memcpy_tocard(unsigned long tp, const void *fp, int count);
 static void word_memcpy_fromcard(void *tp, unsigned long fp, int count);
-static u32 mac8390_msg_enable;
 
 static enum mac8390_type __init mac8390_ident(struct nubus_dev *dev)
 {
@@ -297,8 +296,6 @@ static bool __init mac8390_init(struct net_device *dev, struct nubus_dev *ndev,
 	int offset;
 	volatile unsigned short *i;
 
-	printk_once(KERN_INFO pr_fmt("%s"), version);
-
 	dev->irq = SLOT2IRQ(ndev->board->slot);
 	/* This is getting to be a habit */
 	dev->base_addr = (ndev->board->slot_addr |
@@ -396,7 +393,6 @@ struct net_device * __init mac8390_probe(int unit)
 	struct net_device *dev;
 	struct nubus_dev *ndev = NULL;
 	int err = -ENODEV;
-	struct ei_device *ei_local;
 
 	static unsigned int slots;
 
@@ -436,9 +432,6 @@ struct net_device * __init mac8390_probe(int unit)
 	if (!ndev)
 		goto out;
 
-	 ei_local = netdev_priv(dev);
-	 ei_local->msg_enable = mac8390_msg_enable;
-
 	err = register_netdev(dev);
 	if (err)
 		goto out;
diff --git a/drivers/net/ethernet/8390/mcf8390.c b/drivers/net/ethernet/8390/mcf8390.c
index 4bb967bc879e..4ad8031ab669 100644
--- a/drivers/net/ethernet/8390/mcf8390.c
+++ b/drivers/net/ethernet/8390/mcf8390.c
@@ -38,7 +38,6 @@ static const char version[] =
 
 #define NESM_START_PG	0x40	/* First page of TX buffer */
 #define NESM_STOP_PG	0x80	/* Last page +1 of RX ring */
-static u32 mcf8390_msg_enable;
 
 #ifdef NE2000_ODDOFFSET
 /*
@@ -407,7 +406,6 @@ static int mcf8390_init(struct net_device *dev)
 static int mcf8390_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
-	struct ei_device *ei_local;
 	struct resource *mem, *irq;
 	resource_size_t msize;
 	int ret;
@@ -435,8 +433,6 @@ static int mcf8390_probe(struct platform_device *pdev)
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	platform_set_drvdata(pdev, dev);
-	ei_local = netdev_priv(dev);
-	ei_local->msg_enable = mcf8390_msg_enable;
 
 	dev->irq = irq->start;
 	dev->base_addr = mem->start;
diff --git a/drivers/net/ethernet/8390/pcnet_cs.c b/drivers/net/ethernet/8390/pcnet_cs.c
index bd0a2a14b649..a81ffe4874e1 100644
--- a/drivers/net/ethernet/8390/pcnet_cs.c
+++ b/drivers/net/ethernet/8390/pcnet_cs.c
@@ -66,7 +66,6 @@
 #define PCNET_RDC_TIMEOUT (2*HZ/100)	/* Max wait in jiffies for Tx RDC */
 
 static const char *if_names[] = { "auto", "10baseT", "10base2"};
-static u32 pcnet_msg_enable;
 
 /*====================================================================*/
 
@@ -556,7 +555,6 @@ static int pcnet_config(struct pcmcia_device *link)
     int start_pg, stop_pg, cm_offset;
     int has_shmem = 0;
     struct hw_info *local_hw_info;
-    struct ei_device *ei_local;
 
     dev_dbg(&link->dev, "pcnet_config\n");
 
@@ -606,8 +604,6 @@ static int pcnet_config(struct pcmcia_device *link)
 	mii_phy_probe(dev);
 
     SET_NETDEV_DEV(dev, &link->dev);
-    ei_local = netdev_priv(dev);
-    ei_local->msg_enable = pcnet_msg_enable;
 
     if (register_netdev(dev) != 0) {
 	pr_notice("register_netdev() failed\n");
diff --git a/drivers/net/ethernet/8390/zorro8390.c b/drivers/net/ethernet/8390/zorro8390.c
index 6d93956b293b..35a500a21521 100644
--- a/drivers/net/ethernet/8390/zorro8390.c
+++ b/drivers/net/ethernet/8390/zorro8390.c
@@ -44,8 +44,6 @@
 static const char version[] =
 	"8390.c:v1.10cvs 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
 
-static u32 zorro8390_msg_enable;
-
 #include "lib8390.c"
 
 #define DRV_NAME	"zorro8390"
@@ -296,7 +294,6 @@ static int zorro8390_init(struct net_device *dev, unsigned long board,
 	int err;
 	unsigned char SA_prom[32];
 	int start_page, stop_page;
-	struct ei_device *ei_local = netdev_priv(dev);
 	static u32 zorro8390_offsets[16] = {
 		0x00, 0x02, 0x04, 0x06, 0x08, 0x0a, 0x0c, 0x0e,
 		0x10, 0x12, 0x14, 0x16, 0x18, 0x1a, 0x1c, 0x1e,
@@ -388,8 +385,6 @@ static int zorro8390_init(struct net_device *dev, unsigned long board,
 	dev->netdev_ops = &zorro8390_netdev_ops;
 	__NS8390_init(dev, 0);
 
-	ei_local->msg_enable = zorro8390_msg_enable;
-
 	err = register_netdev(dev);
 	if (err) {
 		free_irq(IRQ_AMIGA_PORTS, dev);
-- 
2.13.5
