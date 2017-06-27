From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 08/14] nfp: move representors' struct net_device_ops to shared code
Date: Tue, 27 Jun 2017 00:50:22 -0700
Message-ID: <20170627075028.4009-9-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34745 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752550AbdF0HvN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:13 -0400
Received: by mail-pf0-f179.google.com with SMTP id s66so12614937pfs.1
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:13 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apps shouldn't declare their own struct net_device_ops for
representors, this makes sharing code harder.  Add necessary
nfp_app callbacks and move the definition of representors'
struct net_device_ops to common code.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c  |  5 ++-
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h  |  2 +-
 drivers/net/ethernet/netronome/nfp/flower/main.c  | 32 ++++++++----------
 drivers/net/ethernet/netronome/nfp/nfp_app.h      | 20 ++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c | 40 ++++++++++++++++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.h |  8 -----
 6 files changed, 68 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
index 7761be436726..916a6196d2ba 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
@@ -79,9 +79,8 @@ nfp_flower_cmsg_alloc(struct nfp_app *app, unsigned int size,
 	return skb;
 }
 
-int nfp_flower_cmsg_portmod(struct net_device *netdev, bool carrier_ok)
+int nfp_flower_cmsg_portmod(struct nfp_repr *repr, bool carrier_ok)
 {
-	struct nfp_repr *repr = netdev_priv(netdev);
 	struct nfp_flower_cmsg_portmod *msg;
 	struct sk_buff *skb;
 
@@ -94,7 +93,7 @@ int nfp_flower_cmsg_portmod(struct net_device *netdev, bool carrier_ok)
 	msg->portnum = cpu_to_be32(repr->dst->u.port_info.port_id);
 	msg->reserved = 0;
 	msg->info = carrier_ok;
-	msg->mtu = cpu_to_be16(netdev->mtu);
+	msg->mtu = cpu_to_be16(repr->netdev->mtu);
 
 	nfp_ctrl_tx(repr->app->ctrl, skb);
 
diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
index 2eeddada7f4d..c10ae7631941 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
@@ -110,7 +110,7 @@ nfp_flower_cmsg_pcie_port(u8 nfp_pcie, enum nfp_flower_cmsg_port_vnic_type type,
 			   NFP_FLOWER_CMSG_PORT_TYPE_PCIE_PORT);
 }
 
-int nfp_flower_cmsg_portmod(struct net_device *netdev, bool carrier_ok);
+int nfp_flower_cmsg_portmod(struct nfp_repr *repr, bool carrier_ok);
 void nfp_flower_cmsg_rx(struct nfp_app *app, struct sk_buff *skb);
 
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index 2e66d51ec104..ab68a8f58862 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -104,37 +104,30 @@ nfp_flower_repr_get(struct nfp_app *app, u32 port_id)
 	return reprs->reprs[port];
 }
 
-static int nfp_flower_repr_netdev_open(struct net_device *netdev)
+static int
+nfp_flower_repr_netdev_open(struct nfp_app *app, struct nfp_repr *repr)
 {
 	int err;
 
-	err = nfp_flower_cmsg_portmod(netdev, true);
+	err = nfp_flower_cmsg_portmod(repr, true);
 	if (err)
 		return err;
 
-	netif_carrier_on(netdev);
-	netif_tx_wake_all_queues(netdev);
+	netif_carrier_on(repr->netdev);
+	netif_tx_wake_all_queues(repr->netdev);
 
 	return 0;
 }
 
-static int nfp_flower_repr_netdev_stop(struct net_device *netdev)
+static int
+nfp_flower_repr_netdev_stop(struct nfp_app *app, struct nfp_repr *repr)
 {
-	netif_carrier_off(netdev);
-	netif_tx_disable(netdev);
+	netif_carrier_off(repr->netdev);
+	netif_tx_disable(repr->netdev);
 
-	return nfp_flower_cmsg_portmod(netdev, false);
+	return nfp_flower_cmsg_portmod(repr, false);
 }
 
