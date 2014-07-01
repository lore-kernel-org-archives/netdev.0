From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] ixgbe: change PTP NSECS_PER_SEC to IXGBE_PTP_PPS_HALF_SECOND
Date: Tue,  1 Jul 2014 04:35:11 -0700
Message-ID: <1404214511-26868-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7368 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756473AbaGALfV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:35:21 -0400
In-Reply-To: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The PPS signal is not correct, as it generates a one half HZ clock
signal, as it only generates one level change per second. To generate a
full clock, we need two level changes per second. Also, change the name
of the #define, in order to prevent confusion between it and
NSEC_PER_SEC which is not guaranteed to be a 64bit value.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 68f87ec..5fd4b52 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -98,9 +98,11 @@
 #define IXGBE_OVERFLOW_PERIOD    (HZ * 30)
 #define IXGBE_PTP_TX_TIMEOUT     (HZ * 15)
 
-#ifndef NSECS_PER_SEC
-#define NSECS_PER_SEC 1000000000ULL
-#endif
+/* half of a one second clock period, for use with PPS signal. We have to use
+ * this instead of something pre-defined like IXGBE_PTP_PPS_HALF_SECOND, in
+ * order to force at least 64bits of precision for shifting
+ */
+#define IXGBE_PTP_PPS_HALF_SECOND 500000000ULL
 
 /**
  * ixgbe_ptp_setup_sdp
@@ -146,8 +148,8 @@ static void ixgbe_ptp_setup_sdp(struct ixgbe_adapter *adapter)
 			  IXGBE_TSAUXC_SDP0_INT);
 
 		/* clock period (or pulse length) */
-		clktiml = (u32)(NSECS_PER_SEC << shift);
-		clktimh = (u32)((NSECS_PER_SEC << shift) >> 32);
+		clktiml = (u32)(IXGBE_PTP_PPS_HALF_SECOND << shift);
+		clktimh = (u32)((IXGBE_PTP_PPS_HALF_SECOND << shift) >> 32);
 
 		/*
 		 * Account for the cyclecounter wrap-around value by
@@ -158,8 +160,8 @@ static void ixgbe_ptp_setup_sdp(struct ixgbe_adapter *adapter)
 		clock_edge |= (u64)IXGBE_READ_REG(hw, IXGBE_SYSTIMH) << 32;
 		ns = timecounter_cyc2time(&adapter->tc, clock_edge);
 
-		div_u64_rem(ns, NSECS_PER_SEC, &rem);
-		clock_edge += ((NSECS_PER_SEC - (u64)rem) << shift);
+		div_u64_rem(ns, IXGBE_PTP_PPS_HALF_SECOND, &rem);
+		clock_edge += ((IXGBE_PTP_PPS_HALF_SECOND - (u64)rem) << shift);
 
 		/* specify the initial clock start time */
 		trgttiml = (u32)clock_edge;
-- 
1.9.3
