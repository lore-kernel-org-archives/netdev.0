From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 02/19] nfp: free buffers before changing MTU
Date: Wed,  3 Feb 2016 11:45:08 +0000
Message-ID: <1454499925-16359-3-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34989 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932779AbcBCLpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:38 -0500
Received: by mail-wm0-f53.google.com with SMTP id r129so160906093wmr.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:37 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For freeing DMA buffers we depend on nfp_net.fl_bufsz having the same
value as during allocation therefore in .ndo_change_mtu we must first
free the buffers and then change the setting.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Rolf Neugebauer <rolf.neugebauer@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 006d9600240f..b381682de3d6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1921,17 +1921,17 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 	}
 
+	if (netif_running(netdev))
+		nfp_net_netdev_close(netdev);
+
 	netdev->mtu = new_mtu;
 
 	/* Freelist buffer size rounded up to the nearest 1K */
 	tmp = new_mtu + ETH_HLEN + VLAN_HLEN + NFP_NET_MAX_PREPEND;
 	nn->fl_bufsz = roundup(tmp, 1024);
 
-	/* restart if running */
-	if (netif_running(netdev)) {
-		nfp_net_netdev_close(netdev);
+	if (netif_running(netdev))
 		ret = nfp_net_netdev_open(netdev);
-	}
 
 	return ret;
 }
-- 
1.9.1
