From: David Miller <davem@davemloft.net>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Tue, 15 Dec 2009 20:50:55 -0800 (PST)
Message-ID: <20091215.205055.193693273.davem@davemloft.net>
References: <4B2690B4.3030604@gmail.com>
	<20091214.143522.102450157.davem@davemloft.net>
	<20091214.231840.106434922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.dykstra1@gmail.com, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gilad@codefidence.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46234
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752272AbZLPEuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 23:50:55 -0500
In-Reply-To: <20091214.231840.106434922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 14 Dec 2009 23:18:40 -0800 (PST)

> From: David Miller <davem@davemloft.net>
> Date: Mon, 14 Dec 2009 14:35:22 -0800 (PST)
> 
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 14 Dec 2009 20:23:32 +0100
>> 
>>> If you disable syncookies, I presume you dont have warnings ?
>> 
>> It happens even with syncookies disabled, hmmm...
> 
> FWIW, I'm starting to bisect this.

Ok, it's the patch series that adds all of the per-route
SACK/DSACK/TIMESTAMP controls.

I hand reverted the entire series and the badness triggers no longer
occur.  I couldn't bisect through the individual changes because of
all of the bug fixes that happened at the end of them.

I'm pretty sure the problem eminates from changing the 'estab'
parameter passed into tcp_parse_options() from
tcp_timewait_state_process() and tcp_check_req().

But even if we fix that, this patch series is very fundamentally
broken.  It takes the 'dst' for the listening socket when creating new
incoming connections in tcp_check_req() to probe the per-route settings.

Listening sockets don't have a route.  So this can't ever work
properly.

And getting the route for the child request we're making (the right
one) can't be done until we setup all of the state and call down into
the code which emits the SYN+ACK packet and look the route up by hand.

I'm simply going to revert this entire series.  Sorry this didn't work
out, but we're not adding this feautre this time around.  Maybe you
can write a working version for the next merge widnow.
