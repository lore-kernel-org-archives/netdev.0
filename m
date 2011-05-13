From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [net-next-2.6 03/10] caif: Use RCU and lists in cfcnfg.c for managing caif link layers
Date: Fri, 13 May 2011 14:44:01 +0200
Message-ID: <1305290648-9613-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:45221 "EHLO
	slow1.isp.as2116.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932776Ab1EMNQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:16:03 -0400
Received: from pmx.vmail.no (pmx.vmail.no [193.75.16.11])
	by slow1.isp.as2116.net (Postfix) with ESMTP id 2A07B80161
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:45:26 +0200 (CEST)
In-Reply-To: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RCU lists are used for handling the link layers instead of array.
When generating CAIF phy-id, ifindex is used as base. Legal range is 1-=
6.
Introduced set_phy_state() for managing CAIF Link layer state.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfcnfg.c |  373 ++++++++++++++++++++++++++++++---------------=
--------
 1 files changed, 213 insertions(+), 160 deletions(-)

diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 25c0b19..7892cc0 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -10,6 +10,7 @@
 #include <linux/stddef.h>
 #include <linux/slab.h>
 #include <linux/netdevice.h>
+#include <linux/module.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfpkt.h>
 #include <net/caif/cfcnfg.h>
@@ -18,11 +19,7 @@
 #include <net/caif/cffrml.h>
 #include <net/caif/cfserl.h>
 #include <net/caif/cfsrvl.h>
-
-#include <linux/module.h>
-#include <asm/atomic.h>
-
-#define MAX_PHY_LAYERS 7
+#include <net/caif/caif_dev.h>
=20
 #define container_obj(layr) container_of(layr, struct cfcnfg, layer)
