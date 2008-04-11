From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 5/5] [E1000e]: [VLAN] Turn off the HW vlan filter if promisc
Date: Fri, 11 Apr 2008 22:59:31 +0900
Message-ID: <20080411135931.GE8137@tp64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jeff@garzik.org, netdev@vger.kernel.org
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:6906 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758869AbYDKN75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:59:57 -0400
Received: by wf-out-1314.google.com with SMTP id 28so499840wff.4
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 06:59:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the netdev goes into mode promiscuous, receive all of the packets on
the wire without HW filtering, those packets will be processed as type
PACKET_OTHERHOST.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/e1000e/netdev.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index fc5c63f..4445b93 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1492,7 +1492,10 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 		if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER) {
 			/* enable VLAN receive filtering */
 			rctl = er32(RCTL);
-			rctl |= E1000_RCTL_VFE;
+			if (netdev->flags & IFF_PROMISC)
+				rctl &= ~E1000_RCTL_VFE;
+			else
+				rctl |= E1000_RCTL_VFE;
 			rctl &= ~E1000_RCTL_CFIEN;
 			ew32(RCTL, rctl);
 			e1000_update_mng_vlan(adapter);
@@ -1889,20 +1892,26 @@ static void e1000_set_multi(struct net_device *netdev)
 	struct e1000_mac_info *mac = &hw->mac;
 	struct dev_mc_list *mc_ptr;
 	u8  *mta_list;
-	u32 rctl;
+	u32 rctl, ctrl;
 	int i;
 
 	/* Check for Promiscuous and All Multicast modes */
 
 	rctl = er32(RCTL);
+	ctrl = er32(CTRL);
 
 	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
-	} else if (netdev->flags & IFF_ALLMULTI) {
-		rctl |= E1000_RCTL_MPE;
-		rctl &= ~E1000_RCTL_UPE;
+		rctl &= ~E1000_RCTL_VFE;
 	} else {
-		rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
+		if (ctrl & E1000_CTRL_VME &&
+		    adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
+			rctl |= E1000_RCTL_VFE;
+		if (netdev->flags & IFF_ALLMULTI) {
+			rctl |= E1000_RCTL_MPE;
+			rctl &= ~E1000_RCTL_UPE;
+		} else
+			rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
 	}
 
 	ew32(RCTL, rctl);
-- 
1.5.4.3


