From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 13:44:18 +0300
Message-ID: <20070220104418.GA5262@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <200702191913.08125.dada1@cosmosbay.com> <20070220092523.GA6238@2ka.mipt.ru> <200702201104.16200.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37852 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932870AbXBTKph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 05:45:37 -0500
Content-Disposition: inline
In-Reply-To: <200702201104.16200.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 11:04:15AM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> You totally miss the fact that the 1-2-4 MB cache is not available for you at 
> all. It is filled by User accesses. I dont care about DOS. I care about real 
> servers, servicing tcp clients. The TCP service/stack should not take more 
> than 10% of CPU (cycles and caches). The User application is certainly more 
> important because it hosts the real added value.

TCP socket is 4k in size, one tree entry can be reduced to 200 bytes?

No one says about _that_ cache miss, it is considered OK to have, but
tree cache miss becomes the worst thing ever.
In softirq we process socket's state, lock, reference counter several
pointer, and if we are happy - the whole TCP state machine fields - and
most of it stasy there when kernel is over - userspace issues syscalls
which must populate it back. Why don't we see that it is moved into
cache each time syscall is invoked? Because it is in the cache as long
as part of the hash table assotiated with last recently used hash
entries, which should not be there, and instead part of the tree can be.

> As soon softirq finished its job, CPU returns to User Space, blowing out your 
> top-level entries from the cache. Next ms (tg3 for example, batching XX 
> packets per interrupt), softirq handler must repopulate the cache again and 
> again.
> 
> Is linux kernel aimed to construct firewalls ? Certainly not. Linux kernel is 
> a generalist kernel. Of course your tree algo might be better in certain 
> situations, but those situations are not the norm. In these situations, we 
> might reserve 50% of cpu cache to hold top level of route cache and tcp 
> cache, but provide no power to user programs.
> 
> With ehash, pressure on cpu caches is small and User application can make 
> progress.

With tree it is exacly the same - but instead of unneded entries one can
put there head of the tree.

To prove myself right (wrong) and make me eat my hat I will implement
simple rb-tree-based socket lookup code (which does not allow simple
RCUfication though) or trie (without wildcards support) which allows
trivial RCUfication. Will you care to test patches or provide testcase
repetable in my lab (couple of 2-way core duo, athlon 3500 and via
epia)?

> Using a jenkin's hash permits a better hash distribution for a litle cpu cost.
> I will post later a distribution simulation based on the data gathered from 
> the same real server.

-- 
	Evgeniy Polyakov
