From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 11:44:22 +0100
Message-ID: <4F0D6806.4080201@broadcom.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary=------------020506010004050700080604
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Network Development" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"=?UTF-8?B?UmFmYcWCIE1pxYJl?= =?UTF-8?B?Y2tp?=" <zajec5@gmail.com>,
	"Larry Finger" <Larry.Finger@lwfinger.net>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1223 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932404Ab2AKKoj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 05:44:39 -0500
In-Reply-To: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--------------020506010004050700080604
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 8bit

On 01/10/2012 09:15 PM, Linus Torvalds wrote:
> So the wireless on my Macbook Air no longer seems to work with the
> current -git tree.
> 
> The BRCMSMAC driver *used* to work, and no longer does. Also, very
> annoyingly, it's even hard to *compile* the thing, because it used to
> be
> 
>   depends on BCMA=n
> 
> but now it is the exact reverse:
> 
>   depends on BCMA
> 
> so there is no sane way to carry a configuration over from before, and
> things like bisection is a major pain due to having to play idiotic
> configuration games to get it to work across all these modifications.

BCMA support has been added to brcmsmac so now we depend on it. As BCMA
claims the PCI device we had the BCMA=n in place before. I agree that it
makes bisecting a pain in the...

> Ragardless, even once you actually enable BCMA and can get the driver
> to come back, it just doesn't do anything. Maybe there is some
> remaining config problem, but I don't think so. I think the driver is
> just buggered.

Looking at the output I had deja-vu feeling. The issue popped up when we
published part of the patches for BCMA support. I looked into it with
Larry Finger and Rafał Miłecki. We found the reason for the failure, but
it seemed resolved after submitting the remaining patches for BCMA
support. However, it seems to have raised its ugly head.

> Please look into this. I'll obviously be happy test any reasonable suggestions,
> 
>                  Linus
> 

My theory is that the BAR window is not mapped to a valid address. Could
you try to revert the following commit:

commit 439678f8b0fca7aeca06c6581e3679eef618721a
Author: Rafał Miłecki <zajec5@gmail.com>
Date:   Mon Dec 5 19:13:39 2011 +0100

    bcma: pci: use fixed windows when possible

    Some cores are mapped in the fixed way, they registers can be accessed
    all the time.

    Signed-off-by: Rafał Miłecki <zajec5@gmail.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

I have attached the 'revert patch' based on your git master branch.

Gr. AvS

--------------020506010004050700080604
Content-Type: text/plain;
 name=0001-Revert-bcma-pci-use-fixed-windows-when-possible.patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0001-Revert-bcma-pci-use-fixed-windows-when-possible.patch

>From 71e949a668bc8c371dc21f17af01284719f1b383 Mon Sep 17 00:00:00 2001
From: Arend van Spriel <arend@broadcom.com>
Date: Wed, 11 Jan 2012 11:35:05 +0100
Subject: [PATCH] Revert "bcma: pci: use fixed windows when possible"

This reverts commit 439678f8b0fca7aeca06c6581e3679eef618721a.
---
 drivers/bcma/host_pci.c |   32 +++++++++++---------------------
 1 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
index 443b83a..990f5a8 100644
--- a/drivers/bcma/host_pci.c
+++ b/drivers/bcma/host_pci.c
@@ -21,58 +21,48 @@ static void bcma_host_pci_switch_core(struct bcma_device *core)
 	pr_debug("Switched to core: 0x%X\n", core->id.id);
 }
 
-/* Provides access to the requested core. Returns base offset that has to be
- * used. It makes use of fixed windows when possible. */
-static u16 bcma_host_pci_provide_access_to_core(struct bcma_device *core)
+static u8 bcma_host_pci_read8(struct bcma_device *core, u16 offset)
 {
-	switch (core->id.id) {
-	case BCMA_CORE_CHIPCOMMON:
-		return 3 * BCMA_CORE_SIZE;
-	case BCMA_CORE_PCIE:
-		return 2 * BCMA_CORE_SIZE;
-	}
-
 	if (core->bus->mapped_core != core)
 		bcma_host_pci_switch_core(core);
-	return 0;
-}
-
-static u8 bcma_host_pci_read8(struct bcma_device *core, u16 offset)
-{
-	offset += bcma_host_pci_provide_access_to_core(core);
 	return ioread8(core->bus->mmio + offset);
 }
 
 static u16 bcma_host_pci_read16(struct bcma_device *core, u16 offset)
 {
-	offset += bcma_host_pci_provide_access_to_core(core);
+	if (core->bus->mapped_core != core)
+		bcma_host_pci_switch_core(core);
 	return ioread16(core->bus->mmio + offset);
 }
 
 static u32 bcma_host_pci_read32(struct bcma_device *core, u16 offset)
 {
-	offset += bcma_host_pci_provide_access_to_core(core);
+	if (core->bus->mapped_core != core)
+		bcma_host_pci_switch_core(core);
 	return ioread32(core->bus->mmio + offset);
 }
 
 static void bcma_host_pci_write8(struct bcma_device *core, u16 offset,
 				 u8 value)
 {
-	offset += bcma_host_pci_provide_access_to_core(core);
+	if (core->bus->mapped_core != core)
+		bcma_host_pci_switch_core(core);
 	iowrite8(value, core->bus->mmio + offset);
 }
 
 static void bcma_host_pci_write16(struct bcma_device *core, u16 offset,
 				 u16 value)
 {
-	offset += bcma_host_pci_provide_access_to_core(core);
+	if (core->bus->mapped_core != core)
+		bcma_host_pci_switch_core(core);
 	iowrite16(value, core->bus->mmio + offset);
 }
 
 static void bcma_host_pci_write32(struct bcma_device *core, u16 offset,
 				 u32 value)
 {
-	offset += bcma_host_pci_provide_access_to_core(core);
+	if (core->bus->mapped_core != core)
+		bcma_host_pci_switch_core(core);
 	iowrite32(value, core->bus->mmio + offset);
 }
 
-- 
1.7.5.4


--------------020506010004050700080604--
