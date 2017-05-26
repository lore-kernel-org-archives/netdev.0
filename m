From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 3/6] nfp: add helper for cleaning up vNICs
Date: Fri, 26 May 2017 01:03:33 -0700
Message-ID: <20170526080336.32689-4-jakub.kicinski@netronome.com>
References: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Cc: jiri@resnulli.us, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34070 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935088AbdEZIDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:03:54 -0400
Received: by mail-pf0-f181.google.com with SMTP id 9so4733884pfj.1
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:03:54 -0700 (PDT)
In-Reply-To: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will soon have to invoke more clean up for vNICs.
Move the cleanup callbacks into a helper.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 8f5a240c8d2f..b0a6ec4fe097 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -418,6 +418,12 @@ nfp_net_pf_alloc_vnics(struct nfp_pf *pf, void __iomem *ctrl_bar,
 	return err;
 }
 
+static void nfp_net_pf_clean_vnic(struct nfp_pf *pf, struct nfp_net *nn)
+{
+	nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
+	nfp_net_clean(nn);
+}
+
 static int
 nfp_net_pf_spawn_vnics(struct nfp_pf *pf,
 		       void __iomem *ctrl_bar, void __iomem *tx_bar,
@@ -480,10 +486,8 @@ nfp_net_pf_spawn_vnics(struct nfp_pf *pf,
 	return 0;
 
 err_prev_deinit:
-	list_for_each_entry_continue_reverse(nn, &pf->vnics, vnic_list) {
-		nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
-		nfp_net_clean(nn);
-	}
+	list_for_each_entry_continue_reverse(nn, &pf->vnics, vnic_list)
+		nfp_net_pf_clean_vnic(pf, nn);
 	nfp_net_irqs_disable(pf->pdev);
 err_vec_free:
 	kfree(pf->irq_entries);
@@ -585,9 +589,7 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 		if (!nn->port || nn->port->type != NFP_PORT_INVALID)
 			continue;
 
-		nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
-		nfp_net_clean(nn);
-
+		nfp_net_pf_clean_vnic(pf, nn);
 		nfp_net_pf_free_vnic(pf, nn);
 	}
 
@@ -760,11 +762,8 @@ void nfp_net_pci_remove(struct nfp_pf *pf)
 	if (list_empty(&pf->vnics))
 		goto out;
 
-	list_for_each_entry(nn, &pf->vnics, vnic_list) {
-		nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
-
-		nfp_net_clean(nn);
-	}
+	list_for_each_entry(nn, &pf->vnics, vnic_list)
+		nfp_net_pf_clean_vnic(pf, nn);
 
 	nfp_net_pf_free_vnics(pf);
 
-- 
2.11.0
