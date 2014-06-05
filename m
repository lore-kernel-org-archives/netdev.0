From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/13] i40e: refactor send version
Date: Thu,  5 Jun 2014 03:12:58 -0700
Message-ID: <1401963181-11110-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401963181-11110-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19636 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbaFEKNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 06:13:07 -0400
In-Reply-To: <1401963181-11110-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This change moves some common code in two places into a
small helper function, and corrects a bug in one of the
two places in the process.

Change-ID: If3bba7152b240f13a7881eb0e8a781655fa66ce7
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 31 +++++++++++++++++------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0f9ccc7..1954e19 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5351,13 +5351,28 @@ static int i40e_prep_for_reset(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_send_version - update firmware with driver version
+ * @pf: PF struct
+ */
+static void i40e_send_version(struct i40e_pf *pf)
+{
+	struct i40e_driver_version dv;
+
+	dv.major_version = DRV_VERSION_MAJOR;
+	dv.minor_version = DRV_VERSION_MINOR;
+	dv.build_version = DRV_VERSION_BUILD;
+	dv.subbuild_version = 0;
+	strncpy(dv.driver_string, DRV_VERSION, sizeof(dv.driver_string));
+	i40e_aq_send_driver_version(&pf->hw, &dv, NULL);
+}
+
+/**
  * i40e_reset_and_rebuild - reset and rebuild using a saved config
  * @pf: board private structure
  * @reinit: if the Main VSI needs to re-initialized.
  **/
 static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 {
-	struct i40e_driver_version dv;
 	struct i40e_hw *hw = &pf->hw;
 	i40e_status ret;
 	u32 v;
@@ -5490,11 +5505,7 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	}
 
 	/* tell the firmware that we're starting */
-	dv.major_version = DRV_VERSION_MAJOR;
-	dv.minor_version = DRV_VERSION_MINOR;
-	dv.build_version = DRV_VERSION_BUILD;
-	dv.subbuild_version = 0;
-	i40e_aq_send_driver_version(&pf->hw, &dv, NULL);
+	i40e_send_version(pf);
 
 	dev_info(&pf->pdev->dev, "reset complete\n");
 
@@ -8138,7 +8149,6 @@ static void i40e_print_features(struct i40e_pf *pf)
  **/
 static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-	struct i40e_driver_version dv;
 	struct i40e_pf *pf;
 	struct i40e_hw *hw;
 	static u16 pfs_found;
@@ -8393,12 +8403,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	i40e_dbg_pf_init(pf);
 
 	/* tell the firmware that we're starting */
-	dv.major_version = DRV_VERSION_MAJOR;
-	dv.minor_version = DRV_VERSION_MINOR;
-	dv.build_version = DRV_VERSION_BUILD;
-	dv.subbuild_version = 0;
-	strncpy(dv.driver_string, DRV_VERSION, sizeof(dv.driver_string));
-	i40e_aq_send_driver_version(&pf->hw, &dv, NULL);
+	i40e_send_version(pf);
 
 	/* since everything's happy, start the service_task timer */
 	mod_timer(&pf->service_timer,
-- 
1.9.3
