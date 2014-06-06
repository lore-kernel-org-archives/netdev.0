From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/13] i40e: remove irqs only when they are set up
Date: Fri,  6 Jun 2014 02:04:21 -0700
Message-ID: <1402045462-10304-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5109 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669AbaFFJFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 05:05:33 -0400
In-Reply-To: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Use an extra state variable to keep track of when the IRQs are fully
set up.  This keeps us from trying to unhook IRQs that already were
left unhooked in a failed reset recovery, e.g. when firmware is broken.

Change-ID: I073eb081e4ef8aedcbdf1ee0717c0ed64fa172f2
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 581898f..9c27d8b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -414,6 +414,7 @@ struct i40e_vsi {
 	struct i40e_q_vector **q_vectors;
 	int num_q_vectors;
 	int base_vector;
+	bool irqs_ready;
 
 	u16 seid;            /* HW index of this VSI (absolute index) */
 	u16 id;              /* VSI number */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 52bd69d..029288e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2790,6 +2790,7 @@ static int i40e_vsi_request_irq_msix(struct i40e_vsi *vsi, char *basename)
 				      &q_vector->affinity_mask);
 	}
 
+	vsi->irqs_ready = true;
 	return 0;
 
 free_queue_irqs:
@@ -3349,6 +3350,10 @@ static void i40e_vsi_free_irq(struct i40e_vsi *vsi)
 		if (!vsi->q_vectors)
 			return;
 
+		if (!vsi->irqs_ready)
+			return;
+
+		vsi->irqs_ready = false;
 		for (i = 0; i < vsi->num_q_vectors; i++) {
 			u16 vector = i + base;
 
@@ -5953,6 +5958,7 @@ static int i40e_vsi_mem_alloc(struct i40e_pf *pf, enum i40e_vsi_type type)
 	vsi->netdev_registered = false;
 	vsi->work_limit = I40E_DEFAULT_IRQ_WORK;
 	INIT_LIST_HEAD(&vsi->mac_filter_list);
+	vsi->irqs_ready = false;
 
 	ret = i40e_set_num_rings_in_vsi(vsi);
 	if (ret)
-- 
1.9.3