=20
@@ -30,6 +27,9 @@
  * to manage physical interfaces
  */
 struct cfcnfg_phyinfo {
+	struct list_head node;
+	bool up;
+
 	/* Pointer to the layer below the MUX (framing layer) */
 	struct cflayer *frm_layer;
 	/* Pointer to the lowest actual physical layer */
@@ -39,9 +39,6 @@ struct cfcnfg_phyinfo {
 	/* Preference of the physical in interface */
 	enum cfcnfg_phy_preference pref;
=20
-	/* Reference count, number of channels using the device */
-	int phy_ref_count;
-
 	/* Information about the physical device */
 	struct dev_info dev_info;
=20
@@ -59,8 +56,8 @@ struct cfcnfg {
 	struct cflayer layer;
 	struct cflayer *ctrl;
 	struct cflayer *mux;
-	u8 last_phyid;
-	struct cfcnfg_phyinfo phy_layers[MAX_PHY_LAYERS];
+	struct list_head phys;
+	struct mutex lock;
 };
=20
 static void cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id,
@@ -76,6 +73,9 @@ struct cfcnfg *cfcnfg_create(void)
 {
 	struct cfcnfg *this;
 	struct cfctrl_rsp *resp;
+
+	might_sleep();
+
 	/* Initiate this layer */
 	this =3D kzalloc(sizeof(struct cfcnfg), GFP_ATOMIC);
 	if (!this) {
@@ -99,15 +99,19 @@ struct cfcnfg *cfcnfg_create(void)
 	resp->radioset_rsp =3D cfctrl_resp_func;
 	resp->linksetup_rsp =3D cfcnfg_linkup_rsp;
 	resp->reject_rsp =3D cfcnfg_reject_rsp;
-
-	this->last_phyid =3D 1;
+	INIT_LIST_HEAD(&this->phys);
=20
 	cfmuxl_set_uplayer(this->mux, this->ctrl, 0);
 	layer_set_dn(this->ctrl, this->mux);
 	layer_set_up(this->ctrl, this);
+	mutex_init(&this->lock);
+
 	return this;
 out_of_mem:
 	pr_warn("Out of memory\n");
+
+	synchronize_rcu();
+
 	kfree(this->mux);
 	kfree(this->ctrl);
 	kfree(this);
@@ -117,7 +121,10 @@ EXPORT_SYMBOL(cfcnfg_create);
=20
 void cfcnfg_remove(struct cfcnfg *cfg)
 {
+	might_sleep();
 	if (cfg) {
+		synchronize_rcu();
+
 		kfree(cfg->mux);
 		kfree(cfg->ctrl);
 		kfree(cfg);
@@ -128,6 +135,17 @@ static void cfctrl_resp_func(void)
 {
 }
=20
+static struct cfcnfg_phyinfo *cfcnfg_get_phyinfo_rcu(struct cfcnfg *cn=
fg,
+							u8 phyid)
+{
+	struct cfcnfg_phyinfo *phy;
+
+	list_for_each_entry_rcu(phy, &cnfg->phys, node)
+		if (phy->id =3D=3D phyid)
+			return phy;
+	return NULL;
+}
+
 static void cfctrl_enum_resp(void)
 {
 }
@@ -135,106 +153,65 @@ static void cfctrl_enum_resp(void)
 struct dev_info *cfcnfg_get_phyid(struct cfcnfg *cnfg,
 				  enum cfcnfg_phy_preference phy_pref)
 {
-	u16 i;
-
 	/* Try to match with specified preference */
-	for (i =3D 1; i < MAX_PHY_LAYERS; i++) {
-		if (cnfg->phy_layers[i].id =3D=3D i &&
-		     cnfg->phy_layers[i].pref =3D=3D phy_pref &&
-		     cnfg->phy_layers[i].frm_layer !=3D NULL) {
-			caif_assert(cnfg->phy_layers !=3D NULL);
-			caif_assert(cnfg->phy_layers[i].id =3D=3D i);
-			return &cnfg->phy_layers[i].dev_info;
-		}
-	}
-	/* Otherwise just return something */
-	for (i =3D 1; i < MAX_PHY_LAYERS; i++) {
-		if (cnfg->phy_layers[i].id =3D=3D i) {
-			caif_assert(cnfg->phy_layers !=3D NULL);
-			caif_assert(cnfg->phy_layers[i].id =3D=3D i);
-			return &cnfg->phy_layers[i].dev_info;
-		}
+	struct cfcnfg_phyinfo *phy;
+
+	list_for_each_entry_rcu(phy, &cnfg->phys, node) {
+		if (phy->up && phy->pref =3D=3D phy_pref &&
+				phy->frm_layer !=3D NULL)
+
+			return &phy->dev_info;
 	}
=20
-	return NULL;
-}
+	/* Otherwise just return something */
+	list_for_each_entry_rcu(phy, &cnfg->phys, node)
+		if (phy->up)
+			return &phy->dev_info;
=20
-static struct cfcnfg_phyinfo *cfcnfg_get_phyinfo(struct cfcnfg *cnfg,
-							u8 phyid)
-{
-	int i;
-	/* Try to match with specified preference */
-	for (i =3D 0; i < MAX_PHY_LAYERS; i++)
-		if (cnfg->phy_layers[i].frm_layer !=3D NULL &&
-		    cnfg->phy_layers[i].id =3D=3D phyid)
-			return &cnfg->phy_layers[i];
 	return NULL;
 }
=20
-
 int cfcnfg_get_id_from_ifi(struct cfcnfg *cnfg, int ifi)
 {
-	int i;
-	for (i =3D 0; i < MAX_PHY_LAYERS; i++)
-		if (cnfg->phy_layers[i].frm_layer !=3D NULL &&
-				cnfg->phy_layers[i].ifindex =3D=3D ifi)
-			return i;
+	struct cfcnfg_phyinfo *phy;
+
+	list_for_each_entry_rcu(phy, &cnfg->phys, node)
+		if (phy->ifindex =3D=3D ifi && phy->up)
+			return phy->id;
 	return -ENODEV;
 }
=20
-int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg, struct cflayer *ad=
ap_layer)
+int cfcnfg_disconn_adapt_layer(struct cfcnfg *cfg, struct cflayer *ada=
p_layer)
 {
 	u8 channel_id =3D 0;
 	int ret =3D 0;
 	struct cflayer *servl =3D NULL;
-	struct cfcnfg_phyinfo *phyinfo =3D NULL;
-	u8 phyid =3D 0;
=20
 	caif_assert(adap_layer !=3D NULL);
+
 	channel_id =3D adap_layer->id;
 	if (adap_layer->dn =3D=3D NULL || channel_id =3D=3D 0) {
 		pr_err("adap_layer->dn =3D=3D NULL or adap_layer->id is 0\n");
 		ret =3D -ENOTCONN;
 		goto end;
 	}
-	servl =3D cfmuxl_remove_uplayer(cnfg->mux, channel_id);
+
+	servl =3D cfmuxl_remove_uplayer(cfg->mux, channel_id);
 	if (servl =3D=3D NULL) {
-		pr_err("PROTOCOL ERROR - Error removing service_layer Channel_Id(%d)=
",
-		       channel_id);
+		pr_err("PROTOCOL ERROR - "
+				"Error removing service_layer Channel_Id(%d)",
+				channel_id);
 		ret =3D -EINVAL;
 		goto end;
 	}
-	layer_set_up(servl, NULL);
-	ret =3D cfctrl_linkdown_req(cnfg->ctrl, channel_id, adap_layer);
-	if (ret)
-		goto end;
-	caif_assert(channel_id =3D=3D servl->id);
-	if (adap_layer->dn !=3D NULL) {
-		phyid =3D cfsrvl_getphyid(adap_layer->dn);
-
-		phyinfo =3D cfcnfg_get_phyinfo(cnfg, phyid);
-		if (phyinfo =3D=3D NULL) {
-			pr_warn("No interface to send disconnect to\n");
-			ret =3D -ENODEV;
-			goto end;
-		}
-		if (phyinfo->id !=3D phyid ||
-			phyinfo->phy_layer->id !=3D phyid ||
-			phyinfo->frm_layer->id !=3D phyid) {
-			pr_err("Inconsistency in phy registration\n");
-			ret =3D -EINVAL;
-			goto end;
-		}
-	}
-	if (phyinfo !=3D NULL && --phyinfo->phy_ref_count =3D=3D 0 &&
-		phyinfo->phy_layer !=3D NULL &&
-		phyinfo->phy_layer->modemcmd !=3D NULL) {
-		phyinfo->phy_layer->modemcmd(phyinfo->phy_layer,
-					     _CAIF_MODEMCMD_PHYIF_USELESS);
-	}
+
+	ret =3D cfctrl_linkdown_req(cfg->ctrl, channel_id, adap_layer);
+
 end:
-	cfsrvl_put(servl);
-	cfctrl_cancel_req(cnfg->ctrl, adap_layer);
+	cfctrl_cancel_req(cfg->ctrl, adap_layer);
+
+	/* Do RCU sync before initiating cleanup */
+	synchronize_rcu();
 	if (adap_layer->ctrlcmd !=3D NULL)
 		adap_layer->ctrlcmd(adap_layer, CAIF_CTRLCMD_DEINIT_RSP, 0);
 	return ret;
@@ -269,39 +246,56 @@ int cfcnfg_add_adaptation_layer(struct cfcnfg *cn=
fg,
 				int *proto_tail)
 {
 	struct cflayer *frml;
+	struct cfcnfg_phyinfo *phy;
+	int err;
+
+	rcu_read_lock();
+	phy =3D cfcnfg_get_phyinfo_rcu(cnfg, param->phyid);
+	if (!phy) {
+		err =3D -ENODEV;
+		goto unlock;
+	}
+	err =3D -EINVAL;
+
 	if (adap_layer =3D=3D NULL) {
 		pr_err("adap_layer is zero\n");
-		return -EINVAL;
+		goto unlock;
 	}
 	if (adap_layer->receive =3D=3D NULL) {
 		pr_err("adap_layer->receive is NULL\n");
-		return -EINVAL;
+		goto unlock;
 	}
 	if (adap_layer->ctrlcmd =3D=3D NULL) {
 		pr_err("adap_layer->ctrlcmd =3D=3D NULL\n");
-		return -EINVAL;
+		goto unlock;
 	}
-	frml =3D cnfg->phy_layers[param->phyid].frm_layer;
+
+	err =3D -ENODEV;
+	frml =3D phy->frm_layer;
 	if (frml =3D=3D NULL) {
 		pr_err("Specified PHY type does not exist!\n");
-		return -ENODEV;
+		goto unlock;
 	}
-	caif_assert(param->phyid =3D=3D cnfg->phy_layers[param->phyid].id);
-	caif_assert(cnfg->phy_layers[param->phyid].frm_layer->id =3D=3D
+	caif_assert(param->phyid =3D=3D phy->id);
+	caif_assert(phy->frm_layer->id =3D=3D
 		     param->phyid);
-	caif_assert(cnfg->phy_layers[param->phyid].phy_layer->id =3D=3D
+	caif_assert(phy->phy_layer->id =3D=3D
 		     param->phyid);
=20
-	*ifindex =3D cnfg->phy_layers[param->phyid].ifindex;
+	*ifindex =3D phy->ifindex;
+	*proto_tail =3D 2;
 	*proto_head =3D
-		protohead[param->linktype]+
-		(cnfg->phy_layers[param->phyid].use_stx ? 1 : 0);
+		protohead[param->linktype] + (phy->use_stx ? 1 : 0);
=20
-	*proto_tail =3D 2;
+	rcu_read_unlock();
=20
 	/* FIXME: ENUMERATE INITIALLY WHEN ACTIVATING PHYSICAL INTERFACE */
 	cfctrl_enum_req(cnfg->ctrl, param->phyid);
 	return cfctrl_linkup_request(cnfg->ctrl, param, adap_layer);
+
+unlock:
+	rcu_read_unlock();
+	return err;
 }
 EXPORT_SYMBOL(cfcnfg_add_adaptation_layer);
=20
@@ -315,32 +309,37 @@ static void cfcnfg_reject_rsp(struct cflayer *lay=
er, u8 channel_id,
=20
 static void
 cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_sr=
v serv,
-		 u8 phyid, struct cflayer *adapt_layer)
+		  u8 phyid, struct cflayer *adapt_layer)
 {
 	struct cfcnfg *cnfg =3D container_obj(layer);
 	struct cflayer *servicel =3D NULL;
 	struct cfcnfg_phyinfo *phyinfo;
 	struct net_device *netdev;
=20
+	rcu_read_lock();
+
 	if (adapt_layer =3D=3D NULL) {
-		pr_debug("link setup response but no client exist, send linkdown bac=
k\n");
+		pr_debug("link setup response but no client exist,"
+				"send linkdown back\n");
 		cfctrl_linkdown_req(cnfg->ctrl, channel_id, NULL);
-		return;
+		goto unlock;
 	}
=20
 	caif_assert(cnfg !=3D NULL);
 	caif_assert(phyid !=3D 0);
-	phyinfo =3D &cnfg->phy_layers[phyid];
+
+	phyinfo =3D cfcnfg_get_phyinfo_rcu(cnfg, phyid);
+	if (phyinfo =3D=3D NULL) {
+		pr_err("ERROR: Link Layer Device dissapeared"
+				"while connecting\n");
+		goto unlock;
+	}
+
+	caif_assert(phyinfo !=3D NULL);
 	caif_assert(phyinfo->id =3D=3D phyid);
 	caif_assert(phyinfo->phy_layer !=3D NULL);
 	caif_assert(phyinfo->phy_layer->id =3D=3D phyid);
=20
-	phyinfo->phy_ref_count++;
-	if (phyinfo->phy_ref_count =3D=3D 1 &&
-	    phyinfo->phy_layer->modemcmd !=3D NULL) {
-		phyinfo->phy_layer->modemcmd(phyinfo->phy_layer,
-					     _CAIF_MODEMCMD_PHYIF_USEFULL);
-	}
 	adapt_layer->id =3D channel_id;
=20
 	switch (serv) {
@@ -348,7 +347,8 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel=
_id, enum cfctrl_srv serv,
 		servicel =3D cfvei_create(channel_id, &phyinfo->dev_info);
 		break;
 	case CFCTRL_SRV_DATAGRAM:
-		servicel =3D cfdgml_create(channel_id, &phyinfo->dev_info);
+		servicel =3D cfdgml_create(channel_id,
+					&phyinfo->dev_info);
 		break;
 	case CFCTRL_SRV_RFM:
 		netdev =3D phyinfo->dev_info.dev;
@@ -365,94 +365,93 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 chann=
el_id, enum cfctrl_srv serv,
 		servicel =3D cfdbgl_create(channel_id, &phyinfo->dev_info);
 		break;
 	default:
-		pr_err("Protocol error. Link setup response - unknown channel type\n=
");
-		return;
+		pr_err("Protocol error. Link setup response "
+				"- unknown channel type\n");
+		goto unlock;
 	}
 	if (!servicel) {
 		pr_warn("Out of memory\n");
-		return;
+		goto unlock;
 	}
 	layer_set_dn(servicel, cnfg->mux);
 	cfmuxl_set_uplayer(cnfg->mux, servicel, channel_id);
 	layer_set_up(servicel, adapt_layer);
 	layer_set_dn(adapt_layer, servicel);
-	cfsrvl_get(servicel);
+
+	rcu_read_unlock();
+
 	servicel->ctrlcmd(servicel, CAIF_CTRLCMD_INIT_RSP, 0);
+	return;
+unlock:
+	rcu_read_unlock();
 }
=20
 void
 cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_typ=
e,
 		     struct net_device *dev, struct cflayer *phy_layer,
-		     u16 *phyid, enum cfcnfg_phy_preference pref,
+		     u16 *phy_id, enum cfcnfg_phy_preference pref,
 		     bool fcs, bool stx)
 {
 	struct cflayer *frml;
 	struct cflayer *phy_driver =3D NULL;
+	struct cfcnfg_phyinfo *phyinfo;
 	int i;
+	u8 phyid;
=20
+	mutex_lock(&cnfg->lock);
=20
-	if (cnfg->phy_layers[cnfg->last_phyid].frm_layer =3D=3D NULL) {
-		*phyid =3D cnfg->last_phyid;
-
-		/* range: * 1..(MAX_PHY_LAYERS-1) */
-		cnfg->last_phyid =3D
-		    (cnfg->last_phyid % (MAX_PHY_LAYERS - 1)) + 1;
-	} else {
-		*phyid =3D 0;
-		for (i =3D 1; i < MAX_PHY_LAYERS; i++) {
-			if (cnfg->phy_layers[i].frm_layer =3D=3D NULL) {
-				*phyid =3D i;
-				break;
-			}
-		}
-	}
-	if (*phyid =3D=3D 0) {
-		pr_err("No Available PHY ID\n");
-		return;
+	/* CAIF protocol allow maximum 6 link-layers */
+	for (i =3D 0; i < 7; i++) {
+		phyid =3D (dev->ifindex + i) & 0x7;
+		if (phyid =3D=3D 0)
+			continue;
+		if (cfcnfg_get_phyinfo_rcu(cnfg, phyid) =3D=3D NULL)
+			goto got_phyid;
 	}
+	pr_warn("Too many CAIF Link Layers (max 6)\n");
+	goto out;
+
+got_phyid:
+	phyinfo =3D kzalloc(sizeof(struct cfcnfg_phyinfo), GFP_ATOMIC);
=20
 	switch (phy_type) {
 	case CFPHYTYPE_FRAG:
 		phy_driver =3D
-		    cfserl_create(CFPHYTYPE_FRAG, *phyid, stx);
+		    cfserl_create(CFPHYTYPE_FRAG, phyid, stx);
 		if (!phy_driver) {
 			pr_warn("Out of memory\n");
-			return;
+			goto out;
 		}
-
 		break;
 	case CFPHYTYPE_CAIF:
 		phy_driver =3D NULL;
 		break;
 	default:
-		pr_err("%d\n", phy_type);
-		return;
-		break;
+		goto out;
 	}
-
-	phy_layer->id =3D *phyid;
-	cnfg->phy_layers[*phyid].pref =3D pref;
-	cnfg->phy_layers[*phyid].id =3D *phyid;
-	cnfg->phy_layers[*phyid].dev_info.id =3D *phyid;
-	cnfg->phy_layers[*phyid].dev_info.dev =3D dev;
-	cnfg->phy_layers[*phyid].phy_layer =3D phy_layer;
-	cnfg->phy_layers[*phyid].phy_ref_count =3D 0;
-	cnfg->phy_layers[*phyid].ifindex =3D dev->ifindex;
-	cnfg->phy_layers[*phyid].use_stx =3D stx;
-	cnfg->phy_layers[*phyid].use_fcs =3D fcs;
+	phy_layer->id =3D phyid;
+	phyinfo->pref =3D pref;
+	phyinfo->id =3D phyid;
+	phyinfo->dev_info.id =3D phyid;
+	phyinfo->dev_info.dev =3D dev;
+	phyinfo->phy_layer =3D phy_layer;
+	phyinfo->ifindex =3D dev->ifindex;
+	phyinfo->use_stx =3D stx;
+	phyinfo->use_fcs =3D fcs;
=20
 	phy_layer->type =3D phy_type;
-	frml =3D cffrml_create(*phyid, fcs);
+	frml =3D cffrml_create(phyid, fcs);
+
 	if (!frml) {
 		pr_warn("Out of memory\n");
-		return;
+		kfree(phyinfo);
+		goto out;
 	}
-	cnfg->phy_layers[*phyid].frm_layer =3D frml;
-	cfmuxl_set_dnlayer(cnfg->mux, frml, *phyid);
+	phyinfo->frm_layer =3D frml;
 	layer_set_up(frml, cnfg->mux);
=20
 	if (phy_driver !=3D NULL) {
-		phy_driver->id =3D *phyid;
+		phy_driver->id =3D phyid;
 		layer_set_dn(frml, phy_driver);
 		layer_set_up(phy_driver, frml);
 		layer_set_dn(phy_driver, phy_layer);
@@ -461,33 +460,87 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cf=
cnfg_phy_type phy_type,
 		layer_set_dn(frml, phy_layer);
 		layer_set_up(phy_layer, frml);
 	}
+
+	list_add_rcu(&phyinfo->node, &cnfg->phys);
+out:
+	mutex_unlock(&cnfg->lock);
 }
 EXPORT_SYMBOL(cfcnfg_add_phy_layer);
=20
+int cfcnfg_set_phy_state(struct cfcnfg *cnfg, struct cflayer *phy_laye=
r,
+		bool up)
+{
+	struct cfcnfg_phyinfo *phyinfo;
+
+	rcu_read_lock();
+	phyinfo =3D cfcnfg_get_phyinfo_rcu(cnfg, phy_layer->id);
+	if (phyinfo =3D=3D NULL) {
+		rcu_read_unlock();
+		return -ENODEV;
+	}
+
+	if (phyinfo->up =3D=3D up) {
+		rcu_read_unlock();
+		return 0;
+	}
+	phyinfo->up =3D up;
+
+	if (up) {
+		cffrml_hold(phyinfo->frm_layer);
+		cfmuxl_set_dnlayer(cnfg->mux, phyinfo->frm_layer,
+					phy_layer->id);
+	} else {
+		cfmuxl_remove_dnlayer(cnfg->mux, phy_layer->id);
+		cffrml_put(phyinfo->frm_layer);
+	}
+
+	rcu_read_unlock();
+	return 0;
+}
+EXPORT_SYMBOL(cfcnfg_set_phy_state);
+
 int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, struct cflayer *phy_laye=
r)
 {
 	struct cflayer *frml, *frml_dn;
 	u16 phyid;
+	struct cfcnfg_phyinfo *phyinfo;
+
+	might_sleep();
+
+	mutex_lock(&cnfg->lock);
+
 	phyid =3D phy_layer->id;
-	caif_assert(phyid =3D=3D cnfg->phy_layers[phyid].id);
-	caif_assert(phy_layer =3D=3D cnfg->phy_layers[phyid].phy_layer);
+	phyinfo =3D cfcnfg_get_phyinfo_rcu(cnfg, phyid);
+
+	if (phyinfo =3D=3D NULL)
+		return 0;
+	caif_assert(phyid =3D=3D phyinfo->id);
+	caif_assert(phy_layer =3D=3D phyinfo->phy_layer);
 	caif_assert(phy_layer->id =3D=3D phyid);
-	caif_assert(cnfg->phy_layers[phyid].frm_layer->id =3D=3D phyid);
+	caif_assert(phyinfo->frm_layer->id =3D=3D phyid);
+
+	list_del_rcu(&phyinfo->node);
+	synchronize_rcu();
=20
-	memset(&cnfg->phy_layers[phy_layer->id], 0,
-	       sizeof(struct cfcnfg_phyinfo));
-	frml =3D cfmuxl_remove_dnlayer(cnfg->mux, phy_layer->id);
+	frml =3D phyinfo->frm_layer;
 	frml_dn =3D frml->dn;
 	cffrml_set_uplayer(frml, NULL);
 	cffrml_set_dnlayer(frml, NULL);
-	kfree(frml);
-
 	if (phy_layer !=3D frml_dn) {
 		layer_set_up(frml_dn, NULL);
 		layer_set_dn(frml_dn, NULL);
-		kfree(frml_dn);
 	}
 	layer_set_up(phy_layer, NULL);
+
+
+
+	if (phyinfo->phy_layer !=3D frml_dn)
+		kfree(frml_dn);
+
+	kfree(frml);
+	kfree(phyinfo);
+	mutex_unlock(&cnfg->lock);
+
 	return 0;
 }
 EXPORT_SYMBOL(cfcnfg_del_phy_layer);
--=20
1.7.1

