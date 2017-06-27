From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 07/14] nfp: make the representor get stats app-independent
Date: Tue, 27 Jun 2017 00:50:21 -0700
Message-ID: <20170627075028.4009-8-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33110 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752545AbdF0HvM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:12 -0400
Received: by mail-pf0-f177.google.com with SMTP id e7so12632278pfk.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:12 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks to the fact that all representors will now have an nfp_port,
we can depend on information there to provide a app-independent
.ndo_get_stats64().

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/main.c  | 16 +------------
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c | 28 +++++++++++++++--------
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.h |  4 ++--
 3 files changed, 22 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index 757bc3d78ea4..2e66d51ec104 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -104,20 +104,6 @@ nfp_flower_repr_get(struct nfp_app *app, u32 port_id)
 	return reprs->reprs[port];
 }
 
-static void
-nfp_flower_repr_netdev_get_stats64(struct net_device *netdev,
-				   struct rtnl_link_stats64 *stats)
-{
-	struct nfp_repr *repr = netdev_priv(netdev);
-	enum nfp_repr_type type;
-	u32 port_id;
-	u8 port = 0;
-
-	port_id = repr->dst->u.port_info.port_id;
-	type = nfp_flower_repr_get_type_and_port(repr->app, port_id, &port);
-	nfp_repr_get_stats64(repr->app, type, port, stats);
-}
-
 static int nfp_flower_repr_netdev_open(struct net_device *netdev)
 {
 	int err;
@@ -144,7 +130,7 @@ static const struct net_device_ops nfp_flower_repr_netdev_ops = {
 	.ndo_open		= nfp_flower_repr_netdev_open,
 	.ndo_stop		= nfp_flower_repr_netdev_stop,
 	.ndo_start_xmit		= nfp_repr_xmit,
-	.ndo_get_stats64	= nfp_flower_repr_netdev_get_stats64,
+	.ndo_get_stats64	= nfp_repr_get_stats64,
 	.ndo_has_offload_stats	= nfp_repr_has_offload_stats,
 	.ndo_get_offload_stats	= nfp_repr_get_offload_stats,
 };
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index 44adcc5df11e..6f1548c6840c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -37,6 +37,7 @@
 #include <net/dst_metadata.h>
 
 #include "nfpcore/nfp_cpp.h"
+#include "nfpcore/nfp_nsp.h"
 #include "nfp_app.h"
 #include "nfp_main.h"
 #include "nfp_net_ctrl.h"
@@ -136,18 +137,27 @@ nfp_repr_pf_get_stats64(const struct nfp_app *app, u8 pf,
 }
 
 void
-nfp_repr_get_stats64(const struct nfp_app *app, enum nfp_repr_type type,
-		     u8 port, struct rtnl_link_stats64 *stats)
+nfp_repr_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 {
-	switch (type) {
-	case NFP_REPR_TYPE_PHYS_PORT:
-		nfp_repr_phy_port_get_stats64(app, port, stats);
+	struct nfp_repr *repr = netdev_priv(netdev);
+	struct nfp_eth_table_port *eth_port;
+	struct nfp_app *app = repr->app;
+
+	if (WARN_ON(!repr->port))
+		return;
+
+	switch (repr->port->type) {
+	case NFP_PORT_PHYS_PORT:
+		eth_port = __nfp_port_get_eth_port(repr->port);
+		if (!eth_port)
+			break;
+		nfp_repr_phy_port_get_stats64(app, eth_port->index, stats);
 		break;
-	case NFP_REPR_TYPE_PF:
-		nfp_repr_pf_get_stats64(app, port, stats);
+	case NFP_PORT_PF_PORT:
+		nfp_repr_pf_get_stats64(app, repr->port->pf_id, stats);
 		break;
-	case NFP_REPR_TYPE_VF:
-		nfp_repr_vf_get_stats64(app, port, stats);
+	case NFP_PORT_VF_PORT:
+		nfp_repr_vf_get_stats64(app, repr->port->vf_id, stats);
 	default:
 		break;
 	}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
index c5ed6611f708..e970661ecd42 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
@@ -99,8 +99,8 @@ enum nfp_repr_type {
 
 void nfp_repr_inc_rx_stats(struct net_device *netdev, unsigned int len);
 void
-nfp_repr_get_stats64(const struct nfp_app *app, enum nfp_repr_type type,
-		     u8 port, struct rtnl_link_stats64 *stats);
+nfp_repr_get_stats64(struct net_device *netdev,
+		     struct rtnl_link_stats64 *stats);
 bool nfp_repr_has_offload_stats(const struct net_device *dev, int attr_id);
 int nfp_repr_get_offload_stats(int attr_id, const struct net_device *dev,
 			       void *stats);
-- 
2.11.0
