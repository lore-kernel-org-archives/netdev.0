From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 3/11] r8169: code cleanup
Date: Tue, 24 Aug 2004 00:47:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823224706.GC20726@electric-eye.fr.zoreil.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com> <20040823224425.GA20726@electric-eye.fr.zoreil.com> <20040823224548.GB20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040823224548.GB20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup/code removal:
- MAX_ETH_FRAME_SIZE is not used;
- removal of assertion for impossible condition (if it happens, it will _not_
  take long to notice anyway)
- introduce rtl8169_release_board() to factor out some code;
- rtl8169_init_board:
  - some variables are not really needed nor do they help read the code;
  - more explicit name for label;
- tp->{Rx/Tx}DescArray: no need to zeroize coherent DMA mapping.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-020 drivers/net/r8169.c
--- linux-2.6.8.1/drivers/net/r8169.c~r8169-020	2004-08-23 23:29:59.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/r8169.c	2004-08-23 23:29:59.000000000 +0200
@@ -87,9 +87,6 @@ static int multicast_filter_limit = 32;
 /* MAC address length*/
 #define MAC_ADDR_LEN	6
 
-/* max supported gigabit ethernet frame size -- must be at least (dev->mtu+14+4).*/
-#define MAX_ETH_FRAME_SIZE	1536
-
 #define TX_FIFO_THRESH 256	/* In bytes */
 
 #define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer.  */
@@ -928,28 +925,31 @@ static inline void rtl8169_request_timer
 	add_timer(timer);
 }
 
+static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
+				  void *ioaddr)
+{
+	iounmap(ioaddr);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	free_netdev(dev);
+}
+
 static int __devinit
 rtl8169_init_board(struct pci_dev *pdev, struct net_device **dev_out,
 		   void **ioaddr_out)
 {
-	void *ioaddr = NULL;
+	void *ioaddr;
 	struct net_device *dev;
 	struct rtl8169_private *tp;
-	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
-	int rc, i, acpi_idle_state = 0, pm_cap;
+	int rc = -ENOMEM, i, acpi_idle_state = 0, pm_cap;
 
-
-	assert(pdev != NULL);
 	assert(ioaddr_out != NULL);
 
-	*ioaddr_out = NULL;
-	*dev_out = NULL;
-
 	// dev zeroed in alloc_etherdev 
 	dev = alloc_etherdev(sizeof (*tp));
 	if (dev == NULL) {
 		printk(KERN_ERR PFX "unable to alloc new ethernet\n");
-		return -ENOMEM;
+		goto err_out;
 	}
 
 	SET_MODULE_OWNER(dev);
@@ -960,7 +960,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 	rc = pci_enable_device(pdev);
 	if (rc) {
 		printk(KERN_ERR PFX "%s: enable failure\n", pdev->slot_name);
-		goto err_out;
+		goto err_out_free_dev;
 	}
 
 	/* save power state before pci_enable_device overwrites it */
@@ -976,20 +976,15 @@ rtl8169_init_board(struct pci_dev *pdev,
 		goto err_out_free_res;
 	}
 
-	mmio_start = pci_resource_start(pdev, 1);
-	mmio_end = pci_resource_end(pdev, 1);
-	mmio_flags = pci_resource_flags(pdev, 1);
-	mmio_len = pci_resource_len(pdev, 1);
-
 	// make sure PCI base addr 1 is MMIO
-	if (!(mmio_flags & IORESOURCE_MEM)) {
+	if (!(pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
 		printk(KERN_ERR PFX
 		       "region #1 not an MMIO resource, aborting\n");
 		rc = -ENODEV;
 		goto err_out_disable;
 	}
 	// check for weird/broken PCI region reporting
-	if (mmio_len < R8169_REGS_SIZE) {
+	if (pci_resource_len(pdev, 1) < R8169_REGS_SIZE) {
 		printk(KERN_ERR PFX "Invalid PCI region size(s), aborting\n");
 		rc = -ENODEV;
 		goto err_out_disable;
@@ -1020,7 +1015,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 	pci_set_master(pdev);
 
 	// ioremap MMIO region 
-	ioaddr = ioremap(mmio_start, mmio_len);
+	ioaddr = ioremap(pci_resource_start(pdev, 1), R8169_REGS_SIZE);
 	if (ioaddr == NULL) {
 		printk(KERN_ERR PFX "cannot remap MMIO, aborting\n");
 		rc = -EIO;
@@ -1061,7 +1056,8 @@ rtl8169_init_board(struct pci_dev *pdev,
 
 	*ioaddr_out = ioaddr;
 	*dev_out = dev;
-	return 0;
+out:
+	return rc;
 
 err_out_free_res:
 	pci_release_regions(pdev);
@@ -1069,16 +1065,19 @@ err_out_free_res:
 err_out_disable:
 	pci_disable_device(pdev);
 
-err_out:
+err_out_free_dev:
 	free_netdev(dev);
-	return rc;
+err_out:
+	*ioaddr_out = NULL;
+	*dev_out = NULL;
+	goto out;
 }
 
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev = NULL;
-	struct rtl8169_private *tp = NULL;
+	struct rtl8169_private *tp;
 	void *ioaddr = NULL;
 	static int board_idx = -1;
 	static int printed_version = 0;
@@ -1102,8 +1101,6 @@ rtl8169_init_one(struct pci_dev *pdev, c
 
 	tp = dev->priv;
 	assert(ioaddr != NULL);
-	assert(dev != NULL);
-	assert(tp != NULL);
 
 	if (RTL_R8(PHYstatus) & TBI_Enable) {
 		tp->set_speed = rtl8169_set_speed_tbi;
@@ -1148,10 +1145,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 
 	rc = register_netdev(dev);
 	if (rc) {
-		iounmap(ioaddr);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		free_netdev(dev);
+		rtl8169_release_board(pdev, dev, ioaddr);
 		return rc;
 	}
 
@@ -1207,11 +1201,7 @@ rtl8169_remove_one(struct pci_dev *pdev)
 	assert(tp != NULL);
 
 	unregister_netdev(dev);
-	iounmap(tp->mmio_addr);
-	pci_release_regions(pdev);
-
-	pci_disable_device(pdev);
-	free_netdev(dev);
+	rtl8169_release_board(pdev, dev, tp->mmio_addr);
 	pci_set_drvdata(pdev, NULL);
 }
 
@@ -1474,8 +1464,6 @@ static int rtl8169_init_ring(struct net_
 
 	tp->cur_rx = tp->dirty_rx = 0;
 	tp->cur_tx = tp->dirty_tx = 0;
-	memset(tp->TxDescArray, 0x0, NUM_TX_DESC * sizeof (struct TxDesc));
-	memset(tp->RxDescArray, 0x0, NUM_RX_DESC * sizeof (struct RxDesc));
 
 	memset(tp->Tx_skbuff, 0x0, NUM_TX_DESC * sizeof(struct sk_buff *));
 	memset(tp->Rx_skbuff, 0x0, NUM_RX_DESC * sizeof(struct sk_buff *));

_
