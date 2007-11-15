From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 9386] New: sis190 network driver crash
Date: Thu, 15 Nov 2007 15:00:41 -0800 (PST)
Message-ID: <20071115.150041.156510275.davem@davemloft.net>
References: <bug-9386-10286@http.bugzilla.kernel.org/>
	<20071115115841.30d43003.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	chris@linuxepos.com, romieu@fr.zoreil.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765545AbXKOXAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 18:00:41 -0500
In-Reply-To: <20071115115841.30d43003.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 15 Nov 2007 11:58:41 -0800

> On Thu, 15 Nov 2007 07:30:53 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=9386
 ...
> > I have a problem where I can lock up a number of machines by 
> > changing the link state on a sis190 Ethernet port. For example, during 
> > a data transfer such as FTP if I unplug the Ethernet cable and plug it 
> > back in, the Ethernet interface will stop responding and the machine 
> > will lock up after a minute or so. This behaviour is repeatable. I have the
> > sis190 driver loaded as a module.
> > 
> > I haven't found a kernel version where this doesn't happen. It happens with
> > kernel 2.6.20.15, for example.

I wonder if somehow sis190_phy_task() is creating some kind
of deadlock when handling the link down and up events.

It takes the RTNL semaphore in sis190_phy_task() but it doesn't
call anything which can see deadlocking on that.

It does invoke the link-watch layer, indirectly via the
various netif_carrier_{on,off}() calls it makes but those
should be OK since they just schedule workqueue things.

Perhaps what is contributing to the problem is that
sis190_interrupt() still processes the RX and TX queues
even when a link change event is signalled.  Perhaps
the chip doesn't like that.

Francois, I noticed two issues while reviewing the driver for
this bug:

1) The interrupt handler does no SMP locking, the chip might
   not be happy with one thread (in phy_task) programming
   the MDIO whilst another thread does RX/TX ring processing,
   for example.

2) The timeout limit check in __mdio_cmd() is buggy, it should
   be 99 instead of 999.
