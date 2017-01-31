From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH] r8152: Allocate interrupt buffer as part of struct r8152
Date: Tue, 31 Jan 2017 14:53:47 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1701311448250.2048-100000@iolanthe.rowland.org>
References: <1485889577-4389-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1485889577-4389-1-git-send-email-linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Jan 2017, Guenter Roeck wrote:

> When unloading the r8152 driver using the 'unbind' sysfs attribute
> in a system with KASAN enabled, the following error message is seen
> on a regular basis.

...

> The two-byte allocation in conjunction with code analysis suggests that
> the interrupt buffer has been overwritten. Added instrumentation in the
> driver shows that the interrupt handler is called after RTL8152_UNPLUG
> was set, and that this event is associated with the error message above.
> This suggests that there are situations where the interrupt buffer is used
> after it has been freed.
> 
> To avoid the problem, allocate the interrupt buffer as part of struct
> r8152.
> 
> Cc: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
> Signed-off-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
> ---
> The problem is seen in chromeos-4.4, but there is not reason to believe
> that it does not occur with the upstream kernel. It is still seen in
> chromeos-4.4 after all patches from upstream and linux-next have been
> applied to the driver.
> 
> While relatively simple, I am not really convinced that this is the best
> (or even an acceptable) solution for this problem. I am open to suggestions
> for a better fix.

The proper approach is to keep the allocation as it is, but _before_
deallocating the buffer, make sure that the interrupt buffer won't be
accessed any more.  This may involve calling usb_kill_urb(), or
synchronize_irq(), or something similar.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
