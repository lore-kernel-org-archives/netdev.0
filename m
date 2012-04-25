From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 03:30:27 -0700
Message-ID: <CANP3RGf5oTd9mQsXqKj3uXgweMwjs9N3VSeXBHjDXQ7vG0NaSg@mail.gmail.com>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	<CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
	<1335298228.5205.168.camel@edumazet-glaptop>
	<CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
	<1335331960.5205.180.camel@edumazet-glaptop>
	<CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
	<f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
	<CANP3RGcGH6Su8Lvt34eTDF2iv2HSipo2DvybXGQA4pXZj_qb9Q@mail.gmail.com>
	<4c435f101fb7c653fd3b4e81980250e7@greed.fud.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:49384 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757866Ab2DYKa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 06:30:28 -0400
Received: by ghrr11 with SMTP id r11so988587ghr.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 03:30:28 -0700 (PDT)
In-Reply-To: <4c435f101fb7c653fd3b4e81980250e7@greed.fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The sensible default would be either 1280 (and keep allfrag feature), or
> the minimum IPv4 PMTU currently enforced by the kernel + 20 bytes (to
> compensate for the larger IPv6 header size). I don't know what the current
> minimum PMTU is.

I'd actually go with min IPv4 PMTU - 20, not + 20, see below for why.

Hmm, it may be best to honour PMTUs below 1280 to some small but not
too small value (512?), and below that give up, say mtu remains 1280
but still add the frag header.

> Also, I'm not really sure if the IPv4 minimum PMTU is defined as 576 or
> 68 bytes. There are some conflicting information out there, and nothing
> really
> authoritative either way (that I've found at least).

Yeah, I've seen conflicting information.
I wonder if there's some tiny embedded devices out there with
miniscule mtus, because of tiny amounts of ram.

> Yup, only difference is that an IPv6 tunnel is guaranteed to have a MTU of
> 1280, so no need for allfrag or dropping PMTU below 1280. No such guarantees
> exist for IPv4 links.

Hmm, I thought one way to implement an IPv6 over IPv4 tunnel was to basically
rely on IPv4 fragmentation, hence you would actually be using the same mechanism
as for an IPv6-IPv4 translator, then you would be tunneling the IPv6
packet over IPv4,
so your IPv6 mtu would be 20 less than the v4 one, not 20 more which
you get if you
replace the v6 header with a smaller v4 one.

Anyway, this certainly seems like an ipv6-in-ipv4 tunneling mechanism
which would currently work, wouldn't it?

(re: Eric's patch, I think it should protect itself against malicious
PMTU messages with too small MTUs, like 0 or 1 or 68 [not enough for
timestamped ipv6/tcp)
