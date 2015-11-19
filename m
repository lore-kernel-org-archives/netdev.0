From: Tom Herbert <tom@herbertland.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 21:12:39 -0800
Message-ID: <CALx6S36-tBwAGFFpdrhXjAXvNmxUXsbRV17Wayjr6-hsKsCeNg@mail.gmail.com>
References: <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
	<20151118.153508.123902005995190872.davem@davemloft.net>
	<1447879416.562854.443622857.62708268@webmail.messagingengine.com>
	<20151118.224919.452852815199526735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Lorenzo Colitti <lorenzo@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38302 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbbKSFMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 00:12:40 -0500
Received: by igbxm8 with SMTP id xm8so55769052igb.1
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 21:12:40 -0800 (PST)
In-Reply-To: <20151118.224919.452852815199526735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015 at 7:49 PM, David Miller <davem@davemloft.net> wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 18 Nov 2015 21:43:36 +0100
>
>> Basically my concern is the same one I tried to express in the other
>> patch about Florian's patch "[PATCH -next] net: tcp: move to
>> timewait when receiving data post active-close": we could give the
>> socket back way too early so the quadruple can be reused. If
>> timestamps are not in use or we are dealing with NAT were we have
>> dozens of synchronized clocks behind the masquerading device, we
>> could end up in accepting delayed data. Especially this scenario can
>> come up when the address is actually not released but someone uses
>> this feature on a server.
>
> Ok, these are legitimate concerns.
>
> What if we implemented this the other way.  The operations that make
> the sockets no longer connected to the world, close them.  The route
> delete during address removal does the socket scan and then the done
> calls on those sockets.
>
> Likewise a VPN or network realm/namespace configuration change can do
> similarly.
>
> That way we are guaranteed to only tcp_done() these sockets strictly
> in situations where we know that they have been fully disconnected
> from the network.
>
> The more I think about it more the more I agree with him and dislike
> having user space make sure "it's ok", that isn't where TCP protocol
> semantic rules are implemented.  It belongs in the kernel.
>
> Whether we do this or not, that's the policy part and userland can
> therefore tell us what it wants when it removes addresses or whatever.
>
> But userland should not be doing the socket scan and triggering the
> closes, _no_ _way_.

I think this solution presumes some out of band signaling about a path
failure deep in the network that is not reported via the TCP
connection. This solution is obviously only as good as the signaling,
but clearly the most general solution to maintaining reachability has
been (and unfortunately will probably continue to be) application
keepalives.

btw, the commit log mentioned that the long timeout problem applies to
sockets doing reads or connects. For connects this should be
uninteresting since the connect can be configured for a quick timeout.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
