From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 4/7] caif: Disconnect without waiting for response
Date: Wed, 28 Apr 2010 20:54:37 +0200
Message-ID: <1272480880-30672-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1272480880-30672-1-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-2-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	sjurbr@gmail.com, linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:35420 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756544Ab0D1Sz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:55:27 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00K3AOK7DG80@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:19 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00MYUOK4Q560@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:19 +0200 (CEST)
In-reply-to: <1272480880-30672-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Changes:
o Function cfcnfg_disconn_adapt_layer is changed to do asynchronous
  disconnect, not waiting for any response from the modem. Due to this
  the function cfcnfg_linkdestroy_rsp does nothing anymore.
o Because disconnect may take down a connection before a connect response
  is received the function cfcnfg_linkup_rsp is checking if the client is
  still waiting for the response, if not a disconnect request is sent to
  the modem.
o cfctrl is no longer keeping track of pending disconnect requests.
o Added function cfctrl_cancel_req, which is used for deleting a pending
  connect request if disconnect is done before connect response is received.
o Removed unused function cfctrl_insert_req2
o Added better handling of connect reject from modem.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/cfctrl.h |    7 +-
 net/caif/cfcnfg.c         |  155 +++++++++++++--------------------------------
 net/caif/cfctrl.c         |   95 ++++++++++++++++++----------
 3 files changed, 111 insertions(+), 146 deletions(-)

diff --git a/include/net/caif/cfctrl.h b/include/net/caif/cfctrl.h
index dee25b8..997603f 100644
--- a/include/net/caif/cfctrl.h
+++ b/include/net/caif/cfctrl.h
@@ -43,8 +43,7 @@ struct cfctrl_rsp {
 	void (*linksetup_rsp)(struct cflayer *layer, u8 linkid,
 			      enum cfctrl_srv serv, u8 phyid,
 			      struct cflayer *adapt_layer);
-	void (*linkdestroy_rsp)(struct cflayer *layer, u8 linkid,
-				struct cflayer *client_layer);
+	void (*linkdestroy_rsp)(struct cflayer *layer, u8 linkid);
 	void (*linkerror_ind)(void);
 	void (*enum_rsp)(void);
 	void (*sleep_rsp)(void);
@@ -117,7 +116,7 @@ struct cfctrl {
 };
 
 void cfctrl_enum_req(struct cflayer *cfctrl, u8 physlinkid);
-void cfctrl_linkup_request(struct cflayer *cfctrl,
+int cfctrl_linkup_request(struct cflayer *cfctrl,
 			   struct cfctrl_link_param *param,
 			   struct cflayer *user_layer);
 int  cfctrl_linkdown_req(struct cflayer *cfctrl, u8 linkid,
@@ -135,4 +134,6 @@ void cfctrl_insert_req(struct cfctrl *ctrl,
 			      struct cfctrl_request_info *req);
 struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
 					      struct cfctrl_request_info *req);
+void cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_layer);
+
 #endif				/* CFCTRL_H_ */
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index f94f3df..471c629 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -54,8 +54,7 @@ struct cfcnfg {
 static void cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id,
 			     enum cfctrl_srv serv, u8 phyid,
 			     struct cflayer *adapt_layer);
-static void cfcnfg_linkdestroy_rsp(struct cflayer *layer, u8 channel_id,
-				  struct cflayer *client_layer);
+static void cfcnfg_linkdestroy_rsp(struct cflayer *layer, u8 channel_id);
 static void cfcnfg_reject_rsp(struct cflayer *layer, u8 channel_id,
 			     struct cflayer *adapt_layer);
 static void cfctrl_resp_func(void);
@@ -175,73 +174,65 @@ int cfcnfg_get_named(struct cfcnfg *cnfg, char *name)
 	return 0;
 }
 
