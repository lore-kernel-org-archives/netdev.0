From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 01/10] qlcnic: backout firmware initialization update
Date: Tue, 31 Aug 2010 07:29:31 -0700
Message-ID: <1283264980-25881-2-git-send-email-amit.salecha@qlogic.com>
References: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:62217 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757469Ab0HaO3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 10:29:41 -0400
In-Reply-To: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

o Backing out "firmware initialization update" changes, commit-id
  "d4066833bb1b35fefb1dd45eb2b10659d46bf151".
o fix heartbit spelling, it should be heartbeat

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    2 +-
 drivers/net/qlcnic/qlcnic_hdr.h  |    6 ++-
 drivers/net/qlcnic/qlcnic_init.c |  109 +++++++++++++++++++++++++++++++-------
 drivers/net/qlcnic/qlcnic_main.c |   11 ++--
 4 files changed, 100 insertions(+), 28 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 1f5c10b..74eff18 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -978,7 +978,7 @@ struct qlcnic_adapter {
 	u32 temp;
 
 	u32 int_vec_bit;
-	u32 heartbit;
+	u32 heartbeat;
 
 	u8 max_mac_filters;
 	u8 dev_state;
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index bce1b1d..716203e 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -747,8 +747,12 @@ enum {
 
 #define QLCNIC_RESET_TIMEOUT_SECS	10
 #define QLCNIC_INIT_TIMEOUT_SECS	30
+#define QLCNIC_RCVPEG_CHECK_RETRY_COUNT	2000
+#define QLCNIC_RCVPEG_CHECK_DELAY	10
+#define QLCNIC_CMDPEG_CHECK_RETRY_COUNT	60
+#define QLCNIC_CMDPEG_CHECK_DELAY	500
 #define QLCNIC_HEARTBEAT_PERIOD_MSECS	200
-#define QLCNIC_HEARTBEAT_RETRY_COUNT	45
+#define QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT	45
 
 #define	ISR_MSI_INT_TRIGGER(FUNC) (QLCNIC_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
 #define ISR_LEGACY_INT_TRIGGERED(VAL)	(((VAL) & 0x300) == 0x200)
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index eb8256b..8e0e7a3 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -46,6 +46,9 @@ static void
 qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_rds_ring *rds_ring);
 
+static int
+qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter);
+
 static void crb_addr_transform_setup(void)
 {
 	crb_addr_transform(XDMA);
@@ -544,31 +547,77 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
-int
-qlcnic_check_fw_status(struct qlcnic_adapter *adapter)
+static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
 {
-	u32 heartbit, cmdpeg_state, ret = -EIO;
-	int retries = QLCNIC_HEARTBEAT_RETRY_COUNT;
+	u32 val;
+	int retries = QLCNIC_CMDPEG_CHECK_RETRY_COUNT;
 
-	adapter->heartbit = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 	do {
-		msleep(QLCNIC_HEARTBEAT_PERIOD_MSECS);
-		heartbit = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
-		if (heartbit != adapter->heartbit) {
-			cmdpeg_state = QLCRD32(adapter, CRB_CMDPEG_STATE);
-			/* Ensure peg states are initialized */
-			if (cmdpeg_state == PHAN_INITIALIZE_COMPLETE ||
-				cmdpeg_state == PHAN_INITIALIZE_ACK) {
-				/* Complete firmware handshake */
-				QLCWR32(adapter, CRB_CMDPEG_STATE,
-					PHAN_INITIALIZE_ACK);
-				ret = QLCNIC_RCODE_SUCCESS;
-				break;
-			}
+		val = QLCRD32(adapter, CRB_CMDPEG_STATE);
+
+		switch (val) {
+		case PHAN_INITIALIZE_COMPLETE:
+		case PHAN_INITIALIZE_ACK:
+			return 0;
+		case PHAN_INITIALIZE_FAILED:
+			goto out_err;
+		default:
+			break;
 		}
+
+		msleep(QLCNIC_CMDPEG_CHECK_DELAY);
+
 	} while (--retries);
 
-	return ret;
+	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
+
+out_err:
+	dev_err(&adapter->pdev->dev, "Command Peg initialization not "
+		      "complete, state: 0x%x.\n", val);
+	return -EIO;
+}
+
+static int
+qlcnic_receive_peg_ready(struct qlcnic_adapter *adapter)
+{
+	u32 val;
+	int retries = QLCNIC_RCVPEG_CHECK_RETRY_COUNT;
+
+	do {
+		val = QLCRD32(adapter, CRB_RCVPEG_STATE);
+
+		if (val == PHAN_PEG_RCV_INITIALIZED)
+			return 0;
+
+		msleep(QLCNIC_RCVPEG_CHECK_DELAY);
+
+	} while (--retries);
+
+	if (!retries) {
+		dev_err(&adapter->pdev->dev, "Receive Peg initialization not "
+			      "complete, state: 0x%x.\n", val);
+		return -EIO;
+	}
+
+	return 0;
+}
+
+int
+qlcnic_check_fw_status(struct qlcnic_adapter *adapter)
+{
+	int err;
+
+	err = qlcnic_cmd_peg_ready(adapter);
+	if (err)
+		return err;
+
+	err = qlcnic_receive_peg_ready(adapter);
+	if (err)
+		return err;
+
+	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
+
+	return err;
 }
 
 int
@@ -943,12 +992,32 @@ static void qlcnic_rom_lock_recovery(struct qlcnic_adapter *adapter)
 	qlcnic_pcie_sem_unlock(adapter, 2);
 }
 
+static int
+qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter)
+{
+	u32 heartbeat, ret = -EIO;
+	int retries = QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT;
+
+	adapter->heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+
+	do {
+		msleep(QLCNIC_HEARTBEAT_PERIOD_MSECS);
+		heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+		if (heartbeat != adapter->heartbeat) {
+			ret = QLCNIC_RCODE_SUCCESS;
+			break;
+		}
+	} while (--retries);
+
+	return ret;
+}
+
 int
 qlcnic_need_fw_reset(struct qlcnic_adapter *adapter)
 {
 	u32 val, version, major, minor, build;
 
-	if (qlcnic_check_fw_status(adapter)) {
+	if (qlcnic_check_fw_hearbeat(adapter)) {
 		qlcnic_rom_lock_recovery(adapter);
 		return 1;
 	}
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 6999d5a..771a160 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -983,7 +983,7 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 
 	err = qlcnic_need_fw_reset(adapter);
 	if (err == 0)
-		goto set_dev_ready;
+		goto check_fw_status;
 
 	err = qlcnic_pinit_from_rom(adapter);
 	if (err)
@@ -1002,7 +1002,6 @@ check_fw_status:
 	if (err)
 		goto err_out;
 
-set_dev_ready:
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
 
@@ -2795,7 +2794,7 @@ done:
 static int
 qlcnic_check_health(struct qlcnic_adapter *adapter)
 {
-	u32 state = 0, heartbit;
+	u32 state = 0, heartbeat;
 	struct net_device *netdev = adapter->netdev;
 
 	if (qlcnic_check_temp(adapter))
@@ -2811,9 +2810,9 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		adapter->need_fw_reset = 1;
 	}
 
-	heartbit = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
-	if (heartbit != adapter->heartbit) {
-		adapter->heartbit = heartbit;
+	heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+	if (heartbeat != adapter->heartbeat) {
+		adapter->heartbeat = heartbeat;
 		adapter->fw_fail_cnt = 0;
 		if (adapter->need_fw_reset)
 			goto detach;
-- 
1.6.0.2

