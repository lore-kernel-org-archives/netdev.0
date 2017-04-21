From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 5/5] nfp: remove the refresh of all ports optimization
Date: Fri, 21 Apr 2017 12:23:10 -0700
Message-ID: <20170421192310.193875-6-jakub.kicinski@netronome.com>
References: <20170421192310.193875-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33136 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424931AbdDUTX6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:23:58 -0400
Received: by mail-io0-f170.google.com with SMTP id k87so132907437ioi.0
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:23:58 -0700 (PDT)
In-Reply-To: <20170421192310.193875-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code refreshing the eth port state was trying to update state
of all ports of the card.  Unfortunately to safely walk the port
list we would have to hold the port lock, which we can't due to
lock ordering constraints against rtnl.

Make the per-port sync refresh and async refresh of all ports
completely separate routines.

Fixes: 172f638c93dd ("nfp: add port state refresh")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  3 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 13 +++--
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 67 +++++++++++++++-------
 3 files changed, 58 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 8302a2d688da..8f20fdef0754 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -819,7 +819,8 @@ struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn);
 int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new);
 
 bool nfp_net_link_changed_read_clear(struct nfp_net *nn);
-void nfp_net_refresh_port_config(struct nfp_net *nn);
+int nfp_net_refresh_eth_port(struct nfp_net *nn);
+void nfp_net_refresh_port_table(struct nfp_net *nn);
 
 #ifdef CONFIG_NFP_DEBUG
 void nfp_net_debugfs_create(void);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 3328041ec290..6e27d1281425 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -211,10 +211,15 @@ nfp_net_get_link_ksettings(struct net_device *netdev,
 		return 0;
 
 	/* Use link speed from ETH table if available, otherwise try the BAR */
-	if (nn->eth_port && nfp_net_link_changed_read_clear(nn))
-		nfp_net_refresh_port_config(nn);
-	/* Separate if - on FW error the port could've disappeared from table */
 	if (nn->eth_port) {
+		int err;
+
+		if (nfp_net_link_changed_read_clear(nn)) {
+			err = nfp_net_refresh_eth_port(nn);
+			if (err)
+				return err;
+		}
+
 		cmd->base.port = nn->eth_port->port_type;
 		cmd->base.speed = nn->eth_port->speed;
 		cmd->base.duplex = DUPLEX_FULL;
@@ -273,7 +278,7 @@ nfp_net_set_link_ksettings(struct net_device *netdev,
 	if (err > 0)
 		return 0; /* no change */
 
-	nfp_net_refresh_port_config(nn);
+	nfp_net_refresh_port_table(nn);
 
 	return err;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 4c6863a072d3..8cb87cbe1120 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -176,13 +176,13 @@ nfp_net_get_mac_addr(struct nfp_net *nn, struct nfp_cpp *cpp, unsigned int id)
 }
 
 static struct nfp_eth_table_port *
-nfp_net_find_port(struct nfp_pf *pf, unsigned int id)
+nfp_net_find_port(struct nfp_eth_table *eth_tbl, unsigned int id)
 {
 	int i;
 
-	for (i = 0; pf->eth_tbl && i < pf->eth_tbl->count; i++)
-		if (pf->eth_tbl->ports[i].eth_index == id)
-			return &pf->eth_tbl->ports[i];
+	for (i = 0; eth_tbl && i < eth_tbl->count; i++)
+		if (eth_tbl->ports[i].eth_index == id)
+			return &eth_tbl->ports[i];
 
 	return NULL;
 }
@@ -367,7 +367,7 @@ nfp_net_pf_alloc_netdevs(struct nfp_pf *pf, void __iomem *ctrl_bar,
 		prev_tx_base = tgt_tx_base;
 		prev_rx_base = tgt_rx_base;
 
-		eth_port = nfp_net_find_port(pf, i);
+		eth_port = nfp_net_find_port(pf->eth_tbl, i);
 		if (eth_port && eth_port->override_changed) {
 			nfp_warn(pf->cpp, "Config changed for port #%d, reboot required before port will be operational\n", i);
 		} else {
@@ -485,6 +485,7 @@ static void nfp_net_refresh_netdevs(struct work_struct *work)
 {
 	struct nfp_pf *pf = container_of(work, struct nfp_pf,
 					 port_refresh_work);
+	struct nfp_eth_table *eth_table;
 	struct nfp_net *nn, *next;
 
 	mutex_lock(&pf->port_lock);
@@ -493,6 +494,27 @@ static void nfp_net_refresh_netdevs(struct work_struct *work)
 	if (list_empty(&pf->ports))
 		goto out;
 
+	list_for_each_entry(nn, &pf->ports, port_list)
+		nfp_net_link_changed_read_clear(nn);
+
+	eth_table = nfp_eth_read_ports(pf->cpp);
+	if (!eth_table) {
+		nfp_err(pf->cpp, "Error refreshing port config!\n");
+		goto out;
+	}
+
+	rtnl_lock();
+	list_for_each_entry(nn, &pf->ports, port_list) {
+		if (!nn->eth_port)
+			continue;
+		nn->eth_port = nfp_net_find_port(eth_table,
+						 nn->eth_port->eth_index);
+	}
+	rtnl_unlock();
+
+	kfree(pf->eth_tbl);
+	pf->eth_tbl = eth_table;
+
 	list_for_each_entry_safe(nn, next, &pf->ports, port_list) {
 		if (!nn->eth_port) {
 			nfp_warn(pf->cpp, "Warning: port not present after reconfig\n");
@@ -517,31 +539,36 @@ static void nfp_net_refresh_netdevs(struct work_struct *work)
 	mutex_unlock(&pf->port_lock);
 }
 
-void nfp_net_refresh_port_config(struct nfp_net *nn)
+void nfp_net_refresh_port_table(struct nfp_net *nn)
 {
 	struct nfp_pf *pf = pci_get_drvdata(nn->pdev);
-	struct nfp_eth_table *old_table;
 
-	ASSERT_RTNL();
+	schedule_work(&pf->port_refresh_work);
+}
 
-	old_table = pf->eth_tbl;
+int nfp_net_refresh_eth_port(struct nfp_net *nn)
+{
+	struct nfp_eth_table_port *eth_port;
+	struct nfp_eth_table *eth_table;
 
-	list_for_each_entry(nn, &pf->ports, port_list)
-		nfp_net_link_changed_read_clear(nn);
+	eth_table = nfp_eth_read_ports(nn->cpp);
+	if (!eth_table) {
+		nn_err(nn, "Error refreshing port state table!\n");
+		return -EIO;
+	}
 
-	pf->eth_tbl = nfp_eth_read_ports(pf->cpp);
-	if (!pf->eth_tbl) {
-		pf->eth_tbl = old_table;
-		nfp_err(pf->cpp, "Error refreshing port config!\n");
-		return;
+	eth_port = nfp_net_find_port(eth_table, nn->eth_port->eth_index);
+	if (!eth_port) {
+		nn_err(nn, "Error finding state of the port!\n");
+		kfree(eth_table);
+		return -EIO;
 	}
 
-	list_for_each_entry(nn, &pf->ports, port_list)
-		nn->eth_port = nfp_net_find_port(pf, nn->eth_port->eth_index);
+	memcpy(nn->eth_port, eth_port, sizeof(*eth_port));
 
-	kfree(old_table);
+	kfree(eth_table);
 
-	schedule_work(&pf->port_refresh_work);
+	return 0;
 }
 
 /*
-- 
2.11.0
