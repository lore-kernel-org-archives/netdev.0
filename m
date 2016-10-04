From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/3] i40e: check if vectors are already depleted when doing VMDq allocation
Date: Mon,  3 Oct 2016 19:25:01 -0700
Message-ID: <1475547903-22168-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1475547903-22168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52990 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751702AbcJDCZF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 22:25:05 -0400
In-Reply-To: <1475547903-22168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

During MSI-X vector allocation for VMDq, a check for "no vectors left"
was missing, add it. This prevents more vectors to be allocated than
available.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8176596..66d2ca0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7674,18 +7674,23 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		int vmdq_vecs_wanted = pf->num_vmdq_vsis * pf->num_vmdq_qps;
 		int vmdq_vecs = min_t(int, vectors_left, vmdq_vecs_wanted);
 
-		/* if we're short on vectors for what's desired, we limit
-		 * the queues per vmdq.  If this is still more than are
-		 * available, the user will need to change the number of
-		 * queues/vectors used by the PF later with the ethtool
-		 * channels command
-		 */
-		if (vmdq_vecs < vmdq_vecs_wanted)
-			pf->num_vmdq_qps = 1;
-		pf->num_vmdq_msix = pf->num_vmdq_qps;
+		if (!vectors_left) {
+			pf->num_vmdq_msix = 0;
+			pf->num_vmdq_qps = 0;
+		} else {
+			/* if we're short on vectors for what's desired, we limit
+			 * the queues per vmdq.  If this is still more than are
+			 * available, the user will need to change the number of
+			 * queues/vectors used by the PF later with the ethtool
+			 * channels command
+			 */
+			if (vmdq_vecs < vmdq_vecs_wanted)
+				pf->num_vmdq_qps = 1;
+			pf->num_vmdq_msix = pf->num_vmdq_qps;
 
-		v_budget += vmdq_vecs;
-		vectors_left -= vmdq_vecs;
+			v_budget += vmdq_vecs;
+			vectors_left -= vmdq_vecs;
+		}
 	}
 
 	pf->msix_entries = kcalloc(v_budget, sizeof(struct msix_entry),
-- 
2.7.4
