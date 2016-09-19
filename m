From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next 1/3] i40e: check if vectors are already depleted when doing VMDq allocation
Date: Mon, 19 Sep 2016 13:37:49 +0200
Message-ID: <1474285071-28218-2-git-send-email-sassmann@kpanic.de>
References: <1474285071-28218-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33274 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753895AbcISLiS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 07:38:18 -0400
In-Reply-To: <1474285071-28218-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During MSI-X vector allocation for VMDq, a check for "no vectors left"
was missing, add it. This prevents more vectors to be allocated than
available.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 61b0fc4..5f3f1c8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7678,18 +7678,23 @@ static int i40e_init_msix(struct i40e_pf *pf)
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
