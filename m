From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 13/13] nfp: refresh port state before reporting autonegotiation
Date: Mon, 22 May 2017 10:59:34 -0700
Message-ID: <20170522175934.27447-14-jakub.kicinski@netronome.com>
References: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33479 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760129AbdEVSBN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:01:13 -0400
Received: by mail-pf0-f176.google.com with SMTP id e193so89417356pfh.0
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 11:01:13 -0700 (PDT)
In-Reply-To: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

State of autonegotiation may have changed but is not yet refreshed.
Make sure ethtool respects the NFP_PORT_CHANGED flag when looking
at autoneg.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 10 +---------
 drivers/net/ethernet/netronome/nfp/nfp_port.c        | 12 ++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_port.h        |  1 +
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 23f9ea0f8982..84fdbc4b835b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -209,7 +209,7 @@ nfp_net_get_link_ksettings(struct net_device *netdev,
 	cmd->base.duplex = DUPLEX_UNKNOWN;
 
 	port = nfp_port_from_netdev(netdev);
-	eth_port = __nfp_port_get_eth_port(port);
+	eth_port = nfp_port_get_eth_port(port);
 	if (eth_port)
 		cmd->base.autoneg = eth_port->aneg != NFP_ANEG_DISABLED ?
 			AUTONEG_ENABLE : AUTONEG_DISABLE;
@@ -219,14 +219,6 @@ nfp_net_get_link_ksettings(struct net_device *netdev,
 
 	/* Use link speed from ETH table if available, otherwise try the BAR */
 	if (eth_port) {
-		int err;
-
-		if (test_bit(NFP_PORT_CHANGED, &port->flags)) {
-			err = nfp_net_refresh_eth_port(port);
-			if (err)
-				return err;
-		}
-
 		cmd->base.port = eth_port->port_type;
 		cmd->base.speed = eth_port->speed;
 		cmd->base.duplex = DUPLEX_FULL;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index 295db04ccb05..3beed4167e2f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -58,6 +58,18 @@ struct nfp_eth_table_port *__nfp_port_get_eth_port(struct nfp_port *port)
 	return port->eth_port;
 }
 
+struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port)
+{
+	if (!__nfp_port_get_eth_port(port))
+		return NULL;
+
+	if (test_bit(NFP_PORT_CHANGED, &port->flags))
+		if (nfp_net_refresh_eth_port(port))
+			return NULL;
+
+	return __nfp_port_get_eth_port(port);
+}
+
 int
 nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
 {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 471fff1fc58f..641617de41cc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -86,6 +86,7 @@ struct nfp_port {
 
 struct nfp_port *nfp_port_from_netdev(struct net_device *netdev);
 struct nfp_eth_table_port *__nfp_port_get_eth_port(struct nfp_port *port);
+struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port);
 
 int
 nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len);
-- 
2.11.0