-/*
- * NOTE: What happens on destroy failure:
- *	 1a) No response - Too early
- *	      This will not happen because enumerate has already
- *	      completed.
- *	 1b) No response - FATAL
- *	      Not handled, but this should be a CAIF PROTOCOL ERROR
- *	      Modem error, response is really expected -  this
- *	      case is not really handled.
- *	 2) O/E-bit indicate error
- *	      Ignored - this link is destroyed anyway.
- *	 3) Not able to match on request
- *	      Not handled, but this should be a CAIF PROTOCOL ERROR
- *	 4) Link-Error - (no response)
- *	      Not handled, but this should be a CAIF PROTOCOL ERROR
- */
 int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer)
 {
 	u8 channel_id = 0;
 	int ret = 0;
+	struct cflayer *servl = NULL;
 	struct cfcnfg_phyinfo *phyinfo = NULL;
 	u8 phyid = 0;
-
 	caif_assert(adap_layer != NULL);
 	channel_id = adap_layer->id;
-	if (channel_id == 0) {
+	if (adap_layer->dn == NULL || channel_id == 0) {
 		pr_err("CAIF: %s():adap_layer->id is 0\n", __func__);
 		ret = -ENOTCONN;
 		goto end;
 	}
-
-	if (adap_layer->dn == NULL) {
-		pr_err("CAIF: %s():adap_layer->dn is NULL\n", __func__);
-		ret = -ENODEV;
-		goto end;
-	}
-
-	if (adap_layer->dn != NULL)
-		phyid = cfsrvl_getphyid(adap_layer->dn);
-
-	phyinfo = cfcnfg_get_phyinfo(cnfg, phyid);
-	if (phyinfo == NULL) {
-		pr_warning("CAIF: %s(): No interface to send disconnect to\n",
-			   __func__);
-		ret = -ENODEV;
+	servl = cfmuxl_remove_uplayer(cnfg->mux, channel_id);
+	if (servl == NULL)
 		goto end;
-	}
-
-	if (phyinfo->id != phyid
-		|| phyinfo->phy_layer->id != phyid
-		|| phyinfo->frm_layer->id != phyid) {
-
-		pr_err("CAIF: %s(): Inconsistency in phy registration\n",
-			__func__);
+	layer_set_up(servl, NULL);
+	ret = cfctrl_linkdown_req(cnfg->ctrl, channel_id, adap_layer);
+	if (servl == NULL) {
+		pr_err("CAIF: %s(): PROTOCOL ERROR "
+		       "- Error removing service_layer Channel_Id(%d)",
+			__func__, channel_id);
 		ret = -EINVAL;
 		goto end;
 	}
+	caif_assert(channel_id == servl->id);
+	if (adap_layer->dn != NULL) {
+		phyid = cfsrvl_getphyid(adap_layer->dn);
 
-	ret = cfctrl_linkdown_req(cnfg->ctrl, channel_id, adap_layer);
-
-end:
+		phyinfo = cfcnfg_get_phyinfo(cnfg, phyid);
+		if (phyinfo == NULL) {
+			pr_warning("CAIF: %s(): "
+				"No interface to send disconnect to\n",
+				__func__);
+			ret = -ENODEV;
+			goto end;
+		}
+		if (phyinfo->id != phyid ||
+			phyinfo->phy_layer->id != phyid ||
+			phyinfo->frm_layer->id != phyid) {
+			pr_err("CAIF: %s(): "
+				"Inconsistency in phy registration\n",
+				__func__);
+			ret = -EINVAL;
+			goto end;
+		}
+	}
 	if (phyinfo != NULL && --phyinfo->phy_ref_count == 0 &&
 		phyinfo->phy_layer != NULL &&
 		phyinfo->phy_layer->modemcmd != NULL) {
 		phyinfo->phy_layer->modemcmd(phyinfo->phy_layer,
 					     _CAIF_MODEMCMD_PHYIF_USELESS);
 	}
+end:
+	cfsrvl_put(servl);
+	cfctrl_cancel_req(cnfg->ctrl, adap_layer);
+	if (adap_layer->ctrlcmd != NULL)
+		adap_layer->ctrlcmd(adap_layer, CAIF_CTRLCMD_DEINIT_RSP, 0);
 	return ret;
 
 }
@@ -254,69 +245,11 @@ void cfcnfg_release_adap_layer(struct cflayer *adap_layer)
 }
 EXPORT_SYMBOL(cfcnfg_release_adap_layer);
 
-static void cfcnfg_linkdestroy_rsp(struct cflayer *layer, u8 channel_id,
-				  struct cflayer *client_layer)
+static void cfcnfg_linkdestroy_rsp(struct cflayer *layer, u8 channel_id)
 {
-	struct cfcnfg *cnfg = container_obj(layer);
-	struct cflayer *servl;
-
-	/*
-	 * 1) Remove service from the MUX layer. The MUX must
-	 *    guarante that no more payload sent "upwards" (receive)
-	 */
-	servl = cfmuxl_remove_uplayer(cnfg->mux, channel_id);
-
-	if (servl == NULL) {
-		pr_err("CAIF: %s(): PROTOCOL ERROR "
-		       "- Error removing service_layer Channel_Id(%d)",
-			__func__, channel_id);
-		return;
-	}
-	caif_assert(channel_id == servl->id);
-
-	if (servl != client_layer && servl->up != client_layer) {
-		pr_err("CAIF: %s(): Error removing service_layer "
-		       "Channel_Id(%d) %p %p",
-			__func__, channel_id, (void *) servl,
-			(void *) client_layer);
-		return;
-	}
-
-	/*
-	 * 2) DEINIT_RSP must guarantee that no more packets are transmitted
-	 *    from client (adap_layer) when it returns.
-	 */
-
-	if (servl->ctrlcmd == NULL) {
-		pr_err("CAIF: %s(): Error servl->ctrlcmd == NULL", __func__);
-		return;
-	}
-
-	servl->ctrlcmd(servl, CAIF_CTRLCMD_DEINIT_RSP, 0);
-
-	/* 3) It is now safe to destroy the service layer. */
-	cfservl_destroy(servl);
 }
 
-/*
- * NOTE: What happens on linksetup failure:
- *	 1a) No response - Too early
- *	      This will not happen because enumerate is secured
- *	      before using interface.
- *	 1b) No response - FATAL
- *	      Not handled, but this should be a CAIF PROTOCOL ERROR
- *	      Modem error, response is really expected -  this case is
- *	      not really handled.
- *	 2) O/E-bit indicate error
- *	      Handled in cnfg_reject_rsp
- *	 3) Not able to match on request
- *	      Not handled, but this should be a CAIF PROTOCOL ERROR
- *	 4) Link-Error - (no response)
- *	      Not handled, but this should be a CAIF PROTOCOL ERROR
- */
-
-int
-cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
+int cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
 				struct cfctrl_link_param *param,
 				struct cflayer *adap_layer)
 {
@@ -346,8 +279,7 @@ cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
 		     param->phyid);
 	/* FIXME: ENUMERATE INITIALLY WHEN ACTIVATING PHYSICAL INTERFACE */
 	cfctrl_enum_req(cnfg->ctrl, param->phyid);
