From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Add PHY firmware support for T420-BT cards
Date: Fri, 22 May 2015 21:58:21 +0530
Message-ID: <1432312101-7944-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23131 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757115AbbEVLPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 07:15:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for flashing 10GBaseT adapter with BCM 84834 PHY and
Aquantia AQ1202 PHY.

Updating of the PHY firmware must happen before the INITIALIZE_CMD.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  39 ++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 155 ++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 217 ++++++++++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |   6 +
 4 files changed, 375 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 6e884d1..3c109d1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1101,6 +1101,19 @@ static inline int is_bypass_device(int device)
 	}
 }
 
+static inline int is_10gbt_device(int device)
+{
+	/* this should be set based upon device capabilities */
+	switch (device) {
+	case 0x4409:
+	case 0x4486:
+		return 1;
+
+	default:
+		return 0;
+	}
+}
+
 static inline unsigned int core_ticks_per_usec(const struct adapter *adap)
 {
 	return adap->params.vpd.cclk / 1000;
@@ -1123,9 +1136,19 @@ static inline unsigned int core_ticks_to_us(const struct adapter *adapter,
 void t4_set_reg_field(struct adapter *adap, unsigned int addr, u32 mask,
 		      u32 val);
 
+int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
+			    int size, void *rpl, bool sleep_ok, int timeout);
 int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 		    void *rpl, bool sleep_ok);
 
+static inline int t4_wr_mbox_timeout(struct adapter *adap, int mbox,
+				     const void *cmd, int size, void *rpl,
+				     int timeout)
+{
+	return t4_wr_mbox_meat_timeout(adap, mbox, cmd, size, rpl, true,
+				       timeout);
+}
+
 static inline int t4_wr_mbox(struct adapter *adap, int mbox, const void *cmd,
 			     int size, void *rpl)
 {
@@ -1179,6 +1202,11 @@ int get_vpd_params(struct adapter *adapter, struct vpd_params *p);
 int t4_read_flash(struct adapter *adapter, unsigned int addr,
 		  unsigned int nwords, u32 *data, int byte_oriented);
 int t4_load_fw(struct adapter *adapter, const u8 *fw_data, unsigned int size);
+int t4_load_phy_fw(struct adapter *adap,
+		   int win, spinlock_t *lock,
+		   int (*phy_fw_version)(const u8 *, size_t),
+		   const u8 *phy_fw_data, size_t phy_fw_size);
+int t4_phy_fw_ver(struct adapter *adap, int *phy_fw_ver);
 int t4_fwcache(struct adapter *adap, enum fw_params_param_dev_fwcache op);
 int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
 		  const u8 *fw_data, unsigned int size, int force);
@@ -1269,13 +1297,16 @@ int t4_fw_initialize(struct adapter *adap, unsigned int mbox);
 int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		    unsigned int vf, unsigned int nparams, const u32 *params,
 		    u32 *val);
+int t4_query_params_rw(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		       unsigned int vf, unsigned int nparams, const u32 *params,
+		       u32 *val, int rw);
+int t4_set_params_timeout(struct adapter *adap, unsigned int mbox,
+			  unsigned int pf, unsigned int vf,
+			  unsigned int nparams, const u32 *params,
+			  const u32 *val, int timeout);
 int t4_set_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		  unsigned int vf, unsigned int nparams, const u32 *params,
 		  const u32 *val);
