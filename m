From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 2/2] tipc: adjust the policy of holding subscription kref
Date: Tue, 28 Mar 2017 12:28:28 +0200
Message-ID: <1490696908-7790-3-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1490696908-7790-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:44896 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754572AbdC1Kaa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 06:30:30 -0400
In-Reply-To: <1490696908-7790-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

When a new subscription object is inserted into name_seq->subscriptions
list, it's under name_seq->lock protection; when a subscription is
deleted from the list, it's also under the same lock protection;
similarly, when accessing a subscription by going through subscriptions
list, the entire process is also protected by the name_seq->lock.

Therefore, if subscription refcount is increased before it's inserted
into subscriptions list, and its refcount is decreased after it's
deleted from the list, it will be unnecessary to hold refcount at all
before accessing subscription object which is obtained by going through
subscriptions list under name_seq->lock protection.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/name_table.c | 2 ++
 net/tipc/subscr.c     | 8 ++------
 net/tipc/subscr.h     | 3 +++
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 9be6592e4a6f..bd0aac87b41a 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -416,6 +416,7 @@ static void tipc_nameseq_subscribe(struct name_seq *nseq,
 
 	tipc_subscrp_convert_seq(&s->evt.s.seq, s->swap, &ns);
 
+	tipc_subscrp_get(s);
 	list_add(&s->nameseq_list, &nseq->subscriptions);
 
 	if (!sseq)
@@ -787,6 +788,7 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 	if (seq != NULL) {
 		spin_lock_bh(&seq->lock);
 		list_del_init(&s->nameseq_list);
+		tipc_subscrp_put(s);
 		if (!seq->first_free && list_empty(&seq->subscriptions)) {
 			hlist_del_init_rcu(&seq->ns_list);
 			kfree(seq->sseqs);
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 0649bc29c6bb..0bf91cd3733c 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -54,8 +54,6 @@ struct tipc_subscriber {
 
 static void tipc_subscrp_delete(struct tipc_subscription *sub);
 static void tipc_subscrb_put(struct tipc_subscriber *subscriber);
-static void tipc_subscrp_put(struct tipc_subscription *subscription);
-static void tipc_subscrp_get(struct tipc_subscription *subscription);
 
 /**
  * htohl - convert value to endianness used by destination
@@ -125,7 +123,6 @@ void tipc_subscrp_report_overlap(struct tipc_subscription *sub, u32 found_lower,
 {
 	struct tipc_name_seq seq;
 
-	tipc_subscrp_get(sub);
 	tipc_subscrp_convert_seq(&sub->evt.s.seq, sub->swap, &seq);
 	if (!tipc_subscrp_check_overlap(&seq, found_lower, found_upper))
 		return;
@@ -135,7 +132,6 @@ void tipc_subscrp_report_overlap(struct tipc_subscription *sub, u32 found_lower,
 
 	tipc_subscrp_send_event(sub, found_lower, found_upper, event, port_ref,
 				node);
-	tipc_subscrp_put(sub);
 }
 
 static void tipc_subscrp_timeout(unsigned long data)
@@ -183,12 +179,12 @@ static void tipc_subscrp_kref_release(struct kref *kref)
 	tipc_subscrb_put(subscriber);
 }
 
-static void tipc_subscrp_put(struct tipc_subscription *subscription)
+void tipc_subscrp_put(struct tipc_subscription *subscription)
 {
 	kref_put(&subscription->kref, tipc_subscrp_kref_release);
 }
 
-static void tipc_subscrp_get(struct tipc_subscription *subscription)
+void tipc_subscrp_get(struct tipc_subscription *subscription)
 {
 	kref_get(&subscription->kref);
 }
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index ffdc214c117a..ee52957dc952 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -78,4 +78,7 @@ u32 tipc_subscrp_convert_seq_type(u32 type, int swap);
 int tipc_topsrv_start(struct net *net);
 void tipc_topsrv_stop(struct net *net);
 
+void tipc_subscrp_put(struct tipc_subscription *subscription);
+void tipc_subscrp_get(struct tipc_subscription *subscription);
+
 #endif
-- 
2.1.4
