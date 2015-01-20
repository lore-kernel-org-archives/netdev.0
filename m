From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 11/11] usb: core: fix a race with
 usb_queue_reset_device()
Date: Tue, 20 Jan 2015 14:48:37 +0100
Message-ID: <1421761717.29486.24.camel@linux-0dmf.site>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
	 <1421756978-4093-2-git-send-email-olivier@sobrie.be>
	 <1421756978-4093-3-git-send-email-olivier@sobrie.be>
	 <1421756978-4093-4-git-send-email-olivier@sobrie.be>
	 <1421756978-4093-5-git-send-email-olivier@sobrie.be>
	 <1421756978-4093-6-git-send-email-olivier@sobrie.be>
	 <1421756978-4093-7-git-send-email-olivier@sobrie.be>
	 <1421756978-4093-8-git-send-email-olivier@sobrie.be>
	 <1421756978-4093-9-git-send-email-olivier@sobrie.be>
	 <1421756978-4093-10-git-send-email-olivier@sobrie.be>
	 <1421756978-4093-11-git-send-email-olivier@sobrie.be>
	 <1421756978-4093-12-git-send-email-olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421756978-4093-12-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-01-20 at 13:29 +0100, Olivier Sobrie wrote:
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
> 
> The following flow shows the problem:
> * usb_queue_reset_device()
> * __usb_queue_reset_device() <- If the reset work is queued after here, then
>     reset_running = 1           it will never be cancelled.
>     usb_reset_device()
>       usb_forced_unbind_intf()
>         usb_driver_release_interface()
>           usb_unbind_interface()
>             driver->disconnect()
>               usb_queue_reset_device() <- second reset

That is the sledgehammer approach. Wouldn't it be better to guarantee
that usb_queue_reset_device() be a nop when reset_running==1 ?

>             usb_cancel_queued_reset() <- does nothing because
>                                          the flag reset_running
>                                          is set
>       usb_unbind_and_rebind_marked_interfaces()
>         usb_rebind_intf()
>           device_attach()
>             driver->probe() <- fails (no more drivers hold a reference to
> 				      the usb interface)
>     reset_running = 0
> * hub_event()
>     usb_disconnect()
>       usb_disable_device()
>         kobject_release()
>           device_release()
>             usb_release_interface()
>               kfree(intf) <- usb interface context is released
>                              while we still have a pending reset
>                              work that should be run
> 
> To avoid this problem, we use a delayed work so that if the reset
> work is currently run, we can avoid further call to
> __usb_queue_reset_device() work by using cancel_delayed_work().
> Unfortunately it increases the size of the usb_interface structure...

	Regards
		Oliver

-- 
Oliver Neukum <oneukum@suse.de>
