From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 02/12] skge: implement set_phys_id
Date: Mon, 04 Apr 2011 11:43:42 -0700
Message-ID: <20110404184501.450494215@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52798 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755150Ab1DDSvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:06 -0400
Content-Disposition: inline; filename=skge-phys-id.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement set_phys_id led control on SysKonnect board.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/skge.c	2011-04-04 10:48:15.713539204 -0700
+++ b/drivers/net/skge.c	2011-04-04 10:50:07.387094723 -0700
@@ -786,29 +786,28 @@ static void skge_led(struct skge_port *s
 }
 
 /* blink LED's for finding board */
-static int skge_phys_id(struct net_device *dev, u32 data)
+static int skge_set_phys_id(struct net_device *dev,
+			    enum ethtool_phys_id_state state)
 {
 	struct skge_port *skge = netdev_priv(dev);
-	unsigned long ms;
-	enum led_mode mode = LED_MODE_TST;
 
-	if (!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
-		ms = jiffies_to_msecs(MAX_SCHEDULE_TIMEOUT / HZ) * 1000;
-	else
-		ms = data * 1000;
-
-	while (ms > 0) {
-		skge_led(skge, mode);
-		mode ^= LED_MODE_TST;
-
-		if (msleep_interruptible(BLINK_MS))
-			break;
-		ms -= BLINK_MS;
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		return -1;
+
+	case ETHTOOL_ID_ON:
+		skge_led(skge, LED_MODE_TST);
+		break;
+
+	case ETHTOOL_ID_OFF:
+		skge_led(skge, LED_MODE_OFF);
+		break;
+
+	case ETHTOOL_ID_INACTIVE:
+		/* back to regular LED state */
+		skge_led(skge, netif_running(dev) ? LED_MODE_ON : LED_MODE_OFF);
 	}
 
-	/* back to regular LED state */
-	skge_led(skge, netif_running(dev) ? LED_MODE_ON : LED_MODE_OFF);
-
 	return 0;
 }
 
@@ -930,7 +929,7 @@ static const struct ethtool_ops skge_eth
 	.get_rx_csum	= skge_get_rx_csum,
 	.set_rx_csum	= skge_set_rx_csum,
 	.get_strings	= skge_get_strings,
-	.phys_id	= skge_phys_id,
+	.set_phys_id	= skge_set_phys_id,
 	.get_sset_count = skge_get_sset_count,
 	.get_ethtool_stats = skge_get_ethtool_stats,
 };


