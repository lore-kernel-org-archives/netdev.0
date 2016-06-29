From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] e1000e: prevent division by zero if TIMINCA is zero
Date: Wed, 29 Jun 2016 14:32:51 -0700
Message-ID: <1467235982-55437-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58211 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751550AbcF2VdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 17:33:05 -0400
In-Reply-To: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Vlasenko <dvlasenk@redhat.com>

Users report that under VMWare, er32(TIMINCA) returns zero.
This causes division by zero at init time as follows:

 ==>       incvalue = er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK;
           for (i = 0; i < E1000_MAX_82574_SYSTIM_REREADS; i++) {
                   /* latch SYSTIMH on read of SYSTIML */
                   systim_next = (cycle_t)er32(SYSTIML);
                   systim_next |= (cycle_t)er32(SYSTIMH) << 32;

                   time_delta = systim_next - systim;
                   temp = time_delta;
 ====>             rem = do_div(temp, incvalue);

This change makes kernel survive this, and users report that
NIC does work after this change.

Since on real hardware incvalue is never zero, this should not affect
real hardware use case.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 75e6089..9d5bab8 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4352,7 +4352,8 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 
 			time_delta = systim_next - systim;
 			temp = time_delta;
-			rem = do_div(temp, incvalue);
+			/* VMWare users have seen incvalue of zero, don't div / 0 */
+			rem = incvalue ? do_div(temp, incvalue) : (time_delta != 0);
 
 			systim = systim_next;
 
-- 
2.5.5
