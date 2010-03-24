From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/2] ixgbevf: convert to use netdev_for_each_mc_addr
Date: Wed, 24 Mar 2010 01:58:20 -0700
Message-ID: <20100324085819.32706.384.stgit@localhost.localdomain>
References: <20100324085733.32706.70587.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:47509
	"EHLO qmta08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752464Ab0CXI6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 04:58:38 -0400
In-Reply-To: <20100324085733.32706.70587.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ixgbevf_main.c |   24 +-----------------------
 drivers/net/ixgbevf/vf.c           |   24 ++++++++++++------------
 drivers/net/ixgbevf/vf.h           |    4 ++--
 3 files changed, 15 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index d6cbd94..9aaebd3 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -1495,22 +1495,6 @@ static void ixgbevf_restore_vlan(struct ixgbevf_adapter *adapter)
 	}
 }
 
-static u8 *ixgbevf_addr_list_itr(struct ixgbe_hw *hw, u8 **mc_addr_ptr,
-				 u32 *vmdq)
-{
-	struct dev_mc_list *mc_ptr;
-	u8 *addr = *mc_addr_ptr;
-	*vmdq = 0;
-
-	mc_ptr = container_of(addr, struct dev_mc_list, dmi_addr[0]);
-	if (mc_ptr->next)
-		*mc_addr_ptr = mc_ptr->next->dmi_addr;
-	else
-		*mc_addr_ptr = NULL;
-
-	return addr;
-}
-
 /**
  * ixgbevf_set_rx_mode - Multicast set
  * @netdev: network interface device structure
@@ -1523,16 +1507,10 @@ static void ixgbevf_set_rx_mode(struct net_device *netdev)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	u8 *addr_list = NULL;
-	int addr_count = 0;
 
 	/* reprogram multicast list */
-	addr_count = netdev_mc_count(netdev);
-	if (addr_count)
-		addr_list = netdev->mc_list->dmi_addr;
 	if (hw->mac.ops.update_mc_addr_list)
-		hw->mac.ops.update_mc_addr_list(hw, addr_list, addr_count,
-						ixgbevf_addr_list_itr);
+		hw->mac.ops.update_mc_addr_list(hw, netdev);
 }
 
 static void ixgbevf_napi_enable_all(struct ixgbevf_adapter *adapter)
diff --git a/drivers/net/ixgbevf/vf.c b/drivers/net/ixgbevf/vf.c
index 4b5dec0..f457c52 100644
--- a/drivers/net/ixgbevf/vf.c
+++ b/drivers/net/ixgbevf/vf.c
@@ -252,22 +252,18 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 /**
  *  ixgbevf_update_mc_addr_list_vf - Update Multicast addresses
  *  @hw: pointer to the HW structure
- *  @mc_addr_list: array of multicast addresses to program
- *  @mc_addr_count: number of multicast addresses to program
- *  @next: caller supplied function to return next address in list
+ *  @netdev: pointer to net device structure
  *
  *  Updates the Multicast Table Array.
  **/
-static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw, u8 *mc_addr_list,
-					u32 mc_addr_count,
-					ixgbe_mc_addr_itr next)
+static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
+					  struct net_device *netdev)
 {
+	struct dev_addr_list *dmi;
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
 	u16 *vector_list = (u16 *)&msgbuf[1];
-	u32 vector;
 	u32 cnt, i;
-	u32 vmdq;
 
 	/* Each entry in the list uses 1 16 bit word.  We have 30
 	 * 16 bit words available in our HW msg buffer (minus 1 for the
@@ -278,13 +274,17 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw, u8 *mc_addr_list,
 	 * addresses except for in large enterprise network environments.
 	 */
 
-	cnt = (mc_addr_count > 30) ? 30 : mc_addr_count;
+	cnt = netdev_mc_count(netdev);
+	if (cnt > 30)
+		cnt = 30;
 	msgbuf[0] = IXGBE_VF_SET_MULTICAST;
 	msgbuf[0] |= cnt << IXGBE_VT_MSGINFO_SHIFT;
 
-	for (i = 0; i < cnt; i++) {
-		vector = ixgbevf_mta_vector(hw, next(hw, &mc_addr_list, &vmdq));
-		vector_list[i] = vector;
+	i = 0;
+	netdev_for_each_mc_addr(dmi, netdev) {
+		if (i == cnt)
+			break;
+		vector_list[i++] = ixgbevf_mta_vector(hw, dmi->dmi_addr);
 	}
 
 	mbx->ops.write_posted(hw, msgbuf, IXGBE_VFMAILBOX_SIZE);
diff --git a/drivers/net/ixgbevf/vf.h b/drivers/net/ixgbevf/vf.h
index 1f31b05..94b750b 100644
--- a/drivers/net/ixgbevf/vf.h
+++ b/drivers/net/ixgbevf/vf.h
@@ -32,6 +32,7 @@
 #include <linux/delay.h>
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
+#include <linux/netdevice.h>
 
 #include "defines.h"
 #include "regs.h"
@@ -62,8 +63,7 @@ struct ixgbe_mac_operations {
 	/* RAR, Multicast, VLAN */
 	s32 (*set_rar)(struct ixgbe_hw *, u32, u8 *, u32);
 	s32 (*init_rx_addrs)(struct ixgbe_hw *);
-	s32 (*update_mc_addr_list)(struct ixgbe_hw *, u8 *, u32,
-				   ixgbe_mc_addr_itr);
+	s32 (*update_mc_addr_list)(struct ixgbe_hw *, struct net_device *);
 	s32 (*enable_mc)(struct ixgbe_hw *);
 	s32 (*disable_mc)(struct ixgbe_hw *);
 	s32 (*clear_vfta)(struct ixgbe_hw *);

