From: David Miller <davem@davemloft.net>
Subject: Re: [patch] Fix SNMPv2 "ipOutNoRoutes" counter error
Date: Sun, 10 Dec 2006 22:48:48 -0800 (PST)
Message-ID: <20061210.224848.55508191.davem@davemloft.net>
References: <1165337386.2545.4.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47898
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762589AbWLKGst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 01:48:49 -0500
To: weid@nanjing-fnst.com
In-Reply-To: <1165337386.2545.4.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: weidong <weid@nanjing-fnst.com>
Date: Tue, 05 Dec 2006 11:49:46 -0500

> Hi All:
>     When I tested linux kernel 2.6.18.3, and find that kernel statistics
> about IPSTATS_MIB_OUTNOROUTES which exsits in file /proc/net/snmp
> doesn't increase correctly.  The criteria conform to RFC2011:
> 
>   ipOutNoRoutes OBJECT-TYPE
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
> When a host received an IP packet, but the destination address is not
> this host. The kernel just discards the IP packet but with no increment
> for this counter.
> 
> When a router received an IP packet that this router can't forward due
> to no route found. Kernel just simply invoke ip_error(), and send ICMP
> packet. Also do nothing for this counter.
> 
> Signed-off-by: Wei Dong <weid@nanjing-fnst.com>

Hosts which have forwarding disabled, are not forwarding and
therefore not routing in the sense being described here.

So bumping this counter when the ip_forward sysctl is "0" makes
no sense.

We are not even getting to the "output" path when the route lookup
fails in ip_rcv_finish().  This means this silly SNMP "output" route
failed counter will get bumped like crazy when promiscuous mode is
enabled on an interface, and that makes zero sense.

This patch, at least in it's current form, is not correct.
