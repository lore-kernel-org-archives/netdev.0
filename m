From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH] fib_trie: Fix uninitialized variable warning
Date: Wed, 11 Mar 2015 14:02:16 -0700
Message-ID: <20150311210211.7975.98821.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752810AbbCKVCS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 17:02:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 0-day kernel test infrastructure reported a use of uninitialized
variable warning for local_table due to the fact that the local and main
allocations had been swapped from the original setup.  This change corrects
that by making it so that we free the main table if the local table
allocation fails.

Fixes: 0ddcf43d5 ("ipv4: FIB Local/MAIN table collapse")

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_frontend.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 7cda3b0..d098987 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -54,11 +54,11 @@ static int __net_init fib4_rules_init(struct net *net)
 
 	main_table  = fib_trie_table(RT_TABLE_MAIN, NULL);
 	if (main_table == NULL)
-		goto fail;
+		return -ENOMEM;
 
 	local_table = fib_trie_table(RT_TABLE_LOCAL, main_table);
 	if (local_table == NULL)
-		return -ENOMEM;
+		goto fail;
 
 	hlist_add_head_rcu(&local_table->tb_hlist,
 				&net->ipv4.fib_table_hash[TABLE_LOCAL_INDEX]);
@@ -67,7 +67,7 @@ static int __net_init fib4_rules_init(struct net *net)
 	return 0;
 
 fail:
-	fib_free_table(local_table);
+	fib_free_table(main_table);
 	return -ENOMEM;
 }
 #else
