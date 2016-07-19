From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] ixgbevf: avoid checking hang when
	performing hardware reset
Date: Wed, 20 Jul 2016 07:23:42 +0800
Message-ID: <1468970622-1882-2-git-send-email-zyjzyj2000@gmail.com>
References: <1468970622-1882-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, donald.c.skidmore@intel.com,
	intel-wired-lan@lists.osuosl.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1468970622-1882-1-git-send-email-zyjzyj2000@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

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


------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity planning
reports.http://sdm.link/zohodev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
