From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 6/7] 2.6.6-rc3-mm1 - r8169 link handling rework (1/2)
Date: Sat, 1 May 2004 02:30:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040501023045.F500@electric-eye.fr.zoreil.com>
References: <20040501022308.A32762@electric-eye.fr.zoreil.com> <20040501022439.A500@electric-eye.fr.zoreil.com> <20040501022552.B500@electric-eye.fr.zoreil.com> <20040501022654.C500@electric-eye.fr.zoreil.com> <20040501022808.D500@electric-eye.fr.zoreil.com> <20040501022907.E500@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@myrealbox.com>, Jon D Mason <jonmason@us.ibm.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040501022907.E500@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, May 01, 2004 at 02:29:07AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Link handling changes (Andy Lutomirski <luto@myrealbox.com>):
- the LinkChg irq enables the phy timer when the link goes down;
- the phy timer is enabled in rtl8169_set_speed() to protect against
  link negociation failure;
- removed rtl8169_hw_phy_reset() and its busy loop; 
- added spinlocking in timer context for rtl8169_phy_timer to avoid
  messing with the {set/get}_settings commands issued via ethtool.


diff -puN drivers/net/r8169.c~r8169-link-00 drivers/net/r8169.c
--- linux-2.6.6-rc3/drivers/net/r8169.c~r8169-link-00	2004-05-01 01:46:40.000000000 +0200
+++ linux-2.6.6-rc3-fr/drivers/net/r8169.c	2004-05-01 01:46:40.000000000 +0200
@@ -41,6 +41,7 @@ VERSION 1.2	<2002/11/30>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
 #include <linux/ethtool.h>
