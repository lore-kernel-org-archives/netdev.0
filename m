From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc2-mm1 1/1] r8169: default on disabling PCIDAC
Date: Mon, 20 Sep 2004 00:42:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919224231.GB32577@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Default to disabling PCI DAC as this option appears unsafe on amd64
(original suggestion by Hans-Frieder Vogt <hfvogt@arcor.de>).

The driver will typically report PCI System error when something goes
wrong. The relevant interrupt is not masked any more and the driver
can thus be disabled.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-145a drivers/net/r8169.c
--- linux-2.6.9-rc2/drivers/net/r8169.c~r8169-145a	2004-09-19 00:17:04.000000000 +0200
+++ linux-2.6.9-rc2-fr/drivers/net/r8169.c	2004-09-20 00:16:02.000000000 +0200
@@ -171,6 +171,7 @@ static struct pci_device_id rtl8169_pci_
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_copybreak = 200;
+static int use_dac;
 
 enum RTL8169_registers {
 	MAC0 = 0,		/* Ethernet hardware address. */
@@ -405,6 +406,8 @@ MODULE_AUTHOR("Realtek");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 MODULE_PARM(media, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM(rx_copybreak, "i");
+MODULE_PARM(use_dac, "i");
+MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
 MODULE_LICENSE("GPL");
 
 static int rtl8169_open(struct net_device *dev);
@@ -422,7 +425,7 @@ static int rtl8169_poll(struct net_devic
 #endif
 
 static const u16 rtl8169_intr_mask =
-	LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
+	SYSErr | LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
 static const u16 rtl8169_napi_event =
 	RxOK | RxOverflow | RxFIFOOver | TxOK | TxErr;
 static const unsigned int rtl8169_rx_config =
@@ -1162,7 +1165,8 @@ rtl8169_init_board(struct pci_dev *pdev,
 
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 
-	if ((sizeof(dma_addr_t) > 4) && !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if ((sizeof(dma_addr_t) > 4) &&
+	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK) && use_dac) {
 		tp->cp_cmd |= PCIDAC;
 		dev->features |= NETIF_F_HIGHDMA;
 	} else {
@@ -2050,6 +2054,15 @@ rtl8169_interrupt(int irq, void *dev_ins
 		if (!(status & rtl8169_intr_mask))
 			break;
 
+		if (unlikely(status & SYSErr)) {
+			printk(KERN_ERR PFX "%s: PCI error (status: 0x%04x)."
+			       " Device disabled.\n", dev->name, status);
+			RTL_W8(ChipCmd, 0x00);
+			RTL_W16(IntrMask, 0x0000);
+			RTL_R16(IntrMask);
+			break;
+		}
+
 		if (status & LinkChg)
 			rtl8169_check_link_status(dev, tp, ioaddr);
 

_
