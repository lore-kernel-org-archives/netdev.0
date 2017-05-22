From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 10/11] qede: Log probe of PCI device
Date: Mon, 22 May 2017 14:32:10 +0300
Message-ID: <1495452731-27171-11-git-send-email-Yuval.Mintz@cavium.com>
References: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0086.outbound.protection.outlook.com ([104.47.36.86]:28296
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933166AbdEVLda (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 07:33:30 -0400
In-Reply-To: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace meaningless logged print ('Ending successfully qede probe')
with a single-liner containing interesting information about probed
device.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 40 ++++++++++++++++++++++++++--
 1 file changed, 38 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index f0871e1..d496ba7 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -852,6 +852,43 @@ static void qede_update_pf_params(struct qed_dev *cdev)
 	qed_ops->common->update_pf_params(cdev, &pf_params);
 }
 
+#define QEDE_FW_VER_STR_SIZE	80
+
+static void qede_log_probe(struct qede_dev *edev)
+{
+	struct qed_dev_info *p_dev_info = &edev->dev_info.common;
+	u8 buf[QEDE_FW_VER_STR_SIZE];
+	size_t left_size;
+
+	snprintf(buf, QEDE_FW_VER_STR_SIZE,
+		 "Storm FW %d.%d.%d.%d, Management FW %d.%d.%d.%d",
+		 p_dev_info->fw_major, p_dev_info->fw_minor, p_dev_info->fw_rev,
+		 p_dev_info->fw_eng,
+		 (p_dev_info->mfw_rev & QED_MFW_VERSION_3_MASK) >>
+		 QED_MFW_VERSION_3_OFFSET,
+		 (p_dev_info->mfw_rev & QED_MFW_VERSION_2_MASK) >>
+		 QED_MFW_VERSION_2_OFFSET,
+		 (p_dev_info->mfw_rev & QED_MFW_VERSION_1_MASK) >>
+		 QED_MFW_VERSION_1_OFFSET,
+		 (p_dev_info->mfw_rev & QED_MFW_VERSION_0_MASK) >>
+		 QED_MFW_VERSION_0_OFFSET);
+
+	left_size = QEDE_FW_VER_STR_SIZE - strlen(buf);
+	if (p_dev_info->mbi_version && left_size)
+		snprintf(buf + strlen(buf), left_size,
+			 " [MBI %d.%d.%d]",
+			 (p_dev_info->mbi_version & QED_MBI_VERSION_2_MASK) >>
+			 QED_MBI_VERSION_2_OFFSET,
+			 (p_dev_info->mbi_version & QED_MBI_VERSION_1_MASK) >>
+			 QED_MBI_VERSION_1_OFFSET,
+			 (p_dev_info->mbi_version & QED_MBI_VERSION_0_MASK) >>
+			 QED_MBI_VERSION_0_OFFSET);
+
+	pr_info("qede %02x:%02x.%02x: %s [%s]\n", edev->pdev->bus->number,
+		PCI_SLOT(edev->pdev->devfn), PCI_FUNC(edev->pdev->devfn),
+		buf, edev->ndev->name);
+}
+
 enum qede_probe_mode {
 	QEDE_PROBE_NORMAL,
 };
@@ -945,8 +982,7 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 
 	edev->rx_copybreak = QEDE_RX_HDR_SIZE;
 
-	DP_INFO(edev, "Ending successfully qede probe\n");
-
+	qede_log_probe(edev);
 	return 0;
 
 err4:
-- 
1.9.3
