From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] ixgbevf: avoid checking hang when performing hardware reset
Date: Tue, 19 Jul 2016 21:31:53 +0800
Message-ID: <1468935113-3051-2-git-send-email-zyjzyj2000@gmail.com>
References: <F6FB0E698C9B3143BDF729DF2228664696ACAA19@ORSMSX116.amr.corp.intel.com>
 <1468935113-3051-1-git-send-email-zyjzyj2000@gmail.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, donald.c.skidmore@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [123.119.179.77] ([123.119.179.77]:37236 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752651AbcGTC4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 22:56:55 -0400
In-Reply-To: <1468935113-3051-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

When performing hardware reset, it is not necessary to check hang.
Or else, the call trace will appear.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 5 +++--
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 5 +++++
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index d5944c3..60fc63b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -446,6 +446,7 @@ enum ixbgevf_state_t {
 	__IXGBEVF_SERVICE_INITED,
 	__IXGBEVF_RESET_REQUESTED,
 	__IXGBEVF_QUEUE_RESET_REQUESTED,
+	__IXGBEVF_HW_RESETTING,
 };
 
 enum ixgbevf_boards {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index acc2401..530005b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2795,9 +2795,10 @@ static void ixgbevf_check_hang_subtask(struct ixgbevf_adapter *adapter)
 	u32 eics = 0;
 	int i;
 
-	/* If we're down or resetting, just bail */
+	/* If we're down, resetting or hw resetting, just bail */
 	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
-	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
+	    test_bit(__IXGBEVF_RESETTING, &adapter->state) ||
+	    test_bit(__IXGBEVF_HW_RESETTING, &adapter->state))
 		return;
 
 	/* Force detection of hung controller */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index e670d3b..4ec4484 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -80,6 +80,9 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
 	s32 ret_val = IXGBE_ERR_INVALID_MAC_ADDR;
 	u32 msgbuf[IXGBE_VF_PERMADDR_MSG_LEN];
 	u8 *addr = (u8 *)(&msgbuf[1]);
+	struct ixgbevf_adapter *adapter = hw->back;
+
+	set_bit(__IXGBEVF_HW_RESETTING, &adapter->state);
 
 	/* Call adapter stop to disable tx/rx and clear interrupts */
 	hw->mac.ops.stop_adapter(hw);
@@ -128,6 +131,8 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
 
 	hw->mac.mc_filter_type = msgbuf[IXGBE_VF_MC_TYPE_WORD];
 
+	clear_bit(__IXGBEVF_HW_RESETTING, &adapter->state);
+
 	return 0;
 }
 
-- 
2.7.4
