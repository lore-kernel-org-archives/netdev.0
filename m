From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 25/25] netfilter: nft_compat: fix crash when related match/target module is removed
Date: Sat, 23 Jul 2016 13:08:39 +0200
Message-ID: <1469272119-29942-26-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35953 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751801AbcGWLJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:41 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 6CD21E7DAA
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:40 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5CC156DA2D
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:40 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4388FFAB59
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:38 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

We "cache" the loaded match/target modules and reuse them, but when the
modules are removed, we still point to them. Then we may end up with
invalid memory references when using iptables-compat to add rules later.

Input the following commands will reproduce the kernel crash:
  # iptables-compat -A INPUT -j LOG
  # iptables-compat -D INPUT -j LOG
  # rmmod xt_LOG
  # iptables-compat -A INPUT -j LOG
  BUG: unable to handle kernel paging request at ffffffffa05a9010
  IP: [<ffffffff813f783e>] strcmp+0xe/0x30
  Call Trace:
  [<ffffffffa05acc43>] nft_target_select_ops+0x83/0x1f0 [nft_compat]
  [<ffffffffa058a177>] nf_tables_expr_parse+0x147/0x1f0 [nf_tables]
  [<ffffffffa058e541>] nf_tables_newrule+0x301/0x810 [nf_tables]
  [<ffffffff8141ca00>] ? nla_parse+0x20/0x100
  [<ffffffffa057fa8f>] nfnetlink_rcv+0x33f/0x53d [nfnetlink]
  [<ffffffffa057f94b>] ? nfnetlink_rcv+0x1fb/0x53d [nfnetlink]
  [<ffffffff817116b8>] netlink_unicast+0x178/0x220
  [<ffffffff81711a5b>] netlink_sendmsg+0x2fb/0x3a0
  [<ffffffff816b7fc8>] sock_sendmsg+0x38/0x50
  [<ffffffff816b8a7e>] ___sys_sendmsg+0x28e/0x2a0
  [<ffffffff816bcb7e>] ? release_sock+0x1e/0xb0
  [<ffffffff81804ac5>] ? _raw_spin_unlock_bh+0x35/0x40
  [<ffffffff816bcbe2>] ? release_sock+0x82/0xb0
  [<ffffffff816b93d4>] __sys_sendmsg+0x54/0x90
  [<ffffffff816b9422>] SyS_sendmsg+0x12/0x20
  [<ffffffff81805172>] entry_SYSCALL_64_fastpath+0x1a/0xa9

So when nobody use the related match/target module, there's no need to
"cache" it. And nft_[match|target]_release are useless anymore, remove
them.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c | 43 ++++++++++++++++++++-----------------------
 1 file changed, 20 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 2e07cec..c21e7eb 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -23,6 +23,20 @@
 #include <linux/netfilter_arp/arp_tables.h>
 #include <net/netfilter/nf_tables.h>
 
+struct nft_xt {
+	struct list_head	head;
+	struct nft_expr_ops	ops;
+	unsigned int		refcnt;
+};
+
+static void nft_xt_put(struct nft_xt *xt)
+{
+	if (--xt->refcnt == 0) {
+		list_del(&xt->head);
+		kfree(xt);
+	}
+}
+
 static int nft_compat_chain_validate_dependency(const char *tablename,
 						const struct nft_chain *chain)
 {
@@ -260,6 +274,7 @@ nft_target_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
 	if (par.target->destroy != NULL)
 		par.target->destroy(&par);
 
+	nft_xt_put(container_of(expr->ops, struct nft_xt, ops));
 	module_put(target->me);
 }
 
@@ -442,6 +457,7 @@ nft_match_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
 	if (par.match->destroy != NULL)
 		par.match->destroy(&par);
 
+	nft_xt_put(container_of(expr->ops, struct nft_xt, ops));
 	module_put(match->me);
 }
 
@@ -612,11 +628,6 @@ static const struct nfnetlink_subsystem nfnl_compat_subsys = {
 
 static LIST_HEAD(nft_match_list);
 
-struct nft_xt {
-	struct list_head	head;
-	struct nft_expr_ops	ops;
-};
-
 static struct nft_expr_type nft_match_type;
 
 static bool nft_match_cmp(const struct xt_match *match,
@@ -653,6 +664,7 @@ nft_match_select_ops(const struct nft_ctx *ctx,
 			if (!try_module_get(match->me))
 				return ERR_PTR(-ENOENT);
 
+			nft_match->refcnt++;
 			return &nft_match->ops;
 		}
 	}
@@ -673,6 +685,7 @@ nft_match_select_ops(const struct nft_ctx *ctx,
 		goto err;
 	}
 
+	nft_match->refcnt = 1;
 	nft_match->ops.type = &nft_match_type;
 	nft_match->ops.size = NFT_EXPR_SIZE(XT_ALIGN(match->matchsize));
 	nft_match->ops.eval = nft_match_eval;
@@ -690,14 +703,6 @@ err:
 	return ERR_PTR(err);
 }
 
-static void nft_match_release(void)
-{
-	struct nft_xt *nft_match, *tmp;
-
-	list_for_each_entry_safe(nft_match, tmp, &nft_match_list, head)
-		kfree(nft_match);
-}
-
 static struct nft_expr_type nft_match_type __read_mostly = {
 	.name		= "match",
 	.select_ops	= nft_match_select_ops,
@@ -744,6 +749,7 @@ nft_target_select_ops(const struct nft_ctx *ctx,
 			if (!try_module_get(target->me))
 				return ERR_PTR(-ENOENT);
 
+			nft_target->refcnt++;
 			return &nft_target->ops;
 		}
 	}
@@ -764,6 +770,7 @@ nft_target_select_ops(const struct nft_ctx *ctx,
 		goto err;
 	}
 
+	nft_target->refcnt = 1;
 	nft_target->ops.type = &nft_target_type;
 	nft_target->ops.size = NFT_EXPR_SIZE(XT_ALIGN(target->targetsize));
 	nft_target->ops.init = nft_target_init;
@@ -785,14 +792,6 @@ err:
 	return ERR_PTR(err);
 }
 
-static void nft_target_release(void)
-{
-	struct nft_xt *nft_target, *tmp;
-
-	list_for_each_entry_safe(nft_target, tmp, &nft_target_list, head)
-		kfree(nft_target);
-}
-
 static struct nft_expr_type nft_target_type __read_mostly = {
 	.name		= "target",
 	.select_ops	= nft_target_select_ops,
@@ -835,8 +834,6 @@ static void __exit nft_compat_module_exit(void)
 	nfnetlink_subsys_unregister(&nfnl_compat_subsys);
 	nft_unregister_expr(&nft_target_type);
 	nft_unregister_expr(&nft_match_type);
-	nft_match_release();
-	nft_target_release();
 }
 
 MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_NFT_COMPAT);
-- 
2.1.4
