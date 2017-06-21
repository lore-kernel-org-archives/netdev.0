From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: clear only cause_ena bit
Date: Tue, 20 Jun 2017 18:18:00 -0700
Message-ID: <20170621011802.81768-14-jeffrey.t.kirsher@intel.com>
References: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Mitch Williams <mitch.a.williams@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7623 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753147AbdFUBSS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 21:18:18 -0400
In-Reply-To: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

When disabling interrupts, we should only be clearing the CAUSE_ENA bit,
not clearing the whole register.  Clearing the whole register sets the
NEXTQ_IDX field to 0 instead of 0x7ff which can confuse the Firmware in
some reset sequences.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b743eca879d5..5d82ff54c7b0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3588,14 +3588,24 @@ static void i40e_vsi_disable_irq(struct i40e_vsi *vsi)
 	int base = vsi->base_vector;
 	int i;
 
+	/* disable interrupt causation from each queue */
 	for (i = 0; i < vsi->num_queue_pairs; i++) {
-		wr32(hw, I40E_QINT_TQCTL(vsi->tx_rings[i]->reg_idx), 0);
-		wr32(hw, I40E_QINT_RQCTL(vsi->rx_rings[i]->reg_idx), 0);
+		u32 val;
+
+		val = rd32(hw, I40E_QINT_TQCTL(vsi->tx_rings[i]->reg_idx));
+		val &= ~I40E_QINT_TQCTL_CAUSE_ENA_MASK;
+		wr32(hw, I40E_QINT_TQCTL(vsi->tx_rings[i]->reg_idx), val);
+
+		val = rd32(hw, I40E_QINT_RQCTL(vsi->rx_rings[i]->reg_idx));
+		val &= ~I40E_QINT_RQCTL_CAUSE_ENA_MASK;
+		wr32(hw, I40E_QINT_RQCTL(vsi->rx_rings[i]->reg_idx), val);
+
 		if (!i40e_enabled_xdp_vsi(vsi))
 			continue;
 		wr32(hw, I40E_QINT_TQCTL(vsi->xdp_rings[i]->reg_idx), 0);
 	}
 
+	/* disable each interrupt */
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
 		for (i = vsi->base_vector;
 		     i < (vsi->num_q_vectors + vsi->base_vector); i++)
-- 
2.12.2
