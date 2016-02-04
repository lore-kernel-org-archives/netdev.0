From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/20] i40e/i40evf: Fix RSS rx-flow-hash configuration through ethtool
Date: Thu,  4 Feb 2016 03:48:53 -0800
Message-ID: <1454586551-35919-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34313 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933862AbcBDLtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:15 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch fixes the Hash PCTYPE enable for X722 since it supports
a broader selection of PCTYPES for TCP and UDP.

This patch also fixes a bug in XL710, X710, X722 support for RSS,
as of now we cannot reduce the (4)tuple for RSS for TCP/IPv4/IPV6 or
UDP/IPv4/IPv6 packets since this requires a product feature change
that comes in a later release.

A VF should never be allowed to change the tuples for RSS for any
PCTYPE since that's a global setting for the device in case of i40e
devices.

Change-ID: I0ee7203c9b24813260f58f3220798bc9d9ac4a12
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 14 +++-----
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 40 +++++-----------------
 2 files changed, 12 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 29d5833..c8b9dca 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2166,8 +2166,7 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 	case TCP_V4_FLOW:
 		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 		case 0:
-			hena &= ~BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
-			break;
+			return -EINVAL;
 		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
 			hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
 			break;
@@ -2178,8 +2177,7 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 	case TCP_V6_FLOW:
 		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 		case 0:
-			hena &= ~BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
-			break;
+			return -EINVAL;
 		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
 			hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
 			break;
@@ -2190,9 +2188,7 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 	case UDP_V4_FLOW:
 		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 		case 0:
-			hena &= ~(BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
-				  BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV4));
-			break;
+			return -EINVAL;
 		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
 			hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
 				 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV4));
@@ -2204,9 +2200,7 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 	case UDP_V6_FLOW:
 		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 		case 0:
-			hena &= ~(BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
-				  BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV6));
-			break;
+			return -EINVAL;
 		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
 			hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
 				 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV6));
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index a4c9feb..8906785 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -477,54 +477,30 @@ static int i40evf_set_rss_hash_opt(struct i40evf_adapter *adapter,
 
 	switch (nfc->flow_type) {
 	case TCP_V4_FLOW:
-		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-		case 0:
-			hena &= ~BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
-			break;
-		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3))
 			hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
-			break;
-		default:
+		else
 			return -EINVAL;
-		}
 		break;
 	case TCP_V6_FLOW:
-		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-		case 0:
-			hena &= ~BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
-			break;
-		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3))
 			hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
-			break;
-		default:
+		else
 			return -EINVAL;
-		}
 		break;
 	case UDP_V4_FLOW:
-		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-		case 0:
-			hena &= ~(BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
-				  BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV4));
-			break;
-		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 			hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
 				 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV4));
-			break;
-		default:
+		} else {
 			return -EINVAL;
 		}
 		break;
 	case UDP_V6_FLOW:
-		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-		case 0:
-			hena &= ~(BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
-				  BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV6));
-			break;
-		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 			hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
 				 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV6));
-			break;
-		default:
+		} else {
 			return -EINVAL;
 		}
 		break;
-- 
2.5.0
