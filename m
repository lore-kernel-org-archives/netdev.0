From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] r8152: Allocate interrupt buffer as part of struct r8152
Date: Tue, 31 Jan 2017 13:15:19 -0800
Message-ID: <20170131211519.GA21758@roeck-us.net>
References: <1485889577-4389-1-git-send-email-linux@roeck-us.net>
 <Pine.LNX.4.44L0.1701311448250.2048-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.1701311448250.2048-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 31, 2017 at 02:53:47PM -0500, Alan Stern wrote:
> On Tue, 31 Jan 2017, Guenter Roeck wrote:
> 
> > When unloading the r8152 driver using the 'unbind' sysfs attribute
> > in a system with KASAN enabled, the following error message is seen
> > on a regular basis.
> 
> ...
> 
> > The two-byte allocation in conjunction with code analysis suggests that
> > the interrupt buffer has been overwritten. Added instrumentation in the
> > driver shows that the interrupt handler is called after RTL8152_UNPLUG
> > was set, and that this event is associated with the error message above.
> > This suggests that there are situations where the interrupt buffer is used
> > after it has been freed.
> > 
> > To avoid the problem, allocate the interrupt buffer as part of struct
> > r8152.
> > 
> > Cc: Hayes Wang <hayeswang@realtek.com>
> > Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> > ---
> > The problem is seen in chromeos-4.4, but there is not reason to believe
> > that it does not occur with the upstream kernel. It is still seen in
> > chromeos-4.4 after all patches from upstream and linux-next have been
> > applied to the driver.
> > 
> > While relatively simple, I am not really convinced that this is the best
> > (or even an acceptable) solution for this problem. I am open to suggestions
> > for a better fix.
> 
> The proper approach is to keep the allocation as it is, but _before_
> deallocating the buffer, make sure that the interrupt buffer won't be
> accessed any more.  This may involve calling usb_kill_urb(), or

usb_kill_urb() is called. I added some more logging. The sequence is
	interrupt_handler()
	...
	usb_kill_urb(intr_urb);
	...
	kfree(intr_buff);
	...
	BUG kmalloc-128

which leaves me a bit puzzled; the interrupt handler is called well before
the memory is freed, and it turns out that it is not always called.

I'll do some digging in the usb core.

Guenter
