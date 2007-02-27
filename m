From: David Miller <davem@davemloft.net>
Subject: Re: Fix "ipOutNoRoutes" counter error for TCP and UDP
Date: Mon, 26 Feb 2007 17:08:32 -0800 (PST)
Message-ID: <20070226.170832.71092126.davem@davemloft.net>
References: <1171465429.7069.18.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weid@np.css.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43254
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161035AbXB0BId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 20:08:33 -0500
In-Reply-To: <1171465429.7069.18.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: weidong <weid@np.css.fujitsu.com>
Date: Wed, 14 Feb 2007 10:03:49 -0500

> Hi, All
>   When I tested Linux-2.6.20 and found that counter "ipOutNoRoutes" can
> not increase correctly.
>   The criteria is RFC2011
> 
> ipOutNoRoutes OBJECT-TYPE
>     SYNTAX      Counter32
>     MAX-ACCESS  read-only
>     STATUS      current
>     DESCRIPTION
>             "The number of IP datagrams discarded because no route could
>             be found to transmit them to their destination.  Note that
>             this counter includes any packets counted in ipForwDatagrams
>             which meet this `no-route' criterion.  Note that this
>             includes any datagrams which a host cannot route because all
>             of its default routers are down."
>     ::= { ip 12 }
> 
> In current Linux TCP/IP stack, maybe we should not increase this counter
> in "input path", but only increase it in "output path" due to the TCP/IP
> stack performance.
> 
> Now in "output path", when TCP client tries to connect to an unreachable
> server(net unreachable, so no route can be found), this counter has no
> increment. When we use UDP sending UDP datagram to an net unreachable
> address, this counter also has no increment.
> 
> Function need to fix:
> tcp_v4_connect(); ip4_datagram_connect(); udp_sendmsg();
> 
> The following patch can fix the problems mentioned above

Thank you for this patch.

I think we need to make these checks more carefully.

Route lookup can fail for several reasons other than
no route being available.  Two examples are:

1) Out of memory error while creating route
2) IPSEC disallows communication to that flow ID

As a result, we'll probably best limiting the counter
increment when the error is either -EHOSTUNREACH or
-ENETUNREACH.

Probably, since this logic will be duplicated to several
locations, you'll want to implement the test inside of
a helper inline function.
