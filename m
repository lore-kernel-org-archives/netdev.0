From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/8] --- drivers/net/niu.c | 33 ++++++++++++++++++--------------- drivers/net/niu.h | 1 + 2 files changed, 19 insertions(+), 15 deletions(-)
Date: Mon, 04 Apr 2011 14:06:39 -0700
Message-ID: <20110404210805.696664557@linuxplumber.net>
References: <20110404210634.840793593@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43882 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755735Ab1DDWSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 18:18:17 -0400
Content-Disposition: inline; filename=niu-set-phys.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- a/drivers/net/niu.c	2011-04-04 13:15:46.805340164 -0700
+++ b/drivers/net/niu.c	2011-04-04 13:19:17.551610508 -0700
@@ -7888,28 +7888,31 @@ static void niu_force_led(struct niu *np
 	nw64_mac(reg, val);
 }
 
-static int niu_phys_id(struct net_device *dev, u32 data)
+static int niu_set_phys_id(struct net_device *dev,
+			   enum ethtool_phys_id_state state)
+
 {
 	struct niu *np = netdev_priv(dev);
-	u64 orig_led_state;
-	int i;
 
 	if (!netif_running(dev))
 		return -EAGAIN;
 
-	if (data == 0)
-		data = 2;
-
-	orig_led_state = niu_led_state_save(np);
-	for (i = 0; i < (data * 2); i++) {
-		int on = ((i % 2) == 0);
-
-		niu_force_led(np, on);
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		np->orig_led_state = niu_led_state_save(np);
+		return -EINVAL;
+
+	case ETHTOOL_ID_ON:
+		niu_force_led(np, 1);
+		break;
+
+	case ETHTOOL_ID_OFF:
+		niu_force_led(np, 0);
+		break;
 
-		if (msleep_interruptible(500))
-			break;
+	case ETHTOOL_ID_INACTIVE:
+		niu_led_state_restore(np, np->orig_led_state);
 	}
-	niu_led_state_restore(np, orig_led_state);
 
 	return 0;
 }
@@ -7932,7 +7935,7 @@ static const struct ethtool_ops niu_etht
 	.get_strings		= niu_get_strings,
 	.get_sset_count		= niu_get_sset_count,
 	.get_ethtool_stats	= niu_get_ethtool_stats,
-	.phys_id		= niu_phys_id,
+	.set_phys_id		= niu_set_phys_id,
 	.get_rxnfc		= niu_get_nfc,
 	.set_rxnfc		= niu_set_nfc,
 	.set_flags		= niu_set_flags,
--- a/drivers/net/niu.h	2011-04-04 13:16:37.445885085 -0700
+++ b/drivers/net/niu.h	2011-04-04 13:17:27.034418897 -0700
@@ -3279,6 +3279,7 @@ struct niu {
 	unsigned long			xpcs_off;
 
 	struct timer_list		timer;
+	u64				orig_led_state;
 	const struct niu_phy_ops	*phy_ops;
 	int				phy_addr;
 


