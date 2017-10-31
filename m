From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] i40e: only redistribute MSI-X vectors when needed
Date: Tue, 31 Oct 2017 11:40:05 -0700
Message-ID: <20171031184012.29690-3-jeffrey.t.kirsher@intel.com>
References: <20171031184012.29690-1-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@oracle.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21198 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932576AbdJaSkf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 14:40:35 -0400
In-Reply-To: <20171031184012.29690-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@oracle.com>

Whether or not there are vectors_left, we only need to redistribute
our vectors if we didn't get as many as we requested.  With the current
check, the code will try to redistribute even if we did in fact get all
the vectors we requested - this can happen when we have more CPUs than
we do vectors.  This restores an earlier check to be sure we only
redistribute if we didn't get the full count we requested.

Fixes: 4ce20abc645f (i40e: fix MSI-X vector redistribution if hw limit is reached)
Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2a087319c09b..1cf9ba2d9a41 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9346,7 +9346,7 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		pf->num_lan_qps = 1;
 		pf->num_lan_msix = 1;
 
-	} else if (!vectors_left) {
+	} else if (v_actual != v_budget) {
 		/* If we have limited resources, we will start with no vectors
 		 * for the special features and then allocate vectors to some
 		 * of these features based on the policy and at the end disable
@@ -9355,7 +9355,8 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		int vec;
 
 		dev_info(&pf->pdev->dev,
-			 "MSI-X vector limit reached, attempting to redistribute vectors\n");
+			 "MSI-X vector limit reached with %d, wanted %d, attempting to redistribute vectors\n",
+			 v_actual, v_budget);
 		/* reserve the misc vector */
 		vec = v_actual - 1;
 
-- 
2.14.2
