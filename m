From: David Miller <davem@davemloft.net>
Subject: Re: BUG: NIU driver: strange issues with multicast "UDP: short
 packet"
Date: Tue, 03 Feb 2009 15:38:53 -0800 (PST)
Message-ID: <20090203.153853.163818774.davem@davemloft.net>
References: <1233668300.20497.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43827
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751589AbZBCXi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 18:38:56 -0500
In-Reply-To: <1233668300.20497.49.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Tue, 03 Feb 2009 14:38:20 +0100

>   UDP: short packet: From 81.161.2.106:0 44063/1324 to 233.123.173.7:0
>   UDP: short packet: From 81.161.2.106:0 44063/1324 to 233.123.173.7:0
>   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
>   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
>   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
>   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931

The UDP header length field is garbage in all of these packets.

In the first two packets here, the source and dest ports are
both zero.  This is also garbage.,

> Tcpdumping the packets, the contents of the packets are correct.

So something corrupts the packet on the way to UDP input.

> The next strange thing is that I can make the log messages go away, if I
> setup a static multicast route out another interface.
> 
>   smcroute -a eth52 81.161.2.106 233.123.173.7 eth21

That could be a good clue.

Do you happen to have multicast routing enabled on this machine?  If
the multicast destination is non-local and IN_DEV_FORWARD is set on
the interface, that puts the packet through ip_mr_input.

ip_mr_input() will clone the SKB if it should be delivered locally
as well as be forwarded.

If the packet does get multicast forwarded, there is all kinds of
funny code that mangles the packet, for example ipmr_cache_report().

Any of this could be corrupting what UDP ends up seeing.

To be honest all of the SKB handling in the ipmr.c file is very scary.
