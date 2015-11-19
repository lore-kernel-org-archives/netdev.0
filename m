From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 14:13:48 +0900
Message-ID: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
References: <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
 <20151118.153508.123902005995190872.davem@davemloft.net> <1447879416.562854.443622857.62708268@webmail.messagingengine.com>
 <20151118.224919.452852815199526735.davem@davemloft.net>
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
Received: from mail-yk0-f174.google.com ([209.85.160.174]:32923 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbbKSFOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 00:14:09 -0500
Received: by ykdv3 with SMTP id v3so96171464ykd.0
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 21:14:08 -0800 (PST)
In-Reply-To: <20151118.224919.452852815199526735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 12:49 PM, David Miller <davem@davemloft.net> wrote:
> What if we implemented this the other way.  The operations that make
> the sockets no longer connected to the world, close them.  The route
> delete during address removal does the socket scan and then the done
> calls on those sockets.

In many cases it's not that simple. Routing can be as complex as the
RPDB allows it to be, and in general the kernel cannot know if a
socket is routable or not. As an example, a system might use
mark-based routing, like so:

100 from all fwmark aaaa/0xffff lookup wifi
200 from all fwmark bbbb/0xffff lookup cell
9999 from all lookup wifi

(This is the basic idea of what Android >= 5.0 does). Suppose that a
VPN connects and routing needs to be moved to the VPN. The system
might implement this by adding the following rule:

50 from all fwmark 0x0/0x10000 lookup vpn

Now all sockets where the fwmark matches aaaa/0x1ffff are dead in the
water. They have the wifi source address, but they are routed to the
VPN and go nowhere. The system can't remove the wifi rule or take wifi
down, because the VPN socket itself (which will have a mark of
0x1aaaa/0x1000) needs to continue to work on wifi. It can't route
those sockets over wifi, because the user expects that the VPN is
securing all network traffic.

In this situation, even if the kernel were to examine all sockets when
the rule is added, how would it know that sockets with a mark of 1aaaa
should now be closed? The IP address is still there. Routing lookups
on those sockets will succeed just fine - they just now point to the
VPN, which doesn't work.

> The more I think about it more the more I agree with him and dislike
> having user space make sure "it's ok", that isn't where TCP protocol
> semantic rules are implemented.  It belongs in the kernel.

Today any app can always, on one of its sockets, set SO_LINGER with a
timeout of 0 and call tcp_close. That results in immediately sending a
RST and forgetting about local state. (Those semantics are the ones of
RFC 793 ABORT.) If SOCK_DESTROY did that instead of just calling
tcp_done, would that be acceptable?
