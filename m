From: Divy Le Ray <None@chelsio.com>
Subject: [PATCH 1/10] cxgb3 - FW versioning
Date: Tue, 30 Jan 2007 19:43:45 -0800
Message-ID: <20070131034345.8574.21031.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:11294 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675AbXAaDnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 22:43:52 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Clean up FW version checking.
The supported FW version is now 3.1.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c       |   15 ++++++++-------
 drivers/net/cxgb3/firmware_exports.h |   27 +++++++++++++++++++++++++++
 drivers/net/cxgb3/t3_hw.c            |   17 ++++++++++++-----
 3 files changed, 47 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 54c49ac..8044146 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -665,11 +665,8 @@ static int cxgb_up(struct adapter *adap)
 
 	if (!(adap->flags & FULL_INIT_DONE)) {
 		err = t3_check_fw_version(adap);
-		if (err) {
-			dev_err(&adap->pdev->dev,
-				"adapter FW is not compatible with driver\n");
+		if (err)
 			goto out;
-		}
 
 		err = init_dummy_netdevs(adap);
 		if (err)
@@ -1002,10 +999,14 @@ static void get_drvinfo(struct net_devic
 	strcpy(info->bus_info, pci_name(adapter->pdev));
 	if (!fw_vers)
 		strcpy(info->fw_version, "N/A");
-	else
+	else {
 		snprintf(info->fw_version, sizeof(info->fw_version),
-			 "%s %u.%u", (fw_vers >> 24) ? "T" : "N",
-			 (fw_vers >> 12) & 0xfff, fw_vers & 0xfff);
+			 "%s %u.%u.%u",
+			 G_FW_VERSION_TYPE(fw_vers) ? "T" : "N",
+			 G_FW_VERSION_MAJOR(fw_vers),
+			 G_FW_VERSION_MINOR(fw_vers),
+			 G_FW_VERSION_MICRO(fw_vers));
+	}
 }
 
 static void get_strings(struct net_device *dev, u32 stringset, u8 * data)
diff --git a/drivers/net/cxgb3/firmware_exports.h b/drivers/net/cxgb3/firmware_exports.h
index 3565f48..eea7d89 100644
--- a/drivers/net/cxgb3/firmware_exports.h
+++ b/drivers/net/cxgb3/firmware_exports.h
@@ -141,4 +141,31 @@
 #define FW_WRC_NUM			\
     (65536 + FW_TUNNEL_NUM + FW_CTRL_NUM + FW_RI_NUM + FW_RX_PKT_NUM)
 
+/*
+ * FW type and version.
+ */
+#define S_FW_VERSION_TYPE		28
+#define M_FW_VERSION_TYPE		0xF
+#define V_FW_VERSION_TYPE(x)		((x) << S_FW_VERSION_TYPE)
+#define G_FW_VERSION_TYPE(x)		\
+    (((x) >> S_FW_VERSION_TYPE) & M_FW_VERSION_TYPE)
+
+#define S_FW_VERSION_MAJOR		16
+#define M_FW_VERSION_MAJOR		0xFFF
+#define V_FW_VERSION_MAJOR(x)		((x) << S_FW_VERSION_MAJOR)
+#define G_FW_VERSION_MAJOR(x)		\
+    (((x) >> S_FW_VERSION_MAJOR) & M_FW_VERSION_MAJOR)
+
+#define S_FW_VERSION_MINOR		8
+#define M_FW_VERSION_MINOR		0xFF
+#define V_FW_VERSION_MINOR(x)		((x) << S_FW_VERSION_MINOR)
+#define G_FW_VERSION_MINOR(x)		\
+    (((x) >> S_FW_VERSION_MINOR) & M_FW_VERSION_MINOR)
+
+#define S_FW_VERSION_MICRO		0
+#define M_FW_VERSION_MICRO		0xFF
+#define V_FW_VERSION_MICRO(x)		((x) << S_FW_VERSION_MICRO)
+#define G_FW_VERSION_MICRO(x)		\
+    (((x) >> S_FW_VERSION_MICRO) & M_FW_VERSION_MICRO)
+
 #endif				/* _FIRMWARE_EXPORTS_H_ */
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index a4e2e57..4545acb 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -826,6 +826,11 @@ static int t3_write_flash(struct adapter
 	return 0;
 }
 
+enum fw_version_type {
+	FW_VERSION_N3,
+	FW_VERSION_T3
+};
+
 /**
  *	t3_get_fw_version - read the firmware version
  *	@adapter: the adapter
@@ -849,19 +854,21 @@ int t3_check_fw_version(struct adapter *
 {
 	int ret;
 	u32 vers;
+	unsigned int type, major, minor;
 
 	ret = t3_get_fw_version(adapter, &vers);
 	if (ret)
 		return ret;
 
-	/* Minor 0xfff means the FW is an internal development-only version. */
-	if ((vers & 0xfff) == 0xfff)
-		return 0;
+	type = G_FW_VERSION_TYPE(vers);
+	major = G_FW_VERSION_MAJOR(vers);
+	minor = G_FW_VERSION_MINOR(vers);
 
-	if (vers == 0x1002009)
+	if (type == FW_VERSION_T3 && major == 3 && minor == 1)
 		return 0;
 
-	CH_ERR(adapter, "found wrong FW version, driver needs version 2.9\n");
+	CH_ERR(adapter, "found wrong FW version(%u.%u), "
+	       "driver needs version 3.1\n", major, minor);
 	return -EINVAL;
 }
 
