From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next-2.6 7/7] sfc: Implement ethtool_ops::set_phys_id
 instead of ethtool_ops::phys_id
Date: Tue, 05 Apr 2011 19:07:15 +0100
Message-ID: <1302026835.2932.65.camel@bwh-desktop>
References: <1302026446.2932.56.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:15895 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775Ab1DESHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 14:07:18 -0400
In-Reply-To: <1302026446.2932.56.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |   28 ++++++++++++++++++----------
 1 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 0d55439..644f7c1 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -178,19 +178,27 @@ static struct efx_ethtool_stat efx_ethtool_stats[] = {
  */
 
 /* Identify device by flashing LEDs */
-static int efx_ethtool_phys_id(struct net_device *net_dev, u32 count)
+static int efx_ethtool_phys_id(struct net_device *net_dev,
+			       enum ethtool_phys_id_state state)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
+	enum efx_led_mode mode;
 
-	do {
-		efx->type->set_id_led(efx, EFX_LED_ON);
-		schedule_timeout_interruptible(HZ / 2);
-
-		efx->type->set_id_led(efx, EFX_LED_OFF);
-		schedule_timeout_interruptible(HZ / 2);
-	} while (!signal_pending(current) && --count != 0);
+	switch (state) {
+	case ETHTOOL_ID_ON:
+		mode = EFX_LED_ON;
+		break;
+	case ETHTOOL_ID_OFF:
+		mode = EFX_LED_OFF;
+		break;
+	case ETHTOOL_ID_INACTIVE:
+		mode = EFX_LED_DEFAULT;
+		break;
+	default:
+		return -EINVAL;
+	}
 
-	efx->type->set_id_led(efx, EFX_LED_DEFAULT);
+	efx->type->set_id_led(efx, mode);
 	return 0;
 }
 
@@ -1007,7 +1015,7 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_sset_count		= efx_ethtool_get_sset_count,
 	.self_test		= efx_ethtool_self_test,
 	.get_strings		= efx_ethtool_get_strings,
-	.phys_id		= efx_ethtool_phys_id,
+	.set_phys_id		= efx_ethtool_phys_id,
 	.get_ethtool_stats	= efx_ethtool_get_stats,
 	.get_wol                = efx_ethtool_get_wol,
 	.set_wol                = efx_ethtool_set_wol,
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

