From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.6-mm4 3/4] r8169: link handling and phy reset rework
Date: Thu, 20 May 2004 14:40:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520144032.C30304@electric-eye.fr.zoreil.com>
References: <20040520143500.A28948@electric-eye.fr.zoreil.com> <20040520143735.A30304@electric-eye.fr.zoreil.com> <20040520143841.B30304@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040520143841.B30304@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Thu, May 20, 2004 at 02:38:41PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Link handling changes (Andy Lutomirski <luto@myrealbox.com>):
- the LinkChg irq enables the phy timer when the link goes down;
- the phy timer is enabled in rtl8169_set_speed() to protect against
  link negociation failure;
- removed rtl8169_hw_phy_reset() and its busy loop;
- RTL8169_PHY_TIMEOUT is x10 to account for the removal of the
  phy_link_down_cnt loop in rtl8169_phy_timer();
- added spinlocking in timer context for rtl8169_phy_timer to avoid
  messing with the {set/get}_settings commands issued via ethtool;
- more TBI stuff.

diff -puN drivers/net/r8169.c~r8169-link-00 drivers/net/r8169.c
--- linux-2.6.6-mm4/drivers/net/r8169.c~r8169-link-00	2004-05-20 13:17:43.000000000 +0200
+++ linux-2.6.6-mm4-fr/drivers/net/r8169.c	2004-05-20 13:31:57.000000000 +0200
@@ -41,6 +41,7 @@ VERSION 1.2	<2002/11/30>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
 #include <linux/ethtool.h>
+#include <linux/mii.h>
 #include <linux/crc32.h>
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
@@ -107,7 +108,7 @@ static int multicast_filter_limit = 32;
 
 #define RTL_MIN_IO_SIZE 0x80
 #define RTL8169_TX_TIMEOUT	(6*HZ)
-#define RTL8169_PHY_TIMEOUT	(HZ) 
+#define RTL8169_PHY_TIMEOUT	(10*HZ)
 
 /* write/read MMIO register */
 #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
@@ -341,7 +342,7 @@ struct rtl8169_private {
 	struct sk_buff *Rx_skbuff[NUM_RX_DESC];	/* Rx data buffers */
 	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Tx data buffers */
 	struct timer_list timer;
-	unsigned long phy_link_down_cnt;
+	unsigned int phy_tried_renegotiate;	/* renegotiation hack */
 	u16 cp_cmd;
 	u16 intr_mask;
 	int phy_auto_nego_reg;
@@ -349,6 +350,10 @@ struct rtl8169_private {
 
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
 	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
+	void (*phy_reset_enable)(void *);
+	unsigned int (*phy_reset_pending)(void *);
+	unsigned int (*link_ok)(void *);
+	void (*andy_s_phy_renegotiation_hack)(struct rtl8169_private *);
 };
 
 MODULE_AUTHOR("Realtek");
@@ -374,7 +379,7 @@ static int rtl8169_poll(struct net_devic
 static const u16 rtl8169_intr_mask =
 	LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
 static const u16 rtl8169_napi_event =
-	RxOK | LinkChg | RxOverflow | RxFIFOOver | TxOK | TxErr;
+	RxOK | RxOverflow | RxFIFOOver | TxOK | TxErr;
 static const unsigned int rtl8169_rx_config =
     (RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
 
@@ -416,6 +421,66 @@ static int mdio_read(void *ioaddr, int R
 	return value;
 }
 
+static unsigned int rtl8169_tbi_reset_pending(void *ioaddr)
+{
+	return RTL_R32(TBICSR) & TBIReset;
+}
+
+static unsigned int rtl8169_xmii_reset_pending(void *ioaddr)
+{
+	return mdio_read(ioaddr, 0) & 0x8000;
+}
+
+static unsigned int rtl8169_tbi_link_ok(void *ioaddr)
+{
+	return RTL_R32(TBICSR) & TBILinkOk;
+}
+
+static unsigned int rtl8169_xmii_link_ok(void *ioaddr)
+{
+	return RTL_R8(PHYstatus) & LinkStatus;
+}
+
+static void rtl8169_tbi_reset_enable(void *ioaddr)
+{
+	RTL_W32(TBICSR, RTL_R32(TBICSR) | TBIReset);
+}
+
+static void rtl8169_xmii_reset_enable(void *ioaddr)
+{
+	unsigned int val;
+
+	val = (mdio_read(ioaddr, PHY_CTRL_REG) | 0x8000) & 0xffff;
+	mdio_write(ioaddr, PHY_CTRL_REG, val);
+}
+
+static void rtl8169_xmii_renegotiation_hack(struct rtl8169_private *tp)
+{
+	void *ioaddr = tp->mmio_addr;
+
+	if (!tp->phy_tried_renegotiate && !(RTL_R8(PHYstatus) & _1000bpsF)) {
+		mdio_write(ioaddr, PHY_CTRL_REG,
+			   BMCR_ANRESTART | BMCR_ANENABLE);
+		tp->phy_tried_renegotiate++;
+	}
+}
+
+static void rtl8169_check_link_status(struct net_device *dev,
+				      struct rtl8169_private *tp, void *ioaddr)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&tp->lock, flags);
+	if (!tp->link_ok(ioaddr)) {
+		netif_carrier_on(dev);
+		printk(KERN_INFO PFX "%s: link up\n", dev->name);
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
@@ -493,8 +558,14 @@ static int rtl8169_set_speed(struct net_
 			     u8 autoneg, u16 speed, u8 duplex)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	int ret;
 
-	return tp->set_speed(dev, autoneg, speed, duplex);
+	ret = tp->set_speed(dev, autoneg, speed, duplex);
+
+	if (tp->phy_1000_ctrl_reg & PHY_Cap_1000_Full)
+		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
+
+	return ret;
 }
 
 static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -753,56 +824,46 @@ static void rtl8169_hw_phy_config(struct
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
 
-			tp->phy_link_down_cnt = 0;
-		}
+	spin_lock_irq(&tp->lock);
+
+	if (tp->phy_reset_pending(ioaddr)) {
+		/* 
+		 * A busy loop could burn quite a few cycles on nowadays CPU.
+		 * Let's delay the execution of the timer for a few ticks.
+		 */
+		timeout = HZ/10;
+		goto out_mod_timer;
+	}
+
+	if (tp->link_ok(ioaddr)) {
+		/* Nothing personal here. Simple documentation purpose :o) */
+		if (tp->andy_s_phy_renegotiation_hack)
+			tp->andy_s_phy_renegotiation_hack(tp);
+		goto out_unlock;
 	}
 
-	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
+	printk(KERN_WARNING PFX "%s: PHY reset until link up\n", dev->name);
+
+	tp->phy_reset_enable(ioaddr);
+
+out_mod_timer:
+	mod_timer(timer, jiffies + timeout);
+out_unlock:
+	spin_unlock_irq(&tp->lock);
 }
 
 static inline void rtl8169_delete_timer(struct net_device *dev)
@@ -815,8 +876,6 @@ static inline void rtl8169_delete_timer(
 		return;
 
 	del_timer_sync(timer);
-
-	tp->phy_link_down_cnt = 0;
 }
 
 static inline void rtl8169_request_timer(struct net_device *dev)
@@ -828,8 +887,6 @@ static inline void rtl8169_request_timer
 	    (tp->phy_version >= RTL_GIGA_PHY_VER_G))
 		return;
 
