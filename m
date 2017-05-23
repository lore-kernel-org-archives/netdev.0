From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/4] nfp: add devlink support
Date: Tue, 23 May 2017 08:12:44 -0700
Message-ID: <20170523151247.8535-2-jakub.kicinski@netronome.com>
References: <20170523151247.8535-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35439 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758907AbdEWPNK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:13:10 -0400
Received: by mail-pf0-f175.google.com with SMTP id n23so117559774pfb.2
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 08:13:09 -0700 (PDT)
In-Reply-To: <20170523151247.8535-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>

Add initial devlink support.  This patch simply switches allocation
of per-adapter structure to devlink's priv and register devlink
with empty ops table.  See following patches for implementation
of particular ops.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile      |  1 +
 drivers/net/ethernet/netronome/nfp/nfp_devlink.c | 39 ++++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_main.c    | 22 ++++++++++---
 drivers/net/ethernet/netronome/nfp/nfp_main.h    |  3 ++
 4 files changed, 61 insertions(+), 4 deletions(-)
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
index bb586ce1ea06..f22c8f083ab0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -44,6 +44,7 @@
 #include <linux/pci.h>
 #include <linux/firmware.h>
 #include <linux/vermagic.h>
+#include <net/devlink.h>
 
 #include "nfpcore/nfp.h"
 #include "nfpcore/nfp_cpp.h"
@@ -315,6 +316,7 @@ static void nfp_fw_unload(struct nfp_pf *pf)
 static int nfp_pci_probe(struct pci_dev *pdev,
 			 const struct pci_device_id *pci_id)
 {
+	struct devlink *devlink;
 	struct nfp_pf *pf;
 	int err;
 
@@ -335,11 +337,12 @@ static int nfp_pci_probe(struct pci_dev *pdev,
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
 	pci_set_drvdata(pdev, pf);
@@ -370,8 +373,14 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_fw_unload;
 
+	err = devlink_register(devlink, &pdev->dev);
+	if (err)
+		goto err_kill_ndevs;
+
 	return 0;
 
+err_kill_ndevs:
+	nfp_net_pci_remove(pf);
 err_fw_unload:
 	if (pf->fw_loaded)
 		nfp_fw_unload(pf);
@@ -380,7 +389,7 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	nfp_cpp_free(pf->cpp);
 err_disable_msix:
 	pci_set_drvdata(pdev, NULL);
-	kfree(pf);
+	devlink_free(devlink);
 err_rel_regions:
 	pci_release_regions(pdev);
 err_pci_disable:
@@ -392,6 +401,11 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 static void nfp_pci_remove(struct pci_dev *pdev)
 {
 	struct nfp_pf *pf = pci_get_drvdata(pdev);
+	struct devlink *devlink;
+
+	devlink = priv_to_devlink(pf);
+
+	devlink_unregister(devlink);
 
 	nfp_net_pci_remove(pf);
 
@@ -404,7 +418,7 @@ static void nfp_pci_remove(struct pci_dev *pdev)
 	nfp_cpp_free(pf->cpp);
 
 	kfree(pf->eth_tbl);
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
 
-- 
2.11.0
