From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 09/14] nfp: allow converting representor's netdev into nfp_port
Date: Tue, 27 Jun 2017 00:50:23 -0700
Message-ID: <20170627075028.4009-10-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33118 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752553AbdF0HvO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:14 -0400
Received: by mail-pf0-f178.google.com with SMTP id e7so12632632pfk.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:13 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on struct net_device_ops figure out if netdev is a nfp_repr.
Use this knowledge to convert netdev directly to nfp_port.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.h |  7 +++++++
 drivers/net/ethernet/netronome/nfp/nfp_port.c     | 18 +++++++++++++-----
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index 44416f679fdb..7bfdef2af1a9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -249,7 +249,7 @@ static int nfp_repr_open(struct net_device *netdev)
 	return nfp_app_repr_open(repr->app, repr);
 }
 
-static const struct net_device_ops nfp_repr_netdev_ops = {
+const struct net_device_ops nfp_repr_netdev_ops = {
 	.ndo_open		= nfp_repr_open,
 	.ndo_stop		= nfp_repr_stop,
 	.ndo_start_xmit		= nfp_repr_xmit,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
index 8f126362d5ed..6a6727816010 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
@@ -97,6 +97,13 @@ enum nfp_repr_type {
 };
 #define NFP_REPR_TYPE_MAX (__NFP_REPR_TYPE_MAX - 1)
 
+extern const struct net_device_ops nfp_repr_netdev_ops;
+
+static inline bool nfp_netdev_is_nfp_repr(struct net_device *netdev)
+{
+	return netdev->netdev_ops == &nfp_repr_netdev_ops;
+}
+
 void nfp_repr_inc_rx_stats(struct net_device *netdev, unsigned int len);
 int nfp_repr_init(struct nfp_app *app, struct net_device *netdev,
 		  u32 cmsg_port_id, struct nfp_port *port,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index 19bceeb82225..0be6c7e0b1c1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -42,13 +42,21 @@
 
 struct nfp_port *nfp_port_from_netdev(struct net_device *netdev)
 {
-	struct nfp_net *nn;
+	if (nfp_netdev_is_nfp_net(netdev)) {
+		struct nfp_net *nn = netdev_priv(netdev);
 
-	if (WARN_ON(!nfp_netdev_is_nfp_net(netdev)))
-		return NULL;
-	nn = netdev_priv(netdev);
+		return nn->port;
+	}
 
-	return nn->port;
+	if (nfp_netdev_is_nfp_repr(netdev)) {
+		struct nfp_repr *repr = netdev_priv(netdev);
+
+		return repr->port;
+	}
+
+	WARN(1, "Unknown netdev type for nfp_port\n");
+
+	return NULL;
 }
 
 struct nfp_port *
-- 
2.11.0
