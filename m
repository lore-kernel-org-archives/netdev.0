From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] NetLabel: correct usage of RCU locking
Date: Thu, 25 Oct 2007 09:52:38 -0400
Message-ID: <20071025135238.6382.62146.stgit@flek.americas.hpqcorp.net>
References: <20071025134727.6382.79273.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:55230 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754818AbXJYNw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 09:52:58 -0400
Received: from smtp1.fc.hp.com (smtp.cnd.hp.com [15.15.136.127])
	by atlrel9.hp.com (Postfix) with ESMTP id 9095236253
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 09:52:42 -0400 (EDT)
In-Reply-To: <20071025134727.6382.79273.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes some awkward, and perhaps even problematic, RCU lock usage in the
NetLabel code as well as some other related trivial cleanups found when
looking through the RCU locking.  Most of the changes involve removing the
redundant RCU read locks wrapping spinlocks in the case of a RCU writer.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/ipv4/cipso_ipv4.c              |   39 +++++++++---------------------------
 net/netlabel/netlabel_domainhash.c |   37 ++++++++++------------------------
 net/netlabel/netlabel_mgmt.c       |    4 ----
 net/netlabel/netlabel_unlabeled.c  |    4 +---
 4 files changed, 22 insertions(+), 62 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 805a78e..f18e88b 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -504,22 +504,16 @@ int cipso_v4_doi_add(struct cipso_v4_doi *doi_def)
 	INIT_RCU_HEAD(&doi_def->rcu);
 	INIT_LIST_HEAD(&doi_def->dom_list);
 
-	rcu_read_lock();
-	if (cipso_v4_doi_search(doi_def->doi) != NULL)
-		goto doi_add_failure_rlock;
 	spin_lock(&cipso_v4_doi_list_lock);
 	if (cipso_v4_doi_search(doi_def->doi) != NULL)
-		goto doi_add_failure_slock;
+		goto doi_add_failure;
 	list_add_tail_rcu(&doi_def->list, &cipso_v4_doi_list);
 	spin_unlock(&cipso_v4_doi_list_lock);
-	rcu_read_unlock();
 
 	return 0;
 
-doi_add_failure_slock:
+doi_add_failure:
 	spin_unlock(&cipso_v4_doi_list_lock);
-doi_add_failure_rlock:
-	rcu_read_unlock();
 	return -EEXIST;
 }
 
@@ -543,29 +537,23 @@ int cipso_v4_doi_remove(u32 doi,
 	struct cipso_v4_doi *doi_def;
 	struct cipso_v4_domhsh_entry *dom_iter;
 
-	rcu_read_lock();
-	if (cipso_v4_doi_search(doi) != NULL) {
-		spin_lock(&cipso_v4_doi_list_lock);
-		doi_def = cipso_v4_doi_search(doi);
-		if (doi_def == NULL) {
-			spin_unlock(&cipso_v4_doi_list_lock);
-			rcu_read_unlock();
-			return -ENOENT;
-		}
+	spin_lock(&cipso_v4_doi_list_lock);
+	doi_def = cipso_v4_doi_search(doi);
+	if (doi_def != NULL) {
 		doi_def->valid = 0;
 		list_del_rcu(&doi_def->list);
 		spin_unlock(&cipso_v4_doi_list_lock);
+		rcu_read_lock();
 		list_for_each_entry_rcu(dom_iter, &doi_def->dom_list, list)
 			if (dom_iter->valid)
 				netlbl_domhsh_remove(dom_iter->domain,
 						     audit_info);
-		cipso_v4_cache_invalidate();
 		rcu_read_unlock();
-
+		cipso_v4_cache_invalidate();
 		call_rcu(&doi_def->rcu, callback);
 		return 0;
 	}
-	rcu_read_unlock();
+	spin_unlock(&cipso_v4_doi_list_lock);
 
 	return -ENOENT;
 }
@@ -653,22 +641,19 @@ int cipso_v4_doi_domhsh_add(struct cipso_v4_doi *doi_def, const char *domain)
 	new_dom->valid = 1;
 	INIT_RCU_HEAD(&new_dom->rcu);
 
-	rcu_read_lock();
 	spin_lock(&cipso_v4_doi_list_lock);
-	list_for_each_entry_rcu(iter, &doi_def->dom_list, list)
+	list_for_each_entry(iter, &doi_def->dom_list, list)
 		if (iter->valid &&
 		    ((domain != NULL && iter->domain != NULL &&
 		      strcmp(iter->domain, domain) == 0) ||
 		     (domain == NULL && iter->domain == NULL))) {
 			spin_unlock(&cipso_v4_doi_list_lock);
-			rcu_read_unlock();
 			kfree(new_dom->domain);
 			kfree(new_dom);
 			return -EEXIST;
 		}
 	list_add_tail_rcu(&new_dom->list, &doi_def->dom_list);
 	spin_unlock(&cipso_v4_doi_list_lock);
-	rcu_read_unlock();
 
 	return 0;
 }
