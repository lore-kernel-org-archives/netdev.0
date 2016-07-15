From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/4] i40e: use valid online CPU on q_vector initialization
Date: Fri, 15 Jul 2016 00:02:04 -0700
Message-ID: <1468566124-63101-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1468566124-63101-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:3140 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628AbcGOHCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 03:02:49 -0400
In-Reply-To: <1468566124-63101-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>

Currently, the q_vector initialization routine sets the affinity_mask
of a q_vector based on v_idx value. Meaning a loop iterates on v_idx,
which is an incremental value, and the cpumask is created based on
this value.

This is a problem in systems with multiple logical CPUs per core (like in
SMT scenarios). If we disable some logical CPUs, by turning SMT off for
example, we will end up with a sparse cpu_online_mask, i.e., only the first
CPU in a core is online, and incremental filling in q_vector cpumask might
lead to multiple offline CPUs being assigned to q_vectors.

Example: if we have a system with 8 cores each one containing 8 logical
CPUs (SMT == 8 in this case), we have 64 CPUs in total. But if SMT is
disabled, only the 1st CPU in each core remains online, so the
cpu_online_mask in this case would have only 8 bits set, in a sparse way.

In general case, when SMT is off the cpu_online_mask has only C bits set:
0, 1*N, 2*N, ..., C*(N-1)  where
C == # of cores;
N == # of logical CPUs per core.
In our example, only bits 0, 8, 16, 24, 32, 40, 48, 56 would be set.

This patch changes the way q_vector's affinity_mask is created: it iterates
on v_idx, but consumes the CPU index from the cpu_online_mask instead of
just using the v_idx incremental value.

No functional changes were introduced.

Signed-off-by: Guilherme G Piccoli <gpiccoli@linux.vnet.ibm.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1592dcb..501f15d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7721,10 +7721,11 @@ static int i40e_init_msix(struct i40e_pf *pf)
  * i40e_vsi_alloc_q_vector - Allocate memory for a single interrupt vector
  * @vsi: the VSI being configured
  * @v_idx: index of the vector in the vsi struct
+ * @cpu: cpu to be used on affinity_mask
  *
  * We allocate one q_vector.  If allocation fails we return -ENOMEM.
  **/
-static int i40e_vsi_alloc_q_vector(struct i40e_vsi *vsi, int v_idx)
+static int i40e_vsi_alloc_q_vector(struct i40e_vsi *vsi, int v_idx, int cpu)
 {
 	struct i40e_q_vector *q_vector;
 
@@ -7735,7 +7736,8 @@ static int i40e_vsi_alloc_q_vector(struct i40e_vsi *vsi, int v_idx)
 
 	q_vector->vsi = vsi;
 	q_vector->v_idx = v_idx;
-	cpumask_set_cpu(v_idx, &q_vector->affinity_mask);
+	cpumask_set_cpu(cpu, &q_vector->affinity_mask);
+
 	if (vsi->netdev)
 		netif_napi_add(vsi->netdev, &q_vector->napi,
 			       i40e_napi_poll, NAPI_POLL_WEIGHT);
@@ -7759,8 +7761,7 @@ static int i40e_vsi_alloc_q_vector(struct i40e_vsi *vsi, int v_idx)
 static int i40e_vsi_alloc_q_vectors(struct i40e_vsi *vsi)
 {
 	struct i40e_pf *pf = vsi->back;
-	int v_idx, num_q_vectors;
-	int err;
+	int err, v_idx, num_q_vectors, current_cpu;
 
 	/* if not MSIX, give the one vector only to the LAN VSI */
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED)
@@ -7770,10 +7771,15 @@ static int i40e_vsi_alloc_q_vectors(struct i40e_vsi *vsi)
 	else
 		return -EINVAL;
 
+	current_cpu = cpumask_first(cpu_online_mask);
+
 	for (v_idx = 0; v_idx < num_q_vectors; v_idx++) {
-		err = i40e_vsi_alloc_q_vector(vsi, v_idx);
+		err = i40e_vsi_alloc_q_vector(vsi, v_idx, current_cpu);
 		if (err)
 			goto err_out;
+		current_cpu = cpumask_next(current_cpu, cpu_online_mask);
+		if (unlikely(current_cpu >= nr_cpu_ids))
+			current_cpu = cpumask_first(cpu_online_mask);
 	}
 
 	return 0;
-- 
2.5.5
