From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40evf: don't round Tx rate down to 0
Date: Thu, 29 May 2014 08:10:04 -0700
Message-ID: <1401376216-12531-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932535AbaE2PKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:36 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Because the hardware configures VF Tx rates in increments of 50 Mbps,
values smaller than that would be rounded down to 0, which was
interpreted as no limit at all. Rather than do this, we round up to 50
Mbps and notify the user.

Change-ID: I5275848233fe7514cf93e11323661c68f4c38737
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 7ab40ff..395c546 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2258,6 +2258,11 @@ int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
 		goto error;
 	}
 
+	if ((max_tx_rate < 50) && (max_tx_rate > 0)) {
+		dev_warn(&pf->pdev->dev, "Setting max Tx rate to minimum usable value of 50Mbps.\n");
+		max_tx_rate = 50;
+	}
+
 	/* Tx rate credits are in values of 50Mbps, 0 is disabled*/
 	ret = i40e_aq_config_vsi_bw_limit(&pf->hw, vsi->seid, max_tx_rate / 50,
 					  0, NULL);
-- 
1.9.3
