From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH v2 net-next 3/4] bnx2x: Add BD support for storage
Date: Tue, 4 Aug 2015 09:37:29 +0300
Message-ID: <1438670250-20130-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1438670250-20130-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <James.bottomley@HansenPartnership.com>,
	<linux-scsi-owner@vger.kernel.org>, <chad.dupuis@qlogic.com>,
	<Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:12583 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754157AbbHDGhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 02:37:54 -0400
In-Reply-To: <1438670250-20130-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 230d00eb4bfe ("bnx2x: new Multi-function mode - BD") adds support
for the new mode in bnx2x. This expands this support by implementing
APIs required by our storage drivers to support that mode.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    | 12 +++
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h    | 19 +++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   | 85 ++++++++++++++++++++++
 4 files changed, 118 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index fa7c532..e18a0e4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1386,4 +1386,16 @@ void bnx2x_schedule_sp_rtnl(struct bnx2x*, enum sp_rtnl_flag,
  * @state:	OS_DRIVER_STATE_* value reflecting current driver state
  */
 void bnx2x_set_os_driver_state(struct bnx2x *bp, u32 state);
+
+/**
+ * bnx2x_nvram_read - reads data from nvram [might sleep]
+ *
+ * @bp:		driver handle
+ * @offset:	byte offset in nvram
+ * @ret_buf:	pointer to buffer where data is to be stored
+ * @buf_size:   Length of 'ret_buf' in bytes
+ */
+int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
+		     int buf_size);
+
 #endif /* BNX2X_CMN_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 6b2050a..6f90907 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1348,8 +1348,8 @@ static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, __be32 *ret_val,
 	return rc;
 }
 
-static int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
-			    int buf_size)
+int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
+		     int buf_size)
 {
 	int rc;
 	u32 cmd_flags;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 08a08fa..cafd5de 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -2075,6 +2075,25 @@ enum curr_cfg_method_e {
 	CURR_CFG_MET_VENDOR_SPEC = 2,/* e.g. Option ROM, NPAR, O/S Cfg Utils */
 };
 
+#define FC_NPIV_WWPN_SIZE 8
+#define FC_NPIV_WWNN_SIZE 8
+struct bdn_npiv_settings {
+	u8 npiv_wwpn[FC_NPIV_WWPN_SIZE];
+	u8 npiv_wwnn[FC_NPIV_WWNN_SIZE];
+};
+
+struct bdn_fc_npiv_cfg {
+	/* hdr used internally by the MFW */
+	u32 hdr;
+	u32 num_of_npiv;
+};
+
+#define MAX_NUMBER_NPIV 64
+struct bdn_fc_npiv_tbl {
+	struct bdn_fc_npiv_cfg fc_npiv_cfg;
+	struct bdn_npiv_settings settings[MAX_NUMBER_NPIV];
+};
+
 struct mdump_driver_info {
 	u32 epoc;
 	u32 drv_ver;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 31c63aa..ad73a60 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -14653,6 +14653,90 @@ static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
 		rc = -EINVAL;
 	}
 
+	/* For storage-only interfaces, change driver state */
+	if (IS_MF_SD_STORAGE_PERSONALITY_ONLY(bp)) {
+		switch (ctl->drv_state) {
+		case DRV_NOP:
+			break;
+		case DRV_ACTIVE:
+			bnx2x_set_os_driver_state(bp,
+						  OS_DRIVER_STATE_ACTIVE);
+			break;
+		case DRV_INACTIVE:
+			bnx2x_set_os_driver_state(bp,
+						  OS_DRIVER_STATE_DISABLED);
+			break;
+		case DRV_UNLOADED:
+			bnx2x_set_os_driver_state(bp,
+						  OS_DRIVER_STATE_NOT_LOADED);
+			break;
+		default:
+		BNX2X_ERR("Unknown cnic driver state: %d\n", ctl->drv_state);
+		}
+	}
+
+	return rc;
+}
+
+static int bnx2x_get_fc_npiv(struct net_device *dev,
+			     struct cnic_fc_npiv_tbl *cnic_tbl)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	struct bdn_fc_npiv_tbl *tbl = NULL;
+	u32 offset, entries;
+	int rc = -EINVAL;
+	int i;
+
+	if (!SHMEM2_HAS(bp, fc_npiv_nvram_tbl_addr[0]))
+		goto out;
+
+	DP(BNX2X_MSG_MCP, "About to read the FC-NPIV table\n");
+
+	tbl = kmalloc(sizeof(*tbl), GFP_KERNEL);
+	if (!tbl) {
+		BNX2X_ERR("Failed to allocate fc_npiv table\n");
+		goto out;
+	}
+
+	offset = SHMEM2_RD(bp, fc_npiv_nvram_tbl_addr[BP_PORT(bp)]);
+	DP(BNX2X_MSG_MCP, "Offset of FC-NPIV in NVRAM: %08x\n", offset);
+
+	/* Read the table contents from nvram */
+	if (bnx2x_nvram_read(bp, offset, (u8 *)tbl, sizeof(*tbl))) {
+		BNX2X_ERR("Failed to read FC-NPIV table\n");
+		goto out;
+	}
+
+	/* Since bnx2x_nvram_read() returns data in be32, we need to convert
+	 * the number of entries back to cpu endianness.
+	 */
+	entries = tbl->fc_npiv_cfg.num_of_npiv;
+	entries = (__force u32)be32_to_cpu((__force __be32)entries);
+	tbl->fc_npiv_cfg.num_of_npiv = entries;
+
+	if (!tbl->fc_npiv_cfg.num_of_npiv) {
+		DP(BNX2X_MSG_MCP,
+		   "No FC-NPIV table [valid, simply not present]\n");
+		goto out;
+	} else if (tbl->fc_npiv_cfg.num_of_npiv > MAX_NUMBER_NPIV) {
+		BNX2X_ERR("FC-NPIV table with bad length 0x%08x\n",
+			  tbl->fc_npiv_cfg.num_of_npiv);
+		goto out;
+	} else {
+		DP(BNX2X_MSG_MCP, "Read 0x%08x entries from NVRAM\n",
+		   tbl->fc_npiv_cfg.num_of_npiv);
+	}
+
+	/* Copy the data into cnic-provided struct */
+	cnic_tbl->count = tbl->fc_npiv_cfg.num_of_npiv;
+	for (i = 0; i < cnic_tbl->count; i++) {
+		memcpy(cnic_tbl->wwpn[i], tbl->settings[i].npiv_wwpn, 8);
+		memcpy(cnic_tbl->wwnn[i], tbl->settings[i].npiv_wwnn, 8);
+	}
+
+	rc = 0;
+out:
+	kfree(tbl);
 	return rc;
 }
 
@@ -14798,6 +14882,7 @@ static struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
 	cp->starting_cid = bnx2x_cid_ilt_lines(bp) * ILT_PAGE_CIDS;
 	cp->drv_submit_kwqes_16 = bnx2x_cnic_sp_queue;
 	cp->drv_ctl = bnx2x_drv_ctl;
+	cp->drv_get_fc_npiv_tbl = bnx2x_get_fc_npiv;
 	cp->drv_register_cnic = bnx2x_register_cnic;
 	cp->drv_unregister_cnic = bnx2x_unregister_cnic;
 	cp->fcoe_init_cid = BNX2X_FCOE_ETH_CID(bp);
-- 
1.9.3
