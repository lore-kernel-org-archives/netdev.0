From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 6/6] nfp: support port splitting via devlink
Date: Fri, 26 May 2017 01:03:36 -0700
Message-ID: <20170526080336.32689-7-jakub.kicinski@netronome.com>
References: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Cc: jiri@resnulli.us, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35161 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932725AbdEZID5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:03:57 -0400
Received: by mail-pf0-f177.google.com with SMTP id n23so4726756pfb.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:03:57 -0700 (PDT)
In-Reply-To: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for configuring port split with devlink.  Add devlink
callbacks to validate requested config and call NSP helpers.
Getting the right nfp_port structure can be done with simple iteration.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_devlink.c  | 97 +++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 23 ++++--
 drivers/net/ethernet/netronome/nfp/nfp_port.c     | 19 +++++
 drivers/net/ethernet/netronome/nfp/nfp_port.h     |  4 +
 4 files changed, 136 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_devlink.c b/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
index 2cfcb66b04bb..2609a0f28e81 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
@@ -54,7 +54,104 @@ nfp_devlink_fill_eth_port(struct nfp_port *port,
 	return 0;
 }
 
+static int
+nfp_devlink_fill_eth_port_from_id(struct nfp_pf *pf, unsigned int port_index,
+				  struct nfp_eth_table_port *copy)
+{
+	struct nfp_port *port;
+
+	port = nfp_port_from_id(pf, NFP_PORT_PHYS_PORT, port_index);
+
+	return nfp_devlink_fill_eth_port(port, copy);
+}
+
+static int
+nfp_devlink_set_lanes(struct nfp_pf *pf, unsigned int idx, unsigned int lanes)
+{
+	struct nfp_nsp *nsp;
+	int ret;
+
+	nsp = nfp_eth_config_start(pf->cpp, idx);
+	if (IS_ERR(nsp))
+		return PTR_ERR(nsp);
+
+	ret = __nfp_eth_set_split(nsp, lanes);
+	if (ret) {
+		nfp_eth_config_cleanup_end(nsp);
+		return ret;
+	}
+
+	ret = nfp_eth_config_commit_end(nsp);
+	if (ret < 0)
+		return ret;
+	if (ret) /* no change */
+		return 0;
+
+	return nfp_net_refresh_port_table_sync(pf);
+}
+
+static int
+nfp_devlink_port_split(struct devlink *devlink, unsigned int port_index,
+		       unsigned int count)
+{
+	struct nfp_pf *pf = devlink_priv(devlink);
+	struct nfp_eth_table_port eth_port;
+	int ret;
+
+	if (count < 2)
+		return -EINVAL;
+
+	mutex_lock(&pf->lock);
+
+	rtnl_lock();
+	ret = nfp_devlink_fill_eth_port_from_id(pf, port_index, &eth_port);
+	rtnl_unlock();
+	if (ret)
+		goto out;
+
+	if (eth_port.is_split || eth_port.port_lanes % count) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = nfp_devlink_set_lanes(pf, eth_port.index,
+				    eth_port.port_lanes / count);
+out:
+	mutex_unlock(&pf->lock);
+
+	return ret;
+}
+
+static int
+nfp_devlink_port_unsplit(struct devlink *devlink, unsigned int port_index)
+{
+	struct nfp_pf *pf = devlink_priv(devlink);
+	struct nfp_eth_table_port eth_port;
+	int ret;
+
+	mutex_lock(&pf->lock);
+
+	rtnl_lock();
+	ret = nfp_devlink_fill_eth_port_from_id(pf, port_index, &eth_port);
+	rtnl_unlock();
+	if (ret)
+		goto out;
+
+	if (!eth_port.is_split) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = nfp_devlink_set_lanes(pf, eth_port.index, eth_port.port_lanes);
+out:
+	mutex_unlock(&pf->lock);
+
+	return ret;
+}
+
 const struct devlink_ops nfp_devlink_ops = {
+	.port_split		= nfp_devlink_port_split,
+	.port_unsplit		= nfp_devlink_port_unsplit,
 };
 
 int nfp_devlink_port_register(struct nfp_app *app, struct nfp_port *port)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index b733c97677fb..388759e047d8 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -43,6 +43,7 @@
 #include <linux/etherdevice.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/lockdep.h>
 #include <linux/pci.h>
 #include <linux/pci_regs.h>
 #include <linux/msi.h>
