From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: port starting location not random
Date: Thu, 04 Oct 2012 23:57:54 +0200
Message-ID: <1349387874.21172.5.camel@edumazet-glaptop>
References: <20121004.171246.1480276635491836767.davem@davemloft.net>
	 <20121004142859.08ab0385@nehalam.linuxnetplumber.net>
	 <1349387153.21172.1.camel@edumazet-glaptop>
	 <20121004.175009.1336502669507423764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:39291 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab2JDV57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 17:57:59 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so638184wey.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 14:57:58 -0700 (PDT)
In-Reply-To: <20121004.175009.1336502669507423764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-04 at 17:50 -0400, David Miller wrote:
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

Sorry I see no issue.

remaining is the delta between high and low, and its right,
unless your compiler or cpu has a nice bug.

remaining = (high - low) + 1;

And I see no bug at all here.

The only assumption is that rand is a random number between 0 and
0xFFFFFFFF

$RANDOM is between 0 and 0x7FFF

Thats the difference
