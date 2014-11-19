From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next] sky2: use new netdev_rss_key_fill() helper
Date: Wed, 19 Nov 2014 09:06:51 +0000
Message-ID: <1416388011-10491-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>,
	Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:38172 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750853AbaKSJOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 04:14:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to a random RSS key rather than a fixed one.
Using netdev_rss_key_fill helper also ensures that all ports share
a common key.

See also commit 960fb622f85180f36d3aff82af53e2be3db2f888.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Cc: Mirko Lindner <mlindner@marvell.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/marvell/sky2.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index bd33662..53a1cc5 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1290,14 +1290,6 @@ static void rx_set_checksum(struct sky2_port *sky2)
 		     ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
 }
 
-/*
- * Fixed initial key as seed to RSS.
- */
-static const uint32_t rss_init_key[10] = {
-	0x7c3351da, 0x51c5cf4e,	0x44adbdd1, 0xe8d38d18,	0x48897c43,
-	0xb1d60e7e, 0x6a3dd760, 0x01a2e453, 0x16f46f13, 0x1a0e7b30
-};
-
 /* Enable/disable receive hash calculation (RSS) */
 static void rx_set_rss(struct net_device *dev, netdev_features_t features)
 {
@@ -1313,9 +1305,12 @@ static void rx_set_rss(struct net_device *dev, netdev_features_t features)
 
 	/* Program RSS initial values */
 	if (features & NETIF_F_RXHASH) {
+		u32 rss_key[10];
+
+		netdev_rss_key_fill(rss_key, sizeof(rss_key));
 		for (i = 0; i < nkeys; i++)
 			sky2_write32(hw, SK_REG(sky2->port, RSS_KEY + i * 4),
-				     rss_init_key[i]);
+				     rss_key[i]);
 
 		/* Need to turn on (undocumented) flag to make hashing work  */
 		sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T),
-- 
1.9.1
