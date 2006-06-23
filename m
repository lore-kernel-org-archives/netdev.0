From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Locking validator output on DCCP
Date: Fri, 23 Jun 2006 09:45:49 +0200
Message-ID: <20060623074549.GA30155@elte.hu>
References: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com> <20060621003413.GA31915@gondor.apana.org.au> <1150885091.3057.30.camel@laptopd505.fenrus.org> <5640c7e00606212151y213c0bfap5e02a77d9363ebb7@mail.gmail.com> <5640c7e00606221938g17516d08yf6733fc35f866d01@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>,
	DCCP Mailing List <dccp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:32440 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S932924AbWFWHuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 03:50:51 -0400
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Content-Disposition: inline
In-Reply-To: <5640c7e00606221938g17516d08yf6733fc35f866d01@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:

> OK. This is in net/ipv4/tcp_ipv4.c tcp_v4_rcv with the 
> bh_lock_sock_nested which I presume is clashing with the nested of 
> skb_clone....

yeah, that's exactly what happens.

> Can we not do two levels nested?

we can - but it needs to be thought through (and needs to be tested). 
But an initial glance seems to suggest that two levels, one used for 
clone and another one used for tcp_v4_rcv nesting ought to do the trick.

> Is there extra documentation for the locking validation suite so that 
> I can stop asking stupid questions? If not I'll just read more of the 
> source code.

i'd suggest to start with: Documentation/lockdep-design.txt, then with 
include/linux/lockdep.h and also look at some of the existing patches 
that introduce multiple nesting levels, such as:

    http://kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.17/2.6.17-mm1/broken-out/lock-validator-special-locking-dcache.patch

the best method is to find the proper central header for the level enum, 
and then make use of it. The enum should have a descriptive name, and 
the enum values too.

If one particular lock has multiple levels then SINGLE_DEPTH_NESTING 
should not be used. (to keep the levels architecture clean) I.e. 
possibly the best idea would be to extend bh_lock_sock_nested() with a 
'subtype' parameter, and to pass that into spin_lock_nested().

Or even better: define bh_lock_sock_nested() as an inline function with 
the right enum parameter, which will make sure only the right type of 
enum will be used. [if it's possible to do it as an inline there - it's 
a macro right now and i'm not sure all the types necessary for the 
inline are declared up to that point in the sock.h include file]

	Ingo