-	tp->phy_link_down_cnt = 0;
-
 	init_timer(timer);
 	timer->expires = jiffies + RTL8169_PHY_TIMEOUT;
 	timer->data = (unsigned long)(dev);
@@ -1014,11 +1071,20 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	if (RTL_R8(PHYstatus) & TBI_Enable) {
 		tp->set_speed = rtl8169_set_speed_tbi;
 		tp->get_settings = rtl8169_gset_tbi;
+		tp->phy_reset_enable = rtl8169_tbi_reset_enable;
+		tp->phy_reset_pending = rtl8169_tbi_reset_pending;
+		tp->link_ok = rtl8169_tbi_link_ok;
 
 		tp->phy_1000_ctrl_reg = PHY_Cap_1000_Full; /* Implied by TBI */
 	} else {
 		tp->set_speed = rtl8169_set_speed_xmii;
 		tp->get_settings = rtl8169_gset_xmii;
+		tp->phy_reset_enable = rtl8169_xmii_reset_enable;
+		tp->phy_reset_pending = rtl8169_xmii_reset_pending;
+		tp->link_ok = rtl8169_xmii_link_ok;
+
+		tp->andy_s_phy_renegotiation_hack =
+			rtl8169_xmii_renegotiation_hack;
 	}
 
 	// Get MAC address.  FIXME: read EEPROM
@@ -1752,10 +1818,7 @@ rtl8169_interrupt(int irq, void *dev_ins
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
@@ -1763,6 +1826,9 @@ rtl8169_interrupt(int irq, void *dev_ins
 		if (!(status & rtl8169_intr_mask))
 			break;
 
+		if (status & LinkChg)
+			rtl8169_check_link_status(dev, tp, ioaddr);
+
 #ifdef CONFIG_R8169_NAPI
 		RTL_W16(IntrMask, rtl8169_intr_mask & ~rtl8169_napi_event);
 		tp->intr_mask = ~rtl8169_napi_event;
@@ -1776,7 +1842,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 		break;
 #else
 		// Rx interrupt 
-		if (status & (RxOK | LinkChg | RxOverflow | RxFIFOOver)) {
+		if (status & (RxOK | RxOverflow | RxFIFOOver)) {
 			rtl8169_rx_interrupt(dev, tp, ioaddr);
 		}
 		// Tx interrupt

_
