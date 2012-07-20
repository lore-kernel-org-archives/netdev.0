From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] ixgbe: Only enable anti-spoof on VF pools
Date: Thu, 19 Jul 2012 18:24:05 -0700
Message-ID: <1342747446-16132-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55809 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752581Ab2GTBYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 21:24:15 -0400
In-Reply-To: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The current logic is enabling anti-spoof on all pools and then clearing
anti-spoof on just the first PF pool.  The correct approach is to only set
anti-spoof on the VF pools and to leave all of the PF pools unchecked.

This allows for items such as FCoE to use adjacent pools within the PF for
transmit and receive queues without the traffic being blocked by this
security feature.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index bbe9d45..90e41db 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3225,20 +3225,22 @@ void ixgbe_set_mac_anti_spoofing(struct ixgbe_hw *hw, bool enable, int pf)
 	 * PFVFSPOOF register array is size 8 with 8 bits assigned to
 	 * MAC anti-spoof enables in each register array element.
 	 */
-	for (j = 0; j < IXGBE_PFVFSPOOF_REG_COUNT; j++)
+	for (j = 0; j < pf_target_reg; j++)
 		IXGBE_WRITE_REG(hw, IXGBE_PFVFSPOOF(j), pfvfspoof);
 
-	/* If not enabling anti-spoofing then done */
-	if (!enable)
-		return;
-
 	/*
 	 * The PF should be allowed to spoof so that it can support
-	 * emulation mode NICs.  Reset the bit assigned to the PF
+	 * emulation mode NICs.  Do not set the bits assigned to the PF
+	 */
+	pfvfspoof &= (1 << pf_target_shift) - 1;
+	IXGBE_WRITE_REG(hw, IXGBE_PFVFSPOOF(j), pfvfspoof);
+
+	/*
+	 * Remaining pools belong to the PF so they do not need to have
+	 * anti-spoofing enabled.
 	 */
-	pfvfspoof = IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(pf_target_reg));
-	pfvfspoof ^= (1 << pf_target_shift);
-	IXGBE_WRITE_REG(hw, IXGBE_PFVFSPOOF(pf_target_reg), pfvfspoof);
+	for (j++; j < IXGBE_PFVFSPOOF_REG_COUNT; j++)
+		IXGBE_WRITE_REG(hw, IXGBE_PFVFSPOOF(j), 0);
 }
 
 /**
-- 
1.7.10.4
