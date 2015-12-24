From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Thu, 24 Dec 2015 10:14:13 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1512241007050.2785-100000@netrider.rowland.org>
References: <1450941280.28243.8.camel@suse.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hayes Wang <hayeswang@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"peter@lekensteyn.nl" <peter@lekensteyn.nl>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netrider.rowland.org ([192.131.102.5]:47321 "HELO
	netrider.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751748AbbLXPOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 10:14:14 -0500
In-Reply-To: <1450941280.28243.8.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Dec 2015, Oliver Neukum wrote:

> On Wed, 2015-12-23 at 20:32 -0500, Alan Stern wrote:
> 
> > I don't understand why the wakeup conditions are different.  It seems
> > to me that the choice of which packets will generate a wakeup ought to
> > depend on the user's selection, not on the kind of suspend.  For
> > instance, if the user says that only a magic packet should cause a
> > wakeup then that should be true for both runtime suspend and system
> > suspend.
> > 
> > To put it another way, as far as the device is concerned a suspend is
> > just a suspend -- there's no different between a runtime suspend and a
> > system suspend.
> 
> This literally true, but the host and the driver care.
> If we autosuspend a running network device, any packet
> (maybe filtered for MAC) should cause a remote wake up,
> else we'd lose packets.

That's also true during system suspend.

> But you cannot keep that setting if the system goes down
> or any broadcast packet would resume the whole system.
> Yet you cannot just disable remote wake up, as WoL packages
> still must trigger a remote wake up.

This means that sometimes you want to avoid losing packets and other 
times you do want to lose packets.  That is a policy decision, and 
therefore it should be made by the user, not the kernel.

> So there are drivers which must change settings on devices
> as the system goes to sleep, even if their devices have
> already been autosuspended. We could use the notifier chains
> for that. But can this solution be called elegant?

Instead of the driver trying to do this automatically, you could rely 
on userspace telling the driver which packets should cause a wakeup.  
The setting could be updated immediately before and after each system 
suspend.

I admit this is more awkward than having the driver make a choice based 
on the type of suspend.  This is a case where the resources provided by 
the PM core aren't adequate for what the driver needs.  The PM core 
distinguishes between wakeup enabled or disabled; it doesn't 
distinguish among different levels of wakekup.

Alan Stern
