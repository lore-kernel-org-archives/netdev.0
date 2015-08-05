From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Add IWARP support for X722
Date: Wed,  5 Aug 2015 16:52:08 -0700
Message-ID: <1438818735-38115-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11984 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753830AbbHEXwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:22 -0400
In-Reply-To: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

X722 supports IWARP, this patch handles checking for PE critical errors.
Since the driver doesn't support the IWARP interface for now, this patch
just does bare minimum to log a message oif a PE critical error
happens.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d9cb87f..3bb832a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2908,6 +2908,9 @@ static void i40e_enable_misc_int_causes(struct i40e_pf *pf)
 	      I40E_PFINT_ICR0_ENA_VFLR_MASK          |
 	      I40E_PFINT_ICR0_ENA_ADMINQ_MASK;
 
+	if (pf->flags & I40E_FLAG_IWARP_ENABLED)
+		val |= I40E_PFINT_ICR0_ENA_PE_CRITERR_MASK;
+
 	if (pf->flags & I40E_FLAG_PTP)
 		val |= I40E_PFINT_ICR0_ENA_TIMESYNC_MASK;
 
@@ -3198,6 +3201,13 @@ static irqreturn_t i40e_intr(int irq, void *data)
 	    (icr0 & I40E_PFINT_ICR0_SWINT_MASK))
 		pf->sw_int_count++;
 
+	if ((pf->flags & I40E_FLAG_IWARP_ENABLED) &&
+	    (ena_mask & I40E_PFINT_ICR0_ENA_PE_CRITERR_MASK)) {
+		ena_mask &= ~I40E_PFINT_ICR0_ENA_PE_CRITERR_MASK;
+		icr0 &= ~I40E_PFINT_ICR0_ENA_PE_CRITERR_MASK;
+		dev_info(&pf->pdev->dev, "cleared PE_CRITERR\n");
+	}
+
 	/* only q0 is used in MSI/Legacy mode, and none are used in MSIX */
 	if (icr0 & I40E_PFINT_ICR0_QUEUE_0_MASK) {
 
-- 
2.4.3
