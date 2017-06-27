From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 06/14] nfp: spawn nfp_ports for PF and VF ports
Date: Tue, 27 Jun 2017 00:50:20 -0700
Message-ID: <20170627075028.4009-7-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33107 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752562AbdF0HvR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:17 -0400
Received: by mail-pf0-f169.google.com with SMTP id e7so12632125pfk.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:16 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_port is an abstraction which is supposed to allow us sharing
code between different netdev types (vNIC vs repr).  Spawn ports
for PFs and VFs to enable this sharing.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/main.c | 19 +++++++++++++++++--
 drivers/net/ethernet/netronome/nfp/nfp_port.h    | 20 ++++++++++++++++++--
 2 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index 54d42a7f0d75..757bc3d78ea4 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -162,14 +162,19 @@ nfp_flower_spawn_vnic_reprs(struct nfp_app *app,
 	u8 nfp_pcie = nfp_cppcore_pcie_unit(app->pf->cpp);
 	struct nfp_flower_priv *priv = app->priv;
 	struct nfp_reprs *reprs, *old_reprs;
+	enum nfp_port_type port_type;
 	const u8 queue = 0;
 	int i, err;
 
+	port_type = repr_type == NFP_REPR_TYPE_PF ? NFP_PORT_PF_PORT :
+						    NFP_PORT_VF_PORT;
+
 	reprs = nfp_reprs_alloc(cnt);
 	if (!reprs)
 		return -ENOMEM;
 
 	for (i = 0; i < cnt; i++) {
+		struct nfp_port *port;
 		u32 port_id;
 
 		reprs->reprs[i] = nfp_repr_alloc(app);
@@ -178,15 +183,25 @@ nfp_flower_spawn_vnic_reprs(struct nfp_app *app,
 			goto err_reprs_clean;
 		}
 
+		port = nfp_port_alloc(app, port_type, reprs->reprs[i]);
+		if (repr_type == NFP_REPR_TYPE_PF) {
+			port->pf_id = i;
+		} else {
+			port->pf_id = 0; /* For now we only support 1 PF */
+			port->vf_id = i;
+		}
+
 		eth_hw_addr_random(reprs->reprs[i]);
 
 		port_id = nfp_flower_cmsg_pcie_port(nfp_pcie, vnic_type,
 						    i, queue);
 		err = nfp_repr_init(app, reprs->reprs[i],
 				    &nfp_flower_repr_netdev_ops,
-				    port_id, NULL, priv->nn->dp.netdev);
-		if (err)
+				    port_id, port, priv->nn->dp.netdev);
+		if (err) {
+			nfp_port_free(port);
 			goto err_reprs_clean;
+		}
 
 		nfp_info(app->cpp, "%s%d Representor(%s) created\n",
 			 repr_type == NFP_REPR_TYPE_PF ? "PF" : "VF", i,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index f472bea4ec2b..57d852a4ca59 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -47,10 +47,14 @@ struct nfp_port;
  *			state when port disappears because of FW fault or config
  *			change
  * @NFP_PORT_PHYS_PORT:	external NIC port
+ * @NFP_PORT_PF_PORT:	logical port of PCI PF
+ * @NFP_PORT_VF_PORT:	logical port of PCI VF
  */
 enum nfp_port_type {
 	NFP_PORT_INVALID,
 	NFP_PORT_PHYS_PORT,
+	NFP_PORT_PF_PORT,
+	NFP_PORT_VF_PORT,
 };
 
 /**
@@ -72,6 +76,8 @@ enum nfp_port_flags {
  * @dl_port:	devlink port structure
  * @eth_id:	for %NFP_PORT_PHYS_PORT port ID in NFP enumeration scheme
  * @eth_port:	for %NFP_PORT_PHYS_PORT translated ETH Table port entry
+ * @pf_id:	for %NFP_PORT_PF_PORT, %NFP_PORT_VF_PORT ID of the PCI PF (0-3)
+ * @vf_id:	for %NFP_PORT_VF_PORT ID of the PCI VF within @pf_id
  * @port_list:	entry on pf's list of ports
  */
 struct nfp_port {
@@ -84,8 +90,18 @@ struct nfp_port {
 
 	struct devlink_port dl_port;
 
-	unsigned int eth_id;
-	struct nfp_eth_table_port *eth_port;
+	union {
+		/* NFP_PORT_PHYS_PORT */
+		struct {
+			unsigned int eth_id;
+			struct nfp_eth_table_port *eth_port;
+		};
+		/* NFP_PORT_PF_PORT, NFP_PORT_VF_PORT */
+		struct {
+			unsigned int pf_id;
+			unsigned int vf_id;
+		};
+	};
 
 	struct list_head port_list;
 };
-- 
2.11.0
