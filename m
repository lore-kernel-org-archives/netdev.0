From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] ixgbe: A fix to VF TX rate limit
Date: Sat, 25 Jun 2011 00:22:23 -0700
Message-ID: <1308986546-12964-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Lior Levy <lior.levy@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38346 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751497Ab1FYHWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 03:22:31 -0400
In-Reply-To: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lior Levy <lior.levy@intel.com>

There is a need to configure MMW_SIZE in register RTTBCNRM with a correct
value (0x4 for non jumbo frames and 0x14 for jumbo frames support).
For 82599 the value is 0x4 and for X540 the value is 0x14.

Signed-off-by: Lior Levy <lior.levy@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_sriov.c |   16 ++++++++++++++++
 drivers/net/ixgbe/ixgbe_type.h  |    2 +-
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index ac99b04..d99d01e 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -605,6 +605,22 @@ static void ixgbe_set_vf_rate_limit(struct ixgbe_hw *hw, int vf, int tx_rate,
 	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, 2*vf); /* vf Y uses queue 2*Y */
+	/*
+	 * Set global transmit compensation time to the MMW_SIZE in RTTBCNRM
+	 * register. Typically MMW_SIZE=0x014 if 9728-byte jumbo is supported
+	 * and 0x004 otherwise.
+	 */
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+		IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRM, 0x4);
+		break;
+	case ixgbe_mac_X540:
+		IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRM, 0x14);
+		break;
+	default:
+		break;
+	}
+
 	IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRC, bcnrc_val);
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 1eefc0c..e0d970e 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -534,7 +534,7 @@
 #define IXGBE_RTTBCNRC_RF_INT_SHIFT	14
 #define IXGBE_RTTBCNRC_RF_INT_MASK	\
 	(IXGBE_RTTBCNRC_RF_DEC_MASK << IXGBE_RTTBCNRC_RF_INT_SHIFT)
-
+#define IXGBE_RTTBCNRM    0x04980
 
 /* FCoE DMA Context Registers */
 #define IXGBE_FCPTRL    0x02410 /* FC User Desc. PTR Low */
-- 
1.7.5.4

