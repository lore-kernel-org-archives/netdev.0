From: Jon Mason <mason@myri.com>
Subject: [PATCH 2/9] myri10ge: Mask PCI Surprise Link Down Events
Date: Mon, 27 Jun 2011 10:05:01 -0500
Message-ID: <1309187108-12715-2-git-send-email-mason@myri.com>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:45673 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab1F0PFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 11:05:19 -0400
Received: by pwj7 with SMTP id 7so2997251pwj.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 08:05:18 -0700 (PDT)
In-Reply-To: <1309187108-12715-1-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A SRAM parity error can cause a surprise link down.  Since We can
recover from SRAM parity errors, mask PCI surprise down events.

Signed-off-by: Jon Mason <mason@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index a8ae641..0f0f83d 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -3327,6 +3327,26 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 			 mgp->fw_name);
 }
 
+static void myri10ge_mask_surprise_down(struct pci_dev *pdev)
+{
+	struct pci_dev *bridge = pdev->bus->self;
+	int cap;
+	u32 mask;
+
+	if (bridge == NULL)
+		return;
+
+	cap = pci_find_ext_capability(bridge, PCI_EXT_CAP_ID_ERR);
+	if (cap) {
+		/* a sram parity error can cause a surprise link
+		 * down; since we expect and can recover from sram
+		 * parity errors, mask surprise link down events */
+		pci_read_config_dword(bridge, cap + PCI_ERR_UNCOR_MASK, &mask);
+		mask |= 0x20;
+		pci_write_config_dword(bridge, cap + PCI_ERR_UNCOR_MASK, mask);
+	}
+}
+
 #ifdef CONFIG_PM
 static int myri10ge_suspend(struct pci_dev *pdev, pm_message_t state)
 {
@@ -3845,6 +3865,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto abort_with_enabled;
 	}
 
+	myri10ge_mask_surprise_down(pdev);
 	pci_set_master(pdev);
 	dac_enabled = 1;
 	status = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
-- 
1.7.5.4

