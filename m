From: Mark Smith <markzzzsmith@ozemail.com.au>
Subject: [PATCH][RFT] 802.3x / ETHTOOL Pause frame support for natsemi 83816
Date: 26 Jan 2003 22:51:09 +1030
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1043583669.1774.22.camel@dupy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: thockin@hockin.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Tim, *

I've put together the following patch to enable 802.3x ethernet pause
frame support, including the ethtool pause options, on the natsemi 83816
based network cards.

I've tested it on my 83815 based Netgear FA312 card, which does have all
the required registers, but according to page 69 of the NS83815.pdf
document, the pause feature is not supported. I added the check for
83816 chips just as the final step before posting it.

I haven't done any kernel level programming before, so I'd appreciate
any suggestions or improvements I can make to it.

The patch is against natsemi.c version 1.0.17.

Thanks,
Mark.

--- natsemi.orig/natsemi.c	Sun Jan 26 20:53:06 2003
+++ natsemi.ethpause/natsemi.c	Sun Jan 26 21:32:30 2003
@@ -133,6 +133,11 @@
 		* comments update (Manfred)
 		* do the right thing on a phy-reset (Manfred and Tim)
 
+	version 1.0.17+ETHPAUSE: (Mark Smith, markzzzsmith at yahoo.com.au)
+		* enable processing of 802.3x multicast pause frames
+		  on the 83816
+		* add support for ethtool [gs]pause options 
+
 	TODO:
 	* big endian support with CFG:BEM instead of cpu_to_le32
 	* support for an external PHY
@@ -171,8 +176,8 @@
 #include <asm/uaccess.h>
 
 #define DRV_NAME	"natsemi"
-#define DRV_VERSION	"1.07+LK1.0.17"
-#define DRV_RELDATE	"Sep 27, 2002"
+#define DRV_VERSION	"1.07+LK1.0.17+ETHPAUSE"
+#define DRV_RELDATE	"Jan 19, 2003"
 
 /* Updated to recommendations in pci-skeleton v2.03. */
 
@@ -449,6 +454,7 @@
 	CfgAnegEnable		= 0x2000,
 	CfgAneg100		= 0x4000,
 	CfgAnegFull		= 0x8000,
+	CfgPauseAdvert		= 0x00010000,
 	CfgAnegDone		= 0x8000000,
 	CfgFullDuplex		= 0x20000000,
 	CfgSpeed100		= 0x40000000,
@@ -569,6 +575,17 @@
 	WakeOptsSummary		= 0x7ff
 };
 
+enum PauseCmd_bits {
+        PauseCounter            = 0x0000ffff,
+        PauseManLoadEnable      = 0x00010000,
+        PauseNegotiated         = 0x00200000,
+        PauseFrameRxed          = 0x00400000,
+        PauseActive		= 0x00800000,
+        PauseOnDestAddr         = 0x20000000,
+        PauseOnMultiCast        = 0x40000000,
+        PauseEnable		= 0x80000000
+};
+
 enum RxFilterAddr_bits {
 	RFCRAddressMask		= 0x3ff,
 	AcceptMulticast		= 0x00200000,
@@ -586,6 +603,10 @@
 	StatsStrobe		= 0x8,
 };
 
+enum AnegAdv_bits {
+	AnegAdvPause	= 0x400
+};
+
 enum MIntrCtrl_bits {
 	MICRIntEn		= 0x2,
 };
@@ -714,6 +735,7 @@
 static int netdev_close(struct net_device *dev);
 static int netdev_get_regs(struct net_device *dev, u8 *buf);
 static int netdev_get_eeprom(struct net_device *dev, u8 *buf);
+static int netdev_reautoneg_link(struct net_device *dev);
 

 static int __devinit natsemi_probe1 (struct pci_dev *pdev,
@@ -1284,13 +1306,13 @@
 	 * ECRETRY=1
 	 * ATP=1
 	 */
-	np->tx_config = TxAutoPad | TxCollRetry | TxMxdma_256 | (0x1002);
+	np->tx_config = TxAutoPad | TxCollRetry | TxMxdma_256 | (0x1002); 
 	writel(np->tx_config, ioaddr + TxConfig);
 
 	/* DRTH 0x10: start copying to memory if 128 bytes are in the fifo
 	 * MXDMA 0: up to 256 byte bursts
 	 */
-	np->rx_config = RxMxdma_256 | 0x20;
+	np->rx_config = RxMxdma_256 | 0x20; 
 	writel(np->rx_config, ioaddr + RxConfig);
 
 	/* Disable PME:
@@ -1306,6 +1328,11 @@
 			dev->name, readl(ioaddr + WOLCmd));
 	}
 
+	/* Switch on 802.3x multicast pause frame processing.
+	* Tx will not actually pause unless pause capability
+	* is autonegotiated or manually switched on. */
+	writel(PauseOnMultiCast,ioaddr + PauseCmd);
+
 	check_link(dev);
 	__set_rx_mode(dev);
 
@@ -2041,6 +2068,7 @@
 		return 0;
 	}
 	/* set wake-on-lan */
