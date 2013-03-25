From: Joseph CHANG <josright123@gmail.com>
Subject: [PATCH 1/1] ethernet driver: dm9000: davicom: Upgrade the driver to suit for all DM9000 series chips
Date: Mon, 25 Mar 2013 16:04:42 +0800
Message-ID: <1364198682-1589-1-git-send-email-josright123@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Joseph CHANG <joseph_chang@davicom.com.tw>
To: "David S. Miller" <davem@davemloft.net>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Matthew Leach <matthew@mattleach.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Joseph CHANG <joseph_chang@davicom.com.tw>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joseph CHANG <joseph_chang@davicom.com.tw>

Some necessary modification for DM9000 series chips to be better in operation!

Had tested to all of DM9000 series chips, include DM9000E, DM9000A, DM9000B,
and DM9000C in X86 and ARM embedded Linux system these years.

Signed-off-by: Joseph CHANG <joseph_chang@davicom.com.tw>
---
 drivers/net/ethernet/davicom/dm9000.c |   28 +++++++++++++++++++++++-----
 drivers/net/ethernet/davicom/dm9000.h |    4 +++-
 2 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 8cdf025..54bdc92 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -47,7 +47,8 @@
 #define DM9000_PHY		0x40	/* PHY address 0x01 */
 
 #define CARDNAME	"dm9000"
-#define DRV_VERSION	"1.31"
+/* [KERN-ADD-1](upgrade) */
+#define DRV_VERSION	"1.39"
 
 /*
  * Transmit timeout, default 5 seconds.
@@ -671,10 +672,16 @@ dm9000_poll_work(struct work_struct *w)
 			if (netif_msg_link(db))
 				dm9000_show_carrier(db, new_carrier, nsr);
 
-			if (!new_carrier)
+			/* [KERN-ADD-2] */
+			if (!new_carrier) {
 				netif_carrier_off(ndev);
-			else
+				netdev_info(ndev, "[%s Ethernet Driver, V%s]: Link-Down!!\n",
+					CARDNAME, DRV_VERSION);
+			} else {
 				netif_carrier_on(ndev);
+				netdev_info(ndev, "[%s Ethernet Driver, V%s]: Link-Up!!\n",
+					CARDNAME, DRV_VERSION);
+			}
 		}
 	} else
 		mii_check_media(&db->mii, netif_msg_link(db), 0);
@@ -794,6 +801,9 @@ dm9000_init_dm9000(struct net_device *dev)
 			(dev->features & NETIF_F_RXCSUM) ? RCSR_CSUM : 0);
 
 	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
+    /* [KERN-ADD-3] */
+	dm9000_phy_write(dev, 0, 0, 0x8000); /* reset PHY */
+	mdelay(2);
 
 	ncr = (db->flags & DM9000_PLATF_EXT_PHY) ? NCR_EXT_PHY : 0;
 
@@ -830,6 +840,8 @@ dm9000_init_dm9000(struct net_device *dev)
 	db->tx_pkt_cnt = 0;
 	db->queue_pkt_len = 0;
 	dev->trans_start = jiffies;
+    /* [KERN-ADD-4]	*/
+	dm9000_phy_write(dev, 0, 27, 0xE100);
 }
 
 /* Our watchdog timed out. Called by the networking layer */
@@ -1181,7 +1193,8 @@ dm9000_open(struct net_device *dev)
 
 	/* GPIO0 on pre-activate PHY, Reg 1F is not set by reset */
 	iow(db, DM9000_GPR, 0);	/* REG_1F bit0 activate phyxcer */
-	mdelay(1); /* delay needs by DM9000B */
+	/* [KERN-ADD-5](Enable PHY) */
+	mdelay(2); /* delay needs by DM9000B */
 
 	/* Initialize DM9000 board */
 	dm9000_reset(db);
@@ -1311,6 +1324,8 @@ dm9000_shutdown(struct net_device *dev)
 
 	/* RESET device */
 	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
+    /* [KERN-ADD-6](NOTICE)(by)("if (!db->wake_state) ..") */
+    /* iow(db, DM9000_GPR, 0x01); */
 	iow(db, DM9000_GPR, 0x01);	/* Power-Down PHY */
 	iow(db, DM9000_IMR, IMR_PAR);	/* Disable all interrupt */
 	iow(db, DM9000_RCR, 0x00);	/* Disable RX */
@@ -1465,6 +1480,8 @@ dm9000_probe(struct platform_device *pdev)
 	/* fill in parameters for net-dev structure */
 	ndev->base_addr = (unsigned long)db->io_addr;
 	ndev->irq	= db->irq_res->start;
+    /* [KERN-ADD-7] */
+	netdev_info(ndev, "[dm9] %s ndev->irq=%x\n", __func__, ndev->irq);
 
 	/* ensure at least we have a default set of IO routines */
 	dm9000_set_io(db, iosize);
@@ -1502,7 +1519,8 @@ dm9000_probe(struct platform_device *pdev)
 	db->flags |= DM9000_PLATF_SIMPLE_PHY;
 #endif
 
-	dm9000_reset(db);
+    /* [KERN-ADD-8](SPECIAL WHEN INIT_OF_PROBE)[takeover"dm9000_reset(db)"] */
+	iow(db, DM9000_NCR, NCR_MAC_LBK | NCR_RST); /* 0x03 */
 
 	/* try multiple times, DM9000 sometimes gets the read wrong */
 	for (i = 0; i < 8; i++) {
diff --git a/drivers/net/ethernet/davicom/dm9000.h b/drivers/net/ethernet/davicom/dm9000.h
index 55688bd..d644506 100644
--- a/drivers/net/ethernet/davicom/dm9000.h
+++ b/drivers/net/ethernet/davicom/dm9000.h
@@ -69,7 +69,9 @@
 #define NCR_WAKEEN          (1<<6)
 #define NCR_FCOL            (1<<4)
 #define NCR_FDX             (1<<3)
-#define NCR_LBK             (3<<1)
+
+#define NCR_RESERVED        (3<<1)
+#define NCR_MAC_LBK         (1<<1) /* [kern-add-0] */
 #define NCR_RST	            (1<<0)
 
 #define NSR_SPEED           (1<<7)
-- 
1.7.1
