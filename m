From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 3/1] Re: [BUG] fib_tries related Oops in 2.6.30
Date: Thu, 18 Jun 2009 07:23:00 +0000
Message-ID: <20090618072300.GA6243@ff.dom.local>
References: <20090615065333.GA4378@ff.dom.local> <20090615160800.GC2767@ami.dom.local> <20090617.185658.226201750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robert.olsson@its.uu.se, zheng.yan@oracle.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f212.google.com ([209.85.220.212]:37616 "EHLO
	mail-fx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbZFRHXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 03:23:05 -0400
Content-Disposition: inline
In-Reply-To: <20090617.185658.226201750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2009 at 06:56:58PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 15 Jun 2009 18:08:01 +0200
> 
> > ipv4: Fix fib_trie rebalancing, part 2
> > 
> > My previous patch, which explicitly delays freeing of tnodes by adding
> > them to the list to flush them after the update is finished, isn't
> > strict enough. It treats exceptionally tnodes without parent, assuming
> > they are newly created, so "invisible" for the read side yet.
> > 
> > But the top tnode doesn't have parent as well, so we have to exclude
> > all exceptions (at least until a better way is found). Additionally we
> > need to move rcu assignment of this node before flushing, so the
> > return type of the trie_rebalance() function is changed.
> > 
> > Reported-by: Yan Zheng <zheng.yan@oracle.com>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Applied, thanks a lot Jarek.

Not at all, really :-( I definitely need more time to find out what's
going on here...

Sorry/thanks x2,
Jarek P.
------------------>
ipv4: Fix fib_trie rebalancing, part 3

Alas my fix, part 2, has one if too much again... (We can't repeat the
same test because tn is different.)

Reported-by: Yan Zheng <zheng.yan@oracle.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
--- a/net/ipv4/fib_trie.c	2009-06-18 06:53:24.000000000 +0000
+++ b/net/ipv4/fib_trie.c	2009-06-18 06:58:00.000000000 +0000
@@ -1032,8 +1032,7 @@ static void trie_rebalance(struct trie *
 		tn = (struct tnode *)resize(t, (struct tnode *)tn);
 
 	rcu_assign_pointer(t->trie, (struct node *)tn);
-	if (IS_TNODE(tn))
-		tnode_free_flush();
+	tnode_free_flush();
 
 	return;
 }
