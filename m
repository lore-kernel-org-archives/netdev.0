From: Robert Olsson <robert@robur.slu.se>
Subject: Re: [oops] with FIB_TRIE [PATCH]
Date: Thu, 21 May 2009 12:19:20 +0200
Message-ID: <18965.10920.161382.237618@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	NetDEV list <netdev@vger.kernel.org>, andrei.popa@i-neo.ro
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:57558 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751408AbZEUKTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 06:19:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 Hi,

Andrei Popa:
 > clear ip bgp * soft"
 > when I have three full BGP sessions the kernel it oopses. 
 > with CONFIG_PREEMPT=y

 It seems we can fix this by disabling preemption while we re-balance the 
 trie. This is with the CONFIG_CLASSIC_RCU. It's been stress-tested at high 
 loads continuesly taking a full BGP table up/down via iproute -batch.
 A patch is below.

 Note. fib_trie is not updated for CONFIG_PREEMPT_RCU
 
 Cheers
					--ro

Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index ec0ae49..33c7c85 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -986,9 +986,12 @@ fib_find_node(struct trie *t, u32 key)
 static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
 {
 	int wasfull;
-	t_key cindex, key = tn->key;
+	t_key cindex, key;
 	struct tnode *tp;
 
+	preempt_disable();
+	key = tn->key;
+
 	while (tn != NULL && (tp = node_parent((struct node *)tn)) != NULL) {
 		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
 		wasfull = tnode_full(tp, tnode_get_child(tp, cindex));
@@ -1007,6 +1010,7 @@ static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
 	if (IS_TNODE(tn))
 		tn = (struct tnode *)resize(t, (struct tnode *)tn);
 
+	preempt_enable();
 	return (struct node *)tn;
 }
 


