From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/16] i40e: Fix errors resulted while turning off TSO
Date: Tue, 28 Jun 2016 21:41:01 -0700
Message-ID: <1467175262-54719-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@oracle.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22102 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486AbcF2EnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:20 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@oracle.com>

On systems with 128 CPUs, turning off TSO results in errors,

i40e 0000:03:00.0: failed to get tracking for 1 vectors for VSI 400, err=-12
i40e 0000:03:00.0: Couldn't create FDir VSI
i40e 0000:03:00.0: i40e_ptp_init: PTP not supported on eth0
i40e 0000:03:00.0: couldn't add VEB, err I40E_ERR_ADMIN_QUEUE_ERROR aq_err I40E_AQ_RC_ENOENT
i40e 0000:03:00.0: rebuild of switch failed: -1, will try to set up simple PF connection
i40e 0000:03:00.0 eth0: adding 00:10:e0:8a:24:b6 vid=0

Enabling FD_SB without checking availability of MSI-X vector is the
root cause. This change adds necessary check.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 9c44739..e83fc8a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -283,6 +283,7 @@ struct i40e_pf {
 #endif /* I40E_FCOE */
 	u16 num_lan_qps;           /* num lan queues this PF has set up */
 	u16 num_lan_msix;          /* num queue vectors for the base PF vsi */
+	u16 num_fdsb_msix;         /* num queue vectors for sideband Fdir */
 	u16 num_iwarp_msix;        /* num of iwarp vectors for this PF */
 	int iwarp_base_vector;
 	int queues_left;           /* queues left unclaimed */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3e394bf..a313194 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7185,7 +7185,7 @@ static int i40e_set_num_rings_in_vsi(struct i40e_vsi *vsi)
 		vsi->alloc_queue_pairs = 1;
 		vsi->num_desc = ALIGN(I40E_FDIR_RING_COUNT,
 				      I40E_REQ_DESCRIPTOR_MULTIPLE);
-		vsi->num_q_vectors = 1;
+		vsi->num_q_vectors = pf->num_fdsb_msix;
 		break;
 
 	case I40E_VSI_VMDQ2:
@@ -7569,9 +7569,11 @@ static int i40e_init_msix(struct i40e_pf *pf)
 	/* reserve one vector for sideband flow director */
 	if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
 		if (vectors_left) {
+			pf->num_fdsb_msix = 1;
 			v_budget++;
 			vectors_left--;
 		} else {
+			pf->num_fdsb_msix = 0;
 			pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
 		}
 	}
@@ -8590,7 +8592,9 @@ bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features)
 		/* Enable filters and mark for reset */
 		if (!(pf->flags & I40E_FLAG_FD_SB_ENABLED))
 			need_reset = true;
-		pf->flags |= I40E_FLAG_FD_SB_ENABLED;
+		/* enable FD_SB only if there is MSI-X vector */
+		if (pf->num_fdsb_msix > 0)
+			pf->flags |= I40E_FLAG_FD_SB_ENABLED;
 	} else {
 		/* turn off filters, mark for reset and clear SW filter list */
 		if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
-- 
2.5.5
