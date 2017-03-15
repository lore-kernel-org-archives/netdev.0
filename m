From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/12] i40e: don't add more vectors to num_lan_msix than number of CPUs
Date: Wed, 15 Mar 2017 02:25:38 -0700
Message-ID: <20170315092545.63654-6-jeffrey.t.kirsher@intel.com>
References: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>,
        Carolyn Wyborny <carolyn.wyborny@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44457 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752400AbdCOJZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 05:25:57 -0400
In-Reply-To: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This is a solution to avoid adding too many queues to num_lan_msix.
A recent refactor of queue pairs accidentally added all remaining
vectors to the num_lan_msix which can have adverse performance issues,
due to enabling more queues than the number of CPU cores.

This patch removes the old calculation, and replaces it with a simple
algorithm.

1) add queue pairs up to num_online_cpus(), but capped at half of total
   vectors
2) then add alternative features such as flow directory and similar
3) finally, add the remaining vectors back to queue pairs, but capped
   such that the total number of queue pairs does not exceed
   num_online_cpus().

Change-ID: I668abf67d5011a1248866daba8885f4ff00cb8d9
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 30 ++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3d7f179af6be..cb678ed7a2ad 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7819,6 +7819,7 @@ static int i40e_reserve_msix_vectors(struct i40e_pf *pf, int vectors)
 static int i40e_init_msix(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
+	int cpus, extra_vectors;
 	int vectors_left;
 	int v_budget, i;
 	int v_actual;
@@ -7854,10 +7855,16 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		vectors_left--;
 	}
 
-	/* reserve vectors for the main PF traffic queues */
-	pf->num_lan_msix = min_t(int, num_online_cpus(), vectors_left);
+	/* reserve some vectors for the main PF traffic queues. Initially we
+	 * only reserve at most 50% of the available vectors, in the case that
+	 * the number of online CPUs is large. This ensures that we can enable
+	 * extra features as well. Once we've enabled the other features, we
+	 * will use any remaining vectors to reach as close as we can to the
+	 * number of online CPUs.
+	 */
+	cpus = num_online_cpus();
+	pf->num_lan_msix = min_t(int, cpus, vectors_left / 2);
 	vectors_left -= pf->num_lan_msix;
-	v_budget += pf->num_lan_msix;
 
 	/* reserve one vector for sideband flow director */
 	if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
@@ -7920,6 +7927,23 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		}
 	}
 
+	/* On systems with a large number of SMP cores, we previously limited
+	 * the number of vectors for num_lan_msix to be at most 50% of the
+	 * available vectors, to allow for other features. Now, we add back
+	 * the remaining vectors. However, we ensure that the total
+	 * num_lan_msix will not exceed num_online_cpus(). To do this, we
+	 * calculate the number of vectors we can add without going over the
+	 * cap of CPUs. For systems with a small number of CPUs this will be
+	 * zero.
+	 */
+	extra_vectors = min_t(int, cpus - pf->num_lan_msix, vectors_left);
+	pf->num_lan_msix += extra_vectors;
+	vectors_left -= extra_vectors;
+
+	WARN(vectors_left < 0,
+	     "Calculation of remaining vectors underflowed. This is an accounting bug when determining total MSI-X vectors.\n");
+
+	v_budget += pf->num_lan_msix;
 	pf->msix_entries = kcalloc(v_budget, sizeof(struct msix_entry),
 				   GFP_KERNEL);
 	if (!pf->msix_entries)
-- 
2.12.0
