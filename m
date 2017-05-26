From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 2/6] nfp: add devlink support
Date: Fri, 26 May 2017 01:03:32 -0700
Message-ID: <20170526080336.32689-3-jakub.kicinski@netronome.com>
References: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Cc: jiri@resnulli.us, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33320 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934646AbdEZIDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:03:54 -0400
Received: by mail-pf0-f175.google.com with SMTP id e193so4785901pfh.0
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:03:53 -0700 (PDT)
In-Reply-To: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>

Add initial devlink support.  This patch simply switches allocation
of per-adapter structure to devlink's priv and register devlink
with empty ops table.  See following patches for implementation
of particular ops.

We should now clear the app pointer on exit, this is how devlink
callbacks will know app is not initialized.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile       |  1 +
 drivers/net/ethernet/netronome/nfp/nfp_devlink.c  | 39 +++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_main.c     | 24 +++++++++++---
 drivers/net/ethernet/netronome/nfp/nfp_main.h     |  3 ++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c |  1 +
 5 files changed, 63 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_devlink.c

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index e8333283ada6..95f6b97b5d71 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -15,6 +15,7 @@ nfp-objs := \
 	    nfpcore/nfp_rtsym.o \
 	    nfpcore/nfp_target.o \
 	    nfp_app.o \
+	    nfp_devlink.o \
 	    nfp_main.o \
 	    nfp_net_common.o \
 	    nfp_net_ethtool.o \
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_devlink.c b/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
new file mode 100644
index 000000000000..a8a52b3ff42b
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_devlink.c
@@ -0,0 +1,39 @@
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
+#include <net/devlink.h>
+
+#include "nfp_main.h"
+
+const struct devlink_ops nfp_devlink_ops = {
+};
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index 3a131559153a..f22f56c9218f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -45,6 +45,7 @@
 #include <linux/pci.h>
 #include <linux/firmware.h>
 #include <linux/vermagic.h>
+#include <net/devlink.h>
 
 #include "nfpcore/nfp.h"
 #include "nfpcore/nfp_cpp.h"
@@ -316,6 +317,7 @@ static void nfp_fw_unload(struct nfp_pf *pf)
 static int nfp_pci_probe(struct pci_dev *pdev,
 			 const struct pci_device_id *pci_id)
 {
+	struct devlink *devlink;
 	struct nfp_pf *pf;
 	int err;
 
@@ -336,11 +338,12 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 		goto err_pci_disable;
 	}
 
-	pf = kzalloc(sizeof(*pf), GFP_KERNEL);
-	if (!pf) {
+	devlink = devlink_alloc(&nfp_devlink_ops, sizeof(*pf));
+	if (!devlink) {
 		err = -ENOMEM;
 		goto err_rel_regions;
 	}
+	pf = devlink_priv(devlink);
 	INIT_LIST_HEAD(&pf->vnics);
 	INIT_LIST_HEAD(&pf->ports);
 	mutex_init(&pf->lock);
@@ -362,10 +365,14 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 		 nfp_hwinfo_lookup(pf->cpp, "assembly.revision"),
 		 nfp_hwinfo_lookup(pf->cpp, "cpld.version"));
 
-	err = nfp_nsp_init(pdev, pf);
+	err = devlink_register(devlink, &pdev->dev);
 	if (err)
 		goto err_cpp_free;
 
+	err = nfp_nsp_init(pdev, pf);
+	if (err)
+		goto err_devlink_unreg;
+
 	nfp_pcie_sriov_read_nfd_limit(pf);
 
 	err = nfp_net_pci_probe(pf);
@@ -378,12 +385,14 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	if (pf->fw_loaded)
 		nfp_fw_unload(pf);
 	kfree(pf->eth_tbl);
+err_devlink_unreg:
+	devlink_unregister(devlink);
 err_cpp_free:
 	nfp_cpp_free(pf->cpp);
 err_disable_msix:
 	pci_set_drvdata(pdev, NULL);
 	mutex_destroy(&pf->lock);
-	kfree(pf);
+	devlink_free(devlink);
 err_rel_regions:
 	pci_release_regions(pdev);
 err_pci_disable:
@@ -395,11 +404,16 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 static void nfp_pci_remove(struct pci_dev *pdev)
 {
 	struct nfp_pf *pf = pci_get_drvdata(pdev);
+	struct devlink *devlink;
+
+	devlink = priv_to_devlink(pf);
 
 	nfp_net_pci_remove(pf);
 
 	nfp_pcie_sriov_disable(pdev);
 
+	devlink_unregister(devlink);
+
 	if (pf->fw_loaded)
 		nfp_fw_unload(pf);
 
@@ -408,7 +422,7 @@ static void nfp_pci_remove(struct pci_dev *pdev)
 
 	kfree(pf->eth_tbl);
 	mutex_destroy(&pf->lock);
-	kfree(pf);
+	devlink_free(devlink);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index 991c4cba0bbf..526db8029dea 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -47,6 +47,7 @@
 #include <linux/workqueue.h>
 
 struct dentry;
+struct devlink_ops;
 struct pci_dev;
 
 struct nfp_cpp;
@@ -107,6 +108,8 @@ struct nfp_pf {
 
 extern struct pci_driver nfp_netvf_pci_driver;
 
+extern const struct devlink_ops nfp_devlink_ops;
+
 int nfp_net_pci_probe(struct nfp_pf *pf);
 void nfp_net_pci_remove(struct nfp_pf *pf);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 5139c13b6e53..8f5a240c8d2f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -502,6 +502,7 @@ static int nfp_net_pf_app_init(struct nfp_pf *pf)
 static void nfp_net_pf_app_clean(struct nfp_pf *pf)
 {
 	nfp_app_free(pf->app);
+	pf->app = NULL;
 }
 
 static void nfp_net_pci_remove_finish(struct nfp_pf *pf)
-- 
2.11.0
