From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 04/13] nfp: add nfp_net_pf_free_vnic() function
Date: Fri, 19 May 2017 15:01:46 -0700
Message-ID: <20170519220155.27857-5-jakub.kicinski@netronome.com>
References: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35918 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932372AbdESWCY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 18:02:24 -0400
Received: by mail-pf0-f170.google.com with SMTP id m17so45465172pfg.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 15:02:24 -0700 (PDT)
In-Reply-To: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Soon a third place will need to free a struct nfp_net.  Add a free
counterpart to nfp_net_pf_alloc_vnic().

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 532371940fd6..5f0c58a56182 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -268,16 +268,20 @@ static u8 __iomem *nfp_net_pf_map_ctrl_bar(struct nfp_pf *pf)
 	return ctrl_bar;
 }
 
+static void nfp_net_pf_free_vnic(struct nfp_pf *pf, struct nfp_net *nn)
+{
+	list_del(&nn->vnic_list);
+	pf->num_vnics--;
+	nfp_net_free(nn);
+}
+
 static void nfp_net_pf_free_vnics(struct nfp_pf *pf)
 {
 	struct nfp_net *nn;
 
 	while (!list_empty(&pf->vnics)) {
 		nn = list_first_entry(&pf->vnics, struct nfp_net, vnic_list);
-		list_del(&nn->vnic_list);
-		pf->num_vnics--;
-
-		nfp_net_free(nn);
+		nfp_net_pf_free_vnic(pf, nn);
 	}
 }
 
@@ -518,9 +522,7 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 		nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
 		nfp_net_clean(nn);
 
-		list_del(&nn->vnic_list);
-		pf->num_vnics--;
-		nfp_net_free(nn);
+		nfp_net_pf_free_vnic(pf, nn);
 	}
 
 	if (list_empty(&pf->vnics))
-- 
2.11.0
