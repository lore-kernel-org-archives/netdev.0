From: Alexander Duyck <aduyck@mirantis.com>
Subject: [PATCH 2/3] i40e/i40evf: use napi_schedule_irqoff()
Date: Tue, 29 Sep 2015 15:19:50 -0700
Message-ID: <20150929221950.3388.63535.stgit@ahduyck-vm-fedora22>
References: <20150929215117.3388.48642.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33007 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755326AbbI2WTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:19:52 -0400
Received: by pacex6 with SMTP id ex6so18079686pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:19:51 -0700 (PDT)
In-Reply-To: <20150929215117.3388.48642.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i40e_intr and i40e/i40evf_msix_clean_rings functions run from hard
interrupt context or with interrupts already disabled in netpoll.

They can use napi_schedule_irqoff() instead of napi_schedule()

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     |    6 ++++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |    2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 484226e0365d..3cc97d4f5f70 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3281,7 +3281,7 @@ static irqreturn_t i40e_msix_clean_rings(int irq, void *data)
 	if (!q_vector->tx.ring && !q_vector->rx.ring)
 		return IRQ_HANDLED;
 
-	napi_schedule(&q_vector->napi);
+	napi_schedule_irqoff(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
@@ -3450,6 +3450,8 @@ static irqreturn_t i40e_intr(int irq, void *data)
 
 	/* only q0 is used in MSI/Legacy mode, and none are used in MSIX */
 	if (icr0 & I40E_PFINT_ICR0_QUEUE_0_MASK) {
+		struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+		struct i40e_q_vector *q_vector = vsi->q_vectors[0];
 
 		/* temporarily disable queue cause for NAPI processing */
 		u32 qval = rd32(hw, I40E_QINT_RQCTL(0));
@@ -3462,7 +3464,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 		wr32(hw, I40E_QINT_TQCTL(0), qval);
 
 		if (!test_bit(__I40E_DOWN, &pf->state))
-			napi_schedule(&pf->vsi[pf->lan_vsi]->q_vectors[0]->napi);
+			napi_schedule_irqoff(&q_vector->napi);
 	}
 
 	if (icr0 & I40E_PFINT_ICR0_ADMINQ_MASK) {
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 5e1336321c2f..4b3db099f58c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -334,7 +334,7 @@ static irqreturn_t i40evf_msix_clean_rings(int irq, void *data)
 	if (!q_vector->tx.ring && !q_vector->rx.ring)
 		return IRQ_HANDLED;
 
-	napi_schedule(&q_vector->napi);
+	napi_schedule_irqoff(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
