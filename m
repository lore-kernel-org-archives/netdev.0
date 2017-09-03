From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/47] netfilter: connlimit: merge root4 and root6.
Date: Mon,  4 Sep 2017 00:40:12 +0200
Message-ID: <1504478435-13160-2-git-send-email-pablo@netfilter.org>
References: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52688 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753168AbdICWku (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:40:50 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C611B190F64
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B58222DC87
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:23 +0200 (CEST)
In-Reply-To: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taehee Yoo <ap420073@gmail.com>

The root4 variable is used only when connlimit extension module has been
stored by the iptables command. and the roo6 variable is used only when
connlimit extension module has been stored by the ip6tables command.
So the root4 and roo6 variable does not be used at the same time.

Signed-off-by: Taehee Yoo <ap420073@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_connlimit.c | 23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 97589b8a2a40..ffa8eec980e9 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -58,8 +58,7 @@ struct xt_connlimit_rb {
 static spinlock_t xt_connlimit_locks[CONNLIMIT_LOCK_SLOTS] __cacheline_aligned_in_smp;
 
 struct xt_connlimit_data {
-	struct rb_root climit_root4[CONNLIMIT_SLOTS];
-	struct rb_root climit_root6[CONNLIMIT_SLOTS];
+	struct rb_root climit_root[CONNLIMIT_SLOTS];
 };
 
 static u_int32_t connlimit_rnd __read_mostly;
@@ -294,13 +293,11 @@ static int count_them(struct net *net,
 	int count;
 	u32 hash;
 
-	if (family == NFPROTO_IPV6) {
+	if (family == NFPROTO_IPV6)
 		hash = connlimit_iphash6(addr, mask);
-		root = &data->climit_root6[hash];
-	} else {
+	else
 		hash = connlimit_iphash(addr->ip & mask->ip);
-		root = &data->climit_root4[hash];
-	}
+	root = &data->climit_root[hash];
 
 	spin_lock_bh(&xt_connlimit_locks[hash % CONNLIMIT_LOCK_SLOTS]);
 
@@ -379,10 +376,8 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 		return -ENOMEM;
 	}
 
-	for (i = 0; i < ARRAY_SIZE(info->data->climit_root4); ++i)
-		info->data->climit_root4[i] = RB_ROOT;
-	for (i = 0; i < ARRAY_SIZE(info->data->climit_root6); ++i)
-		info->data->climit_root6[i] = RB_ROOT;
+	for (i = 0; i < ARRAY_SIZE(info->data->climit_root); ++i)
+		info->data->climit_root[i] = RB_ROOT;
 
 	return 0;
 }
@@ -413,10 +408,8 @@ static void connlimit_mt_destroy(const struct xt_mtdtor_param *par)
 
 	nf_ct_netns_put(par->net, par->family);
 
-	for (i = 0; i < ARRAY_SIZE(info->data->climit_root4); ++i)
-		destroy_tree(&info->data->climit_root4[i]);
-	for (i = 0; i < ARRAY_SIZE(info->data->climit_root6); ++i)
-		destroy_tree(&info->data->climit_root6[i]);
+	for (i = 0; i < ARRAY_SIZE(info->data->climit_root); ++i)
+		destroy_tree(&info->data->climit_root[i]);
 
 	kfree(info->data);
 }
-- 
2.1.4
