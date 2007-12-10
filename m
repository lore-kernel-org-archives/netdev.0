From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/4] Pull request for 'sis190' branch
Date: Mon, 10 Dec 2007 23:27:32 +0100
Message-ID: <20071210222732.GA8675@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"K.M. Liu" <kmliu@sis.com.tw>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39503 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751600AbXLJWeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 17:34:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'sis190' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git sis190

to get the changes below.

Distance from 'upstream-linus' (7962024e9d16e9349d76b553326f3fa7be64305e)
-------------------------------------------------------------------------

c27e14e508664471b8e44ef1f81ec080213ea314
348de67fe200e25d8cb80cff35642192436cfeda
004a22d03d62cd08e5287273a5143447db009cd0
14deb44ffe7220be2de697d616f28cce17e72297

Diffstat
--------

 drivers/net/sis190.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

Shortlog
--------

Francois Romieu (4):
      sis190: add cmos ram access code for the SiS19x/968 chipset pair
      sis190: remove duplicate INIT_WORK
      sis190: mdio operation failure is not correctly detected
      sis190: scheduling while atomic error

Patch
-----

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 7200883..c0db182 100644
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
-- 
Ueimor
