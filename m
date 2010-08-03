From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 06/11] rt2x00: do not use PCI resources before pci_enable_device()
Date: Tue,  3 Aug 2010 19:43:22 +0400
Message-ID: <1280850203-5532-1-git-send-email-segooon@gmail.com>
Cc: Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	Alban Browaeys <prahal@yahoo.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56537 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932212Ab0HCPnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 11:43:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IRQ and resource[] may not have correct values until
after PCI hotplug setup occurs at pci_enable_device() time.

The semantic match that finds this problem is as follows:

// <smpl>
@@
identifier x;
identifier request ~= "pci_request.*|pci_resource.*";
@@

(
* x->irq
|
* x->resource
|
* request(x, ...)
)
 ...
*pci_enable_device(x)
// </smpl>

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/wireless/rt2x00/rt2x00pci.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index 19b262e..63c2cc4 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -240,16 +240,16 @@ int rt2x00pci_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	struct rt2x00_dev *rt2x00dev;
 	int retval;
 
-	retval = pci_request_regions(pci_dev, pci_name(pci_dev));
+	retval = pci_enable_device(pci_dev);
 	if (retval) {
-		ERROR_PROBE("PCI request regions failed.\n");
+		ERROR_PROBE("Enable device failed.\n");
 		return retval;
 	}
 
-	retval = pci_enable_device(pci_dev);
+	retval = pci_request_regions(pci_dev, pci_name(pci_dev));
 	if (retval) {
-		ERROR_PROBE("Enable device failed.\n");
-		goto exit_release_regions;
+		ERROR_PROBE("PCI request regions failed.\n");
+		goto exit_disable_device;
 	}
 
 	pci_set_master(pci_dev);
@@ -260,14 +260,14 @@ int rt2x00pci_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	if (dma_set_mask(&pci_dev->dev, DMA_BIT_MASK(32))) {
 		ERROR_PROBE("PCI DMA not supported.\n");
 		retval = -EIO;
-		goto exit_disable_device;
+		goto exit_release_regions;
 	}
 
 	hw = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), ops->hw);
 	if (!hw) {
 		ERROR_PROBE("Failed to allocate hardware.\n");
 		retval = -ENOMEM;
-		goto exit_disable_device;
+		goto exit_release_regions;
 	}
 
 	pci_set_drvdata(pci_dev, hw);
@@ -300,13 +300,12 @@ exit_free_reg:
 exit_free_device:
 	ieee80211_free_hw(hw);
 
-exit_disable_device:
-	if (retval != -EBUSY)
-		pci_disable_device(pci_dev);
-
 exit_release_regions:
 	pci_release_regions(pci_dev);
 
+exit_disable_device:
+	pci_disable_device(pci_dev);
+
 	pci_set_drvdata(pci_dev, NULL);
 
 	return retval;
-- 
1.7.0.4

