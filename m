From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/10] tipc: Create helper routine to delete unused name sequence structure
Date: Mon, 30 Apr 2012 18:37:05 -0400
Message-ID: <1335825428-16053-8-git-send-email-paul.gortmaker@windriver.com>
References: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35030 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757325Ab2D3WhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 18:37:21 -0400
In-Reply-To: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Replaces two identical chunks of code that delete an unused name
sequence structure from TIPC's name table with calls to a new routine
that performs this operation.

This change is cosmetic and doesn't impact the operation of TIPC.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |   27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 25c2975..4222121 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -186,7 +186,19 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_hea
 	return nseq;
 }
 
-/**
+/*
+ * nameseq_delete_empty - deletes a name sequence structure if now unused
+ */
+static void nameseq_delete_empty(struct name_seq *seq)
+{
+	if (!seq->first_free && list_empty(&seq->subscriptions)) {
+		hlist_del_init(&seq->ns_list);
+		kfree(seq->sseqs);
+		kfree(seq);
+	}
+}
+
+/*
  * nameseq_find_subseq - find sub-sequence (if any) matching a name instance
  *
  * Very time-critical, so binary searches through sub-sequence array.
@@ -529,12 +541,7 @@ struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
 		return NULL;
 
 	publ = tipc_nameseq_remove_publ(seq, lower, node, ref, key);
-
-	if (!seq->first_free && list_empty(&seq->subscriptions)) {
-		hlist_del_init(&seq->ns_list);
-		kfree(seq->sseqs);
-		kfree(seq);
-	}
+	nameseq_delete_empty(seq);
 	return publ;
 }
 
@@ -768,11 +775,7 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 		spin_lock_bh(&seq->lock);
 		list_del_init(&s->nameseq_list);
 		spin_unlock_bh(&seq->lock);
-		if ((seq->first_free == 0) && list_empty(&seq->subscriptions)) {
-			hlist_del_init(&seq->ns_list);
-			kfree(seq->sseqs);
-			kfree(seq);
-		}
+		nameseq_delete_empty(seq);
 	}
 	write_unlock_bh(&tipc_nametbl_lock);
 }
-- 
1.7.9.6
