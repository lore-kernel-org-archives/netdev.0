From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 08/13] nfp: update port state in place
Date: Mon, 22 May 2017 10:59:29 -0700
Message-ID: <20170522175934.27447-9-jakub.kicinski@netronome.com>
References: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36451 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760925AbdEVSBO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:01:14 -0400
Received: by mail-pf0-f169.google.com with SMTP id m17so89350617pfg.3
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 11:01:09 -0700 (PDT)
In-Reply-To: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always updating port state in place by overriding values in exiting
pf->eth_tbl makes things easier to manage and allows us to have a
common helper for both full and per-port refresh.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 54 +++++++++++++----------
 1 file changed, 30 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 8e1e55187262..92037e3624ad 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -518,6 +518,30 @@ static void nfp_net_pci_remove_finish(struct nfp_pf *pf)
 	nfp_cpp_area_release_free(pf->data_vnic_bar);
 }
 
+static int
+nfp_net_eth_port_update(struct nfp_cpp *cpp, struct nfp_port *port,
+			struct nfp_eth_table *eth_table)
+{
+	struct nfp_eth_table_port *eth_port;
+
+	ASSERT_RTNL();
+
+	eth_port = nfp_net_find_port(eth_table, port->eth_id);
+	if (!eth_port) {
+		nfp_warn(cpp, "Warning: port #%d not present after reconfig\n",
+			 port->eth_id);
+		return -EIO;
+	}
+	if (eth_port->override_changed) {
+		nfp_warn(cpp, "Port #%d config changed, unregistering. Reboot required before port will be operational again.\n", port->eth_id);
+		port->type = NFP_PORT_INVALID;
+	}
+
+	memcpy(port->eth_port, eth_port, sizeof(*eth_port));
+
+	return 0;
+}
+
 static void nfp_net_refresh_vnics(struct work_struct *work)
 {
 	struct nfp_pf *pf = container_of(work, struct nfp_pf,
@@ -544,23 +568,12 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 	list_for_each_entry(nn, &pf->vnics, vnic_list) {
 		if (!__nfp_port_get_eth_port(nn->port))
 			continue;
-		nn->port->eth_port = nfp_net_find_port(eth_table,
-						       nn->port->eth_id);
-		if (!nn->port->eth_port) {
-			nfp_warn(pf->cpp, "Warning: port #%d not present after reconfig\n",
-				 nn->port->eth_id);
-			continue;
-		}
-		if (nn->port->eth_port->override_changed) {
-			nfp_warn(pf->cpp, "Port config changed, unregistering. Reboot required before port will be operational again.\n");
-			nn->port->type = NFP_PORT_INVALID;
-			continue;
-		}
+
+		nfp_net_eth_port_update(pf->cpp, nn->port, eth_table);
 	}
 	rtnl_unlock();
 
-	kfree(pf->eth_tbl);
-	pf->eth_tbl = eth_table;
+	kfree(eth_table);
 
 	list_for_each_entry_safe(nn, next, &pf->vnics, vnic_list) {
 		if (!nn->port || nn->port->type != NFP_PORT_INVALID)
@@ -588,8 +601,8 @@ void nfp_net_refresh_port_table(struct nfp_port *port)
 int nfp_net_refresh_eth_port(struct nfp_port *port)
 {
 	struct nfp_cpp *cpp = port->app->cpp;
-	struct nfp_eth_table_port *eth_port;
 	struct nfp_eth_table *eth_table;
+	int ret;
 
 	eth_table = nfp_eth_read_ports(cpp);
 	if (!eth_table) {
@@ -597,18 +610,11 @@ int nfp_net_refresh_eth_port(struct nfp_port *port)
 		return -EIO;
 	}
 
-	eth_port = nfp_net_find_port(eth_table, port->eth_id);
-	if (!eth_port) {
-		nfp_err(cpp, "Error finding state of the port!\n");
-		kfree(eth_table);
-		return -EIO;
-	}
-
-	memcpy(port->eth_port, eth_port, sizeof(*eth_port));
+	ret = nfp_net_eth_port_update(cpp, port, eth_table);
 
 	kfree(eth_table);
 
-	return 0;
+	return ret;
 }
 
 /*
-- 
2.11.0
