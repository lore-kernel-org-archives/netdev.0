From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] caif: add error handling for allocation
Date: Wed, 21 Sep 2011 10:21:59 +0300
Message-ID: <20110921072159.GJ4999@elgon.mountain>
References: <CAJK669Yb6V=xr9ZvQGOKGEvmzO1JGhrHD+sR69b04EQxUjOOrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:45097 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab1IUHWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 03:22:14 -0400
Content-Disposition: inline
In-Reply-To: <CAJK669Yb6V=xr9ZvQGOKGEvmzO1JGhrHD+sR69b04EQxUjOOrQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The allocation of "phyinfo" wasn't checked, and also the allocation
wasn't freed on error paths.  Sjur Br=E6ndeland pointed out as well
that "phy_driver" should be freed on the error path too.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
V2:  Add a kfree(phy_driver).

diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index f07ab8c..00523ec 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -467,7 +467,7 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcn=
fg_phy_type phy_type,
 {
 	struct cflayer *frml;
 	struct cflayer *phy_driver =3D NULL;
-	struct cfcnfg_phyinfo *phyinfo;
+	struct cfcnfg_phyinfo *phyinfo =3D NULL;
 	int i;
 	u8 phyid;
=20
@@ -482,23 +482,25 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cf=
cnfg_phy_type phy_type,
 			goto got_phyid;
 	}
 	pr_warn("Too many CAIF Link Layers (max 6)\n");
-	goto out;
+	goto out_err;
=20
 got_phyid:
 	phyinfo =3D kzalloc(sizeof(struct cfcnfg_phyinfo), GFP_ATOMIC);
+	if (!phyinfo)
+		goto out_err;
=20
 	switch (phy_type) {
 	case CFPHYTYPE_FRAG:
 		phy_driver =3D
 		    cfserl_create(CFPHYTYPE_FRAG, phyid, stx);
 		if (!phy_driver)
-			goto out;
+			goto out_err;
 		break;
 	case CFPHYTYPE_CAIF:
 		phy_driver =3D NULL;
 		break;
 	default:
-		goto out;
+		goto out_err;
 	}
 	phy_layer->id =3D phyid;
 	phyinfo->pref =3D pref;
@@ -512,10 +514,8 @@ got_phyid:
=20
 	frml =3D cffrml_create(phyid, fcs);
=20
-	if (!frml) {
-		kfree(phyinfo);
-		goto out;
-	}
+	if (!frml)
+		goto out_err;
 	phyinfo->frm_layer =3D frml;
 	layer_set_up(frml, cnfg->mux);
=20
@@ -531,7 +531,12 @@ got_phyid:
 	}
=20
 	list_add_rcu(&phyinfo->node, &cnfg->phys);
-out:
+	mutex_unlock(&cnfg->lock);
+	return;
+
+out_err:
+	kfree(phy_driver);
+	kfree(phyinfo);
 	mutex_unlock(&cnfg->lock);
 }
 EXPORT_SYMBOL(cfcnfg_add_phy_layer);