+
 	case ETHTOOL_SWOL: {
 		struct ethtool_wolinfo wol;
 		int r;
@@ -2098,16 +2126,7 @@
 	}
 	/* restart autonegotiation */
 	case ETHTOOL_NWAY_RST: {
-		int tmp;
-		int r = -EINVAL;
-		/* if autoneg is off, it's an error */
-		tmp = mdio_read(dev, 1, MII_BMCR);
-		if (tmp & BMCR_ANENABLE) {
-			tmp |= (BMCR_ANRESTART);
-			mdio_write(dev, 1, MII_BMCR, tmp);
-			r = 0;
-		}
-		return r;
+		return netdev_reautoneg_link(dev);
 	}
 	/* get link status */
 	case ETHTOOL_GLINK: {
@@ -2151,6 +2170,83 @@
 		return 0;
 	}
 
+	case ETHTOOL_GPAUSEPARAM: {
+		struct ethtool_pauseparam epause = { ETHTOOL_GPAUSEPARAM };
+		long ioaddr = dev->base_addr;
+
+		/* Only supported on the 83816, 83815 has all the registers
+		 * required, but according to pg 69 of DP83815.pdf, 
+		 * "The DP83815 does not support this feature."
+		 * Sounds like a hardware bug to me :-(
+		 * Wish I had a 83816 based card to test that my pause
+		 * code actually does what I think it does.
+		 */
+		if (np->srr < SRR_DP83816_A4)
+			return -EINVAL;
+
+		spin_lock_irq(&np->lock);
+
+		epause.autoneg = 
+			(readl(ioaddr + AnegAdv) & AnegAdvPause) != 0;
+
+		if (epause.autoneg)
+			epause.tx_pause =
+				(readl(ioaddr + PauseCmd) & PauseNegotiated)\
+					!= 0;
+		else
+			epause.tx_pause =
+				(readl(ioaddr + PauseCmd) & PauseEnable) != 0;
+		
+		/* NS8381[56] has no rx pause */
+		spin_unlock_irq(&np->lock);
+
+		if (copy_to_user(useraddr, &epause, sizeof(epause)))
+			return -EFAULT;
+
+		return 0;
+
+	}
+
+	case ETHTOOL_SPAUSEPARAM: {
+		struct ethtool_pauseparam epause;
+		long ioaddr = dev->base_addr;
+		u32 tmp;
+
+		/* 83816 and later only */
+		if (np->srr < SRR_DP83816_A4)
+			return -EINVAL;
+
+		if (copy_from_user(&epause, useraddr, sizeof(epause)))
+			return -EFAULT;
+
+		if (epause.rx_pause)
+			return -EINVAL;
+
+		spin_lock_irq(&np->lock);
+
+		if (epause.autoneg) {
+			tmp = readl(ioaddr + AnegAdv) | AnegAdvPause;
+	        	writel(tmp, ioaddr + AnegAdv);
+		} else {
+			tmp = readl(ioaddr + AnegAdv) & ~AnegAdvPause;
+	        	writel(tmp, ioaddr + AnegAdv);
+		}
+
+		if (epause.tx_pause) {
+			tmp = readl(ioaddr + PauseCmd) | PauseEnable;
+			writel(tmp, ioaddr + PauseCmd);
+		} else {
+			tmp = readl(ioaddr + PauseCmd) & ~PauseEnable;
+			writel(tmp, ioaddr + PauseCmd);
+		}
+
+		netdev_reautoneg_link(dev);
+
+		spin_unlock_irq(&np->lock);
+
+		return 0;	
+	}
+
 	}
 
 	return -EOPNOTSUPP;
@@ -2437,6 +2533,21 @@
 		ebuf[i] = SWAP_BITS(ebuf[i]);
 	}
 	return 0;
+}
+
+static int netdev_reautoneg_link(struct net_device *dev)
+{
+	int tmp;
+	int r = -EINVAL;
+
+	/* if autoneg is off, it's an error */
+	tmp = mdio_read(dev, 1, MII_BMCR);
+	if (tmp & BMCR_ANENABLE) {
+		tmp |= (BMCR_ANRESTART);
+		mdio_write(dev, 1, MII_BMCR, tmp);
+		r = 0;
+	}
+	return r;
 }
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