-	cfctrl_linkup_request(cnfg->ctrl, param, adap_layer);
-	return 0;
+	return cfctrl_linkup_request(cnfg->ctrl, param, adap_layer);
 }
 EXPORT_SYMBOL(cfcnfg_add_adaptation_layer);
 
@@ -367,8 +299,10 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 	struct cflayer *servicel = NULL;
 	struct cfcnfg_phyinfo *phyinfo;
 	if (adapt_layer == NULL) {
-		pr_err("CAIF: %s(): PROTOCOL ERROR "
-			"- LinkUp Request/Response did not match\n", __func__);
+		pr_debug("CAIF: %s(): link setup response "
+				"but no client exist, send linkdown back\n",
+				__func__);
+		cfctrl_linkdown_req(cnfg->ctrl, channel_id, NULL);
 		return;
 	}
 
@@ -424,6 +358,7 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 	cfmuxl_set_uplayer(cnfg->mux, servicel, channel_id);
 	layer_set_up(servicel, adapt_layer);
 	layer_set_dn(adapt_layer, servicel);
+	cfsrvl_get(servicel);
 	servicel->ctrlcmd(servicel, CAIF_CTRLCMD_INIT_RSP, 0);
 }
 
diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 11f8014..a521d32 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -32,6 +32,7 @@ static void cfctrl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
 
 struct cflayer *cfctrl_create(void)
 {
+	struct dev_info dev_info;
 	struct cfctrl *this =
 		kmalloc(sizeof(struct cfctrl), GFP_ATOMIC);
 	if (!this) {
@@ -39,12 +40,13 @@ struct cflayer *cfctrl_create(void)
 		return NULL;
 	}
 	caif_assert(offsetof(struct cfctrl, serv.layer) == 0);
+	memset(&dev_info, 0, sizeof(dev_info));
+	dev_info.id = 0xff;
 	memset(this, 0, sizeof(*this));
+	cfsrvl_init(&this->serv, 0, &dev_info);
 	spin_lock_init(&this->info_list_lock);
 	atomic_set(&this->req_seq_no, 1);
 	atomic_set(&this->rsp_seq_no, 1);
-	this->serv.dev_info.id = 0xff;
-	this->serv.layer.id = 0;
 	this->serv.layer.receive = cfctrl_recv;
 	sprintf(this->serv.layer.name, "ctrl");
 	this->serv.layer.ctrlcmd = cfctrl_ctrlcmd;
@@ -127,20 +129,6 @@ void cfctrl_insert_req(struct cfctrl *ctrl,
 	spin_unlock(&ctrl->info_list_lock);
 }
 
-static void cfctrl_insert_req2(struct cfctrl *ctrl, enum cfctrl_cmd cmd,
-			       u8 linkid, struct cflayer *user_layer)
-{
-	struct cfctrl_request_info *req = kmalloc(sizeof(*req), GFP_KERNEL);
-	if (!req) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
-		return;
-	}
-	req->client_layer = user_layer;
-	req->cmd = cmd;
-	req->channel_id = linkid;
-	cfctrl_insert_req(ctrl, req);
-}
-
 /* Compare and remove request */
 struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
 					      struct cfctrl_request_info *req)
