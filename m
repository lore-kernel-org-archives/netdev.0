From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/8] bnx2x: convert to set_phys_id
Date: Mon, 04 Apr 2011 14:06:37 -0700
Message-ID: <20110404210805.493178297@linuxplumber.net>
References: <20110404210634.840793593@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43881 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755591Ab1DDWSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 18:18:17 -0400
Content-Disposition: inline; filename=bnx2x-set-phys.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also cleanup error codes to no lie about things that driver doesn't
support. If device is down report -EAGAIN (same as Broadcom), and 
if port doesn't blink then error as well.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bnx2x/bnx2x_ethtool.c	2011-04-04 12:54:28.927607342 -0700
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c	2011-04-04 12:55:43.108429058 -0700
@@ -2097,36 +2097,38 @@ static void bnx2x_get_ethtool_stats(stru
 	}
 }
 
-static int bnx2x_phys_id(struct net_device *dev, u32 data)
+static int bnx2x_set_phys_id(struct net_device *dev,
+			     enum ethtool_phys_id_state state)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int i;
 
 	if (!netif_running(dev))
-		return 0;
+		return -EAGAIN;
 
 	if (!bp->port.pmf)
-		return 0;
+		return -EOPNOTSUPP;
 
-	if (data == 0)
-		data = 2;
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		return -EINVAL;
 
-	for (i = 0; i < (data * 2); i++) {
-		if ((i % 2) == 0)
-			bnx2x_set_led(&bp->link_params, &bp->link_vars,
-				      LED_MODE_OPER, SPEED_1000);
-		else
-			bnx2x_set_led(&bp->link_params, &bp->link_vars,
-				      LED_MODE_OFF, 0);
+	case ETHTOOL_ID_ON:
+		bnx2x_set_led(&bp->link_params, &bp->link_vars,
+			      LED_MODE_OPER, SPEED_1000);
+		break;
+
+	case ETHTOOL_ID_OFF:
+		bnx2x_set_led(&bp->link_params, &bp->link_vars,
+			      LED_MODE_OFF, 0);
 
-		msleep_interruptible(500);
-		if (signal_pending(current))
-			break;
-	}
+		break;
 
-	if (bp->link_vars.link_up)
-		bnx2x_set_led(&bp->link_params, &bp->link_vars, LED_MODE_OPER,
-			      bp->link_vars.line_speed);
+	case ETHTOOL_ID_INACTIVE:
+		if (bp->link_vars.link_up)
+			bnx2x_set_led(&bp->link_params, &bp->link_vars,
+				      LED_MODE_OPER,
+				      bp->link_vars.line_speed);
+	}
 
 	return 0;
 }
@@ -2218,7 +2220,7 @@ static const struct ethtool_ops bnx2x_et
 	.self_test		= bnx2x_self_test,
 	.get_sset_count		= bnx2x_get_sset_count,
 	.get_strings		= bnx2x_get_strings,
-	.phys_id		= bnx2x_phys_id,
+	.set_phys_id		= bnx2x_set_phys_id,
 	.get_ethtool_stats	= bnx2x_get_ethtool_stats,
 	.get_rxnfc		= bnx2x_get_rxnfc,
 	.get_rxfh_indir		= bnx2x_get_rxfh_indir,


