From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ip: make IP identifiers less predictable
Date: Sat, 26 Jul 2014 01:05:42 +0200
Message-ID: <1406329542.14815.17.camel@localhost>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+55aFyCDNq3E+bZ3aPfS33w8mA_86J+cNWR5V6fdogNihSh2Q@mail.gmail.com>
	 <53D27E0E.40102@cs.unm.edu>
	 <1406311751.3363.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+55aFwZrF88Fj7arP2P3rRshBTaxbjyJkKuOAu2Y4tVQ3kWWA@mail.gmail.com>
	 <1406313497.3363.98.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jeffrey Knockel <jeffk@cs.unm.edu>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	Willy Tarreau <w@1wt.eu>,
	"security@kernel.org" <security@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53906 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750765AbaGYXFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 19:05:46 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway1.nyi.internal (Postfix) with ESMTP id C0102223E0
	for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 19:05:45 -0400 (EDT)
In-Reply-To: <1406313497.3363.98.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fr, 2014-07-25 at 20:38 +0200, Eric Dumazet wrote:
> On Fri, 2014-07-25 at 11:35 -0700, Linus Torvalds wrote:
> > On Fri, Jul 25, 2014 at 11:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > >
> > > We might change the hash to use both daddr & saddr to increase
> > > protection.
> > 
> > .. and maybe protocol too, so that you can't easily use icmp echo
> > packets to do it for udp packets etc. The underlying jhash is
> > jhash_3words(), so that would actually be fairly natural for at least
> > ipv4 (the ipv6 case I didn't look at).
> 
> Right, in fact saddr is probably not worth it.
> 
> Its not like servers have dozen of IPv4 addresses anyway...

Another idea, maybe worth looking at:

Since commit 703133de331a7a ("ip: generate unique IP identificator if
local fragmentation is allowed") we started to generate fragmentation
ids in the output path for every packet that has ignore_df set, which
nearly is every packet.

We could try to push that down the stack and only insert the
fragmentation id in ip_fragment. We still need to generate the frag_id
directly from the socket layer, but we can reuse the ip6_frag_id field
in skb_shinfo for IPv4, too.

Then we actually only need to generate fragmentation ids for the VJ
compression workaround, generated from the socket->inet_id. Do we still
need this (I guess, yes)?

Does this sound worth a try or are there any unseen protocol specific
consequences I am not yet aware of? We would stop leaking too many
fragmentation ids with this change.

Thanks,
Hannes
