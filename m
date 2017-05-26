From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 4/6] nfp: register ports as devlink ports
Date: Fri, 26 May 2017 01:03:34 -0700
Message-ID: <20170526080336.32689-5-jakub.kicinski@netronome.com>
References: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Cc: jiri@resnulli.us, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34077 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939906AbdEZID4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:03:56 -0400
Received: by mail-pf0-f175.google.com with SMTP id 9so4734213pfj.1
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:03:56 -0700 (PDT)
In-Reply-To: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend nfp_port to contain devlink_port structures.  Register the
ports to allow users inspecting device ports.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_devlink.c  | 45 +++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 13 +++++++
 drivers/net/ethernet/netronome/nfp/nfp_port.h     |  8 ++++
 3 files changed, 66 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_devlink.c b/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
index a8a52b3ff42b..2cfcb66b04bb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
@@ -31,9 +31,54 @@
  * SOFTWARE.
  */
 
+#include <linux/rtnetlink.h>
 #include <net/devlink.h>
 
+#include "nfpcore/nfp_nsp.h"
+#include "nfp_app.h"
 #include "nfp_main.h"
+#include "nfp_port.h"
+
+static int
+nfp_devlink_fill_eth_port(struct nfp_port *port,
+			  struct nfp_eth_table_port *copy)
+{
+	struct nfp_eth_table_port *eth_port;
+
+	eth_port = __nfp_port_get_eth_port(port);
+	if (!eth_port)
+		return -EINVAL;
+
+	memcpy(copy, eth_port, sizeof(*eth_port));
+
+	return 0;
+}
 
 const struct devlink_ops nfp_devlink_ops = {
 };
+
+int nfp_devlink_port_register(struct nfp_app *app, struct nfp_port *port)
+{
+	struct nfp_eth_table_port eth_port;
+	struct devlink *devlink;
+	int ret;
+
+	rtnl_lock();
+	ret = nfp_devlink_fill_eth_port(port, &eth_port);
+	rtnl_unlock();
+	if (ret)
+		return ret;
+
+	devlink_port_type_eth_set(&port->dl_port, port->netdev);
+	if (eth_port.is_split)
+		devlink_port_split_set(&port->dl_port, eth_port.label_port);
+
+	devlink = priv_to_devlink(app->pf);
+
+	return devlink_port_register(devlink, &port->dl_port, port->eth_id);
+}
+
+void nfp_devlink_port_unregister(struct nfp_port *port)
+{
+	devlink_port_unregister(&port->dl_port);
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index b0a6ec4fe097..b733c97677fb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -354,9 +354,20 @@ nfp_net_pf_init_vnic(struct nfp_pf *pf, struct nfp_net *nn, unsigned int id)
 
 	nfp_net_debugfs_vnic_add(nn, pf->ddir, id);
 
+	if (nn->port) {
+		err = nfp_devlink_port_register(pf->app, nn->port);
+		if (err)
+			goto err_dfs_clean;
+	}
+
 	nfp_net_info(nn);
 
 	return 0;
+
+err_dfs_clean:
+	nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
+	nfp_net_clean(nn);
+	return err;
 }
 
 static int
@@ -420,6 +431,8 @@ nfp_net_pf_alloc_vnics(struct nfp_pf *pf, void __iomem *ctrl_bar,
 
 static void nfp_net_pf_clean_vnic(struct nfp_pf *pf, struct nfp_net *nn)
 {
+	if (nn->port)
+		nfp_devlink_port_unregister(nn->port);
 	nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
 	nfp_net_clean(nn);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 641617de41cc..36a540b514be 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -34,6 +34,8 @@
 #ifndef _NFP_PORT_H_
 #define _NFP_PORT_H_
 
+#include <net/devlink.h>
+
 struct net_device;
 struct nfp_app;
 struct nfp_port;
@@ -66,6 +68,7 @@ enum nfp_port_flags {
  * @type:	what port type does the entity represent
  * @flags:	port flags
  * @app:	backpointer to the app structure
+ * @dl_port:	devlink port structure
  * @eth_id:	for %NFP_PORT_PHYS_PORT port ID in NFP enumeration scheme
  * @eth_port:	for %NFP_PORT_PHYS_PORT translated ETH Table port entry
  * @port_list:	entry on pf's list of ports
@@ -78,6 +81,8 @@ struct nfp_port {
 
 	struct nfp_app *app;
 
+	struct devlink_port dl_port;
+
 	unsigned int eth_id;
 	struct nfp_eth_table_port *eth_port;
 
@@ -99,4 +104,7 @@ void nfp_port_free(struct nfp_port *port);
 int nfp_net_refresh_eth_port(struct nfp_port *port);
 void nfp_net_refresh_port_table(struct nfp_port *port);
 
+int nfp_devlink_port_register(struct nfp_app *app, struct nfp_port *port);
+void nfp_devlink_port_unregister(struct nfp_port *port);
+
 #endif
-- 
2.11.0
