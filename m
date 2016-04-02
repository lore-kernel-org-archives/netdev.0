From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Fri, 1 Apr 2016 23:02:03 -0700
Message-ID: <CAKgT0UczB-j=V0mQcL09Oph2ZgQgWA6cpZfu_9KN+0w0CcuPuQ@mail.gmail.com>
References: <1459536543.6473.289.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160401.152405.915323132719949585.davem@davemloft.net>
	<CAKgT0UcLvAF9gTzcaR=GZyTkM2UQ6ymDmnisjgZiG8hTE+PdLA@mail.gmail.com>
	<20160401.221632.846129753053296932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35597 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbcDBGCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 02:02:05 -0400
Received: by mail-ig0-f181.google.com with SMTP id cl4so12387620igb.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 23:02:04 -0700 (PDT)
In-Reply-To: <20160401.221632.846129753053296932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 1, 2016 at 7:16 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Fri, 1 Apr 2016 12:58:41 -0700
>
>> RFC 6864 is pretty explicit about this, IPv4 ID used only for
>> fragmentation.  https://tools.ietf.org/html/rfc6864#section-4.1
>>
>> The goal with this change is to try and keep most of the existing
>> behavior in tact without violating this rule?  I would think the
>> sequence number should give you the ability to infer a drop in the
>> case of TCP.  In the case of UDP tunnels we are now getting a bit more
>> data since we were ignoring the outer IP header ID before.
>
> When retransmits happen, the sequence numbers are the same.  But you
> can then use the IP ID to see exactly what happened.  You can even
> tell if multiple retransmits got reordered.
>
> Eric's use case is extremely useful, and flat out eliminates ambiguity
> when analyzing TCP traces.

I'm not really sure the IP ID is really all that useful.  On a 10G
link it takes about 80ms for it to wrap using an MTU of 1500.  That
value is going to keep dropping as we move up to 40G and 100G.  That
was one of the motivations behind RFC 6864 because it starts becoming
a bottle-neck if you want to keep the IP IDs truly unique.  In
addition while this change would allow you to combined disjointed IP
IDs I don't think you would lose the re-transmission as there would
likely be a gap in sequence numbers that would cause the flow to be
flushed from GRO, and it isn't as if we can prepend the retransmit to
the aggregated frame, we are always adding to the tail.

I would think the most likely case where this change would foul up any
IP IDs would be the garbage-in/garbage-out case like the IPv6 to IPv4
translation that is using the fixed IP ID of 0.  I agree that it isn't
desirable, however at the same time per RFC 6864 there is nothing
there to say we cannot do that.  In addition it would likely help to
mitigate some of the impact of IP ID on things like SLHC compression
since the resegmented frames would be incrementing so it would reduce
the number of times the IP ID would have to be updated.

- Alex
