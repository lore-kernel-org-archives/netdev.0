From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 1/2 (V2)] stmmac: don't go through ethtool to start auto-negotiation
Date: Fri, 13 May 2011 08:28:04 +0200
Message-ID: <1305268085-603-1-git-send-email-peppe.cavallaro@st.com>
Cc: David Decotigny <decot@google.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:45232 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753013Ab1EMG2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 02:28:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@google.com>

The driver used to call phy's ethtool configuration routine to start
auto-negotiation. This change has it call directly phy's routine to
start auto-negotiation.

The initial version was hiding phy_start_aneg() return value,
this patch returns it (<0 upon error).

Tested: module compiles, tested on STM HDK7108 STB.

Signed-off-by: David Decotigny <decot@google.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_ethtool.c |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 6f5aaeb..9c05cf0 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -236,17 +236,8 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	priv->flow_ctrl = new_pause;
 
 	if (phy->autoneg) {
-		if (netif_running(netdev)) {
-			struct ethtool_cmd cmd = { .cmd = ETHTOOL_SSET };
-			/* auto-negotiation automatically restarted */
-			cmd.supported = phy->supported;
-			cmd.advertising = phy->advertising;
-			cmd.autoneg = phy->autoneg;
-			ethtool_cmd_speed_set(&cmd, phy->speed);
-			cmd.duplex = phy->duplex;
-			cmd.phy_address = phy->addr;
-			ret = phy_ethtool_sset(phy, &cmd);
-		}
+		if (netif_running(netdev))
+			ret = phy_start_aneg(phy);
 	} else
 		priv->hw->mac->flow_ctrl(priv->ioaddr, phy->duplex,
 					 priv->flow_ctrl, priv->pause);
-- 
1.7.4.4

