From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] udp: port starting location not random
Date: Thu, 4 Oct 2012 14:59:30 -0700
Message-ID: <20121004145930.7ca54fd5@nehalam.linuxnetplumber.net>
References: <20121004.171246.1480276635491836767.davem@davemloft.net>
	<20121004142859.08ab0385@nehalam.linuxnetplumber.net>
	<1349387153.21172.1.camel@edumazet-glaptop>
	<20121004.175009.1336502669507423764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33474 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752684Ab2JDWAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 18:00:07 -0400
In-Reply-To: <20121004.175009.1336502669507423764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 Oct 2012 17:50:09 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 04 Oct 2012 23:45:53 +0200
> 
> > On Thu, 2012-10-04 at 14:28 -0700, Stephen Hemminger wrote:
> >> On Thu, 04 Oct 2012 17:12:46 -0400 (EDT)
> >> David Miller <davem@davemloft.net> wrote:
> >> 
> >> > From: Stephen Hemminger <shemminger@vyatta.com>
> >> > Date: Thu, 4 Oct 2012 14:08:28 -0700
> >> > 
> >> > > While working on VXLAN, noticed a bug in UDP introduced by:
> >> > > 
> >> > > commit 9088c5609584684149f3fb5b065aa7f18dcb03ff
> >> > > Author: Eric Dumazet <dada1@cosmosbay.com>
> >> > > Date:   Wed Oct 8 11:44:17 2008 -0700
> >> > > 
> >> > >     udp: Improve port randomization
> >> > >     
> >> > > 
> >> > > The logic for choosing where to start for port randomization incorrectly
> >> > > calculates the starting port number. It is always ends up using
> >> > > the low end of the range independent of the value of random.
> >> > > This causes all UDP port searches to start at the same port.
> >> > > 
> >> > > Doing the following fixes it but at the cost of doing a real divide.
> >> > > 
> >> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >> > > 
> >> > > ---
> >> > > Resend, previous send was not going to netdev.
> >> > > 
> >> > > Not sure if worth fixing for stable, because only has performance impact
> >> > > and some application might be depending on current broken behaviour.
> >> > > 
> >> > > 
> >> > > 
> >> > > --- a/net/ipv4/udp.c	2012-10-01 17:06:53.107427436 -0700
> >> > > +++ b/net/ipv4/udp.c	2012-10-04 13:43:21.278960379 -0700
> >> > > @@ -216,7 +216,7 @@ int udp_lib_get_port(struct sock *sk, un
> >> > >  		remaining = (high - low) + 1;
> >> > >  
> >> > >  		rand = net_random();
> >> > > -		first = (((u64)rand * remaining) >> 32) + low;
> >> > > +		first = rand % remaining + low;
> >> > 
> >> > Try replacing "remaining" with "(remaining << (64 - 16))" in
> >> > the expression instead.
> >> 
> >> The standalone program gets same result.
> > 
> > Hey, I hope you understand random32() does allocate a 32bit value, not a
> > 15bit one...
> > 
> > If really we had such a bug, I am pretty sure we would have noticed.
> 
> But the issue is is "remaining" that's of limited range, not rand.
> I didn't say to shift up 'rand', but rather 'remaining'.

I think the issue is the Gcc is deciding to truncate the math.
If it is done as separate steps, then the right answer happens:

Good:
	t = ((uint64_t) rand * remaining) >> 32;
	first = t + low;

Bad:
	first = (((uint64_t)rand * remaining) >> (64-16)) + low;
