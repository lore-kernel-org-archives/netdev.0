From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 05/14] nfp: centralize the buffer size calculation
Date: Mon, 31 Oct 2016 20:43:13 +0000
Message-ID: <1477946602-19644-6-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38320 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034036AbcJaUoD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:03 -0400
Received: by mail-wm0-f54.google.com with SMTP id n67so251677146wme.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:02 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper function to calculate the buffer size at run time.
Buffer lengths will now depend on the FW prepend configuration
instead of assuming the most space consuming configuration and
defaulting to 2k buffers at initialization time.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  1 -
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 29 ++++++++++++++++------
 2 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 808c38ae4991..9b90fab8a6df 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -75,7 +75,6 @@
 
 /* Default size for MTU and freelist buffer sizes */
 #define NFP_NET_DEFAULT_MTU		1500
-#define NFP_NET_DEFAULT_RX_BUFSZ	2048
 
 /* Maximum number of bytes prepended to a packet */
 #define NFP_NET_MAX_PREPEND		64
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 025483fb9103..77c645abb827 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1030,6 +1030,19 @@ static void nfp_net_tx_timeout(struct net_device *netdev)
 
 /* Receive processing
  */
+static unsigned int
+nfp_net_calc_fl_bufsz(struct nfp_net *nn, unsigned int mtu)
+{
+	unsigned int fl_bufsz;
+
+	if (nn->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
+		fl_bufsz = NFP_NET_MAX_PREPEND;
+	else
+		fl_bufsz = nn->rx_offset;
+	fl_bufsz += ETH_HLEN + VLAN_HLEN * 2 + mtu;
+
+	return fl_bufsz;
+}
 
 /**
  * nfp_net_rx_alloc_one() - Allocate and map skb for RX
@@ -2191,7 +2204,7 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 
 	old_mtu = netdev->mtu;
 	old_fl_bufsz = nn->fl_bufsz;
-	new_fl_bufsz = NFP_NET_MAX_PREPEND + ETH_HLEN + VLAN_HLEN * 2 + new_mtu;
+	new_fl_bufsz = nfp_net_calc_fl_bufsz(nn, new_mtu);
 
 	if (!netif_running(netdev)) {
 		netdev->mtu = new_mtu;
@@ -2731,12 +2744,18 @@ int nfp_net_netdev_init(struct net_device *netdev)
 
 	nfp_net_write_mac_addr(nn);
 
+	/* Determine RX packet/metadata boundary offset */
+	if (nn->fw_ver.major >= 2)
+		nn->rx_offset = nn_readl(nn, NFP_NET_CFG_RX_OFFSET);
+	else
+		nn->rx_offset = NFP_NET_RX_OFFSET;
+
 	/* Set default MTU and Freelist buffer size */
 	if (nn->max_mtu < NFP_NET_DEFAULT_MTU)
 		netdev->mtu = nn->max_mtu;
 	else
 		netdev->mtu = NFP_NET_DEFAULT_MTU;
-	nn->fl_bufsz = NFP_NET_DEFAULT_RX_BUFSZ;
+	nn->fl_bufsz = nfp_net_calc_fl_bufsz(nn, netdev->mtu);
 
 	/* Advertise/enable offloads based on capabilities
 	 *
@@ -2807,12 +2826,6 @@ int nfp_net_netdev_init(struct net_device *netdev)
 		nn->ctrl |= NFP_NET_CFG_CTRL_IRQMOD;
 	}
 
-	/* Determine RX packet/metadata boundary offset */
-	if (nn->fw_ver.major >= 2)
-		nn->rx_offset = nn_readl(nn, NFP_NET_CFG_RX_OFFSET);
-	else
-		nn->rx_offset = NFP_NET_RX_OFFSET;
-
 	/* Stash the re-configuration queue away.  First odd queue in TX Bar */
 	nn->qcp_cfg = nn->tx_bar + NFP_QCP_QUEUE_ADDR_SZ;
 
-- 
1.9.1
