From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Thu, 21 Apr 2011 12:27:21 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1104211205090.1939-100000@iolanthe.rowland.org>
References: <BANLkTik7Da6K4Fn7=dpo8RwwctCp8kV_iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, <linux-usb@vger.kernel.org>,
	<davem@davemloft.net>, <greg@kroah.com>
To: Paul Stewart <pstew@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:39980 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754491Ab1DUQ1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 12:27:22 -0400
In-Reply-To: <BANLkTik7Da6K4Fn7=dpo8RwwctCp8kV_iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Apr 2011, Paul Stewart wrote:

> I'm trying to handle two separate issues, one of which I can't say I
> fully understand.  The first, which is the most straightforward, is
> for systems in which USB devices remained powered across
> suspend-resume.  For this case for sure, we don't need a flag.  The
> interrupt URBs are halted (either done so by the HCD as I've observed,
> or the drive can choose to kill them in usbnet_suspend()).  On system
> resume, we're guaranteed URBs have stopped, and we can just submit
> one.

Okay, good.

> In a second scenario, for other systems USB devices go unpowered
> during suspend.

As happens during hibernation, for example.

>  At resume time, there's a quick succession where the
> device appears to detach and reattach and enumerate.

Right.  It's called reset-resume, and drivers have a special method for 
it, distinct from regular resume.  In theory it shouldn't make any 
difference.

>  This is where
> things get strange.  It appears that since the enumeration happens in
> the course of system resume, when usbnet_open() gets called, and
> usb_autopm_get_interface(), there's a call path that leads to
> usbnet_resume().

Only if the interface was suspended when usbnet_open() was called.  It
might have gotten suspended automatically following the system resume,
if it wasn't in use.  But this should work out the same whether or not
there was a reset-rseume.

>  If there's no flag, then we submit the interrupt urb
> from usbnet_resume(), so the submit_urb() in usbnet_open() fails in an
> error.  This makes actions like "ifconfig eth0 up" fail on the
> interface after resume from suspend.

The driver needs better coordination between open/stop and
resume/suspend.  The interrupt and receive URBs are supposed to be
active whenever the interface is up and not suspended, right?  Which
means that usbnet_resume() shouldn't submit anything if the interface 
isn't up.

Alan Stern

