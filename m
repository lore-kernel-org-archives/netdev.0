From: pablo@netfilter.org
Subject: [PATCH 09/10] netfilter: replace list_for_each_continue_rcu with new interface
Date: Thu, 23 Aug 2012 01:38:45 +0200
Message-ID: <1345678726-3109-10-git-send-email-pablo@netfilter.org>
References: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wang <wangyun@linux.vnet.ibm.com>

This patch replaces list_for_each_continue_rcu() with
list_for_each_entry_continue_rcu() to allow removing
list_for_each_continue_rcu().

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 0bc6b60..8f4b0b2 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -131,14 +131,13 @@ unsigned int nf_iterate(struct list_head *head,
 			int hook_thresh)
 {
 	unsigned int verdict;
+	struct nf_hook_ops *elem = list_entry_rcu(*i, struct nf_hook_ops, list);
 
 	/*
 	 * The caller must not block between calls to this
 	 * function because of risk of continuing from deleted element.
 	 */
-	list_for_each_continue_rcu(*i, head) {
-		struct nf_hook_ops *elem = (struct nf_hook_ops *)*i;
-
+	list_for_each_entry_continue_rcu(elem, head, list) {
 		if (hook_thresh > elem->priority)
 			continue;
 
@@ -155,11 +154,14 @@ repeat:
 				continue;
 			}
 #endif
-			if (verdict != NF_REPEAT)
+			if (verdict != NF_REPEAT) {
+				*i = &elem->list;
 				return verdict;
+			}
 			goto repeat;
 		}
 	}
+	*i = &elem->list;
 	return NF_ACCEPT;
 }
 
-- 
1.7.10.4

