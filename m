From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Generic PHY lib vs. locking
Date: Sat, 23 Dec 2006 07:53:10 +1100
Message-ID: <1166820790.6673.111.camel@localhost.localdomain>
References: <1166760473.6673.85.camel@localhost.localdomain>
	 <1166801090.30347.1.camel@dhollis-lnx.sunera.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57345 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752686AbWLVUxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Dec 2006 15:53:18 -0500
To: David Hollis <dhollis@davehollis.com>
In-Reply-To: <1166801090.30347.1.camel@dhollis-lnx.sunera.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-12-22 at 10:24 -0500, David Hollis wrote:
> On Fri, 2006-12-22 at 15:07 +1100, Benjamin Herrenschmidt wrote:
> > Hi Andy !
> > 
> > I've been looking at porting various drivers (EMAC, sungem,
> > spider_net, ...) to the generic PHY stuff. However, I have one
> > significant problem here.
> > 
> 
> > One solution would be to change it to use a mutex instead of a lock as
> > well, though that would change the requirements of where phy_start/stop
> > can be called, and use a delayed work queue instead of a timer.
> 
> Wouldn't this change also allow it to be used with USB Ethernet devices?
> I was looking at porting the asix.c drive to use the PHY layer but the
> locking killed that effort since USB devices can't do spinlocks without
> hosing things up.

Yes, possibly. At the end of the day, I get the locking in the driver
down to something like:

 - All rx/tx operatations are done between the NAPI poll and the
hard_start_xmit() routine. Locking here is done with the netif_tx_lock
if needed (depends on the driver). Those can't sleep.

 - Everything else is task level and locks against the fast path above
with stopping NAPI poll and stopping tx. I have my
driver_netif_stop/start routines doing that and a bit more (see below).

 - There is at least one issue with set_multicast which is called with
the lock held. What I do here is that my driver_netif_stop above also
take the lock, set a flag tellign set-mcast to say away, release the
lock. start() on the other hand take the lock, clears that flag, checks
if another flag was set by set-mcast telling it was here, and does the
mcast setting if that was the case.

I much prefer that than having most of the driver operations locked with
the tx lock or some other or run at softirq. Some of the reset/recovery
operations can be slow, PHY operations too, and thus it's all better run
at task level. In addition, MDIO access might be able to sleep waiting
on an interrupt signaling the completion of the access.

Ben.
 

