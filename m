From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] igb/e1000e/e1000/e100: make wol usable
Date: Tue, 21 Jul 2009 17:01:15 -0400
Message-ID: <20090721210115.GL8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38333 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753564AbZGUVCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 17:02:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It seems that the patches that intended to use the new calls to check
status and capabilities for WOL and fix it up:

    commit bc79fc8409b3dccbde072e8113cc1fb3fd876fc5
    Author: Rafael J. Wysocki <rjw@sisk.pl>
    Date:   Wed Oct 29 14:22:18 2008 -0700

        e100: adapt to the reworked PCI PM

    commit e1b86d8479f90aadee57a3d07d8e61c815c202d9
    Author: Rafael J. Wysocki <rjw@sisk.pl>
    Date:   Fri Nov 7 20:30:37 2008 +0000

        igb: Use device_set_wakeup_enable

    commit de1264896c8012a261c1cba17e6a61199c276ad3
    Author: Rafael J. Wysocki <rjw@sisk.pl>
    Date:   Fri Nov 7 20:30:19 2008 +0000

        e1000: Use device_set_wakeup_enable

    commit 6ff68026f4757d68461b7fbeca5c944e1f5f8b44
    Author: Rafael J. Wysocki <rjw@sisk.pl>
    Date:   Wed Nov 12 09:52:32 2008 +0000

        e1000e: Use device_set_wakeup_enable

Unfortunately they left out some important bits.  This should make sure
the e100, igb, e1000e, and e1000-based devices can actually enable WOL
rather than their current state which is reported as not supported.

This looks like it has been broken since 2.6.28.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 e100.c             |    1 +
 e1000/e1000_main.c |    1 +
 e1000e/netdev.c    |    1 +
 igb/igb_main.c     |    1 +
 4 files changed, 4 insertions(+)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 569df19..8824952 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2816,6 +2816,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	if ((nic->mac >= mac_82558_D101_A4) &&
 	   (nic->eeprom[eeprom_id] & eeprom_id_wol)) {
 		nic->flags |= wol_magic;
+		device_init_wakeup(&pdev->dev, true);
 		device_set_wakeup_enable(&pdev->dev, true);
 	}
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index d7df00c..229d874 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1208,6 +1208,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* initialize the wol settings based on the eeprom settings */
 	adapter->wol = adapter->eeprom_wol;
+	device_init_wakeup(&adapter->pdev->dev, adapter->wol);
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
 	/* print bus type/speed/width info */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 63415bb..5c2edaa 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5196,6 +5196,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* initialize the wol settings based on the eeprom settings */
 	adapter->wol = adapter->eeprom_wol;
+	device_init_wakeup(&adapter->pdev->dev, adapter->wol);
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
 	/* save off EEPROM version number */
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index adb09d3..8512a40 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1475,6 +1475,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	/* initialize the wol settings based on the eeprom settings */
 	adapter->wol = adapter->eeprom_wol;
+	device_init_wakeup(&adapter->pdev->dev, adapter->wol);
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
 	/* reset the hardware with the new settings */


