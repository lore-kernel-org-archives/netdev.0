From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next resend 07/13] nfp: move RSS indirection table init into a separate function
Date: Thu,  3 Nov 2016 17:12:03 +0000
Message-ID: <1478193129-23476-8-git-send-email-jakub.kicinski@netronome.com>
References: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35818 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932390AbcKCRM1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:12:27 -0400
Received: by mail-wm0-f53.google.com with SMTP id a197so82842wmd.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 10:12:26 -0700 (PDT)
In-Reply-To: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will need to rerun the initialization of the RSS indirection table
after the number of rings is changed.  Move the code to a separate
function.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 2a4e1f1cb3c9..09cec6e2c6cf 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2229,6 +2229,15 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 	nn->ctrl = new_ctrl;
 }
 
+static void nfp_net_rss_init_itbl(struct nfp_net *nn)
+{
+	int i;
+
+	for (i = 0; i < sizeof(nn->rss_itbl); i++)
+		nn->rss_itbl[i] =
+			ethtool_rxfh_indir_default(i, nn->num_rx_rings);
+}
+
 static int
 nfp_net_ring_swap_enable(struct nfp_net *nn,
 			 struct nfp_net_ring_set *rx,
@@ -2707,13 +2716,9 @@ void nfp_net_netdev_free(struct nfp_net *nn)
  */
 static void nfp_net_rss_init(struct nfp_net *nn)
 {
-	int i;
-
 	netdev_rss_key_fill(nn->rss_key, NFP_NET_CFG_RSS_KEY_SZ);
 
-	for (i = 0; i < sizeof(nn->rss_itbl); i++)
-		nn->rss_itbl[i] =
-			ethtool_rxfh_indir_default(i, nn->num_rx_rings);
+	nfp_net_rss_init_itbl(nn);
 
 	/* Enable IPv4/IPv6 TCP by default */
 	nn->rss_cfg = NFP_NET_CFG_RSS_IPV4_TCP |
-- 
1.9.1
