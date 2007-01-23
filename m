From: Pavel Roskin <proski@gnu.org>
Subject: Re: Can someone please try...
Date: Tue, 23 Jan 2007 01:14:40 -0500
Message-ID: <1169532880.8258.2.camel@dv>
References: <200701161806.02780.mb@bu3sch.de>
	 <200701222106.24329.mb@bu3sch.de> <1169498676.4453.14.camel@dv>
	 <200701222200.19784.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:53722 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933040AbXAWGOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 01:14:46 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1H9Eur-0005dm-Gs
	for netdev@vger.kernel.org; Tue, 23 Jan 2007 01:13:57 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701222200.19784.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-01-22 at 22:00 +0100, Michael Buesch wrote: 
> > No more random crashes.  There is still a crash if I rmmod the driver
> > while wlan0 is up, but it's a separate issue, and it's easy to avoid
> > (unlike the interface going down).  I hope to look at it soon.
> 
> Did you apply that d80211 rmmod crash fix that Michael Wu posted
> recently. I bet it will fix your issue.

I have tried the patch, and it doesn't fix the problem.  It's a separate
problem.  It happens when bcm43xx_interrupt_handler() is called on a
device that has already been removed.  It looks like
bcm43xx_wireless_core_stop() should be called from
bcm43xx_one_core_detach().

Unfortunately, I cannot come to a satisfactory solution yet.  If I call
bcm43xx_wireless_core_stop() with the mutex held, the driver won't
unload if the interface is down.  If I don't hold the mutex, it would
happen when the interface is up.

By the way, I think it's a bad idea to unlock any mutexes or other locks
set outside the function.  The caller assumes that the lock is held
until it (the caller) unlocks it.  Unlocking locks from other functions
breaks this convention. 

> > I think the assert() should be replaced with a FIXME, which would not
> > annoy end users so much.
> 
> Well, no. It's kind of: Michael, go ahead and fix that crap!
> So I'd like to keep it to get me to fix it. :D

I, for one, prefer to keep my to-do items in my to-do list, but I don't
want to distract you with petty arguments from fixing the real problem.

> > And while at that, it would be great to 
> > replace phy->lo_gain with four fields with descriptive names.
> > phy->lo_gain is never used as an array.  Alternatively, you could make
> > it a structure within bcm43xx_phy.
> 
> Yeah, one step after the other. ;)
> We didn't know the meanings of the values until recently. Of course
> I am going to rename them.

Great!

> > The problems with a MadWifi based AP turn out to be related to 802.11g.
> > If the AP is configured for 802.11b only, everything is working.  If
> > 802.11g is enabled, strange things are happening.  Judging by what's on
> > the air, it looks like the driver loses the data frames is receives.
> > wpa_supplicant connects instantly, but ARP and ping packets from AP to
> > STA are lost.  The frames are even acknowledged, but not seen on the
> > station side.  It takes from one to ten minutes util ping suddenly
> > starts working.
> 
> Hm, is this 4318? It is known to loose lots of packets.

No, it's 4312.

-- 
Regards,
Pavel Roskin


