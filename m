From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] e1000e: fix logical error in flush_desc_rings
Date: Wed,  3 Jun 2015 04:27:51 -0700
Message-ID: <1433330876-2658-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:6485 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754517AbbFCL2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 07:28:01 -0400
In-Reply-To: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

The condition under which the flush should occur was reversed.  The fix
should be applied before any HW reset (unless followed by bus reset)
and before any power state transition from D0.

If E1000_FEXTNVM7_NEED_DESCRING_FLUSH bit is set in FEXTNVM7 and TDLEN > 0
the Tx ring should be flushed. (fixes ~95% of the hang states).
If the E1000_FEXTNVM7_NEED_DESCRING_FLUSH did not clear, we should also
flush the RX ring. Bug was caught by Alexander Duyck during a code review
when examining this fix.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 14ee6a6..b2d77a5 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3878,7 +3878,7 @@ static void e1000_flush_desc_rings(struct e1000_adapter *adapter)
 	/* do nothing if we're not in faulty state, or if the queue is empty */
 	tdlen = er32(TDLEN(0));
 	hang_state = er32(FEXTNVM7);
-	if ((hang_state & E1000_FEXTNVM7_NEED_DESCRING_FLUSH) || tdlen)
+	if (!(hang_state & E1000_FEXTNVM7_NEED_DESCRING_FLUSH) || !tdlen)
 		return;
 	e1000_flush_tx_ring(adapter);
 	/* recheck, maybe the fault is caused by the rx ring */
-- 
2.1.0
