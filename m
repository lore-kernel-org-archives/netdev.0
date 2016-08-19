From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: renesas: ravb: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 20 Aug 2016 00:52:19 +0200
Message-ID: <1471647139-1867-2-git-send-email-tremyfr@gmail.com>
References: <1471647139-1867-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
        kazuya.mizuguchi.ks@renesas.com, ykaneko0929@gmail.com,
        horms+renesas@verge.net.au, masaru.nagai.vx@renesas.com,
        geert+renesas@glider.be, niklas.soderlund+renesas@ragnatech.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471647139-1867-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/renesas/ravb_main.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index d21c9a4..cad23ba 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1049,7 +1049,8 @@ static int ravb_phy_start(struct net_device *ndev)
 	return 0;
 }
 
-static int ravb_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
+static int ravb_get_link_ksettings(struct net_device *ndev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
 	int error = -ENODEV;
@@ -1057,14 +1058,15 @@ static int ravb_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 
 	if (ndev->phydev) {
 		spin_lock_irqsave(&priv->lock, flags);
-		error = phy_ethtool_gset(ndev->phydev, ecmd);
+		error = phy_ethtool_ksettings_get(ndev->phydev, cmd);
 		spin_unlock_irqrestore(&priv->lock, flags);
 	}
 
 	return error;
 }
 
-static int ravb_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
+static int ravb_set_link_ksettings(struct net_device *ndev,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
 	unsigned long flags;
@@ -1078,11 +1080,11 @@ static int ravb_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 	/* Disable TX and RX */
 	ravb_rcv_snd_disable(ndev);
 
-	error = phy_ethtool_sset(ndev->phydev, ecmd);
+	error = phy_ethtool_ksettings_set(ndev->phydev, cmd);
 	if (error)
 		goto error_exit;
 
-	if (ecmd->duplex == DUPLEX_FULL)
+	if (cmd->base.duplex == DUPLEX_FULL)
 		priv->duplex = 1;
 	else
 		priv->duplex = 0;
@@ -1306,8 +1308,6 @@ static int ravb_get_ts_info(struct net_device *ndev,
 }
 
 static const struct ethtool_ops ravb_ethtool_ops = {
-	.get_settings		= ravb_get_settings,
-	.set_settings		= ravb_set_settings,
 	.nway_reset		= ravb_nway_reset,
 	.get_msglevel		= ravb_get_msglevel,
 	.set_msglevel		= ravb_set_msglevel,
@@ -1318,6 +1318,8 @@ static const struct ethtool_ops ravb_ethtool_ops = {
 	.get_ringparam		= ravb_get_ringparam,
 	.set_ringparam		= ravb_set_ringparam,
 	.get_ts_info		= ravb_get_ts_info,
+	.get_link_ksettings	= ravb_get_link_ksettings,
+	.set_link_ksettings	= ravb_set_link_ksettings,
 };
 
 static inline int ravb_hook_irq(unsigned int irq, irq_handler_t handler,
-- 
1.7.4.4
