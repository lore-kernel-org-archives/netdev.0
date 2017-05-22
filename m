From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 10/13] nfp: provide linking on port structures
Date: Mon, 22 May 2017 10:59:31 -0700
Message-ID: <20170522175934.27447-11-jakub.kicinski@netronome.com>
References: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33451 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760906AbdEVSBL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:01:11 -0400
Received: by mail-pf0-f177.google.com with SMTP id e193so89415943pfh.0
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 11:01:10 -0700 (PDT)
In-Reply-To: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add link to nfp_ports to make it possible to iterate over all ports.
This will come in handy when some ports may be representors.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c     |  1 +
 drivers/net/ethernet/netronome/nfp/nfp_main.h     |  2 ++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 15 ++++++---------
 drivers/net/ethernet/netronome/nfp/nfp_port.c     |  5 +++++
 drivers/net/ethernet/netronome/nfp/nfp_port.h     |  3 +++
 5 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index 9fbc7eedc017..bb586ce1ea06 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -341,6 +341,7 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 		goto err_rel_regions;
 	}
 	INIT_LIST_HEAD(&pf->vnics);
+	INIT_LIST_HEAD(&pf->ports);
 	pci_set_drvdata(pdev, pf);
 	pf->pdev = pdev;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index 3716ef6b8599..991c4cba0bbf 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -70,6 +70,7 @@ struct nfp_eth_table;
  * @max_data_vnics:	Number of data vNICs app firmware supports
  * @num_vnics:		Number of vNICs spawned
  * @vnics:		Linked list of vNIC structures (struct nfp_net)
+ * @ports:		Linked list of port structures (struct nfp_port)
  * @port_refresh_work:	Work entry for taking netdevs out
  * @lock:		Protects all fields which may change after probe
  */
@@ -99,6 +100,7 @@ struct nfp_pf {
 	unsigned int num_vnics;
 
 	struct list_head vnics;
+	struct list_head ports;
 	struct work_struct port_refresh_work;
 	struct mutex lock;
 };
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index e8d54b9b9b97..40ba5775ff79 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -548,6 +548,7 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 					 port_refresh_work);
 	struct nfp_eth_table *eth_table;
 	struct nfp_net *nn, *next;
+	struct nfp_port *port;
 
 	mutex_lock(&pf->lock);
 
@@ -557,9 +558,8 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 
 	/* Update state of all ports */
 	rtnl_lock();
-	list_for_each_entry(nn, &pf->vnics, vnic_list)
-		if (nn->port)
-			clear_bit(NFP_PORT_CHANGED, &nn->port->flags);
+	list_for_each_entry(port, &pf->ports, port_list)
+		clear_bit(NFP_PORT_CHANGED, &port->flags);
 
 	eth_table = nfp_eth_read_ports(pf->cpp);
 	if (!eth_table) {
@@ -568,12 +568,9 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 		goto out;
 	}
 
-	list_for_each_entry(nn, &pf->vnics, vnic_list) {
-		if (!__nfp_port_get_eth_port(nn->port))
-			continue;
-
-		nfp_net_eth_port_update(pf->cpp, nn->port, eth_table);
-	}
+	list_for_each_entry(port, &pf->ports, port_list)
+		if (__nfp_port_get_eth_port(port))
+			nfp_net_eth_port_update(pf->cpp, port, eth_table);
 	rtnl_unlock();
 
 	kfree(eth_table);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index 95726e01592d..295db04ccb05 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -95,10 +95,15 @@ nfp_port_alloc(struct nfp_app *app, enum nfp_port_type type,
 	port->type = type;
 	port->app = app;
 
+	list_add_tail(&port->port_list, &app->pf->ports);
+
 	return port;
 }
 
 void nfp_port_free(struct nfp_port *port)
 {
+	if (!port)
+		return;
+	list_del(&port->port_list);
 	kfree(port);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 47adacf88557..471fff1fc58f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -68,6 +68,7 @@ enum nfp_port_flags {
  * @app:	backpointer to the app structure
  * @eth_id:	for %NFP_PORT_PHYS_PORT port ID in NFP enumeration scheme
  * @eth_port:	for %NFP_PORT_PHYS_PORT translated ETH Table port entry
+ * @port_list:	entry on pf's list of ports
  */
 struct nfp_port {
 	struct net_device *netdev;
@@ -79,6 +80,8 @@ struct nfp_port {
 
 	unsigned int eth_id;
 	struct nfp_eth_table_port *eth_port;
+
+	struct list_head port_list;
 };
 
 struct nfp_port *nfp_port_from_netdev(struct net_device *netdev);
-- 
2.11.0
