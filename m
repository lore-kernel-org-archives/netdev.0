From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Force uninitialized state if FW in adapter is unsupported
Date: Fri, 28 Aug 2015 11:17:12 +0530
Message-ID: <1440740832-11958-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4914 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750750AbbH1FrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:47:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forcing uninitialized state allows us to upgrade and reinitialize
the adapter.

    FW_VERSION_T4 = 1.4.0.0
    FW_VERSION_T5 = 0.0.0.0
    FW_VERSION_T6 = 0.0.0.0
At this point driver supports above and greater than above version.

If FW in adapter < min FW_VERSION driver supports tries to upgrade the FW
If FW in adapter >= FW_VERSION driver supports then it follows normal path

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h        |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c   |  4 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c        | 56 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h | 11 +++++
 4 files changed, 72 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 3c99454..fa0c7b5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1289,6 +1289,7 @@ int t4_fwcache(struct adapter *adap, enum fw_params_param_dev_fwcache op);
 int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
 		  const u8 *fw_data, unsigned int size, int force);
 unsigned int t4_flash_cfg_addr(struct adapter *adapter);
+int t4_check_fw_version(struct adapter *adap);
 int t4_get_fw_version(struct adapter *adapter, u32 *vers);
 int t4_get_tp_version(struct adapter *adapter, u32 *vers);
 int t4_get_exprom_version(struct adapter *adapter, u32 *vers);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f35dd22..eb22d58 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3668,6 +3668,10 @@ static int adap_init0(struct adapter *adap)
 	 */
 	t4_get_fw_version(adap, &adap->params.fw_vers);
 	t4_get_tp_version(adap, &adap->params.tp_vers);
+	ret = t4_check_fw_version(adap);
+	/* If firmware is too old (not supported by driver) force an update. */
+	if (ret == -EFAULT)
+		state = DEV_STATE_UNINIT;
 	if ((adap->flags & MASTER_PF) && state != DEV_STATE_INIT) {
 		struct fw_info *fw_info;
 		struct fw_hdr *card_fw;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index ac368ef..4480625 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -37,6 +37,7 @@
 #include "t4_regs.h"
 #include "t4_values.h"
 #include "t4fw_api.h"
+#include "t4fw_version.h"
 
 /**
  *	t4_wait_op_done_val - wait until an operation is completed
@@ -2166,6 +2167,61 @@ int t4_get_exprom_version(struct adapter *adap, u32 *vers)
 	return 0;
 }
 
+/**
+ *	t4_check_fw_version - check if the FW is supported with this driver
+ *	@adap: the adapter
+ *
+ *	Checks if an adapter's FW is compatible with the driver.  Returns 0
+ *	if there's exact match, a negative error if the version could not be
+ *	read or there's a major version mismatch
+ */
+int t4_check_fw_version(struct adapter *adap)
+{
+	int ret, major, minor, micro;
+	int exp_major, exp_minor, exp_micro;
+	unsigned int chip_version = CHELSIO_CHIP_VERSION(adap->params.chip);
+
+	ret = t4_get_fw_version(adap, &adap->params.fw_vers);
+	if (ret)
+		return ret;
+
+	major = FW_HDR_FW_VER_MAJOR_G(adap->params.fw_vers);
+	minor = FW_HDR_FW_VER_MINOR_G(adap->params.fw_vers);
+	micro = FW_HDR_FW_VER_MICRO_G(adap->params.fw_vers);
+
+	switch (chip_version) {
+	case CHELSIO_T4:
+		exp_major = T4FW_MIN_VERSION_MAJOR;
+		exp_minor = T4FW_MIN_VERSION_MINOR;
+		exp_micro = T4FW_MIN_VERSION_MICRO;
+		break;
+	case CHELSIO_T5:
+		exp_major = T5FW_MIN_VERSION_MAJOR;
+		exp_minor = T5FW_MIN_VERSION_MINOR;
+		exp_micro = T5FW_MIN_VERSION_MICRO;
+		break;
+	case CHELSIO_T6:
+		exp_major = T6FW_MIN_VERSION_MAJOR;
+		exp_minor = T6FW_MIN_VERSION_MINOR;
+		exp_micro = T6FW_MIN_VERSION_MICRO;
+		break;
+	default:
+		dev_err(adap->pdev_dev, "Unsupported chip type, %x\n",
+			adap->chip);
+		return -EINVAL;
+	}
+
+	if (major < exp_major || (major == exp_major && minor < exp_minor) ||
+	    (major == exp_major && minor == exp_minor && micro < exp_micro)) {
+		dev_err(adap->pdev_dev,
+			"Card has firmware version %u.%u.%u, minimum "
+			"supported firmware is %u.%u.%u.\n", major, minor,
+			micro, exp_major, exp_minor, exp_micro);
+		return -EFAULT;
+	}
+	return 0;
+}
+
 /* Is the given firmware API compatible with the one the driver was compiled
  * with?
  */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
index 32b2135..92bafa7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
@@ -40,14 +40,25 @@
 #define T4FW_VERSION_MICRO 0x20
 #define T4FW_VERSION_BUILD 0x00
 
+#define T4FW_MIN_VERSION_MAJOR 0x01
+#define T4FW_MIN_VERSION_MINOR 0x04
+#define T4FW_MIN_VERSION_MICRO 0x00
+
 #define T5FW_VERSION_MAJOR 0x01
 #define T5FW_VERSION_MINOR 0x0D
 #define T5FW_VERSION_MICRO 0x20
 #define T5FW_VERSION_BUILD 0x00
 
+#define T5FW_MIN_VERSION_MAJOR 0x00
+#define T5FW_MIN_VERSION_MINOR 0x00
+#define T5FW_MIN_VERSION_MICRO 0x00
+
 #define T6FW_VERSION_MAJOR 0x01
 #define T6FW_VERSION_MINOR 0x0D
 #define T6FW_VERSION_MICRO 0x2D
 #define T6FW_VERSION_BUILD 0x00
 
+#define T6FW_MIN_VERSION_MAJOR 0x00
+#define T6FW_MIN_VERSION_MINOR 0x00
+#define T6FW_MIN_VERSION_MICRO 0x00
 #endif
-- 
2.3.4
