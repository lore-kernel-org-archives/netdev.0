From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/47] netfilter: expect: add to hash table after expect init
Date: Mon,  4 Sep 2017 00:25:43 +0200
Message-ID: <1504477589-12045-2-git-send-email-pablo@netfilter.org>
References: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50782 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753069AbdICW0j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:26:39 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 09F05190F66
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:26:13 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EDAA2B502E
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:26:12 +0200 (CEST)
In-Reply-To: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

assuming we have lockless readers we should make sure they can only
see expectations that have already been initialized.

hlist_add_head_rcu acts as memory barrier, move it after timer setup.

Theoretically we could crash due to a del_timer() on other cpu
seeing garbage data.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_expect.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 899c2c36da13..2c63808bea96 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -368,12 +368,6 @@ static void nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	/* two references : one for hash insert, one for the timer */
 	refcount_add(2, &exp->use);
 
-	hlist_add_head_rcu(&exp->lnode, &master_help->expectations);
-	master_help->expecting[exp->class]++;
-
-	hlist_add_head_rcu(&exp->hnode, &nf_ct_expect_hash[h]);
-	net->ct.expect_count++;
-
 	setup_timer(&exp->timeout, nf_ct_expectation_timed_out,
 		    (unsigned long)exp);
 	helper = rcu_dereference_protected(master_help->helper,
@@ -384,6 +378,12 @@ static void nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	}
 	add_timer(&exp->timeout);
 
+	hlist_add_head_rcu(&exp->lnode, &master_help->expectations);
+	master_help->expecting[exp->class]++;
+
+	hlist_add_head_rcu(&exp->hnode, &nf_ct_expect_hash[h]);
+	net->ct.expect_count++;
+
 	NF_CT_STAT_INC(net, expect_create);
 }
 
-- 
2.1.4
