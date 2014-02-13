From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 09/15] i40e: enable extant VFs
Date: Thu, 13 Feb 2014 03:48:47 -0800
Message-ID: <1392292133-32120-10-git-send-email-aaron.f.brown@intel.com>
References: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56830 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754326AbaBMLvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:51:13 -0500
In-Reply-To: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If VFs are present when the driver loads, then set up some resources
so they can function.

Change-ID: I485916a811609a9990ce663d06dc645f625b07ff
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 10 ++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 18 ++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  1 +
 3 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 21d46f4..897452d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8076,6 +8076,16 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		val &= ~I40E_PFGEN_PORTMDIO_NUM_VFLINK_STAT_ENA_MASK;
 		wr32(hw, I40E_PFGEN_PORTMDIO_NUM, val);
 		i40e_flush(hw);
+
+		if (pci_num_vf(pdev)) {
+			dev_info(&pdev->dev,
+				 "Active VFs found, allocating resources.\n");
+			err = i40e_alloc_vfs(pf, pci_num_vf(pdev));
+			if (err)
+				dev_info(&pdev->dev,
+					 "Error %d allocating resources for existing VFs\n",
+					 err);
+		}
 	}
 
 	pfs_found++;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 052be06..9074f63 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -840,7 +840,7 @@ void i40e_free_vfs(struct i40e_pf *pf)
  *
  * allocate vf resources
  **/
-static int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
+int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 {
 	struct i40e_vf *vfs;
 	int i, ret = 0;
@@ -848,14 +848,16 @@ static int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 	/* Disable interrupt 0 so we don't try to handle the VFLR. */
 	i40e_irq_dynamic_disable_icr0(pf);
 
-	ret = pci_enable_sriov(pf->pdev, num_alloc_vfs);
-	if (ret) {
-		dev_err(&pf->pdev->dev,
-			"pci_enable_sriov failed with error %d!\n", ret);
-		pf->num_alloc_vfs = 0;
-		goto err_iov;
+	/* Check to see if we're just allocating resources for extant VFs */
+	if (pci_num_vf(pf->pdev) != num_alloc_vfs) {
+		ret = pci_enable_sriov(pf->pdev, num_alloc_vfs);
+		if (ret) {
+			dev_err(&pf->pdev->dev,
+				"Failed to enable SR-IOV, error %d.\n", ret);
+			pf->num_alloc_vfs = 0;
+			goto err_iov;
+		}
 	}
-
 	/* allocate memory */
 	vfs = kzalloc(num_alloc_vfs * sizeof(struct i40e_vf), GFP_KERNEL);
 	if (!vfs) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index cc1feee..bedf0ba 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -102,6 +102,7 @@ struct i40e_vf {
 
 void i40e_free_vfs(struct i40e_pf *pf);
 int i40e_pci_sriov_configure(struct pci_dev *dev, int num_vfs);
+int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs);
 int i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id, u32 v_opcode,
 			   u32 v_retval, u8 *msg, u16 msglen);
 int i40e_vc_process_vflr_event(struct i40e_pf *pf);
-- 
1.8.5.GIT