-int t4_set_params_nosleep(struct adapter *adap, unsigned int mbox,
-			  unsigned int pf, unsigned int vf,
-			  unsigned int nparams, const u32 *params,
-			  const u32 *val);
 int t4_cfg_pfvf(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		unsigned int vf, unsigned int txq, unsigned int txq_eth_ctrl,
 		unsigned int rxqi, unsigned int rxq, unsigned int tc,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5b8f80fb..73ac153 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -137,6 +137,10 @@ struct filter_entry {
 #define FW5_FNAME "cxgb4/t5fw.bin"
 #define FW4_CFNAME "cxgb4/t4-config.txt"
 #define FW5_CFNAME "cxgb4/t5-config.txt"
+#define PHY_AQ1202_FIRMWARE "cxgb4/aq1202_fw.cld"
+#define PHY_BCM84834_FIRMWARE "cxgb4/bcm8483.bin"
+#define PHY_AQ1202_DEVICEID 0x4409
+#define PHY_BCM84834_DEVICEID 0x4486
 
 MODULE_DESCRIPTION(DRV_DESC);
 MODULE_AUTHOR("Chelsio Communications");
@@ -318,8 +322,9 @@ static void dcb_tx_queue_prio_enable(struct net_device *dev, int enable)
 		 * level") we need to issue the Set Parameters Commannd
 		 * without sleeping (timeout < 0).
 		 */
-		err = t4_set_params_nosleep(adap, adap->mbox, adap->fn, 0, 1,
-					    &name, &value);
+		err = t4_set_params_timeout(adap, adap->mbox, adap->fn, 0, 1,
+					    &name, &value,
+					    -FW_CMD_MAX_TIMEOUT);
 
 		if (err)
 			dev_err(adap->pdev_dev,
@@ -3222,6 +3227,142 @@ static int adap_init0_tweaks(struct adapter *adapter)
 	return 0;
 }
 
+/* 10Gb/s-BT PHY Support. chip-external 10Gb/s-BT PHYs are complex chips
+ * unto themselves and they contain their own firmware to perform their
+ * tasks ...
+ */
+static int phy_aq1202_version(const u8 *phy_fw_data,
+			      size_t phy_fw_size)
+{
+	int offset;
+
+	/* At offset 0x8 you're looking for the primary image's
+	 * starting offset which is 3 Bytes wide
+	 *
+	 * At offset 0xa of the primary image, you look for the offset
+	 * of the DRAM segment which is 3 Bytes wide.
+	 *
+	 * The FW version is at offset 0x27e of the DRAM and is 2 Bytes
+	 * wide
+	 */
+	#define be16(__p) (((__p)[0] << 8) | (__p)[1])
+	#define le16(__p) ((__p)[0] | ((__p)[1] << 8))
+	#define le24(__p) (le16(__p) | ((__p)[2] << 16))
+
+	offset = le24(phy_fw_data + 0x8) << 12;
+	offset = le24(phy_fw_data + offset + 0xa);
+	return be16(phy_fw_data + offset + 0x27e);
+
+	#undef be16
+	#undef le16
+	#undef le24
+}
+
+static struct info_10gbt_phy_fw {
+	unsigned int phy_fw_id;		/* PCI Device ID */
+	char *phy_fw_file;		/* /lib/firmware/ PHY Firmware file */
+	int (*phy_fw_version)(const u8 *phy_fw_data, size_t phy_fw_size);
+	int phy_flash;			/* Has FLASH for PHY Firmware */
+} phy_info_array[] = {
+	{
+		PHY_AQ1202_DEVICEID,
+		PHY_AQ1202_FIRMWARE,
+		phy_aq1202_version,
+		1,
+	},
+	{
+		PHY_BCM84834_DEVICEID,
+		PHY_BCM84834_FIRMWARE,
+		NULL,
+		0,
+	},
+	{ 0, NULL, NULL },
+};
+
+static struct info_10gbt_phy_fw *find_phy_info(int devid)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(phy_info_array); i++) {
+		if (phy_info_array[i].phy_fw_id == devid)
+			return &phy_info_array[i];
+	}
+	return NULL;
+}
+
+/* Handle updating of chip-external 10Gb/s-BT PHY firmware.  This needs to
+ * happen after the FW_RESET_CMD but before the FW_INITIALIZE_CMD.  On error
+ * we return a negative error number.  If we transfer new firmware we return 1
+ * (from t4_load_phy_fw()).  If we don't do anything we return 0.
+ */
+static int adap_init0_phy(struct adapter *adap)
+{
+	const struct firmware *phyf;
+	int ret;
+	struct info_10gbt_phy_fw *phy_info;
+
+	/* Use the device ID to determine which PHY file to flash.
+	 */
+	phy_info = find_phy_info(adap->pdev->device);
+	if (!phy_info) {
+		dev_warn(adap->pdev_dev,
+			 "No PHY Firmware file found for this PHY\n");
+		return -EOPNOTSUPP;
+	}
+
+	/* If we have a T4 PHY firmware file under /lib/firmware/cxgb4/, then
+	 * use that. The adapter firmware provides us with a memory buffer
+	 * where we can load a PHY firmware file from the host if we want to
+	 * override the PHY firmware File in flash.
+	 */
+	ret = request_firmware_direct(&phyf, phy_info->phy_fw_file,
+				      adap->pdev_dev);
+	if (ret < 0) {
+		/* For adapters without FLASH attached to PHY for their
+		 * firmware, it's obviously a fatal error if we can't get the
+		 * firmware to the adapter.  For adapters with PHY firmware
+		 * FLASH storage, it's worth a warning if we can't find the
+		 * PHY Firmware but we'll neuter the error ...
+		 */
+		dev_err(adap->pdev_dev, "unable to find PHY Firmware image "
+			"/lib/firmware/%s, error %d\n",
+			phy_info->phy_fw_file, -ret);
+		if (phy_info->phy_flash) {
+			int cur_phy_fw_ver = 0;
+
+			t4_phy_fw_ver(adap, &cur_phy_fw_ver);
+			dev_warn(adap->pdev_dev, "continuing with, on-adapter "
+				 "FLASH copy, version %#x\n", cur_phy_fw_ver);
+			ret = 0;
+		}
+
+		return ret;
+	}
+
+	/* Load PHY Firmware onto adapter.
+	 */
+	ret = t4_load_phy_fw(adap, MEMWIN_NIC, &adap->win0_lock,
+			     phy_info->phy_fw_version,
+			     (u8 *)phyf->data, phyf->size);
+	if (ret < 0)
+		dev_err(adap->pdev_dev, "PHY Firmware transfer error %d\n",
+			-ret);
+	else if (ret > 0) {
+		int new_phy_fw_ver = 0;
+
+		if (phy_info->phy_fw_version)
+			new_phy_fw_ver = phy_info->phy_fw_version(phyf->data,
+								  phyf->size);
+		dev_info(adap->pdev_dev, "Successfully transferred PHY "
+			 "Firmware /lib/firmware/%s, version %#x\n",
+			 phy_info->phy_fw_file, new_phy_fw_ver);
+	}
+
+	release_firmware(phyf);
+
+	return ret;
+}
+
 /*
  * Attempt to initialize the adapter via a Firmware Configuration File.
  */
