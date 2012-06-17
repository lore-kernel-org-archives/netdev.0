From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbe: Fix PHC loophole allowing misconfiguration of increment register
Date: Sun, 17 Jun 2012 02:29:00 -0700
Message-ID: <1339925340-26286-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51684 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753526Ab2FQJ3E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jun 2012 05:29:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes a potential hole when configuring the cycle counter used to
generate the nanosecond time clock. This clock is based off of the SYSTIME
registers along with the TIMINCA registers. The TIMINCA register determines
the increment to be added to the SYSTIME registers every DMA clock tick. This
register needs to be reconfigured whenever the link-speed changes. However,
the value calculated stays the same when link is down and when link is up.
Misconfiguration can occur if the link status changes due to a reset, which
causes the TIMINCA register to be reset. This reset puts the device in an
unstable state where the SYSTIME registers stop incrementing and the PTP
protocol does not function.

The solution is to double check the TIMINCA value and always reset the value
if the register is zero. This prevents a misconfiguration bug that halts the
PHC.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index ddc6a4d..dcebd12 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -708,6 +708,7 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 incval = 0;
+	u32 timinca = 0;
 	u32 shift = 0;
 	u32 cycle_speed;
 	unsigned long flags;
@@ -730,8 +731,16 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 		break;
 	}
 
-	/* Bail if the cycle speed didn't change */
-	if (adapter->cycle_speed == cycle_speed)
+	/*
+	 * grab the current TIMINCA value from the register so that it can be
+	 * double checked. If the register value has been cleared, it must be
+	 * reset to the correct value for generating a cyclecounter. If
+	 * TIMINCA is zero, the SYSTIME registers do not increment at all.
+	 */
+	timinca = IXGBE_READ_REG(hw, IXGBE_TIMINCA);
+
+	/* Bail if the cycle speed didn't change and TIMINCA is non-zero */
+	if (adapter->cycle_speed == cycle_speed && timinca)
 		return;
 
 	/* disable the SDP clock out */
-- 
1.7.10.2
