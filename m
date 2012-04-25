From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 00:34:26 -0700
Message-ID: <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	<CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
	<1335298228.5205.168.camel@edumazet-glaptop>
	<CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
	<1335331960.5205.180.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tore Anderson <tore@fud.no>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:58106 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142Ab2DYHe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 03:34:26 -0400
Received: by iadi9 with SMTP id i9so2128952iad.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 00:34:26 -0700 (PDT)
In-Reply-To: <1335331960.5205.180.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But we chose to _not_ decrease mtu and adhere to the specs.

I get that we _choose_ to behave such, and I agree this adheres to specs.

But I'm not convinced that (even though this is allowed per RFC) this
is the right choice.

> Current linux chose to implement the allfragfeature, so match RFC 2460
> specs.
>
> If you want to reduce size of subsequent packets, its a lot more work in
> linux stack, for small gain, if any.

True, but this is work at the source host (and indeed might possibly
even be done by tso hardware or at least by gso),
which is reducing work at whatever the actual tunneling point is.
It's not actually affecting how much
work the receiver has to do (indeed it might even decrease it, imagine
sending 3840 bytes, getting that
fragmented into 6 packets: 1000, 280, 1000, 280, 1000, 280 instead of
just 4 packets: 1000, 1000,
1000, 840 [obviously would need to correct for header overhead, but
the basis stands])

[side note: indeed 1280 should never be split 1000 + 280, but should
rather be split into even pieces 640 + 640, to help prevent need for
further fragmentation further down the line]

Tunneling points are traditionally cpu starved.

Also note that IPv6 prefers to see fragmentation happen at the end
hosts, and not at the routers.
Although of course it doesn't treat a tunnel end point as a router.

Also packet loss is better handled by tcp losing segments than by the
tunnel losing a fragment and thus losing the entire packet.

I guess I simply think we're making the wrong trade off here.

> We only need to properly generate the fragment header, that means
> reducing the _payload_ by 8 bytes. Not reducing the _mtu_ that still is
> 1280, as allowed.
>
> IPv6 must cohabit with IPv4 for the next years, there is no hope
> thinking it can ignore tunnelings issues, since tunneling is part of the
> global IPv6 transition that is currently happening.

To be fair this probably isn't super-related to the vast majority of
IPv4, the vast majority of the IPv4 world out there has mtu's easily
in excess of 1280+tunneling overhead bytes.
I wonder if anyone has any statistics, but I'd guess 99.99% of the
IPv4 internet is 1400+ MTU.