@@ -689,9 +674,8 @@ int cipso_v4_doi_domhsh_remove(struct cipso_v4_doi *doi_def,
 {
 	struct cipso_v4_domhsh_entry *iter;
 
-	rcu_read_lock();
 	spin_lock(&cipso_v4_doi_list_lock);
-	list_for_each_entry_rcu(iter, &doi_def->dom_list, list)
+	list_for_each_entry(iter, &doi_def->dom_list, list)
 		if (iter->valid &&
 		    ((domain != NULL && iter->domain != NULL &&
 		      strcmp(iter->domain, domain) == 0) ||
@@ -699,13 +683,10 @@ int cipso_v4_doi_domhsh_remove(struct cipso_v4_doi *doi_def,
 			iter->valid = 0;
 			list_del_rcu(&iter->list);
 			spin_unlock(&cipso_v4_doi_list_lock);
-			rcu_read_unlock();
 			call_rcu(&iter->rcu, cipso_v4_doi_domhsh_free);
-
 			return 0;
 		}
 	spin_unlock(&cipso_v4_doi_list_lock);
-	rcu_read_unlock();
 
 	return -ENOENT;
 }
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index b6c844b..b3675bd 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -178,11 +178,9 @@ int netlbl_domhsh_init(u32 size)
 	for (iter = 0; iter < hsh_tbl->size; iter++)
 		INIT_LIST_HEAD(&hsh_tbl->tbl[iter]);
 
-	rcu_read_lock();
 	spin_lock(&netlbl_domhsh_lock);
 	rcu_assign_pointer(netlbl_domhsh, hsh_tbl);
 	spin_unlock(&netlbl_domhsh_lock);
-	rcu_read_unlock();
 
 	return 0;
 }
@@ -222,7 +220,6 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 	entry->valid = 1;
 	INIT_RCU_HEAD(&entry->rcu);
 
-	ret_val = 0;
 	rcu_read_lock();
 	if (entry->domain != NULL) {
 		bkt = netlbl_domhsh_hash(entry->domain);
@@ -233,7 +230,7 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 		else
 			ret_val = -EEXIST;
 		spin_unlock(&netlbl_domhsh_lock);
-	} else if (entry->domain == NULL) {
+	} else {
 		INIT_LIST_HEAD(&entry->list);
 		spin_lock(&netlbl_domhsh_def_lock);
 		if (rcu_dereference(netlbl_domhsh_def) == NULL)
@@ -241,9 +238,7 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 		else
 			ret_val = -EEXIST;
 		spin_unlock(&netlbl_domhsh_def_lock);
-	} else
-		ret_val = -EINVAL;
-
+	}
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_ADD, audit_info);
 	if (audit_buf != NULL) {
 		audit_log_format(audit_buf,
@@ -262,7 +257,6 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 		audit_log_format(audit_buf, " res=%u", ret_val == 0 ? 1 : 0);
 		audit_log_end(audit_buf);
 	}
-
 	rcu_read_unlock();
 
 	if (ret_val != 0) {
@@ -313,38 +307,30 @@ int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info)
 	struct audit_buffer *audit_buf;
 
 	rcu_read_lock();
-	if (domain != NULL)
-		entry = netlbl_domhsh_search(domain, 0);
-	else
-		entry = netlbl_domhsh_search(domain, 1);
+	entry = netlbl_domhsh_search(domain, (domain != NULL ? 0 : 1));
 	if (entry == NULL)
 		goto remove_return;
 	switch (entry->type) {
-	case NETLBL_NLTYPE_UNLABELED:
-		break;
 	case NETLBL_NLTYPE_CIPSOV4:
-		ret_val = cipso_v4_doi_domhsh_remove(entry->type_def.cipsov4,
-						     entry->domain);
-		if (ret_val != 0)
-			goto remove_return;
+		cipso_v4_doi_domhsh_remove(entry->type_def.cipsov4,
+					   entry->domain);
 		break;
 	}
-	ret_val = 0;
 	if (entry != rcu_dereference(netlbl_domhsh_def)) {
 		spin_lock(&netlbl_domhsh_lock);
 		if (entry->valid) {
 			entry->valid = 0;
 			list_del_rcu(&entry->list);
-		} else
-			ret_val = -ENOENT;
+			ret_val = 0;
+		}
 		spin_unlock(&netlbl_domhsh_lock);
 	} else {
 		spin_lock(&netlbl_domhsh_def_lock);
 		if (entry->valid) {
 			entry->valid = 0;
 			rcu_assign_pointer(netlbl_domhsh_def, NULL);
-		} else
-			ret_val = -ENOENT;
+			ret_val = 0;
+		}
 		spin_unlock(&netlbl_domhsh_def_lock);
 	}
 
