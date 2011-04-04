From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 10/12] tg3: implement ethtool set_phys_id
Date: Mon, 04 Apr 2011 11:43:50 -0700
Message-ID: <20110404184502.194825403@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52831 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755301Ab1DDSvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:16 -0400
Content-Disposition: inline; filename=tg3-set-phys-id.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement control of LED via set_phys_id. 
Note: since PHY is powered off if device is down, this board
only allows blinking if device is up.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tg3.c	2011-04-04 11:04:20.373199183 -0700
+++ b/drivers/net/tg3.c	2011-04-04 11:05:19.485863394 -0700
@@ -10317,35 +10317,38 @@ static void tg3_get_strings(struct net_d
 	}
 }
 
-static int tg3_phys_id(struct net_device *dev, u32 data)
+static int tg3_set_phys_id(struct net_device *dev,
+			    enum ethtool_phys_id_state state)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	int i;
 
 	if (!netif_running(tp->dev))
 		return -EAGAIN;
 
-	if (data == 0)
-		data = UINT_MAX / 2;
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		return -EINVAL;
 
-	for (i = 0; i < (data * 2); i++) {
-		if ((i % 2) == 0)
-			tw32(MAC_LED_CTRL, LED_CTRL_LNKLED_OVERRIDE |
-					   LED_CTRL_1000MBPS_ON |
-					   LED_CTRL_100MBPS_ON |
-					   LED_CTRL_10MBPS_ON |
-					   LED_CTRL_TRAFFIC_OVERRIDE |
-					   LED_CTRL_TRAFFIC_BLINK |
-					   LED_CTRL_TRAFFIC_LED);
+	case ETHTOOL_ID_ON:
+		tw32(MAC_LED_CTRL, LED_CTRL_LNKLED_OVERRIDE |
+		     LED_CTRL_1000MBPS_ON |
+		     LED_CTRL_100MBPS_ON |
+		     LED_CTRL_10MBPS_ON |
+		     LED_CTRL_TRAFFIC_OVERRIDE |
+		     LED_CTRL_TRAFFIC_BLINK |
+		     LED_CTRL_TRAFFIC_LED);
+		break;
 
-		else
-			tw32(MAC_LED_CTRL, LED_CTRL_LNKLED_OVERRIDE |
-					   LED_CTRL_TRAFFIC_OVERRIDE);
+	case ETHTOOL_ID_OFF:
+		tw32(MAC_LED_CTRL, LED_CTRL_LNKLED_OVERRIDE |
+		     LED_CTRL_TRAFFIC_OVERRIDE);
+		break;
 
-		if (msleep_interruptible(500))
-			break;
+	case ETHTOOL_ID_INACTIVE:
+		tw32(MAC_LED_CTRL, tp->led_ctrl);
+		break;
 	}
-	tw32(MAC_LED_CTRL, tp->led_ctrl);
+
 	return 0;
 }
 
@@ -11371,7 +11374,7 @@ static const struct ethtool_ops tg3_etht
 	.set_tso		= tg3_set_tso,
 	.self_test		= tg3_self_test,
 	.get_strings		= tg3_get_strings,
-	.phys_id		= tg3_phys_id,
+	.set_phys_id		= tg3_set_phys_id,
 	.get_ethtool_stats	= tg3_get_ethtool_stats,
 	.get_coalesce		= tg3_get_coalesce,
 	.set_coalesce		= tg3_set_coalesce,


