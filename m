From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 4/5] [E1000]: [VLAN] Turn off the HW vlan filter if promisc
Date: Fri, 11 Apr 2008 22:58:51 +0900
Message-ID: <20080411135851.GD8137@tp64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jeff@garzik.org, netdev@vger.kernel.org
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0708.google.com ([209.85.198.246]:16585 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758634AbYDKN7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:59:22 -0400
Received: by rv-out-0506.google.com with SMTP id k29so34748rvb.1
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 06:59:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the netdev goes into mode promiscuous, receive all of the packets on
the wire without HW filtering, those packets will be processed as type
PACKET_OTHERHOST.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/e1000/e1000_main.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 0991648..61965c2 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2495,7 +2495,7 @@ e1000_set_rx_mode(struct net_device *netdev)
 	struct e1000_hw *hw = &adapter->hw;
 	struct dev_addr_list *uc_ptr;
 	struct dev_addr_list *mc_ptr;
-	uint32_t rctl;
+	uint32_t rctl, ctrl;
 	uint32_t hash_value;
 	int i, rar_entries = E1000_RAR_ENTRIES;
 	int mta_reg_count = (hw->mac_type == e1000_ich8lan) ?
@@ -2512,13 +2512,19 @@ e1000_set_rx_mode(struct net_device *netdev)
 	/* Check for Promiscuous and All Multicast modes */
 
 	rctl = E1000_READ_REG(hw, RCTL);
+	ctrl = E1000_READ_REG(hw, CTRL);
 
 	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
-	} else if (netdev->flags & IFF_ALLMULTI) {
-		rctl |= E1000_RCTL_MPE;
+		rctl &= ~E1000_RCTL_VFE;
 	} else {
-		rctl &= ~E1000_RCTL_MPE;
+		if (ctrl & E1000_CTRL_VME &&
+		    adapter->hw.mac_type != e1000_ich8lan)
+			rctl |= E1000_RCTL_VFE;
+		if (netdev->flags & IFF_ALLMULTI)
+			rctl |= E1000_RCTL_MPE;
+		else
+			rctl &= ~E1000_RCTL_MPE;
 	}
 
 	uc_ptr = NULL;
@@ -5013,7 +5019,10 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		if (adapter->hw.mac_type != e1000_ich8lan) {
 			/* enable VLAN receive filtering */
 			rctl = E1000_READ_REG(&adapter->hw, RCTL);
-			rctl |= E1000_RCTL_VFE;
+			if (netdev->flags & IFF_PROMISC)
+				rctl &= ~E1000_RCTL_VFE;
+			else
+				rctl |= E1000_RCTL_VFE;
 			rctl &= ~E1000_RCTL_CFIEN;
 			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
 			e1000_update_mng_vlan(adapter);
-- 
1.5.4.3


