From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Sun, 31 Jan 2016 01:12:03 -0800
Message-ID: <CAKgT0UepN041H4QcWkoNWnzGgf=yo71w8_3-JQKFFNBegQVpzA@mail.gmail.com>
References: <CAKgT0UcZAh+ciNMkJDdnp7E0xyGMhvgSzJLwORLqYXbpABtoRQ@mail.gmail.com>
	<1454182011.7627.141.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAKgT0UfyK1HO6vp4F9S3rB400A74OhS=qRX_N9RuPRYg2KazLg@mail.gmail.com>
	<20160130.194507.777391919166997236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35737 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbcAaJMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 04:12:05 -0500
Received: by mail-ig0-f175.google.com with SMTP id t15so16092599igr.0
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 01:12:03 -0800 (PST)
In-Reply-To: <20160130.194507.777391919166997236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 30, 2016 at 7:45 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Sat, 30 Jan 2016 17:13:35 -0800
>
>> The NIC hardware only allows us to set receive buffer sizes in 1K
>> increments.  I think fm10k may be an exception in that it may be able
>> to support 512 byte, but otherwise igb and ixgbe are strictly set in
>> 1K increments.  So basically if we did the NET_IP_ALIGN of the page we
>> are limited to 1K buffers if we were to retain the current page reuse,
>> or we could go up to 3K if we were to allocate order 1 pages for
>> receive buffers as currently occurs with FCoE.
>>
>> I would really prefer to keep the pages DMA aligned, and the skb->data
>> IP aligned.  If nothing else it has the advantage of actually having
>> the proper alignment on all the headers if I only pull the outer
>> headers and leave the inner headers in the page.. :-/
>
> I am unconvinced by your arguments.  People getting hit by these
> arguments don't care.  For those not hitting the problem, nothing is
> going to change.
>
> x86 uses NET_IP_ALIGN==0, and therefore nothing will change for the
> only platform people care a lot about.  PowerPC too.

I think you may be getting confused about the scope of what you are
talking about.  The region pointed to by skb->data is IP aligned when
we pass it to the stack.  So the scope of this is very limited and
should only effect the flow dissector.  If needed I would be more than
happy to just fork the function and write up a version that only gets
the length of headers and is good with a 2 byte aligned header.  This
was one of my original misgivings about merging the functionality of
the flow dissector and the functions I was maintaining in the Intel
drivers.

> For platforms with NET_IP_ALIGN==2 or similar, all of these cases
> where 1K extra buffer is allocator or _whatever_ other side effect you
> think is such as huge deal...  trust me it's _nothing_ compared to the
> alternative:

We pay a pretty hefty truesize penalty for consuming any more memory
then we need to.  The changes as proposed would essentially kick our
truesize from 3K to 5K per frame.  It would double the space needed
since it isn't like I can just tell the page allocater to give me an
additional 2 bytes, it bumps me from 4K to 8K.  There would be a
noticeable performance drop, though I admit I don't know if it would
be a very big group noticing it since we are talking about some lesser
used architectures.

> 1) Unaligned accesses

Changing the driver doesn't fix the unaligned accesses problem.  It is
still there with the inner headers on GRE Transparent Ethernet Bridge.
That is why I believe Tom is still trying to come up with a solution
for it.

> 2) Constantly having to say "oops this case, oops that case, oops shit
>    we have to handle this too" as we constantly patch up flow
>    dissector and other paths.

The flow dissector is the only spot that has to deal with this.  If
you forget I had my own function we were perfectly happy to use with
the Intel drivers but I was told we needed to use this one as we
didn't want to duplicate functionality.

The fact is this function served its purpose perfectly fine until
commit b924933cbbfb "flow_dissector: introduce support for ipv6
addressses".  That is when the bug was introduced that is fixed by the
patch I submitted.

> Please, pass aligned buffers to the flow dissector, and let's put this
> behind us, _provably_, for good.

What is the point.  As pointed out earlier there is still an issue
with GRE TEB.  My patch is the surgical approach and fixes the
original issue and is easy to backport to the other kernels that have
this issue.  What you are asking me for is to go through and make
serious changes to igb, ixgbe, ixgbevf, fm10k, and mlx4.  If anything
I would think that fixing this in net with the least invasive patch
would be preferred.  If we want to go through and rewrite the receive
paths in multiple drivers to allow them to use IP aligned pages on
architectures that many of us don't have then we should focus on doing
that in net-next where we can prove out that we aren't making things
worse.

I'm standing by my original patch and still think it is the best fix
for net.  If you want me to go through and rearchitect the drivers so
that they only ever pass IP aligned page buffers to the flow dissector
then I really think it should wait until net-next as it isn't going to
be a small change set, and I don't have the systems or NICs here to be
able to test all of it.

> Thanks.

If nothing else we can discuss this further in Seville as I am just
not convinced changing the drivers is the right way to go about fixing
this, and I won't have the time to really get around to doing any of
it until I have come back from the conference.

Thanks.

- Alex
