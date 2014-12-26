From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Subject: [PATCH] nftables: nft_flush_table: handle chain dependencies
Date: Fri, 26 Dec 2014 22:51:57 +0000
Message-ID: <1419634318-18303-1-git-send-email-asbjorn@asbjorn.biz>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([81.7.185.110]:44635 "EHLO mail.asbjorn.biz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779AbaLZXCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Dec 2014 18:02:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jumping between chains doesn't mix well with flush ruleset,
since nft_flush_table doesn't handle chains referencing chains.

This way it will take one to two loops, to settle.
Alternatively it can be solved by always having two loops,

[  353.373791] ------------[ cut here ]------------
[  353.373845] kernel BUG at net/netfilter/nf_tables_api.c:1159!
[  353.373896] invalid opcode: 0000 [#1] SMP
[  353.373942] Modules linked in: intel_powerclamp uas iwldvm iwlwifi
[  353.374017] CPU: 0 PID: 6445 Comm: 31c3.nft Not tainted 3.18.0 #98
[  353.374069] Hardware name: LENOVO 5129CTO/5129CTO, BIOS 6QET47WW
(1.17 ) 07/14/2010
[  353.374132] task: ffff880230976300 ti: ffff8800a8444000 task.ti:
ffff8800a8444000
[  353.374192] RIP: 0010:[<ffffffff8195fef8>]  [<ffffffff8195fef8>]
nf_tables_chain_destroy+0x58/0x60
[  353.374275] RSP: 0018:ffff8800a8447a90  EFLAGS: 00010202
[  353.374320] RAX: 0000000000000001 RBX: ffff880231d92c00 RCX:
00000001802a0027
[  353.374379] RDX: 00000001802a0028 RSI: ffffea0008c537c0 RDI:
ffff8802314df4e0
[  353.374437] RBP: ffff8800a8447ad8 R08: 00000000314df201 R09:
00000001802a0027
[  353.374494] R10: ffffffff81964a32 R11: ffff8802314df2a0 R12:
ffffffff820c50a8
[  353.374552] R13: ffffffff820c46c0 R14: ffff8800ad706700 R15:
ffff8802314dfcc0
[  353.374611] FS:  00007f96eacb6700(0000) GS:ffff88023bc00000(0000)
knlGS:0000000000000000
[  353.374676] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  353.374723] CR2: 00007f96eacc7002 CR3: 00000000a8418000 CR4:
00000000000007f0
[  353.374781] Stack:
[  353.374800]  ffffffff81964c31 0000000000000000 ffffc90024fecb30
ffffc90024fecb3c
[  353.374872]  ffffc90024fecb7c ffff8800ad706700 0000000000000001
0000000000000000
[  353.374944]  ffff8800ad706300 ffff8800a8447b68 ffffffff81949118
0000000000000000
[  353.375018] Call Trace:
[  353.375046]  [<ffffffff81964c31>] ? nf_tables_commit+0x381/0x540
[  353.375101]  [<ffffffff81949118>] nfnetlink_rcv+0x3d8/0x4b0
[  353.375150]  [<ffffffff81943fc5>] netlink_unicast+0x105/0x1a0
[  353.375200]  [<ffffffff8194438e>] netlink_sendmsg+0x32e/0x790
[  353.375253]  [<ffffffff818f398e>] sock_sendmsg+0x8e/0xc0
[  353.375300]  [<ffffffff818f36b9>] ?
move_addr_to_kernel.part.20+0x19/0x70
[  353.375357]  [<ffffffff818f44f9>] ? move_addr_to_kernel+0x19/0x30
[  353.375410]  [<ffffffff819016d2>] ? verify_iovec+0x42/0xd0
[  353.375459]  [<ffffffff818f3e10>] ___sys_sendmsg+0x3f0/0x400
[  353.375510]  [<ffffffff810615fa>] ? native_sched_clock+0x2a/0x90
[  353.375563]  [<ffffffff81176697>] ? acct_account_cputime+0x17/0x20
[  353.375616]  [<ffffffff8110dc78>] ? account_user_time+0x88/0xa0
[  353.375667]  [<ffffffff818f4bbd>] __sys_sendmsg+0x3d/0x80
[  353.375719]  [<ffffffff81b184f4>] ?
int_check_syscall_exit_work+0x34/0x3d
[  353.375776]  [<ffffffff818f4c0d>] SyS_sendmsg+0xd/0x20
[  353.375823]  [<ffffffff81b1826d>] system_call_fastpath+0x16/0x1b
[  353.375872] Code: 8b 78 10 e8 cb cd 7e ff 48 8b 7b f8 e8 f2 98 86 ff
48 8d bb 78 ff ff ff e8 56 b8 89 ff 48 83 c4 08 5b 5d c3 0f 1f 80 00 00
00 00 <0f> 0b 66 0f 1f 44 00 00 55 48 89 e5 41 57 41 56 41 55 41 54 53
[  353.376307] RIP  [<ffffffff8195fef8>]
nf_tables_chain_destroy+0x58/0x60
[  353.376368]  RSP <ffff8800a8447a90>
[  353.388988] ---[ end trace e51c442af1fdea42 ]---

Cc: stable@vger.kernel.org
Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
---
 net/netfilter/nf_tables_api.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 129a8da..6a10cbd 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -712,7 +712,11 @@ static int nft_flush_table(struct nft_ctx *ctx)
 	int err;
 	struct nft_chain *chain, *nc;
 	struct nft_set *set, *ns;
+	int skipped_chains, flushed_chains;
 
+flush_chains:
+	skipped_chains = 0;
+	flushed_chains = 0;
 	list_for_each_entry_safe(chain, nc, &ctx->table->chains, list) {
 		ctx->chain = chain;
 
@@ -720,9 +724,22 @@ static int nft_flush_table(struct nft_ctx *ctx)
 		if (err < 0)
 			goto out;
 
+		if (chain->use > 0) {
+			skipped_chains++;
+			continue
+		}
+
 		err = nft_delchain(ctx);
 		if (err < 0)
 			goto out;
+
+		flushed_chains++;
+	}
+	if (skipped_chains > 0) {
+		if (flushed_chains > 0)
+			goto flush_chains
+		else
+			BUG_ON(flushed_chains == 0);
 	}
 
 	list_for_each_entry_safe(set, ns, &ctx->table->sets, list) {
-- 
2.1.4
