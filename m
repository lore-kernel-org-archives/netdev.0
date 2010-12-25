From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 06/15] igb: Fix overwrite of the VF's flags
Date: Fri, 24 Dec 2010 22:06:05 -0800
Message-ID: <1293257174-15498-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204Ab0LYGG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:06:59 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The vf flags were being overwritten causing the flag that indicates
that the PF has set the VF MAC address to get cleared.  This would
allow the VF to override the MAC address assigned by the Host VMM
using the ip link set command.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 62348fc..be426a4 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1654,7 +1654,7 @@ void igb_reset(struct igb_adapter *adapter)
 	if (adapter->vfs_allocated_count) {
 		int i;
 		for (i = 0 ; i < adapter->vfs_allocated_count; i++)
-			adapter->vf_data[i].flags = 0;
+			adapter->vf_data[i].flags &= IGB_VF_FLAG_PF_SET_MAC;
 
 		/* ping all the active vfs to let them know we are going down */
 		igb_ping_all_vfs(adapter);
@@ -4971,8 +4971,8 @@ static int igb_set_vf_vlan(struct igb_adapter *adapter, u32 *msgbuf, u32 vf)
 
 static inline void igb_vf_reset(struct igb_adapter *adapter, u32 vf)
 {
-	/* clear flags */
-	adapter->vf_data[vf].flags &= ~(IGB_VF_FLAG_PF_SET_MAC);
+	/* clear flags - except flag that indicates PF has set the MAC */
+	adapter->vf_data[vf].flags &= IGB_VF_FLAG_PF_SET_MAC;
 	adapter->vf_data[vf].last_nack = jiffies;
 
 	/* reset offloads to defaults */
@@ -5026,7 +5026,7 @@ static void igb_vf_reset_msg(struct igb_adapter *adapter, u32 vf)
 	reg = rd32(E1000_VFRE);
 	wr32(E1000_VFRE, reg | (1 << vf));
 
-	adapter->vf_data[vf].flags = IGB_VF_FLAG_CTS;
+	adapter->vf_data[vf].flags |= IGB_VF_FLAG_CTS;
 
 	/* reply to reset with ack and vf mac address */
 	msgbuf[0] = E1000_VF_RESET | E1000_VT_MSGTYPE_ACK;
-- 
1.7.3.4