@@ -357,11 +343,10 @@ int netlbl_domhsh_remove(const char *domain, struct netlbl_audit *audit_info)
 		audit_log_end(audit_buf);
 	}
 
-	if (ret_val == 0)
-		call_rcu(&entry->rcu, netlbl_domhsh_free_entry);
-
 remove_return:
 	rcu_read_unlock();
+	if (ret_val == 0)
+		call_rcu(&entry->rcu, netlbl_domhsh_free_entry);
 	return ret_val;
 }
 
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 5315dac..5648337 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -85,11 +85,9 @@ static const struct nla_policy netlbl_mgmt_genl_policy[NLBL_MGMT_A_MAX + 1] = {
  */
 void netlbl_mgmt_protocount_inc(void)
 {
-	rcu_read_lock();
 	spin_lock(&netlabel_mgmt_protocount_lock);
 	netlabel_mgmt_protocount++;
 	spin_unlock(&netlabel_mgmt_protocount_lock);
-	rcu_read_unlock();
 }
 
 /**
@@ -103,12 +101,10 @@ void netlbl_mgmt_protocount_inc(void)
  */
 void netlbl_mgmt_protocount_dec(void)
 {
-	rcu_read_lock();
 	spin_lock(&netlabel_mgmt_protocount_lock);
 	if (netlabel_mgmt_protocount > 0)
 		netlabel_mgmt_protocount--;
 	spin_unlock(&netlabel_mgmt_protocount_lock);
-	rcu_read_unlock();
 }
 
 /**
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 5c303c6..3482924 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -84,12 +84,10 @@ static void netlbl_unlabel_acceptflg_set(u8 value,
 	struct audit_buffer *audit_buf;
 	u8 old_val;
 
-	rcu_read_lock();
-	old_val = netlabel_unlabel_acceptflg;
 	spin_lock(&netlabel_unlabel_acceptflg_lock);
+	old_val = netlabel_unlabel_acceptflg;
 	netlabel_unlabel_acceptflg = value;
 	spin_unlock(&netlabel_unlabel_acceptflg_lock);
-	rcu_read_unlock();
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_UNLBL_ALLOW,
 					      audit_info);

