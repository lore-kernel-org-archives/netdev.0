From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including destination address in the hash key
Date: Thu, 5 Nov 2009 18:25:45 +0200
Message-ID: <200911051825.45749.opurdila@ixiacom.com>
References: <4AF1EC18.9090106@ixiacom.com> <200911050104.09538.opurdila@ixiacom.com> <4AF20F02.7000601@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:3680 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751808AbZKEQ2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 11:28:44 -0500
In-Reply-To: <4AF20F02.7000601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 05 November 2009 01:32:18 you wrote:

> >
> > Very true, the benchmark itself shows a significant overhead increase on
> > the TX side and indeed this case is not very common. But for us its an
> > important usecase.
> >
> > Maybe there is a more clever way of fixing this specific use-case without
> > hurting the common case?
> 
> Clever way ? Well, we will see :)
> 
> I now understand previous Lucian patch (best match) :)
> 
> Could you please describe your usecase ? I guess something is possible,
> not necessarly hurting performance of regular usecases :)
> 

IIRC, we first saw this issue in VoIP tests with up to 16000 sockets bound on a 
certain port and IP addresses (each IP address is assigned to a particular 
interface). We need this setup in order to emulate lots of VoIP users each 
with a different IP address and possible a different L2 encapsulation.

Now, as a general note I should say that our usecases can seem absurd if you 
take them out of the network testing field :) but my _personal_ opinion is that 
a better integration between our code base and upstream code may benefit both 
upstream and us:

- for us it gives the ability to stay close to upstream and get all of the new 
shiny features without painful upgrades

- for upstream, even if most systems don't run into these scalability issues 
now, I see that some people are moving in that direction (see the recent PPP 
problems); also, stressing Linux in that regard can only make the code better 
- as long as the approach taken is clean and sound

- we (or our customers) use a plethora of networking devices for testing so 
exposing Linux early to those devices can only help catching issues earlier

In short: expect more absurd patches from us :) 

> I have struct reorderings in progress to reduce number of cache lines read
> per socket from two to one. So this would reduce by 50% time to find
> a particular socket in the chain.
> 
> But if you *really* want/need 512 sockets bound to _same_ port, we probably
>  can use secondary hash tables (or rbtree), as soon as we stack more than
>  XX sockets on a particular slot.
> 
> At lookup, we check if extended hash table exists before doing
> normal rcu lookup.
> 
> Probably can be done under 300 lines of code.
> On normal machines, these extra tables/trees would not be used/allocated
> 

Yep, that should work. Will respin the patch based on this idea and see what 
we get, but it will take a while.

Thanks,
tavi

