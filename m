From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-2.6] ixgbe/igb: catch invalid VF settings
Date: Wed, 21 Jul 2010 12:40:31 -0400
Message-ID: <1279730431-17156-1-git-send-email-andy@greyhouse.net>
Cc: chrisw@sous-sol.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27419 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786Ab0GUQim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 12:38:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some ixgbe cards put an invalid VF device ID in the PCIe SR-IOV
capability.  The ixgbe driver is only valid for PFs or non SR-IOV
hardware.  It seems that the same problem could occur on igb hardware as
well, so if we discover we are trying to initialize a VF in ixbge_probe
or igb_probe, print an error and exit.

Based on a patch for ixgbe from Chris Wright <chrisw@sous-sol.org>.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Cc: Chris Wright <chrisw@sous-sol.org>

---
 drivers/net/igb/igb_main.c     |    9 +++++++++
 drivers/net/ixgbe/ixgbe_main.c |    9 +++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3881918..cea37e0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1722,6 +1722,15 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
 	u32 part_num;
 
+	/* Catch broken hardware that put the wrong VF device ID in
+	 * the PCIe SR-IOV capability.
+	 */
+	if (pdev->is_virtfn) {
+		WARN(1, KERN_ERR "%s (%hx:%hx) should not be a VF!\n",
+		     pci_name(pdev), pdev->vendor, pdev->device);
+		return -EINVAL;
+	}
+
 	err = pci_enable_device_mem(pdev);
 	if (err)
 		return err;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7b5d976..74d9b6d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6492,6 +6492,15 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 #endif
 	u32 part_num, eec;
 
+	/* Catch broken hardware that put the wrong VF device ID in
+	 * the PCIe SR-IOV capability.
+	 */
+	if (pdev->is_virtfn) {
+		WARN(1, KERN_ERR "%s (%hx:%hx) should not be a VF!\n",
+		     pci_name(pdev), pdev->vendor, pdev->device);
+		return -EINVAL;
+	}
+
 	err = pci_enable_device_mem(pdev);
 	if (err)
 		return err;
-- 
1.6.2.5

