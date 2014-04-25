From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 5/6] qlcnic: Limit vNIC support in legacy interrupt mode
Date: Fri, 25 Apr 2014 17:44:00 -0400
Message-ID: <1398462241-15478-6-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shahed.shaikh@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:11474 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751984AbaDYWWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 18:22:07 -0400
In-Reply-To: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o When the driver loads in legacy interrupt mode, only vNICs
  with PCI function number 0-7 are supported.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 10 +++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    |  3 +++
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 4ea15ba..7c125d7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -33,6 +33,7 @@ static void qlcnic_83xx_get_beacon_state(struct qlcnic_adapter *);
 #define RSS_HASHTYPE_IP_TCP		0x3
 #define QLC_83XX_FW_MBX_CMD		0
 #define QLC_SKIP_INACTIVE_PCI_REGS	7
+#define QLC_MAX_LEGACY_FUNC_SUPP	8
 
 static const struct qlcnic_mailbox_metadata qlcnic_83xx_mbx_tbl[] = {
 	{QLCNIC_CMD_CONFIGURE_IP_ADDR, 6, 1},
@@ -357,8 +358,15 @@ int qlcnic_83xx_setup_intr(struct qlcnic_adapter *adapter)
 	if (!ahw->intr_tbl)
 		return -ENOMEM;
 
-	if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
+	if (!(adapter->flags & QLCNIC_MSIX_ENABLED)) {
+		if (adapter->ahw->pci_func >= QLC_MAX_LEGACY_FUNC_SUPP) {
+			dev_err(&adapter->pdev->dev, "PCI function number 8 and higher are not supported with legacy interrupt, func 0x%x\n",
+				ahw->pci_func);
+			return -EOPNOTSUPP;
+		}
+
 		qlcnic_83xx_enable_legacy(adapter);
+	}
 
 	for (i = 0; i < num_msix; i++) {
 		if (adapter->flags & QLCNIC_MSIX_ENABLED)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 42f4dfe..07b6e4f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2532,6 +2532,9 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			case -ENOMEM:
 				dev_err(&pdev->dev, "Adapter initialization failed. Please reboot\n");
 				goto err_out_free_hw;
+			case -EOPNOTSUPP:
+				dev_err(&pdev->dev, "Adapter initialization failed\n");
+				goto err_out_free_hw;
 			default:
 				dev_err(&pdev->dev, "Adapter initialization failed. Driver will load in maintenance mode to recover the adapter using the application\n");
 				goto err_out_maintenance_mode;
-- 
1.8.1.4
