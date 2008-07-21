From: David Miller <davem@davemloft.net>
Subject: Re: [crash] kernel BUG at net/core/dev.c:1328!
Date: Mon, 21 Jul 2008 13:11:29 -0700 (PDT)
Message-ID: <20080721.131129.244101157.davem@davemloft.net>
References: <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org>
	<20080721.120052.123606398.davem@davemloft.net>
	<4884E174.5030802@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, mingo@elte.hu,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stefanr@s5r6.in-berlin.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35724
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751542AbYGUUL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:11:29 -0400
In-Reply-To: <4884E174.5030802@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Date: Mon, 21 Jul 2008 21:20:20 +0200

> In the meantime:  Is there perhaps something obviously wrong with 
> drivers/ieee1394/eth1394.c's netdevice initialization?  We do it in 
> ether1394_add_host(), and shortly thereafter the crashing 
> ether1394_host_reset() is called.  So we have essentially
> 
> (add host)
> 	dev = alloc_netdev(...);
> 	initialize various members in dev...
> 	register_netdev(dev);
> 
> (host reset)
> 	netif_stop_queue(dev);
> 	discard some stale 1394 stuff if there were some...
> 	netif_wake_queue(dev);  <-- crashes in __netif_schedule(dev);

You should only do a netif_stop_queue() in your device
initialization, at the very end of ->open() processing
when you've fully committed to returning success.

You should not, in particular, be doing a netif_wake_queue()
before you've even done a netif_start_queue().

Many of these drivers are using netif_{stop,wake}_queue()
to stop packet flow, in particular when link state changes,
and netif_carrier_{on,off}() already does all of that for
you.

Really, anything outside of:

1) netif_start_queue() in ->open()
2) netif_stop_queue() in ->stop()
3) netif_{stop,wake}_queue() in the TX packet handling path

is superfluous.
