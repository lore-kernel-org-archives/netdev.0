From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: nf_tables: use reverse traversal commit_list in nf_tables_abort
Date: Mon, 14 Dec 2015 12:25:46 +0100
Message-ID: <1450092346-3281-7-git-send-email-pablo@netfilter.org>
References: <1450092346-3281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1450092346-3281-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Long <lucien.xin@gmail.com>

When we use 'nft -f' to submit rules, it will build multiple rules into
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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index f1002dc..2cb429d 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4024,7 +4024,8 @@ static int nf_tables_abort(struct sk_buff *skb)
 	struct nft_trans *trans, *next;
 	struct nft_trans_elem *te;
 
-	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
+	list_for_each_entry_safe_reverse(trans, next, &net->nft.commit_list,
+					 list) {
 		switch (trans->msg_type) {
 		case NFT_MSG_NEWTABLE:
 			if (nft_trans_table_update(trans)) {
-- 
2.1.4

