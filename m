From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] GRO scalability
Date: Fri, 05 Oct 2012 11:16:22 -0700
Message-ID: <506F23F6.1060704@hp.com>
References: <1348750130.5093.1227.camel@edumazet-glaptop> <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com> <1348769294.5093.1566.camel@edumazet-glaptop> <1348769990.5093.1584.camel@edumazet-glaptop> <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com> <1348841041.5093.2477.camel@edumazet-glaptop> <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com> <1349448747.21172.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:6961 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932101Ab2JESQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 14:16:26 -0400
In-Reply-To: <1349448747.21172.113.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2012 07:52 AM, Eric Dumazet wrote:
> What we could do :
>
> 1) Use a hash to avoid expensive gro_list management and allow
>     much more concurrent flows.
>
> Use skb_get_rxhash(skb) to compute rxhash
>
> If l4_rxhash not set -> not a GRO candidate.
>
> If l4_rxhash set, use a hash lookup to immediately finds a 'same flow'
> candidates.
>
> (tcp stack could eventually use rxhash instead of its custom hash
> computation ...)
>
> 2) Use a LRU list to eventually be able to 'flush' too old packets,
>     even if the napi never completes. Each time we process a new packet,
>     being a GRO candidate or not, we increment a napi->sequence, and we
>     flush the oldest packet in gro_lru_list if its own sequence is too
>     old.
>
>    That would give a latency guarantee.

Flushing things if N packets have come though sounds like goodness, and 
it reminds me a bit about what happens with IP fragment reassembly - 
another area where the stack is trying to guess just how long to 
hang-onto a packet before doing something else with it.  But the value 
of N to get a "decent" per-flow GRO aggregation rate will depend on the 
number of concurrent flows right?  If I want to have a good shot at 
getting 2 segments combined for 1000 active, concurrent flows entering 
my system via that interface, won't N have to approach 2000?

GRO (and HW LRO) has a fundamental limitation/disadvantage here.  GRO 
does provide a very nice "boost" on various situations (especially 
numbers of concurrent netperfs that don't blow-out the tracking limits) 
but since it won't really know anything about the flow(s) involved (*) 
or even their number (?), it will always be guessing.  That is why it is 
really only "poor man's JumboFrames" (or larger MTU - Sadly, the IEEE 
keeps us all beggars here).

A goodly portion of the benefit of GRO comes from the "incidental" ACK 
avoidance it causes yes?  That being the case, might that be a 
worthwhile avenue to explore?   It would then naturally scale as TCP et 
al do today.

When we go to 40 GbE will we have 4x as many flows, or the same number 
of 4x faster flows?

rick jones

* for example - does this TCP segment contain the last byte(s) of a 
pipelined http request/response and the first byte(s) of the next one 
and so should "flush" now?
