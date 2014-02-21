From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 5/5] qlcnic: reset firmware API lock during driver load
Date: Fri, 21 Feb 2014 01:23:08 -0500
Message-ID: <1392963788-18341-6-git-send-email-shahed.shaikh@qlogic.com>
References: <1392963788-18341-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:32771 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753017AbaBUG6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 01:58:45 -0500
In-Reply-To: <1392963788-18341-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Firmware is not resetting API lock at initialization,
reset the lock at driver load time.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1222865..61f8893 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2305,6 +2305,18 @@ void qlcnic_set_drv_version(struct qlcnic_adapter *adapter)
 		qlcnic_fw_cmd_set_drv_version(adapter, fw_cmd);
 }
 
+static void qlcnic_reset_api_lock(struct qlcnic_adapter *adapter)
+{
+	/* Check lock availability*/
+	if (qlcnic_api_lock(adapter)) {
+		/* Lock not available, force release the lock */
+		qlcnic_api_unlock(adapter);
+	} else {
+		/* Lock available, release it before proceeding */
+		qlcnic_api_unlock(adapter);
+	}
+}
+
 static int
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -2407,6 +2419,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (qlcnic_82xx_check(adapter)) {
 		qlcnic_check_vf(adapter, ent);
 		adapter->portnum = adapter->ahw->pci_func;
+		qlcnic_reset_api_lock(adapter);
 		err = qlcnic_start_firmware(adapter);
 		if (err) {
 			dev_err(&pdev->dev, "Loading fw failed.Please Reboot\n"
-- 
1.8.1.4
