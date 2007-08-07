From: "Paul Moore" <paul.moore@hp.com>
Subject: [patch 1/1] NetLabel: add missing rcu_dereference() calls in the LSM domain mapping hash table
Date: Tue, 07 Aug 2007 16:54:50 -0400
Message-ID: <20070807205458.599982536@hp.com>
Cc: Paul Moore <paul.moore@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:60029 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935757AbXHGU4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 16:56:47 -0400
Received: from smtp2.fc.hp.com (smtp.cnd.hp.com [15.11.136.114])
	by atlrel6.hp.com (Postfix) with ESMTP id A5234342EA
	for <netdev@vger.kernel.org>; Tue,  7 Aug 2007 16:56:36 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

h
Content-Disposition: inline; filename=netlabel-rcu_deref_fix

The LSM domain mapping head table pointer was not being referenced via the RCU
safe dereferencing function, rcu_dereference().  This patch adds those missing
calls to the NetLabel code.

This has been tested using recent linux-2.6 git kernels with no visible
regressions.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/netlabel/netlabel_domainhash.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: linux-2.6_nlbl-rcu-fixup/net/netlabel/netlabel_domainhash.c
===================================================================
--- linux-2.6_nlbl-rcu-fixup.orig/net/netlabel/netlabel_domainhash.c
+++ linux-2.6_nlbl-rcu-fixup/net/netlabel/netlabel_domainhash.c
@@ -126,7 +126,9 @@ static struct netlbl_dom_map *netlbl_dom
 
 	if (domain != NULL) {
 		bkt = netlbl_domhsh_hash(domain);
-		list_for_each_entry_rcu(iter, &netlbl_domhsh->tbl[bkt], list)
+		list_for_each_entry_rcu(iter,
+				     &rcu_dereference(netlbl_domhsh)->tbl[bkt],
+				     list)
 			if (iter->valid && strcmp(iter->domain, domain) == 0)
 				return iter;
 	}
@@ -227,7 +229,7 @@ int netlbl_domhsh_add(struct netlbl_dom_
 		spin_lock(&netlbl_domhsh_lock);
 		if (netlbl_domhsh_search(entry->domain, 0) == NULL)
 			list_add_tail_rcu(&entry->list,
-					  &netlbl_domhsh->tbl[bkt]);
+				    &rcu_dereference(netlbl_domhsh)->tbl[bkt]);
 		else
 			ret_val = -EEXIST;
 		spin_unlock(&netlbl_domhsh_lock);
@@ -423,8 +425,8 @@ int netlbl_domhsh_walk(u32 *skip_bkt,
 	     iter_bkt < rcu_dereference(netlbl_domhsh)->size;
 	     iter_bkt++, chain_cnt = 0) {
 		list_for_each_entry_rcu(iter_entry,
-					&netlbl_domhsh->tbl[iter_bkt],
-					list)
+				&rcu_dereference(netlbl_domhsh)->tbl[iter_bkt],
+				list)
 			if (iter_entry->valid) {
 				if (chain_cnt++ < *skip_chain)
 					continue;

-- 
paul moore
linux security @ hp

