From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/9] nfp: implement .ndo_get_phys_port_name()
Date: Wed,  8 Mar 2017 08:57:02 -0800
Message-ID: <20170308165708.96087-4-jakub.kicinski@netronome.com>
References: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:32914 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753134AbdCHQ7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:59:04 -0500
Received: by mail-pf0-f182.google.com with SMTP id w189so16979747pfb.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:58:11 -0800 (PST)
In-Reply-To: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NSP reports to us port labels.  First id is the id of the physical
port, the other one tells us which logical interface is it within a
split port.  Instead of printing them as string keep them in integer
format.  Compute which interfaces are part of port split.

On netdev side use port labels and split information to provide a
.ndo_get_phys_port_name() implementation.  We follow the name format
of mlxsw which is also suggested in "Port Netdev Naming" section
of Documentation/networking/switchdev.txt.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  4 +++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 22 +++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  2 ++
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   | 31 +++++++++++++++++++---
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h   | 15 +++++++++--
 5 files changed, 69 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 9843e953bbed..50413eea9540 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -112,6 +112,7 @@
 
 /* Forward declarations */
 struct nfp_cpp;
+struct nfp_eth_table_port;
 struct nfp_net;
 struct nfp_net_r_vector;
 
@@ -496,6 +497,7 @@ struct nfp_stat_pair {
  * @ethtool_dump_flag:	Ethtool dump flag
  * @port_list:		Entry on device port list
  * @cpp:		CPP device handle if available
+ * @eth_port:		Translated ETH Table port entry
  */
 struct nfp_net {
 	struct pci_dev *pdev;
@@ -587,6 +589,8 @@ struct nfp_net {
 	struct list_head port_list;
 
 	struct nfp_cpp *cpp;
+
+	struct nfp_eth_table_port *eth_port;
 };
 
 struct nfp_net_ring_set {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index e72468d65c28..5c34f79053f7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -67,6 +67,7 @@
 #include <net/pkt_cls.h>
 #include <net/vxlan.h>
 
+#include "nfpcore/nfp_nsp_eth.h"
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
 
@@ -2831,6 +2832,26 @@ nfp_net_features_check(struct sk_buff *skb, struct net_device *dev,
 	return features;
 }
 
+static int
+nfp_net_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int err;
+
+	if (!nn->eth_port)
+		return -EOPNOTSUPP;
+
+	if (!nn->eth_port->is_split)
+		err = snprintf(name, len, "p%d", nn->eth_port->label_port);
+	else
+		err = snprintf(name, len, "p%ds%d", nn->eth_port->label_port,
+			       nn->eth_port->label_subport);
+	if (err >= len)
+		return -EINVAL;
+
+	return 0;
+}
+
 /**
  * nfp_net_set_vxlan_port() - set vxlan port in SW and reconfigure HW
  * @nn:   NFP Net device to reconfigure
@@ -3009,6 +3030,7 @@ static const struct net_device_ops nfp_net_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_set_features	= nfp_net_set_features,
 	.ndo_features_check	= nfp_net_features_check,
+	.ndo_get_phys_port_name	= nfp_net_get_phys_port_name,
 	.ndo_udp_tunnel_add	= nfp_net_add_vxlan_port,
 	.ndo_udp_tunnel_del	= nfp_net_del_vxlan_port,
 	.ndo_xdp		= nfp_net_xdp,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 3afcdc11480c..f04d0b8e84ad 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -178,6 +178,8 @@ nfp_net_get_mac_addr(struct nfp_net *nn, struct nfp_pf *pf, unsigned int id)
 		if (pf->eth_tbl->ports[i].eth_index == id) {
 			const u8 *mac_addr = pf->eth_tbl->ports[i].mac_addr;
 
+			nn->eth_port = &pf->eth_tbl->ports[i];
+
 			ether_addr_copy(nn->netdev->dev_addr, mac_addr);
 			ether_addr_copy(nn->netdev->perm_addr, mac_addr);
 			return;
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index 1ece1f8ae4b3..10a0c8392d2b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -134,9 +134,32 @@ nfp_eth_port_translate(const struct eth_table_entry *src, unsigned int index,
 
 	nfp_eth_copy_mac_reverse(dst->mac_addr, src->mac_addr);
 
-	snprintf(dst->label, sizeof(dst->label) - 1, "%llu.%llu",
-		 FIELD_GET(NSP_ETH_PORT_PHYLABEL, port),
-		 FIELD_GET(NSP_ETH_PORT_LABEL, port));
+	dst->label_port = FIELD_GET(NSP_ETH_PORT_PHYLABEL, port);
+	dst->label_subport = FIELD_GET(NSP_ETH_PORT_LABEL, port);
+}
+
+static void
+nfp_eth_mark_split_ports(struct nfp_cpp *cpp, struct nfp_eth_table *table)
+{
+	unsigned int i, j;
+
+	for (i = 0; i < table->count; i++)
+		for (j = 0; j < table->count; j++) {
+			if (i == j)
+				continue;
+			if (table->ports[i].label_port !=
+			    table->ports[j].label_port)
+				continue;
+			if (table->ports[i].label_subport ==
+			    table->ports[j].label_subport)
+				nfp_warn(cpp,
+					 "Port %d subport %d is a duplicate\n",
+					 table->ports[i].label_port,
+					 table->ports[i].label_subport);
+
+			table->ports[i].is_split = true;
+			break;
+		}
 }
 
 /**
@@ -203,6 +226,8 @@ __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp)
 			nfp_eth_port_translate(&entries[i], i,
 					       &table->ports[j++]);
 
+	nfp_eth_mark_split_ports(cpp, table);
+
 	kfree(entries);
 
 	return table;
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
index edf703d319c8..325e841ca90a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
@@ -49,10 +49,13 @@
  * @lanes:	number of channels
  * @speed:	interface speed (in Mbps)
  * @mac_addr:	interface MAC address
- * @label:	interface id string
+ * @label_port:	port id
+ * @label_subport:  id of interface within port (for split ports)
  * @enabled:	is enabled?
  * @tx_enabled:	is TX enabled?
  * @rx_enabled:	is RX enabled?
+ *
+ * @is_split:	is interface part of a split port
  */
 struct nfp_eth_table {
 	unsigned int count;
@@ -65,14 +68,22 @@ struct nfp_eth_table {
 		unsigned int speed;
 
 		u8 mac_addr[ETH_ALEN];
-		char label[8];
+
+		u8 label_port;
+		u8 label_subport;
 
 		bool enabled;
 		bool tx_enabled;
 		bool rx_enabled;
+
+		/* Computed fields */
+		bool is_split;
 	} ports[0];
 };
 
+struct nfp_cpp;
+struct nfp_nsp;
+
 struct nfp_eth_table *nfp_eth_read_ports(struct nfp_cpp *cpp);
 struct nfp_eth_table *
 __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp);
-- 
2.11.0