-static const struct net_device_ops nfp_flower_repr_netdev_ops = {
-	.ndo_open		= nfp_flower_repr_netdev_open,
-	.ndo_stop		= nfp_flower_repr_netdev_stop,
-	.ndo_start_xmit		= nfp_repr_xmit,
-	.ndo_get_stats64	= nfp_repr_get_stats64,
-	.ndo_has_offload_stats	= nfp_repr_has_offload_stats,
-	.ndo_get_offload_stats	= nfp_repr_get_offload_stats,
-};
-
 static void nfp_flower_sriov_disable(struct nfp_app *app)
 {
 	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_VF);
@@ -182,7 +175,6 @@ nfp_flower_spawn_vnic_reprs(struct nfp_app *app,
 		port_id = nfp_flower_cmsg_pcie_port(nfp_pcie, vnic_type,
 						    i, queue);
 		err = nfp_repr_init(app, reprs->reprs[i],
-				    &nfp_flower_repr_netdev_ops,
 				    port_id, port, priv->nn->dp.netdev);
 		if (err) {
 			nfp_port_free(port);
@@ -261,7 +253,6 @@ nfp_flower_spawn_phy_reprs(struct nfp_app *app, struct nfp_flower_priv *priv)
 
 		cmsg_port_id = nfp_flower_cmsg_phys_port(phys_port);
 		err = nfp_repr_init(app, reprs->reprs[phys_port],
-				    &nfp_flower_repr_netdev_ops,
 				    cmsg_port_id, port, priv->nn->dp.netdev);
 		if (err) {
 			nfp_port_free(port);
@@ -363,6 +354,9 @@ const struct nfp_app_type app_flower = {
 
 	.vnic_init	= nfp_flower_vnic_init,
 
+	.repr_open	= nfp_flower_repr_netdev_open,
+	.repr_stop	= nfp_flower_repr_netdev_stop,
+
 	.start		= nfp_flower_start,
 	.stop		= nfp_flower_stop,
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index 2fb503a817d2..5d714e10d9a9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -47,6 +47,7 @@ struct sk_buff;
 struct nfp_app;
 struct nfp_cpp;
 struct nfp_pf;
+struct nfp_repr;
 struct nfp_net;
 
 enum nfp_app_id {
@@ -71,6 +72,8 @@ extern const struct nfp_app_type app_flower;
  * @extra_cap:	extra capabilities string
  * @vnic_init:	init vNICs (assign port types, etc.)
  * @vnic_clean:	clean up app's vNIC state
+ * @repr_open:	representor netdev open callback
+ * @repr_stop:	representor netdev stop callback
  * @start:	start application logic
  * @stop:	stop application logic
  * @ctrl_msg_rx:    control message handler
@@ -97,6 +100,9 @@ struct nfp_app_type {
 			 unsigned int id);
 	void (*vnic_clean)(struct nfp_app *app, struct nfp_net *nn);
 
+	int (*repr_open)(struct nfp_app *app, struct nfp_repr *repr);
+	int (*repr_stop)(struct nfp_app *app, struct nfp_repr *repr);
+
 	int (*start)(struct nfp_app *app);
 	void (*stop)(struct nfp_app *app);
 
@@ -164,6 +170,20 @@ static inline void nfp_app_vnic_clean(struct nfp_app *app, struct nfp_net *nn)
 		app->type->vnic_clean(app, nn);
 }
 
+static inline int nfp_app_repr_open(struct nfp_app *app, struct nfp_repr *repr)
+{
+	if (!app->type->repr_open)
+		return -EINVAL;
+	return app->type->repr_open(app, repr);
+}
+
+static inline int nfp_app_repr_stop(struct nfp_app *app, struct nfp_repr *repr)
+{
+	if (!app->type->repr_stop)
+		return -EINVAL;
+	return app->type->repr_stop(app, repr);
+}
+
 static inline int nfp_app_start(struct nfp_app *app, struct nfp_net *ctrl)
 {
 	app->ctrl = ctrl;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index 6f1548c6840c..44416f679fdb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -136,7 +136,7 @@ nfp_repr_pf_get_stats64(const struct nfp_app *app, u8 pf,
 	stats->rx_dropped = readq(mem + NFP_NET_CFG_STATS_TX_DISCARDS);
 }
 
-void
+static void
 nfp_repr_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 {
 	struct nfp_repr *repr = netdev_priv(netdev);
@@ -163,7 +163,7 @@ nfp_repr_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 	}
 }
 
-bool
+static bool
 nfp_repr_has_offload_stats(const struct net_device *dev, int attr_id)
 {
 	switch (attr_id) {
@@ -206,8 +206,9 @@ nfp_repr_get_host_stats64(const struct net_device *netdev,
 	return 0;
 }
 
-int nfp_repr_get_offload_stats(int attr_id, const struct net_device *dev,
-			       void *stats)
+static int
+nfp_repr_get_offload_stats(int attr_id, const struct net_device *dev,
+			   void *stats)
 {
 	switch (attr_id) {
 	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
@@ -217,7 +218,7 @@ int nfp_repr_get_offload_stats(int attr_id, const struct net_device *dev,
 	return -EINVAL;
 }
 
-netdev_tx_t nfp_repr_xmit(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t nfp_repr_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct nfp_repr *repr = netdev_priv(netdev);
 	unsigned int len = skb->len;
@@ -234,6 +235,29 @@ netdev_tx_t nfp_repr_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return ret;
 }
 
+static int nfp_repr_stop(struct net_device *netdev)
+{
+	struct nfp_repr *repr = netdev_priv(netdev);
+
+	return nfp_app_repr_stop(repr->app, repr);
+}
+
+static int nfp_repr_open(struct net_device *netdev)
+{
+	struct nfp_repr *repr = netdev_priv(netdev);
+
+	return nfp_app_repr_open(repr->app, repr);
+}
+
+static const struct net_device_ops nfp_repr_netdev_ops = {
+	.ndo_open		= nfp_repr_open,
+	.ndo_stop		= nfp_repr_stop,
+	.ndo_start_xmit		= nfp_repr_xmit,
+	.ndo_get_stats64	= nfp_repr_get_stats64,
+	.ndo_has_offload_stats	= nfp_repr_has_offload_stats,
+	.ndo_get_offload_stats	= nfp_repr_get_offload_stats,
+};
+
 static void nfp_repr_clean(struct nfp_repr *repr)
 {
 	unregister_netdev(repr->netdev);
@@ -258,8 +282,8 @@ static void nfp_repr_set_lockdep_class(struct net_device *dev)
 }
 
 int nfp_repr_init(struct nfp_app *app, struct net_device *netdev,
-		  const struct net_device_ops *netdev_ops, u32 cmsg_port_id,
-		  struct nfp_port *port, struct net_device *pf_netdev)
+		  u32 cmsg_port_id, struct nfp_port *port,
+		  struct net_device *pf_netdev)
 {
 	struct nfp_repr *repr = netdev_priv(netdev);
 	int err;
@@ -273,7 +297,7 @@ int nfp_repr_init(struct nfp_app *app, struct net_device *netdev,
 	repr->dst->u.port_info.port_id = cmsg_port_id;
 	repr->dst->u.port_info.lower_dev = pf_netdev;
 
-	netdev->netdev_ops = netdev_ops;
+	netdev->netdev_ops = &nfp_repr_netdev_ops;
 
 	err = register_netdev(netdev);
 	if (err)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
index e970661ecd42..8f126362d5ed 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
@@ -98,15 +98,7 @@ enum nfp_repr_type {
 #define NFP_REPR_TYPE_MAX (__NFP_REPR_TYPE_MAX - 1)
 
 void nfp_repr_inc_rx_stats(struct net_device *netdev, unsigned int len);
-void
-nfp_repr_get_stats64(struct net_device *netdev,
-		     struct rtnl_link_stats64 *stats);
-bool nfp_repr_has_offload_stats(const struct net_device *dev, int attr_id);
-int nfp_repr_get_offload_stats(int attr_id, const struct net_device *dev,
-			       void *stats);
-netdev_tx_t nfp_repr_xmit(struct sk_buff *skb, struct net_device *netdev);
 int nfp_repr_init(struct nfp_app *app, struct net_device *netdev,
-		  const struct net_device_ops *netdev_ops,
 		  u32 cmsg_port_id, struct nfp_port *port,
 		  struct net_device *pf_netdev);
 struct net_device *nfp_repr_alloc(struct nfp_app *app);
-- 
2.11.0
