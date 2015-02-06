From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 1/5] cxgb4: Add support in debugfs to display sensor information
Date: Fri,  6 Feb 2015 19:32:51 +0530
Message-ID: <1423231375-28004-2-git-send-email-hariprasad@chelsio.com>
References: <1423231375-28004-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26401 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752535AbbBFN5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:57:21 -0500
In-Reply-To: <1423231375-28004-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump out various chip sensor information. Currently Chip Temperature
and Core Voltage.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   36 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |    6 +++
 2 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 61c000a..35ec230 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -813,6 +813,41 @@ static const struct file_operations mps_tcam_debugfs_fops = {
 	.release = seq_release,
 };
 
+/* Display various sensor information.
+ */
+static int sensors_show(struct seq_file *seq, void *v)
+{
+	struct adapter *adap = seq->private;
+	u32 param[7], val[7];
+	int ret;
+
+	/* Note that if the sensors haven't been initialized and turned on
+	 * we'll get values of 0, so treat those as "<unknown>" ...
+	 */
+	param[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+		    FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_DIAG) |
+		    FW_PARAMS_PARAM_Y_V(FW_PARAM_DEV_DIAG_TMP));
+	param[1] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+		    FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_DIAG) |
+		    FW_PARAMS_PARAM_Y_V(FW_PARAM_DEV_DIAG_VDD));
+	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2,
+			      param, val);
+
+	if (ret < 0 || val[0] == 0)
+		seq_puts(seq, "Temperature: <unknown>\n");
+	else
+		seq_printf(seq, "Temperature: %dC\n", val[0]);
+
+	if (ret < 0 || val[1] == 0)
+		seq_puts(seq, "Core VDD:    <unknown>\n");
+	else
+		seq_printf(seq, "Core VDD:    %dmV\n", val[1]);
+
+	return 0;
+}
+
+DEFINE_SIMPLE_DEBUGFS_FILE(sensors);
+
 #if IS_ENABLED(CONFIG_IPV6)
 static int clip_tbl_open(struct inode *inode, struct file *file)
 {
@@ -1584,6 +1619,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "obq_ulp3", &cim_obq_fops, S_IRUSR, 3 },
 		{ "obq_sge",  &cim_obq_fops, S_IRUSR, 4 },
 		{ "obq_ncsi", &cim_obq_fops, S_IRUSR, 5 },
+		{ "sensors", &sensors_debugfs_fops, S_IRUSR, 0 },
 		{ "pm_stats", &pm_stats_debugfs_fops, S_IRUSR, 0 },
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index c009627..9b353a8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1059,6 +1059,7 @@ enum fw_params_param_dev {
 	FW_PARAMS_PARAM_DEV_FWREV = 0x0B,
 	FW_PARAMS_PARAM_DEV_TPREV = 0x0C,
 	FW_PARAMS_PARAM_DEV_CF = 0x0D,
+	FW_PARAMS_PARAM_DEV_DIAG = 0x11,
 	FW_PARAMS_PARAM_DEV_MAXORDIRD_QP = 0x13, /* max supported QP IRD/ORD */
 	FW_PARAMS_PARAM_DEV_MAXIRD_ADAPTER = 0x14, /* max supported adap IRD */
 	FW_PARAMS_PARAM_DEV_ULPTX_MEMWRITE_DSGL = 0x17,
@@ -1122,6 +1123,11 @@ enum fw_params_param_dmaq {
 	FW_PARAMS_PARAM_DMAQ_EQ_DCBPRIO_ETH = 0x13,
 };
 
+enum fw_params_param_dev_diag {
+	FW_PARAM_DEV_DIAG_TMP		= 0x00,
+	FW_PARAM_DEV_DIAG_VDD		= 0x01,
+};
+
 enum fw_params_param_dev_fwcache {
 	FW_PARAM_DEV_FWCACHE_FLUSH      = 0x00,
 	FW_PARAM_DEV_FWCACHE_FLUSHINV   = 0x01,
-- 
1.7.1
