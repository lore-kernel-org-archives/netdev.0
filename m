From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 04/11] tg3: Add a warning during link settings
 change if mgmt enabled
Date: Tue, 9 Apr 2013 11:48:04 -0700
Message-ID: <1365533291-5672-5-git-send-email-nsujir@broadcom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2276 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934965Ab3DISsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 14:48:53 -0400
In-Reply-To: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the user executes certain ethtool commands such as -s, -A, -G, -L,
-r a phy reset or autonegotiate is performed which results in management
traffic being interrupted.

Add a warning in these cases.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3f0d43f..a744998 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -2531,6 +2531,13 @@ static void tg3_carrier_off(struct tg3 *tp)
 	tp->link_up = false;
 }
 
+static void tg3_warn_mgmt_link_flap(struct tg3 *tp)
+{
+	if (tg3_flag(tp, ENABLE_ASF))
+		netdev_warn(tp->dev,
+			    "Management side-band traffic will be interrupted during phy settings change\n");
+}
+
 /* This will reset the tigon3 PHY if there is no valid
  * link unless the FORCE argument is non-zero.
  */
@@ -11565,6 +11572,8 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		tp->link_config.duplex = cmd->duplex;
 	}
 
+	tg3_warn_mgmt_link_flap(tp);
+
 	if (netif_running(dev))
 		tg3_setup_phy(tp, 1);
 
@@ -11643,6 +11652,8 @@ static int tg3_nway_reset(struct net_device *dev)
 	if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)
 		return -EINVAL;
 
+	tg3_warn_mgmt_link_flap(tp);
+
 	if (tg3_flag(tp, USE_PHYLIB)) {
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
@@ -11755,6 +11766,9 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 	struct tg3 *tp = netdev_priv(dev);
 	int err = 0;
 
+	if (tp->link_config.autoneg == AUTONEG_ENABLE)
+		tg3_warn_mgmt_link_flap(tp);
+
 	if (tg3_flag(tp, USE_PHYLIB)) {
 		u32 newadv;
 		struct phy_device *phydev;
-- 
1.8.1.4
