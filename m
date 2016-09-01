From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/4] xps_flows: XPS flow steering when there is
 no socket
Date: Thu, 1 Sep 2016 09:14:36 -0700
Message-ID: <CALx6S36U0uQCyQh6rCADRqmbBbrM8Wn7aSLvLb02pGS++_YGsQ@mail.gmail.com>
References: <1472688605-2613704-1-git-send-email-tom@herbertland.com> <1472690278.14381.393.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Rick Jones <rick.jones2@hpe.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34672 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932307AbcIAQOi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 12:14:38 -0400
Received: by mail-qk0-f182.google.com with SMTP id t7so90266231qkh.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 09:14:37 -0700 (PDT)
In-Reply-To: <1472690278.14381.393.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2016 at 5:37 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-08-31 at 17:10 -0700, Tom Herbert wrote:
>
>> Tested:
>>   Manually forced all packets to go through the xps_flows path.
>>   Observed that some flows were deferred to change queues because
>>   packets were in flight witht the flow bucket.
>
> I did not realize you were ready to submit this new infra !
>
Sorry, I was assuming there would be some more revisions :-).

> Please add performance tests and documentation.
> ( Documentation/networking/scaling.txt should be a nice place )
>
Waiting to see if this mitigates Rick;s problem.

> Unconnected UDP packets are candidates to this selection,
> even locally generated, while maybe the applications are pinning their
> thread(s) to cpu(s)
> TX completion will then happen on multiple cpus.
>
They are are now, but I am not certain that is the way to go. Not all
unconnected UDP has in order delivery requirements, I suspect most
don't so this might be configuration. I do wonder about something like
QUIC though, do you know if they are using unconnected sockets and
depend in in order delivery?

> Not sure about af_packet and/or pktgen ?
>
> - The new hash table is vmalloc()ed on a single NUMA node. (in
> comparison RFS table (per rx queue) can be properly accessed by a single
> cpu servicing queue interrupts)
>
Yeah, that's kind of unpleasant. Since we're starting from the
application side this is more like rps_sock_flow_table but we are
writing it in every packet. Other than sizing the table to prevent
collisions between flows, I don't readily see a way to get the same
sort of isolation we have in RPS. Any ideas?
.
> - Each packet will likely get an additional cache miss in a DDOS
> forwarding workload.

We don't need xps_flows in forwarding. It looks like the only
situations we need it is when the host is sourcing a flow but there is
no connected socket available. I'll make the mechanism opt-in in next
rev.

Thanks,
Tom

>
> Thanks.
>
>
