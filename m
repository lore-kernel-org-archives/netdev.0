From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 0/2] kproxy: Kernel Proxy
Date: Thu, 29 Jun 2017 13:40:26 -0700
Message-ID: <CALx6S369XPs_6Ap9H8yZCW+XL1pAbJx9XhNdpZ36hpQCEvs-3w@mail.gmail.com>
References: <1498760825-8516-1-git-send-email-tom@herbertland.com> <20170629195402.GA10048@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35545 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751532AbdF2Uk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 16:40:28 -0400
Received: by mail-wr0-f193.google.com with SMTP id z45so37797810wrb.2
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 13:40:27 -0700 (PDT)
In-Reply-To: <20170629195402.GA10048@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willy,

Thanks for the comments!

> In fact that's not much what I observe in field. In practice, large
> data streams are cheaply relayed using splice(), I could achieve
> 60 Gbps of HTTP forwarding via HAProxy on a 4-core xeon 2 years ago.
> And when you use SSL, the cost of the copy to/from kernel is small
> compared to all the crypto operations surrounding this.
>
Right, getting rid of the extra crypto operations and so called "SSL
inspection" is the ultimate goal this is going towards.

> Another point is that most HTTP requests are quite small (typically ~80%
> 20kB or less), and in this case the L7 processing and certain syscalls
> significantly dominate the operations, data copies are comparatively
> small. Simply parsing a HTTP header takes time (when you do it correctly).
> You can hardly parse and index more than 800MB-1GB/s of HTTP headers
> per core, which limits you to roughly 1-1.2 M req+resp per second for
> a 400 byte request and a 400 byte response, and that's without any
> processing at all. But when doing this, certain syscalls like connect(),
> close() or epollctl() start to be quite expensive. Even splice() is
> expensive to forward small data chunks because you need two calls, and
> recv+send is faster. In fact our TCP stack has been so much optimized
> for realistic workloads over the years that it becomes hard to gain
> more by cheating on it :-)
>
> In the end in haproxy I'm seeing about 300k req+resp per second in
> HTTP keep-alive and more like 100-130k with close, when disabling
> TCP quick-ack during accept() and connect() to save one ACK on each
> side (just doing this generally brings performance gains between 7
> and 10%).
>
HTTP is only one use case. The are other interesting use cases such as
those in container security where the application protocol might be
something like simple RPC. Performance is relevant because we
potentially want security applied to every message in every
communication in a containerized data center. Putting the userspace
hop in the datapath of every packet is know to be problematic, not
just for the performance hit  also because it increases the attack
surface on users' privacy.

> Regarding kernel-side protocol parsing, there's an unfortunate trend
> at moving more and more protocols to userland due to these protocols
> evolving very quickly. At least you'll want to find a way to provide
> these parsers from userspace, which will inevitably come with its set
> of problems or limitations :-/
>
That's why everything is going BPF now ;-)

> All this to say that while I can definitely imagine the benefits of
> having in-kernel sockets for in-kernel L7 processing or filtering,
> I'm having strong doubts about the benefits that userland may receive
> by using this (or maybe you already have any performance numbers
> supporting this ?).
>
Nope, no numbers yet.

> Just my two cents,
> Willy
