From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 2/3] e1000e: 82571 Tx Data Corruption during Tx hang recovery
Date: Tue,  7 Aug 2012 01:04:16 -0700
Message-ID: <1344326657-9376-3-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1344326657-9376-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Tushar Dave <tushar.n.dave@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7381 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751887Ab2HGIFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 04:05:45 -0400
In-Reply-To: <1344326657-9376-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@intel.com>

A bus trace shows that while executing e1000e_down, TCTL is cleared except
for the PSP bit.  This occurs while in the middle of fetching a TSO packet
since the Tx packet buffer is full at that point. Before the device is
reset, the e1000_watchdog_task starts to run from the middle (it was
apparently pre-empted earlier, although that is not in the trace) and sets
TCTL.EN.  At that point, 82571 transmits the corrupted packet, apparently
because TCTL.MULR was cleared in the middle of fetching a packet, which is
forbidden.

Driver should just clear TCTL.EN in e1000_reset_hw_82571 instead of
clearing the entire register, so as not to change any settings in the
middle of fetching a packet.

Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 2a4ded2..080c890 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -999,7 +999,7 @@ static s32 e1000_set_d0_lplu_state_82571(struct e1000_hw *hw, bool active)
  **/
 static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 {
-	u32 ctrl, ctrl_ext, eecd;
+	u32 ctrl, ctrl_ext, eecd, tctl;
 	s32 ret_val;
 
 	/*
@@ -1014,7 +1014,9 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	ew32(IMC, 0xffffffff);
 
 	ew32(RCTL, 0);
-	ew32(TCTL, E1000_TCTL_PSP);
+	tctl = er32(TCTL);
+	tctl &= ~E1000_TCTL_EN;
+	ew32(TCTL, tctl);
 	e1e_flush();
 
 	usleep_range(10000, 20000);
-- 
1.7.11.2
