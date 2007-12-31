From: Greg KH <greg@kroah.com>
Subject: Re: [usb regression] Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Sun, 30 Dec 2007 21:25:00 -0800
Message-ID: <20071231052500.GB4187@kroah.com>
References: <20071230161405.GA27788@elte.hu> <Pine.LNX.4.44L0.0712301526090.1963-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
	"Denis V. Lunev" <den@openvz.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:60168 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868AbXLaFYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 00:24:04 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.0712301526090.1963-100000@netrider.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 30, 2007 at 03:34:45PM -0500, Alan Stern wrote:
> On Sun, 30 Dec 2007, Ingo Molnar wrote:
> 
> > * Andreas Mohr <andi@lisas.de> wrote:
> > 
> > > (yes, that's all there is, despite CONFIG_USB_DEBUG being set)
> > > 
> > > The LED of a usb stick isn't active either, for obvious reasons.
> > > 
> > > And keep in mind that this is a (relatively old) OHCI-only machine... 
> > > (which had the 2.6.19 lsmod showing ohci-hcd just fine and working 
> > > fine with WLAN USB)
> > > 
> > > Now pondering whether to try -rc6 proper or whether to revert specific 
> > > guilty-looking USB changes... And wondering how to properly elevate 
> > > this issue (prompt Greg about it, new thread, bug #, ...?)
> 
> It looks like Greg misused the debugfs API -- which is ironic, because
> he wrote debugfs in the first place!  :-)

Oh crap, sorry, I did mess that up :(

> Let me know if this patch fixes the problem.  If it does, I'll submit 
> it to Greg with all the proper accoutrements.

This isn't going to work if CONFIG_DEBUGFS is not enabled either :(

> Index: 2.6.24-rc6-mm1/drivers/usb/host/ohci-hcd.c
> ===================================================================
> --- 2.6.24-rc6-mm1.orig/drivers/usb/host/ohci-hcd.c
> +++ 2.6.24-rc6-mm1/drivers/usb/host/ohci-hcd.c
> @@ -1067,14 +1067,8 @@ static int __init ohci_hcd_mod_init(void
>  
>  #ifdef DEBUG
>  	ohci_debug_root = debugfs_create_dir("ohci", NULL);
> -	if (!ohci_debug_root || IS_ERR(ohci_debug_root)) {
> -		if (!ohci_debug_root)
> -			retval = -ENOENT;
> -		else
> -			retval = PTR_ERR(ohci_debug_root);
> -
> -		goto error_debug;
> -	}
> +	if (!ohci_debug_root)
> +		return -ENOENT;

It needs to check for ERR_PTR(-ENODEV) which is the return value if
debugfs is not enabled, and if so, just ignore things.

If NULL is returned, or anything else, it's a real error.

So, try something like:
	if (!ohci_debug_root) {
		retval = -ENOENT;
		goto error_debug;
	}
	if (IS_ERR(ohci_debug_root) && PTR_ERR(ohci_debug_root) != -ENODEV) {
		retval = PTR_ERR(ohci_debug_root);
		goto error_debug;
	}

and let me know of that works for you.

Although the combination of CONFIG_USB_DEBUG and not CONFIG_DEBUGFS is
strange, we could just enable CONFIG_DEBUGFS is USB_DEBUG is enabled and
then simplify this logic a bunch at the same time.

thanks,

greg k-h
