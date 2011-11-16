From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/6] sky2: used fixed RSS key
Date: Wed, 16 Nov 2011 15:42:59 -0800
Message-ID: <20111116234344.909500366@vyatta.com>
References: <20111116234254.319625694@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:41566 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753962Ab1KPX5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 18:57:33 -0500
Content-Disposition: inline; filename=sky2-fixed-key.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than generating a different RSS key on each boot, just use
a predetermined value that will map same flow to same value on
every device.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:19:40.990692544 -0800
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:19:42.254721076 -0800
@@ -1275,6 +1275,14 @@ static void rx_set_checksum(struct sky2_
 		     ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
 }
 
+/*
+ * Fixed initial key as seed to RSS.
+ */
+static const uint32_t rss_init_key[10] = {
+	0x7c3351da, 0x51c5cf4e,	0x44adbdd1, 0xe8d38d18,	0x48897c43,
+	0xb1d60e7e, 0x6a3dd760, 0x01a2e453, 0x16f46f13, 0x1a0e7b30
+};
+
 /* Enable/disable receive hash calculation (RSS) */
 static void rx_set_rss(struct net_device *dev, netdev_features_t features)
 {
@@ -1290,12 +1298,9 @@ static void rx_set_rss(struct net_device
 
 	/* Program RSS initial values */
 	if (features & NETIF_F_RXHASH) {
-		u32 key[nkeys];
-
-		get_random_bytes(key, nkeys * sizeof(u32));
 		for (i = 0; i < nkeys; i++)
 			sky2_write32(hw, SK_REG(sky2->port, RSS_KEY + i * 4),
-				     key[i]);
+				     rss_init_key[i]);
 
 		/* Need to turn on (undocumented) flag to make hashing work  */
 		sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T),
