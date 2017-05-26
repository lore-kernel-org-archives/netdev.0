From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 1/6] nfp: move mutex init out of net code
Date: Fri, 26 May 2017 01:03:31 -0700
Message-ID: <20170526080336.32689-2-jakub.kicinski@netronome.com>
References: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Cc: jiri@resnulli.us, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35127 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934482AbdEZIDx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:03:53 -0400
Received: by mail-pf0-f171.google.com with SMTP id n23so4725066pfb.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:03:52 -0700 (PDT)
In-Reply-To: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move mutex init to main file close to structure allocation.
This will allow mutex to be taken before net code runs (e.g.
from devlink callbacks).  While at it remember to destroy
the mutex.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c     | 4 ++++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 1 -
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index bb586ce1ea06..3a131559153a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -41,6 +41,7 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/mutex.h>
 #include <linux/pci.h>
 #include <linux/firmware.h>
 #include <linux/vermagic.h>
@@ -342,6 +343,7 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	}
 	INIT_LIST_HEAD(&pf->vnics);
 	INIT_LIST_HEAD(&pf->ports);
+	mutex_init(&pf->lock);
 	pci_set_drvdata(pdev, pf);
 	pf->pdev = pdev;
 
@@ -380,6 +382,7 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	nfp_cpp_free(pf->cpp);
 err_disable_msix:
 	pci_set_drvdata(pdev, NULL);
+	mutex_destroy(&pf->lock);
 	kfree(pf);
 err_rel_regions:
 	pci_release_regions(pdev);
@@ -404,6 +407,7 @@ static void nfp_pci_remove(struct pci_dev *pdev)
 	nfp_cpp_free(pf->cpp);
 
 	kfree(pf->eth_tbl);
+	mutex_destroy(&pf->lock);
 	kfree(pf);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index dd1118c7e1a4..5139c13b6e53 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -641,7 +641,6 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 	int err;
 
 	INIT_WORK(&pf->port_refresh_work, nfp_net_refresh_vnics);
-	mutex_init(&pf->lock);
 
 	/* Verify that the board has completed initialization */
 	if (!nfp_is_ready(pf->cpp)) {
-- 
2.11.0
