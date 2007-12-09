From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: SIS190 Ethernet Driver check for ISA bridge on "SiS968"
	MotherBoards...
Date: Sun, 9 Dec 2007 23:20:12 +0100
Message-ID: <20071209222012.GA14174@electric-eye.fr.zoreil.com>
References: <acbb94d60712090816k72f72ab9m4d46665e7a6823c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "J. Gleacher" <jgleacher@yahoo.com>,
	Alexandre Penasso Teixeira <alexandre@keepsoftware.com>
To: Arliton Rocha <arliton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40488 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751454AbXLIW0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2007 17:26:21 -0500
Content-Disposition: inline
In-Reply-To: <acbb94d60712090816k72f72ab9m4d46665e7a6823c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arliton Rocha <arliton@gmail.com> :
[...]
> Please, can you made sis190 ethernet driver check for isa bridge on
> "sis968" motherboards?
> SiS(R) 191 Gigabit Ethernet
> 
> Similar
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=8eb7ad68bd10d858066ca51713ca5645996e77a5
[...]
> It's Work!

I'd rather avoid the code duplication. Does the patch below do the
work ?

Can you send the output of a 'lspci -vvvxxxx' + 'mii-diag -v' and the brand
name of the motherboard ? Apparently all 968 based devices do not behave the
same (see http://bugzilla.kernel.org/show_bug.cgi?id=9386 for instance).

>From 38c4947eb946db4b5daea0fb37c1ca515ab803d6 Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 4 Dec 2007 22:58:41 +0100
Subject: [PATCH] sis190: add cmos ram access code for the SiS19x/968 chipset pair

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: J. Gleacher <jgleacher@yahoo.com>
Cc: Alexandre Penasso Teixeira <alexandre@keepsoftware.com>
---
 drivers/net/sis190.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b644bc4..ad392c2 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1582,28 +1582,31 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
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
