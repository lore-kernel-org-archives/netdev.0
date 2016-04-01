From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v4 net-next 01/15] nfp: correct RX buffer length calculation
Date: Fri,  1 Apr 2016 22:06:37 +0100
Message-ID: <1459544811-24879-2-git-send-email-jakub.kicinski@netronome.com>
References: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37351 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbcDAVHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 17:07:02 -0400
Received: by mail-wm0-f49.google.com with SMTP id p65so5352624wmp.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 14:07:01 -0700 (PDT)
In-Reply-To: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calculating the RX buffer length we need to account for
up to 2 VLAN tags and up to 8 MPLS labels.  Rounding up to 1k
is an relic of a distant past and can be removed.  While at
it also remove trivial print statement.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 43c618bafdb6..307c02c4ba4a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -61,6 +61,7 @@
 
 #include <linux/ktime.h>
 
+#include <net/mpls.h>
 #include <net/vxlan.h>
 
 #include "nfp_net_ctrl.h"
@@ -1911,9 +1912,6 @@ static void nfp_net_set_rx_mode(struct net_device *netdev)
 static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
-	u32 tmp;
-
-	nn_dbg(nn, "New MTU = %d\n", new_mtu);
 
 	if (new_mtu < 68 || new_mtu > nn->max_mtu) {
 		nn_err(nn, "New MTU (%d) is not valid\n", new_mtu);
@@ -1921,10 +1919,8 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 	}
 
 	netdev->mtu = new_mtu;
-
-	/* Freelist buffer size rounded up to the nearest 1K */
-	tmp = new_mtu + ETH_HLEN + VLAN_HLEN + NFP_NET_MAX_PREPEND;
-	nn->fl_bufsz = roundup(tmp, 1024);
+	nn->fl_bufsz = NFP_NET_MAX_PREPEND + ETH_HLEN + VLAN_HLEN * 2 +
+		MPLS_HLEN * 8 + new_mtu;
 
 	/* restart if running */
 	if (netif_running(netdev)) {
-- 
1.9.1
