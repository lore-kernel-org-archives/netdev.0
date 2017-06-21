From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: Handle PE_CRITERR properly with IWARP enabled
Date: Tue, 20 Jun 2017 18:18:01 -0700
Message-ID: <20170621011802.81768-15-jeffrey.t.kirsher@intel.com>
References: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Mitch Williams <mitch.a.williams@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:4752 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753155AbdFUBSS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 21:18:18 -0400
In-Reply-To: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

When IWARP is enabled, we weren't clearing the PE_CRITERR, just logging
it and removing it from the mask. We need to do a corer to reset the
PE_CRITERR register, so set the bit for that as we handle the
interrupt.

We should also be checking for the error against the PFINT_ICR0 register,
and only need to clear it in the value getting written to
PFINT_ICR0_ENA.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5d82ff54c7b0..c4328b4bec95 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3684,10 +3684,10 @@ static irqreturn_t i40e_intr(int irq, void *data)
 		pf->sw_int_count++;
 
 	if ((pf->flags & I40E_FLAG_IWARP_ENABLED) &&
-	    (ena_mask & I40E_PFINT_ICR0_ENA_PE_CRITERR_MASK)) {
+	    (icr0 & I40E_PFINT_ICR0_ENA_PE_CRITERR_MASK)) {
 		ena_mask &= ~I40E_PFINT_ICR0_ENA_PE_CRITERR_MASK;
-		icr0 &= ~I40E_PFINT_ICR0_ENA_PE_CRITERR_MASK;
 		dev_dbg(&pf->pdev->dev, "cleared PE_CRITERR\n");
+		set_bit(__I40E_CORE_RESET_REQUESTED, pf->state);
 	}
 
 	/* only q0 is used in MSI/Legacy mode, and none are used in MSIX */
-- 
2.12.2
