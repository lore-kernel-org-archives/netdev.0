From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] GRO scalability
Date: Fri, 05 Oct 2012 21:00:34 +0200
Message-ID: <1349463634.21172.152.camel@edumazet-glaptop>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
	 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
	 <1348769294.5093.1566.camel@edumazet-glaptop>
	 <1348769990.5093.1584.camel@edumazet-glaptop>
	 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
	 <1348841041.5093.2477.camel@edumazet-glaptop>
	 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
	 <1349448747.21172.113.camel@edumazet-glaptop>  <506F23F6.1060704@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56089 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909Ab2JETAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 15:00:39 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1106979bkc.19
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 12:00:38 -0700 (PDT)
In-Reply-To: <506F23F6.1060704@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-05 at 11:16 -0700, Rick Jones wrote:
> O
> Flushing things if N packets have come though sounds like goodness, and 
> it reminds me a bit about what happens with IP fragment reassembly - 
> another area where the stack is trying to guess just how long to 
> hang-onto a packet before doing something else with it.  But the value 
> of N to get a "decent" per-flow GRO aggregation rate will depend on the 
> number of concurrent flows right?  If I want to have a good shot at 
> getting 2 segments combined for 1000 active, concurrent flows entering 
> my system via that interface, won't N have to approach 2000?
> 

It all depends on the max latency you can afford.

> GRO (and HW LRO) has a fundamental limitation/disadvantage here.  GRO 
> does provide a very nice "boost" on various situations (especially 
> numbers of concurrent netperfs that don't blow-out the tracking limits) 
> but since it won't really know anything about the flow(s) involved (*) 
> or even their number (?), it will always be guessing.  That is why it is 
> really only "poor man's JumboFrames" (or larger MTU - Sadly, the IEEE 
> keeps us all beggars here).
> 
> A goodly portion of the benefit of GRO comes from the "incidental" ACK 
> avoidance it causes yes?  That being the case, might that be a 
> worthwhile avenue to explore?   It would then naturally scale as TCP et 
> al do today.
> 
> When we go to 40 GbE will we have 4x as many flows, or the same number 
> of 4x faster flows?
> 
> rick jones
> 
> * for example - does this TCP segment contain the last byte(s) of a 
> pipelined http request/response and the first byte(s) of the next one 
> and so should "flush" now?

Some remarks :

1) I use some 40Gbe links, thats probably why I try to improve things ;)

2) benefit of GRO can be huge, and not only for the ACK avoidance
   (other tricks could be done for ACK avoidance in the stack)

3) High speeds probably need multiqueue device, and each queue has its
own GRO unit.

  For example on a 40Gbe, 8 queues -> 5Gbps per queue (about 400k
packets/sec)

Lets say we allow no more than 1ms of delay in GRO, this means we could
have about 400 packets in the GRO queue (assuming 1500 bytes packets)

Another idea to play with would be to extend GRO to allow packet
reorder.
