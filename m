From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] nftables: use list_for_each_entry_safe_reverse to traversal commit_list in nf_tables_abort
Date: Mon,  7 Dec 2015 18:48:07 +0800
Message-ID: <15bcb964221e1a9498e901417d020609cd5aac65.1449485287.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de
To: network dev <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34964 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544AbbLGKsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 05:48:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when we use 'nft -f' to sumbit rules, it will build multiple rules into
one netlink skb to send to kernel, kernel will process them one by one.
meanwhile, it add the trans into commit_list to record every commit.
if one of them's return value is -EAGAIN, status |= NFNL_BATCH_REPLAY
will be marked. after all the process is done. it will roll back all the
commits.

now kernel use list_add_tail to add trans to commit, and use
list_for_each_entry_safe to roll back. which means the order of adding
and rollback is the same. that will cause some cases cannot work well,
even trigger call trace, like:

1. add a set into table foo  [return -EAGAIN]:
   commit_list = 'add set trans'
2. del foo:
   commit_list = 'add set trans' -> 'del set trans' -> 'del tab trans'
then nf_tables_abort will be called to roll back:
firstly process 'add set trans':
                   case NFT_MSG_NEWSET:
                        trans->ctx.table->use--;
                        list_del_rcu(&nft_trans_set(trans)->list);

  it will del the set from the table foo, but it has removed when del
  table foo [step 2], then the kernel will panic.

the right order of rollback should be:
  'del tab trans' -> 'del set trans' -> 'add set trans'.
which is opposite with commit_list order.

so fix it by rolling back commits with reverse order in nf_tables_abort.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/netfilter/nf_tables_api.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 93cc473..4511a78 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4030,7 +4030,8 @@ static int nf_tables_abort(struct sk_buff *skb)
 	struct nft_trans *trans, *next;
 	struct nft_trans_elem *te;
 
-	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
+	list_for_each_entry_safe_reverse(trans, next, &net->nft.commit_list,
+					 list) {
 		switch (trans->msg_type) {
 		case NFT_MSG_NEWTABLE:
 			if (nft_trans_table_update(trans)) {
-- 
2.1.0
