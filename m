From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Fri, 20 Nov 2015 10:55:13 +0900
Message-ID: <CAKD1Yr356LxAATZQ4O8CO5wuek2nFbPGrtRMGzMyda819FZdRA@mail.gmail.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
 <20151119.005318.838757439536205791.davem@davemloft.net> <CAKD1Yr0Es9JqdDi_05Kif=TyCSA+n7yDHUNr-ND-SD4j4p=D9A@mail.gmail.com>
 <20151119.195504.2050784646947745419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:33556 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759180AbbKTBze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 20:55:34 -0500
Received: by ykdv3 with SMTP id v3so139359527ykd.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 17:55:34 -0800 (PST)
In-Reply-To: <20151119.195504.2050784646947745419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 9:55 AM, David Miller <davem@davemloft.net> wrote:
> Netfilter could perform signalling on skb->sk when it drops packets.
>
> Your example is actually a argument _for_ doing this in the kernel.
>
> :-)

Well, I did say that was a simple example. :-) How do I make the VPN
case work? In that case, the packets will go out just fine, they'll
just be sent through the VPN tunnel and get dropped by the VPN server.
Again, the issue there is:

1. TCP connection is established on wifi network.
2. VPN comes up, adds high-priority routing rule that ensures that no
unprivileged app traffic leaks to the wifi network directly, but
everything is sent on VPN.
3. Any packet sent on TCP connection in #1 is now sent on VPN network
with wifi source address.

We don't have a solution for this today; SIOCKILLADDR only takes an IP
address. Today, apps just get stuck. We could fix this with
SOCK_DESTROY.

Here's another thing that could be fixed with SOCK_DESTROY. Today,
when the device switches from cell data to wifi, it tears down cell
data after a 30-second seamless handover period. One major reason to
do this is that if it doesn't, some already-established, long-lived
TCP connection might continue to use expensive cell data because the
app did not close the connection and reconnect on wifi.

If we had SOCK_DESTROY, the system could instead do the following:

1. Device connects to wifi.
2. After 30-second seamless handover, sockets currently established on
cell get closed by SOCK_DESTROY (instead of being closed by tearing
down cell data and calling SIOCKILLADDR). As happens today, apps see
the error and reconnect, and policy steers them to wifi.
3. Unlike today, cell stays up, so that the next time the user needs
it (fast network switching? multipath? app that already has permission
to use cell data?), it's already there and the user doesn't need to
wait 500ms for it to come up again.
4. Unprivileged apps can't use expensive mobile data any more than
they could in previous releases.

As a more general point, I think part of the issue is that there are
lots of problems in the mobile space that might not be immediately
obvious to people on this list. In the past, this has led to us
(Android networking team) proposing non-trivial patches that provided
functionality that makes sense on a mobile device (e.g., UID-based
routing, SOCK_DESTROY), and those patches being rejected on the
grounds that the use cases didn't make sense or that the people
proposing them didn't understand networking. :-)

Better communication might help. I will try to publicly document how
we currently use the stack; hopefully that will provide more context
for discussions such as these, and allow future work to unwind some of
the out-of-tree hacks that we currently rely on and replace it with
upstream alternatives. We might even be able to show up at netdev 1.1
for some higher-bandwidth conversations.
