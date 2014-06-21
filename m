From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFT 3/3] cxgb4: make device firmware load use request_firmware_nowait()
Date: Fri, 20 Jun 2014 17:39:41 -0700
Message-ID: <1403311181-9328-4-git-send-email-mcgrof@do-not-panic.com>
References: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com>
Cc: poswald@suse.com, santosh@chelsio.com, jcheung@suse.com,
	dchang@suse.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mcgrof@suse.com
To: hariprasad@chelsio.com, leedom@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

cxgb4 loading can take a while, this ends the crusade to
change it to be asynchronous.

Cc: Casey Leedom <leedom@chelsio.com>
Cc: Hariprasad Shenai <hariprasad@chelsio.com>
Cc: Philip Oswald <poswald@suse.com>
Cc: Santosh Rastapur <santosh@chelsio.com>
Cc: Jeffrey Cheung <jcheung@suse.com>
Cc: David Chang <dchang@suse.com>
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   6 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 105 ++++++++++++++----------
 2 files changed, 67 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 1507dc2..89296f1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -654,6 +654,12 @@ struct adapter {
 	char fw_config_file[32];
 	struct completion config_comp;
 	int config_comp_status;
+
+	struct fw_info *fw_info;
+	struct completion fw_comp;
+	int fw_comp_status;
+	enum dev_state state;
+	int reset;
 };
 
 /* Defined bit width of user definable filter tuples
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 65e4124..105b83a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5341,6 +5341,39 @@ static struct fw_info *find_fw_info(int chip)
 	return NULL;
 }
 
+static void cxgb4_fw_complete(const struct firmware *fw, void *context)
+{
+	struct adapter *adap = context;
+	struct fw_hdr *card_fw;
+	const u8 *fw_data = NULL;
+	unsigned int fw_size = 0;
+
+	/* allocate memory to read the header of the firmware on the
+	 * card
+	 */
+	card_fw = t4_alloc_mem(sizeof(*card_fw));
+
+	if (!fw) {
+		dev_err(adap->pdev_dev,
+			"unable to load firmware image %s\n",
+			adap->fw_info->fw_mod_name);
+	} else {
+		fw_data = fw->data;
+		fw_size = fw->size;
+	}
+
+	/* upgrade FW logic */
+	adap->fw_comp_status = t4_prep_fw(adap, adap->fw_info, fw_data,
+					  fw_size, card_fw, adap->state,
+					  &adap->reset);
+
+	/* Cleaning up */
+	if (fw != NULL)
+		release_firmware(fw);
+	t4_free_mem(card_fw);
+	complete(&adap->fw_comp);
+}
+
 /*
  * Phase 0 of initialization: contact FW, obtain config, perform basic init.
  */
@@ -5348,10 +5381,10 @@ static int adap_init0(struct adapter *adap)
 {
 	int ret;
 	u32 v, port_vec;
-	enum dev_state state;
 	u32 params[7], val[7];
 	struct fw_caps_config_cmd caps_cmd;
-	int reset = 1;
+
+	adap->reset = 1;
 
 	/*
 	 * Contact FW, advertising Master capability (and potentially forcing
@@ -5360,7 +5393,7 @@ static int adap_init0(struct adapter *adap)
 	 */
 	ret = t4_fw_hello(adap, adap->mbox, adap->fn,
 			  force_init ? MASTER_MUST : MASTER_MAY,
-			  &state);
+			  &adap->state);
 	if (ret < 0) {
 		dev_err(adap->pdev_dev, "could not connect to FW, error %d\n",
 			ret);
@@ -5368,8 +5401,8 @@ static int adap_init0(struct adapter *adap)
 	}
 	if (ret == adap->mbox)
 		adap->flags |= MASTER_PF;
-	if (force_init && state == DEV_STATE_INIT)
-		state = DEV_STATE_UNINIT;
+	if (force_init && adap->state == DEV_STATE_INIT)
+		adap->state = DEV_STATE_UNINIT;
 
 	/*
 	 * If we're the Master PF Driver and the device is uninitialized,
@@ -5380,51 +5413,34 @@ static int adap_init0(struct adapter *adap)
 	 */
 	t4_get_fw_version(adap, &adap->params.fw_vers);
 	t4_get_tp_version(adap, &adap->params.tp_vers);
