From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] e1000e: fix call to do_div() to use u64 arg
Date: Sat,  2 May 2015 03:42:32 -0700
Message-ID: <1430563358-113833-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Yanjiang Jin <yanjiang.jin@windriver.com>,
	Yanir Lubetkin <yanirx.lubetkin@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43420 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985AbbEBKmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2015 06:42:52 -0400
In-Reply-To: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were using s64 for lat_ns (latency nano-second value) since in
our calculations a negative value could be a resultant.  For negative
values, we then assign lat_ns to be zero, so the value passed to
do_div() was never negative, but do_div() expects the argument type
to be u64, so do a cast to resolve a compile warning seen on
PowerPC.

CC: Yanjiang Jin <yanjiang.jin@windriver.com>
CC: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Reported-by: Yanjiang Jin <yanjiang.jin@windriver.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index e2498db..e18443a 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1015,7 +1015,7 @@ static s32 e1000_platform_pm_pch_lpt(struct e1000_hw *hw, bool link)
 		u16 max_snoop, max_nosnoop;
 		u16 max_ltr_enc;	/* max LTR latency encoded */
 		s64 lat_ns;	/* latency (ns) */
-		s64 value;
+		u64 value;
 		u32 rxa;
 
 		if (!hw->adapter->max_frame_size) {
@@ -1042,12 +1042,13 @@ static s32 e1000_platform_pm_pch_lpt(struct e1000_hw *hw, bool link)
 		 */
 		lat_ns = ((s64)rxa * 1024 -
 			  (2 * (s64)hw->adapter->max_frame_size)) * 8 * 1000;
-		if (lat_ns < 0)
-			lat_ns = 0;
-		else
-			do_div(lat_ns, speed);
+		if (lat_ns < 0) {
+			value = 0;
+		} else {
+			value = lat_ns;
+			do_div(value, speed);
+		}
 
-		value = lat_ns;
 		while (value > PCI_LTR_VALUE_MASK) {
 			scale++;
 			value = DIV_ROUND_UP(value, (1 << 5));
-- 
2.1.0
