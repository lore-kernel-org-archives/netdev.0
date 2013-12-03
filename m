From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: Spurious timeouts in mvmdio
Date: Tue, 3 Dec 2013 07:23:46 -0500
Message-ID: <20131203122346.GD29282@titan.lakedaemon.net>
References: <529CA42A.3040504@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Leigh Brown <leigh@solinno.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-03-ewr.mailhop.org ([204.13.248.66]:62458 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752258Ab3LCMX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 07:23:56 -0500
Content-Disposition: inline
In-Reply-To: <529CA42A.3040504@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas,

Sorry for the delay, we spoke about this yesterday on irc, and
apparently we all thought the other person was going to respond.  oops
:(

On Mon, Dec 02, 2013 at 04:15:54PM +0100, Nicolas Schichan wrote:
> During 3.13-rc1 testing, I have found out that the mvmdio driver
> would report timeouts on the kernel console:
> 
> [   11.011334] orion-mdio orion-mdio: Timeout: SMI busy for too long
> 
> The hardware is a MV88F6281 Kirkwood CPU. The mvmdio driver is using
> the irq line 46 (ge00_err).
> 
> I am inclined to believe that it is due to the fact that
> wait_event_timeout() is called with a timeout parameter of 1 jiffy
> in orion_mdio_wait_ready(). If the timer interrupt ticks right after
> calling wait_event_timeout(), we may end up spending much less time
> than MVMDIO_SMI_TIMEOUT (1 msec) in wait_event_timeout(), and as a
> result report a timeout as the MDIO access did not complete in such
> a short time.
> 
> As to how to fix this, I see two options (I don't know which one
> would be prefered):
> 
> - Option 1: always pass a timeout of at least 2 jiffy to wait_event_timeout().
> - Option 2: switch to wait_event_hrtimeout().
> 
> I can provide patches for both options.

Based on yesterday's irc chat, option 1 sounds good.  Here's the dump
from yesterday where Sebastian provided a thorough explanation:

11:29 < shesselba> increasing max timeout to 2 ticks at least sounds reasonable
11:29 < shesselba> 10ms should be enough for every CONFIG_HZ there is

11:30 < kos_tom> why make the timeout tied to the ticks? there are functions/macros to convert real time numbers into ticks.
11:30 < kos_tom> msecs_to_jiffies() or something

11:31 < shesselba> kos_tom: it is already using usecs_to_jiffies()
11:31 < shesselba> the thing is: 1ms is less than a jiffy

11:33 < kos_tom> so it will wait one jiffy or a little bit more, no?

11:38 < shesselba> no, the spurious timeouts he is seeing come from (1) mvmdio gets jiffies close before the next tick, (2) wait_event_timeout is called with jiffies + timeout
11:39 < shesselba> with timeout << 1 jiffy
11:39 < shesselba> then (3) the next timer tick occurs
11:39 < shesselba> it will end up waiting less then a jiffy
11:40 < shesselba> IOW, increase timeout to be at least two jiffies (or 20ms for CONFIG_HZ=100)
11:41 < shesselba> originally, it was 100ms anyway

Looking forward to the patch!

thx,

Jason.
