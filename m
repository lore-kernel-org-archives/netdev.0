From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Sat, 30 Jan 2016 10:36:25 -0800
Message-ID: <CAKgT0UcZAh+ciNMkJDdnp7E0xyGMhvgSzJLwORLqYXbpABtoRQ@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<20160130024556.6227.51798.stgit@localhost.localdomain>
	<1454124234.7627.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160130161702.GA11601@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35712 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932574AbcA3Sg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 13:36:26 -0500
Received: by mail-ig0-f181.google.com with SMTP id t15so10190293igr.0
        for <netdev@vger.kernel.org>; Sat, 30 Jan 2016 10:36:25 -0800 (PST)
In-Reply-To: <20160130161702.GA11601@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 30, 2016 at 8:17 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/29/16 19:23), Eric Dumazet wrote:
>> BTW, even a memcpy(&key_addrs->v4addrs, &iph->saddr, 8) could crash, as
>> the compiler can certainly assume src and dst are 4 bytes aligned, and
>> could use word accesses when inlining memcpy() even on Sparc.
>>
>> Apparently the compiler used by Sowmini is gentle.
>
> One more subtlety that I missed until now..
>
> eth_get_headlen passes in flow_keys_buf_dissector (NOT flow_keys_dissector!)
>
> So FLOW_DISSECTOR_KEY_IPV4_ADDRS is not set, and this helps to dodge
> the unaligned iph->saddr access.

Right this is a bug that got introduced in 4.2 when the check for !skb
was dropped in favor of the flow keys.

My thought was the patch I provided fixes 4.3, and could be applied to
stable for 4.2.  The concerns about GRE TEB and VXLAN go much further
back then that since if I am not mistaken the transmit path for both
is pretty much borked if we try to do GSO as either the inner headers
or outer headers are not aligned so assembling the header will likely
result in unaligned accesses.

> But as others have pointed out, much of this code is brittle
> because it's accessing the data before the driver has had a chance
> to align things. The page_offset initialization of NET_IP_ALIGN,
> with all its weaknesses, at least matches (in principle) the prescription
> used for the xmit path.

That is essentially an unfortunate side effect of this being a
function that has two very different roles to perform.  One goes
through and just determines the length of the frame, the other goes
through and gathers data for computing a hash.

As far as the NET_IP_ALIGN on the page offset I think it is a horrible
idea.  Basically it means we have to allocate at least 1K more space
than we need since page sizes are powers of 2, and buffer sizes in
hardware are measured in 1K increments.

Adding the unaligned reads probably doesn't do much to fix the actual
issue which is the unaligned headers (either inner or outer) on
architectures that don't support unaligned access.  If anything what I
really think we should look at doing is coming up with a way to just
pad the inner headers by NET_IP_ALIGN bytes if the architecture
doesn't support unaligned access and then output the inner and outer
headers as two separate buffers.

- Alex
