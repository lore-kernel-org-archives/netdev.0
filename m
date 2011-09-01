From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: IP_TRANSPARENT requires CAP_NET_ADMIN - why?
Date: Thu, 1 Sep 2011 14:25:58 -0700
Message-ID: <CAHo-OozTNa8gtCuhSZm+aBqK-J0-eGMyr5rJBfTV6SmPZNhQVw@mail.gmail.com>
References: <CAHo-Ooz-0wt4-3oXZBeEmLTSom5qUxhXhP4MDUrSz322OTGa9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Balazs Scheidler <bazsi@balabit.hu>,
	Patrick McHardy <kaber@trash.net>,
	KOVACS Krisztian <hidden@balabit.hu>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Linux NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:49643 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758017Ab1IAVZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 17:25:59 -0400
Received: by yie30 with SMTP id 30so1744235yie.19
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2011 14:25:59 -0700 (PDT)
In-Reply-To: <CAHo-Ooz-0wt4-3oXZBeEmLTSom5qUxhXhP4MDUrSz322OTGa9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm curious why transparent sockets [setsockopt(IP{,V6}_TRANSPARENT),
> ie. inet_sk(sk)->transparent bit] require CAP_NET_ADMIN privileges.
>
> Wouldn't CAP_NET_RAW be more appropriate?
>
> Looks to me like CAP_NET_RAW is all about raw sockets.
> Transparent sockets are dangerous because they effectively allow spoofing.
> But this seems to be the same sort of thing that CAP_NET_RAW protects
> against.
>
> Is there something I'm missing?
> Is there any reason why having CAP_NET_RAW privs shouldn't allow one
> to set the transparent bit on a socket?
>
> Would people be opposed to relaxing the check on setting sk->transparent
> to be either CAP_NET_ADMIN or CAP_NET_RAW?

Why am I even interested?  I have a couple of apps (dns servers, web
servers, load balancers, web crawlers) that
don't require any special permissions except the ability to use any ip
as the source ip for a listening tcp, outgoing tcp, and/or udp socket.
For example machines may receive arbitrary traffic over a tunnel (with
absolutely any ip as the destination ip within the tunneled payload)
and need to respond to it, hence they need to be able to respond with
any ip as the source ip.  This can be achieved with combinations of
routing tricks and/or ip non local bind and/or ip_transparent.

The way I see it there are a couple possibilities.

a) Leave as is: IP{,V6}_TRANSPARENT requires CAP_NET_ADMIN

   This seems like the least desirable solution, we end up requiring a
much more powerful privilege then necessary.

b) Backward compatible: Make it require one of CAP_NET_ADMIN or CAP_NET_RAW

   Better, but kind of ugly in there being two permissions that allow this.

c) Not-backward compatible: Make it require CAP_NET_RAW instead of CAP_NET_ADMIN

   Better, in that a less powerful privilege is required, but *does*
break non-root software which uses CAP_NET_ADMIN to get TRANSPARENT
sockets.
   Also the gain isn't that great, in that we are still using a
privilege which is a little too powerful.

d) Add a new capability: Make it require CAP_NET_ADMIN or CAP_NET_TRANSPARENT

  Again backward compatible - ugly.

e) Add a new capability: Make it require CAP_NET_ADMIN or CAP_NET_RAW
or CAP_NET_TRANSPARENT

  Again backward compatible - ugly.  The reason for allowing
CAP_NET_RAW is that it effectively already allows this to be done with
raw sockets in a less useful way.  ie. AFAICT CAP_NET_TRANSPARENT is a
subset of CAP_NET_RAW

f) Add a new capability: Make it require CAP_NET_TRANSPARENT instead
of CAP_NET_ADMIN

  Not backward compatible, introduces a new capability, however, long
term this is probably the cleanest.

My personal vote is for (f).  I figure the number of non-root-apps
that have CAP_NET_ADMIN in order to get IP{,V6}_TRANSPARENT support is
very low, and they should be easy to fix to request
CAP_NET_TRANSPARENT instead.

Any opinions?

Maciej
