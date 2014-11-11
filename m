From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/10] ixgbe: add helper function for setting RSS key in preparation of X550
Date: Tue, 11 Nov 2014 06:44:46 -0800
Message-ID: <1415717086-3441-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415717086-3441-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3088 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589AbaKKOpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 09:45:31 -0500
In-Reply-To: <1415717086-3441-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Split off the setting of the RSS key into its own function.  This
will help when we add support for X550 which can have different
RSS keys per pool.

CC: John Ronciak <john.ronciak@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 32 +++++++++++++++++----------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 355d1f7..a5ca877 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3210,14 +3210,10 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_SRRCTL(reg_idx), srrctl);
 }
 
-static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
+static void ixgbe_setup_reta(struct ixgbe_adapter *adapter, const u32 *seed)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	static const u32 seed[10] = { 0xE291D73D, 0x1805EC6C, 0x2A94B30D,
-			  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
-			  0x6A3E67EA, 0x14364D17, 0x3BED200D};
-	u32 mrqc = 0, reta = 0;
-	u32 rxcsum;
+	u32 reta = 0;
 	int i, j;
 	u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
 
@@ -3243,6 +3239,16 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 		if ((i & 3) == 3)
 			IXGBE_WRITE_REG(hw, IXGBE_RETA(i >> 2), reta);
 	}
+}
+
+static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	static const u32 seed[10] = { 0xE291D73D, 0x1805EC6C, 0x2A94B30D,
+			  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
+			  0x6A3E67EA, 0x14364D17, 0x3BED200D};
+	u32 mrqc = 0, rss_field = 0;
+	u32 rxcsum;
 
 	/* Disable indicating checksum in descriptor, enables RSS hash */
 	rxcsum = IXGBE_READ_REG(hw, IXGBE_RXCSUM);
@@ -3275,16 +3281,18 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	}
 
 	/* Perform hash on these packet types */
-	mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4 |
-		IXGBE_MRQC_RSS_FIELD_IPV4_TCP |
-		IXGBE_MRQC_RSS_FIELD_IPV6 |
-		IXGBE_MRQC_RSS_FIELD_IPV6_TCP;
+	rss_field |= IXGBE_MRQC_RSS_FIELD_IPV4 |
+		     IXGBE_MRQC_RSS_FIELD_IPV4_TCP |
+		     IXGBE_MRQC_RSS_FIELD_IPV6 |
+		     IXGBE_MRQC_RSS_FIELD_IPV6_TCP;
 
 	if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV4_UDP)
-		mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4_UDP;
+		rss_field |= IXGBE_MRQC_RSS_FIELD_IPV4_UDP;
 	if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV6_UDP)
-		mrqc |= IXGBE_MRQC_RSS_FIELD_IPV6_UDP;
+		rss_field |= IXGBE_MRQC_RSS_FIELD_IPV6_UDP;
 
+	ixgbe_setup_reta(adapter, seed);
+	mrqc |= rss_field;
 	IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
 }
 
-- 
1.9.3
