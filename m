From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected sockets
Date: Thu, 8 Dec 2016 12:44:51 -0800
Message-ID: <CALx6S36BJ5t03onqn1b7R6ZfxiTG8rr2xTCOfoMjSWZh7T-=5w@mail.gmail.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480944138.4694.37.camel@redhat.com> <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481020451.6225.38.camel@redhat.com> <1481044098.7129.7.camel@redhat.com>
 <1481046434.18162.599.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481049061.7129.18.camel@redhat.com> <1481050715.18162.604.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481051786.7129.22.camel@redhat.com> <1481052922.18162.605.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481081570.18162.626.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481093247.18162.637.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S34e_5KW3cdxS_yNXwhYuK2FQe=6+9=yTCVDsg6f2vx87g@mail.gmail.com>
 <1481220136.4930.110.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S35B3ja3pLHnKK4JQZrpKxtSc8nuZ_LBJT7E8qQJj2ronQ@mail.gmail.com> <1481227516.1898563.813013233.52CC6646@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Paolo Abeni <pabeni@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34652 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752035AbcLHUow (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 15:44:52 -0500
Received: by mail-qk0-f177.google.com with SMTP id q130so274139585qke.1
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 12:44:52 -0800 (PST)
In-Reply-To: <1481227516.1898563.813013233.52CC6646@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 12:05 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hello,
>
> On Thu, Dec 8, 2016, at 20:15, Tom Herbert wrote:
>> On Thu, Dec 8, 2016 at 10:02 AM, Eric Dumazet <eric.dumazet@gmail.com>
>> wrote:
>> > On Thu, 2016-12-08 at 09:49 -0800, Tom Herbert wrote:
>> >
>> >> Of course that would only help on systems where no one enable encaps,
>> >> ie. looks good in the the simple benchmarks but in real life if just
>> >> one socket enables encap everyone else takes the hit. Alternatively,
>> >> maybe we could do early demux when we do the lookup in GRO to
>> >> eliminate the extra lookup?
>> >
>> > Well, if you do the lookup in GRO, wont it be done for every incoming
>> > MSS, instead of once per GRO packet ?
>>
>> We should be able to avoid that. We already do the lookup for every
>> UDP packet going into GRO, would only need to take the refcnt once for
>> the whole GRO packet.
>>
>> >
>> > Anyway, the flooded UDP sockets out there are not normally connected
>>
>> We still should be able to use early demux in that case, just can't
>> avoid the route lookup. I wonder if we might be able to cache a soft
>> route maybe for the last local destination received to help the
>> unconnected sockets case...
>>
>> In any case, I can take a look at of doing early demux from with UDP GRO.
>
> Early demux already breaks ip rules: we might set up a rule so an
> incoming packet might depending on the rule not find an input route at
> all and would be forwarded. Same problem might occur with VRF, when you
> have multiple ip addresses in different "realms".
>
> That said, I don't see why we can't be more aggressive for GRO in the
> unconnected case: we simply must make sure that the current namespace
> holds the ip address, which is simply a hash lookup. After that we can
> even accept packets for a wildcard bounded socket.
>
Or just depend on encapsulation sockets to bind to an address. That
would eliminate most the ambiguity especially if it can be pushed into
a device that is trying to parse encapsulation. We would need new
interfaces to support that in HW, or use n-tuple filtering (which I
still maintain is the only right way to do it).

Tom

> Probably we should disable this logic as soon as soon as vrf and/or
> rules are active to have correct semantics.
>
> Bye,
> Hannes