@@ -3246,6 +3387,16 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 			goto bye;
 	}
 
+	/* If this is a 10Gb/s-BT adapter make sure the chip-external
+	 * 10Gb/s-BT PHYs have up-to-date firmware.  Note that this step needs
+	 * to be performed after any global adapter RESET above since some
+	 * PHYs only have local RAM copies of the PHY firmware.
+	 */
+	if (is_10gbt_device(adapter->pdev->device)) {
+		ret = adap_init0_phy(adapter);
+		if (ret < 0)
+			goto bye;
+	}
 	/*
 	 * If we have a T4 configuration file under /lib/firmware/cxgb4/,
 	 * then use that.  Otherwise, use the configuration file stored
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index be34eaa..7b92f0f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -233,13 +233,14 @@ static void dump_mbox(struct adapter *adap, int mbox, u32 data_reg)
 }
 
 /**
- *	t4_wr_mbox_meat - send a command to FW through the given mailbox
+ *	t4_wr_mbox_meat_timeout - send a command to FW through the given mailbox
  *	@adap: the adapter
  *	@mbox: index of the mailbox to use
  *	@cmd: the command to write
  *	@size: command length in bytes
  *	@rpl: where to optionally store the reply
  *	@sleep_ok: if true we may sleep while awaiting command completion
+ *	@timeout: time to wait for command to finish before timing out
  *
  *	Sends the given command to FW through the selected mailbox and waits
  *	for the FW to execute the command.  If @rpl is not %NULL it is used to
@@ -254,8 +255,8 @@ static void dump_mbox(struct adapter *adap, int mbox, u32 data_reg)
  *	command or FW executes it but signals an error.  In the latter case
  *	the return value is the error code indicated by FW (negated).
  */
