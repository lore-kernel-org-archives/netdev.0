From: John Crispin <blogic@openwrt.org>
Subject: [RFC 2/8] net-next: phy: dont auto handle carrier state when multiple phys are attached
Date: Sun, 22 Nov 2015 09:40:52 +0100
Message-ID: <1448181658-38111-2-git-send-email-blogic@openwrt.org>
References: <1448181658-38111-1-git-send-email-blogic@openwrt.org>
Cc: netdev@vger.kernel.org, Michael Lee <igvtee@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	=?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
	<steven.liu@mediatek.com>,
	=?UTF-8?q?Fred=20Chang=20=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
	<Fred.Chang@mediatek.com>, John Crispin <blogic@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:46170 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077AbbKVIlM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Nov 2015 03:41:12 -0500
In-Reply-To: <1448181658-38111-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A network core might have more than one phy attached to its cpu port via a
switch. The current code will set the carrier state to on/off when ever a
cable is plugged into any of these ports.

The patch adds a new bool that allows the driver to tell the phy_device to not
set the carrier state. Instead the driver can manually handle the carrier
state.

Signed-off-by: John Crispin <blogic@openwrt.org>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Michael Lee <igvtee@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c |    9 ++++++---
 include/linux/phy.h   |    1 +
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 48ce6ef..bd2df40 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -843,7 +843,8 @@ void phy_state_machine(struct work_struct *work)
 		/* If the link is down, give up on negotiation for now */
 		if (!phydev->link) {
 			phydev->state = PHY_NOLINK;
-			netif_carrier_off(phydev->attached_dev);
+			if (!phydev->no_auto_carrier_off)
+				netif_carrier_off(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
 			break;
 		}
@@ -926,7 +927,8 @@ void phy_state_machine(struct work_struct *work)
 			netif_carrier_on(phydev->attached_dev);
 		} else {
 			phydev->state = PHY_NOLINK;
-			netif_carrier_off(phydev->attached_dev);
+			if (!phydev->no_auto_carrier_off)
+				netif_carrier_off(phydev->attached_dev);
 		}
 
 		phydev->adjust_link(phydev->attached_dev);
@@ -938,7 +940,8 @@ void phy_state_machine(struct work_struct *work)
 	case PHY_HALTED:
 		if (phydev->link) {
 			phydev->link = 0;
-			netif_carrier_off(phydev->attached_dev);
+			if (!phydev->no_auto_carrier_off)
+				netif_carrier_off(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
 			do_suspend = true;
 		}
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 05fde31..276ab8a 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -377,6 +377,7 @@ struct phy_device {
 	bool is_pseudo_fixed_link;
 	bool has_fixups;
 	bool suspended;
+	bool no_auto_carrier_off;
 
 	enum phy_state state;
 
-- 
1.7.10.4
