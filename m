From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default	configurable
Date: Wed, 01 Jul 2009 19:01:15 +0200
Message-ID: <4A4B965B.4070700@trash.net>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <4A4B24DE.10103@trash.net> <20090701090736.GA32306@gondor.apana.org.au> <4A4B2AA8.3090406@trash.net> <20090701163335.GA5559@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63836 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbZGARBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 13:01:22 -0400
In-Reply-To: <20090701163335.GA5559@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Jul 01, 2009 at 11:21:44AM +0200, Patrick McHardy wrote:
>> Agreed, at least as long as this is still the default behaviour.
>> Mark, could you add this to your patch? br_nf_pre_routing_finish()
>> looks like a good place to print a warning when skb->nfct != NULL.
> 
> Here's a suggestion:
> 
> Can we add another field to the conntrack tuple? This would be used
> to ensure that every bridge's conntrack is distinct from each other,
> as well as that of the system IP stack.

We would need a key that can be uniquely determined at all points
and that can be inverted (taking into account ebtables NAT, NAT to
a different bridge etc) - I can't think of a suitable one right now.
But besides the conntrack size increase, I don't think this is the
correct solution for this problem.

Defragmentation (before conntrack) would still allow fragments to
cross boundaries, unless we key the defragmentation queues using the
same key. And generally defragmenting bridged packets by default,
possibly passing them through NAT, IP routing etc. is simply wrong
and only (somewhat) works in certain scenarios. Helpers might get
confused when the same packet is flooded to multiple output ports,
IPsec policies might magically get applied, etc etc. The best way
to make people aware of all these implications and avoid unsuspecting
people running into this again and again would be to change the
defaults and have people think before they use this. Long term I
think this needs to be completely redesigned.

And for the record, I don't believe that this is used a lot and we're
just not aware because it simply works. The fact is it always had major
problems that we fixed as good as possible over the years, but I'm
pretty certain I've heard from just about every user of this at least
once :)

