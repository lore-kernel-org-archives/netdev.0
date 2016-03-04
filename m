From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: Possible double-free in the usbnet driver
Date: Fri, 4 Mar 2016 13:26:48 -0800
Message-ID: <CA+55aFxqwjs5gs6Fw2jmTteWM4hZTnr7Ls111ExNTieObLs82Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[ Moving this to proper lists ]

On Thu, Mar 3, 2016 at 4:19 PM, Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> I found another double-free, this time in the usbnet driver.

Hmm. It doesn't look like a double free to me, at least from the logs
you attached.

> Whenever the `bind()` function fails (drivers/net/usb/usbnet.c:1676) when
> called from `usbnet_probe()` (and it can fail due to a invalid usb descriptor),
> `free_netdev()` is called for the `net` device (drivers/net/usb/usbnet.c:1772).
> Then, `free_netdev(net)` is called again in `usbnet_disconnect()`
> (drivers/net/usb/usbnet.c:1570) causing a double-free.

The KASAN report says that it's a use-after-free in the kworker
thread: the net device got free'd at the end of usbnet_probe(), but
some work-struct was apparently active at the time.

There might be a double free later that isn't in your report, though.
Do you have the data for that?

But I didn't think we even called the disconnect() function if the
"bind()" failed, so I don't think that one should free it. Greg?

So it *sounds* to me like the usbnet "bind()" routine ended up
returning an error, but doing so *after* it had already activated the
structure somehow.

Which particular usbnet bind routine is this? There are multiple
sub-drivers for usbnet that all do different things.

For example, it *looks* like the cdc_ncm_bind() will have done a
usbnet_link_change() even if the bind fails. So now we've done a
usbnet_defer_kevent() even though we're failing, and then that sets
the ball rolling to later touch the netdev that we're freeing due to
the failure.

But I may be *entirely* misreading this thing.

Anyway, I'm cc'ing the usbnet people who actually know the code (and netdev).

The proper fix may be to just cancel any work that might have been set
up before freeing. Or maybe that netdev *does* get free'd later some
other way properly. Let's see what the experts on the usbnet driver
say.

                  Linus
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
