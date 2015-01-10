From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: nf_tables: fix flush ruleset chain dependencies
Date: Sat, 10 Jan 2015 19:50:08 +0100
Message-ID: <1420915808-7160-7-git-send-email-pablo@netfilter.org>
References: <1420915808-7160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46778 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754385AbbAJSr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2015 13:47:26 -0500
In-Reply-To: <1420915808-7160-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jumping between chains doesn't mix well with flush ruleset. Rules
from a different chain and set elements may still refer to us.

[  353.373791] ------------[ cut here ]------------
[  353.373845] kernel BUG at net/netfilter/nf_tables_api.c:1159!
[  353.373896] invalid opcode: 0000 [#1] SMP
[  353.373942] Modules linked in: intel_powerclamp uas iwldvm iwlwifi
[  353.374017] CPU: 0 PID: 6445 Comm: 31c3.nft Not tainted 3.18.0 #98
[  353.374069] Hardware name: LENOVO 5129CTO/5129CTO, BIOS 6QET47WW (1.17 ) 07/14/2010
[...]
[  353.375018] Call Trace:
[  353.375046]  [<ffffffff81964c31>] ? nf_tables_commit+0x381/0x540
[  353.375101]  [<ffffffff81949118>] nfnetlink_rcv+0x3d8/0x4b0
[  353.375150]  [<ffffffff81943fc5>] netlink_unicast+0x105/0x1a0
[  353.375200]  [<ffffffff8194438e>] netlink_sendmsg+0x32e/0x790
[  353.375253]  [<ffffffff818f398e>] sock_sendmsg+0x8e/0xc0
[  353.375300]  [<ffffffff818f36b9>] ? move_addr_to_kernel.part.20+0x19/0x70
[  353.375357]  [<ffffffff818f44f9>] ? move_addr_to_kernel+0x19/0x30
[  353.375410]  [<ffffffff819016d2>] ? verify_iovec+0x42/0xd0
[  353.375459]  [<ffffffff818f3e10>] ___sys_sendmsg+0x3f0/0x400
[  353.375510]  [<ffffffff810615fa>] ? native_sched_clock+0x2a/0x90
[  353.375563]  [<ffffffff81176697>] ? acct_account_cputime+0x17/0x20
[  353.375616]  [<ffffffff8110dc78>] ? account_user_time+0x88/0xa0
[  353.375667]  [<ffffffff818f4bbd>] __sys_sendmsg+0x3d/0x80
[  353.375719]  [<ffffffff81b184f4>] ? int_check_syscall_exit_work+0x34/0x3d
[  353.375776]  [<ffffffff818f4c0d>] SyS_sendmsg+0xd/0x20
[  353.375823]  [<ffffffff81b1826d>] system_call_fastpath+0x16/0x1b

Release objects in this order: rules -> sets -> chains -> tables, to
make sure no references to chains are held anymore.

Reported-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 129a8da..3b3ddb4 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -713,16 +713,12 @@ static int nft_flush_table(struct nft_ctx *ctx)
 	struct nft_chain *chain, *nc;
 	struct nft_set *set, *ns;
 
-	list_for_each_entry_safe(chain, nc, &ctx->table->chains, list) {
+	list_for_each_entry(chain, &ctx->table->chains, list) {
 		ctx->chain = chain;
 
 		err = nft_delrule_by_chain(ctx);
 		if (err < 0)
 			goto out;
-
-		err = nft_delchain(ctx);
-		if (err < 0)
-			goto out;
 	}
 
 	list_for_each_entry_safe(set, ns, &ctx->table->sets, list) {
@@ -735,6 +731,14 @@ static int nft_flush_table(struct nft_ctx *ctx)
 			goto out;
 	}
 
+	list_for_each_entry_safe(chain, nc, &ctx->table->chains, list) {
+		ctx->chain = chain;
+
+		err = nft_delchain(ctx);
+		if (err < 0)
+			goto out;
+	}
+
 	err = nft_deltable(ctx);
 out:
 	return err;
-- 
1.7.10.4
