From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/16] i40e: add counter for arq overflows
Date: Tue, 16 Feb 2016 21:34:14 -0800
Message-ID: <1455687262-20453-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14537 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756356AbcBQFe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:27 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Sometimes, ARQ overflows are a big deal and tell us that the
firmware/hardware/driver/something is having problems. But normally
they're no big deal. To assist in assessing this, add a counter to
our Ethtool stats. A handful of ARQ overflows during VF init is no
problem. A large, ever-growing number indicates that Something Bad is
happening.

Change-ID: Ie5348bfbc8a54a890559cb00279c28d976a55096
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 1 +
 3 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 53ed3bd..944dee9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -393,6 +393,7 @@ struct i40e_pf {
 	struct i40e_vf *vf;
 	int num_alloc_vfs;	/* actual number of VFs allocated */
 	u32 vf_aq_requests;
+	u32 arq_overflows;	/* Not fatal, possibly indicative of problems */
 
 	/* DCBx/DCBNL capability for PF that indicates
 	 * whether DCBx is managed by firmware or host
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 4549591..812c954 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -143,6 +143,7 @@ static struct i40e_stats i40e_gstrings_stats[] = {
 	I40E_PF_STAT("rx_oversize", stats.rx_oversize),
 	I40E_PF_STAT("rx_jabber", stats.rx_jabber),
 	I40E_PF_STAT("VF_admin_queue_requests", vf_aq_requests),
+	I40E_PF_STAT("arq_overflows", arq_overflows),
 	I40E_PF_STAT("rx_hwtstamp_cleared", rx_hwtstamp_cleared),
 	I40E_PF_STAT("fdir_flush_cnt", fd_flush_cnt),
 	I40E_PF_STAT("fdir_atr_match", stats.fd_atr_match),
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 320b049..7323e32 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6248,6 +6248,7 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 		if (hw->debug_mask & I40E_DEBUG_AQ)
 			dev_info(&pf->pdev->dev, "ARQ Overflow Error detected\n");
 		val &= ~I40E_PF_ARQLEN_ARQOVFL_MASK;
+		pf->arq_overflows++;
 	}
 	if (val & I40E_PF_ARQLEN_ARQCRIT_MASK) {
 		if (hw->debug_mask & I40E_DEBUG_AQ)
-- 
2.5.0
