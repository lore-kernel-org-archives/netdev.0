From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 12/15] ixgbe: Warn on VF attempt to override Administratively set MAC/VLAN
Date: Fri, 24 Dec 2010 22:06:11 -0800
Message-ID: <1293257174-15498-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754Ab0LYGHL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:07:11 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Print warnings to the system log when the VF attempts to override
MAC/VLAN settings that were configured by the VMM Host administrator
using the ip link set commands.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_sriov.c |   40 ++++++++++++++++++++++++++++----------
 1 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index 6e3e94b..e01d0db 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -227,6 +227,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	int entries;
 	u16 *hash_list;
 	int add, vid;
+	u8 *new_mac;
 
 	retval = ixgbe_read_mbx(hw, msgbuf, mbx_size, vf);
 
@@ -244,15 +245,22 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 
 	if (msgbuf[0] == IXGBE_VF_RESET) {
 		unsigned char *vf_mac = adapter->vfinfo[vf].vf_mac_addresses;
-		u8 *addr = (u8 *)(&msgbuf[1]);
+		new_mac = (u8 *)(&msgbuf[1]);
 		e_info(probe, "VF Reset msg received from vf %d\n", vf);
 		adapter->vfinfo[vf].clear_to_send = false;
 		ixgbe_vf_reset_msg(adapter, vf);
 		adapter->vfinfo[vf].clear_to_send = true;
 
+		if (is_valid_ether_addr(new_mac) &&
+		    !adapter->vfinfo[vf].pf_set_mac)
+			ixgbe_set_vf_mac(adapter, vf, vf_mac);
+		else
+			ixgbe_set_vf_mac(adapter,
+				 vf, adapter->vfinfo[vf].vf_mac_addresses);
+
 		/* reply to reset with ack and vf mac address */
 		msgbuf[0] = IXGBE_VF_RESET | IXGBE_VT_MSGTYPE_ACK;
-		memcpy(addr, vf_mac, IXGBE_ETH_LENGTH_OF_ADDRESS);
+		memcpy(new_mac, vf_mac, IXGBE_ETH_LENGTH_OF_ADDRESS);
 		/*
 		 * Piggyback the multicast filter type so VF can compute the
 		 * correct vectors
@@ -271,14 +279,16 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 
 	switch ((msgbuf[0] & 0xFFFF)) {
 	case IXGBE_VF_SET_MAC_ADDR:
-		{
-			u8 *new_mac = ((u8 *)(&msgbuf[1]));
-			if (is_valid_ether_addr(new_mac) &&
-			    !adapter->vfinfo[vf].pf_set_mac)
-				ixgbe_set_vf_mac(adapter, vf, new_mac);
-			else
-				ixgbe_set_vf_mac(adapter,
-				  vf, adapter->vfinfo[vf].vf_mac_addresses);
+		new_mac = ((u8 *)(&msgbuf[1]));
+		if (is_valid_ether_addr(new_mac) &&
+		    !adapter->vfinfo[vf].pf_set_mac) {
+			ixgbe_set_vf_mac(adapter, vf, new_mac);
+		} else if (memcmp(adapter->vfinfo[vf].vf_mac_addresses,
+				  new_mac, ETH_ALEN)) {
+			e_warn(drv, "VF %d attempted to override "
+			       "administratively set MAC address\nReload "
+			       "the VF driver to resume operations\n", vf);
+			retval = -1;
 		}
 		break;
 	case IXGBE_VF_SET_MULTICAST:
@@ -295,7 +305,15 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 		add = (msgbuf[0] & IXGBE_VT_MSGINFO_MASK)
 		      >> IXGBE_VT_MSGINFO_SHIFT;
 		vid = (msgbuf[1] & IXGBE_VLVF_VLANID_MASK);
-		retval = ixgbe_set_vf_vlan(adapter, add, vid, vf);
+		if (adapter->vfinfo[vf].pf_vlan) {
+			e_warn(drv, "VF %d attempted to override "
+			       "administratively set VLAN configuration\n"
+			       "Reload the VF driver to resume operations\n",
+			       vf);
+			retval = -1;
+		} else {
+			retval = ixgbe_set_vf_vlan(adapter, add, vid, vf);
+		}
 		break;
 	default:
 		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
-- 
1.7.3.4

