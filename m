From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 09/12] nfp: add pointer to vNIC config memory to nfp_port structure
Date: Fri, 18 Aug 2017 15:48:19 -0700
Message-ID: <20170818224822.8409-10-jakub.kicinski@netronome.com>
References: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:38479 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751780AbdHRWtb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:49:31 -0400
Received: by mail-pg0-f47.google.com with SMTP id t80so44862660pgb.5
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 15:49:31 -0700 (PDT)
In-Reply-To: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify the statistics handling code by keeping pointer to vNIC's
config memory in nfp_port.  Note that this is referring to the
representor side of vNICs, vNIC side has the pointer in nfp_net.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/main.c  |  8 +++-
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c | 45 +++++------------------
 drivers/net/ethernet/netronome/nfp/nfp_port.h     |  2 +
 3 files changed, 18 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index 3088e959f2a3..126a6b5233bf 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -159,12 +159,18 @@ nfp_flower_spawn_vnic_reprs(struct nfp_app *app,
 			goto err_reprs_clean;
 		}
 
+		/* For now we only support 1 PF */
+		WARN_ON(repr_type == NFP_REPR_TYPE_PF && i);
+
 		port = nfp_port_alloc(app, port_type, reprs->reprs[i]);
 		if (repr_type == NFP_REPR_TYPE_PF) {
 			port->pf_id = i;
+			port->vnic = priv->nn->dp.ctrl_bar;
 		} else {
-			port->pf_id = 0; /* For now we only support 1 PF */
+			port->pf_id = 0;
 			port->vf_id = i;
+			port->vnic =
+				app->pf->vf_cfg_mem + i * NFP_NET_CFG_BAR_SZ;
 		}
 
 		eth_hw_addr_random(reprs->reprs[i]);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index 28e932eab812..0f9878d1bf40 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -96,50 +96,25 @@ nfp_repr_phy_port_get_stats64(struct nfp_port *port,
 }
 
 static void
-nfp_repr_vf_get_stats64(const struct nfp_app *app, u8 vf,
-			struct rtnl_link_stats64 *stats)
+nfp_repr_vnic_get_stats64(struct nfp_port *port,
+			  struct rtnl_link_stats64 *stats)
 {
-	u8 __iomem *mem;
-
-	mem = app->pf->vf_cfg_mem + vf * NFP_NET_CFG_BAR_SZ;
-
 	/* TX and RX stats are flipped as we are returning the stats as seen
 	 * at the switch port corresponding to the VF.
 	 */
-	stats->tx_packets = readq(mem + NFP_NET_CFG_STATS_RX_FRAMES);
-	stats->tx_bytes = readq(mem + NFP_NET_CFG_STATS_RX_OCTETS);
-	stats->tx_dropped = readq(mem + NFP_NET_CFG_STATS_RX_DISCARDS);
+	stats->tx_packets = readq(port->vnic + NFP_NET_CFG_STATS_RX_FRAMES);
+	stats->tx_bytes = readq(port->vnic + NFP_NET_CFG_STATS_RX_OCTETS);
+	stats->tx_dropped = readq(port->vnic + NFP_NET_CFG_STATS_RX_DISCARDS);
 
-	stats->rx_packets = readq(mem + NFP_NET_CFG_STATS_TX_FRAMES);
-	stats->rx_bytes = readq(mem + NFP_NET_CFG_STATS_TX_OCTETS);
-	stats->rx_dropped = readq(mem + NFP_NET_CFG_STATS_TX_DISCARDS);
-}
-
-static void
-nfp_repr_pf_get_stats64(const struct nfp_app *app, u8 pf,
-			struct rtnl_link_stats64 *stats)
-{
-	u8 __iomem *mem;
-
-	if (pf)
-		return;
-
-	mem = nfp_cpp_area_iomem(app->pf->data_vnic_bar);
-
-	stats->tx_packets = readq(mem + NFP_NET_CFG_STATS_RX_FRAMES);
-	stats->tx_bytes = readq(mem + NFP_NET_CFG_STATS_RX_OCTETS);
-	stats->tx_dropped = readq(mem + NFP_NET_CFG_STATS_RX_DISCARDS);
-
-	stats->rx_packets = readq(mem + NFP_NET_CFG_STATS_TX_FRAMES);
-	stats->rx_bytes = readq(mem + NFP_NET_CFG_STATS_TX_OCTETS);
-	stats->rx_dropped = readq(mem + NFP_NET_CFG_STATS_TX_DISCARDS);
+	stats->rx_packets = readq(port->vnic + NFP_NET_CFG_STATS_TX_FRAMES);
+	stats->rx_bytes = readq(port->vnic + NFP_NET_CFG_STATS_TX_OCTETS);
+	stats->rx_dropped = readq(port->vnic + NFP_NET_CFG_STATS_TX_DISCARDS);
 }
 
 static void
 nfp_repr_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 {
 	struct nfp_repr *repr = netdev_priv(netdev);
-	struct nfp_app *app = repr->app;
 
 	if (WARN_ON(!repr->port))
 		return;
@@ -151,10 +126,8 @@ nfp_repr_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 		nfp_repr_phy_port_get_stats64(repr->port, stats);
 		break;
 	case NFP_PORT_PF_PORT:
-		nfp_repr_pf_get_stats64(app, repr->port->pf_id, stats);
-		break;
 	case NFP_PORT_VF_PORT:
-		nfp_repr_vf_get_stats64(app, repr->port->vf_id, stats);
+		nfp_repr_vnic_get_stats64(repr->port, stats);
 	default:
 		break;
 	}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index de8ec609b57e..81c034018133 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -79,6 +79,7 @@ enum nfp_port_flags {
  * @eth_stats:	for %NFP_PORT_PHYS_PORT MAC stats if available
  * @pf_id:	for %NFP_PORT_PF_PORT, %NFP_PORT_VF_PORT ID of the PCI PF (0-3)
  * @vf_id:	for %NFP_PORT_VF_PORT ID of the PCI VF within @pf_id
+ * @vnic:	for %NFP_PORT_PF_PORT, %NFP_PORT_VF_PORT vNIC ctrl memory
  * @port_list:	entry on pf's list of ports
  */
 struct nfp_port {
@@ -102,6 +103,7 @@ struct nfp_port {
 		struct {
 			unsigned int pf_id;
 			unsigned int vf_id;
+			u8 __iomem *vnic;
 		};
 	};
 
-- 
2.11.0
