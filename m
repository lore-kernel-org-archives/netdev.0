From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] fib_hash removal
Date: Fri, 16 Mar 2007 13:38:31 +0100
Message-ID: <17914.36807.643615.571195@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se, kaber@trash.net,
	tgr@suug.ch, Jens.Laas@data.slu.se, hans.liss@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:56367 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753193AbXCPMin (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 08:38:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello, Just discussed this Patrick...

We have two users of trie_leaf_remove, fn_trie_flush and fn_trie_delete 
both are holding RTNL. So there shouldn't be need for this preempt stuff. 
This is assumed to a leftover from an older RCU-take.

> Mhh .. I think I just remembered something - me incorrectly suggesting
> to add it there while we were talking about this at OLS :) IIRC the
> idea was to make sure tnode_free (which at that time didn't use
> call_rcu) wouldn't free memory while still in use in a rcu read-side
> critical section. It should have been synchronize_rcu of course,
> but with tnode_free using call_rcu it seems to be completely
> unnecessary. So I guess we can simply remove it.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Cheers.
					--ro


diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1534,7 +1534,6 @@ static int trie_leaf_remove(struct trie 
 	t->revision++;
 	t->size--;
 
-	preempt_disable();
 	tp = NODE_PARENT(n);
 	tnode_free((struct tnode *) n);
 
@@ -1544,7 +1543,6 @@ static int trie_leaf_remove(struct trie 
 		rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
 	} else
 		rcu_assign_pointer(t->trie, NULL);
-	preempt_enable();
 
 	return 1;
 }

