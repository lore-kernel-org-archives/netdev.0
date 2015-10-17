From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/17] i40e/i40evf: use napi_schedule_irqoff()
Date: Fri, 16 Oct 2015 22:28:18 -0700
Message-ID: <1445059711-45992-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25665 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028AbbJQF2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 01:28:42 -0400
In-Reply-To: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The i40e_intr and i40e/i40evf_msix_clean_rings functions run from hard
interrupt context or with interrupts already disabled in netpoll.

They can use napi_schedule_irqoff() instead of napi_schedule()

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 6 ++++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index aa2aafd..11dbb29 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3287,7 +3287,7 @@ static irqreturn_t i40e_msix_clean_rings(int irq, void *data)
 	if (!q_vector->tx.ring && !q_vector->rx.ring)
 		return IRQ_HANDLED;
 
-	napi_schedule(&q_vector->napi);
+	napi_schedule_irqoff(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
@@ -3456,6 +3456,8 @@ static irqreturn_t i40e_intr(int irq, void *data)
 
 	/* only q0 is used in MSI/Legacy mode, and none are used in MSIX */
 	if (icr0 & I40E_PFINT_ICR0_QUEUE_0_MASK) {
+		struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+		struct i40e_q_vector *q_vector = vsi->q_vectors[0];
 
 		/* temporarily disable queue cause for NAPI processing */
 		u32 qval = rd32(hw, I40E_QINT_RQCTL(0));
@@ -3468,7 +3470,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 		wr32(hw, I40E_QINT_TQCTL(0), qval);
 
 		if (!test_bit(__I40E_DOWN, &pf->state))
-			napi_schedule(&pf->vsi[pf->lan_vsi]->q_vectors[0]->napi);
+			napi_schedule_irqoff(&q_vector->napi);
 	}
 
 	if (icr0 & I40E_PFINT_ICR0_ADMINQ_MASK) {
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 4c4340c..1dd5245 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -334,7 +334,7 @@ static irqreturn_t i40evf_msix_clean_rings(int irq, void *data)
 	if (!q_vector->tx.ring && !q_vector->rx.ring)
 		return IRQ_HANDLED;
 
-	napi_schedule(&q_vector->napi);
+	napi_schedule_irqoff(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
-- 
2.4.3
