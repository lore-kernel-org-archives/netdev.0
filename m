From: Robert Olsson <robert@robur.slu.se>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 22:26:53 +0200
Message-ID: <19013.12045.576790.95151@robur.slu.se>
References: <20090626125449.GA8897@ff.dom.local>
	<20090626132820.GB8897@ff.dom.local>
	<19012.53943.734747.493480@robur.slu.se>
	<20090626151051.GA2714@ami.dom.local>
	<20090626153010.GC6771@linux.vnet.ibm.com>
	<20090626155410.GA6526@ami.dom.local>
	<20090626161500.GB6526@ami.dom.local>
	<20090626162340.GF6771@linux.vnet.ibm.com>
	<20090626164557.GB6755@ami.dom.local>
	<20090626170538.GK6771@linux.vnet.ibm.com>
	<20090626180544.GA6908@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Eric Dumazet <dada1@cosmosbay.com>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:38204 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875AbZFZU0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2009 16:26:55 -0400
In-Reply-To: <20090626180544.GA6908@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Yes looks like a good solution but maybe it safest to synchronize unconditionally?


diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 012cf5a..9cb8623 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1028,8 +1028,11 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 	}
 
 	/* Handle last (top) tnode */
-	if (IS_TNODE(tn))
+	if (IS_TNODE(tn)) {
+		/* force memory freeing after last changes */
+		synchronize_rcu();
 		tn = (struct tnode *)resize(t, (struct tnode *)tn);
+	}
 
 	rcu_assign_pointer(t->trie, (struct node *)tn);
 	tnode_free_flush();

Cheers
						--ro

Jarek Poplawski writes:

 >  net/ipv4/fib_trie.c |    8 ++++++--
 >  1 files changed, 6 insertions(+), 2 deletions(-)
 > 
 > diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
 > index 012cf5a..98b31a1 100644
 > --- a/net/ipv4/fib_trie.c
 > +++ b/net/ipv4/fib_trie.c
 > @@ -1008,7 +1008,7 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 >  {
 >  	int wasfull;
 >  	t_key cindex, key;
 > -	struct tnode *tp;
 > +	struct tnode *tp, *oldtnode = tn;
 >  
 >  	key = tn->key;
 >  
 > @@ -1028,8 +1028,12 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 >  	}
 >  
 >  	/* Handle last (top) tnode */
 > -	if (IS_TNODE(tn))
 > +	if (IS_TNODE(tn)) {
 > +		/* force memory freeing after last changes */
 > +		if (oldtnode != tn)
 > +			synchronize_rcu();
 >  		tn = (struct tnode *)resize(t, (struct tnode *)tn);
 > +	}
 >  
 >  	rcu_assign_pointer(t->trie, (struct node *)tn);
 >  	tnode_free_flush();
 > --
 > To unsubscribe from this list: send the line "unsubscribe netdev" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