-int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
-		    void *rpl, bool sleep_ok)
+int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
+			    int size, void *rpl, bool sleep_ok, int timeout)
 {
 	static const int delay[] = {
 		1, 1, 3, 5, 10, 10, 20, 50, 100, 200
@@ -294,7 +295,7 @@ int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 	delay_idx = 0;
 	ms = delay[0];
 
-	for (i = 0; i < FW_CMD_MAX_TIMEOUT; i += ms) {
+	for (i = 0; i < timeout; i += ms) {
 		if (sleep_ok) {
 			ms = delay[delay_idx];  /* last element may repeat */
 			if (delay_idx < ARRAY_SIZE(delay) - 1)
@@ -332,6 +333,13 @@ int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 	return -ETIMEDOUT;
 }
 
+int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
+		    void *rpl, bool sleep_ok)
+{
+	return t4_wr_mbox_meat_timeout(adap, mbox, cmd, size, rpl, sleep_ok,
+				       FW_CMD_MAX_TIMEOUT);
+}
+
 /**
  *	t4_memory_rw - read/write EDC 0, EDC 1 or MC via PCIE memory window
  *	@adap: the adapter
@@ -2038,6 +2046,147 @@ out:
 }
 
 /**
+ *	t4_phy_fw_ver - return current PHY firmware version
+ *	@adap: the adapter
+ *	@phy_fw_ver: return value buffer for PHY firmware version
+ *
+ *	Returns the current version of external PHY firmware on the
+ *	adapter.
+ */
+int t4_phy_fw_ver(struct adapter *adap, int *phy_fw_ver)
+{
+	u32 param, val;
+	int ret;
+
+	param = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+		 FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_PHYFW) |
+		 FW_PARAMS_PARAM_Y_V(adap->params.portvec) |
+		 FW_PARAMS_PARAM_Z_V(FW_PARAMS_PARAM_DEV_PHYFW_VERSION));
+	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 1,
+			      &param, &val);
+	if (ret < 0)
+		return ret;
+	*phy_fw_ver = val;
+	return 0;
+}
+
+/**
+ *	t4_load_phy_fw - download port PHY firmware
+ *	@adap: the adapter
+ *	@win: the PCI-E Memory Window index to use for t4_memory_rw()
+ *	@win_lock: the lock to use to guard the memory copy
+ *	@phy_fw_version: function to check PHY firmware versions
+ *	@phy_fw_data: the PHY firmware image to write
+ *	@phy_fw_size: image size
+ *
+ *	Transfer the specified PHY firmware to the adapter.  If a non-NULL
+ *	@phy_fw_version is supplied, then it will be used to determine if
+ *	it's necessary to perform the transfer by comparing the version
+ *	of any existing adapter PHY firmware with that of the passed in
+ *	PHY firmware image.  If @win_lock is non-NULL then it will be used
+ *	around the call to t4_memory_rw() which transfers the PHY firmware
+ *	to the adapter.
+ *
+ *	A negative error number will be returned if an error occurs.  If
+ *	version number support is available and there's no need to upgrade
+ *	the firmware, 0 will be returned.  If firmware is successfully
+ *	transferred to the adapter, 1 will be retured.
+ *
+ *	NOTE: some adapters only have local RAM to store the PHY firmware.  As
+ *	a result, a RESET of the adapter would cause that RAM to lose its
+ *	contents.  Thus, loading PHY firmware on such adapters must happen
+ *	after any FW_RESET_CMDs ...
+ */
+int t4_load_phy_fw(struct adapter *adap,
+		   int win, spinlock_t *win_lock,
+		   int (*phy_fw_version)(const u8 *, size_t),
+		   const u8 *phy_fw_data, size_t phy_fw_size)
+{
+	unsigned long mtype = 0, maddr = 0;
+	u32 param, val;
+	int cur_phy_fw_ver = 0, new_phy_fw_vers = 0;
+	int ret;
+
+	/* If we have version number support, then check to see if the adapter
+	 * already has up-to-date PHY firmware loaded.
+	 */
+	 if (phy_fw_version) {
+		new_phy_fw_vers = phy_fw_version(phy_fw_data, phy_fw_size);
+		ret = t4_phy_fw_ver(adap, &cur_phy_fw_ver);
+		if (ret < 0)
+			return ret;
+
+		if (cur_phy_fw_ver >= new_phy_fw_vers) {
+			CH_WARN(adap, "PHY Firmware already up-to-date, "
+				"version %#x\n", cur_phy_fw_ver);
+			return 0;
+		}
+	}
+
+	/* Ask the firmware where it wants us to copy the PHY firmware image.
+	 * The size of the file requires a special version of the READ coommand
+	 * which will pass the file size via the values field in PARAMS_CMD and
+	 * retrieve the return value from firmware and place it in the same
+	 * buffer values
+	 */
+	param = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+		 FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_PHYFW) |
+		 FW_PARAMS_PARAM_Y_V(adap->params.portvec) |
+		 FW_PARAMS_PARAM_Z_V(FW_PARAMS_PARAM_DEV_PHYFW_DOWNLOAD));
+	val = phy_fw_size;
+	ret = t4_query_params_rw(adap, adap->mbox, adap->fn, 0, 1,
+				 &param, &val, 1);
+	if (ret < 0)
+		return ret;
+	mtype = val >> 8;
+	maddr = (val & 0xff) << 16;
+
+	/* Copy the supplied PHY Firmware image to the adapter memory location
+	 * allocated by the adapter firmware.
+	 */
+	if (win_lock)
+		spin_lock_bh(win_lock);
+	ret = t4_memory_rw(adap, win, mtype, maddr,
+			   phy_fw_size, (__be32 *)phy_fw_data,
+			   T4_MEMORY_WRITE);
+	if (win_lock)
+		spin_unlock_bh(win_lock);
+	if (ret)
+		return ret;
+
+	/* Tell the firmware that the PHY firmware image has been written to
+	 * RAM and it can now start copying it over to the PHYs.  The chip
+	 * firmware will RESET the affected PHYs as part of this operation
+	 * leaving them running the new PHY firmware image.
+	 */
+	param = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+		 FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_PHYFW) |
+		 FW_PARAMS_PARAM_Y_V(adap->params.portvec) |
+		 FW_PARAMS_PARAM_Z_V(FW_PARAMS_PARAM_DEV_PHYFW_DOWNLOAD));
+	ret = t4_set_params_timeout(adap, adap->mbox, adap->fn, 0, 1,
+				    &param, &val, 30000);
+
+	/* If we have version number support, then check to see that the new
+	 * firmware got loaded properly.
+	 */
+	if (phy_fw_version) {
+		ret = t4_phy_fw_ver(adap, &cur_phy_fw_ver);
+		if (ret < 0)
+			return ret;
+
+		if (cur_phy_fw_ver != new_phy_fw_vers) {
+			CH_WARN(adap, "PHY Firmware did not update: "
+				"version on adapter %#x, "
+				"version flashed %#x\n",
+				cur_phy_fw_ver, new_phy_fw_vers);
+			return -ENXIO;
+		}
+	}
+
+	return 1;
+}
+
+/**
  *	t4_fwcache - firmware cache operation
  *	@adap: the adapter
  *	@op  : the operation (flush or flush and invalidate)
@@ -4362,7 +4511,7 @@ int t4_fw_initialize(struct adapter *adap, unsigned int mbox)
 }
 
 /**
- *	t4_query_params - query FW or device parameters
+ *	t4_query_params_rw - query FW or device parameters
  *	@adap: the adapter
  *	@mbox: mailbox to use for the FW command
  *	@pf: the PF
@@ -4370,13 +4519,14 @@ int t4_fw_initialize(struct adapter *adap, unsigned int mbox)
  *	@nparams: the number of parameters
  *	@params: the parameter names
  *	@val: the parameter values
+ *	@rw: Write and read flag
  *
  *	Reads the value of FW or device parameters.  Up to 7 parameters can be
  *	queried at once.
  */
