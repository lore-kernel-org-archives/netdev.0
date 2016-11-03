From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/13] nfp: add support for ethtool .get_channels
Date: Thu,  3 Nov 2016 13:58:46 +0000
Message-ID: <1478181538-20778-2-git-send-email-jakub.kicinski@netronome.com>
References: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35986 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757648AbcKCN7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 09:59:16 -0400
Received: by mail-wm0-f54.google.com with SMTP id p190so335314579wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:59:15 -0700 (PDT)
In-Reply-To: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report number of rings via ethtool .get_channels API.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 3418f2277e9d..a7386d1b2883 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -614,6 +614,21 @@ static int nfp_net_set_coalesce(struct net_device *netdev,
 	return nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_IRQMOD);
 }
 
+static void nfp_net_get_channels(struct net_device *netdev,
+				 struct ethtool_channels *channel)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	channel->max_rx = min(nn->max_rx_rings, nn->max_r_vecs);
+	channel->max_tx = min(nn->max_tx_rings, nn->max_r_vecs);
+	channel->max_combined = min(channel->max_rx, channel->max_tx);
+	channel->max_other = NFP_NET_NON_Q_VECTORS;
+	channel->combined_count = min(nn->num_rx_rings, nn->num_tx_rings);
+	channel->rx_count = nn->num_rx_rings - channel->combined_count;
+	channel->tx_count = nn->num_tx_rings - channel->combined_count;
+	channel->other_count = NFP_NET_NON_Q_VECTORS;
+}
+
 static const struct ethtool_ops nfp_net_ethtool_ops = {
 	.get_drvinfo		= nfp_net_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
@@ -632,6 +647,7 @@ static int nfp_net_set_coalesce(struct net_device *netdev,
 	.get_regs		= nfp_net_get_regs,
 	.get_coalesce           = nfp_net_get_coalesce,
 	.set_coalesce           = nfp_net_set_coalesce,
+	.get_channels		= nfp_net_get_channels,
 };
 
 void nfp_net_set_ethtool_ops(struct net_device *netdev)
-- 
1.9.1
