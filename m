From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Mon, 19 Feb 2007 14:38:13 +0100
Message-ID: <200702191438.14010.dada1@cosmosbay.com>
References: <20070204074143.26312.qmail@science.horizon.com> <45D8B54A.70903@cosmosbay.com> <20070219114117.GA22622@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:54893 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932242AbXBSNiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 08:38:24 -0500
In-Reply-To: <20070219114117.GA22622@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 19 February 2007 12:41, Evgeniy Polyakov wrote:

> > 1 microsecond ? Are you kidding ? We want no more than 50 ns.
>
> Theory again.


Theory is nice, but I personally prefer oprofile :)
I base my comments on real facts.
We *want* 50 ns tcp lookups (2 cache line misses, one with reader intent, one 
for exclusive access intent)

>
> Existing table does not scale that good - I created (1<<20)/2 (to cover
> only established part) entries table and filled it with 1 million of random
> entries -search time is about half of microsecod.

I use exactly 1^20 slots, not 1^19 (see commit  
dbca9b2750e3b1ee6f56a616160ccfc12e8b161f , where I changed layout of ehash 
table so that two chains (established/timewait) are on the same cache line. 
every cache miss *counts*) 

http://www.mail-archive.com/netdev@vger.kernel.org/msg31096.html

(Of course, you may have to change MAX_ORDER to 14 or else the hash table hits 
the MAX_ORDER limit)

Search time under 100 ns, for real trafic (kind of random... but not quite)
Most of this time is taken by the rwlock, so expect 50 ns once RCU is finally 
in...

In your tests, please make sure a User process is actually doing real work on 
each CPU, ie evicting cpu caches every ms...

The rule is : On a normal machine, cpu caches contain UserMode data, not 
kernel data. (as a typical machine spends 15% of its cpu time in kernel land, 
and 85% in User land). You can assume kernel text is in cache, but even this 
assumption may be wrong.

