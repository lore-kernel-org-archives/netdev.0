From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 2/8] qlcnic: handshake with card after fw load
Date: Tue, 22 Jun 2010 06:18:59 -0700
Message-ID: <1277212745-26857-3-git-send-email-amit.salecha@qlogic.com>
References: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:17842 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754799Ab0FVNTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 09:19:07 -0400
In-Reply-To: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

Instead of delaying rcv handshake till interface comes up,
do it just after fw load.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 -
 drivers/net/qlcnic/qlcnic_init.c |    9 +++++++--
 drivers/net/qlcnic/qlcnic_main.c |    6 ++----
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 86e4781..588b9a9 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1105,7 +1105,6 @@ int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
 int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
 
 /* Functions from qlcnic_init.c */
-int qlcnic_phantom_init(struct qlcnic_adapter *adapter);
 int qlcnic_load_firmware(struct qlcnic_adapter *adapter);
 int qlcnic_need_fw_reset(struct qlcnic_adapter *adapter);
 void qlcnic_request_firmware(struct qlcnic_adapter *adapter);
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 1c3d5a9..d19d012 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1138,7 +1138,7 @@ qlcnic_release_firmware(struct qlcnic_adapter *adapter)
 	adapter->fw = NULL;
 }
 
-int qlcnic_phantom_init(struct qlcnic_adapter *adapter)
+static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
 {
 	u32 val;
 	int retries = 60;
@@ -1163,7 +1163,8 @@ int qlcnic_phantom_init(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
 
 out_err:
-	dev_err(&adapter->pdev->dev, "firmware init failed\n");
+	dev_err(&adapter->pdev->dev, "Command Peg initialization not "
+		      "complete, state: 0x%x.\n", val);
 	return -EIO;
 }
 
@@ -1196,6 +1197,10 @@ int qlcnic_init_firmware(struct qlcnic_adapter *adapter)
 {
 	int err;
 
+	err = qlcnic_cmd_peg_ready(adapter);
+	if (err)
+		return err;
+
 	err = qlcnic_receive_peg_ready(adapter);
 	if (err)
 		return err;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 655bccd..9658b18 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -758,6 +758,7 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 
 	if (first_boot != 0x55555555) {
 		QLCWR32(adapter, CRB_CMDPEG_STATE, 0);
+		QLCWR32(adapter, CRB_RCVPEG_STATE, 0);
 		qlcnic_pinit_from_rom(adapter);
 		msleep(1);
 	}
@@ -780,7 +781,7 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 
 wait_init:
 	/* Handshake with the card before we register the devices. */
-	err = qlcnic_phantom_init(adapter);
+	err = qlcnic_init_firmware(adapter);
 	if (err)
 		goto err_out;
 
@@ -962,9 +963,6 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 	if (adapter->is_up == QLCNIC_ADAPTER_UP_MAGIC)
 		return 0;
 
-	err = qlcnic_init_firmware(adapter);
-	if (err)
-		return err;
 
 	err = qlcnic_napi_add(adapter, netdev);
 	if (err)
-- 
1.6.0.2

