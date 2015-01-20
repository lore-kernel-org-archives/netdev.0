From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH 11/11] usb: core: fix a race with usb_queue_reset_device()
Date: Tue, 20 Jan 2015 16:10:01 +0100
Message-ID: <20150120151001.GA5681@hposo>
References: <1421756978-4093-4-git-send-email-olivier@sobrie.be>
 <1421756978-4093-5-git-send-email-olivier@sobrie.be>
 <1421756978-4093-6-git-send-email-olivier@sobrie.be>
 <1421756978-4093-7-git-send-email-olivier@sobrie.be>
 <1421756978-4093-8-git-send-email-olivier@sobrie.be>
 <1421756978-4093-9-git-send-email-olivier@sobrie.be>
 <1421756978-4093-10-git-send-email-olivier@sobrie.be>
 <1421756978-4093-11-git-send-email-olivier@sobrie.be>
 <1421756978-4093-12-git-send-email-olivier@sobrie.be>
 <1421761717.29486.24.camel@linux-0dmf.site>
Reply-To: Olivier Sobrie <olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1421761717.29486.24.camel@linux-0dmf.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Oliver,

On Tue, Jan 20, 2015 at 02:48:37PM +0100, Oliver Neukum wrote:
> On Tue, 2015-01-20 at 13:29 +0100, Olivier Sobrie wrote:
> > When usb_queue_reset() is called it schedules a work in view of
> > resetting the usb interface. When the reset work is running, it
> > can be scheduled again (e.g. by the usb disconnect method of
> > the driver).
> > 
> > Consider that the reset work is queued again while the reset work
> > is running and that this work leads to a forced unbinding of the
> > usb interface (e.g. because a driver is bound to the interface
> > and has no pre/post_reset methods - see usb_reset_device()).
> > In such condition, usb_unbind_interface() gets called and this
> > function calls usb_cancel_queued_reset() which does nothing
> > because the flag "reset_running" is set to 1. The second reset
> > work that has been scheduled is therefore not cancelled.
> > Later, the usb_reset_device() tries to rebind the interface.
> > If it fails, then the usb interface context which contain the
> > reset work struct is freed and it most likely crash when the
> > second reset work tries to be run.
> > 
> > The following flow shows the problem:
> > * usb_queue_reset_device()
> > * __usb_queue_reset_device() <- If the reset work is queued after here, then
> >     reset_running = 1           it will never be cancelled.
> >     usb_reset_device()
> >       usb_forced_unbind_intf()
> >         usb_driver_release_interface()
> >           usb_unbind_interface()
> >             driver->disconnect()
> >               usb_queue_reset_device() <- second reset
> 
> That is the sledgehammer approach. Wouldn't it be better to guarantee
> that usb_queue_reset_device() be a nop when reset_running==1 ?

If I'm right, we have to prevent that usb_queue_reset_device() shedules
the work a second time before the variable reset_running is set.
An other task can requeue a reset while the work __usb_queue_reset_device()
is busy but when the flag reset_running hasn't been set yet.

I see different other approaches to solve the problem:

 * Setting a flag in the usb_queue_reset_device() when a reset has been
   scheduled and resetting this flag when the reset is done. This implies
   a locking mechanism around the flag.

 * Avoid that the hso driver queues multiple resets by using a flag. It
   also requires locking. It comes more or less to the same solution
   as the previous one but the patch is done in the hso driver.

 * using get_device() and put_device() to avoid that the usb interface
   structure get freed before the second reset is run.
   I mean:
	void usb_queue_reset_device(struct usb_interface *iface)
	{
		get_device()
		if (!schedule_work(&iface->reset_ws))
			put_device()
	}

	static void __usb_queue_reset_device(struct work_struct *ws)
	{
		...
		put_device()
	}

   But this solution does not avoid the second reset...

If you have other better ideas, let me know.
Correct me if I'm wrong.

Thank you,

Olivier

> 
> >             usb_cancel_queued_reset() <- does nothing because
> >                                          the flag reset_running
> >                                          is set
> >       usb_unbind_and_rebind_marked_interfaces()
> >         usb_rebind_intf()
> >           device_attach()
> >             driver->probe() <- fails (no more drivers hold a reference to
> > 				      the usb interface)
> >     reset_running = 0
> > * hub_event()
> >     usb_disconnect()
> >       usb_disable_device()
> >         kobject_release()
> >           device_release()
> >             usb_release_interface()
> >               kfree(intf) <- usb interface context is released
> >                              while we still have a pending reset
> >                              work that should be run
> > 
> > To avoid this problem, we use a delayed work so that if the reset
> > work is currently run, we can avoid further call to
> > __usb_queue_reset_device() work by using cancel_delayed_work().
> > Unfortunately it increases the size of the usb_interface structure...
> 
> 	Regards
> 		Oliver
> 
> -- 
> Oliver Neukum <oneukum@suse.de>
> 

-- 
Olivier
