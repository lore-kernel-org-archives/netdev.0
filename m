From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net PATCH] fib_trie: Fix trie balancing issue if new node pushes
 down existing node
Date: Wed, 10 Dec 2014 21:49:22 -0800
Message-ID: <20141211054815.1357.36977.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933941AbaLKHrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 02:47:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses an issue with the level compression of the fib_trie.
Specifically in the case of adding a new leaf that triggers a new node to
be added that takes the place of the old node.  The result is a trie where
the 1 child tnode is on one side and one leaf is on the other which gives
you a very deep trie.  Below is the script I used to generate a trie on
dummy0 with a 10.X.X.X family of addresses.

  ip link add type dummy
  ipval=184549374
  bit=2
  for i in `seq 1 23`
  do
    ifconfig dummy0:$bit $ipval/8
    ipval=`expr $ipval - $bit`
    bit=`expr $bit \* 2`
  done
  cat /proc/net/fib_triestat

Running the script before the patch:

	Local:
		Aver depth:     10.82
		Max depth:      23
		Leaves:         29
		Prefixes:       30
		Internal nodes: 27
		  1: 26  2: 1
		Pointers: 56
	Null ptrs: 1
	Total size: 5  kB

After applying the patch and repeating:

	Local:
		Aver depth:     4.72
		Max depth:      9
		Leaves:         29
		Prefixes:       30
		Internal nodes: 12
		  1: 3  2: 2  3: 7
		Pointers: 70
	Null ptrs: 30
	Total size: 4  kB

What this fix does is start the rebalance at the newly created tnode
instead of at the parent tnode.  This way if there is a gap between the
parent and the new node it doesn't prevent the new tnode from being
coalesced with any pre-existing nodes that may have been pushed into one
of the new nodes child branches.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index e9cb258..18bcaf2 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1143,8 +1143,9 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 			put_child(tp, cindex, (struct rt_trie_node *)tn);
 		} else {
 			rcu_assign_pointer(t->trie, (struct rt_trie_node *)tn);
-			tp = tn;
 		}
+
+		tp = tn;
 	}
 
 	if (tp && tp->pos + tp->bits > 32)
