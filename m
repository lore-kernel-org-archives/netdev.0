From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 07/14] nfp: report auto-negotiation in ethtool
Date: Tue,  4 Apr 2017 16:12:28 -0700
Message-ID: <20170404231235.32027-8-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34341 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755284AbdDDXM7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:12:59 -0400
Received: by mail-pg0-f44.google.com with SMTP id 21so165172640pgg.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:12:59 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NSP ABI version 0.17 is exposing the autonegotiation settings.
Report whether autoneg is on via ethtool.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c     |  4 ++++
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c |  2 ++
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h | 11 +++++++++++
 3 files changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 0fdc14e7b576..563ced3c99e1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -203,6 +203,10 @@ nfp_net_get_link_ksettings(struct net_device *netdev,
 	cmd->base.speed = SPEED_UNKNOWN;
 	cmd->base.duplex = DUPLEX_UNKNOWN;
 
+	if (nn->eth_port)
+		cmd->base.autoneg = nn->eth_port->aneg != NFP_ANEG_DISABLED ?
+			AUTONEG_ENABLE : AUTONEG_DISABLE;
+
 	if (!netif_carrier_ok(netdev))
 		return 0;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index 932772fbd27e..dcb1bc81e554 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -63,6 +63,7 @@
 #define NSP_ETH_STATE_RX_ENABLED	BIT_ULL(3)
 #define NSP_ETH_STATE_RATE		GENMASK_ULL(11, 8)
 #define NSP_ETH_STATE_OVRD_CHNG		BIT_ULL(22)
+#define NSP_ETH_STATE_ANEG		GENMASK_ULL(25, 23)
 
 #define NSP_ETH_CTRL_ENABLED		BIT_ULL(1)
 #define NSP_ETH_CTRL_TX_ENABLED		BIT_ULL(2)
@@ -142,6 +143,7 @@ nfp_eth_port_translate(struct nfp_nsp *nsp, const struct eth_table_entry *src,
 		return;
 
 	dst->override_changed = FIELD_GET(NSP_ETH_STATE_OVRD_CHNG, state);
+	dst->aneg = FIELD_GET(NSP_ETH_STATE_ANEG, state);
 }
 
 static void
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
index 6838741fadd7..6b3e954e70b3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
@@ -37,6 +37,14 @@
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
+enum nfp_eth_aneg {
+	NFP_ANEG_AUTO = 0,
+	NFP_ANEG_SEARCH,
+	NFP_ANEG_25G_CONSORTIUM,
+	NFP_ANEG_25G_IEEE,
+	NFP_ANEG_DISABLED,
+};
+
 /**
  * struct nfp_eth_table - ETH table information
  * @count:	number of table entries
@@ -48,6 +56,7 @@
  * @base:	first channel index (within NBI)
  * @lanes:	number of channels
  * @speed:	interface speed (in Mbps)
+ * @aneg:	auto negotiation mode
  * @mac_addr:	interface MAC address
  * @label_port:	port id
  * @label_subport:  id of interface within port (for split ports)
@@ -68,6 +77,8 @@ struct nfp_eth_table {
 		unsigned int lanes;
 		unsigned int speed;
 
+		enum nfp_eth_aneg aneg;
+
 		u8 mac_addr[ETH_ALEN];
 
 		u8 label_port;
-- 
2.11.0
