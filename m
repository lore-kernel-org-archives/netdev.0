From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Wed, 23 Mar 2016 19:53:43 -0700
Message-ID: <CAKgT0UcbX+Kfa0+B57ZOMfeNgDvAuFhQO=oVw2m4kGyurBqFSQ@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160318232522.14955.13475.stgit@localhost.localdomain>
	<CALx6S35wK2_eR1e5OTHnQTkQRg763unS0sCMQU+Jk6e27F26Vw@mail.gmail.com>
	<CAKgT0Uc9FNJ59529V8=0vtZnVij+JrZ2s-uOpFjnvbiqNHdVYQ@mail.gmail.com>
	<CAEh+42jKm0_89n_-vZwMRZHUpNgNVJLJ5Qo4YrhRZx7UZD0Swg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34542 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260AbcCXCxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 22:53:45 -0400
Received: by mail-io0-f171.google.com with SMTP id m184so73298485iof.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 19:53:44 -0700 (PDT)
In-Reply-To: <CAEh+42jKm0_89n_-vZwMRZHUpNgNVJLJ5Qo4YrhRZx7UZD0Swg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 6:37 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Wed, Mar 23, 2016 at 11:19 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Wed, Mar 23, 2016 at 10:09 AM, Tom Herbert <tom@herbertland.com> wrote:
>>> Can you add some description about strategy for dealing with ip_id?
>>
>> Yeah.  I still need to add more documentation.  I just didn't want to
>> get into details on it until we have finalized things a bit more.  I'm
>> still wondering if we should follow the pattern of ipip tunnels in
>> terms of setting the DF bit if the inner header has the DF bit set.
>> If we end up needing to add code to do that then it makes it so that
>> the ip_id value can be fixed for both inner and outer which makes the
>> segmentation much simpler since the only header that would ever really
>> need to be updated would be the transport header in order to get the
>> checksum correct.
>
> I tried to do this years ago but in practice it broke things.
>
> There's enough middleboxes/firewalls/etc. out there that filter ICMP
> messages that path MTU discovery isn't necessarily reliable. And while
> you might argue that if the box is breaking things then the same would
> be true for the original, unencapsulated TCP stream but a lot of times
> there are some other hacks built in (like MSS clamping) that make
> assumptions that the traffic is TCP. So at the minimum it is generally
> good to have an option to force the DF bit off.

Agreed, I think if we tried anything we would have to have some sort
of bit remaining to shut it off.

> That being said, I actually think that it is good to have the DF bit
> on by default for encapsulation headers being added. Unintentional
> (and perhaps multiple layers of) fragmentation usually results in
> unuseably bad performance and so it best to try to correct it,
> hopefully automatically in most cases. And, of course, this is the
> direction that IPv6 has already gone. If we can assume that this is
> the most common case then in practice we can keep the outer headers
> constant for the high performance path.

I'm still weighting my options on how to address the DF issue.  I'm
not really sure having DF always on for outer headers is the best way
to go either.  I kind of like the idea that if DF is set for the inner
headers then we set it for the outer headers.  I just have to see how
hard something like that would be to implement.

> To me, incrementing the inner IP really seems the best choice. The
> inner header is most likely someone else's traffic so it best to not
> mess with that whereas the outer headers are likely ours and we know
> the parameters for them (and can set the DF bit as we believe is
> correct). Also, if you are looking forward to the future as far as
> stacking multiple layers of tunnels, I think the only consistent thing
> to do is have the inner ID increment and all of the tunnel headers
> stay fixed - it is hard to justify why the first tunnel header should
> increment but not the second one. And finally, as a nice bonus, this
> is what the GRO code has been expecting already so you won't cause any
> performance regressions with existing systems.

Agreed.  However in the case of the igb and ixgbe incrementing the
inner isn't really going to work well as it introduces a number of
issues.  I've considered not enabling GSO partial by default on those
parts, but leaving it as an available feature.  In the case of i40e we
will not have any of those issues as both the inner and outer IP IDs
will increment.

The regressions issue shouldn't be all that big.  In most cases
tunnels are point to point links.  Odds are if someone is running a
network they should have similar devices on both ends.  So in the case
of the Intel drivers I have patched here updating i40e isn't that big
of a deal since it retains the original GSO behavior.  In the case of
ixgbe it didn't support any tunnel offloads so there is no GRO support
without checksums being enabled in the tunnel, and Tx checksum support
vi HW_CSUM has yet to be pushed upstream from Jeff's tree so things
are currently throttled by the Tx side.

GSO partial is going to end up being very driver specific in terms of
what increments and what doesn't as we are having to really hack our
way around to make it do things the spec sheets say it cannot do.
Some implementations are going to end up working out better than
others in terms of interoperability and what can make use of other
advanced features such as GRO on legacy systems.

- Alex
