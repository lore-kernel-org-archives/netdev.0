From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next] cxgb4: Force uninitialized state if FW_ON_ADAPTER is < FW_VERSION and we're the MASTER_PF
Date: Thu, 30 May 2013 18:54:14 +0530
Message-ID: <1369920254-12122-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	vipul@chelsio.com, Jay Hernandez <jay@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14050 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755085Ab3E3Nak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 09:30:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Hernandez <jay@chelsio.com>

Forcing uninitialized state allows us to upgrade and reinitialize the adapter.

FW_VERSION_T4 = 1.4.0.0
FW_VERSION_T5 = 0.0.0.0
At this point driver supports above and greater than above version of firmware.
If it doesn't find the required firmware version than it forces the adapter to
be reinitialized as shown below.

1) If FW_ON_ADAPTER < FW_VERSION and we're the MASTER_PF force uninitialized
   state and a FW upgrade if available.

       - If FW_ON_ADAPTER < /lib/firmware/cxgb4/t*fw.bin we will update the
         adapters FW.
       - If FW_ON_ADAPTER >= /lib/firmware/cxgb4/t*fw.bin don't upgrade FW.
       - If upgrade_fw() fails force reinitialization of the adapter anyways,
         it might still work.

   Either way forcing the uninitialized state allows cxgb4 reinitialize FW.

2) If FW_ON_ADAPTER >= FW_VERSION driver follows normal path.

Signed-off-by: Jay Hernandez <jay@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 27 +++++++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  9 +++++++++
 3 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 681804b..2aafb80 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -51,7 +51,7 @@
 #include "t4_hw.h"
 
 #define FW_VERSION_MAJOR 1
-#define FW_VERSION_MINOR 1
+#define FW_VERSION_MINOR 4
 #define FW_VERSION_MICRO 0
 
 #define FW_VERSION_MAJOR_T5 0
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 3cd397d..5a3256b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4842,8 +4842,17 @@ static int adap_init0(struct adapter *adap)
 	 * is excessively mismatched relative to the driver.)
 	 */
 	ret = t4_check_fw_version(adap);
+
+	/* The error code -EFAULT is returned by t4_check_fw_version() if
+	 * firmware on adapter < supported firmware. If firmware on adapter
+	 * is too old (not supported by driver) and we're the MASTER_PF set
+	 * adapter state to DEV_STATE_UNINIT to force firmware upgrade
+	 * and reinitialization.
+	 */
+	if ((adap->flags & MASTER_PF) && ret == -EFAULT)
+		state = DEV_STATE_UNINIT;
 	if ((adap->flags & MASTER_PF) && state != DEV_STATE_INIT) {
-		if (ret == -EINVAL || ret > 0) {
+		if (ret == -EINVAL || ret == -EFAULT || ret > 0) {
 			if (upgrade_fw(adap) >= 0) {
 				/*
 				 * Note that the chip was reset as part of the
@@ -4852,7 +4861,21 @@ static int adap_init0(struct adapter *adap)
 				 */
 				reset = 0;
 				ret = t4_check_fw_version(adap);
-			}
+			} else
+				if (ret == -EFAULT) {
+					/*
+					 * Firmware is old but still might
+					 * work if we force reinitialization
+					 * of the adapter. Ignoring FW upgrade
+					 * failure.
+					 */
+					dev_warn(adap->pdev_dev,
+						 "Ignoring firmware upgrade "
+						 "failure, and forcing driver "
+						 "to reinitialize the "
+						 "adapter.\n");
+					ret = 0;
+				}
 		}
 		if (ret < 0)
 			return ret;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index d02d4e8..bff89a4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -938,6 +938,15 @@ int t4_check_fw_version(struct adapter *adapter)
 	memcpy(adapter->params.api_vers, api_vers,
 	       sizeof(adapter->params.api_vers));
 
+	if (major < exp_major || (major == exp_major && minor < exp_minor) ||
+	    (major == exp_major && minor == exp_minor && micro < exp_micro)) {
+		dev_err(adapter->pdev_dev,
+			"Card has firmware version %u.%u.%u, minimum "
+			"supported firmware is %u.%u.%u.\n", major, minor,
+			micro, exp_major, exp_minor, exp_micro);
+		return -EFAULT;
+	}
+
 	if (major != exp_major) {            /* major mismatch - fail */
 		dev_err(adapter->pdev_dev,
 			"card FW has major version %u, driver wants %u\n",
-- 
1.8.0
