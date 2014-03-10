From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 2/5] qlcnic: Get NIC capabilities using mailbox poll mode
Date: Mon, 10 Mar 2014 12:48:59 -0400
Message-ID: <1394470142-13992-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:14112 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754471AbaCJRZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:25:08 -0400
In-Reply-To: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

In order to enable VXLAN offload feature, we should get adapter
capabilities well before enabling mailbox command in interrupt
mode. So, issue mailbox command to get capabilities in poll mode
and get adapter's capabilities.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 90a2dda..760e602 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2194,6 +2194,19 @@ static int qlcnic_83xx_get_fw_info(struct qlcnic_adapter *adapter)
 	return err;
 }
 
+static void qlcnic_83xx_get_nic_capability(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_info nic_info;
+
+	memset(&nic_info, 0, sizeof(struct qlcnic_info));
+	qlcnic_83xx_enable_mbx_poll(adapter);
+
+	qlcnic_83xx_clear_function_resources(adapter);
+	qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw->pci_func);
+
+	qlcnic_83xx_disable_mbx_poll(adapter);
+}
+
 static void qlcnic_83xx_init_rings(struct qlcnic_adapter *adapter)
 {
 	u8 rx_cnt = QLCNIC_DEF_SDS_RINGS;
@@ -2253,6 +2266,9 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 	if (err)
 		goto detach_mbx;
 
+	/* Get nic capabilities by issuing mailbox in poll mode */
+	qlcnic_83xx_get_nic_capability(adapter);
+
 	err = qlcnic_setup_intr(adapter);
 	if (err) {
 		dev_err(&adapter->pdev->dev, "Failed to setup interrupt\n");
@@ -2263,8 +2279,6 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 	if (err)
 		goto disable_mbx_intr;
 
-	qlcnic_83xx_clear_function_resources(adapter);
-
 	INIT_DELAYED_WORK(&adapter->idc_aen_work, qlcnic_83xx_idc_aen_work);
 
 	qlcnic_83xx_initialize_nic(adapter, 1);
-- 
1.8.3.1
