From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 4/5] qlcnic: Move get template from probe to start fw
Date: Fri, 29 Jul 2011 16:30:28 -0700
Message-ID: <1311982230-10543-4-git-send-email-anirban.chakraborty@qlogic.com>
References: <1311982230-10543-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe003.messaging.microsoft.com ([216.32.180.13]:51484
	"EHLO VA3EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753146Ab1G2Xjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 19:39:52 -0400
In-Reply-To: <1311982230-10543-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Place for gathering FW dump template has been moved to the FW restart path
so that the driver can check if a newer FW version is available and in that case
it replaces the existing FW dump template with the newer template.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 248ebbd..d287a2b 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -643,8 +643,11 @@ static void get_brd_name(struct qlcnic_adapter *adapter, char *name)
 static void
 qlcnic_check_options(struct qlcnic_adapter *adapter)
 {
-	u32 fw_major, fw_minor, fw_build;
+	u32 fw_major, fw_minor, fw_build, prev_fw_version;
 	struct pci_dev *pdev = adapter->pdev;
+	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+
+	prev_fw_version = adapter->fw_version;
 
 	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
 	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
@@ -652,6 +655,17 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	adapter->fw_version = QLCNIC_VERSION_CODE(fw_major, fw_minor, fw_build);
 
+	if (adapter->op_mode != QLCNIC_NON_PRIV_FUNC) {
+		if (fw_dump->tmpl_hdr == NULL ||
+				adapter->fw_version > prev_fw_version) {
+			if (fw_dump->tmpl_hdr)
+				vfree(fw_dump->tmpl_hdr);
+			if (!qlcnic_fw_cmd_get_minidump_temp(adapter))
+				dev_info(&pdev->dev,
+					"Supports FW dump capability\n");
+		}
+	}
+
 	dev_info(&pdev->dev, "firmware v%d.%d.%d\n",
 			fw_major, fw_minor, fw_build);
 	if (adapter->ahw->port_type == QLCNIC_XGBE) {
@@ -1610,12 +1624,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_decr_ref;
 	}
 
-	/* Get FW dump template and store it */
-	if (adapter->op_mode != QLCNIC_NON_PRIV_FUNC)
-		if (!qlcnic_fw_cmd_get_minidump_temp(adapter))
-			dev_info(&pdev->dev,
-				"Supports FW dump capability\n");
-
 	if (qlcnic_read_mac_addr(adapter))
 		dev_warn(&pdev->dev, "failed to read mac addr\n");
 
-- 
1.7.4.1


