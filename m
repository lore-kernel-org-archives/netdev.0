From: kaber@trash.net
Subject: [PATCH 23/79] netfilter: nf_conntrack: one less atomic op in nf_ct_expect_insert()
Date: Wed, 19 Jan 2011 20:14:23 +0100
Message-ID: <1295464519-21763-24-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51980 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513Ab1ASTP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:28 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Instead of doing atomic_inc(&exp->use) twice,
call atomic_add(2, &exp->use);

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_expect.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index bbb2140..774f32b 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -323,7 +323,8 @@ static void nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	const struct nf_conntrack_expect_policy *p;
 	unsigned int h = nf_ct_expect_dst_hash(&exp->tuple);
 
-	atomic_inc(&exp->use);
+	/* two references : one for hash insert, one for the timer */
+	atomic_add(2, &exp->use);
 
 	if (master_help) {
 		hlist_add_head(&exp->lnode, &master_help->expectations);
@@ -345,7 +346,6 @@ static void nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	}
 	add_timer(&exp->timeout);
 
-	atomic_inc(&exp->use);
 	NF_CT_STAT_INC(net, expect_create);
 }
 
-- 
1.7.2.3

