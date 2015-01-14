From: Bhavesh Davda <bhavesh@vmware.com>
Subject: [PATCH] e1000e: Fix 82574/82583 TimeSync errata handling for SYSTIM read
Date: Wed, 14 Jan 2015 15:30:52 -0800
Message-ID: <1421278252-13622-1-git-send-email-bhavesh@vmware.com>
Cc: nithin@vmware.com, ninad@vmware.com, gyang@vmware.com,
	smurali@vmware.com, pv-drivers@vmware.com,
	Bhavesh Davda <bhavesh@vmware.com>
To: linux.nics@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:34919 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752950AbbANXbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 18:31:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In emulated 82574 vNICs, TIMINCA might read as '0', so this change prevents a
divide-by-zero error.

Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
Acked-by: Nithin Raju <nithin@vmware.com>
Acked-by: Ninad Ghodke <ninad@vmware.com>
Reviewed-by: Guolin Yang <gyang@vmware.com>
Reviewed-by: Srividya Murali <smurali@vmware.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e14fd85..a4727e3 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4141,6 +4141,8 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 		 * rate and is a multiple of incvalue
 		 */
 		incvalue = er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK;
+		if (incvalue == 0)
+			goto out;
 		for (i = 0; i < E1000_MAX_82574_SYSTIM_REREADS; i++) {
 			/* latch SYSTIMH on read of SYSTIML */
 			systim_next = (cycle_t)er32(SYSTIML);
@@ -4157,6 +4159,7 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 				break;
 		}
 	}
+out:
 	return systim;
 }
 
-- 
2.3.0.rc0
