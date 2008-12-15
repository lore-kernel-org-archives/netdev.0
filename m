From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.29] cxgb3 - untie strict FW matching
Date: Mon, 15 Dec 2008 11:13:38 -0800
Message-ID: <20081215191338.22028.66965.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:2814 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbYLOTNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 14:13:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

The NIC driver can work with mutliple versions of the FW.
Let the driver load when the embedded FW does not match,
and the FW update mechanism failed.
The iWARP module will make its own loading decision.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h     |    4 ++--
 drivers/net/cxgb3/cxgb3_main.c |   15 ++++++++-------
 drivers/net/cxgb3/t3_hw.c      |   26 +++++---------------------
 3 files changed, 15 insertions(+), 30 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index e312d31..db4f4f5 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -714,7 +714,7 @@ int t3_seeprom_read(struct adapter *adapter, u32 addr, __le32 *data);
 int t3_seeprom_write(struct adapter *adapter, u32 addr, __le32 data);
 int t3_seeprom_wp(struct adapter *adapter, int enable);
 int t3_get_tp_version(struct adapter *adapter, u32 *vers);
-int t3_check_tpsram_version(struct adapter *adapter, int *must_load);
+int t3_check_tpsram_version(struct adapter *adapter);
 int t3_check_tpsram(struct adapter *adapter, const u8 *tp_ram,
 		    unsigned int size);
 int t3_set_proto_sram(struct adapter *adap, const u8 *data);
@@ -722,7 +722,7 @@ int t3_read_flash(struct adapter *adapter, unsigned int addr,
 		  unsigned int nwords, u32 *data, int byte_oriented);
 int t3_load_fw(struct adapter *adapter, const u8 * fw_data, unsigned int size);
 int t3_get_fw_version(struct adapter *adapter, u32 *vers);
-int t3_check_fw_version(struct adapter *adapter, int *must_load);
+int t3_check_fw_version(struct adapter *adapter);
 int t3_init_hw(struct adapter *adapter, u32 fw_params);
 void mac_prep(struct cmac *mac, struct adapter *adapter, int index);
 void early_hw_init(struct adapter *adapter, const struct adapter_info *ai);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 9e8727c..2847f94 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -958,21 +958,22 @@ release_tpsram:
 static int cxgb_up(struct adapter *adap)
 {
 	int err;
-	int must_load;
 
 	if (!(adap->flags & FULL_INIT_DONE)) {
-		err = t3_check_fw_version(adap, &must_load);
+		err = t3_check_fw_version(adap);
 		if (err == -EINVAL) {
 			err = upgrade_fw(adap);
-			if (err && must_load)
-				goto out;
+			CH_WARN(adap, "FW upgrade to %d.%d.%d %s\n",
+				FW_VERSION_MAJOR, FW_VERSION_MINOR,
+				FW_VERSION_MICRO, err ? "failed" : "succeeded");
 		}
 
-		err = t3_check_tpsram_version(adap, &must_load);
+		err = t3_check_tpsram_version(adap);
 		if (err == -EINVAL) {
 			err = update_tpsram(adap);
-			if (err && must_load)
-				goto out;
+			CH_WARN(adap, "TP upgrade to %d.%d.%d %s\n",
+				TP_VERSION_MAJOR, TP_VERSION_MINOR,
+				TP_VERSION_MICRO, err ? "failed" : "succeeded");
 		}
 
 		/*
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 9a0898b..2d14330 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -925,11 +925,10 @@ int t3_get_tp_version(struct adapter *adapter, u32 *vers)
 /**
  *	t3_check_tpsram_version - read the tp sram version
  *	@adapter: the adapter
- *	@must_load: set to 1 if loading a new microcode image is required
  *
  *	Reads the protocol sram version from flash.
  */
-int t3_check_tpsram_version(struct adapter *adapter, int *must_load)
+int t3_check_tpsram_version(struct adapter *adapter)
 {
 	int ret;
 	u32 vers;
@@ -938,7 +937,6 @@ int t3_check_tpsram_version(struct adapter *adapter, int *must_load)
 	if (adapter->params.rev == T3_REV_A)
 		return 0;
 
-	*must_load = 1;
 
 	ret = t3_get_tp_version(adapter, &vers);
 	if (ret)
@@ -949,13 +947,7 @@ int t3_check_tpsram_version(struct adapter *adapter, int *must_load)
 
 	if (major == TP_VERSION_MAJOR && minor == TP_VERSION_MINOR)
 		return 0;
-
-	if (major != TP_VERSION_MAJOR)
-		CH_ERR(adapter, "found wrong TP version (%u.%u), "
-		       "driver needs version %d.%d\n", major, minor,
-		       TP_VERSION_MAJOR, TP_VERSION_MINOR);
 	else {
-		*must_load = 0;
 		CH_ERR(adapter, "found wrong TP version (%u.%u), "
 		       "driver compiled for version %d.%d\n", major, minor,
 		       TP_VERSION_MAJOR, TP_VERSION_MINOR);
@@ -1012,18 +1004,16 @@ int t3_get_fw_version(struct adapter *adapter, u32 *vers)
 /**
  *	t3_check_fw_version - check if the FW is compatible with this driver
  *	@adapter: the adapter
- *	@must_load: set to 1 if loading a new FW image is required
-
+ *
  *	Checks if an adapter's FW is compatible with the driver.  Returns 0
  *	if the versions are compatible, a negative error otherwise.
  */
-int t3_check_fw_version(struct adapter *adapter, int *must_load)
+int t3_check_fw_version(struct adapter *adapter)
 {
 	int ret;
 	u32 vers;
 	unsigned int type, major, minor;
 
-	*must_load = 1;
 	ret = t3_get_fw_version(adapter, &vers);
 	if (ret)
 		return ret;
@@ -1035,17 +1025,11 @@ int t3_check_fw_version(struct adapter *adapter, int *must_load)
 	if (type == FW_VERSION_T3 && major == FW_VERSION_MAJOR &&
 	    minor == FW_VERSION_MINOR)
 		return 0;
-
-	if (major != FW_VERSION_MAJOR)
-		CH_ERR(adapter, "found wrong FW version(%u.%u), "
-		       "driver needs version %u.%u\n", major, minor,
-		       FW_VERSION_MAJOR, FW_VERSION_MINOR);
-	else if (minor < FW_VERSION_MINOR) {
-		*must_load = 0;
+	else if (major != FW_VERSION_MAJOR || minor < FW_VERSION_MINOR)
 		CH_WARN(adapter, "found old FW minor version(%u.%u), "
 		        "driver compiled for version %u.%u\n", major, minor,
 			FW_VERSION_MAJOR, FW_VERSION_MINOR);
-	} else {
+	else {
 		CH_WARN(adapter, "found newer FW version(%u.%u), "
 		        "driver compiled for version %u.%u\n", major, minor,
 			FW_VERSION_MAJOR, FW_VERSION_MINOR);

