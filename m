From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 02/14] nfp: don't spawn netdevs for reconfigured ports
Date: Tue,  4 Apr 2017 16:12:23 -0700
Message-ID: <20170404231235.32027-3-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34328 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754277AbdDDXM4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:12:56 -0400
Received: by mail-pg0-f46.google.com with SMTP id 21so165172032pgg.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:12:55 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After port reconfiguration (port split, media type change)
firmware will continue to report old configuration until
reboot.  NSP will inform us that reconfiguration is pending.
To avoid user confusion refuse to spawn netdevs until the
new configuration is applied (reboot).

We need to split the netdev to eth_table port matching from
MAC search and move it earlier in the probe() flow.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |  5 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 79 +++++++++++++---------
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   | 12 +++-
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h   |  3 +
 4 files changed, 62 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index 39105d0435e9..bb15a5724bf7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -64,7 +64,8 @@ struct nfp_eth_table;
  * @fw_loaded:		Is the firmware loaded?
  * @eth_tbl:		NSP ETH table
  * @ddir:		Per-device debugfs directory
- * @num_ports:		Number of adapter ports
+ * @num_ports:		Number of adapter ports app firmware supports
+ * @num_netdevs:	Number of netdevs spawned
  * @ports:		Linked list of port structures (struct nfp_net)
  */
 struct nfp_pf {
@@ -88,6 +89,8 @@ struct nfp_pf {
 	struct dentry *ddir;
 
 	unsigned int num_ports;
+	unsigned int num_netdevs;
+
 	struct list_head ports;
 };
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 2025cb7c6d90..1644954f52cd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -129,14 +129,29 @@ static u8 __iomem *nfp_net_map_area(struct nfp_cpp *cpp,
 	return (u8 __iomem *)ERR_PTR(err);
 }
 
+/**
+ * nfp_net_get_mac_addr() - Get the MAC address.
+ * @nn:       NFP Network structure
+ * @cpp:      NFP CPP handle
+ * @id:	      NFP port id
+ *
+ * First try to get the MAC address from NSP ETH table. If that
+ * fails try HWInfo.  As a last resort generate a random address.
+ */
 static void
-nfp_net_get_mac_addr_hwinfo(struct nfp_net_dp *dp, struct nfp_cpp *cpp,
-			    unsigned int id)
+nfp_net_get_mac_addr(struct nfp_net *nn, struct nfp_cpp *cpp, unsigned int id)
 {
+	struct nfp_net_dp *dp = &nn->dp;
 	u8 mac_addr[ETH_ALEN];
 	const char *mac_str;
 	char name[32];
 
+	if (nn->eth_port) {
+		ether_addr_copy(dp->netdev->dev_addr, nn->eth_port->mac_addr);
+		ether_addr_copy(dp->netdev->perm_addr, nn->eth_port->mac_addr);
+		return;
+	}
+
 	snprintf(name, sizeof(name), "eth%d.mac", id);
 
 	mac_str = nfp_hwinfo_lookup(cpp, name);
@@ -159,32 +174,16 @@ nfp_net_get_mac_addr_hwinfo(struct nfp_net_dp *dp, struct nfp_cpp *cpp,
 	ether_addr_copy(dp->netdev->perm_addr, mac_addr);
 }
 
-/**
- * nfp_net_get_mac_addr() - Get the MAC address.
- * @nn:       NFP Network structure
- * @pf:	      NFP PF device structure
- * @id:	      NFP port id
- *
- * First try to get the MAC address from NSP ETH table. If that
- * fails try HWInfo.  As a last resort generate a random address.
- */
-static void
-nfp_net_get_mac_addr(struct nfp_net *nn, struct nfp_pf *pf, unsigned int id)
+static struct nfp_eth_table_port *
+nfp_net_find_port(struct nfp_pf *pf, unsigned int id)
 {
 	int i;
 
 	for (i = 0; pf->eth_tbl && i < pf->eth_tbl->count; i++)
-		if (pf->eth_tbl->ports[i].eth_index == id) {
-			const u8 *mac_addr = pf->eth_tbl->ports[i].mac_addr;
-
-			nn->eth_port = &pf->eth_tbl->ports[i];
+		if (pf->eth_tbl->ports[i].eth_index == id)
+			return &pf->eth_tbl->ports[i];
 
-			ether_addr_copy(nn->dp.netdev->dev_addr, mac_addr);
-			ether_addr_copy(nn->dp.netdev->perm_addr, mac_addr);
-			return;
-		}
-
-	nfp_net_get_mac_addr_hwinfo(&nn->dp, pf->cpp, id);
+	return NULL;
 }
 
 static unsigned int nfp_net_pf_get_num_ports(struct nfp_pf *pf)
@@ -283,6 +282,7 @@ static void nfp_net_pf_free_netdevs(struct nfp_pf *pf)
 	while (!list_empty(&pf->ports)) {
 		nn = list_first_entry(&pf->ports, struct nfp_net, port_list);
 		list_del(&nn->port_list);
+		pf->num_netdevs--;
 
 		nfp_net_netdev_free(nn);
 	}
@@ -291,7 +291,8 @@ static void nfp_net_pf_free_netdevs(struct nfp_pf *pf)
 static struct nfp_net *
 nfp_net_pf_alloc_port_netdev(struct nfp_pf *pf, void __iomem *ctrl_bar,
 			     void __iomem *tx_bar, void __iomem *rx_bar,
-			     int stride, struct nfp_net_fw_version *fw_ver)
+			     int stride, struct nfp_net_fw_version *fw_ver,
+			     struct nfp_eth_table_port *eth_port)
 {
 	u32 n_tx_rings, n_rx_rings;
 	struct nfp_net *nn;
@@ -312,6 +313,7 @@ nfp_net_pf_alloc_port_netdev(struct nfp_pf *pf, void __iomem *ctrl_bar,
 	nn->dp.is_vf = 0;
 	nn->stride_rx = stride;
 	nn->stride_tx = stride;
+	nn->eth_port = eth_port;
 
 	return nn;
 }
@@ -323,7 +325,7 @@ nfp_net_pf_init_port_netdev(struct nfp_pf *pf, struct nfp_net *nn,
 	int err;
 
 	/* Get MAC address */
-	nfp_net_get_mac_addr(nn, pf, id);
+	nfp_net_get_mac_addr(nn, pf->cpp, id);
 
 	/* Get ME clock frequency from ctrl BAR
 	 * XXX for now frequency is hardcoded until we figure out how
@@ -348,6 +350,7 @@ nfp_net_pf_alloc_netdevs(struct nfp_pf *pf, void __iomem *ctrl_bar,
 			 int stride, struct nfp_net_fw_version *fw_ver)
 {
 	u32 prev_tx_base, prev_rx_base, tgt_tx_base, tgt_rx_base;
+	struct nfp_eth_table_port *eth_port;
 	struct nfp_net *nn;
 	unsigned int i;
 	int err;
@@ -363,17 +366,27 @@ nfp_net_pf_alloc_netdevs(struct nfp_pf *pf, void __iomem *ctrl_bar,
 		prev_tx_base = tgt_tx_base;
 		prev_rx_base = tgt_rx_base;
 
-		nn = nfp_net_pf_alloc_port_netdev(pf, ctrl_bar, tx_bar, rx_bar,
-						  stride, fw_ver);
-		if (IS_ERR(nn)) {
-			err = PTR_ERR(nn);
-			goto err_free_prev;
+		eth_port = nfp_net_find_port(pf, i);
+		if (eth_port && eth_port->override_changed) {
+			nfp_warn(pf->cpp, "Config changed for port #%d, reboot required before port will be operational\n", i);
+		} else {
+			nn = nfp_net_pf_alloc_port_netdev(pf, ctrl_bar, tx_bar,
+							  rx_bar, stride,
+							  fw_ver, eth_port);
+			if (IS_ERR(nn)) {
+				err = PTR_ERR(nn);
+				goto err_free_prev;
+			}
+			list_add_tail(&nn->port_list, &pf->ports);
+			pf->num_netdevs++;
 		}
-		list_add_tail(&nn->port_list, &pf->ports);
 
 		ctrl_bar += NFP_PF_CSR_SLICE_SIZE;
 	}
 
+	if (list_empty(&pf->ports))
+		return -ENODEV;
+
 	return 0;
 
 err_free_prev:
@@ -409,7 +422,7 @@ nfp_net_pf_spawn_netdevs(struct nfp_pf *pf,
 	}
 
 	num_irqs = nfp_net_irqs_alloc(pf->pdev, pf->irq_entries,
-				      NFP_NET_MIN_PORT_IRQS * pf->num_ports,
+				      NFP_NET_MIN_PORT_IRQS * pf->num_netdevs,
 				      wanted_irqs);
 	if (!num_irqs) {
 		nn_warn(nn, "Unable to allocate MSI-X Vectors. Exiting\n");
@@ -419,7 +432,7 @@ nfp_net_pf_spawn_netdevs(struct nfp_pf *pf,
 
 	/* Distribute IRQs to ports */
 	irqs_left = num_irqs;
-	ports_left = pf->num_ports;
+	ports_left = pf->num_netdevs;
 	list_for_each_entry(nn, &pf->ports, port_list) {
 		unsigned int n;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index 38bd80077e33..932772fbd27e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -62,6 +62,7 @@
 #define NSP_ETH_STATE_TX_ENABLED	BIT_ULL(2)
 #define NSP_ETH_STATE_RX_ENABLED	BIT_ULL(3)
 #define NSP_ETH_STATE_RATE		GENMASK_ULL(11, 8)
+#define NSP_ETH_STATE_OVRD_CHNG		BIT_ULL(22)
 
 #define NSP_ETH_CTRL_ENABLED		BIT_ULL(1)
 #define NSP_ETH_CTRL_TX_ENABLED		BIT_ULL(2)
@@ -110,8 +111,8 @@ static void nfp_eth_copy_mac_reverse(u8 *dst, const u8 *src)
 }
 
 static void
-nfp_eth_port_translate(const struct eth_table_entry *src, unsigned int index,
-		       struct nfp_eth_table_port *dst)
+nfp_eth_port_translate(struct nfp_nsp *nsp, const struct eth_table_entry *src,
+		       unsigned int index, struct nfp_eth_table_port *dst)
 {
 	unsigned int rate;
 	u64 port, state;
@@ -136,6 +137,11 @@ nfp_eth_port_translate(const struct eth_table_entry *src, unsigned int index,
 
 	dst->label_port = FIELD_GET(NSP_ETH_PORT_PHYLABEL, port);
 	dst->label_subport = FIELD_GET(NSP_ETH_PORT_LABEL, port);
+
+	if (nfp_nsp_get_abi_ver_minor(nsp) < 17)
+		return;
+
+	dst->override_changed = FIELD_GET(NSP_ETH_STATE_OVRD_CHNG, state);
 }
 
 static void
@@ -225,7 +231,7 @@ __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp)
 	table->count = cnt;
 	for (i = 0, j = 0; i < NSP_ETH_MAX_COUNT; i++)
 		if (entries[i].port & NSP_ETH_PORT_LANES_MASK)
-			nfp_eth_port_translate(&entries[i], i,
+			nfp_eth_port_translate(nsp, &entries[i], i,
 					       &table->ports[j++]);
 
 	nfp_eth_mark_split_ports(cpp, table);
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
index 325e841ca90a..6838741fadd7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
@@ -54,6 +54,7 @@
  * @enabled:	is enabled?
  * @tx_enabled:	is TX enabled?
  * @rx_enabled:	is RX enabled?
+ * @override_changed: is media reconfig pending?
  *
  * @is_split:	is interface part of a split port
  */
@@ -76,6 +77,8 @@ struct nfp_eth_table {
 		bool tx_enabled;
 		bool rx_enabled;
 
+		bool override_changed;
+
 		/* Computed fields */
 		bool is_split;
 	} ports[0];
-- 
2.11.0
