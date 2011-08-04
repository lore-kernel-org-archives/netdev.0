From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/3] via-velocity : ethtool statistics support.
Date: Thu, 4 Aug 2011 14:38:28 +0200
Message-ID: <20110804123828.GB14858@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jon Nelson <jnelson@jamponi.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45263 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753712Ab1HDMyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 08:54:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Jon Nelson <jnelson@jamponi.net>
---
 drivers/net/via-velocity.c |   74 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 74 insertions(+), 0 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index ae66696..27bcd3b 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -3449,6 +3449,77 @@ static int velocity_set_coalesce(struct net_device *dev,
 	return 0;
 }
 
+static const char velocity_gstrings[][ETH_GSTRING_LEN] = {
+	"rx_all",
+	"rx_ok",
+	"tx_ok",
+	"rx_error",
+	"rx_runt_ok",
+	"rx_runt_err",
+	"rx_64",
+	"tx_64",
+	"rx_65_to_127",
+	"tx_65_to_127",
+	"rx_128_to_255",
+	"tx_128_to_255",
+	"rx_256_to_511",
+	"tx_256_to_511",
+	"rx_512_to_1023",
+	"tx_512_to_1023",
+	"rx_1024_to_1518",
+	"tx_1024_to_1518",
+	"tx_ether_collisions",
+	"rx_crc_errors",
+	"rx_jumbo",
+	"tx_jumbo",
+	"rx_mac_control_frames",
+	"tx_mac_control_frames",
+	"rx_frame_alignement_errors",
+	"rx_long_ok",
+	"rx_long_err",
+	"tx_sqe_errors",
+	"rx_no_buf",
+	"rx_symbol_errors",
+	"in_range_length_errors",
+	"late_collisions"
+};
+
+static void velocity_get_strings(struct net_device *dev, u32 sset, u8 *data)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		memcpy(data, *velocity_gstrings, sizeof(velocity_gstrings));
+		break;
+	}
+}
+
+static int velocity_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(velocity_gstrings);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void velocity_get_ethtool_stats(struct net_device *dev,
+				       struct ethtool_stats *stats, u64 *data)
+{
+	if (netif_running(dev)) {
+		struct velocity_info *vptr = netdev_priv(dev);
+		u32 *p = vptr->mib_counter;
+		int i;
+
+		spin_lock_irq(&vptr->lock);
+		velocity_update_hw_mibs(vptr);
+		spin_unlock_irq(&vptr->lock);
+
+		for (i = 0; i < ARRAY_SIZE(velocity_gstrings); i++)
+			*data++ = *p++;
+	}
+}
+
 static const struct ethtool_ops velocity_ethtool_ops = {
 	.get_settings	=	velocity_get_settings,
 	.set_settings	=	velocity_set_settings,
@@ -3458,6 +3529,9 @@ static const struct ethtool_ops velocity_ethtool_ops = {
 	.get_msglevel	=	velocity_get_msglevel,
 	.set_msglevel	=	velocity_set_msglevel,
 	.get_link	=	velocity_get_link,
+	.get_strings		= velocity_get_strings,
+	.get_sset_count		= velocity_get_sset_count,
+	.get_ethtool_stats	= velocity_get_ethtool_stats,
 	.get_coalesce	=	velocity_get_coalesce,
 	.set_coalesce	=	velocity_set_coalesce,
 	.begin		=	velocity_ethtool_up,
-- 
1.7.4.4

