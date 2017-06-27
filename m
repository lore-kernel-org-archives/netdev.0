From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/14] nfp: wire get_phys_port_name on representors
Date: Tue, 27 Jun 2017 00:50:24 -0700
Message-ID: <20170627075028.4009-11-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33121 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751659AbdF0HvP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:15 -0400
Received: by mail-pf0-f180.google.com with SMTP id e7so12632794pfk.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:15 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make nfp_port_get_phys_port_name() support new port types and
wire it up to representors' struct net_device_ops.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c |  1 +
 drivers/net/ethernet/netronome/nfp/nfp_port.c     | 30 +++++++++++++++++------
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index 7bfdef2af1a9..046b89eb4cf2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -256,6 +256,7 @@ const struct net_device_ops nfp_repr_netdev_ops = {
 	.ndo_get_stats64	= nfp_repr_get_stats64,
 	.ndo_has_offload_stats	= nfp_repr_has_offload_stats,
 	.ndo_get_offload_stats	= nfp_repr_get_offload_stats,
+	.ndo_get_phys_port_name	= nfp_port_get_phys_port_name,
 };
 
 static void nfp_repr_clean(struct nfp_repr *repr)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index 0be6c7e0b1c1..0b44952945d8 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -106,15 +106,31 @@ nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
 	int n;
 
 	port = nfp_port_from_netdev(netdev);
-	eth_port = __nfp_port_get_eth_port(port);
-	if (!eth_port)
+	if (!port)
+		return -EOPNOTSUPP;
+
+	switch (port->type) {
+	case NFP_PORT_PHYS_PORT:
+		eth_port = __nfp_port_get_eth_port(port);
+		if (!eth_port)
+			return -EOPNOTSUPP;
+
+		if (!eth_port->is_split)
+			n = snprintf(name, len, "p%d", eth_port->label_port);
+		else
+			n = snprintf(name, len, "p%ds%d", eth_port->label_port,
+				     eth_port->label_subport);
+		break;
+	case NFP_PORT_PF_PORT:
+		n = snprintf(name, len, "pf%d", port->pf_id);
+		break;
+	case NFP_PORT_VF_PORT:
+		n = snprintf(name, len, "pf%dvf%d", port->pf_id, port->vf_id);
+		break;
+	default:
 		return -EOPNOTSUPP;
+	}
 
-	if (!eth_port->is_split)
-		n = snprintf(name, len, "p%d", eth_port->label_port);
-	else
-		n = snprintf(name, len, "p%ds%d", eth_port->label_port,
-			     eth_port->label_subport);
 	if (n >= len)
 		return -EINVAL;
 
-- 
2.11.0
