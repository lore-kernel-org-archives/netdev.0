From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/3] nfp: free buffers before changing MTU
Date: Mon,  4 Jan 2016 16:03:13 +0000
Message-ID: <1451923395-24533-2-git-send-email-jakub.kicinski@netronome.com>
References: <1451923395-24533-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34786 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516AbcADQDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 11:03:24 -0500
Received: by mail-wm0-f51.google.com with SMTP id u188so152460165wmu.1
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 08:03:23 -0800 (PST)
In-Reply-To: <1451923395-24533-1-git-send-email-jakub.kicinski@netronome.com>
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
index 43c618bafdb6..2826166547fd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1920,17 +1920,17 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
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
 		nfp_net_netdev_open(netdev);
-	}
 
 	return 0;
 }
-- 
1.9.1
