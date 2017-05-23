From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/4] nfp: register ports as devlink ports
Date: Tue, 23 May 2017 08:12:45 -0700
Message-ID: <20170523151247.8535-3-jakub.kicinski@netronome.com>
References: <20170523151247.8535-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36785 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764389AbdEWPNM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:13:12 -0400
Received: by mail-pf0-f174.google.com with SMTP id m17so117622108pfg.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 08:13:10 -0700 (PDT)
In-Reply-To: <20170523151247.8535-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend nfp_port to contain devlink_port structures.  Register the
ports to allow users inspecting device ports.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_devlink.c  | 49 +++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_main.c     |  8 ++++
 drivers/net/ethernet/netronome/nfp/nfp_main.h     |  2 +
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 34 ++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_port.h     |  8 ++++
 5 files changed, 101 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_devlink.c b/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
index a8a52b3ff42b..b65c50c0d211 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
@@ -31,9 +31,58 @@
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
+	/* Due to unpleasant lock ordering we may see the port go away before
+	 * we have fully probed.
+	 */
+	if (port->dl_port.registered)
+		devlink_port_unregister(&port->dl_port);
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index f22c8f083ab0..ea7c122092e7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -377,8 +377,14 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_kill_ndevs;
 
+	err = nfp_net_devlink_register(pf);
+	if (err)
+		goto err_devlink_unregiser;
+
 	return 0;
 
+err_devlink_unregiser:
+	devlink_unregister(devlink);
 err_kill_ndevs:
 	nfp_net_pci_remove(pf);
 err_fw_unload:
@@ -405,6 +411,8 @@ static void nfp_pci_remove(struct pci_dev *pdev)
 
 	devlink = priv_to_devlink(pf);
 
+	nfp_net_devlink_unregister(pf);
+
 	devlink_unregister(devlink);
 
 	nfp_net_pci_remove(pf);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index 526db8029dea..7fdb9036f666 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -112,5 +112,7 @@ extern const struct devlink_ops nfp_devlink_ops;
 
 int nfp_net_pci_probe(struct nfp_pf *pf);
 void nfp_net_pci_remove(struct nfp_pf *pf);
+int nfp_net_devlink_register(struct nfp_pf *pf);
+void nfp_net_devlink_unregister(struct nfp_pf *pf);
 
 #endif /* NFP_MAIN_H */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index dd1118c7e1a4..bf10c0a316f3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -584,6 +584,8 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 		if (!nn->port || nn->port->type != NFP_PORT_INVALID)
 			continue;
 
+		nfp_devlink_port_unregister(nn->port);
+
 		nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
 		nfp_net_clean(nn);
 
@@ -774,3 +776,35 @@ void nfp_net_pci_remove(struct nfp_pf *pf)
 
 	cancel_work_sync(&pf->port_refresh_work);
 }
+
+int nfp_net_devlink_register(struct nfp_pf *pf)
+{
+	struct nfp_port *port;
+	int err;
+
+	mutex_lock(&pf->lock);
+	list_for_each_entry(port, &pf->ports, port_list) {
+		err = nfp_devlink_port_register(pf->app, port);
+		if (err)
+			goto err_prev_ports_unreg;
+	}
+	mutex_unlock(&pf->lock);
+
+	return 0;
+
+err_prev_ports_unreg:
+	list_for_each_entry_continue_reverse(port, &pf->ports, port_list)
+		nfp_devlink_port_unregister(port);
+	mutex_unlock(&pf->lock);
+	return err;
+}
+
+void nfp_net_devlink_unregister(struct nfp_pf *pf)
+{
+	struct nfp_port *port;
+
+	mutex_lock(&pf->lock);
+	list_for_each_entry(port, &pf->ports, port_list)
+		nfp_devlink_port_unregister(port);
+	mutex_unlock(&pf->lock);
+}
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
