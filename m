From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 07 Nov 2013 20:21:57 -0800
Message-ID: <1383884517.9412.172.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
	 <20131107.161755.355597965034457889.davem@davemloft.net>
	 <20131107213111.GA6885@gondor.apana.org.au>
	 <20131107.170651.1819930710384730745.davem@davemloft.net>
	 <20131108021758.GA13467@gondor.apana.org.au>
	 <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383879113.9412.155.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108032359.GA14132@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:42652 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754244Ab3KHEWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 23:22:00 -0500
Received: by mail-pd0-f181.google.com with SMTP id x10so1578363pdj.26
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 20:21:59 -0800 (PST)
In-Reply-To: <20131108032359.GA14132@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 11:23 +0800, Herbert Xu wrote:
> On Thu, Nov 07, 2013 at 06:51:53PM -0800, Eric Dumazet wrote:
> > On Thu, 2013-11-07 at 18:42 -0800, Eric Dumazet wrote:
> > 
> > > A normal TSO packets with 16 MSS setups a ~17 DMA descriptors,
> > > while GSO requires 2 DMA descriptors per MSS, plus a lot of overhead
> > > in sk_buff allocation/deallocation.
> > 
> > Not mentioning fact that a 64KB packet is adding latencies, since high
> > prio packets have to wait the whole preceding 64KB packet has left the
> > host.
> 
> That would be a bug in the GRO code since a high prio packet
> shouldn't have been merged in the first place and therefore
> the usual priority mechanism should allow it to preempt the
> 64KB packet.

Some users install Qdisc (AQM) on their router, to decide of what is
high priority and what is not. Their iptables or qdisc filters can be
quite complex.

Its all TCP for example.

GRO stack cannot make this decision.

So lets say we receive on ingress a mix of high prio packets and low
prio TCP packets. If GRO stack is able to build super big GRO packet,
then this super big GRO packet is a head of line blocking.

At 1Gbps, a 16 MSS packet is holding the line for about 190 us.

At 45 MSS, you basically multiply by 3 this latency.

What we probably want is a way to tune this latency, not ignore the
problem by making big GRO packets.

The only current choice for the user is to enable or disable GRO per
ingress port.

Thats a trivial patch, but net-next is closed at this moment.
