From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [next-next PATCH 5/7] fib_trie: Use empty_children instead of
 counting empty nodes in stats collection
Date: Thu, 22 Jan 2015 15:51:33 -0800
Message-ID: <20150122235133.5779.22497.stgit@ahduyck-vm-fedora20>
References: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50604 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754400AbbAVXvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 18:51:35 -0500
In-Reply-To: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't make much sense to count the pointers ourselves when
empty_children already has a count for the number of NULL pointers stored
in the tnode.  As such save ourselves the cycles and just use
empty_children.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index f874e18..90654bb 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1954,16 +1954,10 @@ static void trie_collect_stats(struct trie *t, struct trie_stat *s)
 			hlist_for_each_entry_rcu(li, &n->list, hlist)
 				++s->prefixes;
 		} else {
-			unsigned long i;
-
 			s->tnodes++;
 			if (n->bits < MAX_STAT_DEPTH)
 				s->nodesizes[n->bits]++;
-
-			for (i = tnode_child_length(n); i--;) {
-				if (!rcu_access_pointer(n->child[i]))
-					s->nullpointers++;
-			}
+			s->nullpointers += n->empty_children;
 		}
 	}
 	rcu_read_unlock();
