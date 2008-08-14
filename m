From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 3/3] Adapt the e100 driver to the reworked PCI PM
Date: Thu, 14 Aug 2008 23:40:24 +0200
Message-ID: <200808142340.25574.rjw@sisk.pl>
References: <200808142335.56644.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	LKML <linux-kernel@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:56451 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752648AbYHNVh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 17:37:59 -0400
In-Reply-To: <200808142335.56644.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Note: I have no hardware to test this patch, but it seems pretty
straightforward.]

Adapt the e100 driver to the reworked PCI PM

* Use device_set_wakeup_enable() and friends as needed
* Use pci_pme_active() to clear PME_Status and disable PME#
* Use the observation that it is sufficient to call pci_enable_wake()
  once, unless it fails

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/e100.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

Index: linux-2.6/drivers/net/e100.c
===================================================================
--- linux-2.6.orig/drivers/net/e100.c
+++ linux-2.6/drivers/net/e100.c
@@ -2322,7 +2322,8 @@ static int e100_set_wol(struct net_devic
 {
 	struct nic *nic = netdev_priv(netdev);
 
-	if(wol->wolopts != WAKE_MAGIC && wol->wolopts != 0)
+	if ((wol->wolopts && wol->wolopts != WAKE_MAGIC) ||
+	    !device_can_wakeup(&nic->pdev->dev))
 		return -EOPNOTSUPP;
 
 	if(wol->wolopts)
@@ -2330,6 +2331,8 @@ static int e100_set_wol(struct net_devic
 	else
 		nic->flags &= ~wol_magic;
 
+	device_set_wakeup_enable(&nic->pdev->dev, wol->wolopts);
+
 	e100_exec_cb(nic, NULL, e100_configure);
 
 	return 0;
@@ -2734,13 +2737,13 @@ static int __devinit e100_probe(struct p
 
 	/* Wol magic packet can be enabled from eeprom */
 	if((nic->mac >= mac_82558_D101_A4) &&
-	   (nic->eeprom[eeprom_id] & eeprom_id_wol))
+	   (nic->eeprom[eeprom_id] & eeprom_id_wol)) {
 		nic->flags |= wol_magic;
+		device_set_wakeup_enable(&pdev->dev, true);
+	}
 
 	/* ack any pending wake events, disable PME */
-	err = pci_enable_wake(pdev, 0, 0);
-	if (err)
-		DPRINTK(PROBE, ERR, "Error clearing wake event\n");
+	pci_pme_active(pdev, false);
 
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
@@ -2796,11 +2799,10 @@ static int e100_suspend(struct pci_dev *
 	pci_save_state(pdev);
 
 	if ((nic->flags & wol_magic) | e100_asf(nic)) {
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
+		if (pci_enable_wake(pdev, PCI_D3cold, true))
+			pci_enable_wake(pdev, PCI_D3hot, true);
 	} else {
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
+		pci_enable_wake(pdev, PCI_D3hot, false);
 	}
 
 	pci_disable_device(pdev);