+#include <linux/mii.h>
 #include <linux/crc32.h>
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
@@ -333,7 +334,8 @@ struct rtl8169_private {
 	struct sk_buff *Rx_skbuff[NUM_RX_DESC];	/* Rx data buffers */
 	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Tx data buffers */
 	struct timer_list timer;
-	unsigned long phy_link_down_cnt;
+	unsigned int phy_tried_renegotiate;
+	unsigned int phy_reset_warned;
 	u16 cp_cmd;
 	u16 intr_mask;
 	int phy_auto_nego_reg;
@@ -363,7 +365,7 @@ static int rtl8169_poll(struct net_devic
 static const u16 rtl8169_intr_mask =
 	LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
 static const u16 rtl8169_napi_event =
-	RxOK | LinkChg | RxOverflow | RxFIFOOver | TxOK | TxErr;
+	RxOK | RxOverflow | RxFIFOOver | TxOK | TxErr;
 static const unsigned int rtl8169_rx_config =
     (RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
 
@@ -405,6 +407,31 @@ static int mdio_read(void *ioaddr, int R
 	return value;
 }
 
+
+static inline int rtl8169_phy_reset_pending(void *ioaddr)
+{
+	return mdio_read(ioaddr, 0) & 0x8000;
+}
+
+static void rtl8169_check_link_status(struct net_device *dev,
+				      struct rtl8169_private *tp, void *ioaddr)
+{
+	unsigned long flags;
+	u8 status;
+
+	status = RTL_R8(PHYstatus) & LinkStatus;
+
+	spin_lock_irqsave(&tp->lock, flags);
+	if (status) {
+		netif_carrier_on(dev);
+		tp->phy_reset_warned = 0;
+	} else {
+		netif_carrier_off(dev);
+		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
+	}
+	spin_unlock_irqrestore(&tp->lock, flags);
+}
+
 static void rtl8169_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
@@ -463,6 +490,9 @@ static void rtl8169_set_speed(struct net
 
 	mdio_write(ioaddr, PHY_CTRL_REG,
 		   PHY_Enable_Auto_Nego | PHY_Restart_Auto_Nego);
+
+	if (giga_ctrl & PHY_Cap_1000_Full)
+		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
 }
 
 static int rtl8169_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -695,56 +725,56 @@ static void rtl8169_hw_phy_config(struct
 	mdio_write(ioaddr, 31, 0x0000); //w 31 2 0 0
 }
 
-static void rtl8169_hw_phy_reset(struct net_device *dev)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	void *ioaddr = tp->mmio_addr;
-	int i, val;
-
-	printk(KERN_WARNING PFX "%s: Reset RTL8169s PHY\n", dev->name);
-
-	val = (mdio_read(ioaddr, 0) | 0x8000) & 0xffff;
-	mdio_write(ioaddr, 0, val);
-
-	for (i = 50; i >= 0; i--) {
-		if (!(mdio_read(ioaddr, 0) & 0x8000))
-			break;
-		udelay(100); /* Gross */
-	}
-
-	if (i < 0) {
-		printk(KERN_WARNING PFX "%s: no PHY Reset ack. Giving up.\n",
-		       dev->name);
-	}
-}
-
 static void rtl8169_phy_timer(unsigned long __opaque)
 {
 	struct net_device *dev = (struct net_device *)__opaque;
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 	void *ioaddr = tp->mmio_addr;
+	unsigned long timeout = RTL8169_PHY_TIMEOUT;
+	unsigned int val;
+	u8 status;
 
 	assert(tp->mac_version > RTL_GIGA_MAC_VER_B);
 	assert(tp->phy_version < RTL_GIGA_PHY_VER_G);
 
-	if (RTL_R8(PHYstatus) & LinkStatus)
-		tp->phy_link_down_cnt = 0;
-	else {
-		tp->phy_link_down_cnt++;
-		if (tp->phy_link_down_cnt >= 12) {
-			int reg;
-
-			// If link on 1000, perform phy reset.
-			reg = mdio_read(ioaddr, PHY_1000_CTRL_REG);
-			if (reg & PHY_Cap_1000_Full) 
-				rtl8169_hw_phy_reset(dev);
+	if (!(tp->phy_1000_ctrl_reg & PHY_Cap_1000_Full))
+		return;
+
+	spin_lock_irq(&tp->lock);
 
-			tp->phy_link_down_cnt = 0;
+	if (rtl8169_phy_reset_pending(ioaddr)) {
+		/* 
+		 * A busy loop could burn quite a few cycles on nowadays CPU.
+		 * Let's delay the execution of the timer for a few ticks.
+		 */
+		timeout = 2;
+		goto out_mod_timer;
+	}
+
+	status = RTL_R8(PHYstatus);
+	if (status & LinkStatus) {
+		if (!tp->phy_tried_renegotiate && !(status & _1000bpsF)) {
+			mdio_write(ioaddr, PHY_CTRL_REG,
+				BMCR_ANRESTART | BMCR_ANENABLE);
+			tp->phy_tried_renegotiate = 1;
 		}
+		goto out_unlock;
 	}
 
-	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
+	if (tp->phy_reset_warned == 0) {
+		printk(KERN_WARNING PFX "%s: PHY reset until link up\n",
+		       dev->name);
+		tp->phy_reset_warned = 1;
+	}
+
+	val = (mdio_read(ioaddr, 0) | 0x8000) & 0xffff;
+	mdio_write(ioaddr, 0, val);
+
+out_mod_timer:
+	mod_timer(timer, jiffies + timeout);
+out_unlock:
+	spin_unlock_irq(&tp->lock);
 }
 
 static inline void rtl8169_delete_timer(struct net_device *dev)
@@ -757,8 +787,6 @@ static inline void rtl8169_delete_timer(
 		return;
 
 	del_timer_sync(timer);
-
-	tp->phy_link_down_cnt = 0;
 }
 
 static inline void rtl8169_request_timer(struct net_device *dev)
@@ -770,8 +798,6 @@ static inline void rtl8169_request_timer
 	    (tp->phy_version >= RTL_GIGA_PHY_VER_G))
 		return;
 
-	tp->phy_link_down_cnt = 0;
-
 	init_timer(timer);
 	timer->expires = jiffies + RTL8169_PHY_TIMEOUT;
 	timer->data = (unsigned long)(dev);
@@ -1684,10 +1710,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 			break;
 
 		handled = 1;
-/*
-		if (status & LinkChg)
-			link_changed = RTL_R16 (CSCR) & CSCR_LinkChangeBit;
-*/
+
 		status &= tp->intr_mask;
 		RTL_W16(IntrStatus,
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
@@ -1695,6 +1718,9 @@ rtl8169_interrupt(int irq, void *dev_ins
 		if (!(status & rtl8169_intr_mask))
 			break;
 
+		if (status & LinkChg)
+			rtl8169_check_link_status(dev, tp, ioaddr);
+
 #ifdef CONFIG_R8169_NAPI
 		RTL_W16(IntrMask, rtl8169_intr_mask & ~rtl8169_napi_event);
 		tp->intr_mask = ~rtl8169_napi_event;
@@ -1708,7 +1734,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 		break;
 #else
 		// Rx interrupt 
-		if (status & (RxOK | LinkChg | RxOverflow | RxFIFOOver)) {
+		if (status & (RxOK | RxOverflow | RxFIFOOver)) {
 			rtl8169_rx_interrupt(dev, tp, ioaddr);
 		}
 		// Tx interrupt

_
