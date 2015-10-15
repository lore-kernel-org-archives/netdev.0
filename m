From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/17] i40e: use priv flags to control flow director
Date: Thu, 15 Oct 2015 02:39:51 -0700
Message-ID: <1444902004-14433-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27563 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752370AbbJOJm3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:29 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Some customers wish to be able to control our hardware specific
feature called flow director, at runtime.  This patch enables
ethtool priv flags to control this driver/hardware specific feature.

ethtool --set-priv-flags ethX flow-director-atr off

NOTE: the ethtool ntuple interface controls the flow-director
      sideband rules.

Change-ID: Iba156350b07fa2ce66f53ded51739f9a3781fe0e
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 14 ++++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index cfe8f83..c8591b9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -102,6 +102,7 @@
 /* Ethtool Private Flags */
 #define I40E_PRIV_FLAGS_NPAR_FLAG	BIT(0)
 #define I40E_PRIV_FLAGS_LINKPOLL_FLAG	BIT(1)
+#define I40E_PRIV_FLAGS_FD_ATR		BIT(2)
 
 #define I40E_NVM_VERSION_LO_SHIFT  0
 #define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 831f971..185ac91 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -231,6 +231,7 @@ static const char i40e_gstrings_test[][ETH_GSTRING_LEN] = {
 static const char i40e_priv_flags_strings[][ETH_GSTRING_LEN] = {
 	"NPAR",
 	"LinkPolling",
+	"flow-director-atr",
 };
 
 #define I40E_PRIV_FLAGS_STR_LEN ARRAY_SIZE(i40e_priv_flags_strings)
@@ -2666,6 +2667,8 @@ static u32 i40e_get_priv_flags(struct net_device *dev)
 		I40E_PRIV_FLAGS_NPAR_FLAG : 0;
 	ret_flags |= pf->flags & I40E_FLAG_LINK_POLLING_ENABLED ?
 		I40E_PRIV_FLAGS_LINKPOLL_FLAG : 0;
+	ret_flags |= pf->flags & I40E_FLAG_FD_ATR_ENABLED ?
+		I40E_PRIV_FLAGS_FD_ATR : 0;
 
 	return ret_flags;
 }
@@ -2686,6 +2689,17 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 	else
 		pf->flags &= ~I40E_FLAG_LINK_POLLING_ENABLED;
 
+	/* allow the user to control the state of the Flow
+	 * Director ATR (Application Targeted Routing) feature
+	 * of the driver
+	 */
+	if (flags & I40E_PRIV_FLAGS_FD_ATR) {
+		pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
+	} else {
+		pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
+		pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
+	}
+
 	return 0;
 }
 
-- 
2.4.3
