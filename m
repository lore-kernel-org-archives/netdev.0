From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 1/3] nfp: improve order of interfaces in breakout mode
Date: Tue,  4 Jul 2017 02:27:19 -0700
Message-ID: <20170704092721.780-2-jakub.kicinski@netronome.com>
References: <20170704092721.780-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34311 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751845AbdGDJ2h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 05:28:37 -0400
Received: by mail-pf0-f171.google.com with SMTP id s66so112677489pfs.1
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 02:28:37 -0700 (PDT)
In-Reply-To: <20170704092721.780-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For historical reasons we enumerate the vNICs in order.  This means
that if user configures breakout on a multiport card, the first
interface of the second port will have its MAC address changed.

What's worse, when moved from static information (HWInfo) to using
management FW (NSP), more features started depending on the port ids.
Right now in case of breakout first subport of the second port and
second subport of the first port will have their link info swapped.

Revise the ordering scheme so that first subport maintains its address.
Side effect of this change is that we will use base lane ids in
devlink (i.e. 40G ports will be 4 ids apart), e.g.:

pci/0000:04:00.0/0: type eth netdev p6p1
pci/0000:04:00.0/4: type eth netdev p6p2

Note that behaviour of phys_port_id is not changed since there is
a separate id number for the subport there.

Fixes: ec8b1fbe682d ("nfp: support port splitting via devlink")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.h     |  2 --
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 10 +++++-----
 drivers/net/ethernet/netronome/nfp/nfp_port.c     | 14 +++++++-------
 3 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index a08cfba7e68e..365252ab4660 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -149,8 +149,6 @@ void nfp_net_pci_remove(struct nfp_pf *pf);
 int nfp_hwmon_register(struct nfp_pf *pf);
 void nfp_hwmon_unregister(struct nfp_pf *pf);
 
-struct nfp_eth_table_port *
-nfp_net_find_port(struct nfp_eth_table *eth_tbl, unsigned int id);
 void
 nfp_net_get_mac_addr(struct nfp_pf *pf, struct nfp_port *port, unsigned int id);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index c85a2f18c4df..bfcdada29cc0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -126,13 +126,13 @@ nfp_net_get_mac_addr(struct nfp_pf *pf, struct nfp_port *port, unsigned int id)
 	ether_addr_copy(port->netdev->perm_addr, mac_addr);
 }
 
-struct nfp_eth_table_port *
-nfp_net_find_port(struct nfp_eth_table *eth_tbl, unsigned int id)
+static struct nfp_eth_table_port *
+nfp_net_find_port(struct nfp_eth_table *eth_tbl, unsigned int index)
 {
 	int i;
 
 	for (i = 0; eth_tbl && i < eth_tbl->count; i++)
-		if (eth_tbl->ports[i].eth_index == id)
+		if (eth_tbl->ports[i].index == index)
 			return &eth_tbl->ports[i];
 
 	return NULL;
@@ -202,7 +202,7 @@ static void nfp_net_pf_free_vnics(struct nfp_pf *pf)
 static struct nfp_net *
 nfp_net_pf_alloc_vnic(struct nfp_pf *pf, bool needs_netdev,
 		      void __iomem *ctrl_bar, void __iomem *qc_bar,
-		      int stride, unsigned int eth_id)
+		      int stride, unsigned int id)
 {
 	u32 tx_base, rx_base, n_tx_rings, n_rx_rings;
 	struct nfp_net *nn;
@@ -228,7 +228,7 @@ nfp_net_pf_alloc_vnic(struct nfp_pf *pf, bool needs_netdev,
 	nn->stride_tx = stride;
 
 	if (needs_netdev) {
-		err = nfp_app_vnic_init(pf->app, nn, eth_id);
+		err = nfp_app_vnic_init(pf->app, nn, id);
 		if (err) {
 			nfp_net_free(nn);
 			return ERR_PTR(err);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index 776e54dd5dd0..e42644dbb865 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -184,24 +184,24 @@ nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
 int nfp_port_init_phy_port(struct nfp_pf *pf, struct nfp_app *app,
 			   struct nfp_port *port, unsigned int id)
 {
-	port->eth_id = id;
-	port->eth_port = nfp_net_find_port(pf->eth_tbl, id);
-
 	/* Check if vNIC has external port associated and cfg is OK */
-	if (!port->eth_port) {
+	if (!pf->eth_tbl || id >= pf->eth_tbl->count) {
 		nfp_err(app->cpp,
-			"NSP port entries don't match vNICs (no entry for port #%d)\n",
+			"NSP port entries don't match vNICs (no entry %d)\n",
 			id);
 		return -EINVAL;
 	}
-	if (port->eth_port->override_changed) {
+	if (pf->eth_tbl->ports[id].override_changed) {
 		nfp_warn(app->cpp,
 			 "Config changed for port #%d, reboot required before port will be operational\n",
-			 id);
+			 pf->eth_tbl->ports[id].index);
 		port->type = NFP_PORT_INVALID;
 		return 0;
 	}
 
+	port->eth_port = &pf->eth_tbl->ports[id];
+	port->eth_id = pf->eth_tbl->ports[id].index;
+
 	return 0;
 }
 
-- 
2.11.0
