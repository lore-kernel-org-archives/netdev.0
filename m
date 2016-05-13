From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] e1000e: e1000e_cyclecounter_read(): fix er32(SYSTIML) overflow check
Date: Fri, 13 May 2016 16:43:47 -0700
Message-ID: <1463183035-31888-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:49411 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932146AbcEMXn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 19:43:59 -0400
In-Reply-To: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Vlasenko <dvlasenk@redhat.com>

If two consecutive reads of the counter are the same, it is also
not an overflow.  "systimel_1 < systimel_2" should be
"systimel_1 <= systimel_2".

Before the patch, we could perform an *erroneous* correction:

Let's say that systimel_1 == systimel_2 == 0xffffffff.
"systimel_1 < systimel_2" is false, we think it's an overflow,
we read "systimeh = er32(SYSTIMH)" which meanwhile had incremented,
and use "(systimeh << 32) + systimel_2" value which is 2^32 too large.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: intel-wired-lan@lists.osuosl.org
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 4969f64..02c64bc 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4287,7 +4287,7 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	systimeh = er32(SYSTIMH);
 	systimel_2 = er32(SYSTIML);
 	/* Check for overflow. If there was no overflow, use the values */
-	if (systimel_1 < systimel_2) {
+	if (systimel_1 <= systimel_2) {
 		systim = (cycle_t)systimel_1;
 		systim |= (cycle_t)systimeh << 32;
 	} else {
-- 
2.5.5
