From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 13/21] ixgbe: DCB, missed translation from 8021Qaz TSA to CEE link strict
Date: Sat, 12 Mar 2011 04:20:20 -0800
Message-ID: <1299932428-3114-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11283 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753906Ab1CLMU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:57 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The patch below  allowed IEEE 802.1Qaz and CEE DCB hardware
configurations to use common hardware set routines,

commit 88eb696cc6a7af8f9272266965b1a4dd7d6a931b
Author: John Fastabend <john.r.fastabend@intel.com>
Date:   Thu Feb 10 03:02:11 2011 -0800

    ixgbe: DCB, abstract out dcb_config from DCB hardware configuration

However the case when CEE link strict and group strict
are set was missed and are currently being mapped
incorrectly in some configurations.

This patch resolves this.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb.c    |   24 +-----------------------
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   24 ++++++++++++++++++++++--
 2 files changed, 23 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index c2ee6fc..e2e7a29 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -292,30 +292,8 @@ s32 ixgbe_dcb_hw_pfc_config(struct ixgbe_hw *hw, u8 pfc_en)
 }
 
 s32 ixgbe_dcb_hw_ets_config(struct ixgbe_hw *hw,
-			    u16 *refill, u16 *max, u8 *bwg_id, u8 *tsa)
+			    u16 *refill, u16 *max, u8 *bwg_id, u8 *prio_type)
 {
-	int i;
-	u8 prio_type[IEEE_8021QAZ_MAX_TCS];
-
-	/* Map TSA onto CEE prio type */
-	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
-		switch (tsa[i]) {
-		case IEEE_8021QAZ_TSA_STRICT:
-			prio_type[i] = 2;
-			break;
-		case IEEE_8021QAZ_TSA_ETS:
-			prio_type[i] = 0;
-			break;
-		default:
-			/* Hardware only supports priority strict or
-			 * ETS transmission selection algorithms if
-			 * we receive some other value from dcbnl
-			 * throw an error
-			 */
-			return -EINVAL;
-		}
-	}
-
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
 		ixgbe_dcb_config_rx_arbiter_82598(hw, refill, max,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 91ff51c..8abef8d 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -642,8 +642,9 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	__u16 refill[IEEE_8021QAZ_MAX_TCS], max[IEEE_8021QAZ_MAX_TCS];
+	__u8 prio_type[IEEE_8021QAZ_MAX_TCS];
 	int max_frame = dev->mtu + ETH_HLEN + ETH_FCS_LEN;
-	int err;
+	int i, err;
 	/* naively give each TC a bwg to map onto CEE hardware */
 	__u8 bwg_id[IEEE_8021QAZ_MAX_TCS] = {0, 1, 2, 3, 4, 5, 6, 7};
 
@@ -659,9 +660,28 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 
 	memcpy(adapter->ixgbe_ieee_ets, ets, sizeof(*adapter->ixgbe_ieee_ets));
 
+	/* Map TSA onto CEE prio type */
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		switch (ets->tc_tsa[i]) {
+		case IEEE_8021QAZ_TSA_STRICT:
+			prio_type[i] = 2;
+			break;
+		case IEEE_8021QAZ_TSA_ETS:
+			prio_type[i] = 0;
+			break;
+		default:
+			/* Hardware only supports priority strict or
+			 * ETS transmission selection algorithms if
+			 * we receive some other value from dcbnl
+			 * throw an error
+			 */
+			return -EINVAL;
+		}
+	}
+
 	ixgbe_ieee_credits(ets->tc_tx_bw, refill, max, max_frame);
 	err = ixgbe_dcb_hw_ets_config(&adapter->hw, refill, max,
-				      bwg_id, ets->tc_tsa);
+				      bwg_id, prio_type);
 	return err;
 }
 
-- 
1.7.4

