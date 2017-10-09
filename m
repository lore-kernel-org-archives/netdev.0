From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] i40e/i40evf: always set the CLEARPBA flag when re-enabling interrupts
Date: Mon,  9 Oct 2017 15:38:32 -0700
Message-ID: <20171009223841.2557-6-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36088 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754068AbdJIWjG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:06 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

In the past we changed driver behavior to not clear the PBA when
re-enabling interrupts. This change was motivated by the flawed belief
that clearing the PBA would cause a lost interrupt if a receive
interrupt occurred while interrupts were disabled.

According to empirical testing this isn't the case. Additionally, the
data sheet specifically says that we should set the CLEARPBA bit when
re-enabling interrupts in a polling setup.

This reverts commit 40d72a509862 ("i40e/i40evf: don't lose interrupts")

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  5 +----
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 11 +++++------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  6 ++----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  4 +---
 5 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 7baf6d8a84dd..8139b4ee1dc3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -949,9 +949,6 @@ static inline void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector)
 	struct i40e_hw *hw = &pf->hw;
 	u32 val;
 
-	/* definitely clear the PBA here, as this function is meant to
-	 * clean out all previous interrupts AND enable the interrupt
-	 */
 	val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
 	      I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
 	      (I40E_ITR_NONE << I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT);
@@ -960,7 +957,7 @@ static inline void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector)
 }
 
 void i40e_irq_dynamic_disable_icr0(struct i40e_pf *pf);
-void i40e_irq_dynamic_enable_icr0(struct i40e_pf *pf, bool clearpba);
+void i40e_irq_dynamic_enable_icr0(struct i40e_pf *pf);
 int i40e_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
 int i40e_open(struct net_device *netdev);
 int i40e_close(struct net_device *netdev);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d4b0cc36afb1..00a83afb02e9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3403,15 +3403,14 @@ void i40e_irq_dynamic_disable_icr0(struct i40e_pf *pf)
 /**
  * i40e_irq_dynamic_enable_icr0 - Enable default interrupt generation for icr0
  * @pf: board private structure
- * @clearpba: true when all pending interrupt events should be cleared
  **/
-void i40e_irq_dynamic_enable_icr0(struct i40e_pf *pf, bool clearpba)
+void i40e_irq_dynamic_enable_icr0(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
 	u32 val;
 
 	val = I40E_PFINT_DYN_CTL0_INTENA_MASK   |
-	      (clearpba ? I40E_PFINT_DYN_CTL0_CLEARPBA_MASK : 0) |
+	      I40E_PFINT_DYN_CTL0_CLEARPBA_MASK |
 	      (I40E_ITR_NONE << I40E_PFINT_DYN_CTL0_ITR_INDX_SHIFT);
 
 	wr32(hw, I40E_PFINT_DYN_CTL0, val);
@@ -3597,7 +3596,7 @@ static int i40e_vsi_enable_irq(struct i40e_vsi *vsi)
 		for (i = 0; i < vsi->num_q_vectors; i++)
 			i40e_irq_dynamic_enable(vsi, i);
 	} else {
-		i40e_irq_dynamic_enable_icr0(pf, true);
+		i40e_irq_dynamic_enable_icr0(pf);
 	}
 
 	i40e_flush(&pf->hw);
@@ -3746,7 +3745,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 	wr32(hw, I40E_PFINT_ICR0_ENA, ena_mask);
 	if (!test_bit(__I40E_DOWN, pf->state)) {
 		i40e_service_event_schedule(pf);
-		i40e_irq_dynamic_enable_icr0(pf, false);
+		i40e_irq_dynamic_enable_icr0(pf);
 	}
 
 	return ret;
@@ -8455,7 +8454,7 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
 
 	i40e_flush(hw);
 
-	i40e_irq_dynamic_enable_icr0(pf, true);
+	i40e_irq_dynamic_enable_icr0(pf);
 
 	return err;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 3bd176606c09..616abf79253e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2202,9 +2202,7 @@ static u32 i40e_buildreg_itr(const int type, const u16 itr)
 	u32 val;
 
 	val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
-	      /* Don't clear PBA because that can cause lost interrupts that
-	       * came in while we were cleaning/polling
-	       */
+	      I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
 	      (type << I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT) |
 	      (itr << I40E_PFINT_DYN_CTLN_INTERVAL_SHIFT);
 
@@ -2241,7 +2239,7 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 
 	/* If we don't have MSIX, then we only need to re-enable icr0 */
 	if (!(vsi->back->flags & I40E_FLAG_MSIX_ENABLED)) {
-		i40e_irq_dynamic_enable_icr0(vsi->back, false);
+		i40e_irq_dynamic_enable_icr0(vsi->back);
 		return;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index c062d74d21f3..10298956a81b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1358,7 +1358,7 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 		i40e_free_vfs(pf);
 err_iov:
 	/* Re-enable interrupt 0. */
-	i40e_irq_dynamic_enable_icr0(pf, false);
+	i40e_irq_dynamic_enable_icr0(pf);
 	return ret;
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 37e1de886d48..fe817e2b6fef 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1409,9 +1409,7 @@ static u32 i40e_buildreg_itr(const int type, const u16 itr)
 	u32 val;
 
 	val = I40E_VFINT_DYN_CTLN1_INTENA_MASK |
-	      /* Don't clear PBA because that can cause lost interrupts that
-	       * came in while we were cleaning/polling
-	       */
+	      I40E_VFINT_DYN_CTLN1_CLEARPBA_MASK |
 	      (type << I40E_VFINT_DYN_CTLN1_ITR_INDX_SHIFT) |
 	      (itr << I40E_VFINT_DYN_CTLN1_INTERVAL_SHIFT);
 
-- 
2.14.2
