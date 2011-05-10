From: David Decotigny <decot@google.com>
Subject: [PATCH 1/2] net/stmmac: don't go through ethtool to start autonegociation
Date: Mon,  9 May 2011 17:19:07 -0700
Message-ID: <1304986748-15809-2-git-send-email-decot@google.com>
References: <1304986748-15809-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	netdev@vger.kernel.org,
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304986748-15809-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver used to call phy's ethtool configuration routine to start
autonegociation. This change has it call directly phy's routine to
start autonegociation.

IMPORTANT: initial version was hiding phy_start_aneg() return value,
           this patch returns it (<0 upon error).

Tested: module compiles, NOT tested on real hardware.
Signed-off-by: David Decotigny <decot@google.com>
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
1.7.3.1