-int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
-		    unsigned int vf, unsigned int nparams, const u32 *params,
-		    u32 *val)
+int t4_query_params_rw(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		       unsigned int vf, unsigned int nparams, const u32 *params,
+		       u32 *val, int rw)
 {
 	int i, ret;
 	struct fw_params_cmd c;
@@ -4392,8 +4542,12 @@ int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 				  FW_PARAMS_CMD_VFN_V(vf));
 	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
 
-	for (i = 0; i < nparams; i++, p += 2)
-		*p = cpu_to_be32(*params++);
+	for (i = 0; i < nparams; i++) {
+		*p++ = cpu_to_be32(*params++);
+		if (rw)
+			*p = cpu_to_be32(*(val + i));
+		p++;
+	}
 
 	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
 	if (ret == 0)
@@ -4402,8 +4556,15 @@ int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	return ret;
 }
 
+int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		    unsigned int vf, unsigned int nparams, const u32 *params,
+		    u32 *val)
+{
+	return t4_query_params_rw(adap, mbox, pf, vf, nparams, params, val, 0);
+}
+
 /**
- *      t4_set_params_nosleep - sets FW or device parameters
+ *      t4_set_params_timeout - sets FW or device parameters
  *      @adap: the adapter
  *      @mbox: mailbox to use for the FW command
  *      @pf: the PF
@@ -4411,15 +4572,15 @@ int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
  *      @nparams: the number of parameters
  *      @params: the parameter names
  *      @val: the parameter values
+ *      @timeout: the timeout time
  *
- *	 Does not ever sleep
  *      Sets the value of FW or device parameters.  Up to 7 parameters can be
  *      specified at once.
  */
