From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 06/13] net-caif: add CAIF generic caif support
 functions
Date: Wed, 20 Jan 2010 23:55:23 +0100
Message-ID: <1264028130-14364-7-git-send-email-sjur.brandeland@stericsson.com>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:52371 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384Ab0ATX4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:56:31 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00CEIIDJGCC0@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:07 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00LQBICIDUE0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:07 +0100 (CET)
In-reply-to: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Support functions for the generic caif protocol stack:
cflist.c        - List implementation for CAIF
cfcnfg.c        - CAIF Configuration Module used for
                  adding and removing drivers and connection
cfpkt_skbuff.c  - CAIF Packet layer (SKB helper functions)

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/generic/cfcnfg.c       |  538 +++++++++++++++++++++++++++++++++++
 net/caif/generic/cflist.c       |   88 ++++++
 net/caif/generic/cfpkt_skbuff.c |  596 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 1222 insertions(+), 0 deletions(-)

diff --git a/net/caif/generic/cfcnfg.c b/net/caif/generic/cfcnfg.c
new file mode 100644
index 0000000..0b664ff
--- /dev/null
+++ b/net/caif/generic/cfcnfg.c
@@ -0,0 +1,538 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cflst.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <net/caif/generic/cfctrl.h>
+#include <net/caif/generic/cfmuxl.h>
+#include <net/caif/generic/cffrml.h>
+#include <net/caif/generic/cfserl.h>
+#include <net/caif/generic/cfsrvl.h>
+
+#include <linux/module.h>
+
+#define MAX_PHY_LAYERS 7
+#define PHY_NAME_LEN 20
+
+#define container_obj(layr) cfglu_container_of(layr, struct cfcnfg, layer)
+
+/* Information about CAIF physical interfaces held by Config Module in order
+ * to manage physical interfaces
+ */
+struct cfcnfg_phyinfo {
+	/* Pointer to the layer below the MUX (framing layer) */
+	struct layer *frm_layer;
+	/* Pointer to the lowest actual physical layer */
+	struct layer *phy_layer;
+	/* Unique identifier of the physical interface */
+	unsigned int id;
+	/* Preference of the physical in interface */
+	enum cfcnfg_phy_preference pref;
+
+	/* Reference count, number of channels using the device */
+	int phy_ref_count;
+
+	/* Information about the physical device */
+	struct dev_info dev_info;
+};
+
+struct cfcnfg {
+	struct layer layer;
+	struct layer *ctrl;
+	struct layer *mux;
+	uint8 last_phyid;
+	struct cfcnfg_phyinfo phy_layers[MAX_PHY_LAYERS];
+};
+
+static void cncfg_linkup_rsp(struct layer *layer, uint8 linkid,
+			     enum cfctrl_srv serv, uint8 phyid,
+			     struct layer *adapt_layer);
+static void cncfg_linkdestroy_rsp(struct layer *layer, uint8 linkid,
+				  struct layer *client_layer);
+static void cncfg_reject_rsp(struct layer *layer, uint8 linkid,
+			     struct layer *adapt_layer);
+static void cfctrl_resp_func(void);
+static void cfctrl_enum_resp(void);
+
+struct cfcnfg *cfcnfg_create()
+{
+	struct cfcnfg *this;
+	struct cfctrl_rsp *resp;
+	/* Initiate this layer */
+	this = cfglu_alloc(sizeof(struct cfcnfg));
+	if (!this) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return NULL;
+	}
+	memset(this, 0, sizeof(struct cfcnfg));
+	this->mux = cfmuxl_create();
+	if (!this->mux)
+		goto out_of_mem;
+	this->ctrl = cfctrl_create();
+	if (!this->ctrl)
+		goto out_of_mem;
+	/* Initiate response functions */
+	resp = cfctrl_get_respfuncs(this->ctrl);
+	resp->enum_rsp = cfctrl_enum_resp;
+	resp->linkerror_ind = cfctrl_resp_func;
+	resp->linkdestroy_rsp = cncfg_linkdestroy_rsp;
+	resp->sleep_rsp = cfctrl_resp_func;
+	resp->wake_rsp = cfctrl_resp_func;
+	resp->restart_rsp = cfctrl_resp_func;
+	resp->radioset_rsp = cfctrl_resp_func;
+	resp->linksetup_rsp = cncfg_linkup_rsp;
+	resp->reject_rsp = cncfg_reject_rsp;
+
+	this->last_phyid = 1;
+
+	cfmuxl_set_uplayer(this->mux, this->ctrl, 0);
+	layer_set_dn(this->ctrl, this->mux);
+	layer_set_up(this->ctrl, this);
+	return this;
+out_of_mem:
+	pr_warning("CAIF: %s(): Out of memory\n", __func__);
+	cfglu_free(this->mux);
+	cfglu_free(this->ctrl);
+	cfglu_free(this);
+	return NULL;
+}
+EXPORT_SYMBOL(cfcnfg_create);
+
+void cfcnfg_remove(struct cfcnfg *cfg)
+{
+	if (cfg) {
+		cfglu_free(cfg->mux);
+		cfglu_free(cfg->ctrl);
+		cfglu_free(cfg);
+	}
+}
+
+static void cfctrl_resp_func(void)
+{
+}
+
+static void cfctrl_enum_resp(void)
+{
+}
+
+struct dev_info *cfcnfg_get_phyid(struct cfcnfg *cnfg,
+				  enum cfcnfg_phy_preference phy_pref)
+{
+	int i;
+
+	/* Try to match with specified preference */
+	for (i = 1; i < MAX_PHY_LAYERS; i++) {
+		if (cnfg->phy_layers[i].id == i &&
+		     cnfg->phy_layers[i].pref == phy_pref &&
+		     cnfg->phy_layers[i].frm_layer != NULL) {
+			caif_assert(cnfg->phy_layers != NULL);
+			caif_assert(cnfg->phy_layers[i].id == i);
+			return &cnfg->phy_layers[i].dev_info;
+		}
+	}
+	/* Otherwise just return something */
+	for (i = 1; i < MAX_PHY_LAYERS; i++) {
+		if (cnfg->phy_layers[i].id == i) {
+			caif_assert(cnfg->phy_layers != NULL);
+			caif_assert(cnfg->phy_layers[i].id == i);
+			return &cnfg->phy_layers[i].dev_info;
+		}
+	}
+
+	return NULL;
+}
+
+static struct cfcnfg_phyinfo *cfcnfg_get_phyinfo(struct cfcnfg *cnfg,
+							uint8 phyid)
+{
+	int i;
+
+	/* Try to match with specified preference */
+	for (i = 0; i < MAX_PHY_LAYERS; i++)
+		if (cnfg->phy_layers[i].frm_layer != NULL &&
+		    cnfg->phy_layers[i].id == phyid)
+			return &cnfg->phy_layers[i];
+	return 0;
+}
+
+int cfcnfg_get_named(struct cfcnfg *cnfg, char *name)
+{
+	int i;
+
+	/* Try to match with specified preference */
+	for (i = 0; i < MAX_PHY_LAYERS; i++) {
+		if (cnfg->phy_layers[i].frm_layer != NULL
+		    && strcmp(cnfg->phy_layers[i].frm_layer->name,
+			      name) == 0) {
+			return cnfg->phy_layers[i].frm_layer->id;
+		}
+	}
+	return 0;
+}
+
+/*
+ * NOTE: What happens on destroy failure:
+ *	 1a) No response - Too early
+ *	      This will not happen because enumerate has already
+ *	      completed.
+ *	 1b) No response - FATAL
+ *	      Not handled, but this should be a CAIF PROTOCOL ERROR
+ *	      Modem error, response is really expected -  this
+ *	      case is not really handled.
+ *	 2) O/E-bit indicate error
+ *	      Ignored - this link is destroyed anyway.
+ *	 3) Not able to match on request
+ *	      Not handled, but this should be a CAIF PROTOCOL ERROR
+ *	 4) Link-Error - (no response)
+ *	      Not handled, but this should be a CAIF PROTOCOL ERROR
+ */
+
+int cfcnfg_del_adapt_layer(struct cfcnfg *cnfg, struct layer *adap_layer)
+{
+	uint8 channel_id = 0;
+	int ret = 0;
+	struct cfcnfg_phyinfo *phyinfo = NULL;
+	uint8 phyid = 0;
+
+	caif_assert(adap_layer != NULL);
+	channel_id = adap_layer->id;
+	if (channel_id == 0) {
+		pr_err("CAIF: %s():adap_layer->id is 0\n", __func__);
+		ret = CFGLU_ENOTCONN;
+		goto end;
+	}
+
+	if (adap_layer->dn == NULL) {
+		pr_err("CAIF: %s():adap_layer->dn is NULL\n", __func__);
+		ret = CFGLU_ENODEV;
+		goto end;
+	}
+
+	if (adap_layer->dn != NULL)
+		phyid = cfsrvl_getphyid(adap_layer->dn);
+
+	phyinfo = cfcnfg_get_phyinfo(cnfg, phyid);
+	if (phyinfo == NULL) {
+		pr_warning("CAIF: %s(): No interface to send disconnect to\n",
+			   __func__);
+		ret = CFGLU_ENODEV;
+		goto end;
+	}
+
+	if (phyinfo->id != phyid
+		|| phyinfo->phy_layer->id != phyid
+		|| phyinfo->frm_layer->id != phyid) {
+
+		pr_err("CAIF: %s(): Inconsistency in phy registration\n",
+			__func__);
+		ret = CFGLU_EINVAL;
+		goto end;
+	}
+
+	ret = cfctrl_linkdown_req(cnfg->ctrl, channel_id, adap_layer);
+
+end:
+	if (phyinfo != NULL && --phyinfo->phy_ref_count == 0 &&
+		phyinfo->phy_layer != NULL &&
+		phyinfo->phy_layer->modemcmd != NULL) {
+		phyinfo->phy_layer->modemcmd(phyinfo->phy_layer,
+					     _CAIF_MODEMCMD_PHYIF_USELESS);
+	}
+	return ret;
+
+}
+EXPORT_SYMBOL(cfcnfg_del_adapt_layer);
+
+static void cncfg_linkdestroy_rsp(struct layer *layer, uint8 linkid,
+				  struct layer *client_layer)
+{
+	struct cfcnfg *cnfg = container_obj(layer);
+	struct layer *servl;
+
+	/*
+	 * 1) Remove service from the MUX layer. The MUX must
+	 *    guarante that no more payload sent "upwards" (receive)
+	 */
+	servl = cfmuxl_remove_uplayer(cnfg->mux, linkid);
+
+	if (servl == NULL) {
+		pr_err("CAIF: %s(): PROTOCOL ERROR "
+		       "- Error removing service_layer Linkid(%d)",
+			__func__, linkid);
+		return;
+	}
+	caif_assert(linkid == servl->id);
+
+	if (servl != client_layer && servl->up != client_layer) {
+		pr_err("CAIF: %s(): Error removing service_layer "
+		       "Linkid(%d) %p %p",
+			__func__, linkid, (void *) servl,
+			(void *) client_layer);
+		return;
+	}
+
+	/*
+	 * 2) DEINIT_RSP must guarantee that no more packets are transmitted
+	 *    from client (adap_layer) when it returns.
+	 */
+
+	if (servl->ctrlcmd == NULL) {
+		pr_err("CAIF: %s(): Error servl->ctrlcmd == NULL", __func__);
+		return;
+	}
+
+	servl->ctrlcmd(servl, CAIF_CTRLCMD_DEINIT_RSP, 0);
+
+	/* 3) It is now safe to destroy the service layer. */
+
+	if (client_layer != servl->up)
+		cfservl_destroy(servl);
+}
+
+/*
+ * NOTE: What happens on linksetup failure:
+ *	 1a) No response - Too early
+ *	      This will not happen because enumerate is secured
+ *	      before using interface.
+ *	 1b) No response - FATAL
+ *	      Not handled, but this should be a CAIF PROTOCOL ERROR
+ *	      Modem error, response is really expected -  this case is
+ *	      not really handled.
+ *	 2) O/E-bit indicate error
+ *	      Handled in cnfg_reject_rsp
+ *	 3) Not able to match on request
+ *	      Not handled, but this should be a CAIF PROTOCOL ERROR
+ *	 4) Link-Error - (no response)
+ *	      Not handled, but this should be a CAIF PROTOCOL ERROR
+ */
+
+bool
+cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
+				struct cfctrl_link_param *param,
+				struct layer *adap_layer)
+{
+	struct layer *frml;
+	if (adap_layer == NULL) {
+		pr_err("CAIF: %s(): adap_layer is zero", __func__);
+		return CFGLU_EINVAL;
+	}
+	if (adap_layer->receive == NULL) {
+		pr_err("CAIF: %s(): adap_layer->receive is NULL", __func__);
+		return CFGLU_EINVAL;
+	}
+	if (adap_layer->ctrlcmd == NULL) {
+		pr_err("CAIF: %s(): adap_layer->ctrlcmd == NULL", __func__);
+		return CFGLU_EINVAL;
+	}
+	frml = cnfg->phy_layers[param->phyid].frm_layer;
+	if (frml == NULL) {
+		pr_err("CAIF: %s(): Specified PHY type does not exist!",
+			__func__);
+		return CFGLU_ENODEV;
+	}
+	caif_assert(param->phyid == cnfg->phy_layers[param->phyid].id);
+	caif_assert(cnfg->phy_layers[param->phyid].frm_layer->id ==
+		     param->phyid);
+	caif_assert(cnfg->phy_layers[param->phyid].phy_layer->id ==
+		     param->phyid);
+	/* FIXME: ENUMERATE INITIALLY WHEN ACTIVATING PHYSICAL INTERFACE */
+	cfctrl_enum_req(cnfg->ctrl, param->phyid);
+	cfctrl_linkup_request(cnfg->ctrl, param, adap_layer);
+	return 0;
+}
+EXPORT_SYMBOL(cfcnfg_add_adaptation_layer);
+
+static void cncfg_reject_rsp(struct layer *layer, uint8 linkid,
+			     struct layer *adapt_layer)
+{
+	if (adapt_layer != NULL && adapt_layer->ctrlcmd != NULL)
+		adapt_layer->ctrlcmd(adapt_layer,
+				     CAIF_CTRLCMD_INIT_FAIL_RSP, 0);
+}
+
+static void
+cncfg_linkup_rsp(struct layer *layer, uint8 linkid, enum cfctrl_srv serv,
+		 uint8 phyid, struct layer *adapt_layer)
+{
+	struct cfcnfg *cnfg = container_obj(layer);
+	struct layer *servicel = NULL;
+	struct cfcnfg_phyinfo *phyinfo;
+	if (adapt_layer == NULL) {
+		pr_err("CAIF: %s(): PROTOCOL ERROR "
+			"- LinkUp Request/Response did not match\n", __func__);
+		return;
+	}
+
+	caif_assert(cnfg != NULL);
+	caif_assert(phyid != 0);
+	phyinfo = &cnfg->phy_layers[phyid];
+	caif_assert(phyinfo != NULL);
+	caif_assert(phyinfo->id == phyid);
+	caif_assert(phyinfo->phy_layer != NULL);
+	caif_assert(phyinfo->phy_layer->id == phyid);
+
+	if (phyinfo != NULL &&
+	    phyinfo->phy_ref_count++ == 0 &&
+	    phyinfo->phy_layer != NULL &&
+	    phyinfo->phy_layer->modemcmd != NULL) {
+		caif_assert(phyinfo->phy_layer->id == phyid);
+		phyinfo->phy_layer->modemcmd(phyinfo->phy_layer,
+					     _CAIF_MODEMCMD_PHYIF_USEFULL);
+
+	}
+	adapt_layer->id = linkid;
+
+	switch (serv) {
+	case CFCTRL_SRV_VEI:
+		servicel = cfvei_create(linkid, &phyinfo->dev_info);
+		break;
+	case CFCTRL_SRV_DATAGRAM:
+		servicel = cfdgml_create(linkid, &phyinfo->dev_info);
+		break;
+	case CFCTRL_SRV_RFM:
+		servicel = cfrfml_create(linkid, &phyinfo->dev_info);
+		break;
+	case CFCTRL_SRV_UTIL:
+		servicel = cfutill_create(linkid, &phyinfo->dev_info);
+		break;
+	case CFCTRL_SRV_VIDEO:
+		servicel = cfvidl_create(linkid, &phyinfo->dev_info);
+		break;
+	case CFCTRL_SRV_DBG:
+		servicel = adapt_layer;
+		break;
+	default:
+		pr_err("CAIF: %s(): Protocol error. "
+			"Link setup response - unknown channel type\n",
+			__func__);
+		return;
+	}
+	if (!servicel) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return;
+	}
+	layer_set_dn(servicel, cnfg->mux);
+
+
+	cfmuxl_set_uplayer(cnfg->mux, servicel, linkid);
+	if (servicel != adapt_layer) {
+		layer_set_up(servicel, adapt_layer);
+		layer_set_dn(adapt_layer, servicel);
+	}
+	servicel->ctrlcmd(servicel, CAIF_CTRLCMD_INIT_RSP, 0);
+}
+
+void
+cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
+		     void *dev, struct layer *phy_layer, uint16 *phyid,
+		     enum cfcnfg_phy_preference pref,
+		     bool fcs, bool stx)
+{
+	struct layer *frml;
+	struct layer *phy_driver = NULL;
+	int i;
+
+
+	if (cnfg->phy_layers[cnfg->last_phyid].frm_layer == NULL) {
+		*phyid = cnfg->last_phyid;
+
+		/* range: * 1..(MAX_PHY_LAYERS-1) */
+		cnfg->last_phyid =
+		    (cnfg->last_phyid % (MAX_PHY_LAYERS - 1)) + 1;
+	} else {
+		*phyid = 0;
+		for (i = 1; i < MAX_PHY_LAYERS; i++) {
+			if (cnfg->phy_layers[i].frm_layer == NULL) {
+				*phyid = i;
+				break;
+			}
+		}
+	}
+	if (*phyid == 0) {
+		pr_err("CAIF: %s(): No Available PHY ID\n", __func__);
+		return;
+	}
+
+	switch (phy_type) {
+	case CFPHYTYPE_FRAG:
+		fcs = true;
+		phy_driver =
+		    cfserl_create(CFPHYTYPE_FRAG, *phyid, stx);
+		if (!phy_driver) {
+			pr_warning("CAIF: %s(): Out of memory\n", __func__);
+			return;
+		}
+
+		break;
+	case CFPHYTYPE_CAIF:
+		phy_driver = NULL;
+		break;
+	default:
+		pr_err("CAIF: %s(): %d", __func__, phy_type);
+		return;
+		break;
+	}
+
+	phy_layer->id = *phyid;
+	cnfg->phy_layers[*phyid].pref = pref;
+	cnfg->phy_layers[*phyid].id = *phyid;
+	cnfg->phy_layers[*phyid].dev_info.id = *phyid;
+	cnfg->phy_layers[*phyid].dev_info.dev = dev;
+	cnfg->phy_layers[*phyid].phy_layer = phy_layer;
+	cnfg->phy_layers[*phyid].phy_ref_count = 0;
+	phy_layer->type = phy_type;
+	frml = cffrml_create(*phyid, fcs);
+	if (!frml) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return;
+	}
+	cnfg->phy_layers[*phyid].frm_layer = frml;
+	cfmuxl_set_dnlayer(cnfg->mux, frml, *phyid);
+	layer_set_up(frml, cnfg->mux);
+
+	if (phy_driver != NULL) {
+		phy_driver->id = *phyid;
+		layer_set_dn(frml, phy_driver);
+		layer_set_up(phy_driver, frml);
+		layer_set_dn(phy_driver, phy_layer);
+		layer_set_up(phy_layer, phy_driver);
+	} else {
+		layer_set_dn(frml, phy_layer);
+		layer_set_up(phy_layer, frml);
+	}
+}
+EXPORT_SYMBOL(cfcnfg_add_phy_layer);
+
+int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, struct layer *phy_layer)
+{
+	struct layer *frml, *frml_dn;
+	uint16 phyid;
+	phyid = phy_layer->id;
+	caif_assert(phyid == cnfg->phy_layers[phyid].id);
+	caif_assert(phy_layer == cnfg->phy_layers[phyid].phy_layer);
+	caif_assert(phy_layer->id == phyid);
+	caif_assert(cnfg->phy_layers[phyid].frm_layer->id == phyid);
+
+	memset(&cnfg->phy_layers[phy_layer->id], 0,
+	       sizeof(struct cfcnfg_phyinfo));
+	frml = cfmuxl_remove_dnlayer(cnfg->mux, phy_layer->id);
+	frml_dn = frml->dn;
+	cffrml_set_uplayer(frml, NULL);
+	cffrml_set_dnlayer(frml, NULL);
+	cffrml_destroy(frml);
+
+	if (phy_layer != frml_dn) {
+		layer_set_up(frml_dn, NULL);
+		layer_set_dn(frml_dn, NULL);
+		cfglu_free(frml_dn);
+	}
+	layer_set_up(phy_layer, NULL);
+	return CFGLU_EOK;
+}
+EXPORT_SYMBOL(cfcnfg_del_phy_layer);
diff --git a/net/caif/generic/cflist.c b/net/caif/generic/cflist.c
new file mode 100644
index 0000000..05603bc
--- /dev/null
+++ b/net/caif/generic/cflist.c
@@ -0,0 +1,88 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cflst.h>
+
+void cflst_init(struct layer **lst)
+{
+	*lst = NULL;
+}
+
+struct layer *cflst_remove(struct layer **lst, struct layer *elem)
+{
+	struct layer *tmp;
+	if (*lst == NULL)
+		return NULL;
+
+	tmp = (*lst);
+	(*lst) = (*lst)->next;
+	return tmp;
+}
+
+/* Adds an element from the queue. */
+void cflst_insert(struct layer **lst, struct layer *node)
+{
+	struct layer *tmp;
+	node->next = NULL;
+	if ((*lst) == NULL) {
+		(*lst) = node;
+		return;
+	}
+	tmp = *lst;
+	while (tmp->next != NULL)
+		tmp = tmp->next;
+	tmp->next = node;
+}
+
+int cflst_put(struct layer **lst, uint8 id, struct layer *node)
+{
+	if (cflst_get(lst, id) != NULL) {
+		pr_err("CAIF: %s(): cflst_put duplicate key\n", __func__);
+		return CFGLU_EINVAL;
+	}
+	node->id = id;
+	cflst_insert(lst, node);
+	return CFGLU_EOK;
+}
+
+struct layer *cflst_get(struct layer * *lst, uint8 id)
+{
+	struct layer *node;
+	for (node = (*lst); node != NULL; node = node->next) {
+		if (id == node->id)
+			return node;
+	}
+	return NULL;
+}
+
+struct layer *cflst_del(struct layer * *lst, uint8 id)
+{
+	struct layer *iter;
+	struct layer *node = NULL;
+
+	if ((*lst) == NULL)
+		return NULL;
+
+	if ((*lst)->id == id) {
+		node = (*lst);
+		(*lst) = (*lst)->next;
+		node->next = NULL;
+
+		return node;
+	}
+
+	for (iter = (*lst); iter->next != NULL; iter = iter->next) {
+		if (id == iter->next->id) {
+			node = iter->next;
+			iter->next = iter->next->next;
+			node->next = NULL;
+			return node;
+		}
+	}
+	return NULL;
+}
diff --git a/net/caif/generic/cfpkt_skbuff.c b/net/caif/generic/cfpkt_skbuff.c
new file mode 100644
index 0000000..1bf0b5e
--- /dev/null
+++ b/net/caif/generic/cfpkt_skbuff.c
@@ -0,0 +1,596 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <linux/hardirq.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfpkt.h>
+
+#define PKT_PREFIX CAIF_NEEDED_HEADROOM
+#define PKT_POSTFIX CAIF_NEEDED_TAILROOM
+#define PKT_LEN_WHEN_EXTENDING 128
+#define PKT_ERROR(pkt, errmsg) do {	   \
+    cfpkt_priv(pkt)->erronous = true;	   \
+    skb_reset_tail_pointer(&pkt->skb);	   \
+    pr_warning("CAIF: " errmsg);\
+  } while (0)
+
+struct cfpktq {
+	struct sk_buff_head head;
+	cfglu_atomic_t count;
+	spinlock_t lock;
+};
+
+/*
+ * net/caif/generic/ is generic and does not
+ * understand SKB, so we do this typecast
+ */
+struct cfpkt {
+	struct sk_buff skb;
+};
+
+/* Private data inside SKB */
+struct cfpkt_priv_data {
+	struct dev_info dev_info;
+	bool erronous;
+};
+
+inline struct cfpkt_priv_data *cfpkt_priv(struct cfpkt *pkt)
+{
+	return (struct cfpkt_priv_data *) pkt->skb.cb;
+}
+
+inline bool is_erronous(struct cfpkt *pkt)
+{
+	return cfpkt_priv(pkt)->erronous;
+}
+
+inline struct sk_buff *pkt_to_skb(struct cfpkt *pkt)
+{
+	return &pkt->skb;
+}
+
+inline struct cfpkt *skb_to_pkt(struct sk_buff *skb)
+{
+	return (struct cfpkt *) skb;
+}
+
+cfglu_atomic_t cfpkt_packet_count;
+EXPORT_SYMBOL(cfpkt_packet_count);
+
+struct cfpkt *cfpkt_fromnative(enum caif_direction dir, void *nativepkt)
+{
+	struct cfpkt *pkt = skb_to_pkt(nativepkt);
+	cfpkt_priv(pkt)->erronous = false;
+	cfglu_atomic_inc(cfpkt_packet_count);
+	return pkt;
+}
+EXPORT_SYMBOL(cfpkt_fromnative);
+
+void *cfpkt_tonative(struct cfpkt *pkt)
+{
+	return (void *) pkt;
+}
+EXPORT_SYMBOL(cfpkt_tonative);
+
+struct cfpkt *cfpkt_create_pfx(uint16 len, uint16 pfx)
+{
+	struct sk_buff *skb;
+
+	if (likely(in_interrupt()))
+		skb = alloc_skb(len + pfx, GFP_ATOMIC);
+	else
+		skb = alloc_skb(len + pfx, GFP_KERNEL);
+
+	if (unlikely(skb == NULL))
+		return NULL;
+
+	skb_reserve(skb, pfx);
+	cfglu_atomic_inc(cfpkt_packet_count);
+	return skb_to_pkt(skb);
+}
+
+inline struct cfpkt *cfpkt_create(uint16 len)
+{
+	return cfpkt_create_pfx(len + PKT_POSTFIX, PKT_PREFIX);
+}
+EXPORT_SYMBOL(cfpkt_create);
+
+void cfpkt_destroy(struct cfpkt *pkt)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	cfglu_atomic_dec(cfpkt_packet_count);
+	caif_assert(cfglu_atomic_read(cfpkt_packet_count) >= 0);
+	kfree_skb(skb);
+}
+EXPORT_SYMBOL(cfpkt_destroy);
+
+inline bool cfpkt_more(struct cfpkt *pkt)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	return skb->len > 0;
+}
+EXPORT_SYMBOL(cfpkt_more);
+
+int cfpkt_peek_head(struct cfpkt *pkt, void *data, uint16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	if (skb->tail - skb->data >= len) {
+		memcpy(data, skb->data, len);
+		return CFGLU_EOK;
+	}
+	return !cfpkt_extr_head(pkt, data, len) &&
+	    !cfpkt_add_head(pkt, data, len);
+}
+EXPORT_SYMBOL(cfpkt_peek_head);
+
+int cfpkt_extr_head(struct cfpkt *pkt, void *data, uint16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	uint8 *from;
+	if (unlikely(is_erronous(pkt)))
+		return CFGLU_EPKT;
+
+	if (unlikely(len > skb->len)) {
+		PKT_ERROR(pkt, "cfpkt_extr_head read beyond end of packet\n");
+		return CFGLU_EPKT;
+	}
+
+	if (unlikely(len > skb_headlen(skb))) {
+		if (unlikely(skb_linearize(skb) != 0)) {
+			PKT_ERROR(pkt, "cfpkt_extr_head linearize failed\n");
+			return CFGLU_EPKT;
+		}
+	}
+	from = skb_pull(skb, len);
+	from -= len;
+	memcpy(data, from, len);
+	return CFGLU_EOK;
+}
+EXPORT_SYMBOL(cfpkt_extr_head);
+
+int cfpkt_extr_trail(struct cfpkt *pkt, void *dta, uint16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	uint8 *data = dta;
+	uint8 *from;
+	if (unlikely(is_erronous(pkt)))
+		return CFGLU_EPKT;
+
+	if (unlikely(skb_linearize(skb) != 0)) {
+		PKT_ERROR(pkt, "cfpkt_extr_trail linearize failed\n");
+		return CFGLU_EPKT;
+	}
+	if (unlikely(skb->data + len > skb_tail_pointer(skb))) {
+		PKT_ERROR(pkt, "cfpkt_extr_trail read beyond end of packet\n");
+		return CFGLU_EPKT;
+	}
+	from = skb_tail_pointer(skb) - len;
+	skb_trim(skb, skb->len - len);
+	memcpy(data, from, len);
+	return CFGLU_EOK;
+}
+EXPORT_SYMBOL(cfpkt_extr_trail);
+
+int cfpkt_pad_trail(struct cfpkt *pkt, uint16 len)
+{
+	return cfpkt_add_body(pkt, NULL, len);
+}
+EXPORT_SYMBOL(cfpkt_pad_trail);
+
+int cfpkt_add_body(struct cfpkt *pkt, const void *data, uint16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	struct sk_buff *lastskb;
+	uint8 *to;
+	uint16 addlen = 0;
+
+
+	if (unlikely(is_erronous(pkt)))
+		return CFGLU_EPKT;
+
+	lastskb = skb;
+
+	/* Check whether we need to add space at the tail */
+	if (unlikely(skb_tailroom(skb) < len)) {
+		if (likely(len < PKT_LEN_WHEN_EXTENDING))
+			addlen = PKT_LEN_WHEN_EXTENDING;
+		else
+			addlen = len;
+	}
+
+	/* Check whether we need to change the SKB before writing to the tail */
+	if (unlikely((addlen > 0) || skb_cloned(skb) || skb_shared(skb))) {
+
+		/* Make sure data is writable */
+		if (unlikely(skb_cow_data(skb, addlen, &lastskb) < 0)) {
+			PKT_ERROR(pkt, "cfpkt_add_body: cow failed\n");
+			return CFGLU_EPKT;
+		}
+		/*
+		 * Is the SKB non-linear after skb_cow_data()? If so, we are
+		 * going to add data to the last SKB, so we need to adjust
+		 * lengths of the top SKB.
+		 */
+		if (lastskb != skb) {
+			pr_warning("CAIF: %s(): Packet is non-linear\n",
+				   __func__);
+			skb->len += len;
+			skb->data_len += len;
+		}
+	}
+
+	/* All set to put the last SKB and optionally write data there. */
+	to = skb_put(lastskb, len);
+	if (likely(data))
+		memcpy(to, data, len);
+	return CFGLU_EOK;
+}
+EXPORT_SYMBOL(cfpkt_add_body);
+
+inline int cfpkt_addbdy(struct cfpkt *pkt, uint8 data)
+{
+	return cfpkt_add_body(pkt, &data, 1);
+}
+EXPORT_SYMBOL(cfpkt_addbdy);
+
+int cfpkt_add_head(struct cfpkt *pkt, const void *data2, uint16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	struct sk_buff *lastskb;
+	uint8 *to;
+	const uint8 *data = data2;
+	if (unlikely(is_erronous(pkt)))
+		return CFGLU_EPKT;
+	if (unlikely(skb_headroom(skb) < len)) {
+		PKT_ERROR(pkt, "cfpkt_add_head: no headroom\n");
+		return CFGLU_EPKT;
+	}
+
+	/* Make sure data is writable */
+	if (unlikely(skb_cow_data(skb, 0, &lastskb) < 0)) {
+		PKT_ERROR(pkt, "cfpkt_add_head: cow failed\n");
+		return CFGLU_EPKT;
+	}
+
+	to = skb_push(skb, len);
+	memcpy(to, data, len);
+	return CFGLU_EOK;
+}
+EXPORT_SYMBOL(cfpkt_add_head);
+
+inline int cfpkt_add_trail(struct cfpkt *pkt, const void *data, uint16 len)
+{
+	return cfpkt_add_body(pkt, data, len);
+}
+EXPORT_SYMBOL(cfpkt_add_trail);
+
+inline uint16 cfpkt_getlen(struct cfpkt *pkt)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	return skb->len;
+}
+EXPORT_SYMBOL(cfpkt_getlen);
+
+inline uint16 cfpkt_iterate(struct cfpkt *pkt,
+			    uint16 (*iter_func)(uint16, void *, uint16),
+			    uint16 data)
+{
+	/*
+	 * Don't care about the performance hit of linearizing,
+	 * Checksum should not be used on high-speed interfaces anyway.
+	 */
+	if (unlikely(is_erronous(pkt)))
+		return CFGLU_EPKT;
+	if (unlikely(skb_linearize(&pkt->skb) != 0)) {
+		PKT_ERROR(pkt, "cfpkt_iterate: linearize failed\n");
+		return CFGLU_EPKT;
+	}
+	return iter_func(data, pkt->skb.data, cfpkt_getlen(pkt));
+}
+EXPORT_SYMBOL(cfpkt_iterate);
+
+int cfpkt_setlen(struct cfpkt *pkt, uint16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+
+
+	if (unlikely(is_erronous(pkt)))
+		return CFGLU_EPKT;
+
+	if (likely(len <= skb->len)) {
+		if (unlikely(skb->data_len))
+			___pskb_trim(skb, len);
+		else
+			skb_trim(skb, len);
+
+			return cfpkt_getlen(pkt);
+	}
+
+	/* Need to expand SKB */
+	if (unlikely(!cfpkt_pad_trail(pkt, len - skb->len)))
+		PKT_ERROR(pkt, "cfpkt_setlen: skb_pad_trail failed\n");
+
+	return cfpkt_getlen(pkt);
+}
+EXPORT_SYMBOL(cfpkt_setlen);
+
+struct cfpkt *cfpkt_create_uplink(const unsigned char *data, unsigned int len)
+{
+	struct cfpkt *pkt = cfpkt_create_pfx(len + PKT_POSTFIX, PKT_PREFIX);
+	if (unlikely(data != NULL))
+		cfpkt_add_body(pkt, data, len);
+	return pkt;
+}
+EXPORT_SYMBOL(cfpkt_create_uplink);
+
+
+struct cfpkt *cfpkt_append(struct cfpkt *dstpkt,
+			     struct cfpkt *addpkt,
+			     uint16 expectlen)
+{
+	struct sk_buff *dst = pkt_to_skb(dstpkt);
+	struct sk_buff *add = pkt_to_skb(addpkt);
+	uint16 addlen = add->tail - add->data;
+	uint16 neededtailspace;
+	struct sk_buff *tmp;
+	uint16 dstlen;
+	uint16 createlen;
+	if (unlikely(is_erronous(dstpkt) || is_erronous(addpkt))) {
+		cfpkt_destroy(addpkt);
+		return dstpkt;
+	}
+	if (expectlen > addlen)
+		neededtailspace = expectlen;
+	else
+		neededtailspace = addlen;
+
+	if (dst->tail + neededtailspace > dst->end) {
+		/* Create a dumplicate of 'dst' with more tail space */
+		dstlen = dst->tail - dst->data;
+		createlen = dstlen + neededtailspace;
+		tmp = pkt_to_skb(
+			cfpkt_create(createlen + PKT_PREFIX + PKT_POSTFIX));
+		if (!tmp)
+			return NULL;
+		tmp->tail = tmp->data + dstlen;
+		tmp->len = dstlen;
+		memcpy(tmp->data, dst->data, dstlen);
+		cfpkt_destroy(dstpkt);
+		dst = tmp;
+	}
+	memcpy(dst->tail, add->data, add->tail - add->data);
+	cfpkt_destroy(addpkt);
+	dst->tail += addlen;
+	dst->len += addlen;
+	return skb_to_pkt(dst);
+}
+EXPORT_SYMBOL(cfpkt_append);
+
+struct cfpkt *cfpkt_split(struct cfpkt *pkt, uint16 pos)
+{
+	struct sk_buff *skb2;
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	uint8 *split = skb->data + pos;
+	uint16 len2nd = skb->tail - split;
+
+	if (unlikely(is_erronous(pkt)))
+		return NULL;
+
+	if (skb->data + pos > skb->tail) {
+		PKT_ERROR(pkt,
+			  "cfpkt_split: trying to split beyond end of packet");
+		return NULL;
+	}
+
+	/* Create a new packet for the second part of the data */
+	skb2 = pkt_to_skb(
+		cfpkt_create_pfx(len2nd + PKT_PREFIX + PKT_POSTFIX,
+				 PKT_PREFIX));
+
+	if (skb2 == NULL)
+		return NULL;
+
+	/* Reduce the length of the original packet */
+	skb->tail = split;
+	skb->len = pos;
+
+	memcpy(skb2->data, split, len2nd);
+	skb2->tail += len2nd;
+	skb2->len += len2nd;
+	return skb_to_pkt(skb2);
+}
+EXPORT_SYMBOL(cfpkt_split);
+
+
+char *cfpkt_log_pkt(struct cfpkt *pkt, char *buf, int buflen)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	char *p = buf;
+	int i;
+
+	/*
+	 * Sanity check buffer length, it needs to be at least as large as
+	 * the header info: ~=50+ bytes
+	 */
+	if (buflen < 50)
+		return NULL;
+
+	snprintf(buf, buflen, "%s: pkt:%p len:%d(%d+%d) {%d,%d} data: [",
+		is_erronous(pkt) ? "ERRONOUS-SKB" :
+		 (skb->data_len != 0 ? "COMPLEX-SKB" : "SKB"),
+		skb,
+		skb->len,
+		skb->tail - skb->data,
+		skb->data_len,
+		skb->data - skb->head, skb->tail - skb->head);
+	p = buf + strlen(buf);
+
+	for (i = 0; i < skb->tail - skb->data && i < 300; i++) {
+		if (p > buf + buflen - 10) {
+			sprintf(p, "...");
+			p = buf + strlen(buf);
+			break;
+		}
+		sprintf(p, "%02x,", skb->data[i]);
+		p = buf + strlen(buf);
+	}
+	sprintf(p, "]\n");
+	return buf;
+}
+EXPORT_SYMBOL(cfpkt_log_pkt);
+
+int cfpkt_raw_append(struct cfpkt *pkt, void **buf, unsigned int buflen)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	struct sk_buff *lastskb;
+
+	caif_assert(buf != NULL);
+	if (unlikely(is_erronous(pkt)))
+		return CFGLU_EPKT;
+	/* Make sure SKB is writable */
+	if (unlikely(skb_cow_data(skb, 0, &lastskb) < 0)) {
+		PKT_ERROR(pkt, "cfpkt_raw_append: skb_cow_data failed\n");
+		return CFGLU_EPKT;
+	}
+
+	if (unlikely(skb_linearize(skb) != 0)) {
+		PKT_ERROR(pkt, "cfpkt_raw_append: linearize failed\n");
+		return CFGLU_EPKT;
+	}
+
+	if (unlikely(skb_tailroom(skb) < buflen)) {
+		PKT_ERROR(pkt, "cfpkt_raw_append: buffer too short - failed\n");
+		return CFGLU_EPKT;
+	}
+
+	*buf = skb_put(skb, buflen);
+	return 1;
+}
+EXPORT_SYMBOL(cfpkt_raw_append);
+
+int cfpkt_raw_extract(struct cfpkt *pkt, void **buf, unsigned int buflen)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+
+	caif_assert(buf != NULL);
+	if (unlikely(is_erronous(pkt)))
+		return CFGLU_EPKT;
+
+	if (unlikely(buflen > skb->len)) {
+		PKT_ERROR(pkt, "cfpkt_raw_extract: buflen too large "
+				"- failed\n");
+		return CFGLU_EPKT;
+	}
+
+	if (unlikely(buflen > skb_headlen(skb))) {
+		if (unlikely(skb_linearize(skb) != 0)) {
+			PKT_ERROR(pkt, "cfpkt_raw_extract: linearize failed\n");
+			return CFGLU_EPKT;
+		}
+	}
+
+	*buf = skb->data;
+	skb_pull(skb, buflen);
+
+	return 1;
+}
+EXPORT_SYMBOL(cfpkt_raw_extract);
+
+inline bool cfpkt_erroneous(struct cfpkt *pkt)
+{
+	return cfpkt_priv(pkt)->erronous;
+}
+EXPORT_SYMBOL(cfpkt_erroneous);
+
+struct cfpkt *cfpkt_create_pkt(enum caif_direction dir,
+			  const unsigned char *data, unsigned int len)
+{
+	struct cfpkt *pkt;
+	if (dir == CAIF_DIR_OUT)
+		pkt = cfpkt_create_pfx(len + PKT_POSTFIX, PKT_PREFIX);
+	else
+		pkt = cfpkt_create_pfx(len, 0);
+	if (unlikely(!pkt))
+		return NULL;
+	if (unlikely(data))
+		cfpkt_add_body(pkt, data, len);
+	cfpkt_priv(pkt)->erronous = false;
+	return pkt;
+}
+EXPORT_SYMBOL(cfpkt_create_pkt);
+
+struct cfpktq *cfpktq_create()
+{
+	struct cfpktq *q = cfglu_alloc(sizeof(struct cfpktq));
+	if (!q)
+		return NULL;
+	skb_queue_head_init(&q->head);
+	cfglu_atomic_set(q->count, 0);
+	spin_lock_init(&q->lock);
+	return q;
+}
+EXPORT_SYMBOL(cfpktq_create);
+
+void cfpkt_queue(struct cfpktq *pktq, struct cfpkt *pkt, unsigned short prio)
+{
+	cfglu_atomic_inc(pktq->count);
+	spin_lock(&pktq->lock);
+	skb_queue_tail(&pktq->head, pkt_to_skb(pkt));
+	spin_unlock(&pktq->lock);
+
+}
+EXPORT_SYMBOL(cfpkt_queue);
+
+struct cfpkt *cfpkt_qpeek(struct cfpktq *pktq)
+{
+	struct cfpkt *tmp;
+	spin_lock(&pktq->lock);
+	tmp = skb_to_pkt(skb_peek(&pktq->head));
+	spin_unlock(&pktq->lock);
+	return tmp;
+}
+EXPORT_SYMBOL(cfpkt_qpeek);
+
+struct cfpkt *cfpkt_dequeue(struct cfpktq *pktq)
+{
+	struct cfpkt *pkt;
+	spin_lock(&pktq->lock);
+	pkt = skb_to_pkt(skb_dequeue(&pktq->head));
+	if (pkt) {
+		cfglu_atomic_dec(pktq->count);
+		caif_assert(cfglu_atomic_read(pktq->count) >= 0);
+	}
+	spin_unlock(&pktq->lock);
+	return pkt;
+}
+EXPORT_SYMBOL(cfpkt_dequeue);
+
+int cfpkt_qcount(struct cfpktq *pktq)
+{
+	return cfglu_atomic_read(pktq->count);
+}
+EXPORT_SYMBOL(cfpkt_qcount);
+
+struct cfpkt *cfpkt_clone_release(struct cfpkt *pkt)
+{
+	struct cfpkt *clone;
+	clone  = skb_to_pkt(skb_clone(pkt_to_skb(pkt), GFP_ATOMIC));
+	/* Free original packet. */
+	cfpkt_destroy(pkt);
+	if (!clone)
+		return NULL;
+	cfglu_atomic_inc(cfpkt_packet_count);
+	return clone;
+}
+EXPORT_SYMBOL(cfpkt_clone_release);
+
+struct payload_info *cfpkt_info(struct cfpkt *pkt)
+{
+	return (struct payload_info *)&pkt_to_skb(pkt)->cb;
+}
+EXPORT_SYMBOL(cfpkt_info);
-- 
1.6.3.3

