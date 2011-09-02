From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] caif: add error handling for allocation
Date: Fri, 2 Sep 2011 11:07:16 +0300
Message-ID: <20110902080716.GF2430@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"open list:CAIF NETWORK LAYER" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:60974 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758143Ab1IBIJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 04:09:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The allocation could fail so we should check, or other errors could
happen and we should free the "phyinfo" variable.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index f07ab8c..b213b53 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -467,7 +467,7 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
 {
 	struct cflayer *frml;
 	struct cflayer *phy_driver = NULL;
-	struct cfcnfg_phyinfo *phyinfo;
+	struct cfcnfg_phyinfo *phyinfo = NULL;
 	int i;
 	u8 phyid;
 
@@ -482,23 +482,25 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
 			goto got_phyid;
 	}
 	pr_warn("Too many CAIF Link Layers (max 6)\n");
-	goto out;
+	goto out_err;
 
 got_phyid:
 	phyinfo = kzalloc(sizeof(struct cfcnfg_phyinfo), GFP_ATOMIC);
+	if (!phyinfo)
+		goto out_err;
 
 	switch (phy_type) {
 	case CFPHYTYPE_FRAG:
 		phy_driver =
 		    cfserl_create(CFPHYTYPE_FRAG, phyid, stx);
 		if (!phy_driver)
-			goto out;
+			goto out_err;
 		break;
 	case CFPHYTYPE_CAIF:
 		phy_driver = NULL;
 		break;
 	default:
-		goto out;
+		goto out_err;
 	}
 	phy_layer->id = phyid;
 	phyinfo->pref = pref;
@@ -512,10 +514,8 @@ got_phyid:
 
 	frml = cffrml_create(phyid, fcs);
 
-	if (!frml) {
-		kfree(phyinfo);
-		goto out;
-	}
+	if (!frml)
+		goto out_err;
 	phyinfo->frm_layer = frml;
 	layer_set_up(frml, cnfg->mux);
 
@@ -531,7 +531,11 @@ got_phyid:
 	}
 
 	list_add_rcu(&phyinfo->node, &cnfg->phys);
-out:
+	mutex_unlock(&cnfg->lock);
+	return;
+
+out_err:
+	kfree(phyinfo);
 	mutex_unlock(&cnfg->lock);
 }
 EXPORT_SYMBOL(cfcnfg_add_phy_layer);
