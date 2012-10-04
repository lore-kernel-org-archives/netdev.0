From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: port starting location not random
Date: Thu, 04 Oct 2012 23:45:53 +0200
Message-ID: <1349387153.21172.1.camel@edumazet-glaptop>
References: <20121004140828.2d6f7bf9@nehalam.linuxnetplumber.net>
	 <20121004.171246.1480276635491836767.davem@davemloft.net>
	 <20121004142859.08ab0385@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54689 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946259Ab2JDVp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 17:45:57 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so810587eek.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 14:45:56 -0700 (PDT)
In-Reply-To: <20121004142859.08ab0385@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-04 at 14:28 -0700, Stephen Hemminger wrote:
> On Thu, 04 Oct 2012 17:12:46 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Thu, 4 Oct 2012 14:08:28 -0700
> > 
> > > While working on VXLAN, noticed a bug in UDP introduced by:
> > > 
> > > commit 9088c5609584684149f3fb5b065aa7f18dcb03ff
> > > Author: Eric Dumazet <dada1@cosmosbay.com>
> > > Date:   Wed Oct 8 11:44:17 2008 -0700
> > > 
> > >     udp: Improve port randomization
> > >     
> > > 
> > > The logic for choosing where to start for port randomization incorrectly
> > > calculates the starting port number. It is always ends up using
> > > the low end of the range independent of the value of random.
> > > This causes all UDP port searches to start at the same port.
> > > 
> > > Doing the following fixes it but at the cost of doing a real divide.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > > 
> > > ---
> > > Resend, previous send was not going to netdev.
> > > 
> > > Not sure if worth fixing for stable, because only has performance impact
> > > and some application might be depending on current broken behaviour.
> > > 
> > > 
> > > 
> > > --- a/net/ipv4/udp.c	2012-10-01 17:06:53.107427436 -0700
> > > +++ b/net/ipv4/udp.c	2012-10-04 13:43:21.278960379 -0700
> > > @@ -216,7 +216,7 @@ int udp_lib_get_port(struct sock *sk, un
> > >  		remaining = (high - low) + 1;
> > >  
> > >  		rand = net_random();
> > > -		first = (((u64)rand * remaining) >> 32) + low;
> > > +		first = rand % remaining + low;
> > 
> > Try replacing "remaining" with "(remaining << (64 - 16))" in
> > the expression instead.
> 
> The standalone program gets same result.


Hey, I hope you understand random32() does allocate a 32bit value, not a
15bit one...

If really we had such a bug, I am pretty sure we would have noticed.
