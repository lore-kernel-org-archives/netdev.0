From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v5 net-next 01/15] nfp: correct RX buffer length calculation
Date: Thu,  7 Apr 2016 19:39:34 +0100
Message-ID: <1460054388-471-2-git-send-email-jakub.kicinski@netronome.com>
References: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36649 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756577AbcDGSkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:40:21 -0400
Received: by mail-qk0-f177.google.com with SMTP id i4so34627728qkc.3
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 11:40:20 -0700 (PDT)
In-Reply-To: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calculating the RX buffer length we need to account
for up to 2 VLAN tags.  Rounding up to 1k is an relic of
a distant past and can be removed.  While at it also remove
trivial print statement.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 43c618bafdb6..0dae81454e77 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1911,9 +1911,6 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
-	u32 tmp;
-
-	nn_dbg(nn, "New MTU = %d\n", new_mtu);
 
 	if (new_mtu < 68 || new_mtu > nn->max_mtu) {
 		nn_err(nn, "New MTU (%d) is not valid\n", new_mtu);
@@ -1921,10 +1918,7 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 	}
 
 	netdev->mtu = new_mtu;
-
-	/* Freelist buffer size rounded up to the nearest 1K */
-	tmp = new_mtu + ETH_HLEN + VLAN_HLEN + NFP_NET_MAX_PREPEND;
-	nn->fl_bufsz = roundup(tmp, 1024);
+	nn->fl_bufsz = NFP_NET_MAX_PREPEND + ETH_HLEN + VLAN_HLEN * 2 + new_mtu;
 
 	/* restart if running */
 	if (netif_running(netdev)) {
-- 
1.9.1
