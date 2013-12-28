From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/8] netfilter: nf_tables: fix oops when updating table with user chains
Date: Sat, 28 Dec 2013 23:03:06 +0100
Message-ID: <1388268187-11569-8-git-send-email-pablo@netfilter.org>
References: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a crash while trying to deactivate a table that
contains user chains. You can reproduce it via:

% nft add table table1
% nft add chain table1 chain1
% nft-table-upd ip table1 dormant

[  253.021026] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[  253.021114] IP: [<ffffffff8134cebd>] nf_register_hook+0x35/0x6f
[  253.021167] PGD 30fa5067 PUD 30fa2067 PMD 0
[  253.021208] Oops: 0000 [#1] SMP
[...]
[  253.023305] Call Trace:
[  253.023331]  [<ffffffffa0885020>] nf_tables_newtable+0x11c/0x258 [nf_tables]
[  253.023385]  [<ffffffffa0878592>] nfnetlink_rcv_msg+0x1f4/0x226 [nfnetlink]
[  253.023438]  [<ffffffffa0878418>] ? nfnetlink_rcv_msg+0x7a/0x226 [nfnetlink]
[  253.023491]  [<ffffffffa087839e>] ? nfnetlink_bind+0x45/0x45 [nfnetlink]
[  253.023542]  [<ffffffff8134b47e>] netlink_rcv_skb+0x3c/0x88
[  253.023586]  [<ffffffffa0878973>] nfnetlink_rcv+0x3af/0x3e4 [nfnetlink]
[  253.023638]  [<ffffffff813fb0d4>] ? _raw_read_unlock+0x22/0x34
[  253.023683]  [<ffffffff8134af17>] netlink_unicast+0xe2/0x161
[  253.023727]  [<ffffffff8134b29a>] netlink_sendmsg+0x304/0x332
[  253.023773]  [<ffffffff8130d250>] __sock_sendmsg_nosec+0x25/0x27
[  253.023820]  [<ffffffff8130fb93>] sock_sendmsg+0x5a/0x7b
[  253.023861]  [<ffffffff8130d5d5>] ? copy_from_user+0x2a/0x2c
[  253.023905]  [<ffffffff8131066f>] ? move_addr_to_kernel+0x35/0x60
[  253.023952]  [<ffffffff813107b3>] SYSC_sendto+0x119/0x15c
[  253.023995]  [<ffffffff81401107>] ? sysret_check+0x1b/0x56
[  253.024039]  [<ffffffff8108dc30>] ? trace_hardirqs_on_caller+0x140/0x1db
[  253.024090]  [<ffffffff8120164e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  253.024141]  [<ffffffff81310caf>] SyS_sendto+0x9/0xb
[  253.026219]  [<ffffffff814010e2>] system_call_fastpath+0x16/0x1b

Reported-by: Alex Wei <alex.kern.mentor@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index d9fcd27..d65c80b 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -312,6 +312,9 @@ static int nf_tables_table_enable(struct nft_table *table)
 	int err, i = 0;
 
 	list_for_each_entry(chain, &table->chains, list) {
+		if (!(chain->flags & NFT_BASE_CHAIN))
+			continue;
+
 		err = nf_register_hook(&nft_base_chain(chain)->ops);
 		if (err < 0)
 			goto err;
@@ -321,6 +324,9 @@ static int nf_tables_table_enable(struct nft_table *table)
 	return 0;
 err:
 	list_for_each_entry(chain, &table->chains, list) {
+		if (!(chain->flags & NFT_BASE_CHAIN))
+			continue;
+
 		if (i-- <= 0)
 			break;
 
@@ -333,8 +339,10 @@ static int nf_tables_table_disable(struct nft_table *table)
 {
 	struct nft_chain *chain;
 
-	list_for_each_entry(chain, &table->chains, list)
-		nf_unregister_hook(&nft_base_chain(chain)->ops);
+	list_for_each_entry(chain, &table->chains, list) {
+		if (chain->flags & NFT_BASE_CHAIN)
+			nf_unregister_hook(&nft_base_chain(chain)->ops);
+	}
 
 	return 0;
 }
-- 
1.7.10.4

