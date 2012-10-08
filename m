From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] GRO scalability
Date: Mon, 08 Oct 2012 18:59:21 +0200
Message-ID: <1349715561.21172.3463.camel@edumazet-glaptop>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
	 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
	 <1348769294.5093.1566.camel@edumazet-glaptop>
	 <1348769990.5093.1584.camel@edumazet-glaptop>
	 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
	 <1348841041.5093.2477.camel@edumazet-glaptop>
	 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
	 <1349448747.21172.113.camel@edumazet-glaptop>  <506F23F6.1060704@hp.com>
	 <1349463634.21172.152.camel@edumazet-glaptop>  <506F368F.3070403@hp.com>
	 <1349467578.21172.178.camel@edumazet-glaptop>  <50730217.6020206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34099 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab2JHQ70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 12:59:26 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2177254bkc.19
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2012 09:59:25 -0700 (PDT)
In-Reply-To: <50730217.6020206@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-08 at 09:40 -0700, Rick Jones wrote:
> On 10/05/2012 01:06 PM, Eric Dumazet wrote:
> > On Fri, 2012-10-05 at 12:35 -0700, Rick Jones wrote:
> >
> >> Just how much code path is there between NAPI and the socket?? (And I
> >> guess just how much combining are you hoping for?)
> >>
> >
> > When GRO correctly works, you can save about 30% of cpu cycles, it
> > depends...
> >
> > Doubling MAX_SKB_FRAGS (allowing 32+1 MSS per GRO skb instead of 16+1)
> > gives an improvement as well...
> 
> OK, but how much of that 30% come from where?  Each coalesced segment is 
> saving the cycles between NAPI and the socket.  Each avoided ACK is 
> saving the cycles from TCP to the bottom of the driver and a (share of) 
> transmit completion.

It comes from the fact that you have less competition between Bottom
Half handler and application on socket lock, not counting all layers
that we have to cross (IP, netfilter ...)

Each time a TCP packet is delivered and socket owned by the user, packet
is placed on a special 'backlog queue', and application has to process
this packet right before releasing socket lock. It sucks because it adds
latencies, and other frames are queued to backlokg since application
processes the backlog (very expensive because of cache line misses)

So GRO really makes this kind of event less probable.

> 
> Whe I say shuffle I mean something along the lines of interleave.  So, 
> if we have four flows, 1-4, a perfect shuffle of their segments would be 
> something like:
> 
> 1 2 3 4 1 2 3 4 1 2 3 4
> 
> but not well shuffled might look like
> 
> 1 1 3 2 3 2 4 4 4 1 3 2
> 

If all these packets are delivered in the same NAPI run, and correctly
aggregated, their order doesnt matter.

In first case, we will deliver  B1, B2, B3, B4   (B being a GRO packet
with 3 MSS)

In second case we will deliver

B1 B3 B2 B4
