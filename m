From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 05/13] nfp: introduce very minimal nfp_app
Date: Fri, 19 May 2017 15:01:47 -0700
Message-ID: <20170519220155.27857-6-jakub.kicinski@netronome.com>
References: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36686 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932382AbdESWCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 18:02:25 -0400
Received: by mail-pg0-f48.google.com with SMTP id x64so43605574pgd.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 15:02:25 -0700 (PDT)
In-Reply-To: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a concept of an application.  For now it's just grouping
pointers and serving as a layer of indirection.  It will help us
weaken the dependency on nfp_net in ethtool code.  Later series
will flesh out support for different apps in the driver.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile        |  1 +
 drivers/net/ethernet/netronome/nfp/nfp_app.c       | 80 ++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_app.h       | 48 +++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |  3 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  4 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 20 +++---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 26 ++++++-
 7 files changed, 168 insertions(+), 14 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_app.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_app.h

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index 4b15f0f496aa..a6b9c4dcbe12 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -14,6 +14,7 @@ nfp-objs := \
 	    nfpcore/nfp_resource.o \
 	    nfpcore/nfp_rtsym.o \
 	    nfpcore/nfp_target.o \
+	    nfp_app.o \
 	    nfp_main.o \
 	    nfp_net_common.o \
 	    nfp_net_ethtool.o \
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.c b/drivers/net/ethernet/netronome/nfp/nfp_app.c
new file mode 100644
index 000000000000..c5dc8faffc61
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.c
@@ -0,0 +1,80 @@
+/*
+ * Copyright (C) 2017 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/slab.h>
+
+#include "nfpcore/nfp_cpp.h"
+#include "nfp_app.h"
+#include "nfp_main.h"
+
+/**
+ * struct nfp_app - NFP application container
+ * @pdev:	backpointer to PCI device
+ * @pf:		backpointer to NFP PF structure
+ * @cpp:	pointer to the CPP handle
+ */
+struct nfp_app {
+	struct pci_dev *pdev;
+	struct nfp_pf *pf;
+	struct nfp_cpp *cpp;
+};
+
+struct nfp_cpp *nfp_app_cpp(struct nfp_app *app)
+{
+	return app->cpp;
+}
+
+struct nfp_pf *nfp_app_pf(struct nfp_app *app)
+{
+	return app->pf;
+}
+
+struct nfp_app *nfp_app_alloc(struct nfp_pf *pf)
+{
+	struct nfp_app *app;
+
+	app = kzalloc(sizeof(*app), GFP_KERNEL);
+	if (!app)
+		return ERR_PTR(-ENOMEM);
+
+	app->pf = pf;
+	app->cpp = pf->cpp;
+	app->pdev = pf->pdev;
+
+	return app;
+}
+
+void nfp_app_free(struct nfp_app *app)
+{
+	kfree(app);
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
new file mode 100644
index 000000000000..c0a5e97d19b8
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -0,0 +1,48 @@
+/*
+ * Copyright (C) 2017 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef _NFP_APP_H
+#define _NFP_APP_H 1
+
+struct nfp_app;
+struct nfp_cpp;
+struct nfp_pf;
+
+struct nfp_cpp *nfp_app_cpp(struct nfp_app *app);
+
+struct nfp_pf *nfp_app_pf(struct nfp_app *app);
+
+struct nfp_app *nfp_app_alloc(struct nfp_pf *pf);
+void nfp_app_free(struct nfp_app *app);
+
+#endif
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index bf31913ac7a5..b1ddea0e2406 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -57,6 +57,7 @@ struct nfp_eth_table;
  * struct nfp_pf - NFP PF-specific device structure
  * @pdev:		Backpointer to PCI device
  * @cpp:		Pointer to the CPP handle
+ * @app:		Pointer to the APP handle
  * @data_vnic_bar:	Pointer to the CPP area for the data vNICs' BARs
  * @tx_area:		Pointer to the CPP area for the TX queues
  * @rx_area:		Pointer to the CPP area for the FL/RX queues
@@ -78,6 +79,8 @@ struct nfp_pf {
 
 	struct nfp_cpp *cpp;
 
+	struct nfp_app *app;
+
 	struct nfp_cpp_area *data_vnic_bar;
 	struct nfp_cpp_area *tx_area;
 	struct nfp_cpp_area *rx_area;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 1d41be9b2309..d8edd61a5ad1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -557,7 +557,7 @@ struct nfp_net_dp {
  * @ethtool_dump_flag:	Ethtool dump flag
  * @vnic_list:		Entry on device vNIC list
  * @pdev:		Backpointer to PCI device
- * @cpp:		CPP device handle if available
+ * @app:		APP handle if available
  * @eth_port:		Translated ETH Table port entry
  */
 struct nfp_net {
@@ -628,7 +628,7 @@ struct nfp_net {
 	struct list_head vnic_list;
 
 	struct pci_dev *pdev;
-	struct nfp_cpp *cpp;
+	struct nfp_app *app;
 
 	struct nfp_eth_table_port *eth_port;
 };
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 70bb0a0152b9..a15b15b30acf 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -50,6 +50,7 @@
 
 #include "nfpcore/nfp.h"
 #include "nfpcore/nfp_nsp.h"
+#include "nfp_app.h"
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
 
@@ -134,14 +135,14 @@ static const struct _nfp_net_et_stats nfp_net_et_stats[] = {
 #define NN_ET_STATS_LEN (NN_ET_GLOBAL_STATS_LEN + NN_ET_RVEC_GATHER_STATS + \
 			 NN_ET_RVEC_STATS_LEN + NN_ET_QUEUE_STATS_LEN)
 
-static void nfp_net_get_nspinfo(struct nfp_net *nn, char *version)
+static void nfp_net_get_nspinfo(struct nfp_app *app, char *version)
 {
 	struct nfp_nsp *nsp;
 
-	if (!nn->cpp)
+	if (!app)
 		return;
 
-	nsp = nfp_nsp_open(nn->cpp);
+	nsp = nfp_nsp_open(nfp_app_cpp(app));
 	if (IS_ERR(nsp))
 		return;
 
@@ -162,7 +163,7 @@ static void nfp_net_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, nfp_driver_version, sizeof(drvinfo->version));
 
-	nfp_net_get_nspinfo(nn, nsp_version);
+	nfp_net_get_nspinfo(nn->app, nsp_version);
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
 		 "%d.%d.%d.%d %s",
 		 nn->fw_ver.resv, nn->fw_ver.class,
@@ -258,7 +259,7 @@ nfp_net_set_link_ksettings(struct net_device *netdev,
 		return -EBUSY;
 	}
 
-	nsp = nfp_eth_config_start(nn->cpp, nn->eth_port->index);
+	nsp = nfp_eth_config_start(nfp_app_cpp(nn->app), nn->eth_port->index);
 	if (IS_ERR(nsp))
 		return PTR_ERR(nsp);
 
@@ -706,13 +707,13 @@ nfp_dump_nsp_diag(struct nfp_net *nn, struct ethtool_dump *dump, void *buffer)
 	struct nfp_resource *res;
 	int ret;
 
-	if (!nn->cpp)
+	if (!nn->app)
 		return -EOPNOTSUPP;
 
 	dump->version = 1;
 	dump->flag = NFP_DUMP_NSP_DIAG;
 
-	res = nfp_resource_acquire(nn->cpp, NFP_RESOURCE_NSP_DIAG);
+	res = nfp_resource_acquire(nfp_app_cpp(nn->app), NFP_RESOURCE_NSP_DIAG);
 	if (IS_ERR(res))
 		return PTR_ERR(res);
 
@@ -722,7 +723,8 @@ nfp_dump_nsp_diag(struct nfp_net *nn, struct ethtool_dump *dump, void *buffer)
 			goto exit_release;
 		}
 
-		ret = nfp_cpp_read(nn->cpp, nfp_resource_cpp_id(res),
+		ret = nfp_cpp_read(nfp_app_cpp(nn->app),
+				   nfp_resource_cpp_id(res),
 				   nfp_resource_address(res),
 				   buffer, dump->len);
 		if (ret != dump->len)
@@ -743,7 +745,7 @@ static int nfp_net_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
-	if (!nn->cpp)
+	if (!nn->app)
 		return -EOPNOTSUPP;
 
 	if (val->flag != NFP_DUMP_NSP_DIAG)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 5f0c58a56182..17ff8a88fc24 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -54,7 +54,7 @@
 #include "nfpcore/nfp_nffw.h"
 #include "nfpcore/nfp_nsp.h"
 #include "nfpcore/nfp6000_pcie.h"
-
+#include "nfp_app.h"
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
 #include "nfp_main.h"
@@ -302,7 +302,7 @@ nfp_net_pf_alloc_vnic(struct nfp_pf *pf, void __iomem *ctrl_bar,
 	if (IS_ERR(nn))
 		return nn;
 
-	nn->cpp = pf->cpp;
+	nn->app = pf->app;
 	nn->fw_ver = *fw_ver;
 	nn->dp.ctrl_bar = ctrl_bar;
 	nn->tx_bar = tx_bar;
@@ -463,6 +463,18 @@ nfp_net_pf_spawn_vnics(struct nfp_pf *pf,
 	return err;
 }
 
+static int nfp_net_pf_app_init(struct nfp_pf *pf)
+{
+	pf->app = nfp_app_alloc(pf);
+
+	return PTR_ERR_OR_ZERO(pf->app);
+}
+
+static void nfp_net_pf_app_clean(struct nfp_pf *pf)
+{
+	nfp_app_free(pf->app);
+}
+
 static void nfp_net_pci_remove_finish(struct nfp_pf *pf)
 {
 	nfp_net_debugfs_dir_clean(&pf->ddir);
@@ -470,6 +482,8 @@ static void nfp_net_pci_remove_finish(struct nfp_pf *pf)
 	nfp_net_irqs_disable(pf->pdev);
 	kfree(pf->irq_entries);
 
+	nfp_net_pf_app_clean(pf);
+
 	nfp_cpp_area_release_free(pf->rx_area);
 	nfp_cpp_area_release_free(pf->tx_area);
 	nfp_cpp_area_release_free(pf->data_vnic_bar);
@@ -543,7 +557,7 @@ int nfp_net_refresh_eth_port(struct nfp_net *nn)
 	struct nfp_eth_table_port *eth_port;
 	struct nfp_eth_table *eth_table;
 
-	eth_table = nfp_eth_read_ports(nn->cpp);
+	eth_table = nfp_eth_read_ports(nfp_app_cpp(nn->app));
 	if (!eth_table) {
 		nn_err(nn, "Error refreshing port state table!\n");
 		return -EIO;
@@ -659,6 +673,10 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 		goto err_unmap_tx;
 	}
 
+	err = nfp_net_pf_app_init(pf);
+	if (err)
+		goto err_unmap_rx;
+
 	pf->ddir = nfp_net_debugfs_device_add(pf->pdev);
 
 	err = nfp_net_pf_spawn_vnics(pf, ctrl_bar, tx_bar, rx_bar,
@@ -672,6 +690,8 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 
 err_clean_ddir:
 	nfp_net_debugfs_dir_clean(&pf->ddir);
+	nfp_net_pf_app_clean(pf);
+err_unmap_rx:
 	nfp_cpp_area_release_free(pf->rx_area);
 err_unmap_tx:
 	nfp_cpp_area_release_free(pf->tx_area);
-- 
2.11.0
