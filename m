From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 5/11 RESEND] cxgb3 - tighten checks on TID values
Date: Tue, 21 Aug 2007 20:49:26 -0700
Message-ID: <20070822034926.9333.31858.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:18447 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756923AbXHVDt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 23:49:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Enforce validity checks on connection ids

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_defs.h    |   20 ++++++++++++++++++--
 drivers/net/cxgb3/cxgb3_offload.c |   28 +++++++++++++++++++++++-----
 2 files changed, 41 insertions(+), 7 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_defs.h b/drivers/net/cxgb3/cxgb3_defs.h
index 483a594..45e9216 100644
--- a/drivers/net/cxgb3/cxgb3_defs.h
+++ b/drivers/net/cxgb3/cxgb3_defs.h
@@ -79,9 +79,17 @@ static inline struct t3c_tid_entry *lookup_tid(const struct tid_info *t,
 static inline struct t3c_tid_entry *lookup_stid(const struct tid_info *t,
 						unsigned int tid)
 {
+	union listen_entry *e;
+
 	if (tid < t->stid_base || tid >= t->stid_base + t->nstids)
 		return NULL;
-	return &(stid2entry(t, tid)->t3c_tid);
+
+	e = stid2entry(t, tid);
+	if ((void *)e->next >= (void *)t->tid_tab &&
+	    (void *)e->next < (void *)&t->atid_tab[t->natids])
+		return NULL;
+
+	return &e->t3c_tid;
 }
 
 /*
@@ -90,9 +98,17 @@ static inline struct t3c_tid_entry *lookup_stid(const struct tid_info *t,
 static inline struct t3c_tid_entry *lookup_atid(const struct tid_info *t,
 						unsigned int tid)
 {
+	union active_open_entry *e;
+
 	if (tid < t->atid_base || tid >= t->atid_base + t->natids)
 		return NULL;
-	return &(atid2entry(t, tid)->t3c_tid);
+
+	e = atid2entry(t, tid);
+	if ((void *)e->next >= (void *)t->tid_tab &&
+	    (void *)e->next < (void *)&t->atid_tab[t->natids])
+		return NULL;
+
+	return &e->t3c_tid;
 }
 
 int process_rx(struct t3cdev *dev, struct sk_buff **skbs, int n);
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 522c1be..7fb526a 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -57,7 +57,7 @@ static DEFINE_RWLOCK(adapter_list_lock);
 static LIST_HEAD(adapter_list);
 
 static const unsigned int MAX_ATIDS = 64 * 1024;
-static const unsigned int ATID_BASE = 0x100000;
+static const unsigned int ATID_BASE = 0x10000;
 
 static inline int offload_activated(struct t3cdev *tdev)
 {
@@ -684,10 +684,19 @@ static int do_cr(struct t3cdev *dev, struct sk_buff *skb)
 {
 	struct cpl_pass_accept_req *req = cplhdr(skb);
 	unsigned int stid = G_PASS_OPEN_TID(ntohl(req->tos_tid));
+	struct tid_info *t = &(T3C_DATA(dev))->tid_maps;
 	struct t3c_tid_entry *t3c_tid;
+	unsigned int tid = GET_TID(req);
 
-	t3c_tid = lookup_stid(&(T3C_DATA(dev))->tid_maps, stid);
-	if (t3c_tid->ctx && t3c_tid->client->handlers &&
+	if (unlikely(tid >= t->ntids)) {
+		printk("%s: passive open TID %u too large\n",
+		       dev->name, tid);
+		t3_fatal_err(tdev2adap(dev));
+		return CPL_RET_BUF_DONE;
+	}
+	
+	t3c_tid = lookup_stid(t, stid);
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[CPL_PASS_ACCEPT_REQ]) {
 		return t3c_tid->client->handlers[CPL_PASS_ACCEPT_REQ]
 		    (dev, skb, t3c_tid->ctx);
@@ -769,16 +778,25 @@ static int do_act_establish(struct t3cdev *dev, struct sk_buff *skb)
 {
 	struct cpl_act_establish *req = cplhdr(skb);
 	unsigned int atid = G_PASS_OPEN_TID(ntohl(req->tos_tid));
+	struct tid_info *t = &(T3C_DATA(dev))->tid_maps;
 	struct t3c_tid_entry *t3c_tid;
+	unsigned int tid = GET_TID(req);
 
-	t3c_tid = lookup_atid(&(T3C_DATA(dev))->tid_maps, atid);
+	if (unlikely(tid >= t->ntids)) {
+		printk("%s: active establish TID %u too large\n",
+		       dev->name, tid);
+		t3_fatal_err(tdev2adap(dev));
+		return CPL_RET_BUF_DONE;
+	}
+
+	t3c_tid = lookup_atid(t, atid);
 	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[CPL_ACT_ESTABLISH]) {
 		return t3c_tid->client->handlers[CPL_ACT_ESTABLISH]
 		    (dev, skb, t3c_tid->ctx);
 	} else {
 		printk(KERN_ERR "%s: received clientless CPL command 0x%x\n",
-		       dev->name, CPL_PASS_ACCEPT_REQ);
+		       dev->name, CPL_ACT_ESTABLISH);
 		return CPL_RET_BUF_DONE | CPL_RET_BAD_MSG;
 	}
 }
