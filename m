From: Patrick McHardy <kaber@trash.net>
Subject: [SKY2]: Fix VLAN unregistration
Date: Sun, 27 May 2007 20:44:04 +0200
Message-ID: <4659D174.70301@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060002040702000706000504"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56194 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbXE0SoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 14:44:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060002040702000706000504
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix sky2 disabling VLAN completely when the first vid is unregistered.

For some reason the VLAN code insists on the driver providing a
vlan_rx_kill_vid function even if only NETIF_F_HW_VLAN_RX and not
NETIF_F_HW_VLAN_FILTER is set, so this patch keeps an empty
function. This seems to be a bug though, vlan_rx_add_vid is only
required with NETIF_F_HW_VLAN_FILTER. Ben?


--------------060002040702000706000504
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[SKY2]: Fix VLAN unregistration

sky2 disables VLAN completely when the first VID is unregistered. It
should instead disable VLAN when the group is unregistered by calling
sky2_vlan_rx_register with grp = NULL.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 62d7f463e185a0b65915110d25d8c4c732e67c0a
tree dc6efd2d80b927bb45e0b33b33a7b5174d1bf05a
parent add81ec9b23f1fbe973093d5999a3d70e9d4c48b
author Patrick McHardy <kaber@trash.net> Sun, 27 May 2007 20:39:09 +0200
committer Patrick McHardy <kaber@trash.net> Sun, 27 May 2007 20:39:09 +0200

 drivers/net/sky2.c |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 832fd69..c973def 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1050,8 +1050,17 @@ static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_group *grp
 
 	netif_tx_lock_bh(dev);
 
-	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), RX_VLAN_STRIP_ON);
-	sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_VLAN_TAG_ON);
+	if (grp) {
+		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
+			     RX_VLAN_STRIP_ON);
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_VLAN_TAG_ON);
+	} else {
+		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
+			     RX_VLAN_STRIP_OFF);
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_VLAN_TAG_OFF);
+	}
 	sky2->vlgrp = grp;
 
 	netif_tx_unlock_bh(dev);
@@ -1059,17 +1068,7 @@ static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_group *grp
 
 static void sky2_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
-	struct sky2_port *sky2 = netdev_priv(dev);
-	struct sky2_hw *hw = sky2->hw;
-	u16 port = sky2->port;
-
-	netif_tx_lock_bh(dev);
-
-	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), RX_VLAN_STRIP_OFF);
-	sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_VLAN_TAG_OFF);
-	vlan_group_set_device(sky2->vlgrp, vid, NULL);
-
-	netif_tx_unlock_bh(dev);
+	return;
 }
 #endif
 

--------------060002040702000706000504--
