From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v8 06/12] net-caif: add CAIF generic caif support
 functions
Date: Wed, 31 Mar 2010 01:56:24 +0200
Message-ID: <1269993390-23830-7-git-send-email-sjur.brandeland@stericsson.com>
References: <1269993390-23830-1-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-2-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-3-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-4-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-5-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-6-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: daniel.martensson@stericsson.com, sjurbr@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:63548 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757299Ab0C3X5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:57:08 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400CB4D6PAR20@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:49 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L04003KXD6FYY70@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:49 +0200 (CEST)
In-reply-to: <1269993390-23830-6-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Support functions for the caif protocol stack:
cfcnfg.c        - CAIF Configuration Module used for
                  adding and removing drivers and connection
cfpkt_skbuff.c  - CAIF Packet layer (SKB helper functions)

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfcnfg.c       |  529 +++++++++++++++++++++++++++++++++++++++++++
 net/caif/cfpkt_skbuff.c |  571 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 1100 insertions(+), 0 deletions(-)

diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
new file mode 100644
index 0000000..70a733d
--- /dev/null
+++ b/net/caif/cfcnfg.c
@@ -0,0 +1,529 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+#include <linux/kernel.h>
+#include <linux/stddef.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfpkt.h>
+#include <net/caif/cfcnfg.h>
+#include <net/caif/cfctrl.h>
+#include <net/caif/cfmuxl.h>
+#include <net/caif/cffrml.h>
+#include <net/caif/cfserl.h>
+#include <net/caif/cfsrvl.h>
+
+#include <linux/module.h>
+#include <asm/atomic.h>
+
+#define MAX_PHY_LAYERS 7
+#define PHY_NAME_LEN 20
+
+#define container_obj(layr) container_of(layr, struct cfcnfg, layer)
+
+/* Information about CAIF physical interfaces held by Config Module in order
+ * to manage physical interfaces
+ */
+struct cfcnfg_phyinfo {
+	/* Pointer to the layer below the MUX (framing layer) */
+	struct cflayer *frm_layer;
+	/* Pointer to the lowest actual physical layer */
+	struct cflayer *phy_layer;
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
+	struct cflayer layer;
+	struct cflayer *ctrl;
+	struct cflayer *mux;
+	u8 last_phyid;
+	struct cfcnfg_phyinfo phy_layers[MAX_PHY_LAYERS];
+};
+
+static void cncfg_linkup_rsp(struct cflayer *layer, u8 linkid,
+			     enum cfctrl_srv serv, u8 phyid,
+			     struct cflayer *adapt_layer);
+static void cncfg_linkdestroy_rsp(struct cflayer *layer, u8 linkid,
+				  struct cflayer *client_layer);
+static void cncfg_reject_rsp(struct cflayer *layer, u8 linkid,
+			     struct cflayer *adapt_layer);
+static void cfctrl_resp_func(void);
+static void cfctrl_enum_resp(void);
+
+struct cfcnfg *cfcnfg_create(void)
+{
+	struct cfcnfg *this;
+	struct cfctrl_rsp *resp;
+	/* Initiate this layer */
+	this = kmalloc(sizeof(struct cfcnfg), GFP_ATOMIC);
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
+	kfree(this->mux);
+	kfree(this->ctrl);
+	kfree(this);
+	return NULL;
+}
+EXPORT_SYMBOL(cfcnfg_create);
+
+void cfcnfg_remove(struct cfcnfg *cfg)
+{
+	if (cfg) {
+		kfree(cfg->mux);
+		kfree(cfg->ctrl);
+		kfree(cfg);
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
+	u16 i;
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
+							u8 phyid)
+{
+	int i;
+	/* Try to match with specified preference */
+	for (i = 0; i < MAX_PHY_LAYERS; i++)
+		if (cnfg->phy_layers[i].frm_layer != NULL &&
+		    cnfg->phy_layers[i].id == phyid)
+			return &cnfg->phy_layers[i];
+	return NULL;
+}
+
+int cfcnfg_get_named(struct cfcnfg *cnfg, char *name)
+{
+	int i;
+
+	/* Try to match with specified name */
+	for (i = 0; i < MAX_PHY_LAYERS; i++) {
+		if (cnfg->phy_layers[i].frm_layer != NULL
+		    && strcmp(cnfg->phy_layers[i].phy_layer->name,
+			      name) == 0)
+			return cnfg->phy_layers[i].frm_layer->id;
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
+int cfcnfg_del_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer)
+{
+	u8 channel_id = 0;
+	int ret = 0;
+	struct cfcnfg_phyinfo *phyinfo = NULL;
+	u8 phyid = 0;
+
+	caif_assert(adap_layer != NULL);
+	channel_id = adap_layer->id;
+	if (channel_id == 0) {
+		pr_err("CAIF: %s():adap_layer->id is 0\n", __func__);
+		ret = -ENOTCONN;
+		goto end;
+	}
+
+	if (adap_layer->dn == NULL) {
+		pr_err("CAIF: %s():adap_layer->dn is NULL\n", __func__);
+		ret = -ENODEV;
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
+		ret = -ENODEV;
+		goto end;
+	}
+
+	if (phyinfo->id != phyid
+		|| phyinfo->phy_layer->id != phyid
+		|| phyinfo->frm_layer->id != phyid) {
+
+		pr_err("CAIF: %s(): Inconsistency in phy registration\n",
+			__func__);
+		ret = -EINVAL;
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
+static void cncfg_linkdestroy_rsp(struct cflayer *layer, u8 linkid,
+				  struct cflayer *client_layer)
+{
+	struct cfcnfg *cnfg = container_obj(layer);
+	struct cflayer *servl;
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
+	cfservl_destroy(servl);
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
+int
+cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
+				struct cfctrl_link_param *param,
+				struct cflayer *adap_layer)
+{
+	struct cflayer *frml;
+	if (adap_layer == NULL) {
+		pr_err("CAIF: %s(): adap_layer is zero", __func__);
+		return -EINVAL;
+	}
+	if (adap_layer->receive == NULL) {
+		pr_err("CAIF: %s(): adap_layer->receive is NULL", __func__);
+		return -EINVAL;
+	}
+	if (adap_layer->ctrlcmd == NULL) {
+		pr_err("CAIF: %s(): adap_layer->ctrlcmd == NULL", __func__);
+		return -EINVAL;
+	}
+	frml = cnfg->phy_layers[param->phyid].frm_layer;
+	if (frml == NULL) {
+		pr_err("CAIF: %s(): Specified PHY type does not exist!",
+			__func__);
+		return -ENODEV;
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
+static void cncfg_reject_rsp(struct cflayer *layer, u8 linkid,
+			     struct cflayer *adapt_layer)
+{
+	if (adapt_layer != NULL && adapt_layer->ctrlcmd != NULL)
+		adapt_layer->ctrlcmd(adapt_layer,
+				     CAIF_CTRLCMD_INIT_FAIL_RSP, 0);
+}
+
+static void
+cncfg_linkup_rsp(struct cflayer *layer, u8 linkid, enum cfctrl_srv serv,
+		 u8 phyid, struct cflayer *adapt_layer)
+{
+	struct cfcnfg *cnfg = container_obj(layer);
+	struct cflayer *servicel = NULL;
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
+		servicel = cfdbgl_create(linkid, &phyinfo->dev_info);
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
+	cfmuxl_set_uplayer(cnfg->mux, servicel, linkid);
+	layer_set_up(servicel, adapt_layer);
+	layer_set_dn(adapt_layer, servicel);
+	servicel->ctrlcmd(servicel, CAIF_CTRLCMD_INIT_RSP, 0);
+}
+
+void
+cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
+		     void *dev, struct cflayer *phy_layer, u16 *phyid,
+		     enum cfcnfg_phy_preference pref,
+		     bool fcs, bool stx)
+{
+	struct cflayer *frml;
+	struct cflayer *phy_driver = NULL;
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
+int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, struct cflayer *phy_layer)
+{
+	struct cflayer *frml, *frml_dn;
+	u16 phyid;
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
+	kfree(frml);
+
+	if (phy_layer != frml_dn) {
+		layer_set_up(frml_dn, NULL);
+		layer_set_dn(frml_dn, NULL);
+		kfree(frml_dn);
+	}
+	layer_set_up(phy_layer, NULL);
+	return 0;
+}
+EXPORT_SYMBOL(cfcnfg_del_phy_layer);
diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
new file mode 100644
index 0000000..83fff2f
--- /dev/null
+++ b/net/caif/cfpkt_skbuff.c
@@ -0,0 +1,571 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <linux/hardirq.h>
+#include <net/caif/cfpkt.h>
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
+	atomic_t count;
+	/* Lock protects count updates */
+	spinlock_t lock;
+};
+
+/*
+ * net/caif/ is generic and does not
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
+
+struct cfpkt *cfpkt_fromnative(enum caif_direction dir, void *nativepkt)
+{
+	struct cfpkt *pkt = skb_to_pkt(nativepkt);
+	cfpkt_priv(pkt)->erronous = false;
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
+static struct cfpkt *cfpkt_create_pfx(u16 len, u16 pfx)
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
+	return skb_to_pkt(skb);
+}
+
+inline struct cfpkt *cfpkt_create(u16 len)
+{
+	return cfpkt_create_pfx(len + PKT_POSTFIX, PKT_PREFIX);
+}
+EXPORT_SYMBOL(cfpkt_create);
+
+void cfpkt_destroy(struct cfpkt *pkt)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
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
+int cfpkt_peek_head(struct cfpkt *pkt, void *data, u16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	if (skb_headlen(skb) >= len) {
+		memcpy(data, skb->data, len);
+		return 0;
+	}
+	return !cfpkt_extr_head(pkt, data, len) &&
+	    !cfpkt_add_head(pkt, data, len);
+}
+EXPORT_SYMBOL(cfpkt_peek_head);
+
+int cfpkt_extr_head(struct cfpkt *pkt, void *data, u16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	u8 *from;
+	if (unlikely(is_erronous(pkt)))
+		return -EPROTO;
+
+	if (unlikely(len > skb->len)) {
+		PKT_ERROR(pkt, "cfpkt_extr_head read beyond end of packet\n");
+		return -EPROTO;
+	}
+
+	if (unlikely(len > skb_headlen(skb))) {
+		if (unlikely(skb_linearize(skb) != 0)) {
+			PKT_ERROR(pkt, "cfpkt_extr_head linearize failed\n");
+			return -EPROTO;
+		}
+	}
+	from = skb_pull(skb, len);
+	from -= len;
+	memcpy(data, from, len);
+	return 0;
+}
+EXPORT_SYMBOL(cfpkt_extr_head);
+
+int cfpkt_extr_trail(struct cfpkt *pkt, void *dta, u16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	u8 *data = dta;
+	u8 *from;
+	if (unlikely(is_erronous(pkt)))
+		return -EPROTO;
+
+	if (unlikely(skb_linearize(skb) != 0)) {
+		PKT_ERROR(pkt, "cfpkt_extr_trail linearize failed\n");
+		return -EPROTO;
+	}
+	if (unlikely(skb->data + len > skb_tail_pointer(skb))) {
+		PKT_ERROR(pkt, "cfpkt_extr_trail read beyond end of packet\n");
+		return -EPROTO;
+	}
+	from = skb_tail_pointer(skb) - len;
+	skb_trim(skb, skb->len - len);
+	memcpy(data, from, len);
+	return 0;
+}
+EXPORT_SYMBOL(cfpkt_extr_trail);
+
+int cfpkt_pad_trail(struct cfpkt *pkt, u16 len)
+{
+	return cfpkt_add_body(pkt, NULL, len);
+}
+EXPORT_SYMBOL(cfpkt_pad_trail);
+
+int cfpkt_add_body(struct cfpkt *pkt, const void *data, u16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	struct sk_buff *lastskb;
+	u8 *to;
+	u16 addlen = 0;
+
+
+	if (unlikely(is_erronous(pkt)))
+		return -EPROTO;
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
+			return -EPROTO;
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
+	return 0;
+}
+EXPORT_SYMBOL(cfpkt_add_body);
+
+inline int cfpkt_addbdy(struct cfpkt *pkt, u8 data)
+{
+	return cfpkt_add_body(pkt, &data, 1);
+}
+EXPORT_SYMBOL(cfpkt_addbdy);
+
+int cfpkt_add_head(struct cfpkt *pkt, const void *data2, u16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	struct sk_buff *lastskb;
+	u8 *to;
+	const u8 *data = data2;
+	if (unlikely(is_erronous(pkt)))
+		return -EPROTO;
+	if (unlikely(skb_headroom(skb) < len)) {
+		PKT_ERROR(pkt, "cfpkt_add_head: no headroom\n");
+		return -EPROTO;
+	}
+
+	/* Make sure data is writable */
+	if (unlikely(skb_cow_data(skb, 0, &lastskb) < 0)) {
+		PKT_ERROR(pkt, "cfpkt_add_head: cow failed\n");
+		return -EPROTO;
+	}
+
+	to = skb_push(skb, len);
+	memcpy(to, data, len);
+	return 0;
+}
+EXPORT_SYMBOL(cfpkt_add_head);
+
+inline int cfpkt_add_trail(struct cfpkt *pkt, const void *data, u16 len)
+{
+	return cfpkt_add_body(pkt, data, len);
+}
+EXPORT_SYMBOL(cfpkt_add_trail);
+
+inline u16 cfpkt_getlen(struct cfpkt *pkt)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	return skb->len;
+}
+EXPORT_SYMBOL(cfpkt_getlen);
+
+inline u16 cfpkt_iterate(struct cfpkt *pkt,
+			    u16 (*iter_func)(u16, void *, u16),
+			    u16 data)
+{
+	/*
+	 * Don't care about the performance hit of linearizing,
+	 * Checksum should not be used on high-speed interfaces anyway.
+	 */
+	if (unlikely(is_erronous(pkt)))
+		return -EPROTO;
+	if (unlikely(skb_linearize(&pkt->skb) != 0)) {
+		PKT_ERROR(pkt, "cfpkt_iterate: linearize failed\n");
+		return -EPROTO;
+	}
+	return iter_func(data, pkt->skb.data, cfpkt_getlen(pkt));
+}
+EXPORT_SYMBOL(cfpkt_iterate);
+
+int cfpkt_setlen(struct cfpkt *pkt, u16 len)
+{
+	struct sk_buff *skb = pkt_to_skb(pkt);
+
+
+	if (unlikely(is_erronous(pkt)))
+		return -EPROTO;
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
+struct cfpkt *cfpkt_append(struct cfpkt *dstpkt,
+			     struct cfpkt *addpkt,
+			     u16 expectlen)
+{
+	struct sk_buff *dst = pkt_to_skb(dstpkt);
+	struct sk_buff *add = pkt_to_skb(addpkt);
+	u16 addlen = skb_headlen(add);
+	u16 neededtailspace;
+	struct sk_buff *tmp;
+	u16 dstlen;
+	u16 createlen;
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
+		dstlen = skb_headlen(dst);
+		createlen = dstlen + neededtailspace;
+		tmp = pkt_to_skb(
+			cfpkt_create(createlen + PKT_PREFIX + PKT_POSTFIX));
+		if (!tmp)
+			return NULL;
+		skb_set_tail_pointer(tmp, dstlen);
+		tmp->len = dstlen;
+		memcpy(tmp->data, dst->data, dstlen);
+		cfpkt_destroy(dstpkt);
+		dst = tmp;
+	}
+	memcpy(skb_tail_pointer(dst), add->data, skb_headlen(add));
+	cfpkt_destroy(addpkt);
+	dst->tail += addlen;
+	dst->len += addlen;
+	return skb_to_pkt(dst);
+}
+EXPORT_SYMBOL(cfpkt_append);
+
+struct cfpkt *cfpkt_split(struct cfpkt *pkt, u16 pos)
+{
+	struct sk_buff *skb2;
+	struct sk_buff *skb = pkt_to_skb(pkt);
+	u8 *split = skb->data + pos;
+	u16 len2nd = skb_tail_pointer(skb) - split;
+
+	if (unlikely(is_erronous(pkt)))
+		return NULL;
+
+	if (skb->data + pos > skb_tail_pointer(skb)) {
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
+	skb_set_tail_pointer(skb, pos);
+	skb->len = pos;
+
+	memcpy(skb2->data, split, len2nd);
+	skb2->tail += len2nd;
+	skb2->len += len2nd;
+	return skb_to_pkt(skb2);
+}
+EXPORT_SYMBOL(cfpkt_split);
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
+	snprintf(buf, buflen, "%s: pkt:%p len:%ld(%ld+%ld) {%ld,%ld} data: [",
+		is_erronous(pkt) ? "ERRONOUS-SKB" :
+		 (skb->data_len != 0 ? "COMPLEX-SKB" : "SKB"),
+		 skb,
+		 (long) skb->len,
+		 (long) (skb_tail_pointer(skb) - skb->data),
+		 (long) skb->data_len,
+		 (long) (skb->data - skb->head),
+		 (long) (skb_tail_pointer(skb) - skb->head));
+	p = buf + strlen(buf);
+
+	for (i = 0; i < skb_tail_pointer(skb) - skb->data && i < 300; i++) {
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
+		return -EPROTO;
+	/* Make sure SKB is writable */
+	if (unlikely(skb_cow_data(skb, 0, &lastskb) < 0)) {
+		PKT_ERROR(pkt, "cfpkt_raw_append: skb_cow_data failed\n");
+		return -EPROTO;
+	}
+
+	if (unlikely(skb_linearize(skb) != 0)) {
+		PKT_ERROR(pkt, "cfpkt_raw_append: linearize failed\n");
+		return -EPROTO;
+	}
+
+	if (unlikely(skb_tailroom(skb) < buflen)) {
+		PKT_ERROR(pkt, "cfpkt_raw_append: buffer too short - failed\n");
+		return -EPROTO;
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
+		return -EPROTO;
+
+	if (unlikely(buflen > skb->len)) {
+		PKT_ERROR(pkt, "cfpkt_raw_extract: buflen too large "
+				"- failed\n");
+		return -EPROTO;
+	}
+
+	if (unlikely(buflen > skb_headlen(skb))) {
+		if (unlikely(skb_linearize(skb) != 0)) {
+			PKT_ERROR(pkt, "cfpkt_raw_extract: linearize failed\n");
+			return -EPROTO;
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
+struct cfpktq *cfpktq_create(void)
+{
+	struct cfpktq *q = kmalloc(sizeof(struct cfpktq), GFP_ATOMIC);
+	if (!q)
+		return NULL;
+	skb_queue_head_init(&q->head);
+	atomic_set(&q->count, 0);
+	spin_lock_init(&q->lock);
+	return q;
+}
+EXPORT_SYMBOL(cfpktq_create);
+
+void cfpkt_queue(struct cfpktq *pktq, struct cfpkt *pkt, unsigned short prio)
+{
+	atomic_inc(&pktq->count);
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
+		atomic_dec(&pktq->count);
+		caif_assert(atomic_read(&pktq->count) >= 0);
+	}
+	spin_unlock(&pktq->lock);
+	return pkt;
+}
+EXPORT_SYMBOL(cfpkt_dequeue);
+
+int cfpkt_qcount(struct cfpktq *pktq)
+{
+	return atomic_read(&pktq->count);
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
+	return clone;
+}
+EXPORT_SYMBOL(cfpkt_clone_release);
+
+struct caif_payload_info *cfpkt_info(struct cfpkt *pkt)
+{
+	return (struct caif_payload_info *)&pkt_to_skb(pkt)->cb;
+}
+EXPORT_SYMBOL(cfpkt_info);
-- 
1.6.3.3

