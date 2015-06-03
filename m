From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] e1000e: remove call to do_div and sign mismatch warning
Date: Wed,  3 Jun 2015 04:27:50 -0700
Message-ID: <1433330876-2658-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24080 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505AbbFCL2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 07:28:01 -0400
In-Reply-To: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

Fixes a warning that was reported by Yanjiang Jin
<yanjiang.jin@windriver.com> by implementing the solution suggested by
Alexander Duyck <alexander.h.duyck@redhat.com>.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index e18443a..d9f7b93 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1014,7 +1014,6 @@ static s32 e1000_platform_pm_pch_lpt(struct e1000_hw *hw, bool link)
 		u16 speed, duplex, scale = 0;
 		u16 max_snoop, max_nosnoop;
 		u16 max_ltr_enc;	/* max LTR latency encoded */
-		s64 lat_ns;	/* latency (ns) */
 		u64 value;
 		u32 rxa;
 
@@ -1040,14 +1039,10 @@ static s32 e1000_platform_pm_pch_lpt(struct e1000_hw *hw, bool link)
 		 * 2^25*(2^10-1) ns.  The scale is encoded as 0=2^0ns,
 		 * 1=2^5ns, 2=2^10ns,...5=2^25ns.
 		 */
-		lat_ns = ((s64)rxa * 1024 -
-			  (2 * (s64)hw->adapter->max_frame_size)) * 8 * 1000;
-		if (lat_ns < 0) {
-			value = 0;
-		} else {
-			value = lat_ns;
-			do_div(value, speed);
-		}
+		rxa *= 512;
+		value = (rxa > hw->adapter->max_frame_size) ?
+			(rxa - hw->adapter->max_frame_size) * (16000 / speed) :
+			0;
 
 		while (value > PCI_LTR_VALUE_MASK) {
 			scale++;
-- 
2.1.0