@@ -234,7 +222,7 @@ void cfctrl_enum_req(struct cflayer *layer, u8 physlinkid)
 	}
 }
 
-void cfctrl_linkup_request(struct cflayer *layer,
+int cfctrl_linkup_request(struct cflayer *layer,
 			   struct cfctrl_link_param *param,
 			   struct cflayer *user_layer)
 {
@@ -248,7 +236,7 @@ void cfctrl_linkup_request(struct cflayer *layer,
 	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	if (!pkt) {
 		pr_warning("CAIF: %s(): Out of memory\n", __func__);
-		return;
+		return -ENOMEM;
 	}
 	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_SETUP);
 	cfpkt_addbdy(pkt, (param->chtype << 4) + param->linktype);
@@ -294,11 +282,12 @@ void cfctrl_linkup_request(struct cflayer *layer,
 	default:
 		pr_warning("CAIF: %s():Request setup of bad link type = %d\n",
 			   __func__, param->linktype);
+		return -EINVAL;
 	}
 	req = kmalloc(sizeof(*req), GFP_KERNEL);
 	if (!req) {
 		pr_warning("CAIF: %s(): Out of memory\n", __func__);
-		return;
+		return -ENOMEM;
 	}
 	memset(req, 0, sizeof(*req));
 	req->client_layer = user_layer;
@@ -306,6 +295,11 @@ void cfctrl_linkup_request(struct cflayer *layer,
 	req->param = *param;
 	cfctrl_insert_req(cfctrl, req);
 	init_info(cfpkt_info(pkt), cfctrl);
+	/*
+	 * NOTE:Always send linkup and linkdown request on the same
+	 *	device as the payload. Otherwise old queued up payload
+	 *	might arrive with the newly allocated channel ID.
+	 */
 	cfpkt_info(pkt)->dev_info->id = param->phyid;
 	ret =
 	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
@@ -313,7 +307,9 @@ void cfctrl_linkup_request(struct cflayer *layer,
 		pr_err("CAIF: %s(): Could not transmit linksetup request\n",
 			__func__);
 		cfpkt_destroy(pkt);
+		return -ENODEV;
 	}
+	return 0;
 }
 
 int cfctrl_linkdown_req(struct cflayer *layer, u8 channelid,
@@ -326,7 +322,6 @@ int cfctrl_linkdown_req(struct cflayer *layer, u8 channelid,
 		pr_warning("CAIF: %s(): Out of memory\n", __func__);
 		return -ENOMEM;
 	}
-	cfctrl_insert_req2(cfctrl, CFCTRL_CMD_LINK_DESTROY, channelid, client);
 	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_DESTROY);
 	cfpkt_addbdy(pkt, channelid);
 	init_info(cfpkt_info(pkt), cfctrl);
@@ -392,6 +387,38 @@ void cfctrl_getstartreason_req(struct cflayer *layer)
 }
 
 
+void cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_layer)
+{
+	struct cfctrl_request_info *p, *req;
+	struct cfctrl *ctrl = container_obj(layr);
+	spin_lock(&ctrl->info_list_lock);
+
+	if (ctrl->first_req == NULL) {
+		spin_unlock(&ctrl->info_list_lock);
+		return;
+	}
+
+	if (ctrl->first_req->client_layer == adap_layer) {
+
+		req = ctrl->first_req;
+		ctrl->first_req = ctrl->first_req->next;
+		kfree(req);
+	}
+
+	p = ctrl->first_req;
+	while (p != NULL && p->next != NULL) {
+		if (p->next->client_layer == adap_layer) {
+
+			req = p->next;
+			p->next = p->next->next;
+			kfree(p->next);
+		}
+		p = p->next;
+	}
+
+	spin_unlock(&ctrl->info_list_lock);
+}
+
 static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 {
 	u8 cmdrsp;
@@ -409,11 +436,8 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 	cmd = cmdrsp & CFCTRL_CMD_MASK;
 	if (cmd != CFCTRL_CMD_LINK_ERR
 	    && CFCTRL_RSP_BIT != (CFCTRL_RSP_BIT & cmdrsp)) {
-		if (handle_loop(cfctrl, cmd, pkt) == CAIF_FAILURE) {
-			pr_info("CAIF: %s() CAIF Protocol error:"
-				"Response bit not set\n", __func__);
-			goto error;
-		}
+		if (handle_loop(cfctrl, cmd, pkt) == CAIF_FAILURE)
+			cmdrsp |= CFCTRL_ERR_BIT;
 	}
 
 	switch (cmd) {
@@ -451,12 +475,16 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 			switch (serv) {
 			case CFCTRL_SRV_VEI:
 			case CFCTRL_SRV_DBG:
+				if (CFCTRL_ERR_BIT & cmdrsp)
+					break;
 				/* Link ID */
 				cfpkt_extr_head(pkt, &linkid, 1);
 				break;
 			case CFCTRL_SRV_VIDEO:
 				cfpkt_extr_head(pkt, &tmp, 1);
 				linkparam.u.video.connid = tmp;
+				if (CFCTRL_ERR_BIT & cmdrsp)
+					break;
 				/* Link ID */
 				cfpkt_extr_head(pkt, &linkid, 1);
 				break;
@@ -465,6 +493,8 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 				cfpkt_extr_head(pkt, &tmp32, 4);
 				linkparam.u.datagram.connid =
 				    le32_to_cpu(tmp32);
+				if (CFCTRL_ERR_BIT & cmdrsp)
+					break;
 				/* Link ID */
 				cfpkt_extr_head(pkt, &linkid, 1);
 				break;
@@ -483,6 +513,8 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 					*cp++ = tmp;
 				*cp = '\0';
 
+				if (CFCTRL_ERR_BIT & cmdrsp)
+					break;
 				/* Link ID */
 				cfpkt_extr_head(pkt, &linkid, 1);
 
@@ -519,6 +551,8 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 					cfpkt_extr_head(pkt, &tmp, 1);
 					*cp++ = tmp;
 				}
+				if (CFCTRL_ERR_BIT & cmdrsp)
+					break;
 				/* Link ID */
 				cfpkt_extr_head(pkt, &linkid, 1);
 				/* Length */
@@ -560,13 +594,7 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 		break;
 	case CFCTRL_CMD_LINK_DESTROY:
 		cfpkt_extr_head(pkt, &linkid, 1);
-		rsp.cmd = cmd;
-		rsp.channel_id = linkid;
-		req = cfctrl_remove_req(cfctrl, &rsp);
-		cfctrl->res.linkdestroy_rsp(cfctrl->serv.layer.up, linkid,
-					    req ? req->client_layer : NULL);
-		if (req != NULL)
-			kfree(req);
+		cfctrl->res.linkdestroy_rsp(cfctrl->serv.layer.up, linkid);
 		break;
 	case CFCTRL_CMD_LINK_ERR:
 		pr_err("CAIF: %s(): Frame Error Indication received\n",
@@ -608,7 +636,7 @@ static void cfctrl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
 	case CAIF_CTRLCMD_FLOW_OFF_IND:
 		spin_lock(&this->info_list_lock);
 		if (this->first_req != NULL) {
-			pr_warning("CAIF: %s(): Received flow off in "
+			pr_debug("CAIF: %s(): Received flow off in "
 				   "control layer", __func__);
 		}
 		spin_unlock(&this->info_list_lock);
@@ -633,6 +661,7 @@ static int handle_loop(struct cfctrl *ctrl, int cmd, struct cfpkt *pkt)
 			if (!ctrl->loop_linkused[linkid])
 				goto found;
 		spin_unlock(&ctrl->loop_linkid_lock);
+		pr_err("CAIF: %s(): Out of link-ids\n", __func__);
 		return -EINVAL;
 found:
 		if (!ctrl->loop_linkused[linkid])
-- 
1.6.3.3

