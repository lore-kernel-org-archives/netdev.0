From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 7/7] qlcnic: mark device state fail
Date: Mon, 17 May 2010 04:22:14 -0700
Message-ID: <1274095334-32362-8-git-send-email-amit.salecha@qlogic.com>
References: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:52529 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751925Ab0EQKVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 06:21:51 -0400
In-Reply-To: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device state need to be mark as FAILED, if fail to start firmware.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index f8bd1bd..1003eb7 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -635,9 +635,12 @@ wait_init:
 
 	adapter->need_fw_reset = 0;
 
-	/* fall through and release firmware */
+	qlcnic_release_firmware(adapter);
+	return 0;
 
 err_out:
+	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
+	dev_err(&adapter->pdev->dev, "Device state set to failed\n");
 	qlcnic_release_firmware(adapter);
 	return err;
 }
@@ -1100,8 +1103,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_iounmap;
 
 	err = qlcnic_start_firmware(adapter);
-	if (err)
+	if (err) {
+		dev_err(&pdev->dev, "Loading fw failed.Please Reboot\n");
 		goto err_out_decr_ref;
+	}
 
 	qlcnic_clear_stats(adapter);
 
@@ -2061,6 +2066,7 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 		break;
 
 	case QLCNIC_DEV_FAILED:
+		dev_err(&adapter->pdev->dev, "Device in failed state.\n");
 		qlcnic_api_unlock(adapter);
 		return -1;
 
-- 
1.5.6.1