@@ -561,19 +562,17 @@ nfp_net_eth_port_update(struct nfp_cpp *cpp, struct nfp_port *port,
 	return 0;
 }
 
-static void nfp_net_refresh_vnics(struct work_struct *work)
+int nfp_net_refresh_port_table_sync(struct nfp_pf *pf)
 {
-	struct nfp_pf *pf = container_of(work, struct nfp_pf,
-					 port_refresh_work);
 	struct nfp_eth_table *eth_table;
 	struct nfp_net *nn, *next;
 	struct nfp_port *port;
 
-	mutex_lock(&pf->lock);
+	lockdep_assert_held(&pf->lock);
 
 	/* Check for nfp_net_pci_remove() racing against us */
 	if (list_empty(&pf->vnics))
-		goto out;
+		return 0;
 
 	/* Update state of all ports */
 	rtnl_lock();
@@ -587,7 +586,7 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 				set_bit(NFP_PORT_CHANGED, &port->flags);
 		rtnl_unlock();
 		nfp_err(pf->cpp, "Error refreshing port config!\n");
-		goto out;
+		return -EIO;
 	}
 
 	list_for_each_entry(port, &pf->ports, port_list)
@@ -608,7 +607,17 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 
 	if (list_empty(&pf->vnics))
 		nfp_net_pci_remove_finish(pf);
-out:
+
+	return 0;
+}
+
+static void nfp_net_refresh_vnics(struct work_struct *work)
+{
+	struct nfp_pf *pf = container_of(work, struct nfp_pf,
+					 port_refresh_work);
+
+	mutex_lock(&pf->lock);
+	nfp_net_refresh_port_table_sync(pf);
 	mutex_unlock(&pf->lock);
 }
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index 3beed4167e2f..a17410ac01ab 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -31,6 +31,8 @@
  * SOFTWARE.
  */
 
+#include <linux/lockdep.h>
+
 #include "nfpcore/nfp_nsp.h"
 #include "nfp_app.h"
 #include "nfp_main.h"
@@ -48,6 +50,23 @@ struct nfp_port *nfp_port_from_netdev(struct net_device *netdev)
 	return nn->port;
 }
 
+struct nfp_port *
+nfp_port_from_id(struct nfp_pf *pf, enum nfp_port_type type, unsigned int id)
+{
+	struct nfp_port *port;
+
+	lockdep_assert_held(&pf->lock);
+
+	if (type != NFP_PORT_PHYS_PORT)
+		return NULL;
+
+	list_for_each_entry(port, &pf->ports, port_list)
+		if (port->eth_id == id)
+			return port;
+
+	return NULL;
+}
+
 struct nfp_eth_table_port *__nfp_port_get_eth_port(struct nfp_port *port)
 {
 	if (!port)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 36a540b514be..4d1a9b3fed41 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -38,6 +38,7 @@
 
 struct net_device;
 struct nfp_app;
+struct nfp_pf;
 struct nfp_port;
 
 /**
@@ -90,6 +91,8 @@ struct nfp_port {
 };
 
 struct nfp_port *nfp_port_from_netdev(struct net_device *netdev);
+struct nfp_port *
+nfp_port_from_id(struct nfp_pf *pf, enum nfp_port_type type, unsigned int id);
 struct nfp_eth_table_port *__nfp_port_get_eth_port(struct nfp_port *port);
 struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port);
 
@@ -103,6 +106,7 @@ void nfp_port_free(struct nfp_port *port);
 
 int nfp_net_refresh_eth_port(struct nfp_port *port);
 void nfp_net_refresh_port_table(struct nfp_port *port);
+int nfp_net_refresh_port_table_sync(struct nfp_pf *pf);
 
 int nfp_devlink_port_register(struct nfp_app *app, struct nfp_port *port);
 void nfp_devlink_port_unregister(struct nfp_port *port);
-- 
2.11.0
