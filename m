From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Prevent UDP tunnels from operating on garbage
 socket
Date: Mon, 06 Apr 2015 12:41:14 -0400 (EDT)
Message-ID: <20150406.124114.924455461962119301.davem@davemloft.net>
References: <20150405.221847.2119086885797169021.davem@davemloft.net>
	<CALx6S348YyYxrT+3fcXEFz=w6BYFGZwcQ6iD1PjzVePotioJKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org, hannes@stressinduktion.org, jiri@resnulli.us
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbbDFQlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 12:41:19 -0400
In-Reply-To: <CALx6S348YyYxrT+3fcXEFz=w6BYFGZwcQ6iD1PjzVePotioJKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 6 Apr 2015 06:59:21 -0700

> On Sun, Apr 5, 2015 at 7:18 PM, David Miller <davem@davemloft.net> wrote:
>>
>> So this should do the rest of the work such that when we encapsulate
>> into a UDP tunnel, the output path works on the UDP tunnel's socket
>> rather than skb->sk.
>>
> Doesn't this contradict "udp: Do not require sock in
> udp_tunnel_xmit_skb" patch?  How is the skbuf getting set with a
> garbage socket?

It's not a garbage socket, but it could be a socket for a completely
different address family than ipv4/ipv6.  The canonical example is
AF_PACKET transmitting over an encapsulating device.

Tom if you are saying that skb->sk should be reset to the tunnel
socket, that doesn't work and is completely broken.

You must retain the original skb->sk of the application so that socket
memory accounting does not break.  You can't just rewrite skb->sk
during tunnel encapsulation.

That's the whole point these changes.

If an AF_PACKET socket transmits over a UDP encapsulating tunnel device
we want skb->sk to be the AF_PACKET socket for socket memory accounting
purposes, and pass down explicitly the UDP tunnel socket through the
output path starting at the point of UDP encapsulation.
