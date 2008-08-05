From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: "e100_probe: Error clearing wake event" when booting 2.6.27-rc1
Date: Tue, 5 Aug 2008 22:03:07 +0200
Message-ID: <200808052203.07815.rjw@sisk.pl>
References: <200808051730.27599.alessandro.guido@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	pm list <linux-pm@lists.linux-foundation.org>
To: Alessandro Guido <alessandro.guido@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:52928 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761394AbYHEUA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 16:00:26 -0400
In-Reply-To: <200808051730.27599.alessandro.guido@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, 5 of August 2008, Alessandro Guido wrote:
> [please cc me on replies]
> 
> I'm getting this error message when booting my laptop.
> 
> The commit that causes this is:
> 
> commit eb9d0fe40e313c0a74115ef456a2e43a6c8da72f
> Author: Rafael J. Wysocki <rjw@sisk.pl>
> Date:   Mon Jul 7 03:34:48 2008 +0200
> 
>     PCI ACPI: Rework PCI handling of wake-up
> 
> [very long commit message snipped]
> 
> Should I ignore that?

The message is harmless, but it exposes the problem that e100_probe() should
not use pci_enable_wake() for this purpose.

The appended patch makes it use pci_pme_active() instead.

Thanks,
Rafael

---
PCI PM: Export pci_pme_active to drivers

Export pci_pme_active() to drivers, so that they can clear the
PME_status bit and disable PME# for the device without involving
ACPI.

Modify the e100 driver to use pci_pme_active() for this purpose.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/e100.c  |    4 +---
 drivers/pci/pci.c   |    3 ++-
 include/linux/pci.h |    1 +
 3 files changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/pci/pci.c
===================================================================
--- linux-2.6.orig/drivers/pci/pci.c
+++ linux-2.6/drivers/pci/pci.c
@@ -1060,7 +1060,7 @@ bool pci_pme_capable(struct pci_dev *dev
  * The caller must verify that the device is capable of generating PME# before
  * calling this function with @enable equal to 'true'.
  */
-static void pci_pme_active(struct pci_dev *dev, bool enable)
+void pci_pme_active(struct pci_dev *dev, bool enable)
 {
 	u16 pmcsr;
 
@@ -1945,6 +1945,7 @@ EXPORT_SYMBOL(pci_set_power_state);
 EXPORT_SYMBOL(pci_save_state);
 EXPORT_SYMBOL(pci_restore_state);
 EXPORT_SYMBOL(pci_pme_capable);
+EXPORT_SYMBOL(pci_pme_active);
 EXPORT_SYMBOL(pci_enable_wake);
 EXPORT_SYMBOL(pci_target_state);
 EXPORT_SYMBOL(pci_prepare_to_sleep);
Index: linux-2.6/include/linux/pci.h
===================================================================
--- linux-2.6.orig/include/linux/pci.h
+++ linux-2.6/include/linux/pci.h
@@ -648,6 +648,7 @@ int pci_restore_state(struct pci_dev *de
 int pci_set_power_state(struct pci_dev *dev, pci_power_t state);
 pci_power_t pci_choose_state(struct pci_dev *dev, pm_message_t state);
 bool pci_pme_capable(struct pci_dev *dev, pci_power_t state);
+void pci_pme_active(struct pci_dev *dev, bool enable);
 int pci_enable_wake(struct pci_dev *dev, pci_power_t state, int enable);
 pci_power_t pci_target_state(struct pci_dev *dev);
 int pci_prepare_to_sleep(struct pci_dev *dev);
Index: linux-2.6/drivers/net/e100.c
===================================================================
--- linux-2.6.orig/drivers/net/e100.c
+++ linux-2.6/drivers/net/e100.c
@@ -2738,9 +2738,7 @@ static int __devinit e100_probe(struct p
 		nic->flags |= wol_magic;
 
 	/* ack any pending wake events, disable PME */
-	err = pci_enable_wake(pdev, 0, 0);
-	if (err)
-		DPRINTK(PROBE, ERR, "Error clearing wake event\n");
+	pci_pme_active(pdev, false);
 
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
