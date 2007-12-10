From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/4] sis190: add cmos ram access code for the SiS19x/968
	chipset pair
Date: Mon, 10 Dec 2007 23:29:19 +0100
Message-ID: <20071210222919.GB8675@electric-eye.fr.zoreil.com>
References: <20071210222732.GA8675@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"K.M. Liu" <kmliu@sis.com.tw>, "J. Gleacher" <jgleacher@yahoo.com>,
	Alexandre Penasso Teixeira <alexandre@keepsoftware.com>,
	Arliton Rocha <arliton@gmail.com>,
	Juan Jose Pablos <juanjo@apertus.es>,
	Wipat Srutiprom <wipat.s@psu.ac.th>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50909 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751818AbXLJWiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 17:38:05 -0500
Content-Disposition: inline
In-Reply-To: <20071210222732.GA8675@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More work is needed to handle correctly the PHY of the new devices
when connected to a 10Mb link but this change already helps some
users as is.

Fix for:
http://bugzilla.kernel.org/show_bug.cgi?id=9467

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: K.M. Liu <kmliu@sis.com.tw>
Cc: J. Gleacher <jgleacher@yahoo.com>
Cc: Alexandre Penasso Teixeira <alexandre@keepsoftware.com>
Cc: Arliton Rocha <arliton@gmail.com>
Cc: Juan Jose Pablos <juanjo@apertus.es>
Cc: Wipat Srutiprom <wipat.s@psu.ac.th>
---
 drivers/net/sis190.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 7200883..51bbb60 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1549,28 +1549,31 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
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
1.5.3.3

