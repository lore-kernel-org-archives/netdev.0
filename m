From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] udp: UDP Fast Port
Date: Mon, 28 Jul 2014 16:20:22 +0200
Message-ID: <1406557222.12728.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1407261519050.27164@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50108 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbaG1OVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 10:21:24 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so7417116wgh.27
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 07:21:23 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1407261519050.27164@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-07-26 at 15:29 -0700, Tom Herbert wrote:
> This patch implements fast ports in UDP. The idea is that a kernel
> module registers a port and associated receive function. In UDP receive,
> the list of fast ports is scanned and the destinaton port is matched
> against the registered port. If there is a match, then the receive
> function is called to process the packet. When a UDP fast port is used,
> we can receive encap'ed packets without performing or accessing a
> socket. This is a performance gain, especially since we don't need to
> take socket ref count on every packet.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/net/udp.h | 23 +++++++++++++++++++
>  net/ipv4/udp.c    | 69 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
>  net/ipv6/udp.c    | 21 +++++++++++++++--
>  3 files changed, 108 insertions(+), 5 deletions(-)

I find this very hacky. I do not think we should have different sorts of
UDP sockets.

If we believe we need a fast UDP path, without socket refcount being
touched, we should remove the SLAB_DESTROY_BY_RCU and switch to rcu
socket freeing (call_rcu())

At the time we added RCU lookups to UDP, we hadn't vxlan, and fear was
that the extra RCU grace period at socket dismantle was too heavy cost,
like TCP sockets.

Meanwhile, RCU cleanups got lot of attention, and UDP sockets serve as
tunnels vehicle.
