From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH 11/11] usb: core: fix a race with usb_queue_reset_device()
Date: Tue, 20 Jan 2015 10:26:30 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1501201022360.1150-100000@iolanthe.rowland.org>
References: <1421756978-4093-12-git-send-email-olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421756978-4093-12-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Jan 2015, Olivier Sobrie wrote:

> When usb_queue_reset() is called it schedules a work in view of
> resetting the usb interface. When the reset work is running, it
> can be scheduled again (e.g. by the usb disconnect method of
> the driver).
> 
> Consider that the reset work is queued again while the reset work
> is running and that this work leads to a forced unbinding of the
> usb interface (e.g. because a driver is bound to the interface
> and has no pre/post_reset methods - see usb_reset_device()).
> In such condition, usb_unbind_interface() gets called and this
> function calls usb_cancel_queued_reset() which does nothing
> because the flag "reset_running" is set to 1. The second reset
> work that has been scheduled is therefore not cancelled.
> Later, the usb_reset_device() tries to rebind the interface.
> If it fails, then the usb interface context which contain the
> reset work struct is freed and it most likely crash when the
> second reset work tries to be run.

There was an earlier patch posted for testing (no results yet)  
affecting this same region of code:

	http://marc.info/?l=linux-usb&m=142064533924019&w=2

It should fix the problem described here, because (among other things) 
it adds usb_get/put_intf calls to the delayed-reset routines.

Alan Stern
