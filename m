From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 07/12] nfp: store pointer to MAC statistics in nfp_port
Date: Fri, 18 Aug 2017 15:48:17 -0700
Message-ID: <20170818224822.8409-8-jakub.kicinski@netronome.com>
References: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:38472 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751713AbdHRWt3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:49:29 -0400
Received: by mail-pg0-f43.google.com with SMTP id t80so44862299pgb.5
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 15:49:29 -0700 (PDT)
In-Reply-To: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Store pointer to device memory containing MAC statistics
in nfp_port.  This simplifies representor code and will
be used to dump those statistics in ethtool as well.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c | 12 ++++--------
 drivers/net/ethernet/netronome/nfp/nfp_port.c     |  3 +++
 drivers/net/ethernet/netronome/nfp/nfp_port.h     |  2 ++
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index 50f7cc057cc9..28e932eab812 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -78,12 +78,10 @@ void nfp_repr_inc_rx_stats(struct net_device *netdev, unsigned int len)
 }
 
 static void
-nfp_repr_phy_port_get_stats64(const struct nfp_app *app, u8 phy_port,
+nfp_repr_phy_port_get_stats64(struct nfp_port *port,
 			      struct rtnl_link_stats64 *stats)
 {
-	u8 __iomem *mem;
-
-	mem = app->pf->mac_stats_mem + phy_port * NFP_MAC_STATS_SIZE;
+	u8 __iomem *mem = port->eth_stats;
 
 	/* TX and RX stats are flipped as we are returning the stats as seen
 	 * at the switch port corresponding to the phys port.
@@ -141,7 +139,6 @@ static void
 nfp_repr_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 {
 	struct nfp_repr *repr = netdev_priv(netdev);
-	struct nfp_eth_table_port *eth_port;
 	struct nfp_app *app = repr->app;
 
 	if (WARN_ON(!repr->port))
@@ -149,10 +146,9 @@ nfp_repr_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 
 	switch (repr->port->type) {
 	case NFP_PORT_PHYS_PORT:
-		eth_port = __nfp_port_get_eth_port(repr->port);
-		if (!eth_port)
+		if (!__nfp_port_get_eth_port(repr->port))
 			break;
-		nfp_repr_phy_port_get_stats64(app, eth_port->index, stats);
+		nfp_repr_phy_port_get_stats64(repr->port, stats);
 		break;
 	case NFP_PORT_PF_PORT:
 		nfp_repr_pf_get_stats64(app, repr->port->pf_id, stats);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index 0cf65e57addb..34a6e035fe9a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -225,6 +225,9 @@ int nfp_port_init_phy_port(struct nfp_pf *pf, struct nfp_app *app,
 
 	port->eth_port = &pf->eth_tbl->ports[id];
 	port->eth_id = pf->eth_tbl->ports[id].index;
+	if (pf->mac_stats_mem)
+		port->eth_stats =
+			pf->mac_stats_mem + port->eth_id * NFP_MAC_STATS_SIZE;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 784d82c2f32c..cf71ac065e85 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -76,6 +76,7 @@ enum nfp_port_flags {
  * @dl_port:	devlink port structure
  * @eth_id:	for %NFP_PORT_PHYS_PORT port ID in NFP enumeration scheme
  * @eth_port:	for %NFP_PORT_PHYS_PORT translated ETH Table port entry
+ * @eth_stats:	for %NFP_PORT_PHYS_PORT MAC stats if available
  * @pf_id:	for %NFP_PORT_PF_PORT, %NFP_PORT_VF_PORT ID of the PCI PF (0-3)
  * @vf_id:	for %NFP_PORT_VF_PORT ID of the PCI VF within @pf_id
  * @port_list:	entry on pf's list of ports
@@ -95,6 +96,7 @@ struct nfp_port {
 		struct {
 			unsigned int eth_id;
 			struct nfp_eth_table_port *eth_port;
+			u8 __iomem *eth_stats;
 		};
 		/* NFP_PORT_PF_PORT, NFP_PORT_VF_PORT */
 		struct {
-- 
2.11.0
