From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH net-next] ixgbe: make macvlan on PF working
 when SRIOV is enabled
Date: Tue, 25 May 2010 09:55:09 -0700
Message-ID: <1274806509.18023.58.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com, gregory.v.rose@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When SRIOV is enabled, if we create macvlan on PF and load the VF driver in host 
domain, when macvlan/PF and VF interfaces are all up, the macvlan incoming network
traffics are directed to VF interface not PF interface. This patch has fixed this
issue.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
--- 
 drivers/net/ixgbe/ixgbe_common.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 1159d91..591dd19 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1271,6 +1271,7 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 {
 	u32 i;
 	u32 rar_entries = hw->mac.num_rar_entries;
+	struct ixgbe_adapter *adapter = hw->back;
 
 	/*
 	 * If the current mac address is valid, assume it is a software override
@@ -1288,15 +1289,18 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 		hw_dbg(hw, "Overriding MAC Address in RAR[0]\n");
 		hw_dbg(hw, " New MAC Addr =%pM\n", hw->mac.addr);
 
-		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
+		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, adapter->num_vfs,
+				    IXGBE_RAH_AV);
 	}
 	hw->addr_ctrl.overflow_promisc = 0;
 
-	hw->addr_ctrl.rar_used_count = 1;
+	/* reserve VFs receive address entries if any */
+	hw->addr_ctrl.rar_used_count = adapter->num_vfs + 1;
 
-	/* Zero out the other receive addresses. */
-	hw_dbg(hw, "Clearing RAR[1-%d]\n", rar_entries - 1);
-	for (i = 1; i < rar_entries; i++) {
+	/* Zero out the other receive addresses except VFs if any */
+	hw_dbg(hw, "Clearing RAR[%d-%d]\n",
+	       adapter->num_vfs + 1, rar_entries - 1);
+	for (i = adapter->num_vfs + 1; i < rar_entries; i++) {
 		IXGBE_WRITE_REG(hw, IXGBE_RAL(i), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_RAH(i), 0);
 	}
@@ -1368,18 +1372,20 @@ s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
 	u32 uc_addr_in_use;
 	u32 fctrl;
 	struct netdev_hw_addr *ha;
+	struct ixgbe_adapter *adapter = hw->back;
 
 	/*
 	 * Clear accounting of old secondary address list,
 	 * don't count RAR[0]
 	 */
-	uc_addr_in_use = hw->addr_ctrl.rar_used_count - 1;
+	uc_addr_in_use = hw->addr_ctrl.rar_used_count - 1 - adapter->num_vfs;
 	hw->addr_ctrl.rar_used_count -= uc_addr_in_use;
 	hw->addr_ctrl.overflow_promisc = 0;
 
-	/* Zero out the other receive addresses */
-	hw_dbg(hw, "Clearing RAR[1-%d]\n", uc_addr_in_use + 1);
-	for (i = 0; i < uc_addr_in_use; i++) {
+	/* Zero out the other receive addresses except VFs if any */
+	hw_dbg(hw, "Clearing RAR[%d-%d]\n",
+	       adapter->num_vfs + 1, uc_addr_in_use + adapter->num_vfs + 1);
+	for (i = adapter->num_vfs; i < uc_addr_in_use + adapter->num_vfs; i++) {
 		IXGBE_WRITE_REG(hw, IXGBE_RAL(1+i), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_RAH(1+i), 0);
 	}
@@ -1387,7 +1393,7 @@ s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
 	/* Add the new addresses */
 	netdev_for_each_uc_addr(ha, netdev) {
 		hw_dbg(hw, " Adding the secondary addresses:\n");
-		ixgbe_add_uc_addr(hw, ha->addr, 0);
+		ixgbe_add_uc_addr(hw, ha->addr, adapter->num_vfs);
 	}
 
 	if (hw->addr_ctrl.overflow_promisc) {




------------------------------------------------------------------------------

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
