From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Fri, 2 Mar 2007 11:52:47 +0300
Message-ID: <20070302085246.GA30951@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain> <20070217131302.GA22732@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org
To: akepner@sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49350 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933104AbXCBI6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 03:58:50 -0500
Content-Disposition: inline
In-Reply-To: <20070217131302.GA22732@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 17, 2007 at 04:13:02PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > >I noticed in an LCA talk mention that apprently extensible hashing
> > >with RCU access is an unsolved problem.  Here's an idea for solving it.
> > >....
> > 
> > Yes, I have been playing around with the same idea for
> > doing dynamic resizing of the TCP hashtable.
> > 
> > Did a prototype "toy" implementation, and I have a
> > "half-finished" patch which resizes the TCP hashtable
> > at runtime. Hmmm, your mail may be the impetus to get
> > me to finally finish this thing....
> 
> Why anyone do not want to use trie - for socket-like loads it has
> exactly constant search/insert/delete time and scales as hell.

Ok, I've ran an analysis of linked lists and trie traversals and found 
that (at least on x86) optimized one list traversal is about 4 (!) 
times faster than one bit lookup in trie traversal (or actually one
lookup in binary tree-like structure) - that is because of the fact 
that trie traversal needs to have more instructions per lookup, and at 
least one additional branch which can not be predicted.

Tests with rdtsc shows that one bit lookup in trie (actually it is any
lookup in binary tree structures) is about 3-4 times slower than one
lookup in linked list.

Since hash table usually has upto 4 elements in each hash entry,
competing binary tree/trie stucture must get an entry in one lookup,
which is essentially impossible with usual tree/trie implementations.

Things dramatically change when linked list became too long, but it
should not happend with proper resizing of the hash table, wildcards
implementation also introduce additional requirements, which can not be
easily solved in hash tables.

So I get my words about tree/trie implementation instead of hash table 
for socket lookup back.

Interested reader can find more details on tests, asm outputs and
conclusions at:
http://tservice.net.ru/~s0mbre/blog/2007/03/01#2007_03_01

-- 
	Evgeniy Polyakov
