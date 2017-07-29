From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v3 net-next 1/4] tcp: ULP infrastructure
Date: Sat, 29 Jul 2017 13:19:05 -0700
Message-ID: <CALx6S37pcti4jb6ysb=qO622go6FD_bDmb59v6QOSk+9z4zUkA@mail.gmail.com>
References: <cover.1497465295.git.davejwatson@fb.com> <20170614183714.GA80310@davejwatson-mba.dhcp.thefacebook.com>
 <20170617001455.GB82626@Chimay.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dave Watson <davejwatson@fb.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Nikos Mavrogiannopoulos <nmav@gnutls.org>,
        =?UTF-8?B?RnJpZG9sw61uIFBva29ybsO9?= <fridolin.pokorny@gmail.com>
To: Christoph Paasch <christoph.paasch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36468 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752031AbdG2UTH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 16:19:07 -0400
Received: by mail-wm0-f68.google.com with SMTP id d40so2189190wma.3
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 13:19:06 -0700 (PDT)
In-Reply-To: <20170617001455.GB82626@Chimay.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 16, 2017 at 5:14 PM, Christoph Paasch
<christoph.paasch@gmail.com> wrote:
> Hello,
>
> On 14/06/17 - 11:37:14, Dave Watson wrote:
>> Add the infrustructure for attaching Upper Layer Protocols (ULPs) over TCP
>> sockets. Based on a similar infrastructure in tcp_cong.  The idea is that any
>> ULP can add its own logic by changing the TCP proto_ops structure to its own
>> methods.
>>
>> Example usage:
>>
>> setsockopt(sock, SOL_TCP, TCP_ULP, "tls", sizeof("tls"));
>>
>> modules will call:
>> tcp_register_ulp(&tcp_tls_ulp_ops);
>>
>> to register/unregister their ulp, with an init function and name.
>>
>> A list of registered ulps will be returned by tcp_get_available_ulp, which is
>> hooked up to /proc.  Example:
>>
>> $ cat /proc/sys/net/ipv4/tcp_available_ulp
>> tls
>>
>> There is currently no functionality to remove or chain ULPs, but
>> it should be possible to add these in the future if needed.
>>
>> Signed-off-by: Boris Pismenny <borisp@mellanox.com>
>> Signed-off-by: Dave Watson <davejwatson@fb.com>
>> ---
>>  include/net/inet_connection_sock.h |   4 ++
>>  include/net/tcp.h                  |  25 +++++++
>>  include/uapi/linux/tcp.h           |   1 +
>>  net/ipv4/Makefile                  |   2 +-
>>  net/ipv4/sysctl_net_ipv4.c         |  25 +++++++
>>  net/ipv4/tcp.c                     |  28 ++++++++
>>  net/ipv4/tcp_ipv4.c                |   2 +
>>  net/ipv4/tcp_ulp.c                 | 134 +++++++++++++++++++++++++++++++++++++
>>  8 files changed, 220 insertions(+), 1 deletion(-)
>>  create mode 100644 net/ipv4/tcp_ulp.c
>
> I know I'm pretty late to the game (and maybe this has already been
> discussed but I couldn't find anything in the archives), but I am wondering
> what the take is on potential races of the setsockopt() vs other system-calls.
>
> For example one might race the setsockopt() with a sendmsg() and the sendmsg
> might end up blocking on the lock_sock in tcp_sendmsg, waiting for
> tcp_set_ulp() to finish changing sk_prot. When the setsockopt() finishes, we
> are then inside tcp_sendmsg() coming directly from sendmsg(), while we
> should have been in the ULP's sendmsg.
>
> It seems like TLS-ULP is resilient to this (or at least, won't cause a panic),
> but there might be more exotic users of ULP in the future, that change other
> callbacks and then things might go wrong.

Christoph,

I noticed this also. I think the easiest answer would be to just
assume the caller understands the race condition and can synchronize
itself. Other than that we'd probably have wake up everyone blocking
on the socket without something like EAGAIN so they're forced to retry
the operation. But even that might not easily yield an obvious point
at which the socket can be safely changed.

Tom

>
>
> Thoughts?
>
>
> Thanks,
> Christoph
>
