From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] ixgbe: fix return values and memcpy parameters to eliminate Smatch warnings
Date: Tue,  5 Feb 2013 02:02:25 -0800
Message-ID: <1360058548-18158-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Josh Hay <joshua.a.hay@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:25253 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753782Ab3BEKCz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 05:02:55 -0500
In-Reply-To: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hay <joshua.a.hay@intel.com>

This patch removes the rval variable returns from function and replaces
them with direct returns in ixgbe_dcbnl_getnumtcs. It also changes how
ixgbe_gstrings_test is copied into data with memcpy in ixgbe_get_strings
because "*ixgbe_gstrings_test too small (32 vs 160)".

Signed-off-by: Josh Hay <joshua.a.hay@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c  | 7 +++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 6 ++++--
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index c261333..3735590 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -449,7 +449,6 @@ static u8 ixgbe_dcbnl_getcap(struct net_device *netdev, int capid, u8 *cap)
 static int ixgbe_dcbnl_getnumtcs(struct net_device *netdev, int tcid, u8 *num)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u8 rval = 0;
 
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 		switch (tcid) {
@@ -460,14 +459,14 @@ static int ixgbe_dcbnl_getnumtcs(struct net_device *netdev, int tcid, u8 *num)
 			*num = adapter->dcb_cfg.num_tcs.pfc_tcs;
 			break;
 		default:
-			rval = -EINVAL;
+			return -EINVAL;
 			break;
 		}
 	} else {
-		rval = -EINVAL;
+		return -EINVAL;
 	}
 
-	return rval;
+	return 0;
 }
 
 static int ixgbe_dcbnl_setnumtcs(struct net_device *netdev, int tcid, u8 num)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index bafd141..355ca08 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1099,8 +1099,10 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 
 	switch (stringset) {
 	case ETH_SS_TEST:
-		memcpy(data, *ixgbe_gstrings_test,
-		       IXGBE_TEST_LEN * ETH_GSTRING_LEN);
+		for (i = 0; i < IXGBE_TEST_LEN; i++) {
+			memcpy(data, ixgbe_gstrings_test[i], ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
 		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
-- 
1.7.11.7
