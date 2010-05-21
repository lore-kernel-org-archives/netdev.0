From: sjur.brandeland@stericsson.com
Subject: [PATCH net-2.6 2/6] caif: Bugfix - use standard Linux lists
Date: Fri, 21 May 2010 14:16:08 +0200
Message-ID: <1274444172-31969-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1274444172-31969-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: sjurbr@gmail.com, linus.walleij@stericsson.com,
	marcel@holtmann.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:44152 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896Ab0EUMQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 08:16:45 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2R003SMRF9K140@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Fri, 21 May 2010 14:16:21 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2R006WURF8S590@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Fri, 21 May 2010 14:16:21 +0200 (CEST)
In-reply-to: <1274444172-31969-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Discovered bug when running high number of parallel connect requests.
Replace buggy home brewed list with linux/list.h.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/cfctrl.h |    4 +-
 net/caif/cfctrl.c         |   92 +++++++++++++--------------------------------
 2 files changed, 28 insertions(+), 68 deletions(-)

diff --git a/include/net/caif/cfctrl.h b/include/net/caif/cfctrl.h
index 997603f..9402543 100644
--- a/include/net/caif/cfctrl.h
+++ b/include/net/caif/cfctrl.h
@@ -94,8 +94,8 @@ struct cfctrl_request_info {
 	enum cfctrl_cmd cmd;
 	u8 channel_id;
 	struct cfctrl_link_param param;
-	struct cfctrl_request_info *next;
 	struct cflayer *client_layer;
+	struct list_head list;
 };
 
 struct cfctrl {
@@ -103,7 +103,7 @@ struct cfctrl {
 	struct cfctrl_rsp res;
 	atomic_t req_seq_no;
 	atomic_t rsp_seq_no;
-	struct cfctrl_request_info *first_req;
+	struct list_head list;
 	/* Protects from simultaneous access to first_req list */
 	spinlock_t info_list_lock;
 #ifndef CAIF_NO_LOOP
diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 0ffe1e1..fcfda98 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -44,13 +44,14 @@ struct cflayer *cfctrl_create(void)
 	dev_info.id = 0xff;
 	memset(this, 0, sizeof(*this));
 	cfsrvl_init(&this->serv, 0, &dev_info);
-	spin_lock_init(&this->info_list_lock);
 	atomic_set(&this->req_seq_no, 1);
 	atomic_set(&this->rsp_seq_no, 1);
 	this->serv.layer.receive = cfctrl_recv;
 	sprintf(this->serv.layer.name, "ctrl");
 	this->serv.layer.ctrlcmd = cfctrl_ctrlcmd;
 	spin_lock_init(&this->loop_linkid_lock);
+	spin_lock_init(&this->info_list_lock);
+	INIT_LIST_HEAD(&this->list);
 	this->loop_linkid = 1;
 	return &this->serv.layer;
 }
@@ -112,20 +113,10 @@ bool cfctrl_req_eq(struct cfctrl_request_info *r1,
 void cfctrl_insert_req(struct cfctrl *ctrl,
 			      struct cfctrl_request_info *req)
 {
-	struct cfctrl_request_info *p;
 	spin_lock(&ctrl->info_list_lock);
-	req->next = NULL;
 	atomic_inc(&ctrl->req_seq_no);
 	req->sequence_no = atomic_read(&ctrl->req_seq_no);
-	if (ctrl->first_req == NULL) {
-		ctrl->first_req = req;
-		spin_unlock(&ctrl->info_list_lock);
-		return;
-	}
-	p = ctrl->first_req;
-	while (p->next != NULL)
-		p = p->next;
-	p->next = req;
+	list_add_tail(&req->list, &ctrl->list);
 	spin_unlock(&ctrl->info_list_lock);
 }
 
@@ -133,46 +124,28 @@ void cfctrl_insert_req(struct cfctrl *ctrl,
 struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
 					      struct cfctrl_request_info *req)
 {
-	struct cfctrl_request_info *p;
-	struct cfctrl_request_info *ret;
+	struct cfctrl_request_info *p, *tmp, *first;
 
 	spin_lock(&ctrl->info_list_lock);
-	if (ctrl->first_req == NULL) {
-		spin_unlock(&ctrl->info_list_lock);
-		return NULL;
-	}
-
-	if (cfctrl_req_eq(req, ctrl->first_req)) {
-		ret = ctrl->first_req;
-		caif_assert(ctrl->first_req);
-		atomic_set(&ctrl->rsp_seq_no,
-				 ctrl->first_req->sequence_no);
-		ctrl->first_req = ctrl->first_req->next;
-		spin_unlock(&ctrl->info_list_lock);
-		return ret;
-	}
+	first = list_first_entry(&ctrl->list, struct cfctrl_request_info, list);
 
-	p = ctrl->first_req;
-
-	while (p->next != NULL) {
-		if (cfctrl_req_eq(req, p->next)) {
-			pr_warning("CAIF: %s(): Requests are not "
+	list_for_each_entry_safe(p, tmp, &ctrl->list, list) {
+		if (cfctrl_req_eq(req, p)) {
+			if (p != first)
+				pr_warning("CAIF: %s(): Requests are not "
 					"received in order\n",
 					__func__);
-			ret = p->next;
+
 			atomic_set(&ctrl->rsp_seq_no,
-					p->next->sequence_no);
-			p->next = p->next->next;
-			spin_unlock(&ctrl->info_list_lock);
-			return ret;
+					 p->sequence_no);
+			list_del(&p->list);
+			goto out;
 		}
-		p = p->next;
 	}
+	p = NULL;
+out:
 	spin_unlock(&ctrl->info_list_lock);
-
-	pr_warning("CAIF: %s(): Request does not match\n",
-		   __func__);
-	return NULL;
+	return p;
 }
 
 struct cfctrl_rsp *cfctrl_get_respfuncs(struct cflayer *layer)
@@ -388,31 +361,18 @@ void cfctrl_getstartreason_req(struct cflayer *layer)
 
 void cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_layer)
 {
-	struct cfctrl_request_info *p, *req;
+	struct cfctrl_request_info *p, *tmp;
 	struct cfctrl *ctrl = container_obj(layr);
 	spin_lock(&ctrl->info_list_lock);
-
-	if (ctrl->first_req == NULL) {
-		spin_unlock(&ctrl->info_list_lock);
-		return;
-	}
-
-	if (ctrl->first_req->client_layer == adap_layer) {
-
-		req = ctrl->first_req;
-		ctrl->first_req = ctrl->first_req->next;
-		kfree(req);
-	}
-
-	p = ctrl->first_req;
-	while (p != NULL && p->next != NULL) {
-		if (p->next->client_layer == adap_layer) {
-
-			req = p->next;
-			p->next = p->next->next;
-			kfree(p->next);
+	pr_warning("CAIF: %s(): enter\n", __func__);
+
+	list_for_each_entry_safe(p, tmp, &ctrl->list, list) {
+		if (p->client_layer == adap_layer) {
+			pr_warning("CAIF: %s(): cancel req :%d\n", __func__,
+					p->sequence_no);
+			list_del(&p->list);
+			kfree(p);
 		}
-		p = p->next;
 	}
 
 	spin_unlock(&ctrl->info_list_lock);
@@ -634,7 +594,7 @@ static void cfctrl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
 	case _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND:
 	case CAIF_CTRLCMD_FLOW_OFF_IND:
 		spin_lock(&this->info_list_lock);
-		if (this->first_req != NULL) {
+		if (!list_empty(&this->list)) {
 			pr_debug("CAIF: %s(): Received flow off in "
 				   "control layer", __func__);
 		}
-- 
1.6.3.3

