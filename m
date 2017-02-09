From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/12] nfp: add port layer to debugfs directories
Date: Thu,  9 Feb 2017 09:17:36 -0800
Message-ID: <20170209171738.17386-11-jakub.kicinski@netronome.com>
References: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33880 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdBIR3i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:29:38 -0500
Received: by mail-pf0-f173.google.com with SMTP id e4so2038774pfg.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:29:33 -0800 (PST)
In-Reply-To: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PF driver will support multiple ports per PCI device, add port
number to DebugFS paths.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       | 15 ++++++---
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   | 39 +++++++++++++++-------
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  7 ++--
 3 files changed, 43 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index f05f750c2ea0..60c9aa80bbd1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -797,8 +797,9 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 #ifdef CONFIG_NFP_DEBUG
 void nfp_net_debugfs_create(void);
 void nfp_net_debugfs_destroy(void);
-void nfp_net_debugfs_adapter_add(struct nfp_net *nn);
-void nfp_net_debugfs_adapter_del(struct nfp_net *nn);
+struct dentry *nfp_net_debugfs_device_add(struct pci_dev *pdev);
+void nfp_net_debugfs_port_add(struct nfp_net *nn, struct dentry *ddir, int id);
+void nfp_net_debugfs_dir_clean(struct dentry **dir);
 #else
 static inline void nfp_net_debugfs_create(void)
 {
@@ -808,11 +809,17 @@ static inline void nfp_net_debugfs_destroy(void)
 {
 }
 
-static inline void nfp_net_debugfs_adapter_add(struct nfp_net *nn)
+static inline struct dentry *nfp_net_debugfs_device_add(struct pci_dev *pdev)
 {
+	return NULL;
 }
 
-static inline void nfp_net_debugfs_adapter_del(struct nfp_net *nn)
+static inline void
+nfp_net_debugfs_port_add(struct nfp_net *nn, struct dentry *ddir, int id)
+{
+}
+
+static inline void nfp_net_debugfs_dir_clean(struct dentry **dir)
 {
 }
 #endif /* CONFIG_NFP_DEBUG */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index c66f3f954aa8..6e9372a18375 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2015 Netronome Systems, Inc.
+ * Copyright (C) 2015-2017 Netronome Systems, Inc.
  *
  * This software is dual licensed under the GNU General License Version 2,
  * June 1991 as shown in the file COPYING in the top-level directory of this
@@ -202,16 +202,17 @@ static const struct file_operations nfp_xdp_q_fops = {
 	.llseek = seq_lseek
 };
 
-void nfp_net_debugfs_adapter_add(struct nfp_net *nn)
+void nfp_net_debugfs_port_add(struct nfp_net *nn, struct dentry *ddir, int id)
 {
 	struct dentry *queues, *tx, *rx, *xdp;
-	char int_name[16];
+	char name[20];
 	int i;
 
 	if (IS_ERR_OR_NULL(nfp_dir))
 		return;
 
-	nn->debugfs_dir = debugfs_create_dir(pci_name(nn->pdev), nfp_dir);
+	sprintf(name, "port%d", id);
+	nn->debugfs_dir = debugfs_create_dir(name, ddir);
 	if (IS_ERR_OR_NULL(nn->debugfs_dir))
 		return;
 
@@ -227,24 +228,38 @@ void nfp_net_debugfs_adapter_add(struct nfp_net *nn)
 		return;
 
 	for (i = 0; i < min(nn->max_rx_rings, nn->max_r_vecs); i++) {
-		sprintf(int_name, "%d", i);
-		debugfs_create_file(int_name, S_IRUSR, rx,
+		sprintf(name, "%d", i);
+		debugfs_create_file(name, S_IRUSR, rx,
 				    &nn->r_vecs[i], &nfp_rx_q_fops);
-		debugfs_create_file(int_name, S_IRUSR, xdp,
+		debugfs_create_file(name, S_IRUSR, xdp,
 				    &nn->r_vecs[i], &nfp_xdp_q_fops);
 	}
 
 	for (i = 0; i < min(nn->max_tx_rings, nn->max_r_vecs); i++) {
-		sprintf(int_name, "%d", i);
-		debugfs_create_file(int_name, S_IRUSR, tx,
+		sprintf(name, "%d", i);
+		debugfs_create_file(name, S_IRUSR, tx,
 				    &nn->r_vecs[i], &nfp_tx_q_fops);
 	}
 }
 
-void nfp_net_debugfs_adapter_del(struct nfp_net *nn)
+struct dentry *nfp_net_debugfs_device_add(struct pci_dev *pdev)
 {
-	debugfs_remove_recursive(nn->debugfs_dir);
-	nn->debugfs_dir = NULL;
+	struct dentry *dev_dir;
+
+	if (IS_ERR_OR_NULL(nfp_dir))
+		return NULL;
+
+	dev_dir = debugfs_create_dir(pci_name(pdev), nfp_dir);
+	if (IS_ERR_OR_NULL(dev_dir))
+		return NULL;
+
+	return dev_dir;
+}
+
+void nfp_net_debugfs_dir_clean(struct dentry **dir)
+{
+	debugfs_remove_recursive(*dir);
+	*dir = NULL;
 }
 
 void nfp_net_debugfs_create(void)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
index 5bacc48e6627..ad0cc629cc32 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -83,6 +83,7 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	u32 tx_bar_sz, rx_bar_sz;
 	int tx_bar_no, rx_bar_no;
 	u8 __iomem *ctrl_bar;
+	struct dentry *ddir;
 	struct nfp_net *nn;
 	u32 startq;
 	int stride;
@@ -260,7 +261,9 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, nn);
 
 	nfp_net_info(nn);
-	nfp_net_debugfs_adapter_add(nn);
+	ddir = nfp_net_debugfs_device_add(pdev);
+	nfp_net_debugfs_port_add(nn, ddir, 0);
+	nn->debugfs_dir = ddir;
 
 	return 0;
 
@@ -293,7 +296,7 @@ static void nfp_netvf_pci_remove(struct pci_dev *pdev)
 	/* Note, the order is slightly different from above as we need
 	 * to keep the nn pointer around till we have freed everything.
 	 */
-	nfp_net_debugfs_adapter_del(nn);
+	nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
 
 	nfp_net_netdev_clean(nn->netdev);
 
-- 
2.11.0
