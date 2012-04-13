From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pppoatm: Fix excessive queue bloat
Date: Fri, 13 Apr 2012 13:05:57 -0400 (EDT)
Message-ID: <20120413.130557.2049216012537456628.davem@davemloft.net>
References: <1332878138.3547.41.camel@edumazet-glaptop>
	<1332880522.2058.67.camel@shinybook.infradead.org>
	<1333914837.31812.57.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, chas@cmf.nrl.navy.mil,
	eric.dumazet@gmail.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848Ab2DMRJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 13:09:03 -0400
In-Reply-To: <1333914837.31812.57.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 08 Apr 2012 21:53:57 +0200

> We discovered that PPPoATM has an excessively deep transmit queue. A
> queue the size of the default socket send buffer (wmem_default) is
> maintained between the PPP generic core and the ATM device.
> 
> Fix it to queue a maximum of *two* packets. The one the ATM device is
> currently working on, and one more for the ATM driver to process
> immediately in its TX done interrupt handler. The PPP core is designed
> to feed packets to the channel with minimal latency, so that really
> ought to be enough to keep the ATM device busy.
> 
> While we're at it, fix the fact that we were triggering the wakeup
> tasklet on *every* pppoatm_pop() call. The comment saying "this is
> inefficient, but doing it right is too hard" turns out to be overly
> pessimistic... I think :)
> 
> On machines like the Traverse Geos, with a slow Geode CPU and two
> high-speed ADSL2+ interfaces, there were reports of extremely high CPU
> usage which could partly be attributed to the extra wakeups.
> 
> (The wakeup handling could actually be made a whole lot easier if we
>  stop checking sk->sk_sndbuf altogether. Given that we now only queue
>  *two* packets ever, one wonders what the point is. As it is, you could
>  already deadlock the thing by setting the sk_sndbuf to a value lower
>  than the MTU of the device, and it'd just block for ever.)
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied to net-next, thanks David.

I always considered the use of socket buffers to handle packets
moving around the ATM layers as a fundamental design error.

Although it's major surgery, fixing that up would be a much
appreciated contribution for someone suitably motivated :-)
