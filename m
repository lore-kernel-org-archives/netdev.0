From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40e: dump VF information in debugfs
Date: Wed, 19 Apr 2017 18:57:40 -0700
Message-ID: <20170420015750.6828-5-jeffrey.t.kirsher@intel.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:29694 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939037AbdDTB54 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 21:57:56 -0400
In-Reply-To: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Dump some internal state about VFs through debugfs. This provides
information not available with 'ip link show'. To use, write "dump vf
<id>" to the command file, or just "dump vf" to dump information on all
of the VFs.

Change-ID: Ibe32b7f4ae55d4358c0b903217475f708ada1ecd
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 51 ++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index c5f68cc1edcd..a3d7ec62b76c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -384,6 +384,8 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 		 "    base_queue = %d, num_queue_pairs = %d, num_desc = %d\n",
 		 vsi->base_queue, vsi->num_queue_pairs, vsi->num_desc);
 	dev_info(&pf->pdev->dev, "    type = %i\n", vsi->type);
+	if (vsi->type == I40E_VSI_SRIOV)
+		dev_info(&pf->pdev->dev, "    VF ID = %i\n", vsi->vf_id);
 	dev_info(&pf->pdev->dev,
 		 "    info: valid_sections = 0x%04x, switch_id = 0x%04x\n",
 		 vsi->info.valid_sections, vsi->info.switch_id);
@@ -694,6 +696,47 @@ static void i40e_dbg_dump_veb_all(struct i40e_pf *pf)
 	}
 }
 
+/**
+ * i40e_dbg_dump_vf - dump VF info
+ * @pf: the i40e_pf created in command write
+ * @vf_id: the vf_id from the user
+ **/
+static void i40e_dbg_dump_vf(struct i40e_pf *pf, int vf_id)
+{
+	struct i40e_vf *vf;
+	struct i40e_vsi *vsi;
+
+	if (!pf->num_alloc_vfs) {
+		dev_info(&pf->pdev->dev, "no VFs allocated\n");
+	} else if ((vf_id >= 0) && (vf_id < pf->num_alloc_vfs)) {
+		vf = &pf->vf[vf_id];
+		vsi = pf->vsi[vf->lan_vsi_idx];
+		dev_info(&pf->pdev->dev, "vf %2d: VSI id=%d, seid=%d, qps=%d\n",
+			 vf_id, vf->lan_vsi_id, vsi->seid, vf->num_queue_pairs);
+		dev_info(&pf->pdev->dev, "       num MDD=%lld, invalid msg=%lld, valid msg=%lld\n",
+			 vf->num_mdd_events,
+			 vf->num_invalid_msgs,
+			 vf->num_valid_msgs);
+	} else {
+		dev_info(&pf->pdev->dev, "invalid VF id %d\n", vf_id);
+	}
+}
+
+/**
+ * i40e_dbg_dump_vf_all - dump VF info for all VFs
+ * @pf: the i40e_pf created in command write
+ **/
+static void i40e_dbg_dump_vf_all(struct i40e_pf *pf)
+{
+	int i;
+
+	if (!pf->num_alloc_vfs)
+		dev_info(&pf->pdev->dev, "no VFs enabled!\n");
+	else
+		for (i = 0; i < pf->num_alloc_vfs; i++)
+			i40e_dbg_dump_vf(pf, i);
+}
+
 #define I40E_MAX_DEBUG_OUT_BUFFER (4096*4)
 /**
  * i40e_dbg_command_write - write into command datum
@@ -712,6 +755,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 	struct i40e_vsi *vsi;
 	int vsi_seid;
 	int veb_seid;
+	int vf_id;
 	int cnt;
 
 	/* don't allow partial writes */
@@ -914,6 +958,12 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				i40e_dbg_dump_veb_seid(pf, vsi_seid);
 			else
 				i40e_dbg_dump_veb_all(pf);
+		} else if (strncmp(&cmd_buf[5], "vf", 2) == 0) {
+			cnt = sscanf(&cmd_buf[7], "%i", &vf_id);
+			if (cnt > 0)
+				i40e_dbg_dump_vf(pf, vf_id);
+			else
+				i40e_dbg_dump_vf_all(pf);
 		} else if (strncmp(&cmd_buf[5], "desc", 4) == 0) {
 			int ring_id, desc_n;
 			if (strncmp(&cmd_buf[10], "rx", 2) == 0) {
@@ -1109,6 +1159,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			dev_info(&pf->pdev->dev, "dump vsi [seid]\n");
 			dev_info(&pf->pdev->dev, "dump reset stats\n");
 			dev_info(&pf->pdev->dev, "dump port\n");
+			dev_info(&pf->pdev->dev, "dump vf [vf_id]\n");
 			dev_info(&pf->pdev->dev,
 				 "dump debug fwdata <cluster_id> <table_id> <index>\n");
 		}
-- 
2.12.2
