From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 10/13] cxgb3 - engine microcode update
Date: Fri, 10 Aug 2007 23:30:20 -0700
Message-ID: <20070811063020.8184.94082.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:9391 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265AbXHKGa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2007 02:30:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Load microcode engine when the interface
is configured up.
Bump up version to 1.1.0.
Allow the driver to be and running with
older microcode images.
Allow ethtool to log the microcode version.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h     |    8 ++-
 drivers/net/cxgb3/cxgb3_main.c |  116 ++++++++++++++++++++++++----------------
 drivers/net/cxgb3/t3_hw.c      |   43 +++++++++++++--
 3 files changed, 113 insertions(+), 54 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index d54446f..b665b20 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -127,8 +127,8 @@ enum {				/* adapter interrupt-maintained statistics */
 
 enum {
 	TP_VERSION_MAJOR	= 1,
-	TP_VERSION_MINOR	= 0,
-	TP_VERSION_MICRO	= 44
+	TP_VERSION_MINOR	= 1,
+	TP_VERSION_MICRO	= 0
 };
 
 #define S_TP_VERSION_MAJOR		16
@@ -438,6 +438,7 @@ enum {					    /* chip revisions */
 	T3_REV_A  = 0,
 	T3_REV_B  = 2,
 	T3_REV_B2 = 3,
+	T3_REV_C  = 4,
 };
 
 struct trace_params {
@@ -682,7 +683,8 @@ const struct adapter_info *t3_get_adapter_info(unsigned int board_id);
 int t3_seeprom_read(struct adapter *adapter, u32 addr, u32 *data);
 int t3_seeprom_write(struct adapter *adapter, u32 addr, u32 data);
 int t3_seeprom_wp(struct adapter *adapter, int enable);
-int t3_check_tpsram_version(struct adapter *adapter);
+int t3_get_tp_version(struct adapter *adapter, u32 *vers);
+int t3_check_tpsram_version(struct adapter *adapter, int *must_load);
 int t3_check_tpsram(struct adapter *adapter, u8 *tp_ram, unsigned int size);
 int t3_set_proto_sram(struct adapter *adap, u8 *data);
 int t3_read_flash(struct adapter *adapter, unsigned int addr,
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index e5744e7..65ded16 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -721,6 +721,7 @@ static void bind_qsets(struct adapter *adap)
 }
 
 #define FW_FNAME "t3fw-%d.%d.%d.bin"
+#define TPSRAM_NAME "t3%c_protocol_sram-%d.%d.%d.bin"
 
 static int upgrade_fw(struct adapter *adap)
 {
@@ -742,6 +743,61 @@ static int upgrade_fw(struct adapter *adap)
 	return ret;
 }
 
+static inline char t3rev2char(struct adapter *adapter)
+{
+	char rev = 0;
+
+	switch(adapter->params.rev) {
+	case T3_REV_A:
+		rev = 'a';
+		break;
+	case T3_REV_B:
+	case T3_REV_B2:
+		rev = 'b';
+		break;
+	case T3_REV_C:
+		rev = 'c';
+		break;
+	}
+	return rev;
+}
+
+int update_tpsram(struct adapter *adap)
+{
+	const struct firmware *tpsram;
+	char buf[64];
+	struct device *dev = &adap->pdev->dev;
+	int ret;
+	char rev;
+	
+	rev = t3rev2char(adap);
+	if (!rev)
+		return 0;
+
+	snprintf(buf, sizeof(buf), TPSRAM_NAME, rev,
+		 TP_VERSION_MAJOR, TP_VERSION_MINOR, TP_VERSION_MICRO);
+
+	ret = request_firmware(&tpsram, buf, dev);
+	if (ret < 0) {
+		dev_err(dev, "could not load TP SRAM: unable to load %s\n",
+			buf);
+		return ret;
+	}
+	
+	ret = t3_check_tpsram(adap, tpsram->data, tpsram->size);
+	if (ret)
+		goto release_tpsram;	
+
+	ret = t3_set_proto_sram(adap, tpsram->data);
+	if (ret)
+		dev_err(dev, "loading protocol SRAM failed\n");
+
+release_tpsram:
+	release_firmware(tpsram);
+	
+	return ret;
+}
+
 /**
  *	cxgb_up - enable the adapter
  *	@adapter: adapter being enabled
@@ -755,6 +811,7 @@ static int upgrade_fw(struct adapter *adap)
 static int cxgb_up(struct adapter *adap)
 {
 	int err = 0;
+	int must_load;
 
 	if (!(adap->flags & FULL_INIT_DONE)) {
 		err = t3_check_fw_version(adap);
@@ -763,6 +820,13 @@ static int cxgb_up(struct adapter *adap)
 		if (err)
 			goto out;
 
+		err = t3_check_tpsram_version(adap, &must_load);
+		if (err == -EINVAL) {
+			err = update_tpsram(adap);
+			if (err && must_load)
+				goto out;
+		}
+
 		err = init_dummy_netdevs(adap);
 		if (err)
 			goto out;
@@ -1097,9 +1161,11 @@ static int get_eeprom_len(struct net_device *dev)
 static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	u32 fw_vers = 0;
+	u32 tp_vers = 0;
 	struct adapter *adapter = dev->priv;
 
 	t3_get_fw_version(adapter, &fw_vers);
+	t3_get_tp_version(adapter, &tp_vers);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -1108,11 +1174,14 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 		strcpy(info->fw_version, "N/A");
 	else {
 		snprintf(info->fw_version, sizeof(info->fw_version),
-			 "%s %u.%u.%u",
+			 "%s %u.%u.%u TP %u.%u.%u",
 			 G_FW_VERSION_TYPE(fw_vers) ? "T" : "N",
 			 G_FW_VERSION_MAJOR(fw_vers),
 			 G_FW_VERSION_MINOR(fw_vers),
-			 G_FW_VERSION_MICRO(fw_vers));
+			 G_FW_VERSION_MICRO(fw_vers),
+			 G_TP_VERSION_MAJOR(tp_vers),
+			 G_TP_VERSION_MINOR(tp_vers),
+			 G_TP_VERSION_MICRO(tp_vers));
 	}
 }
 
@@ -2088,42 +2157,6 @@ static void cxgb_netpoll(struct net_device *dev)
 }
 #endif
 
-#define TPSRAM_NAME "t3%c_protocol_sram-%d.%d.%d.bin"
-int update_tpsram(struct adapter *adap)
-{
-	const struct firmware *tpsram;
-	char buf[64];
-	struct device *dev = &adap->pdev->dev;
-	int ret;
-	char rev;
-	
-	rev = adap->params.rev == T3_REV_B2 ? 'b' : 'a';
-
-	snprintf(buf, sizeof(buf), TPSRAM_NAME, rev,
-		 TP_VERSION_MAJOR, TP_VERSION_MINOR, TP_VERSION_MICRO);
-
-	ret = request_firmware(&tpsram, buf, dev);
-	if (ret < 0) {
-		dev_err(dev, "could not load TP SRAM: unable to load %s\n",
-			buf);
-		return ret;
-	}
-	
-	ret = t3_check_tpsram(adap, tpsram->data, tpsram->size);
-	if (ret)
-		goto release_tpsram;	
-
-	ret = t3_set_proto_sram(adap, tpsram->data);
-	if (ret)
-		dev_err(dev, "loading protocol SRAM failed\n");
-
-release_tpsram:
-	release_firmware(tpsram);
-	
-	return ret;
-}
-
-
 /*
  * Periodic accumulation of MAC statistics.
  */
@@ -2478,13 +2511,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 		err = -ENODEV;
 		goto out_free_dev;
 	}
-
-	err = t3_check_tpsram_version(adapter);
-	if (err == -EINVAL)
-		err = update_tpsram(adapter);
-
-	if (err)
-		goto out_free_dev;
 		
 	/*
 	 * The card is now ready to go.  If any errors occur during device
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 13bfbec..63032e8 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -849,16 +849,15 @@ static int t3_write_flash(struct adapter *adapter, unsigned int addr,
 }
 
 /**
- *	t3_check_tpsram_version - read the tp sram version
+ *	t3_get_tp_version - read the tp sram version
  *	@adapter: the adapter
+ *	@vers: where to place the version
  *
- *	Reads the protocol sram version from serial eeprom.
+ *	Reads the protocol sram version from sram.
  */
-int t3_check_tpsram_version(struct adapter *adapter)
+int t3_get_tp_version(struct adapter *adapter, u32 *vers)
 {
 	int ret;
-	u32 vers;
-	unsigned int major, minor;
 
 	/* Get version loaded in SRAM */
 	t3_write_reg(adapter, A_TP_EMBED_OP_FIELD0, 0);
@@ -867,7 +866,29 @@ int t3_check_tpsram_version(struct adapter *adapter)
 	if (ret)
 		return ret;
 	
-	vers = t3_read_reg(adapter, A_TP_EMBED_OP_FIELD1);
+	*vers = t3_read_reg(adapter, A_TP_EMBED_OP_FIELD1);
+
+	return 0;
+}
+
+/**
+ *	t3_check_tpsram_version - read the tp sram version
+ *	@adapter: the adapter
+ *	@must_load: set to 1 if loading a new microcode image is required
+ *
+ *	Reads the protocol sram version from flash.
+ */
+int t3_check_tpsram_version(struct adapter *adapter, int *must_load)
+{
+	int ret;
+	u32 vers;
+	unsigned int major, minor;
+
+	*must_load = 1;
+
+	ret = t3_get_tp_version(adapter, &vers);
+	if (ret)
+		return ret;
 
 	major = G_TP_VERSION_MAJOR(vers);
 	minor = G_TP_VERSION_MINOR(vers);
@@ -875,6 +896,16 @@ int t3_check_tpsram_version(struct adapter *adapter)
 	if (major == TP_VERSION_MAJOR && minor == TP_VERSION_MINOR) 
 		return 0;
 
+	if (major != TP_VERSION_MAJOR)
+		CH_ERR(adapter, "found wrong TP version (%u.%u), "
+		       "driver needs version %d.%d\n", major, minor,
+		       TP_VERSION_MAJOR, TP_VERSION_MINOR);
+	else {
+		*must_load = 0;
+		CH_ERR(adapter, "found wrong TP version (%u.%u), "
+		       "driver compiled for version %d.%d\n", major, minor,
+		       TP_VERSION_MAJOR, TP_VERSION_MINOR);
+	}
 	return -EINVAL;
 }
 