-int t4_set_params_nosleep(struct adapter *adap, unsigned int mbox,
+int t4_set_params_timeout(struct adapter *adap, unsigned int mbox,
 			  unsigned int pf, unsigned int vf,
 			  unsigned int nparams, const u32 *params,
-			  const u32 *val)
+			  const u32 *val, int timeout)
 {
 	struct fw_params_cmd c;
 	__be32 *p = &c.param[0].mnem;
@@ -4429,9 +4590,9 @@ int t4_set_params_nosleep(struct adapter *adap, unsigned int mbox,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_PARAMS_CMD) |
-				FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
-				FW_PARAMS_CMD_PFN_V(pf) |
-				FW_PARAMS_CMD_VFN_V(vf));
+				  FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
+				  FW_PARAMS_CMD_PFN_V(pf) |
+				  FW_PARAMS_CMD_VFN_V(vf));
 	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
 
 	while (nparams--) {
@@ -4439,7 +4600,7 @@ int t4_set_params_nosleep(struct adapter *adap, unsigned int mbox,
 		*p++ = cpu_to_be32(*val++);
 	}
 
-	return t4_wr_mbox_ns(adap, mbox, &c, sizeof(c), NULL);
+	return t4_wr_mbox_timeout(adap, mbox, &c, sizeof(c), NULL, timeout);
 }
 
 /**
@@ -4459,24 +4620,8 @@ int t4_set_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		  unsigned int vf, unsigned int nparams, const u32 *params,
 		  const u32 *val)
 {
-	struct fw_params_cmd c;
-	__be32 *p = &c.param[0].mnem;
-
-	if (nparams > 7)
-		return -EINVAL;
-
-	memset(&c, 0, sizeof(c));
-	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_PARAMS_CMD) |
-				  FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
-				  FW_PARAMS_CMD_PFN_V(pf) |
-				  FW_PARAMS_CMD_VFN_V(vf));
-	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
-	while (nparams--) {
-		*p++ = cpu_to_be32(*params++);
-		*p++ = cpu_to_be32(*val++);
-	}
-
-	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+	return t4_set_params_timeout(adap, mbox, pf, vf, nparams, params, val,
+				     FW_CMD_MAX_TIMEOUT);
 }
 
 /**
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 16c6d67..0848317 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1061,6 +1061,7 @@ enum fw_params_param_dev {
 	FW_PARAMS_PARAM_DEV_FWREV = 0x0B,
 	FW_PARAMS_PARAM_DEV_TPREV = 0x0C,
 	FW_PARAMS_PARAM_DEV_CF = 0x0D,
+	FW_PARAMS_PARAM_DEV_PHYFW = 0x0F,
 	FW_PARAMS_PARAM_DEV_DIAG = 0x11,
 	FW_PARAMS_PARAM_DEV_MAXORDIRD_QP = 0x13, /* max supported QP IRD/ORD */
 	FW_PARAMS_PARAM_DEV_MAXIRD_ADAPTER = 0x14, /* max supported adap IRD */
@@ -1126,6 +1127,11 @@ enum fw_params_param_dmaq {
 	FW_PARAMS_PARAM_DMAQ_CONM_CTXT = 0x20,
 };
 
+enum fw_params_param_dev_phyfw {
+	FW_PARAMS_PARAM_DEV_PHYFW_DOWNLOAD = 0x00,
+	FW_PARAMS_PARAM_DEV_PHYFW_VERSION = 0x01,
+};
+
 enum fw_params_param_dev_diag {
 	FW_PARAM_DEV_DIAG_TMP		= 0x00,
 	FW_PARAM_DEV_DIAG_VDD		= 0x01,
-- 
2.3.4
