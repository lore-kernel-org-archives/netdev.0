From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 07/15] igb: Warn on attempt to override administratively set MAC/VLAN
Date: Fri, 24 Dec 2010 22:06:06 -0800
Message-ID: <1293257174-15498-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754Ab0LYGHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:07:01 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Print a warning message to the system log when the VF attempts to
override administratively set MAC/VLAN configuration.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_main.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index be426a4..c9aac7f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5105,7 +5105,14 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 
 	switch ((msgbuf[0] & 0xFFFF)) {
 	case E1000_VF_SET_MAC_ADDR:
-		retval = igb_set_vf_mac_addr(adapter, msgbuf, vf);
+		retval = -EINVAL;
+		if (!(vf_data->flags & IGB_VF_FLAG_PF_SET_MAC))
+			retval = igb_set_vf_mac_addr(adapter, msgbuf, vf);
+		else
+			dev_warn(&pdev->dev,
+				 "VF %d attempted to override administratively "
+				 "set MAC address\nReload the VF driver to "
+				 "resume operations\n", vf);
 		break;
 	case E1000_VF_SET_PROMISC:
 		retval = igb_set_vf_promisc(adapter, msgbuf, vf);
@@ -5117,8 +5124,12 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 		retval = igb_set_vf_rlpml(adapter, msgbuf[1], vf);
 		break;
 	case E1000_VF_SET_VLAN:
-		if (adapter->vf_data[vf].pf_vlan)
-			retval = -1;
+		retval = -1;
+		if (vf_data->pf_vlan)
+			dev_warn(&pdev->dev,
+				 "VF %d attempted to override administratively "
+				 "set VLAN tag\nReload the VF driver to "
+				 "resume operations\n", vf);
 		else
 			retval = igb_set_vf_vlan(adapter, msgbuf, vf);
 		break;
-- 
1.7.3.4

