From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv2 net-next 3/4] nfp: correct RX buffer length calculation
Date: Tue,  5 Jan 2016 11:57:30 +0000
Message-ID: <1451995051-21920-4-git-send-email-jakub.kicinski@netronome.com>
References: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38488 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081AbcAEL5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 06:57:40 -0500
Received: by mail-wm0-f42.google.com with SMTP id b14so25351189wmb.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 03:57:39 -0800 (PST)
In-Reply-To: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calculating the RX buffer length we need to account for
up to 2 VLAN tags and up to 8 MPLS labels.  Rounding up to 1k
is an relic of a distant past and can be removed.  While at
it also remove trivial print statement.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Rolf Neugebauer <rolf.neugebauer@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index b381682de3d6..553ae64e2f7f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -61,6 +61,7 @@
 
 #include <linux/ktime.h>
 
+#include <net/mpls.h>
 #include <net/vxlan.h>
 
 #include "nfp_net_ctrl.h"
@@ -1912,9 +1913,6 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 	int ret = 0;
-	u32 tmp;
-
-	nn_dbg(nn, "New MTU = %d\n", new_mtu);
 
 	if (new_mtu < 68 || new_mtu > nn->max_mtu) {
 		nn_err(nn, "New MTU (%d) is not valid\n", new_mtu);
@@ -1925,10 +1923,8 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 		nfp_net_netdev_close(netdev);
 
 	netdev->mtu = new_mtu;
-
-	/* Freelist buffer size rounded up to the nearest 1K */
-	tmp = new_mtu + ETH_HLEN + VLAN_HLEN + NFP_NET_MAX_PREPEND;
-	nn->fl_bufsz = roundup(tmp, 1024);
+	nn->fl_bufsz = NFP_NET_MAX_PREPEND + ETH_HLEN + VLAN_HLEN * 2 +
+		MPLS_HLEN * 8 + new_mtu;
 
 	if (netif_running(netdev))
 		ret = nfp_net_netdev_open(netdev);
-- 
1.9.1
