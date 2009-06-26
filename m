From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 20:05:45 +0200
Message-ID: <20090626180544.GA6908@ami.dom.local>
References: <20090626125449.GA8897@ff.dom.local> <20090626132820.GB8897@ff.dom.local> <19012.53943.734747.493480@robur.slu.se> <20090626151051.GA2714@ami.dom.local> <20090626153010.GC6771@linux.vnet.ibm.com> <20090626155410.GA6526@ami.dom.local> <20090626161500.GB6526@ami.dom.local> <20090626162340.GF6771@linux.vnet.ibm.com> <20090626164557.GB6755@ami.dom.local> <20090626170538.GK6771@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Eric Dumazet <dada1@cosmosbay.com>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:38901 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756264AbZFZSF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 14:05:59 -0400
Received: by bwz9 with SMTP id 9so2176443bwz.37
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 11:06:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090626170538.GK6771@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 10:05:38AM -0700, Paul E. McKenney wrote:
...
> In that case, simply invoking synchronize_rcu() every once and awhile
> should take care of things.  This could be at the end of every large
> trie operation, or you could even count the call_rcu() invocations and
> do a synchronize_rcu() every 100th, 1,000th, or whatever, based on
> the amount of memory available.

OK, for now the minimal change for testing (2.6.30 needs previously
mentioned two commits from 2.6.31-rc). (I guess I'll send it with a
changelog after net-next is opened.)

Thanks,
Jarek P.
--- (take 4 - for testing)

 net/ipv4/fib_trie.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 012cf5a..98b31a1 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1008,7 +1008,7 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 {
 	int wasfull;
 	t_key cindex, key;
-	struct tnode *tp;
+	struct tnode *tp, *oldtnode = tn;
 
 	key = tn->key;
 
@@ -1028,8 +1028,12 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 	}
 
 	/* Handle last (top) tnode */
-	if (IS_TNODE(tn))
+	if (IS_TNODE(tn)) {
+		/* force memory freeing after last changes */
+		if (oldtnode != tn)
+			synchronize_rcu();
 		tn = (struct tnode *)resize(t, (struct tnode *)tn);
+	}
 
 	rcu_assign_pointer(t->trie, (struct node *)tn);
 	tnode_free_flush();
