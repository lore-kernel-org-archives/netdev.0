From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/13] nfp: provide linking on port structures
Date: Fri, 19 May 2017 15:01:52 -0700
Message-ID: <20170519220155.27857-11-jakub.kicinski@netronome.com>
References: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:32810 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932080AbdESWC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 18:02:28 -0400
Received: by mail-pg0-f45.google.com with SMTP id u187so43650204pgb.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 15:02:28 -0700 (PDT)
In-Reply-To: <20170519220155.27857-1-jakub.kicinski@netronome.com>
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
 drivers/net/ethernet/netronome/nfp/nfp_port.c     |  7 +++++++
 drivers/net/ethernet/netronome/nfp/nfp_port.h     |  3 +++
 5 files changed, 19 insertions(+), 9 deletions(-)

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
index b1ddea0e2406..9f1127895dd6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -72,6 +72,7 @@ struct nfp_eth_table;
  * @max_data_vnics:	Number of data vNICs app firmware supports
  * @num_vnics:		Number of vNICs spawned
  * @vnics:		Linked list of vNIC structures (struct nfp_net)
+ * @ports:		Linked list of port structures (struct nfp_port)
  * @port_refresh_work:	Work entry for taking netdevs out
  */
 struct nfp_pf {
@@ -100,6 +101,7 @@ struct nfp_pf {
 	unsigned int num_vnics;
 
 	struct list_head vnics;
+	struct list_head ports;
 	struct work_struct port_refresh_work;
 	struct mutex lock;
 };
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 0114071dc0fd..9c4ba929cb0a 100644
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
index 8d0599fc6321..f73a5452f02b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -86,6 +86,7 @@ nfp_port_alloc(struct nfp_app *app, enum nfp_port_type type,
 	       struct net_device *netdev)
 {
 	struct nfp_port *port;
+	struct nfp_pf *pf;
 
 	port = kzalloc(sizeof(*port), GFP_KERNEL);
 	if (!port)
@@ -95,10 +96,16 @@ nfp_port_alloc(struct nfp_app *app, enum nfp_port_type type,
 	port->type = type;
 	port->app = app;
 
+	pf = nfp_app_pf(app);
+	list_add_tail(&port->port_list, &pf->ports);
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
index d674c8623a65..02d664f58482 100644
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
 
 bool nfp_netdev_is_nfp_net(struct net_device *netdev);
-- 
2.11.0
