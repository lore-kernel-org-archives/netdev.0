From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Fix FW flash logic using ethtool
Date: Wed, 15 Oct 2014 01:54:14 +0530
Message-ID: <1413318254-23813-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43615
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755538AbaJNUSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 16:18:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use t4_fw_upgrade instead of t4_load_fw to write firmware into FLASH, since
t4_load_fw doesn't co-ordinate with the firmware and the adapter can get hosed
enough to require a power cycle of the system.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    2 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   14 ++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |    6 ++----
 3 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 9b2c669..38d8234 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -986,6 +986,8 @@ static inline int t4_memory_write(struct adapter *adap, int mtype, u32 addr,
 int t4_seeprom_wp(struct adapter *adapter, bool enable);
 int get_vpd_params(struct adapter *adapter, struct vpd_params *p);
 int t4_load_fw(struct adapter *adapter, const u8 *fw_data, unsigned int size);
+int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
+		  const u8 *fw_data, unsigned int size, int force);
 unsigned int t4_flash_cfg_addr(struct adapter *adapter);
 int t4_get_fw_version(struct adapter *adapter, u32 *vers);
 int t4_get_tp_version(struct adapter *adapter, u32 *vers);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 321f3d9..54a135d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2929,16 +2929,26 @@ static int set_flash(struct net_device *netdev, struct ethtool_flash *ef)
 	int ret;
 	const struct firmware *fw;
 	struct adapter *adap = netdev2adap(netdev);
+	unsigned int mbox = FW_PCIE_FW_MASTER_MASK + 1;
 
 	ef->data[sizeof(ef->data) - 1] = '\0';
 	ret = request_firmware(&fw, ef->data, adap->pdev_dev);
 	if (ret < 0)
 		return ret;
 
-	ret = t4_load_fw(adap, fw->data, fw->size);
+	/* If the adapter has been fully initialized then we'll go ahead and
+	 * try to get the firmware's cooperation in upgrading to the new
+	 * firmware image otherwise we'll try to do the entire job from the
+	 * host ... and we always "force" the operation in this path.
+	 */
+	if (adap->flags & FULL_INIT_DONE)
+		mbox = adap->mbox;
+
+	ret = t4_fw_upgrade(adap, mbox, fw->data, fw->size, 1);
 	release_firmware(fw);
 	if (!ret)
-		dev_info(adap->pdev_dev, "loaded firmware %s\n", ef->data);
+		dev_info(adap->pdev_dev, "loaded firmware %s,"
+			 " reload cxgb4 driver\n", ef->data);
 	return ret;
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 22d7581..b659b94 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -37,8 +37,6 @@
 #include "t4_regs.h"
 #include "t4fw_api.h"
 
-static int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
-			 const u8 *fw_data, unsigned int size, int force);
 /**
  *	t4_wait_op_done_val - wait until an operation is completed
  *	@adapter: the adapter performing the operation
@@ -3076,8 +3074,8 @@ static int t4_fw_restart(struct adapter *adap, unsigned int mbox, int reset)
  *	positive errno indicates that the adapter is ~probably~ intact, a
  *	negative errno indicates that things are looking bad ...
  */
-static int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
-			 const u8 *fw_data, unsigned int size, int force)
+int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
+		  const u8 *fw_data, unsigned int size, int force)
 {
 	const struct fw_hdr *fw_hdr = (const struct fw_hdr *)fw_data;
 	int reset, ret;
-- 
1.7.1
