From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2 03/12] nfp: move physical port init into a helper
Date: Tue, 20 Jun 2017 23:36:11 +0200
Message-ID: <1497994580-6271-4-git-send-email-simon.horman@netronome.com>
References: <1497994580-6271-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:34558 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752626AbdFTVgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 17:36:52 -0400
Received: by mail-qk0-f180.google.com with SMTP id d14so68396615qkb.1
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 14:36:46 -0700 (PDT)
In-Reply-To: <1497994580-6271-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>

Move MAC/PHY port init into a helper to make it easier to reuse
it in the representor code.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_app_nic.c | 23 ++++++----------------
 drivers/net/ethernet/netronome/nfp/nfp_port.c    | 25 ++++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_port.h    |  3 +++
 3 files changed, 34 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c b/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c
index 83c65e6291ee..7b966bd3d214 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app_nic.c
@@ -42,6 +42,8 @@ static int
 nfp_app_nic_vnic_init_phy_port(struct nfp_pf *pf, struct nfp_app *app,
 			       struct nfp_net *nn, unsigned int id)
 {
+	int err;
+
 	if (!pf->eth_tbl)
 		return 0;
 
@@ -49,26 +51,13 @@ nfp_app_nic_vnic_init_phy_port(struct nfp_pf *pf, struct nfp_app *app,
 	if (IS_ERR(nn->port))
 		return PTR_ERR(nn->port);
 
-	nn->port->eth_id = id;
-	nn->port->eth_port = nfp_net_find_port(pf->eth_tbl, id);
-
-	/* Check if vNIC has external port associated and cfg is OK */
-	if (!nn->port->eth_port) {
-		nfp_err(app->cpp,
-			"NSP port entries don't match vNICs (no entry for port #%d)\n",
-			id);
+	err = nfp_port_init_phy_port(pf, app, nn->port, id);
+	if (err) {
 		nfp_port_free(nn->port);
-		return -EINVAL;
-	}
-	if (nn->port->eth_port->override_changed) {
-		nfp_warn(app->cpp,
-			 "Config changed for port #%d, reboot required before port will be operational\n",
-			 id);
-		nn->port->type = NFP_PORT_INVALID;
-		return 1;
+		return err;
 	}
 
-	return 0;
+	return nn->port->type == NFP_PORT_INVALID;
 }
 
 int nfp_app_nic_vnic_init(struct nfp_app *app, struct nfp_net *nn,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index a17410ac01ab..19bceeb82225 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -33,6 +33,7 @@
 
 #include <linux/lockdep.h>
 
+#include "nfpcore/nfp_cpp.h"
 #include "nfpcore/nfp_nsp.h"
 #include "nfp_app.h"
 #include "nfp_main.h"
@@ -112,6 +113,30 @@ nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
 	return 0;
 }
 
+int nfp_port_init_phy_port(struct nfp_pf *pf, struct nfp_app *app,
+			   struct nfp_port *port, unsigned int id)
+{
+	port->eth_id = id;
+	port->eth_port = nfp_net_find_port(pf->eth_tbl, id);
+
+	/* Check if vNIC has external port associated and cfg is OK */
+	if (!port->eth_port) {
+		nfp_err(app->cpp,
+			"NSP port entries don't match vNICs (no entry for port #%d)\n",
+			id);
+		return -EINVAL;
+	}
+	if (port->eth_port->override_changed) {
+		nfp_warn(app->cpp,
+			 "Config changed for port #%d, reboot required before port will be operational\n",
+			 id);
+		port->type = NFP_PORT_INVALID;
+		return 0;
+	}
+
+	return 0;
+}
+
 struct nfp_port *
 nfp_port_alloc(struct nfp_app *app, enum nfp_port_type type,
 	       struct net_device *netdev)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 4d1a9b3fed41..fb28c7071987 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -104,6 +104,9 @@ nfp_port_alloc(struct nfp_app *app, enum nfp_port_type type,
 	       struct net_device *netdev);
 void nfp_port_free(struct nfp_port *port);
 
+int nfp_port_init_phy_port(struct nfp_pf *pf, struct nfp_app *app,
+			   struct nfp_port *port, unsigned int id);
+
 int nfp_net_refresh_eth_port(struct nfp_port *port);
 void nfp_net_refresh_port_table(struct nfp_port *port);
 int nfp_net_refresh_port_table_sync(struct nfp_pf *pf);
-- 
2.1.4
