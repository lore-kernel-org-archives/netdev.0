From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Sun, 18 Feb 2007 22:10:10 +0300
Message-ID: <20070218191009.GA28216@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain> <20070217131302.GA22732@2ka.mipt.ru> <45D89EFE.4080103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@linux.intel.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34762 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751867AbXBRTMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Feb 2007 14:12:01 -0500
Content-Disposition: inline
In-Reply-To: <45D89EFE.4080103@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 18, 2007 at 07:46:22PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> >Why anyone do not want to use trie - for socket-like loads it has
> >exactly constant search/insert/delete time and scales as hell.
> >
> 
> Because we want to be *very* fast. You cannot beat hash table.
> 
> Say you have 1.000.000 tcp connections, with 50.000 incoming packets per 
> second to *random* streams...

What is really good in trie, that you may have upto 2^32 connections
without _any_ difference in lookup performance of random streams.

> With a 2^20 hashtable, a lookup uses one cache line (the hash head pointer) 
> plus one cache line to get the socket (you need it to access its refcounter)
> 
> Several attempts were done in the past to add RCU to ehash table (last done 
> by Benjamin LaHaise last March). I believe this was delayed a bit, because 
> David would like to be able to resize the hash table...

This is a theory.
Practice includes cost for hashing, locking, and list traversal
(each pointer is in own cache line btw, which must be fetched) and plus
the same for time wait sockets (if we are unlucky).

No need to talk about price of cache miss when there might be more
serious problems - for example length of the linked list to traverse each 
time new packet is received.

For example lookup time in trie with 1.6 millions random 3-dimensional
32bit (saddr/daddr/ports) entries is about 1 microsecond on amd athlon64 
3500 cpu (test was ran in userspace emulator though).
Data obtained from netchannels research:
http://tservice.net.ru/~s0mbre/blog/2006/12/02#2006_12_02

I think I need to setup similar emulator for hash table of the above
size to check hash/list goodness.

> I am not really interested in hash resizing, because an admin can size it 
> at boot time. But RCU is definitly *wanted*

Trie in that regard is true winner - its RCU'fication is trivial.

> Note : It would be good to also use RCU for UDP, because the current rwlock 
> protecting udp_hash[] is a scalability problem.

-- 
	Evgeniy Polyakov
