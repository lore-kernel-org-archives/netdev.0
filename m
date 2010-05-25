From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv4: Allow configuring subnets as local addresses
Date: Mon, 24 May 2010 20:29:55 -0700
Message-ID: <20100524202955.63ea2358@nehalam>
References: <alpine.DEB.1.00.1005232249380.18495@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43526 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757254Ab0EYD36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 May 2010 23:29:58 -0400
In-Reply-To: <alpine.DEB.1.00.1005232249380.18495@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 May 2010 22:54:12 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

> This patch allows a host to be configured to respond to any address in
> a specified range as if it were local, without actually needing to
> configure the address on an interface.  This is done through routing
> table configuration.  For instance, to configure a host to respond
> to any address in 10.1/16 received on eth0 as a local address we can do:
> 
> ip rule add from all iif eth0 lookup 200
> ip route add local 10.1/16 dev lo proto kernel scope host src 127.0.0.1 table 200
> 
> This host is now reachable by any 10.1/16 address (route lookup on
> input for packets received on eth0 can find the route).  On output, the
> rule will not be matched so that this host can still send packets to
> 10.1/16 (not sent on loopback).  Presumably, external routing can be
> configured to make sense out of this.
> 
> To make this work, we needed to modify the logic in finding the
> interface which is assigned a given source address for output
> (dev_ip_find).  We perform a normal fib_lookup instead of just a
> lookup on the local table, and in the lookup we ignore the input
> interface for matching.
> 
> This patch is useful to implement IP-anycast for subnets of virtual
> addresses.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

It makes sense, no sure what else will break because of this.
This won't work so well with routing daemons like Quagga(BGP, Zebra)
etc because they believe loopback is special but they don't
handle multiple routing tables well anyway.
