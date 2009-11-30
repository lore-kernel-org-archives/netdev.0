From: sjur.brandeland@stericsson.com
Subject: [RFC PATCH v3  4/8] CAIF Protocol Stack
Date: Mon, 30 Nov 2009 16:00:48 +0100
Message-ID: <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: randy.dunlap@oracle.com, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55205 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbZK3QBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 11:01:50 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX001YVGEPKF10@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:37 +0100 (CET)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX00IAMGDW9QV1@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:37 +0100 (CET)
In-reply-to: <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/generic/cfcnfg.c       |  560 ++++++++++++++++++++++++++++++
 net/caif/generic/cfctrl.c       |  685 ++++++++++++++++++++++++++++++++++++
 net/caif/generic/cfdgml.c       |  115 ++++++
 net/caif/generic/cffrml.c       |  149 ++++++++
 net/caif/generic/cflist.c       |   88 +++++
 net/caif/generic/cfloopcfg.c    |  103 ++++++
 net/caif/generic/cflooplayer.c  |  109 ++++++
 net/caif/generic/cfmsll.c       |   52 +++
 net/caif/generic/cfmuxl.c       |  247 +++++++++++++
 net/caif/generic/cfpkt_skbuff.c |  726 +++++++++++++++++++++++++++++++++++++++
 net/caif/generic/cfrfml.c       |  112 ++++++
 net/caif/generic/cfserl.c       |  292 ++++++++++++++++
 net/caif/generic/cfshml.c       |   63 ++++
 net/caif/generic/cfspil.c       |  344 ++++++++++++++++++
 net/caif/generic/cfsrvl.c       |  181 ++++++++++
 net/caif/generic/cfusbl.c       |   51 +++
 net/caif/generic/cfutill.c      |  109 ++++++
 net/caif/generic/cfveil.c       |  113 ++++++
 net/caif/generic/cfvidl.c       |   62 ++++
 net/caif/generic/fcs.c          |   51 +++
 20 files changed, 4212 insertions(+), 0 deletions(-)
 create mode 100644 net/caif/generic/cfcnfg.c
 create mode 100644 net/caif/generic/cfctrl.c
 create mode 100644 net/caif/generic/cfdgml.c
 create mode 100644 net/caif/generic/cffrml.c
 create mode 100644 net/caif/generic/cflist.c
 create mode 100644 net/caif/generic/cfloopcfg.c
 create mode 100644 net/caif/generic/cflooplayer.c
 create mode 100644 net/caif/generic/cfmsll.c
 create mode 100644 net/caif/generic/cfmuxl.c
 create mode 100644 net/caif/generic/cfpkt_skbuff.c
 create mode 100644 net/caif/generic/cfrfml.c
 create mode 100644 net/caif/generic/cfserl.c
 create mode 100644 net/caif/generic/cfshml.c
 create mode 100644 net/caif/generic/cfspil.c
 create mode 100644 net/caif/generic/cfsrvl.c
 create mode 100644 net/caif/generic/cfusbl.c
 create mode 100644 net/caif/generic/cfutill.c
 create mode 100644 net/caif/generic/cfveil.c
 create mode 100644 net/caif/generic/cfvidl.c
 create mode 100644 net/caif/generic/fcs.c

