From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 0/8] Basic MPLS support
Date: Fri, 27 Feb 2015 18:58:09 -0600
Message-ID: <87mw3yg8da.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, santiago@crfreenet.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:54207 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbbB1BBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 20:01:50 -0500
In-Reply-To: <20150227.162131.431559184124647735.davem@davemloft.net> (David
	Miller's message of "Fri, 27 Feb 2015 16:21:31 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Wed, 25 Feb 2015 11:09:23 -0600
>
>> While trying to figure out what MPLS is and why MPLS support is not in
>> the kernel on a lark I sat down and wrote an MPLS implemenation, so I
>> could answer those questions for myself.
>> 
>> From what I can tell the short answer is MPLS is trivial-simple and the
>> we don't have an in-kernel implementation because no one has sat down
>> and done the work to have a good mergable implementation.
>> 
>> MPLS has it's good sides and it's bad sides but at the end of the day
>> MPLS has users, and having an in-kernel implementation should help us
>> understand MPLS and focus our conversations dealing with MPLS and
>> VRFs.
>> 
>> Having MPLS in our toolkit as the entire world begins playing with
>> overlay networks aka ``network virtualization'' to support VM and
>> container migration seems appropriate as MPLS is the historical solution
>> to this problem.
>> 
>> Constructive criticism about the netlink interface is especially
>> appreciated.  Hopefully we can have at least one protocol in the kernel
>> where the netlink interface doesn't have nasty corner case.
>> 
>> As for linux users.  The conversations I had at netdev01 this sounds
>> like a case of if I build it people will use the code.
>
> At a high level I have no objections to this work and I'm in fact
> extremely happy to see someone working on this.

Thank you.  That statement alone I think is enough to ensure that
someone completes this work.

> However I would ask you to reconsider the neighbour handling issue.
>
> It seems to me that routing daemons are going to more naturally work
> with ipv4 addresses as MPLS next hops, and therefore when that's the
> case we should too.
>
> Why?
>
> Because then the neighbour layer handles failover transparently for
> you.

I have no objection to using the neighbour table for ipv4 or ipv6
next hops.  I simply did not implement them out of expediency.

Part of that expediency was the realization that waiting for neighbour
resolution before transmitting packets requires the packets have dst
entries.  Something that is not otherwise required.  That seems to add
a noticable amount of complexity to the forwarding code.  If nothing
else I have to manage dst objects and their packet specific lifetimes.

There is also my experience in router contexts that says arp or
neighbour discovery is usually the last thing to know (short of
gratuitious arps) that a neighbour has failed.  So some other protocol
is needed to detect failure.

At the same time if you have a static configuration a arp or ipv6
neighbour discovery is the only thing you have so it those protocols
definitely has some value.

I think to properly handle ipv4 and ipv6 next hops I would need to pull
the neighbour cache apart and and put it back together again while
reexaming all of it's assumptions about which things are a good idea to
optimize.   That feels like more work in benchmarking etc than the MPLS
code has been so far.  

Little details make a big difference, especially the question of when
we are caching the link-layer header do we take a performance hit if we
don't cache the protocol type in the cached link-layer header?   Upon
that question revolves the effort of refactoring the neighbour cache to
support multiple protocol types.  There are other questions such as is
there actually a benefit in caching the link-layer header?

> Think about it, if we have a case where some other resolving mechanism
> would be used for MPLS nexthops, there would need to be some kind of
> fail over handling mechanism for it as well.

Good question.  What I know for certain is that the MPLS-TP
specification does not use IPv4 or IPv6 next hops.  I think in those use
cases some of the next hops don't actually have link-layer addresses,
and I expect some of them are designed to be used on machines where the
control plane and the data plane are separate interfaces.  Which
suggests that there would not be any next hop resolution as we are
familiar with it, in the case of ethernet and related networks.

I don't know if any of those weird cases apply to Linux.  That is I
don't know if anyone would ever connect one of those weird MPLS users
as a nexthop to a MPLS speaking linux box.

So I don't know that the usual conditions do not apply or if we would
ever actually need a Link-Layer Gateway address.  I just know it was
coding MPLS in that way seemed much simpler, easier and more performant
than figuring out the neighbor cache.

Eric
