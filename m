From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/5] udp: Flow dissection for tunnels
Date: Thu, 13 Oct 2016 12:29:46 -0700
Message-ID: <CALx6S35hEQzc=pCb6ko23HNFdK96-nb=F8Ni2+c=inSpJC16og@mail.gmail.com>
References: <20161012232547.2383961-1-tom@herbertland.com> <20161013.151700.1071876162706356206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:35141 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754902AbcJMT6h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 15:58:37 -0400
Received: by mail-qk0-f179.google.com with SMTP id z190so112048470qkc.2
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 12:58:37 -0700 (PDT)
In-Reply-To: <20161013.151700.1071876162706356206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 13, 2016 at 12:17 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Wed, 12 Oct 2016 16:25:42 -0700
>
>> Since performing a UDP lookup on every packet might be expensive I
>> added a static key check to bypass the lookup if there are no
>> sockets with flow_dissect set. I should mention that doing the
>> lookup wasn't particularly a big hit anyway.
>
> I think this new static key is unnecessary, as it is equivalent
> to: (udp_encap_needed + udpv6_encap_needed)
>
Good point.

> This socket lookup is very heavy handed, and I realize that you
> need this because we no longer store the encapsulation socket in
> skb->sk these days.
>
I don't quite understand your point about the encapsulation socket.
The reason we do the socket lookup is the same as why we do it this
way in GRO already, identifying UDP encapsulation by just port is
insufficient and may lead to incorrect results. Once we removed the
atomic operation from the UDP socket lookup (thanks Eric!) it becomes
feasible to do the lookup in critical paths and so the special per
port offloads lookup was removed. In my testing I didn't see a
noticeable hit in performing the lookup, but it still seems prudent to
use the static key since UDP tunnels are a relatively narrow use case.

> Can you talk about the various code paths that lead into the
> flow dissector and why the UDP socket lookup is needed?  Maybe
> we can propagate it another way, at least on TX.
>
The code path I'm interested in simple RX, particularly in the case
where UDP is being used as static tunnel for many flows in IPv4
(assuming in IPv6 we have flow label to provide entropy). For getting
the flow hash on TX we are already using sk->tx_hash if it's
available.

Tom

> Thanks.