diff --git a/net/caif/generic/cfcnfg.c b/net/caif/generic/cfcnfg.c
new file mode 100644
index 0000000..5ebcb50
--- /dev/null
+++ b/net/caif/generic/cfcnfg.c
@@ -0,0 +1,560 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cflst.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <net/caif/generic/cfctrl.h>
+#include <net/caif/generic/cfmuxl.h>
+#include <net/caif/generic/cffrml.h>
+#include <net/caif/generic/cfserl.h>
+#include <net/caif/generic/cfspil.h>
+#include <net/caif/generic/cfshml.h>
+#include <net/caif/generic/cfmsll.h>
+#include <net/caif/generic/cfusbl.h>
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
+	/** Type of physical layer e.g. UART or SPI */
+	enum cfcnfg_phy_type type;
+	/** Pointer to the layer below the MUX (framing layer) */
+	struct layer *frm_layer;
+	/** Pointer to the lowest actual physical layer */
+	struct layer *phy_layer;
+	/** Unique identifier of the physical interface */
+	unsigned int id;
+	/** Name of the physical interface */
+	char name[PHY_NAME_LEN];
+	/** Preference of the physical in interface */
+	enum cfcnfg_phy_preference pref;
+
+	/** Reference count, number of channels using the device */
+	int phy_ref_count;
+};
+
+struct cfcnfg {
+	struct layer layer;
+	struct layer *ctrl;
+	struct layer *mux;
+	uint8 last_phyid;
+	struct cfcnfg_phyinfo phy_layers[MAX_PHY_LAYERS];
+	struct cfcnfg_phy_mgmt phy_registration[CFPHYTYPE_MAX];
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
+
+
+struct cfcnfg *cfcnfg_create()
+{
+	struct cfcnfg *this;
+	struct cfctrl_rsp resp;
+	/* Initiate response functions */
+	resp.enum_rsp = cfctrl_enum_resp;
+	resp.linkerror_ind = cfctrl_resp_func;
+	resp.linkdestroy_rsp = cncfg_linkdestroy_rsp;
+	resp.sleep_rsp = cfctrl_resp_func;
+	resp.wake_rsp = cfctrl_resp_func;
+	resp.restart_rsp = cfctrl_resp_func;
+	resp.radioset_rsp = cfctrl_resp_func;
+	resp.linksetup_rsp = cncfg_linkup_rsp;
+	resp.reject_rsp = cncfg_reject_rsp;
+	/* Initiate this layer */
+	this = cfglu_alloc(sizeof(struct cfcnfg));
+	memset(this, 0, sizeof(struct cfcnfg));
+	this->mux = cfmuxl_create();
+	this->ctrl = cfctrl_create();
+	this->last_phyid = 1;
+	cfctrl_set_respfuncs(this->ctrl, &resp);
+	cfmuxl_set_uplayer(this->mux, this->ctrl, 0);
+	layer_set_dn(this->ctrl, this->mux);
+	layer_set_up(this->ctrl, this);
+	return this;
+}
+EXPORT_SYMBOL(cfcnfg_create);
+
+static void cfctrl_resp_func(void)
+{
+	CFLOG_ENTER(("cfcnfg: cfctrl_resp_func\n"));
+	CFLOG_EXIT(("cfcnfg: cfctrl_resp_func\n"));
+}
+
+static void cfctrl_enum_resp(void)
+{
+	CFLOG_ENTER(("cfcnfg: enter cfctrl_enum_resp\n"));
+	CFLOG_EXIT(("cfcnfg: exit cfctrl_enum_resp\n"));
+}
+
+int cfcnfg_get_phyid(struct cfcnfg *cnfg, enum cfcnfg_phy_preference phy_pref)
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
+			return cnfg->phy_layers[i].frm_layer->id;
+		}
+	}
+	/* Otherwise just return something */
+	for (i = 1; i < MAX_PHY_LAYERS; i++) {
+		if (cnfg->phy_layers[i].id == i) {
+			caif_assert(cnfg->phy_layers != NULL);
+			caif_assert(cnfg->phy_layers[i].id == i);
+			return i;
+		}
+	}
+
+	return 0;
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
+/**
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
+	CFLOG_TRACE(("cfcnfg: enter del_adaptation_layer\n"));
+
+	caif_assert(adap_layer != NULL);
+	channel_id = adap_layer->id;
+	if (channel_id == 0) {
+		CFLOG_ERROR(("cfcnfg:adap_layer->id is 0\n"));
+		ret = CFGLU_ENOTCONN;
+		goto end;
+	}
+
+	if (adap_layer->dn == NULL) {
+		CFLOG_ERROR(("cfcnfg:adap_layer->dn is NULL\n"));
+		ret = CFGLU_ENODEV;
+		goto end;
+	}
+
+	if (adap_layer->dn != NULL)
+		phyid = cfsrvl_getphyid(adap_layer->dn);
+
+
+	phyinfo = cfcnfg_get_phyinfo(cnfg, phyid);
+	if (phyinfo == NULL) {
+		CFLOG_WARN(("cfcnfg: No interface to send disconnect to\n"));
+		ret = CFGLU_ENODEV;
+		goto end;
+	}
+
+	if (phyinfo->id != phyid
+		|| phyinfo->phy_layer->id != phyid
+		|| phyinfo->frm_layer->id != phyid) {
+
+		CFLOG_ERROR(("cfcnfg: Inconsitency in phy registration\n"));
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
+		CFLOG_TRACE(("cfcnfg: send PHYIF_USELESS\n"));
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
+	CFLOG_TRACE(("cfcnfg: enter linkdestroy_rsp\n"));
+
+	/* 1) Remove service from the MUX layer */
+	servl = cfmuxl_remove_uplayer(cnfg->mux, linkid);
+	/* invar: MUX guarantees no more payload sent "upwards" (receive) */
+
+	if (servl == NULL) {
+		CFLOG_ERROR(("cfcnfg: Error removing service_layer Linkid(%d)",
+			     linkid));
+		return;
+	}
+	caif_assert(linkid == servl->id);
+
+	if (servl != client_layer && servl->up != client_layer) {
+		CFLOG_ERROR(("cfcnfg: Error removing service_layer "
+			     "Linkid(%d) %p %p",
+			     linkid, (void *) servl, (void *) client_layer));
+		return;
+	}
+
+	/* 2) SHUTDOWN must guarantee that no more packets are transmitted
+	 * from adap_layer when it returns.  We assume it locks the layer for
+	 * every transmit and lock when receiving this SHUTDOWN
+	 */
+
+	if (servl->ctrlcmd == NULL) {
+		CFLOG_ERROR(("cfcnfg: Error servl->ctrlcmd == NULL"));
+		return;
+	}
+
+	servl->ctrlcmd(servl, CAIF_CTRLCMD_DEINIT_RSP, 0);
+
+	/* invar: Adaptation Layer guarantees no more payload sent
+	 *  "down-wards" (transmit)
+	 */
+
+	/* 3) It is now safe to destroy the service layer (if any) */
+
+	/*
+	 * FIXME: We need a ref-count in order to safely free
+	 *        the up layer.
+	 */
+	if (client_layer != servl->up)
+		cfservl_destroy(servl);
+}
+
+/**
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
+	CFLOG_TRACE(("cfcnfg[%p]: enter add_adaptation_layer\n",
+		     (void *) cnfg));
+
+	if (adap_layer == NULL) {
+		CFLOG_ERROR(("cfcnfg: adap_layer is zero"));
+		return CFGLU_EINVAL;
+	}
+	if (adap_layer->receive == NULL) {
+		CFLOG_ERROR(("cfcnfg-add: adap_layer->receive is NULL"));
+		return CFGLU_EINVAL;
+	}
+	if (adap_layer->ctrlcmd == NULL) {
+		CFLOG_ERROR(("cfcnfg-add: adap_layer->ctrlcmd == NULL"));
+		return CFGLU_EINVAL;
+	}
+
+	frml = cnfg->phy_layers[param->phyid].frm_layer;
+	if (frml == NULL) {
+		CFLOG_ERROR(("cfcnfg: Specified PHY type does not exist!"));
+		return false;
+	}
+	caif_assert(param->phyid == cnfg->phy_layers[param->phyid].id);
+	caif_assert(cnfg->phy_layers[param->phyid].frm_layer->id ==
+		     param->phyid);
+	caif_assert(cnfg->phy_layers[param->phyid].phy_layer->id ==
+		     param->phyid);
+	CFLOG_TRACE(("cfcnfg: send enum request\n"));
+	/* FIXME: ENUMERATE INITIALLY WHEN ACTIVATING PHYSICAL INTERFACE */
+
+	cfctrl_enum_req(cnfg->ctrl, param->phyid);
+
+	cfctrl_linkup_request(cnfg->ctrl, param, adap_layer);
+
+	return true;
+}
+EXPORT_SYMBOL(cfcnfg_add_adaptation_layer);
+
+static void cncfg_reject_rsp(struct layer *layer, uint8 linkid,
+			     struct layer *adapt_layer)
+{
+	CFLOG_ENTER(("layer=%p linkid=%d adapt_layer=%p\n", (void *) layer,
+		     linkid, (void *) adapt_layer));
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
+	CFLOG_ENTER(("cfcnfg[%p]: enter scfcnfg_linup_rsp\n", (void *) layer));
+	if (adapt_layer == NULL) {
+		CFLOG_ERROR(("cfcnfg: CAIF PROTOCOL ERROR "
+			     "- LinkUp Request/Response did not match\n"));
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
+		servicel = cfvei_create(linkid, phyid);
+		CFLOG_TRACE(("cfcnfg: AT channel created\n"));
+		break;
+	case CFCTRL_SRV_DATAGRAM:
+		servicel = cfdgml_create(linkid, phyid);
+		CFLOG_TRACE(("cfcnfg: Datagram channel created\n"));
+		break;
+	case CFCTRL_SRV_RFM:
+		servicel = cfrfml_create(linkid, phyid);
+		CFLOG_TRACE(("cfcnfg: RFM channel created\n"));
+		break;
+	case CFCTRL_SRV_UTIL:
+		servicel = cfutill_create(linkid, phyid);
+		CFLOG_TRACE(("cfcnfg: Utility channel created\n"));
+		break;
+	case CFCTRL_SRV_VIDEO:
+		servicel = cfvidl_create(linkid, phyid);
+		CFLOG_TRACE(("cfcnfg: Video channel created\n"));
+		break;
+	case CFCTRL_SRV_DBG:
+		CFLOG_TRACE(("cfcnfg: Debug channel created\n"));
+		servicel = adapt_layer;
+		break;
+	default:
+		CFLOG_ERROR(("cfcnfg: ERROR "
+			     "Link setup response - unknown channel type\n"));
+		return;
+	}
+	layer_set_dn(servicel, cnfg->mux);
+
+	CFLOG_TRACE(("cfcnfg: insert service layer in mux\n"));
+
+	cfmuxl_set_uplayer(cnfg->mux, servicel, linkid);
+	if (servicel != adapt_layer) {
+		CFLOG_TRACE(("cfcnfg: insert adapt-layer in service layer\n"));
+		layer_set_up(servicel, adapt_layer);
+		layer_set_dn(adapt_layer, servicel);
+	}
+	CFLOG_TRACE(("cfcnfg: successfull link setup - call flowtrl(init)\n"));
+	servicel->ctrlcmd(servicel, CAIF_CTRLCMD_INIT_RSP, 0);
+}
+
+struct caif_packet_funcs cfcnfg_get_packet_funcs()
+{
+	return cfpkt_get_packet_funcs();
+}
+EXPORT_SYMBOL(cfcnfg_get_packet_funcs);
+
+void
+cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
+		     struct layer *phy_layer, uint16 *phyid,
+		     enum cfcnfg_phy_preference pref)
+{
+	struct layer *frml;
+	struct layer *phy_driver = NULL;
+	int i;
+	bool DoFCS = false;
+	struct cfspipad padopt;
+
+	CFLOG_TRACE(("cfcnfg: enter add_phy_layer\n"));
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
+		CFLOG_ERROR(("cfcnfg: No Available PHY ID\n"));
+		return;
+	}
+
+	switch (phy_type) {
+	case CFPHYTYPE_SERIAL:
+		CFLOG_TRACE(("cfcnfg: Starting Serial link\n"));
+		DoFCS = true;
+		phy_driver =
+		    cfserl_create(CFPHYTYPE_SERIAL, *phyid, serial_use_stx);
+		break;
+	case CFPHYTYPE_SPI:
+		padopt.up_head_align = (uint16)spi_up_head_align;
+		padopt.up_tail_align = (uint16)spi_up_tail_align;
+		padopt.down_head_align = (uint16)spi_down_head_align;
+		padopt.down_tail_align = (uint16)spi_down_tail_align;
+		CFLOG_TRACE(("cfcnfg: Starting SPI link\n"));
+		phy_driver = cfspil_create(CFPHYTYPE_SPI, *phyid, padopt);
+		break;
+	case CFPHYTYPE_SHM:
+		CFLOG_TRACE(("cfcnfg: Starting SHM link\n"));
+		phy_driver = cfshml_create(CFPHYTYPE_SHM, *phyid);
+		break;
+	case CFPHYTYPE_MSL:
+		CFLOG_TRACE(("cfcnfg: Starting MSL link\n"));
+		phy_driver = cfmsll_create(CFPHYTYPE_MSL, *phyid);
+		break;
+	case CFPHYTYPE_USB:
+		CFLOG_TRACE(("cfcnfg: Starting USB link\n"));
+		phy_driver = cfusbl_create(CFPHYTYPE_USB, *phyid);
+		break;
+	default:
+		CFLOG_ERROR(("cfcnfg: Bad phy_type specified: %d", phy_type));
+		return;
+		break;
+	}
+
+	phy_layer->id = *phyid;
+	phy_driver->id = *phyid;
+	cnfg->phy_layers[*phyid].pref = pref;
+	cnfg->phy_layers[*phyid].id = *phyid;
+	cnfg->phy_layers[*phyid].type = phy_type;
+	cnfg->phy_layers[*phyid].phy_layer = phy_layer;
+	cnfg->phy_layers[*phyid].phy_ref_count = 0;
+	phy_layer->type = phy_type;
+	frml = cffrml_create(*phyid, DoFCS);
+	cnfg->phy_layers[*phyid].frm_layer = frml;
+	cfmuxl_set_dnlayer(cnfg->mux, frml, *phyid);
+	layer_set_up(frml, cnfg->mux);
+	layer_set_dn(frml, phy_driver);
+	layer_set_up(phy_driver, frml);
+	layer_set_dn(phy_driver, phy_layer);
+	layer_set_up(phy_layer, phy_driver);
+	CFLOG_TRACE(("cfcnfg: phy1=%p phy2=%p transmit=0x%d\n",
+		     (void *) phy_driver, (void *) phy_layer,
+		     (int) phy_layer->transmit));
+}
+EXPORT_SYMBOL(cfcnfg_add_phy_layer);
+
+int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, struct layer *phy_layer)
+{
+	struct layer *frml, *cfphy;
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
+	cfphy = frml->dn;
+
+	cffrml_set_uplayer(frml, NULL);
+	cffrml_set_dnlayer(frml, NULL);
+	cffrml_destroy(frml);
+
+	caif_assert(cfphy->dn == phy_layer);
+	layer_set_up(cfphy, NULL);
+	layer_set_dn(cfphy, NULL);
+	cfglu_free(cfphy);
+
+	layer_set_up(phy_layer, NULL);
+	return CFGLU_EOK;
+}
+EXPORT_SYMBOL(cfcnfg_del_phy_layer);
diff --git a/net/caif/generic/cfctrl.c b/net/caif/generic/cfctrl.c
new file mode 100644
index 0000000..0a27731
--- /dev/null
+++ b/net/caif/generic/cfctrl.c
@@ -0,0 +1,685 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfctrl.h>
+
+#define container_obj(layr) cfglu_container_of(layr, struct cfctrl, serv.layer)
+#define UTILITY_NAME_LENGTH 16
+#define CFPKT_CTRL_PKT_LEN 20
+
+
+#ifdef CAIF_NO_LOOP
+static inline int handle_loop(struct cfctrl *ctrl,
+			      int cmd, struct cfpkt *pkt){
+	return CAIF_FAILURE;
+}
+#else
+static int handle_loop(struct cfctrl *ctrl,
+		int cmd, struct cfpkt *pkt);
+#endif
+static int cfctrl_recv(struct layer *layr, struct cfpkt *pkt);
+static void cfctrl_ctrlcmd(struct layer *layr, enum caif_ctrlcmd ctrl,
+				int phyid);
+
+
+struct layer *cfctrl_create()
+{
+	struct cfctrl *this =
+	    (struct cfctrl *) cfglu_alloc(sizeof(struct cfctrl));
+	caif_assert(offsetof(struct cfctrl, serv.layer) == 0);
+	memset(this, 0, sizeof(*this));
+	cfglu_init_lock(this->info_list_lock);
+	cfglu_atomic_set(this->req_seq_no, 1);
+	cfglu_atomic_set(this->rsp_seq_no, 1);
+	this->serv.phid = 0xff;
+	this->serv.layer.id = 0;
+	this->serv.layer.receive = cfctrl_recv;
+	sprintf(this->serv.layer.name, "ctrl");
+	this->serv.layer.ctrlcmd = cfctrl_ctrlcmd;
+	cfglu_init_lock(this->loop_linkid_lock);
+	this->loop_linkid = 1;
+	return &this->serv.layer;
+}
+
+bool param_eq(struct cfctrl_link_param *p1, struct cfctrl_link_param *p2)
+{
+	bool eq =
+	    p1->linktype == p2->linktype &&
+	    p1->priority == p2->priority &&
+	    p1->phyid == p2->phyid &&
+	    p1->endpoint == p2->endpoint && p1->chtype == p2->chtype;
+
+	if (!eq)
+		return false;
+
+	switch (p1->linktype) {
+	case CFCTRL_SRV_VEI:
+		return true;
+	case CFCTRL_SRV_DATAGRAM:
+		return p1->u.datagram.connid == p2->u.datagram.connid;
+	case CFCTRL_SRV_RFM:
+		return
+		    p1->u.rfm.connid == p2->u.rfm.connid &&
+		    strcmp(p1->u.rfm.volume, p2->u.rfm.volume) == 0;
+	case CFCTRL_SRV_UTIL:
+		return
+		    p1->u.utility.fifosize_kb == p2->u.utility.fifosize_kb
+		    && p1->u.utility.fifosize_bufs ==
+		    p2->u.utility.fifosize_bufs
+		    && strcmp(p1->u.utility.name, p2->u.utility.name) == 0
+		    && p1->u.utility.paramlen == p2->u.utility.paramlen
+		    && memcmp(p1->u.utility.params, p2->u.utility.params,
+			      p1->u.utility.paramlen) == 0;
+
+	case CFCTRL_SRV_VIDEO:
+		return p1->u.video.connid == p2->u.video.connid;
+	case CFCTRL_SRV_DBG:
+		return true;
+	case CFCTRL_SRV_DECM:
+		return false;
+	default:
+		return false;
+	}
+	return false;
+}
+
+bool cfctrl_req_eq(struct cfctrl_request_info *r1,
+		   struct cfctrl_request_info *r2)
+{
+	if (r1->cmd != r2->cmd)
+		return false;
+	if (r1->cmd == CFCTRL_CMD_LINK_SETUP)
+		return param_eq(&r1->param, &r2->param);
+	else
+		return r1->channel_id == r2->channel_id;
+}
+
+/* Insert request at the end */
+void cfctrl_insert_req(struct cfctrl *ctrl,
+			      struct cfctrl_request_info *req)
+{
+	struct cfctrl_request_info *p;
+	cfglu_lock(ctrl->info_list_lock);
+	req->next = NULL;
+	cfglu_atomic_inc(ctrl->req_seq_no);
+	req->sequence_no = cfglu_atomic_read(ctrl->req_seq_no);
+	if (ctrl->first_req == NULL) {
+		ctrl->first_req = req;
+		cfglu_unlock(ctrl->info_list_lock);
+		return;
+	}
+	p = ctrl->first_req;
+	while (p->next != NULL)
+		p = p->next;
+	p->next = req;
+	cfglu_unlock(ctrl->info_list_lock);
+}
+
+static void cfctrl_insert_req2(struct cfctrl *ctrl, enum cfctrl_cmd cmd,
+			       uint8 linkid, struct layer *user_layer)
+{
+	struct cfctrl_request_info *req = cfglu_alloc(sizeof(*req));
+	req->client_layer = user_layer;
+	req->cmd = cmd;
+	req->channel_id = linkid;
+	cfctrl_insert_req(ctrl, req);
+}
+
+/* Compare and remove request */
+struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
+					      struct cfctrl_request_info *req)
+{
+	struct cfctrl_request_info *p;
+	struct cfctrl_request_info *ret;
+
+	cfglu_lock(ctrl->info_list_lock);
+	if (ctrl->first_req == NULL) {
+		cfglu_unlock(ctrl->info_list_lock);
+		return NULL;
+	}
+
+	if (cfctrl_req_eq(req, ctrl->first_req)) {
+		ret = ctrl->first_req;
+		cfglu_atomic_set(ctrl->rsp_seq_no,
+				 ctrl->first_req->sequence_no);
+		ctrl->first_req = ctrl->first_req->next;
+		cfglu_unlock(ctrl->info_list_lock);
+		return ret;
+	}
+
+	CFLOG_WARN(("cfctrl: Requests are not received in order/matching\n"));
+
+	p = ctrl->first_req;
+
+	while (p->next != NULL) {
+		if (cfctrl_req_eq(req, p->next)) {
+			ret = p->next;
+			cfglu_atomic_set(ctrl->rsp_seq_no,
+					 p->next->sequence_no);
+			p = p->next;
+			cfglu_unlock(ctrl->info_list_lock);
+			return ret;
+		}
+		p = p->next;
+	}
+	cfglu_unlock(ctrl->info_list_lock);
+	return NULL;
+}
+
+/* Compare and remove old requests based on sequence no. */
+void cfctrl_prune_req(struct cfctrl *ctrl)
+{
+	struct cfctrl_request_info *p;
+	struct cfctrl_request_info *del;
+
+	cfglu_lock(ctrl->info_list_lock);
+	if (ctrl->first_req == NULL) {
+		cfglu_unlock(ctrl->info_list_lock);
+		return;
+	}
+
+	if (ctrl->first_req->sequence_no <
+	    cfglu_atomic_read(ctrl->req_seq_no)) {
+		del = ctrl->first_req;
+		ctrl->first_req = ctrl->first_req->next;
+		cfglu_free(del);
+	}
+	p = ctrl->first_req;
+	while (p->next != NULL) {
+		if (p->next->sequence_no <
+		    cfglu_atomic_read(ctrl->rsp_seq_no)) {
+			del = p->next;
+			p = p->next;
+			cfglu_atomic_set(ctrl->rsp_seq_no,
+					 ctrl->first_req->sequence_no);
+			cfglu_free(del);
+		}
+		p = p->next;
+	}
+	cfglu_unlock(ctrl->info_list_lock);
+}
+
+void cfctrl_set_respfuncs(struct layer *layer, struct cfctrl_rsp *respfuncs)
+{
+	struct cfctrl *this = container_obj(layer);
+	this->res = *respfuncs;
+}
+
+void cfctrl_set_dnlayer(struct layer *this, struct layer *dn)
+{
+	this->dn = dn;
+}
+
+void cfctrl_set_uplayer(struct layer *this, struct layer *up)
+{
+	this->up = up;
+}
+
+static struct transmt_info init_info(struct cfctrl *cfctrl)
+{
+	struct transmt_info info;
+	info.hdr_len = 0;
+	info.prio = 0;
+	info.channel_id = cfctrl->serv.layer.id;
+	info.phid = cfctrl->serv.phid;
+	return info;
+}
+
+void cfctrl_enum_req(struct layer *layer, uint8 physlinkid)
+{
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct transmt_info info = init_info(cfctrl);
+	int ret;
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	caif_assert(offsetof(struct cfctrl, serv.layer) == 0);
+	info.phid = physlinkid;
+	cfctrl->serv.phid = physlinkid;
+	cfpkt_addbdy(pkt, CFCTRL_CMD_ENUM);
+	cfpkt_addbdy(pkt, physlinkid);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, &info, pkt);
+	if (ret < 0) {
+		CFLOG_ERROR(("Could not transmit enum message\n"));
+		cfpkt_destroy(pkt);
+	}
+}
+
+void cfctrl_linkup_request(struct layer *layer, struct cfctrl_link_param *param,
+			   struct layer *user_layer)
+{
+	struct cfctrl *cfctrl = container_obj(layer);
+	uint32 tmp32;
+	uint16 tmp16;
+	uint8 tmp8;
+	int ret;
+	char utility_name[16];
+	struct cfctrl_request_info *req;
+	struct transmt_info info = init_info(cfctrl);
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	CFLOG_TRACE(("cfctrl: enter linkup_request\n"));
+
+	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_SETUP);
+	cfpkt_addbdy(pkt, (param->chtype << 4) + param->linktype);
+	cfpkt_addbdy(pkt, (param->priority << 3) + param->phyid);
+	cfpkt_addbdy(pkt, param->endpoint & 0x03);
+	CFLOG_TRACE2(("channel config: chtype:%d linktype:%d "
+		      "phyid:%d prio:%d endpoint:%d\n",
+		      param->chtype, param->linktype,
+		      param->phyid, param->priority, param->endpoint));
+	switch (param->linktype) {
+	case CFCTRL_SRV_VEI:
+		break;
+	case CFCTRL_SRV_VIDEO:
+		cfpkt_addbdy(pkt, (uint8) param->u.video.connid);
+		break;
+	case CFCTRL_SRV_DBG:
+		break;
+	case CFCTRL_SRV_DATAGRAM:
+		tmp32 = cfglu_cpu_to_le32(param->u.datagram.connid);
+		cfpkt_add_body(pkt, &tmp32, 4);
+		break;
+	case CFCTRL_SRV_RFM:
+		/* Construct a frame, convert DatagramConnectionID to network
+		 * format long and copy it out...
+		 */
+		tmp32 = cfglu_cpu_to_le32(param->u.rfm.connid);
+		cfpkt_add_body(pkt, &tmp32, 4);
+		/* Add volume name, including zero termination... */
+		cfpkt_add_body(pkt, param->u.rfm.volume,
+			       strlen(param->u.rfm.volume) + 1);
+		break;
+	case CFCTRL_SRV_UTIL:
+		tmp16 = cfglu_cpu_to_le16(param->u.utility.fifosize_kb);
+		cfpkt_add_body(pkt, &tmp16, 2);
+		tmp16 = cfglu_cpu_to_le16(param->u.utility.fifosize_bufs);
+		cfpkt_add_body(pkt, &tmp16, 2);
+		memset(utility_name, 0, sizeof(utility_name));
+		strncpy(utility_name, param->u.utility.name,
+			UTILITY_NAME_LENGTH - 1);
+		cfpkt_add_body(pkt, utility_name, UTILITY_NAME_LENGTH);
+		tmp8 = param->u.utility.paramlen;
+		cfpkt_add_body(pkt, &tmp8, 1);
+		cfpkt_add_body(pkt, param->u.utility.params,
+			       param->u.utility.paramlen);
+		CFLOG_TRACE2(("util config: kb:%d bufs:%d name:%s paramlen:%d"
+			      "param:0x%02x,%02x,%02x,%02x,%02x\n",
+			      param->u.utility.fifosize_kb,
+			      param->u.utility.fifosize_bufs,
+			      utility_name,
+			      param->u.utility.paramlen,
+			      param->u.utility.params[0],
+			      param->u.utility.params[1],
+			      param->u.utility.params[2],
+			      param->u.utility.params[3],
+			      param->u.utility.params[4]));
+		break;
+	default:
+		CFLOG_ERROR(("CAIF: Request setup of invalid link type = %d\n",
+			     param->linktype));
+	}
+	req = cfglu_alloc(sizeof(*req));
+	memset(req, 0, sizeof(*req));
+	req->client_layer = user_layer;
+	req->cmd = CFCTRL_CMD_LINK_SETUP;
+	req->param = *param;
+	cfctrl_insert_req(cfctrl, req);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, &info, pkt);
+	if (ret < 0) {
+		CFLOG_ERROR(("cfctl: Could not transmit linksetup request\n"));
+		cfpkt_destroy(pkt);
+	}
+}
+
+int cfctrl_linkdown_req(struct layer *layer, uint8 channelid,
+				struct layer *client)
+{
+	int ret;
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	struct transmt_info info = init_info(cfctrl);
+	cfctrl_insert_req2(cfctrl, CFCTRL_CMD_LINK_DESTROY, channelid, client);
+	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_DESTROY);
+	cfpkt_addbdy(pkt, channelid);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, &info, pkt);
+	if (ret < 0) {
+		CFLOG_ERROR(("cfctl: Could not transmit link-down request\n"));
+		cfpkt_destroy(pkt);
+	}
+	return ret;
+}
+
+void cfctrl_sleep_req(struct layer *layer)
+{
+	int ret;
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	struct transmt_info info = init_info(cfctrl);
+	cfpkt_addbdy(pkt, CFCTRL_CMD_SLEEP);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, &info, pkt);
+	if (ret < 0)
+		cfpkt_destroy(pkt);
+}
+
+void cfctrl_wake_req(struct layer *layer)
+{
+	int ret;
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	struct transmt_info info = init_info(cfctrl);
+	cfpkt_addbdy(pkt, CFCTRL_CMD_WAKE);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, &info, pkt);
+	if (ret < 0)
+		cfpkt_destroy(pkt);
+}
+
+void cfctrl_getstartreason_req(struct layer *layer)
+{
+	int ret;
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	struct transmt_info info = init_info(cfctrl);
+	cfpkt_addbdy(pkt, CFCTRL_CMD_START_REASON);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, &info, pkt);
+	if (ret < 0)
+		cfpkt_destroy(pkt);
+}
+
+void cfctrl_setmode_req(struct layer *layer, uint8 mode)
+{
+	int ret;
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	struct transmt_info info = init_info(cfctrl);
+	cfpkt_addbdy(pkt, CFCTRL_CMD_RADIO_SET);
+	cfpkt_addbdy(pkt, mode);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, &info, pkt);
+	if (ret < 0)
+		cfpkt_destroy(pkt);
+}
+
+static int cfctrl_recv(struct layer *layer, struct cfpkt *pkt)
+{
+	uint8 cmdrsp;
+	uint8 cmd;
+	int ret = -1;
+	uint16 tmp16;
+	uint8 len;
+	uint8 param[255];
+	uint8 linkid;
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct cfctrl_request_info rsp, *req;
+
+	CFLOG_TRACE(("cfctrl: enter cfctrl_recv\n"));
+
+	(void) cfpkt_extr_head(pkt, &cmdrsp, 1);
+	cmd = cmdrsp & CFCTRL_CMD_MASK;
+	if (cmd != CFCTRL_CMD_LINK_ERR
+	    && CFCTRL_RSP_BIT != (CFCTRL_RSP_BIT & cmdrsp)) {
+		if (handle_loop(cfctrl, cmd, pkt) == CAIF_FAILURE) {
+			CFLOG_ERROR(("CAIF Protocol error:"
+					"Response bit not set\n"));
+			goto error;
+		}
+	}
+
+	switch (cmd) {
+	case CFCTRL_CMD_LINK_SETUP:
+		{
+			enum cfctrl_srv serv;
+			enum cfctrl_srv servtype;
+			uint8 endpoint;
+			uint8 physlinkid;
+			uint8 prio;
+			uint8 tmp;
+			uint32 tmp32;
+			uint8 *cp;
+			int i;
+			struct cfctrl_link_param linkparam;
+			memset(&linkparam, 0, sizeof(linkparam));
+
+			cfpkt_extr_head(pkt, &tmp, 1);
+
+			serv = tmp & CFCTRL_SRV_MASK;
+			linkparam.linktype = serv;
+
+			servtype = tmp >> 4;
+			linkparam.chtype = servtype;
+
+			cfpkt_extr_head(pkt, &tmp, 1);
+			physlinkid = tmp & 0x07;
+			prio = tmp >> 3;
+
+			linkparam.priority = prio;
+			linkparam.phyid = physlinkid;
+			cfpkt_extr_head(pkt, &endpoint, 1);
+			linkparam.endpoint = endpoint & 0x03;
+
+			switch (serv) {
+			case CFCTRL_SRV_VEI:
+			case CFCTRL_SRV_DBG:
+				/* Link ID */
+				cfpkt_extr_head(pkt, &linkid, 1);
+				break;
+			case CFCTRL_SRV_VIDEO:
+				cfpkt_extr_head(pkt, &tmp, 1);
+				linkparam.u.video.connid = tmp;
+				/* Link ID */
+				cfpkt_extr_head(pkt, &linkid, 1);
+				break;
+
+			case CFCTRL_SRV_DATAGRAM:
+				cfpkt_extr_head(pkt, &tmp32, 4);
+				linkparam.u.datagram.connid =
+				    cfglu_le32_to_cpu(tmp32);
+				/* Link ID */
+				cfpkt_extr_head(pkt, &linkid, 1);
+				break;
+			case CFCTRL_SRV_RFM:
+				/* Construct a frame, convert
+				 * DatagramConnectionID
+				 * to network format long and copy it out...
+				 */
+				cfpkt_extr_head(pkt, &tmp32, 4);
+				linkparam.u.rfm.connid =
+				  cfglu_le32_to_cpu(tmp32);
+				cp = (uint8 *) linkparam.u.rfm.volume;
+				for (cfpkt_extr_head(pkt, &tmp, 1);
+				     cfpkt_more(pkt) && tmp != '\0';
+				     cfpkt_extr_head(pkt, &tmp, 1))
+					*cp++ = tmp;
+				*cp = '\0';
+
+				/* Link ID */
+				cfpkt_extr_head(pkt, &linkid, 1);
+
+				break;
+			case CFCTRL_SRV_UTIL:
+				/* Construct a frame, convert
+				 * DatagramConnectionID
+				 * to network format long and copy it out...
+				 */
+				/* Fifosize KB */
+				cfpkt_extr_head(pkt, &tmp16, 2);
+				linkparam.u.utility.fifosize_kb =
+				    cfglu_le16_to_cpu(tmp16);
+				/* Fifosize bufs */
+				cfpkt_extr_head(pkt, &tmp16, 2);
+				linkparam.u.utility.fifosize_bufs =
+				    cfglu_le16_to_cpu(tmp16);
+				/* name */
+				cp = (uint8 *) linkparam.u.utility.name;
+				caif_assert(sizeof(linkparam.u.utility.name)
+					     >= UTILITY_NAME_LENGTH);
+				for (i = 0;
+				     i < UTILITY_NAME_LENGTH
+				     && cfpkt_more(pkt); i++) {
+					cfpkt_extr_head(pkt, &tmp, 1);
+					*cp++ = tmp;
+				}
+				/* Length */
+				cfpkt_extr_head(pkt, &len, 1);
+				linkparam.u.utility.paramlen = len;
+				/* Param Data */
+				cp = linkparam.u.utility.params;
+				while (cfpkt_more(pkt) && len--) {
+					cfpkt_extr_head(pkt, &tmp, 1);
+					*cp++ = tmp;
+				}
+				/* Link ID */
+				cfpkt_extr_head(pkt, &linkid, 1);
+				/* Length */
+				cfpkt_extr_head(pkt, &len, 1);
+				/* Param Data */
+				cfpkt_extr_head(pkt, &param, len);
+				break;
+			default:
+				CFLOG_ERROR(("cfctrl_rec:Request setup "
+					     "- invalid link type (%d)",
+					     serv));
+				goto error;
+			}
+			if (cfpkt_erroneous(pkt)) {
+				CFLOG_ERROR(("cfctrl: Packet is erroneous!"));
+				goto error;
+			}
+			CFLOG_TRACE(("cfctrl: success parsing linksetup_rsp"));
+			rsp.cmd = cmd;
+			rsp.param = linkparam;
+			req = cfctrl_remove_req(cfctrl, &rsp);
+
+			if (CFCTRL_ERR_BIT == (CFCTRL_ERR_BIT & cmdrsp)) {
+				CFLOG_ERROR(("CaifChannel:Invalid O/E bit "
+					     "on CAIF control channel"));
+				cfctrl->res.reject_rsp(cfctrl->serv.layer.up,
+						       0,
+						       req ? req->client_layer
+						       : NULL);
+			} else {
+				cfctrl->res.linksetup_rsp(cfctrl->serv.
+							  layer.up, linkid,
+							  serv, physlinkid,
+							  req ? req->
+							  client_layer : NULL);
+			}
+
+			if (req != NULL)
+				cfglu_free(req);
+		}
+		break;
+	case CFCTRL_CMD_LINK_DESTROY:
+		cfpkt_extr_head(pkt, &linkid, 1);
+		rsp.cmd = cmd;
+		rsp.channel_id = linkid;
+		req = cfctrl_remove_req(cfctrl, &rsp);
+		cfctrl->res.linkdestroy_rsp(cfctrl->serv.layer.up, linkid,
+					    req ? req->client_layer : NULL);
+		if (req != NULL)
+			cfglu_free(req);
+		break;
+	case CFCTRL_CMD_LINK_ERR:
+		CFLOG_ERROR(("cfctrl: Frame Error Indication received \n"));
+		cfctrl->res.linkerror_ind();
+		break;
+	case CFCTRL_CMD_ENUM:
+		cfctrl->res.enum_rsp();
+		break;
+	case CFCTRL_CMD_SLEEP:
+		cfctrl->res.sleep_rsp();
+		break;
+	case CFCTRL_CMD_WAKE:
+		cfctrl->res.wake_rsp();
+		break;
+	case CFCTRL_CMD_LINK_RECONF:
+		cfctrl->res.restart_rsp();
+		break;
+	case CFCTRL_CMD_RADIO_SET:
+		cfctrl->res.radioset_rsp();
+		break;
+	default:
+		CFLOG_ERROR(("CAIF: Unrecognized Control Frame\n"));
+		goto error;
+		break;
+	}
+	ret = 0;
+error:
+	cfpkt_destroy(pkt);
+	return ret;
+}
+
+static void cfctrl_ctrlcmd(struct layer *layr, enum caif_ctrlcmd ctrl,
+				int phyid)
+{
+	struct cfctrl *this = container_obj(layr);
+	CFLOG_ENTER(("\n"));
+	switch (ctrl) {
+	case _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND:
+	case CAIF_CTRLCMD_FLOW_OFF_IND:
+		cfglu_lock(this->info_list_lock);
+		if (this->first_req != NULL) {
+			CFLOG_WARN(("cfctrl:"
+				    "Received flow off in control layer"));
+		}
+		cfglu_unlock(this->info_list_lock);
+		break;
+	default:
+		break;
+	}
+	CFLOG_EXIT(("\n"));
+}
+
+#ifndef CAIF_NO_LOOP
+int handle_loop(struct cfctrl *ctrl, int cmd, struct cfpkt *pkt)
+{
+	uint8 linkid, linktype, tmp;
+	switch (cmd) {
+	case CFCTRL_CMD_LINK_SETUP:
+		cfglu_lock(ctrl->loop_linkid_lock);
+		for (linkid = 0x1; linkid < 255; linkid++) {
+			if (!ctrl->loop_linkused[linkid]) {
+				ctrl->loop_linkused[linkid] = 1;
+				break;
+			}
+		}
+		if (linkid == 255) {
+			CFLOG_TRACE(("cfctrl_receive: loopback"
+					" no free link id's\n"));
+		}
+		CFLOG_TRACE(("cfcntrl_receive: setup loopback"
+				"linkid = %d\n", linkid));
+		cfpkt_add_trail(pkt, &linkid, 1);
+		cfglu_unlock(ctrl->loop_linkid_lock);
+		cfpkt_peek_head(pkt, &linktype, 1);
+		if (linktype ==  CFCTRL_SRV_UTIL) {
+			tmp = 0x01;
+			cfpkt_add_trail(pkt, &tmp, 1);
+			cfpkt_add_trail(pkt, &tmp, 1);
+		}
+		break;
+
+	case CFCTRL_CMD_LINK_DESTROY:
+		cfglu_lock(ctrl->loop_linkid_lock);
+		(void) cfpkt_peek_head(pkt, &linkid, 1);
+		CFLOG_TRACE(("cfctrl_receive: destroy "
+				"linkid = %d\n", linkid));
+		ctrl->loop_linkused[linkid] = 0;
+		cfglu_unlock(ctrl->loop_linkid_lock);
+		break;
+	default:
+		break;
+	}
+	return CAIF_SUCCESS;
+}
+#endif
diff --git a/net/caif/generic/cfdgml.c b/net/caif/generic/cfdgml.c
new file mode 100644
index 0000000..54be0b4
--- /dev/null
+++ b/net/caif/generic/cfdgml.c
@@ -0,0 +1,115 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfsrvl.h>
+#include <net/caif/generic/cfpkt.h>
+
+#define container_obj(layr) ((struct cfsrvl *) layr)
+
+#define DGM_CMD_BIT  0x80
+#define DGM_FLOW_OFF 0x81
+#define DGM_FLOW_ON  0x80
+#define DGM_CTRL_PKT_SIZE 1
+
+static int cfdgml_receive(struct layer *layr, struct cfpkt *pkt);
+static int cfdgml_transmit(struct layer *layr, struct transmt_info *dummy,
+				struct cfpkt *pkt);
+
+struct layer *cfdgml_create(uint8 channel_id, uint8 phyid)
+{
+	struct cfsrvl *dgm = cfglu_alloc(sizeof(struct cfsrvl));
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+	CFLOG_ENTER(("\n"));
+	memset(dgm, 0, sizeof(struct cfsrvl));
+	cfsrvl_init(dgm, channel_id, phyid);
+	dgm->layer.receive = cfdgml_receive;
+	dgm->layer.transmit = cfdgml_transmit;
+	snprintf(dgm->layer.name, CAIF_LAYER_NAME_SZ - 1, "dgm%d", channel_id);
+	dgm->layer.name[CAIF_LAYER_NAME_SZ - 1] = '\0';
+	CFLOG_EXIT(("\n"));
+	return &dgm->layer;
+}
+
+static int cfdgml_receive(struct layer *layr, struct cfpkt *pkt)
+{
+	uint8 cmd = -1;
+	uint8 dgmhdr[3];
+	int ret;
+	caif_assert(layr->up != NULL);
+	caif_assert(layr->receive != NULL);
+	caif_assert(layr->ctrlcmd != NULL);
+	CFLOG_ENTER(("\n"));
+
+	if (!cfpkt_extr_head(pkt, &cmd, 1)) {
+		CFLOG_ERROR(("cfdgml: Packet is erroneous!\n"));
+		cfpkt_destroy(pkt);
+		CFLOG_EXIT(("\n"));
+		return CFGLU_EPROTO;
+	}
+
+	if ((cmd & DGM_CMD_BIT) == 0) {
+		if (!cfpkt_extr_head(pkt, &dgmhdr, 3)) {
+			CFLOG_ERROR(("cfdgml: Packet is erroneous!\n"));
+			cfpkt_destroy(pkt);
+			return CFGLU_EPROTO;
+		}
+		ret = layr->up->receive(layr->up, pkt);
+		CFLOG_EXIT(("\n"));
+		return ret;
+	}
+
+	switch (cmd) {
+	case DGM_FLOW_OFF:	/* FLOW OFF */
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_FLOW_OFF_IND, 0);
+		cfpkt_destroy(pkt);
+		CFLOG_EXIT(("\n"));
+		return 0;
+	case DGM_FLOW_ON:	/* FLOW ON */
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_FLOW_ON_IND, 0);
+		cfpkt_destroy(pkt);
+		CFLOG_EXIT(("\n"));
+		return 0;
+	default:
+		cfpkt_destroy(pkt);
+		CFLOG_ERROR(("cfdgml: Unknown datagram control %d (0x%x)\n",
+			     cmd, cmd));
+		CFLOG_EXIT(("\n"));
+		return CFGLU_EPROTO;
+	}
+	CFLOG_EXIT(("\n"));
+}
+
+static int cfdgml_transmit(struct layer *layr, struct transmt_info *dummy,
+				struct cfpkt *pkt)
+{
+	uint32 zero = 0;
+	struct transmt_info info;
+	struct cfsrvl *service = container_obj(layr);
+	int ret;
+	CFLOG_ENTER(("\n"));
+	if (!cfsrvl_ready(service, &ret))
+		return ret;
+
+	cfpkt_add_head(pkt, &zero, 4);
+
+	/* Add info for MUX-layer to route the packet out. */
+	info.channel_id = service->layer.id;
+	info.phid = service->phid;
+	/* To optimize alignment, we add up the size of CAIF header
+	 * before payload.
+	 */
+	info.hdr_len = 4;
+	ret = layr->dn->transmit(layr->dn, &info, pkt);
+	if (ret < 0) {
+		uint32 tmp32;
+		cfpkt_extr_head(pkt, &tmp32, 4);
+	}
+	CFLOG_EXIT(("\n"));
+	return ret;
+}
diff --git a/net/caif/generic/cffrml.c b/net/caif/generic/cffrml.c
new file mode 100644
index 0000000..2649da3
--- /dev/null
+++ b/net/caif/generic/cffrml.c
@@ -0,0 +1,149 @@
+/*
+ * Caif Framing Layer.
+ *
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#define container_obj(layr) cfglu_container_of(layr, struct cffrml, layer)
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/fcs.h>
+#include <net/caif/generic/cffrml.h>
+
+struct cffrml {
+	struct layer layer;
+	bool dofcs;		/* !< FCS active */
+};
+
+static int cffrml_receive(struct layer *layr, struct cfpkt *pkt);
+static int cffrml_transmit(struct layer *layr, struct transmt_info *info,
+				struct cfpkt *pkt);
+static void cffrml_ctrlcmd(struct layer *layr, enum caif_ctrlcmd ctrl,
+				int phyid);
+
+uint32 cffrml_rcv_error;
+uint32 cffrml_rcv_checsum_error;
+struct layer *cffrml_create(uint16 phyid, bool use_fcs)
+{
+	struct cffrml *this = cfglu_alloc(sizeof(struct cffrml));
+	caif_assert(offsetof(struct cffrml, layer) == 0);
+
+	memset(this, 0, sizeof(struct layer));
+	this->layer.receive = cffrml_receive;
+	this->layer.transmit = cffrml_transmit;
+	this->layer.ctrlcmd = cffrml_ctrlcmd;
+	snprintf(this->layer.name, CAIF_LAYER_NAME_SZ, "frm%d", phyid);
+	this->dofcs = use_fcs;
+	this->layer.id = phyid;
+	CFLOG_TRACE(("cffrml: FCS=%d\n", use_fcs));
+	return (struct layer *) this;
+}
+
+void cffrml_set_uplayer(struct layer *this, struct layer *up)
+{
+	this->up = up;
+}
+
+void cffrml_set_dnlayer(struct layer *this, struct layer *dn)
+{
+	this->dn = dn;
+}
+
+static uint16 cffrml_checksum(uint16 chks, void *buf, uint16 len)
+{
+	/* FIXME: FCS should be moved to glue in order to use OS-Specific
+	 * solutions
+	 */
+	return fcs16(chks, buf, len);
+}
+
+static int cffrml_receive(struct layer *layr, struct cfpkt *pkt)
+{
+	uint16 tmp;
+	uint16 len;
+	uint16 hdrchks;
+	uint16 pktchks;
+	struct cffrml *this;
+	this = container_obj(layr);
+
+	(void) cfpkt_extr_head(pkt, &tmp, 2);
+	len = cfglu_le16_to_cpu(tmp);
+
+	/* Subtract for FCS on length if FCS is not used. */
+	if (!this->dofcs)
+		len -= 2;
+
+	if (cfpkt_setlen(pkt, len) < 0) {
+		++cffrml_rcv_error;
+		CFLOG_ERROR(("cffrml: Framing length error (%d)\n", len));
+		cfpkt_destroy(pkt);
+		return CFGLU_EPKT;
+	}
+	/* Don't do extract if FCS is false, rather do setlen - then we don't
+	 * get a cache-miss.
+	 */
+	if (this->dofcs) {
+		(void) cfpkt_extr_trail(pkt, &tmp, 2);
+		hdrchks = cfglu_le16_to_cpu(tmp);
+		pktchks = cfpkt_iterate(pkt, cffrml_checksum, 0xffff);
+		if (pktchks != hdrchks) {
+			cfpkt_add_trail(pkt, &tmp, 2);
+			++cffrml_rcv_error;
+			++cffrml_rcv_checsum_error;
+			CFLOG_ERROR(("cffrml: Frame checksum error "
+				     "(0x%x != 0x%x)\n", hdrchks, pktchks));
+			return CFGLU_EFCS;
+		}
+	}
+	if (cfpkt_erroneous(pkt)) {
+		++cffrml_rcv_error;
+		CFLOG_ERROR(("cffrml: Packet is erroneous!\n"));
+		cfpkt_destroy(pkt);
+		return CFGLU_EPKT;
+	}
+	return layr->up->receive(layr->up, pkt);
+}
+
+static int cffrml_transmit(struct layer *layr, struct transmt_info *info,
+					struct cfpkt *pkt)
+{
+	int tmp;
+	uint16 chks;
+	uint16 len;
+	int ret;
+	struct cffrml *this = container_obj(layr);
+	if (this->dofcs) {
+		chks = cfpkt_iterate(pkt, cffrml_checksum, 0xffff);
+		tmp = cfglu_cpu_to_le16(chks);
+		cfpkt_add_trail(pkt, &tmp, 2);
+	} else {
+		cfpkt_pad_trail(pkt, 2);
+	}
+
+	len = cfpkt_getlen(pkt);
+	tmp = cfglu_cpu_to_le16(len);
+	cfpkt_add_head(pkt, &tmp, 2);
+	info->hdr_len += 2;
+	if (cfpkt_erroneous(pkt)) {
+		CFLOG_ERROR(("cffrml: Packet is erroneous!\n"));
+		return CFGLU_EPROTO;
+	}
+	ret = layr->dn->transmit(layr->dn, info, pkt);
+	if (ret < 0) {
+		/* Remove header on faulty packet. */
+		cfpkt_extr_head(pkt, &tmp, 2);
+	}
+	return ret;
+}
+
+static void cffrml_ctrlcmd(struct layer *layr, enum caif_ctrlcmd ctrl,
+					int phyid)
+{
+	if (layr->up->ctrlcmd)
+		layr->up->ctrlcmd(layr->up, ctrl, layr->id);
+}
diff --git a/net/caif/generic/cflist.c b/net/caif/generic/cflist.c
new file mode 100644
index 0000000..b7b541f
--- /dev/null
+++ b/net/caif/generic/cflist.c
@@ -0,0 +1,88 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfglue.h>
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
+/** Adds an element from the queue. */
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
+bool cflst_put(struct layer **lst, uint8 id, struct layer *node)
+{
+	if (cflst_get(lst, id) != NULL) {
+		CFLOG_ERROR(("CAIF: cflst_put duplicate key\n"));
+		return false;
+	}
+	node->id = id;
+	cflst_insert(lst, node);
+	return true;
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
diff --git a/net/caif/generic/cfloopcfg.c b/net/caif/generic/cfloopcfg.c
new file mode 100644
index 0000000..4102122
--- /dev/null
+++ b/net/caif/generic/cfloopcfg.c
@@ -0,0 +1,103 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cflst.h>
+#include <net/caif/generic/cfctrl.h>
+#include <net/caif/generic/cfmuxl.h>
+#include <net/caif/generic/cffrml.h>
+#include <net/caif/generic/cfspil.h>
+#include <net/caif/generic/cfserl.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <net/caif/generic/cfshml.h>
+#include <net/caif/generic/cfmsll.h>
+#include <net/caif/generic/cfusbl.h>
+#include <net/caif/generic/cfloopcfg.h>
+
+struct cfloopcfg {
+	struct layer *loop;
+
+};
+
+struct cfloopcfg *cfloopcfg_create(void)
+{
+	struct cfloopcfg *this;
+	this = cfglu_alloc(sizeof(struct cfloopcfg));
+	memset(this, 0, sizeof(struct cfloopcfg));
+	this->loop = cflooplayer_create();
+	return this;
+}
+EXPORT_SYMBOL(cfloopcfg_create);
+
+void cfloopcfg_add_phy_layer(struct cfloopcfg *cnfg,
+			     enum cfcnfg_phy_type phy_type,
+			     struct layer *phy_layer)
+{
+	if (phy_type == CFPHYTYPE_SERIAL) {
+		struct layer *frml = cffrml_create(1, true);
+		struct layer *cfser;
+		cfser = cfserl_create(phy_type, 0, serial_use_stx);
+		layer_set_dn(cnfg->loop, frml);
+		layer_set_up(frml, cnfg->loop);
+		layer_set_dn(frml, cfser);
+		layer_set_up(cfser, frml);
+		layer_set_dn(cfser, phy_layer);
+		layer_set_up(phy_layer, cfser);
+	}
+	if (phy_type == CFPHYTYPE_SPI) {
+		struct cfspipad padopt;
+		struct layer *frml = cffrml_create(1, false);
+		struct layer *cfspi;
+		/* The loop device has to invert the padding options. */
+		padopt.up_head_align = (uint16)spi_down_head_align;
+		padopt.up_tail_align = (uint16)spi_down_tail_align;
+		padopt.down_head_align = (uint16)spi_up_head_align;
+		padopt.down_tail_align = (uint16)spi_up_tail_align;
+		cfspi = cfspil_create(phy_type, 0, padopt);
+		layer_set_dn(cnfg->loop, frml);
+		layer_set_up(frml, cnfg->loop);
+		layer_set_dn(frml, cfspi);
+		layer_set_up(cfspi, frml);
+		layer_set_dn(cfspi, phy_layer);
+		layer_set_up(phy_layer, cfspi);
+	}
+	if (phy_type == CFPHYTYPE_SHM) {
+		struct layer *frml = cffrml_create(1, false);
+		struct layer *cfshm;
+		cfshm = cfshml_create(phy_type, 0);
+		layer_set_dn(cnfg->loop, frml);
+		layer_set_up(frml, cnfg->loop);
+		layer_set_dn(frml, cfshm);
+		layer_set_up(cfshm, frml);
+		layer_set_dn(cfshm, phy_layer);
+		layer_set_up(phy_layer, cfshm);
+	}
+	if (phy_type == CFPHYTYPE_MSL) {
+		struct layer *frml = cffrml_create(1, false);
+		struct layer *cfmsl;
+		cfmsl = cfmsll_create(phy_type, 0);
+		layer_set_dn(cnfg->loop, frml);
+		layer_set_up(frml, cnfg->loop);
+		layer_set_dn(frml, cfmsl);
+		layer_set_up(cfmsl, frml);
+		layer_set_dn(cfmsl, phy_layer);
+		layer_set_up(phy_layer, cfmsl);
+	}
+	if (phy_type == CFPHYTYPE_USB) {
+		struct layer *frml = cffrml_create(1, false);
+		struct layer *cfusb;
+		cfusb = cfusbl_create(phy_type, 0);
+		layer_set_dn(cnfg->loop, frml);
+		layer_set_up(frml, cnfg->loop);
+		layer_set_dn(frml, cfusb);
+		layer_set_up(cfusb, frml);
+		layer_set_dn(cfusb, phy_layer);
+		layer_set_up(phy_layer, cfusb);
+	}
+}
+EXPORT_SYMBOL(cfloopcfg_add_phy_layer);
diff --git a/net/caif/generic/cflooplayer.c b/net/caif/generic/cflooplayer.c
new file mode 100644
index 0000000..f989120
--- /dev/null
+++ b/net/caif/generic/cflooplayer.c
@@ -0,0 +1,109 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cflst.h>
+#include <net/caif/generic/cfsrvl.h>
+#include <net/caif/generic/cffrml.h>
+#include <net/caif/generic/cfctrl.h>
+
+static int cflooplayer_receive(struct layer *layr, struct cfpkt *pkt);
+static uint8 linkid;
+static int linkused[256];
+static cfglu_lock_t linkid_lock;
+
+struct layer *cflooplayer_create(void)
+{
+	struct layer *this = cfglu_alloc(sizeof(struct layer));
+	memset(this, 0, sizeof(struct layer));
+	this->receive = cflooplayer_receive;
+	cfglu_init_lock(linkid_lock);
+	snprintf(this->name, CAIF_LAYER_NAME_SZ, "loop1");
+	return this;
+}
+
+static int cflooplayer_receive(struct layer *layr, struct cfpkt *inpkt)
+{
+	uint8 id;
+	struct transmt_info info;
+	uint8 *buf;
+	uint16 pktlen;
+	struct cfpkt *pkt;
+	int ret;
+	struct caif_packet_funcs f = cfpkt_get_packet_funcs();
+	memset(&info, 0, sizeof(info));
+	pktlen = cfpkt_getlen(inpkt);
+	ret = f.cfpkt_raw_extract(inpkt, (void **) &buf, pktlen);
+	caif_assert(ret > 0);
+	pkt = f.cfpkt_create_recv_pkt(buf, pktlen);
+	cfpkt_destroy(inpkt);
+	(void) cfpkt_extr_head(pkt, &id, 1);
+	if (id != 0) {
+		/* This is not a control packet, so just loop it. */
+		cfpkt_add_head(pkt, &id, 1);
+	} else {
+		/* This is a control packet. */
+		uint8 tmp;
+		uint8 cmdrsp;
+		uint8 cmd;
+		uint8 linktype = 0;
+
+		(void) cfpkt_extr_head(pkt, &cmdrsp, 1);
+		cmd = cmdrsp & CFCTRL_CMD_MASK;
+
+		switch (cmd) {
+		case CFCTRL_CMD_LINK_SETUP:
+			{
+				caif_assert(!cfpkt_erroneous(pkt));
+				caif_assert(cfpkt_more(pkt));
+				cfpkt_peek_head(pkt, &linktype, 1);
+				caif_assert(!cfpkt_erroneous(pkt));
+				cmdrsp |= CFCTRL_RSP_BIT;
+				cfpkt_add_head(pkt, &cmdrsp, 1);
+				cfpkt_add_head(pkt, &id, 1);
+				cfglu_lock(linkid_lock);
+				for (linkid = 0x41; linkid < 255; linkid++) {
+					if (!linkused[linkid]) {
+						linkused[linkid] = 1;
+						break;
+					}
+				}
+				if (linkid == 255) {
+					CFLOG_WARN(("cflooplayer_receive:"
+						    " no free link id's\n"));
+				}
+				CFLOG_WARN(("cflooplayer_receive: setup "
+					    "linkid = %d\n", linkid));
+				cfpkt_add_trail(pkt, &linkid, 1);
+				cfglu_unlock(linkid_lock);
+
+				if (linktype == 0x06) {
+					tmp = 0x01;
+					cfpkt_add_trail(pkt, &tmp, 1);
+					cfpkt_add_trail(pkt, &tmp, 1);
+				}
+				break;
+			}
+		case CFCTRL_CMD_LINK_DESTROY:
+			cfglu_lock(linkid_lock);
+			(void) cfpkt_peek_head(pkt, &linkid, 1);
+			CFLOG_WARN(("cflooplayer_receive: destroy "
+				    "linkid = %d\n", linkid));
+			linkused[linkid] = 0;
+			cfglu_unlock(linkid_lock);
+			/* fallthrough */
+		default:
+			cmdrsp |= CFCTRL_RSP_BIT;
+			cfpkt_add_head(pkt, &cmdrsp, 1);
+			cfpkt_add_head(pkt, &id, 1);
+			break;
+		}
+	}
+	return layr->dn->transmit(layr->dn, &info, pkt);
+}
diff --git a/net/caif/generic/cfmsll.c b/net/caif/generic/cfmsll.c
new file mode 100644
index 0000000..588fbd7
--- /dev/null
+++ b/net/caif/generic/cfmsll.c
@@ -0,0 +1,52 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfmsll.h>
+
+static int cfmsll_receive(struct layer *layr, struct cfpkt *pkt);
+static int cfmsll_transmit(struct layer *layr, struct transmt_info *info,
+				struct cfpkt *pkt);
+
+struct layer *cfmsll_create(int type, int instance)
+{
+	struct layer *this = cfglu_alloc(sizeof(struct layer));
+	memset(this, 0, sizeof(struct layer));
+	this->receive = cfmsll_receive;
+	this->transmit = cfmsll_transmit;
+	this->type = type;
+	snprintf(this->name, CAIF_LAYER_NAME_SZ - 1, "msl%d", instance);
+	this->name[CAIF_LAYER_NAME_SZ-1] = '\0';
+	return this;
+}
+
+void cfmsll_set_uplayer(struct layer *this, struct layer *up)
+{
+	this->up = up;
+}
+
+void cfmsll_set_dnlayer(struct layer *this, struct layer *dn)
+{
+	this->dn = dn;
+}
+
+static int cfmsll_receive(struct layer *layr, struct cfpkt *pkt)
+{
+	/* Send the first part of the packet upwards. */
+	int ret = layr->up->receive(layr->up, pkt);
+	/* FCS error - don't delete the packet. */
+	if (ret == CFGLU_EFCS)
+		cfpkt_destroy(pkt);
+	return ret;
+}
+
+static int cfmsll_transmit(struct layer *layr, struct transmt_info *info,
+				struct cfpkt *pkt)
+{
+	return layr->dn->transmit(layr->dn, info, pkt);
+}
diff --git a/net/caif/generic/cfmuxl.c b/net/caif/generic/cfmuxl.c
new file mode 100644
index 0000000..5b2a2cc
--- /dev/null
+++ b/net/caif/generic/cfmuxl.c
@@ -0,0 +1,247 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cflst.h>
+#include <net/caif/generic/cfmuxl.h>
+#include <net/caif/generic/cfsrvl.h>
+#include <net/caif/generic/cffrml.h>
+
+#define container_obj(layr) cfglu_container_of(layr, struct cfmuxl, layer)
+
+#define CAIF_CTRL_CHANNEL 0
+#define UP_CACHE_SIZE 8
+#define DN_CACHE_SIZE 8
+
+struct cfmuxl {
+	struct layer layer;
+	struct layer *up_cache[UP_CACHE_SIZE];
+	struct layer *dn_cache[DN_CACHE_SIZE];
+	/*
+	 * Set when inserting or removing downwards layers.
+	 */
+	cfglu_lock_t transmit_lock;
+
+	/*
+	 * Set when inserting or removing upwards layers.
+	 */
+	cfglu_lock_t receive_lock;
+
+};
+
+static int cfmuxl_receive(struct layer *layr, struct cfpkt *pkt);
+static int cfmuxl_transmit(struct layer *layr, struct transmt_info *info,
+				struct cfpkt *pkt);
+static void cfmuxl_ctrlcmd(struct layer *layr, enum caif_ctrlcmd ctrl,
+				int phyid);
+static struct layer *get_up(struct cfmuxl *muxl, int id);
+
+struct layer *cfmuxl_create()
+{
+	struct cfmuxl *this = cfglu_alloc(sizeof(struct cfmuxl));
+	memset(this, 0, sizeof(*this));
+	this->layer.receive = cfmuxl_receive;
+	this->layer.transmit = cfmuxl_transmit;
+	this->layer.ctrlcmd = cfmuxl_ctrlcmd;
+	cfglu_init_lock(this->transmit_lock);
+	cfglu_init_lock(this->receive_lock);
+	snprintf(this->layer.name, CAIF_LAYER_NAME_SZ, "mux");
+	return &this->layer;
+}
+
+bool cfmuxl_set_uplayer(struct layer *layr, struct layer *up, uint8 linkid)
+{
+	bool ok;
+	struct cfmuxl *muxl = container_obj(layr);
+	CFLOG_ENTER(("layr:%p up:%p linkid:%d\n", (void *) layr, (void *) up,
+		     linkid));
+	cfglu_lock(muxl->receive_lock);
+	ok = cflst_put(&muxl->layer.up, linkid, up);
+	cfglu_unlock(muxl->receive_lock);
+	CFLOG_EXIT(("ok=%d\n", ok));
+	return ok;
+}
+
+bool cfmuxl_is_phy_inuse(struct layer *layr, uint8 phyid)
+{
+	struct layer *p;
+	struct cfmuxl *muxl = container_obj(layr);
+	bool match = false;
+	cfglu_lock(muxl->receive_lock);
+	CFLOG_ENTER(("\n"));
+
+	for (p = layr->up; p != NULL; p = p->next) {
+		if (cfsrvl_phyid_match(p, phyid)) {
+			match = true;
+			break;
+		}
+	}
+	cfglu_unlock(muxl->receive_lock);
+	CFLOG_EXIT(("\n"));
+	return match;
+}
+
+uint8 cfmuxl_get_phyid(struct layer *layr, uint8 channel_id)
+{
+	struct layer *up;
+	int phyid;
+	struct cfmuxl *muxl = container_obj(layr);
+	cfglu_lock(muxl->receive_lock);
+	CFLOG_ENTER(("\n"));
+	up = get_up(muxl, channel_id);
+	if (up != NULL)
+		phyid = cfsrvl_getphyid(up);
+	else
+		phyid = 0;
+	cfglu_unlock(muxl->receive_lock);
+	return phyid;
+}
+
+bool cfmuxl_set_dnlayer(struct layer *layr, struct layer *dn, uint8 phyid)
+{
+	bool ok;
+	struct cfmuxl *muxl = (struct cfmuxl *) layr;
+	CFLOG_ENTER(("\n"));
+	cfglu_lock(muxl->transmit_lock);
+	ok = cflst_put(&muxl->layer.dn, phyid, dn);
+	cfglu_unlock(muxl->transmit_lock);
+	CFLOG_EXIT(("\n"));
+	return ok;
+}
+
+struct layer *cfmuxl_remove_dnlayer(struct layer *layr, uint8 phyid)
+{
+	struct cfmuxl *muxl = container_obj(layr);
+	struct layer *dn;
+	CFLOG_ENTER(("\n"));
+	cfglu_lock(muxl->transmit_lock);
+	memset(muxl->dn_cache, 0, sizeof(muxl->dn_cache));
+	dn = cflst_del(&muxl->layer.dn, phyid);
+	caif_assert(dn != NULL);
+	cfglu_unlock(muxl->transmit_lock);
+	CFLOG_EXIT(("\n"));
+	return dn;
+}
+
+/* Invariant: lock is taken */
+static struct layer *get_up(struct cfmuxl *muxl, int id)
+{
+	struct layer *up;
+	int idx = id % UP_CACHE_SIZE;
+	CFLOG_ENTER(("id:%d\n", id));
+	up = muxl->up_cache[idx];
+	if (up == NULL || up->id != id) {
+		up = cflst_get(&muxl->layer.up, id);
+		muxl->up_cache[idx] = up;
+	}
+	CFLOG_EXIT(("id: %d up:%p", id, (void *) up));
+	return up;
+}
+
+/* Invariant: lock is taken */
+static struct layer *get_dn(struct cfmuxl *muxl, int id)
+{
+	struct layer *dn;
+	int idx = id % DN_CACHE_SIZE;
+	CFLOG_ENTER(("\n"));
+	dn = muxl->dn_cache[idx];
+	if (dn == NULL || dn->id != id) {
+		dn = cflst_get(&muxl->layer.dn, id);
+		muxl->dn_cache[idx] = dn;
+	}
+	CFLOG_EXIT(("\n"));
+	return dn;
+}
+
+struct layer *cfmuxl_remove_uplayer(struct layer *layr, uint8 id)
+{
+	struct layer *up;
+	struct cfmuxl *muxl = container_obj(layr);
+	CFLOG_ENTER(("\n"));
+	cfglu_lock(muxl->receive_lock);
+	memset(muxl->up_cache, 0, sizeof(muxl->up_cache));
+	up = cflst_del(&muxl->layer.up, id);
+	caif_assert(up != NULL);
+	cfglu_unlock(muxl->receive_lock);
+	CFLOG_EXIT(("\n"));
+	return up;
+}
+
+static int cfmuxl_receive(struct layer *layr, struct cfpkt *pkt)
+{
+	int ret;
+	struct cfmuxl *muxl = container_obj(layr);
+	uint8 id;
+	struct layer *up;
+	CFLOG_ENTER(("\n"));
+	if (!cfpkt_extr_head(pkt, &id, 1)) {
+		CFLOG_ERROR(("cfmuxl: erroneous Caif Packet\n"));
+		cfpkt_destroy(pkt);
+		CFLOG_EXIT(("error"));
+		return CFGLU_EPKT;
+	}
+
+	up = get_up(muxl, id);
+	if (up == NULL) {
+		CFLOG_WARN(("CAIF: Received data on unknown link ID = %d "
+			    "(0x%x)  up == NULL", id, id));
+		cfpkt_destroy(pkt);
+		/* Don't return ERROR, since modem misbehaves and sends out
+		 *  flow before linksetup response.
+		 */
+		CFLOG_EXIT(("error - unknown channel"));
+		return /* CFGLU_EPROT; */ CFGLU_EOK;
+	}
+
+	ret = up->receive(up, pkt);
+
+	CFLOG_EXIT(("\n"));
+
+	return ret;
+}
+
+static int cfmuxl_transmit(struct layer *layr, struct transmt_info *info,
+				struct cfpkt *pkt)
+{
+	int ret;
+	struct cfmuxl *muxl = container_obj(layr);
+	uint8 linkid;
+	struct layer *dn;
+	CFLOG_ENTER(("\n"));
+
+	dn = get_dn(muxl, info->phid);
+	if (dn == NULL) {
+		CFLOG_WARN(("CAIF: Send data on unknown phy ID = %d (0x%x)\n",
+			    info->phid, info->phid));
+		CFLOG_EXIT(("error"));
+		return CFGLU_ENOTCONN;
+	}
+	info->hdr_len += 1;
+	linkid = info->channel_id;
+	cfpkt_add_head(pkt, &linkid, 1);
+
+	ret = dn->transmit(dn, info, pkt);
+	if (ret < 0) {
+		/* Remove MUX protocol header upon error. */
+		cfpkt_extr_head(pkt, &linkid, 1);
+	}
+
+	CFLOG_EXIT(("\n"));
+	return ret;
+}
+
+static void cfmuxl_ctrlcmd(struct layer *layr, enum caif_ctrlcmd ctrl,
+				int phyid)
+{
+	struct layer *p;
+	struct cfmuxl *muxl = container_obj(layr);
+	for (p = muxl->layer.up; p != NULL; p = p->next) {
+		if (cfsrvl_phyid_match(p, phyid))
+			p->ctrlcmd(p, ctrl, phyid);
+	}
+}
diff --git a/net/caif/generic/cfpkt_skbuff.c b/net/caif/generic/cfpkt_skbuff.c
new file mode 100644
index 0000000..584c768
--- /dev/null
+++ b/net/caif/generic/cfpkt_skbuff.c
@@ -0,0 +1,726 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <linux/hardirq.h>
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfpkt.h>
+
+/* Maximum size of CAIF header */
+#define PKT_PREFIX CAIF_NEEDED_HEADROOM
+
+/* Maximum size of CAIF trailer */
+#define PKT_POSTFIX CAIF_NEEDED_TAILROOM
+
+#define PKT_LEN_WHEN_EXTENDING 128
+
+#define CFPKT_PRIV_DATA(pkt) ((struct cfpkt_priv_data *) (&pkt->skb.cb[0]))
+
+#define PKT_ERROR(pkt, errmsg) do {	   \
+    CFPKT_PRIV_DATA(pkt)->erronous = true; \
+    skb_reset_tail_pointer(&pkt->skb);	   \
+    CFLOG_WARN((errmsg));		   \
+  } while (0)
+
+#ifdef CFKPKT_PACKET_DUMP
+char pkt_debug_buffer[256];
+#define pkt_dump_debug(pkt) do {				     \
+    cfpkt_log_pkt((pkt), pkt_debug_buffer, 250);		     \
+    printk(KERN_DEBUG "%d: nonlinear: %s, fp=%s %s",		     \
+	__LINE__,						     \
+	skb_is_nonlinear(&(pkt)->skb) ? "true" : "false",	     \
+	CFPKT_PRIV_DATA((pkt))->fastpath ? "true" : "false",	     \
+	pkt_debug_buffer);					     \
+  } while (0)
+#else
+#define pkt_dump_debug(pkt)
+#endif
+
+struct cfpktq {
+	struct sk_buff_head head;
+	cfglu_atomic_t count;
+	spinlock_t lock;
+};
+
+/* struct cfpkt is (memory-wise) an sk_buff, but struct cfpkt is forward
+ * declared in cfpkt.h, so we do it this way (instead of typedef):
+ */
+struct cfpkt {
+	struct sk_buff skb;
+};
+
+/* Private data inside SKB */
+struct cfpkt_priv_data {
+	bool erronous;
+	/*!<Indicate fastpath; buffer has large enough head and tail room,
+	 * so boundary checks are skipped.
+	 */
+	bool fastpath;
+};
+
+cfglu_atomic_t cfpkt_packet_count;
+EXPORT_SYMBOL(cfpkt_packet_count);
+
+struct cfpkt *cfpkt_fromnative(enum caif_direction dir, void *nativepkt)
+{
+	struct cfpkt *pkt = (struct cfpkt *) nativepkt;
+
+	/* In Linux, "native" is always sk_buff: */
+	struct sk_buff *skb = (struct sk_buff *) nativepkt;
+
+	CFPKT_PRIV_DATA(pkt)->erronous = false;
+
+	/* Set Fastpath if we have enough head room */
+	if (likely(dir == CAIF_DIR_OUT && !skb_is_nonlinear(skb)
+		   && skb_headroom(skb) >= PKT_PREFIX
+		   && skb_tailroom(skb) >= PKT_POSTFIX))
+		CFPKT_PRIV_DATA(pkt)->fastpath = true;
+	else if (likely(dir == CAIF_DIR_IN && !skb_is_nonlinear(skb)
+			&& skb_headlen(skb) > PKT_PREFIX + PKT_POSTFIX))
+		CFPKT_PRIV_DATA(pkt)->fastpath = true;
+	else
+		CFPKT_PRIV_DATA(pkt)->fastpath = false;
+
+	CFLOG_TRACE3(("cfpkt_fromnative: fastpath=%s",
+		      CFPKT_PRIV_DATA(pkt)->fastpath ? "true" : "false"));
+	cfglu_atomic_inc(cfpkt_packet_count);
+
+	pkt_dump_debug(pkt);
+	return pkt;
+}
+EXPORT_SYMBOL(cfpkt_fromnative);
+
+void *cfpkt_tonative(struct cfpkt *pkt)
+{
+	/* In Linux, "native" is always sk_buff: */
+	pkt_dump_debug(pkt);
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
+	return (struct cfpkt *) skb;
+}
+
+inline struct cfpkt *cfpkt_create(uint16 len)
+{
+	struct cfpkt *r = cfpkt_create_pfx(len + PKT_POSTFIX, PKT_PREFIX);
+	CFPKT_PRIV_DATA(r)->fastpath = true;
+
+	pkt_dump_debug(r);
+	return r;
+}
+EXPORT_SYMBOL(cfpkt_create);
+
+void cfpkt_destroy(struct cfpkt *pkt)
+{
+	struct sk_buff *skb = (struct sk_buff *) pkt;
+	cfglu_atomic_dec(cfpkt_packet_count);
+	caif_assert(cfglu_atomic_read(cfpkt_packet_count) >= 0);
+	kfree_skb(skb);
+}
+EXPORT_SYMBOL(cfpkt_destroy);
+
+inline bool cfpkt_more(struct cfpkt *pkt)
+{
+	struct sk_buff *skb = (struct sk_buff *) pkt;
+	return skb->len > 0;
+}
+EXPORT_SYMBOL(cfpkt_more);
+
+bool cfpkt_peek_head(struct cfpkt *pkt, void *data, uint16 len)
+{
+	struct sk_buff *skb = (struct sk_buff *) pkt;
+	pkt_dump_debug(pkt);
+	if (likely(CFPKT_PRIV_DATA(pkt)->fastpath)) {
+		memcpy(data, skb->data, len);
+		pkt_dump_debug(pkt);
+		return true;
+	}
+	return cfpkt_extr_head(pkt, data, len) &&
+	    cfpkt_add_head(pkt, data, len);
+}
+EXPORT_SYMBOL(cfpkt_peek_head);
+
+bool cfpkt_extr_head(struct cfpkt *pkt, void *data, uint16 len)
+{
+	struct sk_buff *skb = (struct sk_buff *) pkt;
+	uint8 *from;
+	pkt_dump_debug(pkt);
+
+	if (unlikely(len > skb->len)) {
+		PKT_ERROR(pkt, "cfpkt_extr_head read beyond end of packet\n");
+		CFPKT_PRIV_DATA(pkt)->erronous = true;
+		return false;
+	}
+
+	if (unlikely(!(CFPKT_PRIV_DATA(pkt)->fastpath) &&
+		     (len > skb_headlen(skb)))) {
+		if (unlikely(skb_linearize(skb) != 0)) {
+			CFPKT_PRIV_DATA(pkt)->erronous = true;
+			return false;
+		}
+	}
+
+	from = skb_pull(skb, len);
+	from -= len;
+	memcpy(data, from, len);
+	pkt_dump_debug(pkt);
+	return true;
+}
+EXPORT_SYMBOL(cfpkt_extr_head);
+
+bool cfpkt_extr_trail(struct cfpkt *pkt, void *dta, uint16 len)
+{
+	struct sk_buff *skb = (struct sk_buff *) pkt;
+	uint8 *data = dta;
+	uint8 *from;
+	pkt_dump_debug(pkt);
+	if (unlikely(skb_linearize(skb) != 0)) {
+		CFPKT_PRIV_DATA(pkt)->erronous = true;
+		return false;
+	}
+	pkt_dump_debug(pkt);
+	if (unlikely(skb->data + len > skb_tail_pointer(skb))) {
+		PKT_ERROR(pkt, "cfpkt_extr_trail read beyond end of packet\n");
+		CFPKT_PRIV_DATA(pkt)->erronous = true;
+		return false;
+	}
+	from = skb_tail_pointer(skb) - len;
+	skb_trim(skb, skb->len - len);
+	pkt_dump_debug(pkt);
+	memcpy(data, from, len);
+	return true;
+}
+EXPORT_SYMBOL(cfpkt_extr_trail);
+
+bool cfpkt_pad_trail(struct cfpkt *pkt, uint16 len)
+{
+	return cfpkt_add_body(pkt, NULL, len);
+}
+EXPORT_SYMBOL(cfpkt_pad_trail);
+
+bool cfpkt_add_body(struct cfpkt *pkt, const void *data, uint16 len)
+{
+	struct sk_buff *skb = (struct sk_buff *) pkt;
+	struct sk_buff *lastskb;
+	uint8 *to;
+	uint16 addlen = 0;
+
+	pkt_dump_debug(pkt);
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
+			CFPKT_PRIV_DATA(pkt)->erronous = true;
+			return false;
+		}
+
+		/* Is the SKB non-linear after skb_cow_data()? If so, we are
+		 * going to add data to the last SKB, so we need to adjust
+		 * lengths of the top SKB.
+		 */
+		if (lastskb != skb) {
+			skb->len += len;
+			skb->data_len += len;
+		}
+	}
+
+	/* All set to put the last SKB and optionally write data there. */
+	to = skb_put(lastskb, len);
+	if (likely(data))
+		memcpy(to, data, len);
+	pkt_dump_debug(pkt);
+	return true;
+}
+EXPORT_SYMBOL(cfpkt_add_body);
+
+inline bool cfpkt_addbdy(struct cfpkt *pkt, uint8 data)
+{
+	return cfpkt_add_body(pkt, &data, 1);
+}
+EXPORT_SYMBOL(cfpkt_addbdy);
+
+bool cfpkt_add_head(struct cfpkt *pkt, const void *data2, uint16 len)
+{
+	struct sk_buff *skb = (struct sk_buff *) pkt;
+	struct sk_buff *lastskb;
+	uint8 *to;
+	const uint8 *data = data2;
+	pkt_dump_debug(pkt);
+	if (unlikely(skb_headroom(skb) < len)) {
+		CFPKT_PRIV_DATA(pkt)->erronous = true;
+		return false;
+	}
+
+	/* Make sure data is writable */
+	if (unlikely(skb_cow_data(skb, 0, &lastskb) < 0)) {
+		CFPKT_PRIV_DATA(pkt)->erronous = true;
+		return false;
+	}
+
+	to = skb_push(skb, len);
+	memcpy(to, data, len);
+	pkt_dump_debug(pkt);
+	return true;
+}
+EXPORT_SYMBOL(cfpkt_add_head);
+
+inline bool cfpkt_add_trail(struct cfpkt *pkt, const void *data, uint16 len)
+{
+	return cfpkt_add_body(pkt, data, len);
+}
+EXPORT_SYMBOL(cfpkt_add_trail);
+
+inline uint16 cfpkt_getlen(struct cfpkt *pkt)
+{
+	struct sk_buff *skb = (struct sk_buff *) pkt;
+	return skb->len;
+}
+EXPORT_SYMBOL(cfpkt_getlen);
+
+inline uint16 cfpkt_iterate(struct cfpkt *pkt, iterfunc_t func, uint16 data)
+{
+
+	/* Don't care about the performance hit of linearizing,
+	 * Checksum should not be used on high-speed interfaces anyway.
+	 */
+	if (unlikely(skb_linearize(&pkt->skb) != 0)) {
+		CFPKT_PRIV_DATA(pkt)->erronous = true;
+		return 0;
+	}
+	return func(data, pkt->skb.data, cfpkt_getlen(pkt));
+}
+EXPORT_SYMBOL(cfpkt_iterate);
+
+int cfpkt_setlen(struct cfpkt *pkt, uint16 len)
+{
+	struct sk_buff *skb = (struct sk_buff *) pkt;
+
+	pkt_dump_debug(pkt);
+
+	if (likely(len <= skb->len)) {
+		if (unlikely(skb->data_len))
+			___pskb_trim(skb, len);
+		else
+			skb_trim(skb, len);
+
+		pkt_dump_debug(pkt);
+		return cfpkt_getlen(pkt);
+	}
+
+	/* Need to expand SKB */
+	if (unlikely(!cfpkt_pad_trail(pkt, len - skb->len)))
+		CFPKT_PRIV_DATA(pkt)->erronous = true;
+
+	pkt_dump_debug(pkt);
+	return cfpkt_getlen(pkt);
+}
+EXPORT_SYMBOL(cfpkt_setlen);
+
+void
+cfpkt_extract(struct cfpkt *cfpkt, void *buf, unsigned int buflen,
+	      unsigned int *actual_len)
+{
+	uint16 pklen;
+
+	pkt_dump_debug(cfpkt);
+	pklen = cfpkt_getlen(cfpkt);
+	if (likely(buflen < pklen))
+		pklen = buflen;
+	*actual_len = pklen;
+	cfpkt_extr_head(cfpkt, buf, pklen);
+	pkt_dump_debug(cfpkt);
+}
+EXPORT_SYMBOL(cfpkt_extract);
+
+struct cfpkt *cfpkt_create_uplink(const unsigned char *data, unsigned int len)
+{
+	struct cfpkt *pkt = cfpkt_create_pfx(len + PKT_POSTFIX, PKT_PREFIX);
+	CFPKT_PRIV_DATA(pkt)->fastpath = true;
+	if (unlikely(data != NULL))
+		cfpkt_add_body(pkt, data, len);
+	return pkt;
+}
+
+
+#ifdef CAIF_FAST_SKB_OPS
+struct cfpkt *cfpkt_append(struct cfpkt *dstpkt, struct cfpkt *addpkt,
+				uint16 expectlen)
+{
+	struct sk_buff *dst = (struct sk_buff *) dstpkt;
+	struct sk_buff *add = (struct sk_buff *) addpkt;
+	struct sk_buff *lastskb;
+	CFPKT_PRIV_DATA(addpkt)->fastpath = false;
+	CFPKT_PRIV_DATA(dstpkt)->fastpath = false;
+	pkt_dump_debug(dstpkt);
+	pkt_dump_debug(addpkt);
+
+	/* TODO Could we (instead of calling skb_cow_data()) check for
+	 * cloned || shared and if true allocate a new skb
+	 * with an empty head and set skb_shinfo(skb)->frag_list = add ?
+	 * If this is safe, would it be more efficient?
+	 */
+
+	/* Make sure destination SKB is writable */
+	if (unlikely(skb_cow_data(dst, 0, &lastskb) < 0)) {
+		CFPKT_PRIV_DATA(dstpkt)->erronous = true;
+		return dstpkt;
+	}
+
+	/* First get the frag_list if any */
+	if (likely(skb_shinfo(dst)->frag_list == NULL))
+		skb_shinfo(dst)->frag_list = add;
+	else {
+		lastskb = skb_shinfo(dst)->frag_list;
+
+		/* Go to the very right in the fragment list */
+		while (lastskb->next)
+			lastskb = lastskb->next;
+
+		lastskb->next = add;
+	}
+
+	/* Update size */
+	dst->data_len += add->len;
+	dst->len += add->len;
+	dst->truesize += add->truesize;
+	pkt_dump_debug(dstpkt);
+	cfglu_atomic_dec(cfpkt_packet_count);
+	return dstpkt;
+}
+EXPORT_SYMBOL(cfpkt_append);
+
+struct cfpkt *cfpkt_split(struct cfpkt *pkt, uint16 pos)
+{
+	struct sk_buff *skb = (struct sk_buff *) pkt;
+	struct sk_buff *skb2;
+	CFPKT_PRIV_DATA(pkt)->fastpath = false;
+	if (unlikely(pos > skb->len)) {
+		PKT_ERROR(pkt, "cfpkt_split: split beyond end of packet\n");
+		return NULL;
+	}
+	pkt_dump_debug(pkt);
+
+	/* Make sure SKB is writable */
+	if (unlikely(skb_cow_data(skb, 0, &skb2) < 0)) {
+		CFPKT_PRIV_DATA(pkt)->erronous = true;
+		return NULL;
+	}
+
+	skb2 = (struct sk_buff *) cfpkt_create(skb->len - pos);
+
+	if (unlikely(skb2 == NULL))
+		return NULL;
+
+	CFPKT_PRIV_DATA(pkt)->fastpath = false;
+	CFPKT_PRIV_DATA(pkt)->erronous = false;
+	pkt_dump_debug((struct cfpkt *) skb2);
+
+	skb_split(skb, skb2, pos);
+
+	pkt_dump_debug((struct cfpkt *) skb2);
+	cfglu_atomic_inc(cfpkt_packet_count);
+	return (struct cfpkt *) skb2;
+}
+EXPORT_SYMBOL(cfpkt_split);
+
+#else
+struct cfpkt *cfpkt_append(struct cfpkt *dstpkt,
+			     struct cfpkt *addpkt,
+			     uint16 expectlen)
+{
+	struct sk_buff *dst = (struct sk_buff *) dstpkt;
+	struct sk_buff *add = (struct sk_buff *) addpkt;
+	uint16 addlen = add->tail - add->data;
+	uint16 neededtailspace;
+	struct sk_buff *tmp;
+	uint16 dstlen;
+	uint16 createlen;
+
+	if (expectlen > addlen)
+		neededtailspace = expectlen;
+	else
+		neededtailspace = addlen;
+
+	if (dst->tail + neededtailspace > dst->end) {
+		/* Create a dumplicate of 'dst' with more tail space */
+		dstlen = dst->tail - dst->data;
+		createlen = dstlen + addlen;
+		if (expectlen > createlen)
+			createlen = expectlen;
+		tmp = (struct sk_buff *)
+			cfpkt_create(createlen + PKT_PREFIX + PKT_POSTFIX);
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
+	return (struct cfpkt *) dst;
+}
+
+struct cfpkt *cfpkt_split(struct cfpkt *pkt, uint16 pos)
+{
+	struct sk_buff *skb2;		/* FIXME: Rename skb2 to pkt2 */
+	struct sk_buff *skb = (struct sk_buff *) pkt;
+	uint8 *split = skb->data + pos;
+	uint16 len2nd = skb->tail - split;
+	CFLOG_TRACE3(("cfpkt_split(%p,%d)", (void *) pkt, pos));
+
+	if (skb->data + pos > skb->tail) {
+		PKT_ERROR(pkt,
+			  "cfpkt_split: trying to split beyond end of packet");
+		return 0;
+	}
+
+	/* Create a new packet for the second part of the data */
+	skb2 = (struct sk_buff *)
+		cfpkt_create_pfx(len2nd + PKT_PREFIX + PKT_POSTFIX,
+				 PKT_PREFIX);
+
+	if (skb2 == NULL)
+		return NULL;
+
+	/* Reduce the length of the original packet */
+	skb->tail = split;
+	skb->len -= pos;
+
+	memcpy(skb2->data, split, len2nd);
+	skb2->tail += len2nd;
+	skb2->len += len2nd;
+	return (struct cfpkt *) skb2;
+}
+#endif
+
+char *cfpkt_log_pkt(struct cfpkt *cfpkt, char *buf, int buflen)
+{
+	struct sk_buff *skb = (struct sk_buff *) cfpkt;
+	char *p = buf;
+	int i;
+
+	if (skb_linearize(skb) != 0)
+		return NULL;
+	/* Sanity check buffer length, it needs to be at least as large as
+	 *  the header info: ~=50+ bytes
+	 */
+	if (buflen < 50)
+		return NULL;
+
+	snprintf(buf, buflen, " pkt:%p len:%d {%d,%d} data: [",
+		skb,
+		skb->tail - skb->data,
+		skb->data - skb->head, skb->tail - skb->head);
+	p = buf + strlen(buf);
+
+	for (i = 0; i < skb->tail - skb->data; i++) {
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
+int cfpkt_raw_append(struct cfpkt *cfpkt, void **buf, unsigned int buflen)
+{
+	struct sk_buff *skb = (struct sk_buff *) cfpkt;
+	struct sk_buff *lastskb;
+
+	caif_assert(buf != NULL);
+
+	/* Make sure SKB is writable */
+	if (unlikely(skb_cow_data(skb, 0, &lastskb) < 0)) {
+		CFPKT_PRIV_DATA(cfpkt)->erronous = true;
+		return 0;
+	}
+
+	if (unlikely(skb_linearize(skb) != 0)) {
+		CFPKT_PRIV_DATA(cfpkt)->erronous = true;
+		return 0;
+	}
+
+	if (unlikely(skb_tailroom(skb) < buflen)) {
+		CFPKT_PRIV_DATA(cfpkt)->erronous = true;
+		return 0;
+	}
+
+	*buf = skb_put(skb, buflen);
+	return 1;
+}
+EXPORT_SYMBOL(cfpkt_raw_append);
+
+int cfpkt_raw_extract(struct cfpkt *cfpkt, void **buf, unsigned int buflen)
+{
+	struct sk_buff *skb = (struct sk_buff *) cfpkt;
+
+	caif_assert(buf != NULL);
+
+	if (unlikely(buflen > skb->len)) {
+		CFPKT_PRIV_DATA(cfpkt)->erronous = true;
+		return 0;
+	}
+
+	if (unlikely(buflen > skb_headlen(skb))) {
+		if (unlikely(skb_linearize(skb) != 0)) {
+			CFPKT_PRIV_DATA(cfpkt)->erronous = true;
+			return 0;
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
+	return CFPKT_PRIV_DATA(pkt)->erronous;
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
+
+	if (unlikely(data))
+		cfpkt_add_body(pkt, data, len);
+	CFPKT_PRIV_DATA(pkt)->fastpath = true;
+	CFPKT_PRIV_DATA(pkt)->erronous = false;
+	return pkt;
+}
+EXPORT_SYMBOL(cfpkt_create_pkt);
+
+
+struct caif_packet_funcs cfpkt_get_packet_funcs()
+{
+	struct caif_packet_funcs f;
+	f.cfpkt_fromnative = cfpkt_fromnative;
+	f.cfpkt_tonative = cfpkt_tonative;
+	f.cfpkt_destroy = cfpkt_destroy;
+	f.cfpkt_extract = cfpkt_extract;
+	f.cfpkt_create_xmit_pkt = cfpkt_create_uplink;
+	f.cfpkt_create_recv_pkt = cfpkt_create_uplink;
+	f.cfpkt_dequeue = cfpkt_dequeue;
+	f.cfpkt_qpeek = cfpkt_qpeek;
+	f.cfpkt_queue = cfpkt_queue;
+	f.cfpktq_create = cfpktq_create;
+	f.cfpkt_raw_extract = cfpkt_raw_extract;
+	f.cfpkt_raw_append = cfpkt_raw_append;
+	f.cfpkt_getlen = cfpkt_getlen;
+	return f;
+}
+
+struct cfpktq *cfpktq_create()
+{
+	struct cfpktq *q = cfglu_alloc(sizeof(struct cfpktq));
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
+	skb_queue_tail(&pktq->head, (struct sk_buff *) pkt);
+	spin_unlock(&pktq->lock);
+
+}
+EXPORT_SYMBOL(cfpkt_queue);
+
+struct cfpkt *cfpkt_qpeek(struct cfpktq *pktq)
+{
+	struct cfpkt *tmp;
+	spin_lock(&pktq->lock);
+	tmp = (struct cfpkt *) skb_peek(&pktq->head);
+	spin_unlock(&pktq->lock);
+	return tmp;
+}
+EXPORT_SYMBOL(cfpkt_qpeek);
+
+struct cfpkt *cfpkt_dequeue(struct cfpktq *pktq)
+{
+	struct cfpkt *pkt;
+	spin_lock(&pktq->lock);
+	pkt = (struct cfpkt *) skb_dequeue(&pktq->head);
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
+
+	clone  = (struct cfpkt *) skb_clone((struct sk_buff *) pkt, GFP_ATOMIC);
+
+	/* Free original packet. */
+	cfpkt_destroy(pkt);
+
+	if (!clone)
+		return NULL;
+
+	cfglu_atomic_inc(cfpkt_packet_count);
+
+	return clone;
+}
+EXPORT_SYMBOL(cfpkt_clone_release);
diff --git a/net/caif/generic/cfrfml.c b/net/caif/generic/cfrfml.c
new file mode 100644
index 0000000..1ed70b5
--- /dev/null
+++ b/net/caif/generic/cfrfml.c
@@ -0,0 +1,112 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfsrvl.h>
+#include <net/caif/generic/cfpkt.h>
+
+#define container_obj(layr) cfglu_container_of(layr, struct cfsrvl, layer)
+
+#define RFM_SEGMENTATION_BIT 0x01
+#define RFM_PAYLOAD  0x00
+#define RFM_CMD_BIT  0x80
+#define RFM_FLOW_OFF 0x81
+#define RFM_FLOW_ON  0x80
+#define RFM_SET_PIN  0x82
+#define RFM_CTRL_PKT_SIZE 1
+
+static int cfrfml_receive(struct layer *layr, struct cfpkt *pkt);
+static int cfrfml_transmit(struct layer *layr, struct transmt_info *dummy,
+				struct cfpkt *pkt);
+
+struct layer *cfrfml_create(uint8 channel_id, uint8 phyid)
+{
+	struct cfsrvl *rfm = cfglu_alloc(sizeof(struct cfsrvl));
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+
+	memset(rfm, 0, sizeof(struct cfsrvl));
+	cfsrvl_init(rfm, channel_id, phyid);
+	rfm->layer.receive = cfrfml_receive;
+	rfm->layer.transmit = cfrfml_transmit;
+	snprintf(rfm->layer.name, CAIF_LAYER_NAME_SZ, "rfm%d", channel_id);
+	return &rfm->layer;
+}
+
+void cffrml_destroy(struct layer *layer)
+{
+	cfglu_free(layer);
+}
+
+static int cfrfml_receive(struct layer *layr, struct cfpkt *pkt)
+{
+	uint8 tmp;
+	bool segmented;
+	int ret;
+	CFLOG_ENTER(("\n"));
+	caif_assert(layr->up != NULL);
+	caif_assert(layr->receive != NULL);
+
+	/*
+	 * RFM is taking care of segmentation and stripping of
+	 * segmentation bit.
+	 */
+	if (!cfpkt_extr_head(pkt, &tmp, 1)) {
+		CFLOG_ERROR(("cfrfml: Packet is erroneous!\n"));
+		cfpkt_destroy(pkt);
+		return CFGLU_EPROTO;
+	}
+	segmented = tmp & RFM_SEGMENTATION_BIT;
+	caif_assert(!segmented);
+
+	ret = layr->up->receive(layr->up, pkt);
+	CFLOG_EXIT(("\n"));
+	return ret;
+}
+
+static int cfrfml_transmit(struct layer *layr, struct transmt_info *dummy,
+			   struct cfpkt *pkt)
+{
+	uint8 tmp = 0;
+	struct transmt_info info;
+	int ret;
+	struct cfsrvl *service = container_obj(layr);
+
+	caif_assert(layr->dn != NULL);
+	caif_assert(layr->dn->transmit != NULL);
+
+	if (!cfsrvl_ready(service, &ret))
+		return ret;
+
+	if (!cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
+		CFLOG_ERROR(("Packet too large - size=%d\n",
+			     cfpkt_getlen(pkt)));
+		return CFGLU_EOVERFLOW;
+	}
+
+	if (!cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
+		CFLOG_ERROR(("Packet too large - size=%d\n",
+			     cfpkt_getlen(pkt)));
+		return CFGLU_EOVERFLOW;
+	}
+	if (!cfpkt_add_head(pkt, &tmp, 1)) {
+		CFLOG_ERROR(("cffrml: Packet is erroneous!\n"));
+		return CFGLU_EPKT;
+	}
+
+	/* Add info for MUX-layer to route the packet out. */
+	info.channel_id = service->layer.id;
+	info.phid = service->phid;
+	/* To optimize alignment, we add up the size of CAIF header before
+	 * payload.
+	 */
+	info.hdr_len = 1;
+	ret = layr->dn->transmit(layr->dn, &info, pkt);
+	if (ret < 0)
+		cfpkt_extr_head(pkt, &tmp, 1);
+	return ret;
+}
diff --git a/net/caif/generic/cfserl.c b/net/caif/generic/cfserl.c
new file mode 100644
index 0000000..9697941
--- /dev/null
+++ b/net/caif/generic/cfserl.c
@@ -0,0 +1,292 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/fcs.h>
+
+#define container_obj(layr) ((struct cfserl *) layr)
+
+#define CFSERL_STX 0x02
+#define CAIF_MINIUM_PACKET_SIZE 4
+struct cfserl {
+	struct layer layer;
+	struct cfpkt *incomplete_frm;
+	cfglu_lock_t sync;
+	bool usestx;
+};
+#define STXLEN(layr) (layr->usestx ? 1 : 0)
+
+/**
+ * This variable is used as a global flag, in order to set whether
+ * STX is used on serial communication.
+ * NOTE: This is not a fully future proof solution.
+ */
+int serial_use_stx;
+EXPORT_SYMBOL(serial_use_stx);
+
+
+
+static int cfserl_receive(struct layer *layr, struct cfpkt *pkt);
+static int cfserl_transmit(struct layer *layr, struct transmt_info *info,
+				struct cfpkt *pkt);
+static void cfserl_ctrlcmd(struct layer *layr, enum caif_ctrlcmd ctrl,
+				int phyid);
+
+struct cfserl *cfserl_create(int type, int instance, bool use_stx)
+{
+	struct cfserl *this = cfglu_alloc(sizeof(struct cfserl));
+	caif_assert(offsetof(struct cfserl, layer) == 0);
+
+	memset(this, 0, sizeof(struct cfserl));
+	this->layer.receive = cfserl_receive;
+	this->layer.transmit = cfserl_transmit;
+	this->layer.ctrlcmd = cfserl_ctrlcmd;
+	this->layer.type = type;
+	this->usestx = use_stx;
+	cfglu_init_lock(this->sync);
+	snprintf(this->layer.name, CAIF_LAYER_NAME_SZ, "ser1");
+	return this;
+}
+
+void cfserl_set_uplayer(struct cfserl *this, struct layer *up)
+{
+	this->layer.up = up;
+}
+
+void cfserl_set_dnlayer(struct cfserl *this, struct layer *dn)
+{
+	this->layer.dn = dn;
+}
+
+static int cfserl_receive(struct layer *l, struct cfpkt *newpkt)
+{
+	struct cfserl *layr = container_obj(l);
+	uint16 pkt_len;
+	struct cfpkt *pkt = NULL;
+	struct cfpkt *tail_pkt = NULL;
+	uint8 tmp8;
+	uint16 tmp;
+	uint8 stx = CFSERL_STX;
+	int ret;
+	uint16 expectlen = 0;
+#ifdef CAIF_DEBUG_ON
+	uint16 newpktlen;
+	static char buf[10000];
+#endif
+	caif_assert(newpkt != NULL);
+#ifdef CAIF_DEBUG_ON
+	newpktlen = cfpkt_getlen(newpkt);
+	CFLOG_ENTER(("\n"));
+	if (caif_dbg_level > CFLOG_LEVEL_TRACE3) {
+		cfpkt_log_pkt(newpkt, buf, sizeof(buf));
+		CFLOG_TRACE3(("serl: RECEIVE PACKET %s\n", buf));
+	}
+#endif
+	cfglu_lock(layr->sync);
+
+	if (layr->incomplete_frm != NULL) {
+
+		layr->incomplete_frm =
+		    cfpkt_append(layr->incomplete_frm, newpkt, expectlen);
+#ifdef CAIF_DEBUG_ON
+		CFLOG_TRACE2(("serl: Appending %d bytes, new packet holds %d "
+			      "bytes with expected frame-length=%d\n",
+			      newpktlen,
+			      cfpkt_getlen(layr->incomplete_frm),
+			      expectlen));
+#endif
+		pkt = layr->incomplete_frm;
+	} else {
+		pkt = newpkt;
+	}
+	layr->incomplete_frm = NULL;
+
+	do {
+#ifdef CAIF_DEBUG_ON
+		if (caif_dbg_level > CFLOG_LEVEL_TRACE3) {
+			cfpkt_log_pkt(pkt, buf, sizeof(buf));
+			CFLOG_TRACE3(("serl: PACKET before STX search: %s\n",
+				      buf));
+		}
+#endif
+		/* Search for STX at start of pkt if STX is used */
+		if (layr->usestx) {
+			CFLOG_TRACE2(("serl: Start looking for STX at "
+				      "start of frame\n"));
+			(void) cfpkt_extr_head(pkt, &tmp8, 1);
+			if (tmp8 != CFSERL_STX) {
+				CFLOG_TRACE(("serl: STX Error! STX not at "
+					     "start of packe\n"));
+				while (cfpkt_more(pkt)
+				       && tmp8 != CFSERL_STX) {
+					(void) cfpkt_extr_head(pkt, &tmp8, 1);
+				}
+				if (!cfpkt_more(pkt)) {
+					CFLOG_TRACE(("serl: Destroying packet "
+						     "when no STX found\n"));
+					cfpkt_destroy(pkt);
+					layr->incomplete_frm = NULL;
+					cfglu_unlock(layr->sync);
+					CFLOG_EXIT(("\n"));
+					return CFGLU_EPROTO;
+				}
+			}
+		}
+
+		pkt_len = cfpkt_getlen(pkt);
+
+		/*
+		 *  pkt_len is the accumulated length of the packet data
+		 *  we have received so far.
+		 *  Exit if frame doesn't hold length.
+		 */
+
+		if (pkt_len < 2) {
+			if (layr->usestx)
+				cfpkt_add_head(pkt, &stx, 1);
+			layr->incomplete_frm = pkt;
+			cfglu_unlock(layr->sync);
+#ifdef CAIF_DEBUG_ON
+			if (caif_dbg_level > CFLOG_LEVEL_TRACE3) {
+				cfpkt_log_pkt(pkt, buf, sizeof(buf));
+				CFLOG_TRACE3(("serl: PACKET before exit "
+					      "(too short): %s\n", buf));
+			}
+#endif
+			CFLOG_EXIT(("\n"));
+			return 0;
+		}
+
+		/*
+		 *  Find length of frame.
+		 *  expectlen is the length we need for a full frame.
+		 */
+		(void) cfpkt_peek_head(pkt, &tmp, 2);
+		expectlen = cfglu_le16_to_cpu(tmp) + 2;
+		CFLOG_TRACE2(("serl:  Processing a packet of %d bytes with "
+			      "expected length=%d\n", pkt_len, expectlen));
+
+#ifdef CAIF_DEBUG_ON
+		if (caif_dbg_level > CFLOG_LEVEL_TRACE3) {
+			cfpkt_log_pkt(pkt, buf, sizeof(buf));
+			CFLOG_TRACE3(("serl: PACKET after STX Seach: %s\n",
+				      buf));
+		}
+#endif
+		/*
+		 * Frame error handling
+		 */
+		if (expectlen < CAIF_MINIUM_PACKET_SIZE
+		    || expectlen > CAIF_MAX_FRAMESIZE) {
+			if (!layr->usestx) {
+				CFLOG_ERROR(("cfserl: packet has bad expectlen "
+					     "%d\n", expectlen));
+				CFLOG_ERROR(("serl: Packet is erroneous throw "
+					     "it away (expectlen=%d, len=%d)",
+					     expectlen, pkt_len));
+				if (pkt != NULL)
+					cfpkt_destroy(pkt);
+				layr->incomplete_frm = NULL;
+				expectlen = 0;
+				cfglu_unlock(layr->sync);
+				CFLOG_EXIT(("\n"));
+				return CFGLU_EPROTO;
+			}
+			continue;
+		}
+
+		if (pkt_len < expectlen) {
+			/* Too little received data */
+			CFLOG_TRACE2(("serl: Holding incomplete packet with "
+				      "current length=%d and expected "
+				      "length=%d", pkt_len, expectlen));
+			if (layr->usestx)
+				cfpkt_add_head(pkt, &stx, 1);
+
+#ifdef CAIF_DEBUG_ON
+			if (caif_dbg_level > CFLOG_LEVEL_TRACE3) {
+				cfpkt_log_pkt(pkt, buf, sizeof(buf));
+				CFLOG_TRACE3(("serl: incomplete_frame: %s\n",
+					      buf));
+			}
+#endif
+			layr->incomplete_frm = pkt;
+			cfglu_unlock(layr->sync);
+			return 0;
+		}
+
+		/* Enough data for at least one frame.
+		 * Split the frame, if too long
+		 */
+		if (pkt_len > expectlen) {
+			CFLOG_TRACE2(("serl: Splitting too long packet of "
+				      "length = %d and frame size =%d\n",
+				      pkt_len, expectlen));
+			tail_pkt = cfpkt_split(pkt, expectlen);
+		} else {
+			tail_pkt = NULL;
+		}
+
+#ifdef CAIF_DEBUG_ON
+		if (caif_dbg_level > CFLOG_LEVEL_TRACE3) {
+			cfpkt_log_pkt(pkt, buf, sizeof(buf));
+			CFLOG_TRACE3(("serl: PACKET sent up: %s\n", buf));
+		}
+#endif
+		/* Send the first part of packet upwards */
+		ret = layr->layer.up->receive(layr->layer.up, pkt);
+
+		if (ret == CFGLU_EFCS) {
+			CFLOG_ERROR(("cfserl: upper layer return error: %d\n",
+				     ret));
+
+			if (layr->usestx) {
+				CFLOG_WARN(("cfserl: Layer above return fcs "
+					    "error, Search for next STX\n"));
+				if (tail_pkt != NULL)
+					pkt = cfpkt_append(pkt, tail_pkt, 0);
+
+				/* Start search for next STX if frame failed */
+				continue;
+			} else {
+				cfpkt_destroy(pkt);
+				pkt = NULL;
+			}
+		}
+
+		pkt = tail_pkt;
+
+	} while (pkt != NULL);
+
+	cfglu_unlock(layr->sync);
+	return 0;
+}
+
+static int cfserl_transmit(struct layer *layer, struct transmt_info *info,
+			   struct cfpkt *newpkt)
+{
+	struct cfserl *layr = container_obj(layer);
+	int ret;
+	uint8 tmp8 = CFSERL_STX;
+	CFLOG_ENTER(("\n"));
+	if (layr->usestx)
+		cfpkt_add_head(newpkt, &tmp8, 1);
+	ret = layer->dn->transmit(layer->dn, info, newpkt);
+	if (ret < 0)
+		cfpkt_extr_head(newpkt, &tmp8, 1);
+
+	CFLOG_EXIT(("\n"));
+	return ret;
+}
+
+static void cfserl_ctrlcmd(struct layer *layr, enum caif_ctrlcmd ctrl,
+				int phyid)
+{
+	layr->up->ctrlcmd(layr->up, ctrl, phyid);
+}
diff --git a/net/caif/generic/cfshml.c b/net/caif/generic/cfshml.c
new file mode 100644
index 0000000..cdf2cd1
--- /dev/null
+++ b/net/caif/generic/cfshml.c
@@ -0,0 +1,63 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/fcs.h>
+
+static int cfshml_receive(struct layer *layr, struct cfpkt *pkt);
+static int cfshml_transmit(struct layer *layr, struct transmt_info *info,
+				struct cfpkt *pkt);
+static void cfshml_ctrlcmd(struct layer *layr, enum caif_ctrlcmd ctrl,
+				int phyid);
+
+struct layer *cfshml_create(int type, int instance)
+{
+	struct layer *this = cfglu_alloc(sizeof(struct layer));
+
+	memset(this, 0, sizeof(struct layer));
+	this->receive = cfshml_receive;
+	this->ctrlcmd = cfshml_ctrlcmd;
+	this->transmit = cfshml_transmit;
+	this->type = type;
+	snprintf(this->name, CAIF_LAYER_NAME_SZ, "shm1");
+	return this;
+}
+
+void cfshml_set_uplayer(struct layer *this, struct layer *up)
+{
+	this->up = up;
+}
+
+void cfshml_set_dnlayer(struct layer *this, struct layer *dn)
+{
+	this->dn = dn;
+	this->dn->type = this->type;
+}
+
+static int cfshml_receive(struct layer *layr, struct cfpkt *pkt)
+{
+	int ret;
+	/* Send the first part of packet upwards. */
+	ret = layr->up->receive(layr->up, pkt);
+	/* FCS error - don't delete the packet. */
+	if (ret == CFGLU_EFCS)
+		cfpkt_destroy(pkt);
+	return ret;
+}
+
+static int cfshml_transmit(struct layer *layr, struct transmt_info *info,
+				struct cfpkt *pkt)
+{
+	return layr->dn->transmit(layr->dn, info, pkt);
+}
+
+static void cfshml_ctrlcmd(struct layer *layr, enum caif_ctrlcmd ctrl,
+				int phyid)
+{
+	layr->up->ctrlcmd(layr->up, ctrl, phyid);
+}
diff --git a/net/caif/generic/cfspil.c b/net/caif/generic/cfspil.c
new file mode 100644
index 0000000..4813548
--- /dev/null
+++ b/net/caif/generic/cfspil.c
@@ -0,0 +1,344 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+/** \page CFSPIL - CAIF SPI Layer:
+
+ *  \note: A special protocol is defined for SPI PHYSICAL layer:
+ *	-# CAIF packet is sent by \ref transmit_cb_t "transmit function"
+ *	-# SPI PHY layer will send  \ref ctrlcmd_cb_t "flowcontrol"
+ *	    \ref CAIF_CTRLCMD_FLOW_OFF_IND "off"  upwards in CAIF stack.
+ *	-# CAIF will start appending CAIF Packets upto maximum size.
+ *	-# SPI PHY layer will send  \ref ctrlcmd_cb_t "flowcontrol"
+ *	    \ref CAIF_CTRLCMD_FLOW_ON_IND "on"	upwards in CAIF stack.
+ *	-# Appended CAIF packets are sent by \ref transmit_cb_t
+ *	   "transmit" function.
+ */
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/cfspil.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/fcs.h>
+
+/* Normally this should be aligned on the modem in order to benefit from full
+ * duplex transfers. However a size of 8188 provokes errors when running with
+ * the modem. These errors occur when packet sizes approaches 4 kB of data.
+ */
+#define CAIF_MAX_SPI_FRAME 4092
+
+/* Maximum number of uplink CAIF frames that can reside in the same SPI frame.
+ * This number should correspond with the modem setting. The application side
+ * CAIF accepts any number of embedded downlink CAIF frames.
+ */
+#define CAIF_MAX_SPI_PKTS 9
+
+#define container_obj(layr) cfglu_container_of(layr, struct cfspil, layer)
+
+#define CAIF_SPI_QUEUE_LOW 12
+#define CAIF_SPI_QUEUE_HIGH 24
+
+struct cfspil {
+	struct layer layer;		/* The layer structure must always
+					 * be present first in struct. */
+	struct cfspipad pad;		/* CAIF padding options. */
+	struct cfpkt *xmitpkt;	/* Pending packet to be sent */
+	cfglu_lock_t sync;
+	struct cfpktq *queue;
+	bool flow_stop;			/* Flow control state. */
+};
+
+
+int spi_up_head_align = 1;
+EXPORT_SYMBOL(spi_up_head_align);
+
+int spi_up_tail_align;
+EXPORT_SYMBOL(spi_up_tail_align);
+
+int spi_down_head_align = 3;
+EXPORT_SYMBOL(spi_down_head_align);
+
+int spi_down_tail_align = 1;
+EXPORT_SYMBOL(spi_down_tail_align);
+
+
+
+
+/* Prototype declarations */
+static int cfspil_receive(struct layer *layr, struct cfpkt *pkt);
+static int cfspil_transmit(struct layer *layr, struct transmt_info *info,
+			   struct cfpkt *pkt);
+
+struct layer *cfspil_create(int type, int instance, struct cfspipad cfpad)
+{
+	struct cfspil *this = cfglu_alloc(sizeof(struct cfspil));
+	caif_assert(offsetof(struct cfspil, layer) == 0);
+	memset(this, 0, sizeof(struct cfspil));
+	cfglu_init_lock(this->sync);
+	this->layer.receive = cfspil_receive;
+	this->layer.transmit = cfspil_transmit;
+	this->pad.up_head_align = cfpad.up_head_align;
+	this->pad.up_tail_align = cfpad.up_tail_align;
+	this->pad.down_head_align = cfpad.down_head_align;
+	this->pad.down_tail_align = cfpad.down_tail_align;
+	this->xmitpkt = NULL;	/* Pending packet to be sent */
+	this->layer.type = type;
+	this->flow_stop = false;
+	sprintf(this->layer.name, "spi1");
+	this->queue = cfpktq_create();
+	return &this->layer;
+}
+
+static int cfspil_receive(struct layer *layer, struct cfpkt *pkt)
+{
+	uint8 startpad;
+	uint8 pad[16];
+	uint16 len, tmplen;
+	uint16 pktlen;
+	uint16 endpad;
+	int ret;
+	struct cfspil *layr = container_obj(layer);
+	struct cfpkt *nextpkt = NULL;
+
+	while (pkt && cfpkt_more(pkt)) {
+		if (layr->pad.down_head_align) {
+			/* Read and handle start offset */
+			(void)cfpkt_extr_head(pkt, &startpad, 1);
+			if (startpad >= (layr->pad.down_head_align + 1)) {
+				CFLOG_ERROR(("cfspil: Recieved start pad=%d,"
+					     " expected less than %d\n",
+					     startpad,
+					     (layr->pad.down_head_align + 1)));
+				goto error;
+			}
+		} else
+			startpad = 0;
+
+		caif_assert(startpad < 16);
+
+		if (startpad)
+			(void)cfpkt_extr_head(pkt, &pad, startpad);
+
+		pktlen = cfpkt_getlen(pkt);
+
+		/* Read packet length */
+		(void)cfpkt_peek_head(pkt, &tmplen, 2);
+		len = cfglu_le16_to_cpu(tmplen) + 2;
+		if (cfpkt_erroneous(pkt) || len < 6
+		    || len > CAIF_MAX_SPI_FRAME || pktlen < len) {
+			CFLOG_ERROR(("cfspil: Packet is erroneous throw it "
+				     " away (len=%d)\n", len));
+			cfpkt_destroy(pkt);
+			return CFGLU_EPROTO;
+		}
+
+		/*
+		 * Compute tail offset i.e. number of bytes to
+		 * add to get alignment
+		 */
+		if (layr->pad.down_head_align)
+			endpad =
+			    (len + startpad + 1) & layr->pad.down_tail_align;
+		else
+			endpad = len & layr->pad.down_tail_align;
+
+		CFLOG_TRACE3(("cfspil: recv pkt:0x%p len:%d startpad:%d "
+			      "endpad:%d\n", pkt, len, startpad, endpad));
+
+		nextpkt = NULL;
+		if (pktlen - len > 5)
+			nextpkt = cfpkt_split(pkt, len);
+
+		if (cfpkt_erroneous(pkt)) {
+			CFLOG_ERROR(("cfspil: Packet is erroneous!\n"));
+			goto error;
+		}
+
+		if (endpad && nextpkt)
+			(void)cfpkt_extr_head(nextpkt, &pad, endpad);
+
+		ret = layr->layer.up->receive(layr->layer.up, pkt);
+		/* FCS Error don't delete the packet */
+		if (ret == CFGLU_EFCS)
+			cfpkt_destroy(pkt);
+
+		pkt = nextpkt;
+		nextpkt = NULL;
+	}
+	return 0;
+ error:
+	cfpkt_destroy(pkt);
+	if (nextpkt)
+		cfpkt_destroy(nextpkt);
+	return CFGLU_EPROTO;
+}
+
+static struct cfpkt *cfspil_built_xmit_pkt(struct cfspil *layr)
+{
+	uint16 totallen;
+	int count;
+	int pkts = 0;
+	struct cfpkt *pkt, *xmitpkt;
+
+	cfglu_lock(layr->sync);
+	xmitpkt = cfpkt_dequeue(layr->queue);
+	cfglu_unlock(layr->sync);
+	pkts++;
+
+	count = cfpkt_qcount(layr->queue);
+	if ((layr->flow_stop == true) && (count <= CAIF_SPI_QUEUE_LOW)) {
+		layr->flow_stop = false;
+		if (layr->layer.up->ctrlcmd)
+			layr->layer.up->ctrlcmd(layr->layer.up,
+					_CAIF_CTRLCMD_PHYIF_FLOW_ON_IND,
+					0);
+	}
+
+	/* CFLOG_TRACE(("cfspil_xmitlen - 1: lyr:0x%x,
+	   xmitpkt:0x%x\n", layr, xmitpkt)); */
+
+	if (xmitpkt == NULL)
+		return NULL;
+
+	totallen = cfpkt_getlen(xmitpkt);
+	/* CFLOG_TRACE(("cfspil_xmitlen -2 : xmitpkt:0x%x
+	   len:%d\n", xmitpkt, totallen)); */
+
+	while (xmitpkt != NULL && !cfpkt_erroneous(xmitpkt)) {
+		int len;
+
+		/* Verify that we don't exceed the maximum uplink CAIF
+		 * frame count within a CAIF SPI frame.
+		 */
+		if (pkts >= CAIF_MAX_SPI_PKTS) {
+			caif_assert(pkts <= CAIF_MAX_SPI_PKTS);
+			return xmitpkt;
+		}
+
+		cfglu_lock(layr->sync);
+		pkt = cfpkt_qpeek(layr->queue);
+
+		len = pkt == NULL ? 0 : cfpkt_getlen(pkt);
+		if (pkt != NULL && totallen + len < CAIF_MAX_SPI_FRAME) {
+			pkt = cfpkt_dequeue(layr->queue);
+			cfglu_unlock(layr->sync);
+			pkts++;
+			/* CFLOG_TRACE(("cfspil_xmitlen - 3: pkt:0x%x
+			   len:%d\n", pkt, len)); */
+			totallen += len;
+			xmitpkt = cfpkt_append(xmitpkt, pkt, 0);
+			/* CFLOG_TRACE(("cfspil_xmitlen - 4: pkt:0x%x
+			   len:%d\n", xmitpkt, totallen)); */
+
+			count = cfpkt_qcount(layr->queue);
+			if ((layr->flow_stop == true)
+			    && (count <= CAIF_SPI_QUEUE_LOW)) {
+				layr->flow_stop = false;
+				if (layr->layer.up->ctrlcmd)
+					layr->layer.up->ctrlcmd(layr->layer.up,
+					       _CAIF_CTRLCMD_PHYIF_FLOW_ON_IND,
+					       0);
+			}
+
+		} else {
+			cfglu_unlock(layr->sync);
+			/* CFLOG_TRACE(("cfspil_xmitlen - 5: pkt:0x%x
+			   len:%d\n", xmitpkt, totallen)); */
+
+			return xmitpkt;
+		}
+	}
+
+	/* Error handling */
+	if (xmitpkt != NULL)
+		cfpkt_destroy(xmitpkt);
+
+	return NULL;
+}
+
+int cfspil_xmitlen(struct cfspil *layr)
+{
+	if (layr->xmitpkt == NULL)
+		layr->xmitpkt = cfspil_built_xmit_pkt(layr);
+
+	/* CFLOG_TRACE(("cfspil_xmitlen: lyr:0x%x\n", layr)); */
+
+	if (layr->xmitpkt != NULL)
+		return cfpkt_getlen(layr->xmitpkt);
+	return 0;
+}
+EXPORT_SYMBOL(cfspil_xmitlen);
+
+struct cfpkt *cfspil_getxmitpkt(struct cfspil *layr)
+{
+	struct cfpkt *ret = layr->xmitpkt;
+	layr->xmitpkt = NULL;
+	return ret;
+}
+EXPORT_SYMBOL(cfspil_getxmitpkt);
+
+static int cfspil_transmit(struct layer *layer, struct transmt_info *info,
+			   struct cfpkt *pkt)
+{
+	uint32 pad = -1;
+	int count;
+	uint8 startpad;
+	uint16 endpad;
+	uint16 len;
+	struct cfpkt *clone;
+	struct cfspil *layr = container_obj(layer);
+	CFLOG_TRACE3(("cfspil_transmit: lyr:0x%p, pkt:0x%p "
+		      "pktlen:%d\n", layr, pkt, cfpkt_getlen(pkt)));
+
+	if (layr->pad.up_head_align) {
+		startpad = (info->hdr_len + 1) & layr->pad.up_head_align;
+		if (startpad)
+			cfpkt_add_head(pkt, &pad, startpad);
+		cfpkt_add_head(pkt, &startpad, 1);
+	} else
+		startpad = 0;
+
+	len = cfpkt_getlen(pkt);
+
+	/* Compute tail offset i.e. number of bytes to add to get alignment */
+	if (layr->pad.up_head_align)
+		endpad = (len + startpad + 1) & layr->pad.up_tail_align;
+	else
+		endpad = len & layr->pad.up_tail_align;
+
+	if (endpad)
+		cfpkt_pad_trail(pkt, endpad);
+
+	if (cfpkt_erroneous(pkt)) {
+		CFLOG_ERROR(("cfspil: Packet is erroneous!\n"));
+		return CFGLU_EPROTO;
+	}
+
+	/* Take ownership of packet. */
+	clone = cfpkt_clone_release(pkt);
+	if (!clone) {
+		CFLOG_ERROR(("cfspil: Cloning failed!\n"));
+		return CFGLU_ENOMEM;
+	}
+
+	cfglu_lock(layr->sync);
+	cfpkt_queue(layr->queue, clone, info->prio);
+	cfglu_unlock(layr->sync);
+
+	count = cfpkt_qcount(layr->queue);
+	if (count >= CAIF_SPI_QUEUE_HIGH) {
+		layr->flow_stop = true;
+		if (layr->layer.up->ctrlcmd)
+			layr->layer.up->ctrlcmd(layr->layer.up,
+					_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND,
+					0);
+	}
+
+	/* Inidicate a transmit request, but SPI PHY pulls the packet */
+	layr->layer.dn->transmit(layr->layer.dn, NULL, NULL);
+
+	return 0;
+}
diff --git a/net/caif/generic/cfsrvl.c b/net/caif/generic/cfsrvl.c
new file mode 100644
index 0000000..cf82dfa
--- /dev/null
+++ b/net/caif/generic/cfsrvl.c
@@ -0,0 +1,181 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfsrvl.h>
+#include <net/caif/generic/cfpkt.h>
+
+#define SRVL_CTRL_PKT_SIZE 1
+#define SRVL_FLOW_OFF 0x81
+#define SRVL_FLOW_ON  0x80
+#define SRVL_SET_PIN  0x82
+#define SRVL_CTRL_PKT_SIZE 1
+
+#define container_obj(layr) cfglu_container_of(layr, struct cfsrvl, layer)
+
+static void cfservl_ctrlcmd(struct layer *layr, enum caif_ctrlcmd ctrl,
+				int phyid)
+{
+	struct cfsrvl *service = container_obj(layr);
+	caif_assert(layr->up != NULL);
+	caif_assert(layr->up->ctrlcmd != NULL);
+	CFLOG_ENTER(("\n"));
+	switch (ctrl) {
+	case CAIF_CTRLCMD_INIT_RSP:
+		CFLOG_TRACE(("cfsrvl: ctrlcmd SEND_FLOW_INIT\n"));
+		service->open = true;
+		layr->up->ctrlcmd(layr->up, ctrl, phyid);
+		break;
+	case CAIF_CTRLCMD_DEINIT_RSP:
+	case CAIF_CTRLCMD_INIT_FAIL_RSP:
+		CFLOG_TRACE(("cfsrvl: ctrlcmd DEINIT_RSP / INIT_FAIL_RSP\n"));
+		service->open = false;
+		layr->up->ctrlcmd(layr->up, ctrl, phyid);
+		break;
+	case _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND:
+		if (phyid != service->phid)
+			break;
+		if (service->modem_flow_on)
+			layr->up->ctrlcmd(layr->up,
+					  CAIF_CTRLCMD_FLOW_OFF_IND, phyid);
+		service->phy_flow_on = false;
+		break;
+	case _CAIF_CTRLCMD_PHYIF_FLOW_ON_IND:
+		if (phyid != service->phid)
+			return;
+		if (service->modem_flow_on) {
+			layr->up->ctrlcmd(layr->up,
+					   CAIF_CTRLCMD_FLOW_ON_IND,
+					   phyid);
+		}
+		service->phy_flow_on = true;
+		break;
+	case CAIF_CTRLCMD_FLOW_OFF_IND:
+		if (service->phy_flow_on) {
+			layr->up->ctrlcmd(layr->up,
+					  CAIF_CTRLCMD_FLOW_OFF_IND, phyid);
+		}
+		service->modem_flow_on = false;
+		break;
+	case CAIF_CTRLCMD_FLOW_ON_IND:
+		if (service->phy_flow_on) {
+			layr->up->ctrlcmd(layr->up,
+					  CAIF_CTRLCMD_FLOW_ON_IND, phyid);
+		}
+		service->modem_flow_on = true;
+		break;
+	case _CAIF_CTRLCMD_PHYIF_DOWN_IND:
+		/* In case interface is down, let's fake a remove shutdown */
+		layr->up->ctrlcmd(layr->up,
+				CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND, phyid);
+		break;
+	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
+		layr->up->ctrlcmd(layr->up, ctrl, phyid);
+		break;
+	default:
+		CFLOG_WARN(("cfsrvl: Unexpected ctrl in cfsrvl (%d)\n", ctrl));
+
+		/* We have both modem and phy flow on, send flow on */
+		layr->up->ctrlcmd(layr->up, ctrl, phyid);
+		service->phy_flow_on = true;
+		break;
+	}
+	CFLOG_EXIT(("\n"));
+}
+
+static int cfservl_modemcmd(struct layer *layr, enum caif_modemcmd ctrl)
+{
+	struct cfsrvl *service = container_obj(layr);
+	caif_assert(layr != NULL);
+	caif_assert(layr->dn != NULL);
+	caif_assert(layr->dn->transmit != NULL);
+	switch (ctrl) {
+	case CAIF_MODEMCMD_FLOW_ON_REQ:
+		{
+			struct cfpkt *pkt;
+			struct transmt_info info;
+			uint8 flow_on = SRVL_FLOW_ON;
+			memset(&info, 0, sizeof(info));
+			info.channel_id = service->layer.id;
+			info.phid = service->phid;
+			info.hdr_len = 1;
+			CFLOG_TRACE(("cfsrvl: ctrlcmd SEND_FLOW_ON\n"));
+			pkt = cfpkt_create(SRVL_CTRL_PKT_SIZE);
+			if (!cfpkt_add_head(pkt, &flow_on, 1)) {
+				CFLOG_ERROR(("cfsrvl: Packet is erroneous!\n"));
+				cfpkt_destroy(pkt);
+				return CFGLU_EPROTO;
+			}
+			return layr->dn->transmit(layr->dn, &info, pkt);
+		}
+	case CAIF_MODEMCMD_FLOW_OFF_REQ:
+		{
+			struct cfpkt *pkt;
+			struct transmt_info info;
+			uint8 flow_off = SRVL_FLOW_OFF;
+			memset(&info, 0, sizeof(info));
+			info.channel_id = service->layer.id;
+			info.phid = service->phid;
+			info.hdr_len = 1;
+			CFLOG_TRACE(("cfsrvl: ctrlcmd SEND_FLOW_OFF\n"));
+			pkt = cfpkt_create(SRVL_CTRL_PKT_SIZE);
+			if (!cfpkt_add_head(pkt, &flow_off, 1)) {
+				CFLOG_ERROR(("cfsrvl: Packet is erroneous!\n"));
+				cfpkt_destroy(pkt);
+				return CFGLU_EPROTO;
+			}
+			return layr->dn->transmit(layr->dn, &info, pkt);
+		}
+	default:
+	  break;
+	}
+	return CFGLU_EINVAL;
+}
+
+void cfservl_destroy(struct layer *layer)
+{
+	cfglu_free(layer);
+}
+
+void cfsrvl_init(struct cfsrvl *service, uint8 channel_id, uint8 phyid)
+{
+	struct cfsrvl *srvl = cfglu_alloc(sizeof(struct cfsrvl));
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+	memset(srvl, 0, sizeof(struct cfsrvl));
+	service->open = false;
+	service->modem_flow_on = true;
+	service->phy_flow_on = true;
+	service->layer.id = channel_id;
+	service->phid = phyid;
+	service->layer.ctrlcmd = cfservl_ctrlcmd;
+	service->layer.modemcmd = cfservl_modemcmd;
+}
+
+bool cfsrvl_ready(struct cfsrvl *service, int *err)
+{
+	if (service->open && service->modem_flow_on && service->phy_flow_on)
+		return true;
+	if (!service->open) {
+		*err = CFGLU_ENOTCONN;
+		return false;
+	}
+	caif_assert(!(service->modem_flow_on && service->phy_flow_on));
+	*err = CFGLU_ERETRY;
+	return false;
+}
+uint8 cfsrvl_getphyid(struct layer *layer)
+{
+	struct cfsrvl *servl = container_obj(layer);
+	return servl->phid;
+}
+
+bool cfsrvl_phyid_match(struct layer *layer, int phyid)
+{
+	struct cfsrvl *servl = container_obj(layer);
+	return servl->phid == phyid;
+}
diff --git a/net/caif/generic/cfusbl.c b/net/caif/generic/cfusbl.c
new file mode 100644
index 0000000..0be7b72
--- /dev/null
+++ b/net/caif/generic/cfusbl.c
@@ -0,0 +1,51 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfusbl.h>
+
+static int cfusbl_receive(struct layer *layr, struct cfpkt *pkt);
+static int cfusbl_transmit(struct layer *layr, struct transmt_info *info,
+				struct cfpkt *pkt);
+
+struct layer *cfusbl_create(int type, int instance)
+{
+	struct layer *this = cfglu_alloc(sizeof(struct layer));
+	memset(this, 0, sizeof(struct layer));
+	this->receive = cfusbl_receive;
+	this->transmit = cfusbl_transmit;
+	this->type = type;
+	sprintf(this->name, "usb%d", instance);
+	return this;
+}
+
+void cfusbl_set_uplayer(struct layer *this, struct layer *up)
+{
+	this->up = up;
+}
+
+void cfusbl_set_dnlayer(struct layer *this, struct layer *dn)
+{
+	this->dn = dn;
+}
+
+static int cfusbl_receive(struct layer *layr, struct cfpkt *pkt)
+{
+	/* Send the first part of the packet upwards. */
+	int ret = layr->up->receive(layr->up, pkt);
+	/* FCS error - don't delete the packet. */
+	if (ret == CFGLU_EFCS)
+		cfpkt_destroy(pkt);
+	return ret;
+}
+
+static int cfusbl_transmit(struct layer *layr, struct transmt_info *info,
+				struct cfpkt *pkt)
+{
+	return layr->dn->transmit(layr->dn, info, pkt);
+}
diff --git a/net/caif/generic/cfutill.c b/net/caif/generic/cfutill.c
new file mode 100644
index 0000000..2f76968
--- /dev/null
+++ b/net/caif/generic/cfutill.c
@@ -0,0 +1,109 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfsrvl.h>
+#include <net/caif/generic/cfpkt.h>
+
+#define container_obj(layr) ((struct cfsrvl *) layr)
+#define UTIL_PAYLOAD  0x00
+#define UTIL_CMD_BIT  0x80
+#define UTIL_REMOTE_SHUTDOWN 0x82
+#define UTIL_FLOW_OFF 0x81
+#define UTIL_FLOW_ON  0x80
+#define UTIL_CTRL_PKT_SIZE 1
+static int cfutill_receive(struct layer *layr, struct cfpkt *pkt);
+static int cfutill_transmit(struct layer *layr, struct transmt_info *dummy,
+			    struct cfpkt *pkt);
+
+struct layer *cfutill_create(uint8 channel_id, uint8 phyid)
+{
+	struct cfsrvl *util = cfglu_alloc(sizeof(struct cfsrvl));
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+
+	memset(util, 0, sizeof(struct cfsrvl));
+	cfsrvl_init(util, channel_id, phyid);
+	util->layer.receive = cfutill_receive;
+	util->layer.transmit = cfutill_transmit;
+	snprintf(util->layer.name, CAIF_LAYER_NAME_SZ - 1, "util1");
+	return &util->layer;
+}
+
+static int cfutill_receive(struct layer *layr, struct cfpkt *pkt)
+{
+	uint8 cmd = -1;
+	struct cfsrvl *service = container_obj(layr);
+	caif_assert(layr != NULL);
+	caif_assert(layr->up != NULL);
+	caif_assert(layr->up->receive != NULL);
+	caif_assert(layr->up->ctrlcmd != NULL);
+	if (!cfpkt_extr_head(pkt, &cmd, 1)) {
+		CFLOG_ERROR(("cfutill: Packet is erroneous!\n"));
+		cfpkt_destroy(pkt);
+		return CFGLU_EPROTO;
+	}
+
+	switch (cmd) {
+	case UTIL_PAYLOAD:
+		return layr->up->receive(layr->up, pkt);
+	case UTIL_FLOW_OFF:
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_FLOW_OFF_IND, 0);
+		cfpkt_destroy(pkt);
+		return 0;
+	case UTIL_FLOW_ON:
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_FLOW_ON_IND, 0);
+		cfpkt_destroy(pkt);
+		return 0;
+	case UTIL_REMOTE_SHUTDOWN:	/* Remote Shutdown Request */
+		CFLOG_ERROR(("cfutill: REMOTE SHUTDOWN REQUEST RECEIVED\n"));
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND, 0);
+		service->open = false;
+		cfpkt_destroy(pkt);
+		return 0;
+	default:
+		cfpkt_destroy(pkt);
+		CFLOG_ERROR(("cfmuxl: Unknown datagram control %d (0x%x!\n",
+			     cmd, cmd));
+		return CFGLU_EPROTO;
+	}
+}
+
+static int cfutill_transmit(struct layer *layr, struct transmt_info *dummy,
+				struct cfpkt *pkt)
+{
+	uint8 zero = 0;
+	struct transmt_info info;
+	int ret;
+	struct cfsrvl *service = container_obj(layr);
+	caif_assert(layr != NULL);
+	caif_assert(layr->dn != NULL);
+	caif_assert(layr->dn->transmit != NULL);
+	if (!cfsrvl_ready(service, &ret))
+		return ret;
+
+	if (cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
+		CFLOG_ERROR(("packet too large size=%d\n", cfpkt_getlen(pkt)));
+		return CFGLU_EOVERFLOW;
+	}
+
+	cfpkt_add_head(pkt, &zero, 1);
+	memset(&info, 0, sizeof(info));
+	/* Add info for MUX-layer to route the packet out. */
+	info.channel_id = service->layer.id;
+	info.phid = service->phid;
+	/* To optimize alignment, we add up the size of CAIF header before
+	 * payload.
+	 */
+	info.hdr_len = 1;
+	ret = layr->dn->transmit(layr->dn, &info, pkt);
+	if (ret < 0) {
+		uint32 tmp32;
+		cfpkt_extr_head(pkt, &tmp32, 4);
+	}
+	return ret;
+}
diff --git a/net/caif/generic/cfveil.c b/net/caif/generic/cfveil.c
new file mode 100644
index 0000000..9aa6430
--- /dev/null
+++ b/net/caif/generic/cfveil.c
@@ -0,0 +1,113 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfsrvl.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/caif_log.h>
+
+#define VEI_PAYLOAD  0x00
+#define VEI_CMD_BIT  0x80
+#define VEI_FLOW_OFF 0x81
+#define VEI_FLOW_ON  0x80
+#define VEI_SET_PIN  0x82
+#define VEI_CTRL_PKT_SIZE 1
+#define container_obj(layr) cfglu_container_of(layr, struct cfsrvl, layer)
+
+static int cfvei_receive(struct layer *layr, struct cfpkt *pkt);
+static int cfvei_transmit(struct layer *layr, struct transmt_info *dummy,
+				struct cfpkt *pkt);
+
+struct layer *cfvei_create(uint8 channel_id, uint8 phyid)
+{
+	struct cfsrvl *vei = cfglu_alloc(sizeof(struct cfsrvl));
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+	memset(vei, 0, sizeof(struct cfsrvl));
+	cfsrvl_init(vei, channel_id, phyid);
+	vei->layer.receive = cfvei_receive;
+	vei->layer.transmit = cfvei_transmit;
+	snprintf(vei->layer.name, CAIF_LAYER_NAME_SZ - 1, "vei%d", channel_id);
+	CFLOG_TRACE(("cfvei: Created %p\n", (void *) vei));
+	return &vei->layer;
+}
+
+static int cfvei_receive(struct layer *layr, struct cfpkt *pkt)
+{
+	uint8 cmd;
+	int ret;
+	CFLOG_ENTER(("\n"));
+	caif_assert(layr->up != NULL);
+	caif_assert(layr->receive != NULL);
+	caif_assert(layr->ctrlcmd != NULL);
+
+
+	if (!cfpkt_extr_head(pkt, &cmd, 1)) {
+		CFLOG_ERROR(("cfvei: Packet is erroneous!\n"));
+		cfpkt_destroy(pkt);
+		CFLOG_ENTER(("\n"));
+		return CFGLU_EPROTO;
+	}
+	switch (cmd) {
+	case VEI_PAYLOAD:
+		ret = layr->up->receive(layr->up, pkt);
+		CFLOG_EXIT(("\n"));
+		return ret;
+	case VEI_FLOW_OFF:
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_FLOW_OFF_IND, 0);
+		cfpkt_destroy(pkt);
+		CFLOG_EXIT(("\n"));
+		return CFGLU_EOK;
+	case VEI_FLOW_ON:
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_FLOW_ON_IND, 0);
+		cfpkt_destroy(pkt);
+		CFLOG_EXIT(("\n"));
+		return CFGLU_EOK;
+	case VEI_SET_PIN:	/* SET RS232 PIN */
+		cfpkt_destroy(pkt);
+		CFLOG_EXIT(("\n"));
+		return CFGLU_EOK;
+	default:		/* SET RS232 PIN */
+		CFLOG_ERROR(("cfvei: Unknown VEI control packet %d (0x%x)!\n",
+			     cmd, cmd));
+		cfpkt_destroy(pkt);
+		CFLOG_EXIT(("error"));
+		return CFGLU_EPROTO;
+	}
+}
+
+static int cfvei_transmit(struct layer *layr, struct transmt_info *dummy,
+				struct cfpkt *pkt)
+{
+	uint8 tmp = 0;
+	struct transmt_info info;
+	int ret;
+	struct cfsrvl *service = container_obj(layr);
+	if (!cfsrvl_ready(service, &ret))
+		return ret;
+
+	caif_assert(layr->dn != NULL);
+	caif_assert(layr->dn->transmit != NULL);
+	if (!cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
+		CFLOG_ERROR(("Packet too large - size=%d\n",
+			     cfpkt_getlen(pkt)));
+		return CFGLU_EOVERFLOW;
+	}
+
+	if (!cfpkt_add_head(pkt, &tmp, 1)) {
+		CFLOG_ERROR(("cfvei: Packet is erroneous!\n"));
+		return CFGLU_EPKT;
+	}
+
+	/* Add info for MUX-layer to route the packet out. */
+	info.channel_id = service->layer.id;
+	info.phid = service->phid;
+	info.hdr_len = 1;
+	ret = layr->dn->transmit(layr->dn, &info, pkt);
+	if (ret < 0)
+		cfpkt_extr_head(pkt, &tmp, 1);
+	return ret;
+}
diff --git a/net/caif/generic/cfvidl.c b/net/caif/generic/cfvidl.c
new file mode 100644
index 0000000..365364a
--- /dev/null
+++ b/net/caif/generic/cfvidl.c
@@ -0,0 +1,62 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfsrvl.h>
+#include <net/caif/generic/cfpkt.h>
+
+#define container_obj(layr) ((struct cfsrvl *) layr)
+
+static int cfvidl_receive(struct layer *layr, struct cfpkt *pkt);
+static int cfvidl_transmit(struct layer *layr, struct transmt_info *dummy,
+				struct cfpkt *pkt);
+
+struct layer *cfvidl_create(uint8 channel_id, uint8 phyid)
+{
+	struct cfsrvl *vid = cfglu_alloc(sizeof(struct cfsrvl));
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+
+	memset(vid, 0, sizeof(struct cfsrvl));
+	cfsrvl_init(vid, channel_id, phyid);
+	vid->layer.receive = cfvidl_receive;
+	vid->layer.transmit = cfvidl_transmit;
+	snprintf(vid->layer.name, CAIF_LAYER_NAME_SZ - 1, "vid1");
+	return &vid->layer;
+}
+
+static int cfvidl_receive(struct layer *layr, struct cfpkt *pkt)
+{
+	uint32 videoheader;
+	if (!cfpkt_extr_head(pkt, &videoheader, 4)) {
+		CFLOG_ERROR(("cfvidl: Packet is erroneous!\n"));
+		cfpkt_destroy(pkt);
+		return CFGLU_EPROTO;
+	}
+	return layr->up->receive(layr->up, pkt);
+}
+
+static int cfvidl_transmit(struct layer *layr, struct transmt_info *dummy,
+				struct cfpkt *pkt)
+{
+	struct cfsrvl *service = container_obj(layr);
+	uint32 videoheader = 0;
+	int ret;
+	struct transmt_info info;
+	if (!cfsrvl_ready(service, &ret))
+		return ret;
+	cfpkt_add_head(pkt, &videoheader, 4);
+	memset(&info, 0, sizeof(info));
+	/* Add info for MUX-layer to route the packet out */
+	info.channel_id = service->layer.id;
+	info.phid = service->phid;
+
+	ret = layr->dn->transmit(layr->dn, &info, pkt);
+	if (ret < 0)
+		cfpkt_extr_head(pkt, &videoheader, 4);
+	return ret;
+}
diff --git a/net/caif/generic/fcs.c b/net/caif/generic/fcs.c
new file mode 100644
index 0000000..7dd2768
--- /dev/null
+++ b/net/caif/generic/fcs.c
@@ -0,0 +1,51 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+/* NOTE: Move this to glue and use OS specific function if exists */
+
+#include <net/caif/generic/cfglue.h>
+
+static uint16 fcstab[256] = {
+	0x0000, 0x1189, 0x2312, 0x329b, 0x4624, 0x57ad, 0x6536, 0x74bf,
+	0x8c48, 0x9dc1, 0xaf5a, 0xbed3, 0xca6c, 0xdbe5, 0xe97e, 0xf8f7,
+	0x1081, 0x0108, 0x3393, 0x221a, 0x56a5, 0x472c, 0x75b7, 0x643e,
+	0x9cc9, 0x8d40, 0xbfdb, 0xae52, 0xdaed, 0xcb64, 0xf9ff, 0xe876,
+	0x2102, 0x308b, 0x0210, 0x1399, 0x6726, 0x76af, 0x4434, 0x55bd,
+	0xad4a, 0xbcc3, 0x8e58, 0x9fd1, 0xeb6e, 0xfae7, 0xc87c, 0xd9f5,
+	0x3183, 0x200a, 0x1291, 0x0318, 0x77a7, 0x662e, 0x54b5, 0x453c,
+	0xbdcb, 0xac42, 0x9ed9, 0x8f50, 0xfbef, 0xea66, 0xd8fd, 0xc974,
+	0x4204, 0x538d, 0x6116, 0x709f, 0x0420, 0x15a9, 0x2732, 0x36bb,
+	0xce4c, 0xdfc5, 0xed5e, 0xfcd7, 0x8868, 0x99e1, 0xab7a, 0xbaf3,
+	0x5285, 0x430c, 0x7197, 0x601e, 0x14a1, 0x0528, 0x37b3, 0x263a,
+	0xdecd, 0xcf44, 0xfddf, 0xec56, 0x98e9, 0x8960, 0xbbfb, 0xaa72,
+	0x6306, 0x728f, 0x4014, 0x519d, 0x2522, 0x34ab, 0x0630, 0x17b9,
+	0xef4e, 0xfec7, 0xcc5c, 0xddd5, 0xa96a, 0xb8e3, 0x8a78, 0x9bf1,
+	0x7387, 0x620e, 0x5095, 0x411c, 0x35a3, 0x242a, 0x16b1, 0x0738,
+	0xffcf, 0xee46, 0xdcdd, 0xcd54, 0xb9eb, 0xa862, 0x9af9, 0x8b70,
+	0x8408, 0x9581, 0xa71a, 0xb693, 0xc22c, 0xd3a5, 0xe13e, 0xf0b7,
+	0x0840, 0x19c9, 0x2b52, 0x3adb, 0x4e64, 0x5fed, 0x6d76, 0x7cff,
+	0x9489, 0x8500, 0xb79b, 0xa612, 0xd2ad, 0xc324, 0xf1bf, 0xe036,
+	0x18c1, 0x0948, 0x3bd3, 0x2a5a, 0x5ee5, 0x4f6c, 0x7df7, 0x6c7e,
+	0xa50a, 0xb483, 0x8618, 0x9791, 0xe32e, 0xf2a7, 0xc03c, 0xd1b5,
+	0x2942, 0x38cb, 0x0a50, 0x1bd9, 0x6f66, 0x7eef, 0x4c74, 0x5dfd,
+	0xb58b, 0xa402, 0x9699, 0x8710, 0xf3af, 0xe226, 0xd0bd, 0xc134,
+	0x39c3, 0x284a, 0x1ad1, 0x0b58, 0x7fe7, 0x6e6e, 0x5cf5, 0x4d7c,
+	0xc60c, 0xd785, 0xe51e, 0xf497, 0x8028, 0x91a1, 0xa33a, 0xb2b3,
+	0x4a44, 0x5bcd, 0x6956, 0x78df, 0x0c60, 0x1de9, 0x2f72, 0x3efb,
+	0xd68d, 0xc704, 0xf59f, 0xe416, 0x90a9, 0x8120, 0xb3bb, 0xa232,
+	0x5ac5, 0x4b4c, 0x79d7, 0x685e, 0x1ce1, 0x0d68, 0x3ff3, 0x2e7a,
+	0xe70e, 0xf687, 0xc41c, 0xd595, 0xa12a, 0xb0a3, 0x8238, 0x93b1,
+	0x6b46, 0x7acf, 0x4854, 0x59dd, 0x2d62, 0x3ceb, 0x0e70, 0x1ff9,
+	0xf78f, 0xe606, 0xd49d, 0xc514, 0xb1ab, 0xa022, 0x92b9, 0x8330,
+	0x7bc7, 0x6a4e, 0x58d5, 0x495c, 0x3de3, 0x2c6a, 0x1ef1, 0x0f78
+};
+
+uint16 fcs16(uint16 fcs, uint8 *cp, uint16 len)
+{
+	while (len--)
+		fcs = (fcs >> 8) ^ fcstab[(fcs ^ *cp++) & 0xff];
+	return fcs;
+}
-- 
1.6.2.2.1669.g7eaf8

