From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 2.6.38 dev_watchdog WARNING
Date: Tue, 19 Apr 2011 19:49:19 +0100
Message-ID: <1303238959.2988.30.camel@bwh-desktop>
References: <4DADC8F2.9050700@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: tim.gardner@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42248 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab1DSStV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 14:49:21 -0400
In-Reply-To: <4DADC8F2.9050700@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-19 at 11:40 -0600, Tim Gardner wrote:
> I'm seeing a lot of these kinds of bugs: WARNING: at 
> /build/buildd/linux-2.6.38/net/sched/sch_generic.c:256 
> dev_watchdog+0x213/0x220()
> 
> The kernel is 2.6.38.2 plus Ubuntu cruft.
> 
> A spot check of the 200+ hits on this string indicates they are 
> primarily due to these drivers:
> 
> ipheth
> atl1c
> sis900
> r8169
> 
> As far as I can tell the warning happens when link is down on the media 
> (and has never been link UP) and are sent a transmit packet which never 
> completes. Is there a net/core or net/sched requirement to which these 
> drivers do not conform ? Are they not correctly indicating link status?

The watchdog fires when the software queue has been stopped *and* the
link has been reported as up for over dev->watchdog_timeo ticks.

The software queue should be stopped iff the hardware queue is full or
nearly full.  If the software queue remains stopped and the link is
still reported up, then one of these things is happening:

1. The link went down but the driver didn't notice
2. TX completions are not being indicated or handled correctly
3. The hardware TX path has locked up
4. The link is stalled by excessive pause frames or collisions
5. Timeout is too low and/or low watermark is too high
(there may be other explanations)

I think the watchdog is primarily meant to deal with case 3, though all
of cases 1-3 may be worked around by resetting the hardware.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

