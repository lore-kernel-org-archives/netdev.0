From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 13/13] nfp: refresh port state before reporting autonegotiation
Date: Fri, 19 May 2017 15:01:55 -0700
Message-ID: <20170519220155.27857-14-jakub.kicinski@netronome.com>
References: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36706 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932649AbdESWCb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 18:02:31 -0400
Received: by mail-pg0-f50.google.com with SMTP id x64so43606441pgd.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 15:02:30 -0700 (PDT)
In-Reply-To: <20170519220155.27857-1-jakub.kicinski@netronome.com>
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
index 050629df5cff..46fafee87371 100644
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
index f73a5452f02b..2c9e0e36d743 100644
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
index 02d664f58482..34276e1d673d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -88,6 +88,7 @@ bool nfp_netdev_is_nfp_net(struct net_device *netdev);
 
 struct nfp_port *nfp_port_from_netdev(struct net_device *netdev);
 struct nfp_eth_table_port *__nfp_port_get_eth_port(struct nfp_port *port);
+struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port);
 
 int
 nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len);
-- 
2.11.0
