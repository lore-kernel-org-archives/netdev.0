From: David Decotigny <decot@google.com>
Subject: [PATCH 2/5] bnx2x: cosmetics: Using ethtool_cmd_speed() API
Date: Sat, 16 Apr 2011 17:54:08 -0700
Message-ID: <1303001651-4074-2-git-send-email-decot@google.com>
References: <1303001651-4074-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Stanislaw Gruszka <sgruszka@redh
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:30549 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171Ab1DQAyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 20:54:50 -0400
In-Reply-To: <1303001651-4074-1-git-send-email-decot@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This updates bnx2x to use the ethtool_cmd_speed() family of functions
(see b11f8d8c in 2.6.27-rc3 aka. "ethtool: Expand ethtool_cmd.speed to
32 bits") to get and set the link speed via ethtool. This allows to
avoid manually accessing ethtool_cmd's speed_hi field.

Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/bnx2x/bnx2x_ethtool.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 0a5e88d..e711a22 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -167,6 +167,7 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	int cfg_idx = bnx2x_get_link_cfg_idx(bp);
+
 	/* Dual Media boards present all available port types */
 	cmd->supported = bp->port.supported[cfg_idx] |
 		(bp->port.supported[cfg_idx ^ 1] &
@@ -176,16 +177,16 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if ((bp->state == BNX2X_STATE_OPEN) &&
 	    !(bp->flags & MF_FUNC_DIS) &&
 	    (bp->link_vars.link_up)) {
-		cmd->speed = bp->link_vars.line_speed;
+		ethtool_cmd_speed_set(cmd, bp->link_vars.line_speed);
 		cmd->duplex = bp->link_vars.duplex;
 	} else {
-
-		cmd->speed = bp->link_params.req_line_speed[cfg_idx];
+		ethtool_cmd_speed_set(
+			cmd, bp->link_params.req_line_speed[cfg_idx]);
 		cmd->duplex = bp->link_params.req_duplex[cfg_idx];
 	}
 
 	if (IS_MF(bp))
-		cmd->speed = bnx2x_get_mf_speed(bp);
+		ethtool_cmd_speed_set(cmd, bnx2x_get_mf_speed(bp));
 
 	if (bp->port.supported[cfg_idx] & SUPPORTED_TP)
 		cmd->port = PORT_TP;
@@ -206,10 +207,11 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	cmd->maxrxpkt = 0;
 
 	DP(NETIF_MSG_LINK, "ethtool_cmd: cmd %d\n"
-	   DP_LEVEL "  supported 0x%x  advertising 0x%x  speed %d\n"
+	   DP_LEVEL "  supported 0x%x  advertising 0x%x  speed %u\n"
 	   DP_LEVEL "  duplex %d  port %d  phy_address %d  transceiver %d\n"
 	   DP_LEVEL "  autoneg %d  maxtxpkt %d  maxrxpkt %d\n",
-	   cmd->cmd, cmd->supported, cmd->advertising, cmd->speed,
+	   cmd->cmd, cmd->supported, cmd->advertising,
+	   ethtool_cmd_speed(cmd),
 	   cmd->duplex, cmd->port, cmd->phy_address, cmd->transceiver,
 	   cmd->autoneg, cmd->maxtxpkt, cmd->maxrxpkt);
 
@@ -226,16 +228,15 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return 0;
 
 	DP(NETIF_MSG_LINK, "ethtool_cmd: cmd %d\n"
-	   "  supported 0x%x  advertising 0x%x  speed %d speed_hi %d\n"
+	   "  supported 0x%x  advertising 0x%x  speed %u\n"
 	   "  duplex %d  port %d  phy_address %d  transceiver %d\n"
 	   "  autoneg %d  maxtxpkt %d  maxrxpkt %d\n",
-	   cmd->cmd, cmd->supported, cmd->advertising, cmd->speed,
-	   cmd->speed_hi,
+	   cmd->cmd, cmd->supported, cmd->advertising,
+	   ethtool_cmd_speed(cmd),
 	   cmd->duplex, cmd->port, cmd->phy_address, cmd->transceiver,
 	   cmd->autoneg, cmd->maxtxpkt, cmd->maxrxpkt);
 
-	speed = cmd->speed;
-	speed |= (cmd->speed_hi << 16);
+	speed = ethtool_cmd_speed(cmd);
 
 	if (IS_MF_SI(bp)) {
 		u32 part;
@@ -439,7 +440,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			break;
 
 		default:
-			DP(NETIF_MSG_LINK, "Unsupported speed %d\n", speed);
+			DP(NETIF_MSG_LINK, "Unsupported speed %u\n", speed);
 			return -EINVAL;
 		}
 
-- 
1.7.3.1

