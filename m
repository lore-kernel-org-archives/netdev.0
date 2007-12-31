From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [usb regression] Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Mon, 31 Dec 2007 12:49:52 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.0712311237150.7182-100000@iolanthe.rowland.org>
References: <20071231052500.GB4187@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andreas Mohr <andi@lisas.de>, Ingo Molnar <mingo@elte.hu>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Denis V. Lunev" <den@openvz.org>,
	USB list <linux-usb@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:34663 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750935AbXLaRtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 12:49:53 -0500
In-Reply-To: <20071231052500.GB4187@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Dec 2007, Greg KH wrote:

> > It looks like Greg misused the debugfs API -- which is ironic, because
> > he wrote debugfs in the first place!  :-)
> 
> Oh crap, sorry, I did mess that up :(
> 
> > Let me know if this patch fixes the problem.  If it does, I'll submit 
> > it to Greg with all the proper accoutrements.
> 
> This isn't going to work if CONFIG_DEBUGFS is not enabled either :(

Why not?  The debugging files won't be created, true, but the driver
should work just fine regardless.  This is exactly the way uhci-hcd
behaves, and it hasn't caused any problems.

> > Index: 2.6.24-rc6-mm1/drivers/usb/host/ohci-hcd.c
> > ===================================================================
> > --- 2.6.24-rc6-mm1.orig/drivers/usb/host/ohci-hcd.c
> > +++ 2.6.24-rc6-mm1/drivers/usb/host/ohci-hcd.c
> > @@ -1067,14 +1067,8 @@ static int __init ohci_hcd_mod_init(void
> >  
> >  #ifdef DEBUG
> >  	ohci_debug_root = debugfs_create_dir("ohci", NULL);
> > -	if (!ohci_debug_root || IS_ERR(ohci_debug_root)) {
> > -		if (!ohci_debug_root)
> > -			retval = -ENOENT;
> > -		else
> > -			retval = PTR_ERR(ohci_debug_root);
> > -
> > -		goto error_debug;
> > -	}
> > +	if (!ohci_debug_root)
> > +		return -ENOENT;
> 
> It needs to check for ERR_PTR(-ENODEV) which is the return value if
> debugfs is not enabled, and if so, just ignore things.

No.  That is the mistake you made before.  If debugfs isn't enabled 
then the driver should just ignore things, yes -- and in particular it 
should ignore the fact that the return code is ERR_PTR(-ENODEV).  No 
extra checking is required.

> If NULL is returned, or anything else, it's a real error.

If NULL is returned, it's a real error, agreed.  But if anything else
is returned then the call was successful as far as the driver is 
concerned.

> So, try something like:
> 	if (!ohci_debug_root) {
> 		retval = -ENOENT;
> 		goto error_debug;
> 	}
> 	if (IS_ERR(ohci_debug_root) && PTR_ERR(ohci_debug_root) != -ENODEV) {
> 		retval = PTR_ERR(ohci_debug_root);
> 		goto error_debug;
> 	}
> 
> and let me know of that works for you.

Greg, it sounds like you have forgotten the rationale you originally 
used for specifying the return codes in debugfs!  The idea was to 
return non-NULL if CONFIG_DEBUGFS was disabled, so that drivers could 
pretend the calls had succeeded and not need to worry about matters 
beyond their control.

Only a NULL return indicates a genuine error.  The kerneldoc for 
debugfs_create_dir says this very plainly.

> Although the combination of CONFIG_USB_DEBUG and not CONFIG_DEBUGFS is
> strange, we could just enable CONFIG_DEBUGFS is USB_DEBUG is enabled and
> then simplify this logic a bunch at the same time.

Most distributions enable CONFIG_DEBUGFS by default, don't they?  So 
this problem only comes up when people make up their own configs.  
Having USB_DEBUG enabled and DEBUGFS disabled seems like a perfectly 
reasonable combination to me.  I wouldn't change any aspect of the 
configuration logic.

Alan Stern

