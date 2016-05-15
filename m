From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 3/9] bnxt_en: Report PCIe link speed and width during driver load
Date: Sun, 15 May 2016 03:04:45 -0400
Message-ID: <1463295891-15216-4-git-send-email-michael.chan@broadcom.com>
References: <1463295891-15216-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33630 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbcEOHFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 03:05:05 -0400
Received: by mail-pf0-f178.google.com with SMTP id 206so56891187pfu.0
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 00:05:05 -0700 (PDT)
In-Reply-To: <1463295891-15216-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@broadcom.com>

Add code to log a message during driver load indicating PCIe link
speed and width.

The log message will look like this:
bnxt_en 0000:86:00.0 eth0: PCIe: Speed 8.0GT/s Width x8

Signed-off-by: Ajit Khaparde <ajit.khaparde@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 59b2e36..ba0c3e5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6198,6 +6198,22 @@ static int bnxt_set_dflt_rings(struct bnxt *bp)
 	return rc;
 }
 
+static void bnxt_parse_log_pcie_link(struct bnxt *bp)
+{
+	enum pcie_link_width width = PCIE_LNK_WIDTH_UNKNOWN;
+	enum pci_bus_speed speed = PCI_SPEED_UNKNOWN;
+
+	if (pcie_get_minimum_link(bp->pdev, &speed, &width) ||
+	    speed == PCI_SPEED_UNKNOWN || width == PCIE_LNK_WIDTH_UNKNOWN)
+		netdev_info(bp->dev, "Failed to determine PCIe Link Info\n");
+	else
+		netdev_info(bp->dev, "PCIe: Speed %s Width x%d\n",
+			    speed == PCIE_SPEED_2_5GT ? "2.5GT/s" :
+			    speed == PCIE_SPEED_5_0GT ? "5.0GT/s" :
+			    speed == PCIE_SPEED_8_0GT ? "8.0GT/s" :
+			    "Unknown", width);
+}
+
 static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int version_printed;
@@ -6318,6 +6334,8 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		    board_info[ent->driver_data].name,
 		    (long)pci_resource_start(pdev, 0), dev->dev_addr);
 
+	bnxt_parse_log_pcie_link(bp);
+
 	return 0;
 
 init_err:
-- 
1.8.3.1
