From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/16] i40e: inline interrupt enable
Date: Thu,  8 Oct 2015 18:32:40 -0700
Message-ID: <1444354374-24351-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54300 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755265AbbJIBc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:32:57 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The interrupt enable function can be inlined by moving it to the header
file, which decreases the function call overhead for a frequently called
function.

Change-ID: I3214cc99593725768642680e7b8ce7e9bba7e44d
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 19 ++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c | 18 ------------------
 2 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 681bd5d..7a3c939 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -702,7 +702,24 @@ static inline void i40e_dbg_pf_exit(struct i40e_pf *pf) {}
 static inline void i40e_dbg_init(void) {}
 static inline void i40e_dbg_exit(void) {}
 #endif /* CONFIG_DEBUG_FS*/
-void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector);
+/**
+ * i40e_irq_dynamic_enable - Enable default interrupt generation settings
+ * @vsi: pointer to a vsi
+ * @vector: enable a particular Hw Interrupt vector, without base_vector
+ **/
+static inline void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector)
+{
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	u32 val;
+
+	val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
+	      I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
+	      (I40E_ITR_NONE << I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT);
+	wr32(hw, I40E_PFINT_DYN_CTLN(vector + vsi->base_vector - 1), val);
+	/* skip the flush */
+}
+
 void i40e_irq_dynamic_disable(struct i40e_vsi *vsi, int vector);
 void i40e_irq_dynamic_disable_icr0(struct i40e_pf *pf);
 void i40e_irq_dynamic_enable_icr0(struct i40e_pf *pf);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index fb4b34d..2c59214 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3060,24 +3060,6 @@ void i40e_irq_dynamic_enable_icr0(struct i40e_pf *pf)
 }
 
 /**
- * i40e_irq_dynamic_enable - Enable default interrupt generation settings
- * @vsi: pointer to a vsi
- * @vector: enable a particular Hw Interrupt vector, without base_vector
- **/
-void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector)
-{
-	struct i40e_pf *pf = vsi->back;
-	struct i40e_hw *hw = &pf->hw;
-	u32 val;
-
-	val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
-	      I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
-	      (I40E_ITR_NONE << I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT);
-	wr32(hw, I40E_PFINT_DYN_CTLN(vector + vsi->base_vector - 1), val);
-	/* skip the flush */
-}
-
-/**
  * i40e_irq_dynamic_disable - Disable default interrupt generation settings
  * @vsi: pointer to a vsi
  * @vector: disable a particular Hw Interrupt vector
-- 
2.4.3
