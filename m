From: David Miller <davem@davemloft.net>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 22:49:19 -0500 (EST)
Message-ID: <20151118.224919.452852815199526735.davem@davemloft.net>
References: <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
	<20151118.153508.123902005995190872.davem@davemloft.net>
	<1447879416.562854.443622857.62708268@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo@google.com, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755404AbbKSDtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 22:49:21 -0500
In-Reply-To: <1447879416.562854.443622857.62708268@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 18 Nov 2015 21:43:36 +0100

> Basically my concern is the same one I tried to express in the other
> patch about Florian's patch "[PATCH -next] net: tcp: move to
> timewait when receiving data post active-close": we could give the
> socket back way too early so the quadruple can be reused. If
> timestamps are not in use or we are dealing with NAT were we have
> dozens of synchronized clocks behind the masquerading device, we
> could end up in accepting delayed data. Especially this scenario can
> come up when the address is actually not released but someone uses
> this feature on a server.

Ok, these are legitimate concerns.

What if we implemented this the other way.  The operations that make
the sockets no longer connected to the world, close them.  The route
delete during address removal does the socket scan and then the done
calls on those sockets.

Likewise a VPN or network realm/namespace configuration change can do
similarly.

That way we are guaranteed to only tcp_done() these sockets strictly
in situations where we know that they have been fully disconnected
from the network.

The more I think about it more the more I agree with him and dislike
having user space make sure "it's ok", that isn't where TCP protocol
semantic rules are implemented.  It belongs in the kernel.

Whether we do this or not, that's the policy part and userland can
therefore tell us what it wants when it removes addresses or whatever.

But userland should not be doing the socket scan and triggering the
closes, _no_ _way_.
