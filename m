From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] 2.6.0-test11-bk27-netdrvr-exp1 - r8169 update
Date: Thu, 27 Nov 2003 23:51:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031127235143.A16767@electric-eye.fr.zoreil.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <20031126004550.A25408@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ReaqsoxgOBHFXBhH"
Cc: Jeff Garzik <jgarzik@pobox.com>, brad_mssw@gentoo.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031126004550.A25408@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Wed, Nov 26, 2003 at 12:45:50AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Even more Brad/Realtek's merging. 

Applies on top of:
  2.6.0-test11
+ 2.6.0-test9-bk25-netdrvr-exp1
+ r8169-mac-phy-version
+ r8169-init_one

--
Ueimor

--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-timer.patch"


Merge of timer related changes from Realtek:
- changed their timeout value from 100 to HZ to trigger rtl8169_phy_timer();
- s/TX_TIMEOUT/RTL8169_TX_TIMEOUT/ to have RTL8169_{TX/PHY}_TIMEOUT.


 drivers/net/r8169.c |   94 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 92 insertions(+), 2 deletions(-)

diff -puN drivers/net/r8169.c~r8169-timer drivers/net/r8169.c
--- linux-2.6.0-test11/drivers/net/r8169.c~r8169-timer	2003-11-27 22:14:24.000000000 +0100
+++ linux-2.6.0-test11-fr/drivers/net/r8169.c	2003-11-27 23:50:41.000000000 +0100
@@ -95,7 +95,8 @@ static int multicast_filter_limit = 32;
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
 
 #define RTL_MIN_IO_SIZE 0x80
-#define TX_TIMEOUT  (6*HZ)
+#define RTL8169_TX_TIMEOUT	(6*HZ)
+#define RTL8169_PHY_TIMEOUT	(HZ) 
 
 /* write/read MMIO register */
 #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
@@ -311,6 +312,8 @@ struct rtl8169_private {
 	dma_addr_t RxPhyAddr;
 	struct sk_buff *Rx_skbuff[NUM_RX_DESC];	/* Rx data buffers */
 	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Index of Transmit data buffer */
+	struct timer_list timer;
+	unsigned long phy_link_down_cnt;
 };
 
 MODULE_AUTHOR("Realtek");
@@ -540,6 +543,90 @@ static void rtl8169_hw_phy_config(struct
 	mdio_write(ioaddr, 31, 0x0000); //w 31 2 0 0
 }
 
+static void rtl8169_hw_phy_reset(struct net_device *dev)
+{
+	struct rtl8169_private *tp = dev->priv;
+	void *ioaddr = tp->mmio_addr;
+	int i, val;
+
+	printk(KERN_WARNING PFX "%s: Reset RTL8169s PHY\n", dev->name);
+
+	val = (mdio_read(ioaddr, 0) | 0x8000) & 0xffff;
+	mdio_write(ioaddr, 0, val);
+
+	for (i = 50; i >= 0; i--) {
+		if (!(mdio_read(ioaddr, 0) & 0x8000))
+			break;
+		udelay(100); /* Gross */
+	}
+
+	if (i < 0) {
+		printk(KERN_WARNING PFX "%s: no PHY Reset ack. Giving up.\n",
+		       dev->name);
+	}
+}
+
+static void rtl8169_phy_timer(unsigned long __opaque)
+{
+	struct net_device *dev = (struct net_device *)__opaque;
+	struct rtl8169_private *tp = dev->priv;
+	struct timer_list *timer = &tp->timer;
+	void *ioaddr = tp->mmio_addr;
+
+	assert(tp->mac_version > RTL_GIGA_MAC_VER_B);
+	assert(tp->phy_version < RTL_GIGA_PHY_VER_G);
+
+	if (RTL_R8(PHYstatus) & LinkStatus)
+		tp->phy_link_down_cnt = 0;
+	else {
+		tp->phy_link_down_cnt++;
+		if (tp->phy_link_down_cnt >= 12) {
+			int reg;
+
+			// If link on 1000, perform phy reset.
+			reg = mdio_read(ioaddr, PHY_1000_CTRL_REG);
+			if (reg & PHY_Cap_1000_Full) 
+				rtl8169_hw_phy_reset(dev);
+
+			tp->phy_link_down_cnt = 0;
+		}
+	}
+
+	mod_timer(timer, RTL8169_PHY_TIMEOUT);
+}
+
+static inline void rtl8169_delete_timer(struct net_device *dev)
+{
+	struct rtl8169_private *tp = dev->priv;
+	struct timer_list *timer = &tp->timer;
+
+	if ((tp->mac_version <= RTL_GIGA_MAC_VER_B) ||
+	    (tp->phy_version >= RTL_GIGA_PHY_VER_G))
+		return;
+
+	del_timer_sync(timer);
+
+	tp->phy_link_down_cnt = 0;
+}
+
+static inline void rtl8169_request_timer(struct net_device *dev)
+{
+	struct rtl8169_private *tp = dev->priv;
+	struct timer_list *timer = &tp->timer;
+
+	if ((tp->mac_version <= RTL_GIGA_MAC_VER_B) ||
+	    (tp->phy_version >= RTL_GIGA_PHY_VER_G))
+		return;
+
+	tp->phy_link_down_cnt = 0;
+
+	init_timer(timer);
+	timer->expires = jiffies + RTL8169_PHY_TIMEOUT;
+	timer->data = (unsigned long)(dev);
+	timer->function = rtl8169_phy_timer;
+	add_timer(timer);
+}
+
 static int __devinit
 rtl8169_init_board(struct pci_dev *pdev, struct net_device **dev_out,
 		   void **ioaddr_out)
@@ -691,7 +778,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->stop = rtl8169_close;
 	dev->tx_timeout = rtl8169_tx_timeout;
 	dev->set_multicast_list = rtl8169_set_rx_mode;
-	dev->watchdog_timeo = TX_TIMEOUT;
+	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
 //      dev->do_ioctl           = mii_ioctl;
@@ -892,6 +979,7 @@ rtl8169_open(struct net_device *dev)
 
 	rtl8169_hw_start(dev);
 
+	rtl8169_request_timer(dev);
 out:
 	return retval;
 
@@ -1385,6 +1473,8 @@ rtl8169_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
+	rtl8169_delete_timer(dev);
+
 	spin_lock_irq(&tp->lock);
 
 	/* Stop the chip's Tx and Rx DMA processes. */

_

--ReaqsoxgOBHFXBhH--
