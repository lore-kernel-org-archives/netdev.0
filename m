From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] ixgbe: Move bridge mode from flag to variable
Date: Fri, 10 Apr 2015 00:53:13 -0700
Message-ID: <1428652398-10147-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:55251 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754221AbbDJHxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 03:53:22 -0400
In-Reply-To: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We are currently storing our BRIDGE_MODE as a bit in our adapter flags.
This patch will store the actual mode instead which minimizes obfuscation
and makes following patches for X550 simpler.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 33 +++++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  3 ++-
 3 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 7068e9c..ae5b8b2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -642,7 +642,6 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_RSS_FIELD_IPV4_UDP		(u32)(1 << 8)
 #define IXGBE_FLAG2_RSS_FIELD_IPV6_UDP		(u32)(1 << 9)
 #define IXGBE_FLAG2_PTP_PPS_ENABLED		(u32)(1 << 10)
-#define IXGBE_FLAG2_BRIDGE_MODE_VEB		(u32)(1 << 11)
 
 	/* Tx fast path data */
 	int num_tx_queues;
@@ -722,6 +721,8 @@ struct ixgbe_adapter {
 	u8 __iomem *io_addr; /* Mainly for iounmap use */
 	u32 wol;
 
+	u16 bridge_mode;
+
 	u16 eeprom_verh;
 	u16 eeprom_verl;
 	u16 eeprom_cap;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 395dc6b..aceb13c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3553,7 +3553,7 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset ^ 1), reg_offset - 1);
 	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), (~0) << vf_shift);
 	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset ^ 1), reg_offset - 1);
-	if (adapter->flags2 & IXGBE_FLAG2_BRIDGE_MODE_VEB)
+	if (adapter->bridge_mode == BRIDGE_MODE_VEB)
 		IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 
 	/* Map PF MAC address in RAR Entry 0 to first pool following VFs */
@@ -7886,7 +7886,6 @@ static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 
 	nla_for_each_nested(attr, br_spec, rem) {
 		__u16 mode;
-		u32 reg = 0;
 
 		if (nla_type(attr) != IFLA_BRIDGE_MODE)
 			continue;
@@ -7895,19 +7894,24 @@ static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 			return -EINVAL;
 
 		mode = nla_get_u16(attr);
-		if (mode == BRIDGE_MODE_VEPA) {
-			reg = 0;
-			adapter->flags2 &= ~IXGBE_FLAG2_BRIDGE_MODE_VEB;
-		} else if (mode == BRIDGE_MODE_VEB) {
-			reg = IXGBE_PFDTXGSWC_VT_LBEN;
-			adapter->flags2 |= IXGBE_FLAG2_BRIDGE_MODE_VEB;
-		} else
+		switch (mode) {
+		case BRIDGE_MODE_VEPA:
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_PFDTXGSWC, 0);
+			break;
+		case BRIDGE_MODE_VEB:
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_PFDTXGSWC,
+					IXGBE_PFDTXGSWC_VT_LBEN);
+			break;
+		default:
 			return -EINVAL;
+		}
 
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_PFDTXGSWC, reg);
+		adapter->bridge_mode = mode;
 
 		e_info(drv, "enabling bridge mode: %s\n",
 			mode == BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
+
+		break;
 	}
 
 	return 0;
@@ -7918,17 +7922,12 @@ static int ixgbe_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				    u32 filter_mask)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	u16 mode;
 
 	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
 		return 0;
 
-	if (adapter->flags2 & IXGBE_FLAG2_BRIDGE_MODE_VEB)
-		mode = BRIDGE_MODE_VEB;
-	else
-		mode = BRIDGE_MODE_VEPA;
-
-	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode, 0, 0);
+	return ndo_dflt_bridge_getlink(skb, pid, seq, dev,
+				       adapter->bridge_mode, 0, 0);
 }
 
 static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 09a291b..2d98ecd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -36,6 +36,7 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/ipv6.h>
+#include <linux/if_bridge.h>
 #ifdef NETIF_F_HW_VLAN_CTAG_TX
 #include <linux/if_vlan.h>
 #endif
@@ -79,7 +80,7 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 
 	/* Initialize default switching mode VEB */
 	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
-	adapter->flags2 |= IXGBE_FLAG2_BRIDGE_MODE_VEB;
+	adapter->bridge_mode = BRIDGE_MODE_VEB;
 
 	/* If call to enable VFs succeeded then allocate memory
 	 * for per VF control structures.
-- 
1.9.3
