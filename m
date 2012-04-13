From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net/ipv6/udp: Add encap_rcv support to
 IPv6 UDP
Date: Fri, 13 Apr 2012 13:24:46 -0400 (EDT)
Message-ID: <20120413.132446.79547904328484363.davem@davemloft.net>
References: <20120411022047.GA19124@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033Ab2DMRYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 13:24:52 -0400
In-Reply-To: <20120411022047.GA19124@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 10 Apr 2012 22:20:47 -0400

> At present, UDP encapsulated protocols (like L2TP) are only able to use the
> encap_rcv hook with UDP over IPv4.  This patch adds the same support for use
> with UDP over IPv6.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

This isn't right at all.

The return value of udpv6_queue_rcv_skb() ignorred at all
call sites except when it is invoked via ->backlog_rcv(), which
expects a different kind of return value, not an encap operation
indication.

So the whole "requeue as proto '-N'" logic isn't going to ever work.

You need to do what the ipv4 side does, split the routine into
two parts:

1) A __udpv6_queue_rcv_skb() which purely handles socket queueing
   cases.  It does not handle encap or anything like that.

   This is what is what you hook into ->backlog_rcv for ipv6 udp.

2) A udpv6_queue_rcv_skb() which is invoked by the UDPv6 socket demux
   on receive, and which will properly propagate the return values
   back down into ipv6 input to do the "requeue as proto '-N'" stuff.

Please resubmit both of these patches once you've fixed this up (and
tested it).
