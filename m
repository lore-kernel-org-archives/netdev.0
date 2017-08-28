From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: move enabling icr0 into i40e_update_enable_itr
Date: Sun, 27 Aug 2017 17:15:59 -0700
Message-ID: <20170828001603.75876-12-jeffrey.t.kirsher@intel.com>
References: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:36375 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751685AbdH1AQU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:20 -0400
In-Reply-To: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

If we don't have MSI-X enabled, we handle interrupts on all icr0. This
is a special case, so let's move the conditional into
i40e_update_enable_itr() in order to make i40e_napi_poll easier to
read about.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 8a969d8f0790..5c1edcce9459 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2243,6 +2243,12 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 	int idx = q_vector->v_idx;
 	int rx_itr_setting, tx_itr_setting;
 
+	/* If we don't have MSIX, then we only need to re-enable icr0 */
+	if (!(vsi->back->flags & I40E_FLAG_MSIX_ENABLED)) {
+		i40e_irq_dynamic_enable_icr0(vsi->back, false);
+		return;
+	}
+
 	vector = (q_vector->v_idx + vsi->base_vector);
 
 	/* avoid dynamic calculation if in countdown mode OR if
@@ -2396,8 +2402,6 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	 */
 	if (!clean_complete)
 		i40e_force_wb(vsi, q_vector);
-	else if (!(vsi->back->flags & I40E_FLAG_MSIX_ENABLED))
-		i40e_irq_dynamic_enable_icr0(vsi->back, false);
 	else
 		i40e_update_enable_itr(vsi, q_vector);
 
-- 
2.14.1