-	if ((adap->flags & MASTER_PF) && state != DEV_STATE_INIT) {
-		struct fw_info *fw_info;
-		struct fw_hdr *card_fw;
-		const struct firmware *fw;
-		const u8 *fw_data = NULL;
-		unsigned int fw_size = 0;
+	if ((adap->flags & MASTER_PF) && adap->state != DEV_STATE_INIT) {
+		init_completion(&adap->fw_comp);
+		adap->fw_comp_status = 0;
 
 		/* This is the firmware whose headers the driver was compiled
 		 * against
 		 */
-		fw_info = find_fw_info(CHELSIO_CHIP_VERSION(adap->params.chip));
-		if (fw_info == NULL) {
+		adap->fw_info =
+			find_fw_info(CHELSIO_CHIP_VERSION(adap->params.chip));
+		if (adap->fw_info == NULL) {
 			dev_err(adap->pdev_dev,
 				"unable to get firmware info for chip %d.\n",
 				CHELSIO_CHIP_VERSION(adap->params.chip));
 			return -EINVAL;
 		}
 
-		/* allocate memory to read the header of the firmware on the
-		 * card
-		 */
-		card_fw = t4_alloc_mem(sizeof(*card_fw));
-
 		/* Get FW from from /lib/firmware/ */
-		ret = request_firmware(&fw, fw_info->fw_mod_name,
-				       adap->pdev_dev);
-		if (ret < 0) {
-			dev_err(adap->pdev_dev,
-				"unable to load firmware image %s, error %d\n",
-				fw_info->fw_mod_name, ret);
-		} else {
-			fw_data = fw->data;
-			fw_size = fw->size;
-		}
-
-		/* upgrade FW logic */
-		ret = t4_prep_fw(adap, fw_info, fw_data, fw_size, card_fw,
-				 state, &reset);
-
-		/* Cleaning up */
-		if (fw != NULL)
-			release_firmware(fw);
-		t4_free_mem(card_fw);
-
+		ret = request_firmware_nowait(THIS_MODULE, 1,
+					      adap->fw_info->fw_mod_name,
+					      adap->pdev_dev,
+					      GFP_KERNEL,
+					      adap,
+					      cxgb4_fw_complete);
 		if (ret < 0)
+			return -EINVAL;
+
+		wait_for_completion(&adap->fw_comp);
+		if (adap->fw_comp_status < 0)
 			goto bye;
 	}
 
@@ -5460,7 +5476,7 @@ static int adap_init0(struct adapter *adap)
 	 * adapter parameters.  Otherwise, it's time to try initializing the
 	 * adapter ...
 	 */
-	if (state == DEV_STATE_INIT) {
+	if (adap->state == DEV_STATE_INIT) {
 		dev_info(adap->pdev_dev, "Coming up as %s: "\
 			 "Adapter already initialized\n",
 			 adap->flags & MASTER_PF ? "MASTER" : "SLAVE");
@@ -5477,7 +5493,7 @@ static int adap_init0(struct adapter *adap)
 			dev_warn(adap->pdev_dev, "Firmware doesn't support "
 				 "configuration file.\n");
 		if (force_old_init)
-			ret = adap_init0_no_config(adap, reset);
+			ret = adap_init0_no_config(adap, adap->reset);
 		else {
 			/*
 			 * Find out whether we're dealing with a version of
@@ -5497,7 +5513,7 @@ static int adap_init0(struct adapter *adap)
 			 * Configuration File found.
 			 */
 			if (ret < 0)
-				ret = adap_init0_no_config(adap, reset);
+				ret = adap_init0_no_config(adap, adap->reset);
 			else {
 				/*
 				 * The firmware provides us with a memory
@@ -5506,13 +5522,14 @@ static int adap_init0(struct adapter *adap)
 				 * the Configuration File in flash.
 				 */
 
-				ret = adap_init0_config(adap, reset);
+				ret = adap_init0_config(adap, adap->reset);
 				if (ret == -ENOENT) {
 					dev_info(adap->pdev_dev,
 					    "No Configuration File present "
 					    "on adapter. Using hard-wired "
 					    "configuration parameters.\n");
-					ret = adap_init0_no_config(adap, reset);
+					ret = adap_init0_no_config(adap,
+								   adap->reset);
 				}
 			}
 		}
@@ -5711,7 +5728,7 @@ static int adap_init0(struct adapter *adap)
 	 * parameters.
 	 */
 	t4_read_mtu_tbl(adap, adap->params.mtus, NULL);
-	if (state != DEV_STATE_INIT) {
+	if (adap->state != DEV_STATE_INIT) {
 		int i;
 
 		/* The default MTU Table contains values 1492 and 1500.
-- 
2.0.0
