From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: Don't notify client of VF reset during VF creation
Date: Thu, 18 Aug 2016 14:57:30 -0700
Message-ID: <1471557456-136741-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Avinash Dayanand <avinash.dayanand@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62947 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754663AbcHSBwD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 21:52:03 -0400
In-Reply-To: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Avinash Dayanand <avinash.dayanand@intel.com>

VF goes through reset path during VF creation which happens to also
have notification of VF reset to client. Adding conditional check to
avoid wrongly notifying VF reset during VF creation.

Also changing the call order of VF enable, calling it after VF creation
rather than before.

Change-ID: I96eabd99deae746a2f0fc465194c886f196178ce
Signed-off-by: Avinash Dayanand <avinash.dayanand@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 0fa050a..5ea659c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -991,7 +991,9 @@ complete_reset:
 		i40e_enable_vf_mappings(vf);
 		set_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states);
 		clear_bit(I40E_VF_STAT_DISABLED, &vf->vf_states);
-		i40e_notify_client_of_vf_reset(pf, abs_vf_id);
+		/* Do not notify the client during VF init */
+		if (vf->pf->num_alloc_vfs)
+			i40e_notify_client_of_vf_reset(pf, abs_vf_id);
 		vf->num_vlan = 0;
 	}
 	/* tell the VF the reset is done */
@@ -1090,7 +1092,6 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 			goto err_iov;
 		}
 	}
-	i40e_notify_client_of_vf_enable(pf, num_alloc_vfs);
 	/* allocate memory */
 	vfs = kcalloc(num_alloc_vfs, sizeof(struct i40e_vf), GFP_KERNEL);
 	if (!vfs) {
@@ -1114,6 +1115,8 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 	}
 	pf->num_alloc_vfs = num_alloc_vfs;
 
+	i40e_notify_client_of_vf_enable(pf, num_alloc_vfs);
+
 err_alloc:
 	if (ret)
 		i40e_free_vfs(pf);
-- 
2.7.4
