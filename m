From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/16] i40e: rework fdir setup and teardown
Date: Tue, 22 Apr 2014 05:39:28 -0700
Message-ID: <1398170371-3333-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27100 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932616AbaDVMjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:43 -0400
In-Reply-To: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Use the newer i40e_vsi_open() and i40e_vsi_close() in the FDIR VSI
lifetime.  This makes sure we're using standard methods for all the
VSI open and close paths.  This also fixes a memory leak of the
FDIR queue buffer info structs across a reset.

Change-ID: I1b60a1b08ab923afe4f49810c2c7844d850e19b9
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 57 +++++++++--------------------
 1 file changed, 17 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7bbecf8..8392796 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4335,6 +4335,11 @@ int i40e_vsi_open(struct i40e_vsi *vsi)
 						   vsi->num_queue_pairs);
 		if (err)
 			goto err_set_queues;
+
+	} else if (vsi->type == I40E_VSI_FDIR) {
+		snprintf(int_name, sizeof(int_name) - 1, "%s-fdir",
+			 dev_driver_string(&pf->pdev->dev));
+		err = i40e_vsi_request_irq(vsi, int_name);
 	} else {
 		err = EINVAL;
 		goto err_setup_rx;
@@ -5269,8 +5274,7 @@ static int i40e_vsi_clear(struct i40e_vsi *vsi);
 static void i40e_fdir_sb_setup(struct i40e_pf *pf)
 {
 	struct i40e_vsi *vsi;
-	bool new_vsi = false;
-	int err, i;
+	int i;
 
 	if (!(pf->flags & I40E_FLAG_FD_SB_ENABLED))
 		return;
@@ -5290,47 +5294,12 @@ static void i40e_fdir_sb_setup(struct i40e_pf *pf)
 				     pf->vsi[pf->lan_vsi]->seid, 0);
 		if (!vsi) {
 			dev_info(&pf->pdev->dev, "Couldn't create FDir VSI\n");
-			goto err_vsi;
+			pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
+			return;
 		}
-		new_vsi = true;
 	}
-	i40e_vsi_setup_irqhandler(vsi, i40e_fdir_clean_ring);
-
-	err = i40e_vsi_setup_tx_resources(vsi);
-	if (err)
-		goto err_setup_tx;
-	err = i40e_vsi_setup_rx_resources(vsi);
-	if (err)
-		goto err_setup_rx;
 
-	if (new_vsi) {
-		char int_name[IFNAMSIZ + 9];
-		err = i40e_vsi_configure(vsi);
-		if (err)
-			goto err_setup_rx;
-		snprintf(int_name, sizeof(int_name) - 1, "%s-fdir",
-			 dev_driver_string(&pf->pdev->dev));
-		err = i40e_vsi_request_irq(vsi, int_name);
-		if (err)
-			goto err_setup_rx;
-		err = i40e_up_complete(vsi);
-		if (err)
-			goto err_up_complete;
-		clear_bit(__I40E_NEEDS_RESTART, &vsi->state);
-	}
-
-	return;
-
-err_up_complete:
-	i40e_down(vsi);
-	i40e_vsi_free_irq(vsi);
-err_setup_rx:
-	i40e_vsi_free_rx_resources(vsi);
-err_setup_tx:
-	i40e_vsi_free_tx_resources(vsi);
-err_vsi:
-	pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
-	i40e_vsi_clear(vsi);
+	i40e_vsi_setup_irqhandler(vsi, i40e_fdir_clean_ring);
 }
 
 /**
@@ -8184,6 +8153,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u16 link_status;
 	int err = 0;
 	u32 len;
+	u32 i;
 
 	err = pci_enable_device_mem(pdev);
 	if (err)
@@ -8373,6 +8343,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_info(&pdev->dev, "setup_pf_switch failed: %d\n", err);
 		goto err_vsis;
 	}
+	/* if FDIR VSI was set up, start it now */
+	for (i = 0; i < pf->hw.func_caps.num_vsis; i++) {
+		if (pf->vsi[i] && pf->vsi[i]->type == I40E_VSI_FDIR) {
+			i40e_vsi_open(pf->vsi[i]);
+			break;
+		}
+	}
 
 	/* The main driver is (mostly) up and happy. We need to set this state
 	 * before setting up the misc vector or we get a race and the vector
-- 
1.9.0
