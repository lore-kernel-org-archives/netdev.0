From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 23 Jan 2008 05:05:18 -0500
Message-ID: <20080123100518.GA12590@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:41216 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750767AbYAWKFU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 05:05:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Francois noted that these warranted promotion from net-2.6.25.git to
current 2.6.24-rc.

NOTE:  These changesets were cherry-picked from net-2.6.25, without any
modifications.  Any future rebase or merge should hopefully notice this
automatically.



Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 drivers/net/sis190.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

Francois Romieu (4):
      sis190: add cmos ram access code for the SiS19x/968 chipset pair
      sis190: remove duplicate INIT_WORK
      sis190: mdio operation failure is not correctly detected
      sis190: scheduling while atomic error

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 7eab072..b570402 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -372,7 +372,7 @@ static void __mdio_cmd(void __iomem *ioaddr, u32 ctl)
 		msleep(1);
 	}
 
-	if (i > 999)
+	if (i > 99)
 		printk(KERN_ERR PFX "PHY command failed !\n");
 }
 
@@ -847,10 +847,8 @@ static void sis190_soft_reset(void __iomem *ioaddr)
 {
 	SIS_W32(IntrControl, 0x8000);
 	SIS_PCI_COMMIT();
-	msleep(1);
 	SIS_W32(IntrControl, 0x0);
 	sis190_asic_down(ioaddr);
-	msleep(1);
 }
 
 static void sis190_hw_start(struct net_device *dev)
@@ -1041,8 +1039,6 @@ static int sis190_open(struct net_device *dev)
 	if (rc < 0)
 		goto err_free_rx_1;
 
-	INIT_WORK(&tp->phy_task, sis190_phy_task);
-
 	sis190_request_timer(dev);
 
 	rc = request_irq(dev->irq, sis190_interrupt, IRQF_SHARED, dev->name, dev);
@@ -1549,28 +1545,31 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
 }
 
 /**
- *	sis190_get_mac_addr_from_apc - Get MAC address for SiS965 model
+ *	sis190_get_mac_addr_from_apc - Get MAC address for SiS96x model
  *	@pdev: PCI device
  *	@dev:  network device to get address for
  *
- *	SiS965 model, use APC CMOS RAM to store MAC address.
+ *	SiS96x model, use APC CMOS RAM to store MAC address.
  *	APC CMOS RAM is accessed through ISA bridge.
  *	MAC address is read into @net_dev->dev_addr.
  */
 static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
 						  struct net_device *dev)
 {
+	static const u16 __devinitdata ids[] = { 0x0965, 0x0966, 0x0968 };
 	struct sis190_private *tp = netdev_priv(dev);
 	struct pci_dev *isa_bridge;
 	u8 reg, tmp8;
-	int i;
+	unsigned int i;
 
 	net_probe(tp, KERN_INFO "%s: Read MAC address from APC.\n",
 		  pci_name(pdev));
 
-	isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0965, NULL);
-	if (!isa_bridge)
-		isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0966, NULL);
+	for (i = 0; i < ARRAY_SIZE(ids); i++) {
+		isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, ids[i], NULL);
+		if (isa_bridge)
+			break;
+	}
 
 	if (!isa_bridge) {
 		net_probe(tp, KERN_INFO "%s: Can not find ISA bridge.\n",
