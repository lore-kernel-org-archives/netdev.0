From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/3] nfp: correct RX buffer length calculation
Date: Mon,  4 Jan 2016 16:03:14 +0000
Message-ID: <1451923395-24533-3-git-send-email-jakub.kicinski@netronome.com>
References: <1451923395-24533-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36666 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526AbcADQDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 11:03:25 -0500
Received: by mail-wm0-f53.google.com with SMTP id l65so168118225wmf.1
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 08:03:24 -0800 (PST)
In-Reply-To: <1451923395-24533-1-git-send-email-jakub.kicinski@netronome.com>
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
index 2826166547fd..bfc522474820 100644
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
@@ -1924,10 +1922,8 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 		nfp_net_netdev_close(netdev);
 
 	netdev->mtu = new_mtu;
-
-	/* Freelist buffer size rounded up to the nearest 1K */
-	tmp = new_mtu + ETH_HLEN + VLAN_HLEN + NFP_NET_MAX_PREPEND;
-	nn->fl_bufsz = roundup(tmp, 1024);
+	nn->fl_bufsz = NFP_NET_MAX_PREPEND + ETH_HLEN + VLAN_HLEN * 2 +
+		MPLS_HLEN * 8 + new_mtu;
 
 	if (netif_running(netdev))
 		nfp_net_netdev_open(netdev);
-- 
1.9.1
