From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 11/13] cxgb3 - Firmware update
Date: Fri, 10 Aug 2007 23:30:25 -0700
Message-ID: <20070811063025.8203.59703.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:23130 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669AbXHKGab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2007 02:30:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Update firmware version
Allow the driver to be up and running with older FW image

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h     |    2 +-
 drivers/net/cxgb3/cxgb3_main.c |    9 +++++----
 drivers/net/cxgb3/t3_hw.c      |   20 +++++++++++++++-----
 drivers/net/cxgb3/version.h    |    2 +-
 4 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index b665b20..ff867c2 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -691,7 +691,7 @@ int t3_read_flash(struct adapter *adapter, unsigned int addr,
 		  unsigned int nwords, u32 *data, int byte_oriented);
 int t3_load_fw(struct adapter *adapter, const u8 * fw_data, unsigned int size);
 int t3_get_fw_version(struct adapter *adapter, u32 *vers);
-int t3_check_fw_version(struct adapter *adapter);
+int t3_check_fw_version(struct adapter *adapter, int *must_load);
 int t3_init_hw(struct adapter *adapter, u32 fw_params);
 void mac_prep(struct cmac *mac, struct adapter *adapter, int index);
 void early_hw_init(struct adapter *adapter, const struct adapter_info *ai);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 65ded16..eaebd7f 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -814,11 +814,12 @@ static int cxgb_up(struct adapter *adap)
 	int must_load;
 
 	if (!(adap->flags & FULL_INIT_DONE)) {
-		err = t3_check_fw_version(adap);
-		if (err == -EINVAL)
+		err = t3_check_fw_version(adap, &must_load);
+		if (err == -EINVAL) {
 			err = upgrade_fw(adap);
-		if (err)
-			goto out;
+			if (err && must_load)
+				goto out;
+		}
 
 		err = t3_check_tpsram_version(adap, &must_load);
 		if (err == -EINVAL) {
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 63032e8..3d47627 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -957,16 +957,18 @@ int t3_get_fw_version(struct adapter *adapter, u32 *vers)
 /**
  *	t3_check_fw_version - check if the FW is compatible with this driver
  *	@adapter: the adapter
- *
+ *	@must_load: set to 1 if loading a new FW image is required
+
  *	Checks if an adapter's FW is compatible with the driver.  Returns 0
  *	if the versions are compatible, a negative error otherwise.
  */
-int t3_check_fw_version(struct adapter *adapter)
+int t3_check_fw_version(struct adapter *adapter, int *must_load)
 {
 	int ret;
 	u32 vers;
 	unsigned int type, major, minor;
 
+	*must_load = 1;
 	ret = t3_get_fw_version(adapter, &vers);
 	if (ret)
 		return ret;
@@ -979,9 +981,17 @@ int t3_check_fw_version(struct adapter *adapter)
 	    minor == FW_VERSION_MINOR)
 		return 0;
 
-	CH_ERR(adapter, "found wrong FW version(%u.%u), "
-	       "driver needs version %u.%u\n", major, minor,
-	       FW_VERSION_MAJOR, FW_VERSION_MINOR);
+	if (major != FW_VERSION_MAJOR)
+		CH_ERR(adapter, "found wrong FW version(%u.%u), "
+		       "driver needs version %u.%u\n", major, minor,
+		       FW_VERSION_MAJOR, FW_VERSION_MINOR);
+	else {
+		*must_load = 0;
+		CH_WARN(adapter, "found wrong FW minor version(%u.%u), "
+		        "driver compiled for version %u.%u\n", major, minor,
+			FW_VERSION_MAJOR, FW_VERSION_MINOR);
+	}
+
 	return -EINVAL;
 }
 
diff --git a/drivers/net/cxgb3/version.h b/drivers/net/cxgb3/version.h
index eb508bf..ef1c633 100644
--- a/drivers/net/cxgb3/version.h
+++ b/drivers/net/cxgb3/version.h
@@ -39,6 +39,6 @@
 
 /* Firmware version */
 #define FW_VERSION_MAJOR 4
-#define FW_VERSION_MINOR 3
+#define FW_VERSION_MINOR 6
 #define FW_VERSION_MICRO 0
 #endif				/* __CHELSIO_VERSION_H */
