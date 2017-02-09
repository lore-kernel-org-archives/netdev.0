From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: myricom: myri10ge: use new api ethtool_{get|set}_link_ksettings
Date: Thu,  9 Feb 2017 23:17:23 +0100
Message-ID: <1486678643-13139-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: hykim@myri.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   23 +++++++++------------
 1 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 1139d18..b171ed2 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1610,15 +1610,16 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 }
 
 static int
-myri10ge_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+myri10ge_get_link_ksettings(struct net_device *netdev,
+			    struct ethtool_link_ksettings *cmd)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
 	char *ptr;
 	int i;
 
-	cmd->autoneg = AUTONEG_DISABLE;
-	ethtool_cmd_speed_set(cmd, SPEED_10000);
-	cmd->duplex = DUPLEX_FULL;
+	cmd->base.autoneg = AUTONEG_DISABLE;
+	cmd->base.speed = SPEED_10000;
+	cmd->base.duplex = DUPLEX_FULL;
 
 	/*
 	 * parse the product code to deterimine the interface type
@@ -1643,16 +1644,12 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 		ptr++;
 	if (*ptr == 'R' || *ptr == 'Q' || *ptr == 'S') {
 		/* We've found either an XFP, quad ribbon fiber, or SFP+ */
-		cmd->port = PORT_FIBRE;
-		cmd->supported |= SUPPORTED_FIBRE;
-		cmd->advertising |= ADVERTISED_FIBRE;
+		cmd->base.port = PORT_FIBRE;
+		ethtool_link_ksettings_add_link_mode(cmd, supported, FIBRE);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising, FIBRE);
 	} else {
-		cmd->port = PORT_OTHER;
+		cmd->base.port = PORT_OTHER;
 	}
-	if (*ptr == 'R' || *ptr == 'S')
-		cmd->transceiver = XCVR_EXTERNAL;
-	else
-		cmd->transceiver = XCVR_INTERNAL;
 
 	return 0;
 }
@@ -1925,7 +1922,6 @@ static int myri10ge_led(struct myri10ge_priv *mgp, int on)
 }
 
 static const struct ethtool_ops myri10ge_ethtool_ops = {
-	.get_settings = myri10ge_get_settings,
 	.get_drvinfo = myri10ge_get_drvinfo,
 	.get_coalesce = myri10ge_get_coalesce,
 	.set_coalesce = myri10ge_set_coalesce,
@@ -1939,6 +1935,7 @@ static int myri10ge_led(struct myri10ge_priv *mgp, int on)
 	.set_msglevel = myri10ge_set_msglevel,
 	.get_msglevel = myri10ge_get_msglevel,
 	.set_phys_id = myri10ge_phys_id,
+	.get_link_ksettings = myri10ge_get_link_ksettings,
 };
 
 static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
-- 
1.7.4.4
