From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.23 2/2] - cxgb3 engine microcode load
Date: Wed, 29 Aug 2007 19:15:52 -0700
Message-ID: <20070830021552.21493.76824.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:20845 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759236AbXH3CP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 22:15:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Load the engine microcode when an interface 
is brought up, instead of of doing it when the module
is loaded. 
Loosen up tight binding between the driver and the 
engine microcode version. 
There is no need for microcode update with T3A boards.
Fix the file naming.
Do a better job at logging the loading activity.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h     |    3 +
 drivers/net/cxgb3/cxgb3_main.c |  126 ++++++++++++++++++++++++++--------------
 drivers/net/cxgb3/t3_hw.c      |   46 +++++++++++++--
 3 files changed, 123 insertions(+), 52 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 1637800..2129210 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -679,7 +679,8 @@ const struct adapter_info *t3_get_adapter_info(unsigned int board_id);
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
index f3bf128..5ab319c 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -729,6 +729,7 @@ static void bind_qsets(struct adapter *adap)
 }
 
 #define FW_FNAME "t3fw-%d.%d.%d.bin"
+#define TPSRAM_NAME "t3%c_protocol_sram-%d.%d.%d.bin"
 
 static int upgrade_fw(struct adapter *adap)
 {
@@ -747,6 +748,71 @@ static int upgrade_fw(struct adapter *adap)
 	}
 	ret = t3_load_fw(adap, fw->data, fw->size);
 	release_firmware(fw);
+
+	if (ret == 0)
+		dev_info(dev, "successful upgrade to firmware %d.%d.%d\n",
+			 FW_VERSION_MAJOR, FW_VERSION_MINOR, FW_VERSION_MICRO);
+	else
+		dev_err(dev, "failed to upgrade to firmware %d.%d.%d\n",
+			FW_VERSION_MAJOR, FW_VERSION_MINOR, FW_VERSION_MICRO);
+	
+	return ret;
+}
+
+static inline char t3rev2char(struct adapter *adapter)
+{
+	char rev = 0;
+
+	switch(adapter->params.rev) {
+	case T3_REV_B:
+	case T3_REV_B2:
+		rev = 'b';
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
+	if (ret == 0)
+		dev_info(dev,
+			 "successful update of protocol engine "
+			 "to %d.%d.%d\n",
+			 TP_VERSION_MAJOR, TP_VERSION_MINOR, TP_VERSION_MICRO);
+	else
+		dev_err(dev, "failed to update of protocol engine %d.%d.%d\n",
+			TP_VERSION_MAJOR, TP_VERSION_MINOR, TP_VERSION_MICRO);
+	if (ret)
+		dev_err(dev, "loading protocol SRAM failed\n");
+
+release_tpsram:
+	release_firmware(tpsram);
+	
 	return ret;
 }
 
@@ -763,6 +829,7 @@ static int upgrade_fw(struct adapter *adap)
 static int cxgb_up(struct adapter *adap)
 {
 	int err = 0;
+	int must_load;
 
 	if (!(adap->flags & FULL_INIT_DONE)) {
 		err = t3_check_fw_version(adap);
@@ -771,6 +838,13 @@ static int cxgb_up(struct adapter *adap)
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
@@ -1110,8 +1184,10 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
 	u32 fw_vers = 0;
+	u32 tp_vers = 0;
 
 	t3_get_fw_version(adapter, &fw_vers);
+	t3_get_tp_version(adapter, &tp_vers);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -1120,11 +1196,14 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
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
 
@@ -2107,42 +2186,6 @@ static void cxgb_netpoll(struct net_device *dev)
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
@@ -2491,13 +2534,6 @@ static int __devinit init_one(struct pci_dev *pdev,
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
index dd3149d..b02d15d 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -848,16 +848,15 @@ static int t3_write_flash(struct adapter *adapter, unsigned int addr,
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
@@ -866,7 +865,32 @@ int t3_check_tpsram_version(struct adapter *adapter)
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
+	if (adapter->params.rev == T3_REV_A)
+		return 0;
+
+	*must_load = 1;
+
+	ret = t3_get_tp_version(adapter, &vers);
+	if (ret)
+		return ret;
 
 	major = G_TP_VERSION_MAJOR(vers);
 	minor = G_TP_VERSION_MINOR(vers);
@@ -874,6 +898,16 @@ int t3_check_tpsram_version(struct adapter *adapter)
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
 
