From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40evf: tweak Tx rate params and de-magic-ify
Date: Thu, 29 May 2014 08:10:05 -0700
Message-ID: <1401376216-12531-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42446 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932768AbaE2PKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:37 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

In order for the VF to achieve its programmed Tx rate, we need to set
the max credits value to 4. While we're at it, get rid of some magic
numbers.

Change-ID: I4f17b4d3a90f1e069bdd134a543f0aa22feac3a9
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 395c546..4e7634c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2198,6 +2198,8 @@ error_pvid:
 	return ret;
 }
 
+#define I40E_BW_CREDIT_DIVISOR 50     /* 50Mbps per BW credit */
+#define I40E_MAX_BW_INACTIVE_ACCUM 4  /* device can accumulate 4 credits max */
 /**
  * i40e_ndo_set_vf_bw
  * @netdev: network interface device structure
@@ -2264,8 +2266,9 @@ int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
 	}
 
 	/* Tx rate credits are in values of 50Mbps, 0 is disabled*/
-	ret = i40e_aq_config_vsi_bw_limit(&pf->hw, vsi->seid, max_tx_rate / 50,
-					  0, NULL);
+	ret = i40e_aq_config_vsi_bw_limit(&pf->hw, vsi->seid,
+					  max_tx_rate / I40E_BW_CREDIT_DIVISOR,
+					  I40E_MAX_BW_INACTIVE_ACCUM, NULL);
 	if (ret) {
 		dev_err(&pf->pdev->dev, "Unable to set max tx rate, error code %d.\n",
 			ret);
-- 
1.9.3
