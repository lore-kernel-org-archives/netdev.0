From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v8 05/12] net-caif: add CAIF core protocol stack
Date: Wed, 31 Mar 2010 01:56:23 +0200
Message-ID: <1269993390-23830-6-git-send-email-sjur.brandeland@stericsson.com>
References: <1269993390-23830-1-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-2-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-3-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-4-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-5-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: daniel.martensson@stericsson.com, sjurbr@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:63548 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756648Ab0C3X5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:57:04 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400CATD6OAR20@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:48 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L04003KXD6FYY70@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:48 +0200 (CEST)
In-reply-to: <1269993390-23830-5-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

CAIF generic protocol implementation. This layer is
somewhat generic in order to be able to use and test it outside
the Linux Kernel.

cfctrl.c     - CAIF control protocol layer
cfdbgl.c     - CAIF debug protocol layer
cfdgml.c     - CAIF datagram protocol layer
cffrml.c     - CAIF framing protocol layer
cfmuxl.c     - CAIF mux protocol layer
cfrfml.c     - CAIF remote file manager protocol layer
cfserl.c     - CAIF serial (fragmentation) protocol layer
cfsrvl.c     - CAIF generic service layer functions
cfutill.c    - CAIF utility protocol layer
cfveil.c     - CAIF AT protocol layer
cfvidl.c     - CAIF video protocol layer

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfctrl.c  |  664 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/caif/cfdbgl.c  |   40 ++++
 net/caif/cfdgml.c  |  108 +++++++++
 net/caif/cffrml.c  |  151 ++++++++++++
 net/caif/cfmuxl.c  |  246 +++++++++++++++++++
 net/caif/cfrfml.c  |  108 +++++++++
 net/caif/cfserl.c  |  192 +++++++++++++++
 net/caif/cfsrvl.c  |  185 +++++++++++++++
 net/caif/cfutill.c |  115 +++++++++
 net/caif/cfveil.c  |  107 +++++++++
 net/caif/cfvidl.c  |   65 +++++
 11 files changed, 1981 insertions(+), 0 deletions(-)

diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
new file mode 100644
index 0000000..11f8014
--- /dev/null
+++ b/net/caif/cfctrl.c
@@ -0,0 +1,664 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/stddef.h>
+#include <linux/spinlock.h>
+#include <linux/slab.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfpkt.h>
+#include <net/caif/cfctrl.h>
+
+#define container_obj(layr) container_of(layr, struct cfctrl, serv.layer)
+#define UTILITY_NAME_LENGTH 16
+#define CFPKT_CTRL_PKT_LEN 20
+
+
+#ifdef CAIF_NO_LOOP
+static int handle_loop(struct cfctrl *ctrl,
+			      int cmd, struct cfpkt *pkt){
+	return CAIF_FAILURE;
+}
+#else
+static int handle_loop(struct cfctrl *ctrl,
+		int cmd, struct cfpkt *pkt);
+#endif
+static int cfctrl_recv(struct cflayer *layr, struct cfpkt *pkt);
+static void cfctrl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
+			   int phyid);
+
+
+struct cflayer *cfctrl_create(void)
+{
+	struct cfctrl *this =
+		kmalloc(sizeof(struct cfctrl), GFP_ATOMIC);
+	if (!this) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return NULL;
+	}
+	caif_assert(offsetof(struct cfctrl, serv.layer) == 0);
+	memset(this, 0, sizeof(*this));
+	spin_lock_init(&this->info_list_lock);
+	atomic_set(&this->req_seq_no, 1);
+	atomic_set(&this->rsp_seq_no, 1);
+	this->serv.dev_info.id = 0xff;
+	this->serv.layer.id = 0;
+	this->serv.layer.receive = cfctrl_recv;
+	sprintf(this->serv.layer.name, "ctrl");
+	this->serv.layer.ctrlcmd = cfctrl_ctrlcmd;
+	spin_lock_init(&this->loop_linkid_lock);
+	this->loop_linkid = 1;
+	return &this->serv.layer;
+}
+
+static bool param_eq(struct cfctrl_link_param *p1, struct cfctrl_link_param *p2)
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
+	spin_lock(&ctrl->info_list_lock);
+	req->next = NULL;
+	atomic_inc(&ctrl->req_seq_no);
+	req->sequence_no = atomic_read(&ctrl->req_seq_no);
+	if (ctrl->first_req == NULL) {
+		ctrl->first_req = req;
+		spin_unlock(&ctrl->info_list_lock);
+		return;
+	}
+	p = ctrl->first_req;
+	while (p->next != NULL)
+		p = p->next;
+	p->next = req;
+	spin_unlock(&ctrl->info_list_lock);
+}
+
+static void cfctrl_insert_req2(struct cfctrl *ctrl, enum cfctrl_cmd cmd,
+			       u8 linkid, struct cflayer *user_layer)
+{
+	struct cfctrl_request_info *req = kmalloc(sizeof(*req), GFP_KERNEL);
+	if (!req) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return;
+	}
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
+	spin_lock(&ctrl->info_list_lock);
+	if (ctrl->first_req == NULL) {
+		spin_unlock(&ctrl->info_list_lock);
+		return NULL;
+	}
+
+	if (cfctrl_req_eq(req, ctrl->first_req)) {
+		ret = ctrl->first_req;
+		caif_assert(ctrl->first_req);
+		atomic_set(&ctrl->rsp_seq_no,
+				 ctrl->first_req->sequence_no);
+		ctrl->first_req = ctrl->first_req->next;
+		spin_unlock(&ctrl->info_list_lock);
+		return ret;
+	}
+
+	p = ctrl->first_req;
+
+	while (p->next != NULL) {
+		if (cfctrl_req_eq(req, p->next)) {
+			pr_warning("CAIF: %s(): Requests are not "
+					"received in order\n",
+					__func__);
+			ret = p->next;
+			atomic_set(&ctrl->rsp_seq_no,
+					p->next->sequence_no);
+			p->next = p->next->next;
+			spin_unlock(&ctrl->info_list_lock);
+			return ret;
+		}
+		p = p->next;
+	}
+	spin_unlock(&ctrl->info_list_lock);
+
+	pr_warning("CAIF: %s(): Request does not match\n",
+		   __func__);
+	return NULL;
+}
+
+struct cfctrl_rsp *cfctrl_get_respfuncs(struct cflayer *layer)
+{
+	struct cfctrl *this = container_obj(layer);
+	return &this->res;
+}
+
+void cfctrl_set_dnlayer(struct cflayer *this, struct cflayer *dn)
+{
+	this->dn = dn;
+}
+
+void cfctrl_set_uplayer(struct cflayer *this, struct cflayer *up)
+{
+	this->up = up;
+}
+
+static void init_info(struct caif_payload_info *info, struct cfctrl *cfctrl)
+{
+	info->hdr_len = 0;
+	info->channel_id = cfctrl->serv.layer.id;
+	info->dev_info = &cfctrl->serv.dev_info;
+}
+
+void cfctrl_enum_req(struct cflayer *layer, u8 physlinkid)
+{
+	struct cfctrl *cfctrl = container_obj(layer);
+	int ret;
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	if (!pkt) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return;
+	}
+	caif_assert(offsetof(struct cfctrl, serv.layer) == 0);
+	init_info(cfpkt_info(pkt), cfctrl);
+	cfpkt_info(pkt)->dev_info->id = physlinkid;
+	cfctrl->serv.dev_info.id = physlinkid;
+	cfpkt_addbdy(pkt, CFCTRL_CMD_ENUM);
+	cfpkt_addbdy(pkt, physlinkid);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
+	if (ret < 0) {
+		pr_err("CAIF: %s(): Could not transmit enum message\n",
+			__func__);
+		cfpkt_destroy(pkt);
+	}
+}
+
+void cfctrl_linkup_request(struct cflayer *layer,
+			   struct cfctrl_link_param *param,
+			   struct cflayer *user_layer)
+{
+	struct cfctrl *cfctrl = container_obj(layer);
+	u32 tmp32;
+	u16 tmp16;
+	u8 tmp8;
+	struct cfctrl_request_info *req;
+	int ret;
+	char utility_name[16];
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	if (!pkt) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return;
+	}
+	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_SETUP);
+	cfpkt_addbdy(pkt, (param->chtype << 4) + param->linktype);
+	cfpkt_addbdy(pkt, (param->priority << 3) + param->phyid);
+	cfpkt_addbdy(pkt, param->endpoint & 0x03);
+
+	switch (param->linktype) {
+	case CFCTRL_SRV_VEI:
+		break;
+	case CFCTRL_SRV_VIDEO:
+		cfpkt_addbdy(pkt, (u8) param->u.video.connid);
+		break;
+	case CFCTRL_SRV_DBG:
+		break;
+	case CFCTRL_SRV_DATAGRAM:
+		tmp32 = cpu_to_le32(param->u.datagram.connid);
+		cfpkt_add_body(pkt, &tmp32, 4);
+		break;
+	case CFCTRL_SRV_RFM:
+		/* Construct a frame, convert DatagramConnectionID to network
+		 * format long and copy it out...
+		 */
+		tmp32 = cpu_to_le32(param->u.rfm.connid);
+		cfpkt_add_body(pkt, &tmp32, 4);
+		/* Add volume name, including zero termination... */
+		cfpkt_add_body(pkt, param->u.rfm.volume,
+			       strlen(param->u.rfm.volume) + 1);
+		break;
+	case CFCTRL_SRV_UTIL:
+		tmp16 = cpu_to_le16(param->u.utility.fifosize_kb);
+		cfpkt_add_body(pkt, &tmp16, 2);
+		tmp16 = cpu_to_le16(param->u.utility.fifosize_bufs);
+		cfpkt_add_body(pkt, &tmp16, 2);
+		memset(utility_name, 0, sizeof(utility_name));
+		strncpy(utility_name, param->u.utility.name,
+			UTILITY_NAME_LENGTH - 1);
+		cfpkt_add_body(pkt, utility_name, UTILITY_NAME_LENGTH);
+		tmp8 = param->u.utility.paramlen;
+		cfpkt_add_body(pkt, &tmp8, 1);
+		cfpkt_add_body(pkt, param->u.utility.params,
+			       param->u.utility.paramlen);
+		break;
+	default:
+		pr_warning("CAIF: %s():Request setup of bad link type = %d\n",
+			   __func__, param->linktype);
+	}
+	req = kmalloc(sizeof(*req), GFP_KERNEL);
+	if (!req) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return;
+	}
+	memset(req, 0, sizeof(*req));
+	req->client_layer = user_layer;
+	req->cmd = CFCTRL_CMD_LINK_SETUP;
+	req->param = *param;
+	cfctrl_insert_req(cfctrl, req);
+	init_info(cfpkt_info(pkt), cfctrl);
+	cfpkt_info(pkt)->dev_info->id = param->phyid;
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
+	if (ret < 0) {
+		pr_err("CAIF: %s(): Could not transmit linksetup request\n",
+			__func__);
+		cfpkt_destroy(pkt);
+	}
+}
+
+int cfctrl_linkdown_req(struct cflayer *layer, u8 channelid,
+				struct cflayer *client)
+{
+	int ret;
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	if (!pkt) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return -ENOMEM;
+	}
+	cfctrl_insert_req2(cfctrl, CFCTRL_CMD_LINK_DESTROY, channelid, client);
+	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_DESTROY);
+	cfpkt_addbdy(pkt, channelid);
+	init_info(cfpkt_info(pkt), cfctrl);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
+	if (ret < 0) {
+		pr_err("CAIF: %s(): Could not transmit link-down request\n",
+			__func__);
+		cfpkt_destroy(pkt);
+	}
+	return ret;
+}
+
+void cfctrl_sleep_req(struct cflayer *layer)
+{
+	int ret;
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	if (!pkt) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return;
+	}
+	cfpkt_addbdy(pkt, CFCTRL_CMD_SLEEP);
+	init_info(cfpkt_info(pkt), cfctrl);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
+	if (ret < 0)
+		cfpkt_destroy(pkt);
+}
+
+void cfctrl_wake_req(struct cflayer *layer)
+{
+	int ret;
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	if (!pkt) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return;
+	}
+	cfpkt_addbdy(pkt, CFCTRL_CMD_WAKE);
+	init_info(cfpkt_info(pkt), cfctrl);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
+	if (ret < 0)
+		cfpkt_destroy(pkt);
+}
+
+void cfctrl_getstartreason_req(struct cflayer *layer)
+{
+	int ret;
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	if (!pkt) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return;
+	}
+	cfpkt_addbdy(pkt, CFCTRL_CMD_START_REASON);
+	init_info(cfpkt_info(pkt), cfctrl);
+	ret =
+	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
+	if (ret < 0)
+		cfpkt_destroy(pkt);
+}
+
+
+static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
+{
+	u8 cmdrsp;
+	u8 cmd;
+	int ret = -1;
+	u16 tmp16;
+	u8 len;
+	u8 param[255];
+	u8 linkid;
+	struct cfctrl *cfctrl = container_obj(layer);
+	struct cfctrl_request_info rsp, *req;
+
+
+	cfpkt_extr_head(pkt, &cmdrsp, 1);
+	cmd = cmdrsp & CFCTRL_CMD_MASK;
+	if (cmd != CFCTRL_CMD_LINK_ERR
+	    && CFCTRL_RSP_BIT != (CFCTRL_RSP_BIT & cmdrsp)) {
+		if (handle_loop(cfctrl, cmd, pkt) == CAIF_FAILURE) {
+			pr_info("CAIF: %s() CAIF Protocol error:"
+				"Response bit not set\n", __func__);
+			goto error;
+		}
+	}
+
+	switch (cmd) {
+	case CFCTRL_CMD_LINK_SETUP:
+		{
+			enum cfctrl_srv serv;
+			enum cfctrl_srv servtype;
+			u8 endpoint;
+			u8 physlinkid;
+			u8 prio;
+			u8 tmp;
+			u32 tmp32;
+			u8 *cp;
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
+				    le32_to_cpu(tmp32);
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
+				  le32_to_cpu(tmp32);
+				cp = (u8 *) linkparam.u.rfm.volume;
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
+				    le16_to_cpu(tmp16);
+				/* Fifosize bufs */
+				cfpkt_extr_head(pkt, &tmp16, 2);
+				linkparam.u.utility.fifosize_bufs =
+				    le16_to_cpu(tmp16);
+				/* name */
+				cp = (u8 *) linkparam.u.utility.name;
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
+				pr_warning("CAIF: %s(): Request setup "
+					   "- invalid link type (%d)",
+					   __func__, serv);
+				goto error;
+			}
+
+			rsp.cmd = cmd;
+			rsp.param = linkparam;
+			req = cfctrl_remove_req(cfctrl, &rsp);
+
+			if (CFCTRL_ERR_BIT == (CFCTRL_ERR_BIT & cmdrsp) ||
+				cfpkt_erroneous(pkt)) {
+				pr_err("CAIF: %s(): Invalid O/E bit or parse "
+				       "error on CAIF control channel",
+					__func__);
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
+				kfree(req);
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
+			kfree(req);
+		break;
+	case CFCTRL_CMD_LINK_ERR:
+		pr_err("CAIF: %s(): Frame Error Indication received\n",
+			__func__);
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
+		pr_err("CAIF: %s(): Unrecognized Control Frame\n", __func__);
+		goto error;
+		break;
+	}
+	ret = 0;
+error:
+	cfpkt_destroy(pkt);
+	return ret;
+}
+
+static void cfctrl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
+			int phyid)
+{
+	struct cfctrl *this = container_obj(layr);
+	switch (ctrl) {
+	case _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND:
+	case CAIF_CTRLCMD_FLOW_OFF_IND:
+		spin_lock(&this->info_list_lock);
+		if (this->first_req != NULL) {
+			pr_warning("CAIF: %s(): Received flow off in "
+				   "control layer", __func__);
+		}
+		spin_unlock(&this->info_list_lock);
+		break;
+	default:
+		break;
+	}
+}
+
+#ifndef CAIF_NO_LOOP
+static int handle_loop(struct cfctrl *ctrl, int cmd, struct cfpkt *pkt)
+{
+	static int last_linkid;
+	u8 linkid, linktype, tmp;
+	switch (cmd) {
+	case CFCTRL_CMD_LINK_SETUP:
+		spin_lock(&ctrl->loop_linkid_lock);
+		for (linkid = last_linkid + 1; linkid < 255; linkid++)
+			if (!ctrl->loop_linkused[linkid])
+				goto found;
+		for (linkid = last_linkid - 1; linkid > 0; linkid--)
+			if (!ctrl->loop_linkused[linkid])
+				goto found;
+		spin_unlock(&ctrl->loop_linkid_lock);
+		return -EINVAL;
+found:
+		if (!ctrl->loop_linkused[linkid])
+			ctrl->loop_linkused[linkid] = 1;
+
+		last_linkid = linkid;
+
+		cfpkt_add_trail(pkt, &linkid, 1);
+		spin_unlock(&ctrl->loop_linkid_lock);
+		cfpkt_peek_head(pkt, &linktype, 1);
+		if (linktype ==  CFCTRL_SRV_UTIL) {
+			tmp = 0x01;
+			cfpkt_add_trail(pkt, &tmp, 1);
+			cfpkt_add_trail(pkt, &tmp, 1);
+		}
+		break;
+
+	case CFCTRL_CMD_LINK_DESTROY:
+		spin_lock(&ctrl->loop_linkid_lock);
+		cfpkt_peek_head(pkt, &linkid, 1);
+		ctrl->loop_linkused[linkid] = 0;
+		spin_unlock(&ctrl->loop_linkid_lock);
+		break;
+	default:
+		break;
+	}
+	return CAIF_SUCCESS;
+}
+#endif
diff --git a/net/caif/cfdbgl.c b/net/caif/cfdbgl.c
new file mode 100644
index 0000000..ab6b6dc
--- /dev/null
+++ b/net/caif/cfdbgl.c
@@ -0,0 +1,40 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/stddef.h>
+#include <linux/slab.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfsrvl.h>
+#include <net/caif/cfpkt.h>
+
+static int cfdbgl_receive(struct cflayer *layr, struct cfpkt *pkt);
+static int cfdbgl_transmit(struct cflayer *layr, struct cfpkt *pkt);
+
+struct cflayer *cfdbgl_create(u8 channel_id, struct dev_info *dev_info)
+{
+	struct cfsrvl *dbg = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	if (!dbg) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return NULL;
+	}
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+	memset(dbg, 0, sizeof(struct cfsrvl));
+	cfsrvl_init(dbg, channel_id, dev_info);
+	dbg->layer.receive = cfdbgl_receive;
+	dbg->layer.transmit = cfdbgl_transmit;
+	snprintf(dbg->layer.name, CAIF_LAYER_NAME_SZ - 1, "dbg%d", channel_id);
+	return &dbg->layer;
+}
+
+static int cfdbgl_receive(struct cflayer *layr, struct cfpkt *pkt)
+{
+	return layr->up->receive(layr->up, pkt);
+}
+
+static int cfdbgl_transmit(struct cflayer *layr, struct cfpkt *pkt)
+{
+	return layr->dn->transmit(layr->dn, pkt);
+}
diff --git a/net/caif/cfdgml.c b/net/caif/cfdgml.c
new file mode 100644
index 0000000..5319484
--- /dev/null
+++ b/net/caif/cfdgml.c
@@ -0,0 +1,108 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/stddef.h>
+#include <linux/spinlock.h>
+#include <linux/slab.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfsrvl.h>
+#include <net/caif/cfpkt.h>
+
+#define container_obj(layr) ((struct cfsrvl *) layr)
+
+#define DGM_CMD_BIT  0x80
+#define DGM_FLOW_OFF 0x81
+#define DGM_FLOW_ON  0x80
+#define DGM_CTRL_PKT_SIZE 1
+
+static int cfdgml_receive(struct cflayer *layr, struct cfpkt *pkt);
+static int cfdgml_transmit(struct cflayer *layr, struct cfpkt *pkt);
+
+struct cflayer *cfdgml_create(u8 channel_id, struct dev_info *dev_info)
+{
+	struct cfsrvl *dgm = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	if (!dgm) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return NULL;
+	}
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+	memset(dgm, 0, sizeof(struct cfsrvl));
+	cfsrvl_init(dgm, channel_id, dev_info);
+	dgm->layer.receive = cfdgml_receive;
+	dgm->layer.transmit = cfdgml_transmit;
+	snprintf(dgm->layer.name, CAIF_LAYER_NAME_SZ - 1, "dgm%d", channel_id);
+	dgm->layer.name[CAIF_LAYER_NAME_SZ - 1] = '\0';
+	return &dgm->layer;
+}
+
+static int cfdgml_receive(struct cflayer *layr, struct cfpkt *pkt)
+{
+	u8 cmd = -1;
+	u8 dgmhdr[3];
+	int ret;
+	caif_assert(layr->up != NULL);
+	caif_assert(layr->receive != NULL);
+	caif_assert(layr->ctrlcmd != NULL);
+
+	if (cfpkt_extr_head(pkt, &cmd, 1) < 0) {
+		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		cfpkt_destroy(pkt);
+		return -EPROTO;
+	}
+
+	if ((cmd & DGM_CMD_BIT) == 0) {
+		if (cfpkt_extr_head(pkt, &dgmhdr, 3) < 0) {
+			pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+			cfpkt_destroy(pkt);
+			return -EPROTO;
+		}
+		ret = layr->up->receive(layr->up, pkt);
+		return ret;
+	}
+
+	switch (cmd) {
+	case DGM_FLOW_OFF:	/* FLOW OFF */
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_FLOW_OFF_IND, 0);
+		cfpkt_destroy(pkt);
+		return 0;
+	case DGM_FLOW_ON:	/* FLOW ON */
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_FLOW_ON_IND, 0);
+		cfpkt_destroy(pkt);
+		return 0;
+	default:
+		cfpkt_destroy(pkt);
+		pr_info("CAIF: %s(): Unknown datagram control %d (0x%x)\n",
+			__func__, cmd, cmd);
+		return -EPROTO;
+	}
+}
+
+static int cfdgml_transmit(struct cflayer *layr, struct cfpkt *pkt)
+{
+	u32 zero = 0;
+	struct caif_payload_info *info;
+	struct cfsrvl *service = container_obj(layr);
+	int ret;
+	if (!cfsrvl_ready(service, &ret))
+		return ret;
+
+	cfpkt_add_head(pkt, &zero, 4);
+
+	/* Add info for MUX-layer to route the packet out. */
+	info = cfpkt_info(pkt);
+	info->channel_id = service->layer.id;
+	/* To optimize alignment, we add up the size of CAIF header
+	 * before payload.
+	 */
+	info->hdr_len = 4;
+	info->dev_info = &service->dev_info;
+	ret = layr->dn->transmit(layr->dn, pkt);
+	if (ret < 0) {
+		u32 tmp32;
+		cfpkt_extr_head(pkt, &tmp32, 4);
+	}
+	return ret;
+}
diff --git a/net/caif/cffrml.c b/net/caif/cffrml.c
new file mode 100644
index 0000000..e86a4ca
--- /dev/null
+++ b/net/caif/cffrml.c
@@ -0,0 +1,151 @@
+/*
+ * CAIF Framing Layer.
+ *
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/stddef.h>
+#include <linux/spinlock.h>
+#include <linux/slab.h>
+#include <linux/crc-ccitt.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfpkt.h>
+#include <net/caif/cffrml.h>
+
+#define container_obj(layr) container_of(layr, struct cffrml, layer)
+
+struct cffrml {
+	struct cflayer layer;
+	bool dofcs;		/* !< FCS active */
+};
+
+static int cffrml_receive(struct cflayer *layr, struct cfpkt *pkt);
+static int cffrml_transmit(struct cflayer *layr, struct cfpkt *pkt);
+static void cffrml_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
+				int phyid);
+
+static u32 cffrml_rcv_error;
+static u32 cffrml_rcv_checsum_error;
+struct cflayer *cffrml_create(u16 phyid, bool use_fcs)
+{
+	struct cffrml *this = kmalloc(sizeof(struct cffrml), GFP_ATOMIC);
+	if (!this) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return NULL;
+	}
+	caif_assert(offsetof(struct cffrml, layer) == 0);
+
+	memset(this, 0, sizeof(struct cflayer));
+	this->layer.receive = cffrml_receive;
+	this->layer.transmit = cffrml_transmit;
+	this->layer.ctrlcmd = cffrml_ctrlcmd;
+	snprintf(this->layer.name, CAIF_LAYER_NAME_SZ, "frm%d", phyid);
+	this->dofcs = use_fcs;
+	this->layer.id = phyid;
+	return (struct cflayer *) this;
+}
+
+void cffrml_set_uplayer(struct cflayer *this, struct cflayer *up)
+{
+	this->up = up;
+}
+
+void cffrml_set_dnlayer(struct cflayer *this, struct cflayer *dn)
+{
+	this->dn = dn;
+}
+
+static u16 cffrml_checksum(u16 chks, void *buf, u16 len)
+{
+	/* FIXME: FCS should be moved to glue in order to use OS-Specific
+	 * solutions
+	 */
+	return crc_ccitt(chks, buf, len);
+}
+
+static int cffrml_receive(struct cflayer *layr, struct cfpkt *pkt)
+{
+	u16 tmp;
+	u16 len;
+	u16 hdrchks;
+	u16 pktchks;
+	struct cffrml *this;
+	this = container_obj(layr);
+
+	cfpkt_extr_head(pkt, &tmp, 2);
+	len = le16_to_cpu(tmp);
+
+	/* Subtract for FCS on length if FCS is not used. */
+	if (!this->dofcs)
+		len -= 2;
+
+	if (cfpkt_setlen(pkt, len) < 0) {
+		++cffrml_rcv_error;
+		pr_err("CAIF: %s():Framing length error (%d)\n", __func__, len);
+		cfpkt_destroy(pkt);
+		return -EPROTO;
+	}
+	/*
+	 * Don't do extract if FCS is false, rather do setlen - then we don't
+	 * get a cache-miss.
+	 */
+	if (this->dofcs) {
+		cfpkt_extr_trail(pkt, &tmp, 2);
+		hdrchks = le16_to_cpu(tmp);
+		pktchks = cfpkt_iterate(pkt, cffrml_checksum, 0xffff);
+		if (pktchks != hdrchks) {
+			cfpkt_add_trail(pkt, &tmp, 2);
+			++cffrml_rcv_error;
+			++cffrml_rcv_checsum_error;
+			pr_info("CAIF: %s(): Frame checksum error "
+				"(0x%x != 0x%x)\n", __func__, hdrchks, pktchks);
+			return -EILSEQ;
+		}
+	}
+	if (cfpkt_erroneous(pkt)) {
+		++cffrml_rcv_error;
+		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		cfpkt_destroy(pkt);
+		return -EPROTO;
+	}
+	return layr->up->receive(layr->up, pkt);
+}
+
+static int cffrml_transmit(struct cflayer *layr, struct cfpkt *pkt)
+{
+	int tmp;
+	u16 chks;
+	u16 len;
+	int ret;
+	struct cffrml *this = container_obj(layr);
+	if (this->dofcs) {
+		chks = cfpkt_iterate(pkt, cffrml_checksum, 0xffff);
+		tmp = cpu_to_le16(chks);
+		cfpkt_add_trail(pkt, &tmp, 2);
+	} else {
+		cfpkt_pad_trail(pkt, 2);
+	}
+	len = cfpkt_getlen(pkt);
+	tmp = cpu_to_le16(len);
+	cfpkt_add_head(pkt, &tmp, 2);
+	cfpkt_info(pkt)->hdr_len += 2;
+	if (cfpkt_erroneous(pkt)) {
+		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		return -EPROTO;
+	}
+	ret = layr->dn->transmit(layr->dn, pkt);
+	if (ret < 0) {
+		/* Remove header on faulty packet. */
+		cfpkt_extr_head(pkt, &tmp, 2);
+	}
+	return ret;
+}
+
+static void cffrml_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
+					int phyid)
+{
+	if (layr->up->ctrlcmd)
+		layr->up->ctrlcmd(layr->up, ctrl, layr->id);
+}
diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
new file mode 100644
index 0000000..6fb9f9e
--- /dev/null
+++ b/net/caif/cfmuxl.c
@@ -0,0 +1,246 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+#include <linux/stddef.h>
+#include <linux/spinlock.h>
+#include <linux/slab.h>
+#include <net/caif/cfpkt.h>
+#include <net/caif/cfmuxl.h>
+#include <net/caif/cfsrvl.h>
+#include <net/caif/cffrml.h>
+
+#define container_obj(layr) container_of(layr, struct cfmuxl, layer)
+
+#define CAIF_CTRL_CHANNEL 0
+#define UP_CACHE_SIZE 8
+#define DN_CACHE_SIZE 8
+
+struct cfmuxl {
+	struct cflayer layer;
+	struct list_head srvl_list;
+	struct list_head frml_list;
+	struct cflayer *up_cache[UP_CACHE_SIZE];
+	struct cflayer *dn_cache[DN_CACHE_SIZE];
+	/*
+	 * Set when inserting or removing downwards layers.
+	 */
+	spinlock_t transmit_lock;
+
+	/*
+	 * Set when inserting or removing upwards layers.
+	 */
+	spinlock_t receive_lock;
+
+};
+
+static int cfmuxl_receive(struct cflayer *layr, struct cfpkt *pkt);
+static int cfmuxl_transmit(struct cflayer *layr, struct cfpkt *pkt);
+static void cfmuxl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
+				int phyid);
+static struct cflayer *get_up(struct cfmuxl *muxl, u16 id);
+
+struct cflayer *cfmuxl_create(void)
+{
+	struct cfmuxl *this = kmalloc(sizeof(struct cfmuxl), GFP_ATOMIC);
+	if (!this)
+		return NULL;
+	memset(this, 0, sizeof(*this));
+	this->layer.receive = cfmuxl_receive;
+	this->layer.transmit = cfmuxl_transmit;
+	this->layer.ctrlcmd = cfmuxl_ctrlcmd;
+	INIT_LIST_HEAD(&this->srvl_list);
+	INIT_LIST_HEAD(&this->frml_list);
+	spin_lock_init(&this->transmit_lock);
+	spin_lock_init(&this->receive_lock);
+	snprintf(this->layer.name, CAIF_LAYER_NAME_SZ, "mux");
+	return &this->layer;
+}
+
+int cfmuxl_set_uplayer(struct cflayer *layr, struct cflayer *up, u8 linkid)
+{
+	struct cfmuxl *muxl = container_obj(layr);
+	spin_lock(&muxl->receive_lock);
+	list_add(&up->node, &muxl->srvl_list);
+	spin_unlock(&muxl->receive_lock);
+	return 0;
+}
+
+bool cfmuxl_is_phy_inuse(struct cflayer *layr, u8 phyid)
+{
+	struct list_head *node;
+	struct cflayer *layer;
+	struct cfmuxl *muxl = container_obj(layr);
+	bool match = false;
+	spin_lock(&muxl->receive_lock);
+
+	list_for_each(node, &muxl->srvl_list) {
+		layer = list_entry(node, struct cflayer, node);
+		if (cfsrvl_phyid_match(layer, phyid)) {
+			match = true;
+			break;
+		}
+
+	}
+	spin_unlock(&muxl->receive_lock);
+	return match;
+}
+
+u8 cfmuxl_get_phyid(struct cflayer *layr, u8 channel_id)
+{
+	struct cflayer *up;
+	int phyid;
+	struct cfmuxl *muxl = container_obj(layr);
+	spin_lock(&muxl->receive_lock);
+	up = get_up(muxl, channel_id);
+	if (up != NULL)
+		phyid = cfsrvl_getphyid(up);
+	else
+		phyid = 0;
+	spin_unlock(&muxl->receive_lock);
+	return phyid;
+}
+
+int cfmuxl_set_dnlayer(struct cflayer *layr, struct cflayer *dn, u8 phyid)
+{
+	struct cfmuxl *muxl = (struct cfmuxl *) layr;
+	spin_lock(&muxl->transmit_lock);
+	list_add(&dn->node, &muxl->frml_list);
+	spin_unlock(&muxl->transmit_lock);
+	return 0;
+}
+
+static struct cflayer *get_from_id(struct list_head *list, u16 id)
+{
+	struct list_head *node;
+	struct cflayer *layer;
+	list_for_each(node, list) {
+		layer = list_entry(node, struct cflayer, node);
+		if (layer->id == id)
+			return layer;
+	}
+	return NULL;
+}
+
+struct cflayer *cfmuxl_remove_dnlayer(struct cflayer *layr, u8 phyid)
+{
+	struct cfmuxl *muxl = container_obj(layr);
+	struct cflayer *dn;
+	spin_lock(&muxl->transmit_lock);
+	memset(muxl->dn_cache, 0, sizeof(muxl->dn_cache));
+	dn = get_from_id(&muxl->frml_list, phyid);
+	if (dn == NULL) {
+		spin_unlock(&muxl->transmit_lock);
+		return NULL;
+	}
+	list_del(&dn->node);
+	caif_assert(dn != NULL);
+	spin_unlock(&muxl->transmit_lock);
+	return dn;
+}
+
+/* Invariant: lock is taken */
+static struct cflayer *get_up(struct cfmuxl *muxl, u16 id)
+{
+	struct cflayer *up;
+	int idx = id % UP_CACHE_SIZE;
+	up = muxl->up_cache[idx];
+	if (up == NULL || up->id != id) {
+		up = get_from_id(&muxl->srvl_list, id);
+		muxl->up_cache[idx] = up;
+	}
+	return up;
+}
+
+/* Invariant: lock is taken */
+static struct cflayer *get_dn(struct cfmuxl *muxl, struct dev_info *dev_info)
+{
+	struct cflayer *dn;
+	int idx = dev_info->id % DN_CACHE_SIZE;
+	dn = muxl->dn_cache[idx];
+	if (dn == NULL || dn->id != dev_info->id) {
+		dn = get_from_id(&muxl->frml_list, dev_info->id);
+		muxl->dn_cache[idx] = dn;
+	}
+	return dn;
+}
+
+struct cflayer *cfmuxl_remove_uplayer(struct cflayer *layr, u8 id)
+{
+	struct cflayer *up;
+	struct cfmuxl *muxl = container_obj(layr);
+	spin_lock(&muxl->receive_lock);
+	up = get_up(muxl, id);
+	memset(muxl->up_cache, 0, sizeof(muxl->up_cache));
+	list_del(&up->node);
+	spin_unlock(&muxl->receive_lock);
+	return up;
+}
+
+static int cfmuxl_receive(struct cflayer *layr, struct cfpkt *pkt)
+{
+	int ret;
+	struct cfmuxl *muxl = container_obj(layr);
+	u8 id;
+	struct cflayer *up;
+	if (cfpkt_extr_head(pkt, &id, 1) < 0) {
+		pr_err("CAIF: %s(): erroneous Caif Packet\n", __func__);
+		cfpkt_destroy(pkt);
+		return -EPROTO;
+	}
+
+	spin_lock(&muxl->receive_lock);
+	up = get_up(muxl, id);
+	spin_unlock(&muxl->receive_lock);
+	if (up == NULL) {
+		pr_info("CAIF: %s():Received data on unknown link ID = %d "
+			"(0x%x)	 up == NULL", __func__, id, id);
+		cfpkt_destroy(pkt);
+		/*
+		 * Don't return ERROR, since modem misbehaves and sends out
+		 * flow on before linksetup response.
+		 */
+		return /* CFGLU_EPROT; */ 0;
+	}
+
+	ret = up->receive(up, pkt);
+	return ret;
+}
+
+static int cfmuxl_transmit(struct cflayer *layr, struct cfpkt *pkt)
+{
+	int ret;
+	struct cfmuxl *muxl = container_obj(layr);
+	u8 linkid;
+	struct cflayer *dn;
+	struct caif_payload_info *info = cfpkt_info(pkt);
+	dn = get_dn(muxl, cfpkt_info(pkt)->dev_info);
+	if (dn == NULL) {
+		pr_warning("CAIF: %s(): Send data on unknown phy "
+			   "ID = %d (0x%x)\n",
+			   __func__, info->dev_info->id, info->dev_info->id);
+		return -ENOTCONN;
+	}
+	info->hdr_len += 1;
+	linkid = info->channel_id;
+	cfpkt_add_head(pkt, &linkid, 1);
+	ret = dn->transmit(dn, pkt);
+	/* Remove MUX protocol header upon error. */
+	if (ret < 0)
+		cfpkt_extr_head(pkt, &linkid, 1);
+	return ret;
+}
+
+static void cfmuxl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
+				int phyid)
+{
+	struct cfmuxl *muxl = container_obj(layr);
+	struct list_head *node;
+	struct cflayer *layer;
+	list_for_each(node, &muxl->srvl_list) {
+		layer = list_entry(node, struct cflayer, node);
+		if (cfsrvl_phyid_match(layer, phyid))
+			layer->ctrlcmd(layer, ctrl, phyid);
+	}
+}
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
new file mode 100644
index 0000000..cd2830f
--- /dev/null
+++ b/net/caif/cfrfml.c
@@ -0,0 +1,108 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/stddef.h>
+#include <linux/spinlock.h>
+#include <linux/slab.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfsrvl.h>
+#include <net/caif/cfpkt.h>
+
+#define container_obj(layr) container_of(layr, struct cfsrvl, layer)
+
+#define RFM_SEGMENTATION_BIT 0x01
+#define RFM_PAYLOAD  0x00
+#define RFM_CMD_BIT  0x80
+#define RFM_FLOW_OFF 0x81
+#define RFM_FLOW_ON  0x80
+#define RFM_SET_PIN  0x82
+#define RFM_CTRL_PKT_SIZE 1
+
+static int cfrfml_receive(struct cflayer *layr, struct cfpkt *pkt);
+static int cfrfml_transmit(struct cflayer *layr, struct cfpkt *pkt);
+static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl);
+
+struct cflayer *cfrfml_create(u8 channel_id, struct dev_info *dev_info)
+{
+	struct cfsrvl *rfm = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	if (!rfm) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return NULL;
+	}
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+	memset(rfm, 0, sizeof(struct cfsrvl));
+	cfsrvl_init(rfm, channel_id, dev_info);
+	rfm->layer.modemcmd = cfservl_modemcmd;
+	rfm->layer.receive = cfrfml_receive;
+	rfm->layer.transmit = cfrfml_transmit;
+	snprintf(rfm->layer.name, CAIF_LAYER_NAME_SZ, "rfm%d", channel_id);
+	return &rfm->layer;
+}
+
+static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
+{
+       return -EPROTO;
+}
+
+static int cfrfml_receive(struct cflayer *layr, struct cfpkt *pkt)
+{
+	u8 tmp;
+	bool segmented;
+	int ret;
+	caif_assert(layr->up != NULL);
+	caif_assert(layr->receive != NULL);
+
+	/*
+	 * RFM is taking care of segmentation and stripping of
+	 * segmentation bit.
+	 */
+	if (cfpkt_extr_head(pkt, &tmp, 1) < 0) {
+		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		cfpkt_destroy(pkt);
+		return -EPROTO;
+	}
+	segmented = tmp & RFM_SEGMENTATION_BIT;
+	caif_assert(!segmented);
+
+	ret = layr->up->receive(layr->up, pkt);
+	return ret;
+}
+
+static int cfrfml_transmit(struct cflayer *layr, struct cfpkt *pkt)
+{
+	u8 tmp = 0;
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
+		pr_err("CAIF: %s():Packet too large - size=%d\n",
+			__func__, cfpkt_getlen(pkt));
+		return -EOVERFLOW;
+	}
+	if (cfpkt_add_head(pkt, &tmp, 1) < 0) {
+		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		return -EPROTO;
+	}
+
+	/* Add info for MUX-layer to route the packet out. */
+	cfpkt_info(pkt)->channel_id = service->layer.id;
+	/*
+	 * To optimize alignment, we add up the size of CAIF header before
+	 * payload.
+	 */
+	cfpkt_info(pkt)->hdr_len = 1;
+	cfpkt_info(pkt)->dev_info = &service->dev_info;
+	ret = layr->dn->transmit(layr->dn, pkt);
+	if (ret < 0)
+		cfpkt_extr_head(pkt, &tmp, 1);
+	return ret;
+}
diff --git a/net/caif/cfserl.c b/net/caif/cfserl.c
new file mode 100644
index 0000000..06029ea
--- /dev/null
+++ b/net/caif/cfserl.c
@@ -0,0 +1,192 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/stddef.h>
+#include <linux/spinlock.h>
+#include <linux/slab.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfpkt.h>
+#include <net/caif/cfserl.h>
+
+#define container_obj(layr) ((struct cfserl *) layr)
+
+#define CFSERL_STX 0x02
+#define CAIF_MINIUM_PACKET_SIZE 4
+struct cfserl {
+	struct cflayer layer;
+	struct cfpkt *incomplete_frm;
+	/* Protects parallel processing of incoming packets */
+	spinlock_t sync;
+	bool usestx;
+};
+#define STXLEN(layr) (layr->usestx ? 1 : 0)
+
+static int cfserl_receive(struct cflayer *layr, struct cfpkt *pkt);
+static int cfserl_transmit(struct cflayer *layr, struct cfpkt *pkt);
+static void cfserl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
+				int phyid);
+
+struct cflayer *cfserl_create(int type, int instance, bool use_stx)
+{
+	struct cfserl *this = kmalloc(sizeof(struct cfserl), GFP_ATOMIC);
+	if (!this) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return NULL;
+	}
+	caif_assert(offsetof(struct cfserl, layer) == 0);
+	memset(this, 0, sizeof(struct cfserl));
+	this->layer.receive = cfserl_receive;
+	this->layer.transmit = cfserl_transmit;
+	this->layer.ctrlcmd = cfserl_ctrlcmd;
+	this->layer.type = type;
+	this->usestx = use_stx;
+	spin_lock_init(&this->sync);
+	snprintf(this->layer.name, CAIF_LAYER_NAME_SZ, "ser1");
+	return &this->layer;
+}
+
+static int cfserl_receive(struct cflayer *l, struct cfpkt *newpkt)
+{
+	struct cfserl *layr = container_obj(l);
+	u16 pkt_len;
+	struct cfpkt *pkt = NULL;
+	struct cfpkt *tail_pkt = NULL;
+	u8 tmp8;
+	u16 tmp;
+	u8 stx = CFSERL_STX;
+	int ret;
+	u16 expectlen = 0;
+	caif_assert(newpkt != NULL);
+	spin_lock(&layr->sync);
+
+	if (layr->incomplete_frm != NULL) {
+
+		layr->incomplete_frm =
+		    cfpkt_append(layr->incomplete_frm, newpkt, expectlen);
+		pkt = layr->incomplete_frm;
+	} else {
+		pkt = newpkt;
+	}
+	layr->incomplete_frm = NULL;
+
+	do {
+		/* Search for STX at start of pkt if STX is used */
+		if (layr->usestx) {
+			cfpkt_extr_head(pkt, &tmp8, 1);
+			if (tmp8 != CFSERL_STX) {
+				while (cfpkt_more(pkt)
+				       && tmp8 != CFSERL_STX) {
+					cfpkt_extr_head(pkt, &tmp8, 1);
+				}
+				if (!cfpkt_more(pkt)) {
+					cfpkt_destroy(pkt);
+					layr->incomplete_frm = NULL;
+					spin_unlock(&layr->sync);
+					return -EPROTO;
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
+			spin_unlock(&layr->sync);
+			return 0;
+		}
+
+		/*
+		 *  Find length of frame.
+		 *  expectlen is the length we need for a full frame.
+		 */
+		cfpkt_peek_head(pkt, &tmp, 2);
+		expectlen = le16_to_cpu(tmp) + 2;
+		/*
+		 * Frame error handling
+		 */
+		if (expectlen < CAIF_MINIUM_PACKET_SIZE
+		    || expectlen > CAIF_MAX_FRAMESIZE) {
+			if (!layr->usestx) {
+				if (pkt != NULL)
+					cfpkt_destroy(pkt);
+				layr->incomplete_frm = NULL;
+				expectlen = 0;
+				spin_unlock(&layr->sync);
+				return -EPROTO;
+			}
+			continue;
+		}
+
+		if (pkt_len < expectlen) {
+			/* Too little received data */
+			if (layr->usestx)
+				cfpkt_add_head(pkt, &stx, 1);
+			layr->incomplete_frm = pkt;
+			spin_unlock(&layr->sync);
+			return 0;
+		}
+
+		/*
+		 * Enough data for at least one frame.
+		 * Split the frame, if too long
+		 */
+		if (pkt_len > expectlen)
+			tail_pkt = cfpkt_split(pkt, expectlen);
+		else
+			tail_pkt = NULL;
+
+		/* Send the first part of packet upwards.*/
+		spin_unlock(&layr->sync);
+		ret = layr->layer.up->receive(layr->layer.up, pkt);
+		spin_lock(&layr->sync);
+		if (ret == -EILSEQ) {
+			if (layr->usestx) {
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
+	spin_unlock(&layr->sync);
+	return 0;
+}
+
+static int cfserl_transmit(struct cflayer *layer, struct cfpkt *newpkt)
+{
+	struct cfserl *layr = container_obj(layer);
+	int ret;
+	u8 tmp8 = CFSERL_STX;
+	if (layr->usestx)
+		cfpkt_add_head(newpkt, &tmp8, 1);
+	ret = layer->dn->transmit(layer->dn, newpkt);
+	if (ret < 0)
+		cfpkt_extr_head(newpkt, &tmp8, 1);
+
+	return ret;
+}
+
+static void cfserl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
+				int phyid)
+{
+	layr->up->ctrlcmd(layr->up, ctrl, phyid);
+}
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
new file mode 100644
index 0000000..d470c51
--- /dev/null
+++ b/net/caif/cfsrvl.c
@@ -0,0 +1,185 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfsrvl.h>
+#include <net/caif/cfpkt.h>
+
+#define SRVL_CTRL_PKT_SIZE 1
+#define SRVL_FLOW_OFF 0x81
+#define SRVL_FLOW_ON  0x80
+#define SRVL_SET_PIN  0x82
+#define SRVL_CTRL_PKT_SIZE 1
+
+#define container_obj(layr) container_of(layr, struct cfsrvl, layer)
+
+static void cfservl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
+				int phyid)
+{
+	struct cfsrvl *service = container_obj(layr);
+	caif_assert(layr->up != NULL);
+	caif_assert(layr->up->ctrlcmd != NULL);
+	switch (ctrl) {
+	case CAIF_CTRLCMD_INIT_RSP:
+		service->open = true;
+		layr->up->ctrlcmd(layr->up, ctrl, phyid);
+		break;
+	case CAIF_CTRLCMD_DEINIT_RSP:
+	case CAIF_CTRLCMD_INIT_FAIL_RSP:
+		service->open = false;
+		layr->up->ctrlcmd(layr->up, ctrl, phyid);
+		break;
+	case _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND:
+		if (phyid != service->dev_info.id)
+			break;
+		if (service->modem_flow_on)
+			layr->up->ctrlcmd(layr->up,
+					  CAIF_CTRLCMD_FLOW_OFF_IND, phyid);
+		service->phy_flow_on = false;
+		break;
+	case _CAIF_CTRLCMD_PHYIF_FLOW_ON_IND:
+		if (phyid != service->dev_info.id)
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
+		pr_warning("CAIF: %s(): "
+			   "Unexpected ctrl in cfsrvl (%d)\n", __func__, ctrl);
+		/* We have both modem and phy flow on, send flow on */
+		layr->up->ctrlcmd(layr->up, ctrl, phyid);
+		service->phy_flow_on = true;
+		break;
+	}
+}
+
+static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
+{
+	struct cfsrvl *service = container_obj(layr);
+	caif_assert(layr != NULL);
+	caif_assert(layr->dn != NULL);
+	caif_assert(layr->dn->transmit != NULL);
+	switch (ctrl) {
+	case CAIF_MODEMCMD_FLOW_ON_REQ:
+		{
+			struct cfpkt *pkt;
+			struct caif_payload_info *info;
+			u8 flow_on = SRVL_FLOW_ON;
+			pkt = cfpkt_create(SRVL_CTRL_PKT_SIZE);
+			if (!pkt) {
+				pr_warning("CAIF: %s(): Out of memory\n",
+					__func__);
+				return -ENOMEM;
+			}
+
+			if (cfpkt_add_head(pkt, &flow_on, 1) < 0) {
+				pr_err("CAIF: %s(): Packet is erroneous!\n",
+					__func__);
+				cfpkt_destroy(pkt);
+				return -EPROTO;
+			}
+			info = cfpkt_info(pkt);
+			info->channel_id = service->layer.id;
+			info->hdr_len = 1;
+			info->dev_info = &service->dev_info;
+			return layr->dn->transmit(layr->dn, pkt);
+		}
+	case CAIF_MODEMCMD_FLOW_OFF_REQ:
+		{
+			struct cfpkt *pkt;
+			struct caif_payload_info *info;
+			u8 flow_off = SRVL_FLOW_OFF;
+			pkt = cfpkt_create(SRVL_CTRL_PKT_SIZE);
+			if (cfpkt_add_head(pkt, &flow_off, 1) < 0) {
+				pr_err("CAIF: %s(): Packet is erroneous!\n",
+					__func__);
+				cfpkt_destroy(pkt);
+				return -EPROTO;
+			}
+			info = cfpkt_info(pkt);
+			info->channel_id = service->layer.id;
+			info->hdr_len = 1;
+			info->dev_info = &service->dev_info;
+			return layr->dn->transmit(layr->dn, pkt);
+		}
+	default:
+	  break;
+	}
+	return -EINVAL;
+}
+
+void cfservl_destroy(struct cflayer *layer)
+{
+	kfree(layer);
+}
+
+void cfsrvl_init(struct cfsrvl *service,
+		 u8 channel_id,
+		 struct dev_info *dev_info)
+{
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+	service->open = false;
+	service->modem_flow_on = true;
+	service->phy_flow_on = true;
+	service->layer.id = channel_id;
+	service->layer.ctrlcmd = cfservl_ctrlcmd;
+	service->layer.modemcmd = cfservl_modemcmd;
+	service->dev_info = *dev_info;
+}
+
+bool cfsrvl_ready(struct cfsrvl *service, int *err)
+{
+	if (service->open && service->modem_flow_on && service->phy_flow_on)
+		return true;
+	if (!service->open) {
+		*err = -ENOTCONN;
+		return false;
+	}
+	caif_assert(!(service->modem_flow_on && service->phy_flow_on));
+	*err = -EAGAIN;
+	return false;
+}
+u8 cfsrvl_getphyid(struct cflayer *layer)
+{
+	struct cfsrvl *servl = container_obj(layer);
+	return servl->dev_info.id;
+}
+
+bool cfsrvl_phyid_match(struct cflayer *layer, int phyid)
+{
+	struct cfsrvl *servl = container_obj(layer);
+	return servl->dev_info.id == phyid;
+}
diff --git a/net/caif/cfutill.c b/net/caif/cfutill.c
new file mode 100644
index 0000000..5fd2c9e
--- /dev/null
+++ b/net/caif/cfutill.c
@@ -0,0 +1,115 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfsrvl.h>
+#include <net/caif/cfpkt.h>
+
+#define container_obj(layr) ((struct cfsrvl *) layr)
+#define UTIL_PAYLOAD  0x00
+#define UTIL_CMD_BIT  0x80
+#define UTIL_REMOTE_SHUTDOWN 0x82
+#define UTIL_FLOW_OFF 0x81
+#define UTIL_FLOW_ON  0x80
+#define UTIL_CTRL_PKT_SIZE 1
+static int cfutill_receive(struct cflayer *layr, struct cfpkt *pkt);
+static int cfutill_transmit(struct cflayer *layr, struct cfpkt *pkt);
+
+struct cflayer *cfutill_create(u8 channel_id, struct dev_info *dev_info)
+{
+	struct cfsrvl *util = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	if (!util) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return NULL;
+	}
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+	memset(util, 0, sizeof(struct cfsrvl));
+	cfsrvl_init(util, channel_id, dev_info);
+	util->layer.receive = cfutill_receive;
+	util->layer.transmit = cfutill_transmit;
+	snprintf(util->layer.name, CAIF_LAYER_NAME_SZ - 1, "util1");
+	return &util->layer;
+}
+
+static int cfutill_receive(struct cflayer *layr, struct cfpkt *pkt)
+{
+	u8 cmd = -1;
+	struct cfsrvl *service = container_obj(layr);
+	caif_assert(layr != NULL);
+	caif_assert(layr->up != NULL);
+	caif_assert(layr->up->receive != NULL);
+	caif_assert(layr->up->ctrlcmd != NULL);
+	if (cfpkt_extr_head(pkt, &cmd, 1) < 0) {
+		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		cfpkt_destroy(pkt);
+		return -EPROTO;
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
+		pr_err("CAIF: %s(): REMOTE SHUTDOWN REQUEST RECEIVED\n",
+			__func__);
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND, 0);
+		service->open = false;
+		cfpkt_destroy(pkt);
+		return 0;
+	default:
+		cfpkt_destroy(pkt);
+		pr_warning("CAIF: %s(): Unknown service control %d (0x%x)\n",
+			   __func__, cmd, cmd);
+		return -EPROTO;
+	}
+}
+
+static int cfutill_transmit(struct cflayer *layr, struct cfpkt *pkt)
+{
+	u8 zero = 0;
+	struct caif_payload_info *info;
+	int ret;
+	struct cfsrvl *service = container_obj(layr);
+	caif_assert(layr != NULL);
+	caif_assert(layr->dn != NULL);
+	caif_assert(layr->dn->transmit != NULL);
+	if (!cfsrvl_ready(service, &ret))
+		return ret;
+
+	if (cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
+		pr_err("CAIF: %s(): packet too large size=%d\n",
+			__func__, cfpkt_getlen(pkt));
+		return -EOVERFLOW;
+	}
+
+	cfpkt_add_head(pkt, &zero, 1);
+	/* Add info for MUX-layer to route the packet out. */
+	info = cfpkt_info(pkt);
+	info->channel_id = service->layer.id;
+	/*
+	 * To optimize alignment, we add up the size of CAIF header before
+	 * payload.
+	 */
+	info->hdr_len = 1;
+	info->dev_info = &service->dev_info;
+	ret = layr->dn->transmit(layr->dn, pkt);
+	if (ret < 0) {
+		u32 tmp32;
+		cfpkt_extr_head(pkt, &tmp32, 4);
+	}
+	return ret;
+}
diff --git a/net/caif/cfveil.c b/net/caif/cfveil.c
new file mode 100644
index 0000000..0fd827f
--- /dev/null
+++ b/net/caif/cfveil.c
@@ -0,0 +1,107 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/stddef.h>
+#include <linux/slab.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfsrvl.h>
+#include <net/caif/cfpkt.h>
+
+#define VEI_PAYLOAD  0x00
+#define VEI_CMD_BIT  0x80
+#define VEI_FLOW_OFF 0x81
+#define VEI_FLOW_ON  0x80
+#define VEI_SET_PIN  0x82
+#define VEI_CTRL_PKT_SIZE 1
+#define container_obj(layr) container_of(layr, struct cfsrvl, layer)
+
+static int cfvei_receive(struct cflayer *layr, struct cfpkt *pkt);
+static int cfvei_transmit(struct cflayer *layr, struct cfpkt *pkt);
+
+struct cflayer *cfvei_create(u8 channel_id, struct dev_info *dev_info)
+{
+	struct cfsrvl *vei = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	if (!vei) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return NULL;
+	}
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+	memset(vei, 0, sizeof(struct cfsrvl));
+	cfsrvl_init(vei, channel_id, dev_info);
+	vei->layer.receive = cfvei_receive;
+	vei->layer.transmit = cfvei_transmit;
+	snprintf(vei->layer.name, CAIF_LAYER_NAME_SZ - 1, "vei%d", channel_id);
+	return &vei->layer;
+}
+
+static int cfvei_receive(struct cflayer *layr, struct cfpkt *pkt)
+{
+	u8 cmd;
+	int ret;
+	caif_assert(layr->up != NULL);
+	caif_assert(layr->receive != NULL);
+	caif_assert(layr->ctrlcmd != NULL);
+
+
+	if (cfpkt_extr_head(pkt, &cmd, 1) < 0) {
+		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		cfpkt_destroy(pkt);
+		return -EPROTO;
+	}
+	switch (cmd) {
+	case VEI_PAYLOAD:
+		ret = layr->up->receive(layr->up, pkt);
+		return ret;
+	case VEI_FLOW_OFF:
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_FLOW_OFF_IND, 0);
+		cfpkt_destroy(pkt);
+		return 0;
+	case VEI_FLOW_ON:
+		layr->ctrlcmd(layr, CAIF_CTRLCMD_FLOW_ON_IND, 0);
+		cfpkt_destroy(pkt);
+		return 0;
+	case VEI_SET_PIN:	/* SET RS232 PIN */
+		cfpkt_destroy(pkt);
+		return 0;
+	default:		/* SET RS232 PIN */
+		pr_warning("CAIF: %s():Unknown VEI control packet %d (0x%x)!\n",
+			   __func__, cmd, cmd);
+		cfpkt_destroy(pkt);
+		return -EPROTO;
+	}
+}
+
+static int cfvei_transmit(struct cflayer *layr, struct cfpkt *pkt)
+{
+	u8 tmp = 0;
+	struct caif_payload_info *info;
+	int ret;
+	struct cfsrvl *service = container_obj(layr);
+	if (!cfsrvl_ready(service, &ret))
+		return ret;
+	caif_assert(layr->dn != NULL);
+	caif_assert(layr->dn->transmit != NULL);
+	if (!cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
+		pr_warning("CAIF: %s(): Packet too large - size=%d\n",
+			   __func__, cfpkt_getlen(pkt));
+		return -EOVERFLOW;
+	}
+
+	if (cfpkt_add_head(pkt, &tmp, 1) < 0) {
+		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		return -EPROTO;
+	}
+
+	/* Add info-> for MUX-layer to route the packet out. */
+	info = cfpkt_info(pkt);
+	info->channel_id = service->layer.id;
+	info->hdr_len = 1;
+	info->dev_info = &service->dev_info;
+	ret = layr->dn->transmit(layr->dn, pkt);
+	if (ret < 0)
+		cfpkt_extr_head(pkt, &tmp, 1);
+	return ret;
+}
diff --git a/net/caif/cfvidl.c b/net/caif/cfvidl.c
new file mode 100644
index 0000000..89ad4ea
--- /dev/null
+++ b/net/caif/cfvidl.c
@@ -0,0 +1,65 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfsrvl.h>
+#include <net/caif/cfpkt.h>
+
+#define container_obj(layr) ((struct cfsrvl *) layr)
+
+static int cfvidl_receive(struct cflayer *layr, struct cfpkt *pkt);
+static int cfvidl_transmit(struct cflayer *layr, struct cfpkt *pkt);
+
+struct cflayer *cfvidl_create(u8 channel_id, struct dev_info *dev_info)
+{
+	struct cfsrvl *vid = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	if (!vid) {
+		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		return NULL;
+	}
+	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+
+	memset(vid, 0, sizeof(struct cfsrvl));
+	cfsrvl_init(vid, channel_id, dev_info);
+	vid->layer.receive = cfvidl_receive;
+	vid->layer.transmit = cfvidl_transmit;
+	snprintf(vid->layer.name, CAIF_LAYER_NAME_SZ - 1, "vid1");
+	return &vid->layer;
+}
+
+static int cfvidl_receive(struct cflayer *layr, struct cfpkt *pkt)
+{
+	u32 videoheader;
+	if (cfpkt_extr_head(pkt, &videoheader, 4) < 0) {
+		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		cfpkt_destroy(pkt);
+		return -EPROTO;
+	}
+	return layr->up->receive(layr->up, pkt);
+}
+
+static int cfvidl_transmit(struct cflayer *layr, struct cfpkt *pkt)
+{
+	struct cfsrvl *service = container_obj(layr);
+	struct caif_payload_info *info;
+	u32 videoheader = 0;
+	int ret;
+	if (!cfsrvl_ready(service, &ret))
+		return ret;
+	cfpkt_add_head(pkt, &videoheader, 4);
+	/* Add info for MUX-layer to route the packet out */
+	info = cfpkt_info(pkt);
+	info->channel_id = service->layer.id;
+	info->dev_info = &service->dev_info;
+	ret = layr->dn->transmit(layr->dn, pkt);
+	if (ret < 0)
+		cfpkt_extr_head(pkt, &videoheader, 4);
+	return ret;
+}
-- 
1.6.3.3

