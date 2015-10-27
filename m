From: Stefan Bader <stefan.bader@canonical.com>
Subject: Stable-4.2 inclusion request for e1000e fix
Date: Tue, 27 Oct 2015 17:28:01 +0100
Message-ID: <1445963281-13704-1-git-send-email-stefan.bader@canonical.com>
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	raanan.avargil@intel.com
To: netdev@vger.kernel.org, kernel-team@lists.ubuntu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:60117 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932466AbbJ0Q2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 12:28:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was attempted to get into 4.2 before release but did not seem to
be successful[1]. But was now reported to us and verified[2] that adding
this prevents issues when the NIC is not connected.

Could the patch below be added to the stable queue for 4.2. Thanks.

-Stefan


[1] http://lkml.iu.edu/hypermail/linux/kernel/1508.2/01174.html
[2] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1509929

--

>From 37b12910dd11d9ab969f2c310dc9160b7f3e3405 Mon Sep 17 00:00:00 2001
From: Raanan Avargil <raanan.avargil@intel.com>
Date: Sun, 19 Jul 2015 16:33:20 +0300
Subject: [PATCH] e1000e: Fix tight loop implementation of systime read
 algorithm

Change the algorithm. Read systimel twice and check for overflow.
If there was no overflow, use the first value.
If there was an overflow, read systimeh again and use the second
systimel value.

Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
(cherry-picked from commit 37b12910dd11d9ab969f2c310dc9160b7f3e3405)
Signed-off-by: Stefan Bader <stefan.bader@canonical.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 31 ++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 24b7269..96a8166 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4280,18 +4280,29 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	struct e1000_adapter *adapter = container_of(cc, struct e1000_adapter,
 						     cc);
 	struct e1000_hw *hw = &adapter->hw;
+	u32 systimel_1, systimel_2, systimeh;
 	cycle_t systim, systim_next;
-	/* SYSTIMH latching upon SYSTIML read does not work well. To fix that
-	 * we don't want to allow overflow of SYSTIML and a change to SYSTIMH
-	 * to occur between reads, so if we read a vale close to overflow, we
-	 * wait for overflow to occur and read both registers when its safe.
+	/* SYSTIMH latching upon SYSTIML read does not work well.
+	 * This means that if SYSTIML overflows after we read it but before
+	 * we read SYSTIMH, the value of SYSTIMH has been incremented and we
+	 * will experience a huge non linear increment in the systime value
+	 * to fix that we test for overflow and if true, we re-read systime.
 	 */
-	u32 systim_overflow_latch_fix = 0x3FFFFFFF;
-
-	do {
-		systim = (cycle_t)er32(SYSTIML);
-	} while (systim > systim_overflow_latch_fix);
-	systim |= (cycle_t)er32(SYSTIMH) << 32;
+	systimel_1 = er32(SYSTIML);
+	systimeh = er32(SYSTIMH);
+	systimel_2 = er32(SYSTIML);
+	/* Check for overflow. If there was no overflow, use the values */
+	if (systimel_1 < systimel_2) {
+		systim = (cycle_t)systimel_1;
+		systim |= (cycle_t)systimeh << 32;
+	} else {
+		/* There was an overflow, read again SYSTIMH, and use
+		 * systimel_2
+		 */
+		systimeh = er32(SYSTIMH);
+		systim = (cycle_t)systimel_2;
+		systim |= (cycle_t)systimeh << 32;
+	}
 
 	if ((hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82583)) {
 		u64 incvalue, time_delta, rem, temp;
-- 
1.9.1
