From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 16/19] vxge: remove unnecessary reads of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 12:48:11 -0500
Message-ID: <1309196891-16274-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36086 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660Ab1F0RsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 13:48:16 -0400
Received: by pvg12 with SMTP id 12so2994025pvg.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 10:48:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIE capability offset is saved during PCI bus walking.  It will
remove an unnecessary search in the PCI configuration space if this
value is referenced instead of reacquiring it.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/vxge/vxge-config.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 857618a..1520c57 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -753,12 +753,11 @@ static void __vxge_hw_device_host_info_get(struct __vxge_hw_device *hldev)
 static enum vxge_hw_status
 __vxge_hw_verify_pci_e_info(struct __vxge_hw_device *hldev)
 {
-	int exp_cap;
+	struct pci_dev *dev = hldev->pdev;
 	u16 lnk;
 
 	/* Get the negotiated link width and speed from PCI config space */
-	exp_cap = pci_find_capability(hldev->pdev, PCI_CAP_ID_EXP);
-	pci_read_config_word(hldev->pdev, exp_cap + PCI_EXP_LNKSTA, &lnk);
+	pci_read_config_word(dev, dev->pcie_cap + PCI_EXP_LNKSTA, &lnk);
 
 	if ((lnk & PCI_EXP_LNKSTA_CLS) != 1)
 		return VXGE_HW_ERR_INVALID_PCI_INFO;
@@ -1982,13 +1981,11 @@ exit:
 
 u16 vxge_hw_device_link_width_get(struct __vxge_hw_device *hldev)
 {
-	int link_width, exp_cap;
+	struct pci_dev *dev = hldev->pdev;
 	u16 lnk;
 
-	exp_cap = pci_find_capability(hldev->pdev, PCI_CAP_ID_EXP);
-	pci_read_config_word(hldev->pdev, exp_cap + PCI_EXP_LNKSTA, &lnk);
-	link_width = (lnk & VXGE_HW_PCI_EXP_LNKCAP_LNK_WIDTH) >> 4;
-	return link_width;
+	pci_read_config_word(dev, dev->pcie_cap + PCI_EXP_LNKSTA, &lnk);
+	return (lnk & VXGE_HW_PCI_EXP_LNKCAP_LNK_WIDTH) >> 4;
 }
 
 /*
-- 
1.7.5.4

