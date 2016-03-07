From: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: Possible double-free in the usbnet driver
Date: Mon, 7 Mar 2016 10:08:39 +0100
Message-ID: <CACT4Y+bdsGHWb97N+5Q2NfMpimYyhmw3=czOUHZzG-20v2NqdA@mail.gmail.com>
References: <CA+55aFxqwjs5gs6Fw2jmTteWM4hZTnr7Ls111ExNTieObLs82Q@mail.gmail.com>
 <CA+fCnZfS51F7WZEM1YTSPDMWSzvBTJWGf5cRWv5LrNCSOf_-qA@mail.gmail.com> <CA+55aFwxbs_hLG58Q_xSK2vpufjmwMk-xkqxTNh_5h-A8y4vbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+55aFwxbs_hLG58Q_xSK2vpufjmwMk-xkqxTNh_5h-A8y4vbg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 4, 2016 at 11:43 PM, Linus Torvalds
<torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> On Fri, Mar 4, 2016 at 2:26 PM, Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>
>> and when I run the vm and connect the device I get:
>>
>> [   23.672662] cdc_ncm 1-1:1.6: bind() failure
>> [   23.673447] usbnet_probe(): freeing netdev: ffff88006ab48000
>> [   23.675822] usbnet_probe(): freeing netdev: ffff88006ab48000
>>
>> So this seems to be a double-free (or at least a double free_netdev()
>> call), but the object gets freed twice from usbnet_probe() and not
>> from usbnet_disconnect(), so you're right that the latter doesn't get
>> called. I'm not sure how usbnet_probe() ends up being called twice.
>
> I still don't think it's a double free. I think the probe thing is
> called twice, and that's why to different allocations get free'd twice
> (and the reason it's the same pointer is that the same allocation got
> reused)


FYI, we have a KASAN patch in flight that adds "quarantine" for freed
memory (memory is reused only after a significant delay). It should
help to easily differentiate between use-after-free, double-free and
heap-out-of-bound. Yes, now it is confusing.


> But I don't know that driver, really.
>
>>> Which particular usbnet bind routine is this? There are multiple
>>> sub-drivers for usbnet that all do different things.
>>
>> cdc_ncm_bind()
>
> Ok, so that matches my theory.
>
> Does this attached stupid patch make the warning go away? Because from
> what I can tell, usbnet_link_change() really will start using that
> "dev" that simply isn't valid - and will be free'd - if the bind
> fails.
>
> So you have usbnet_defer_kevent() getting triggered, which in turn
> ends up using "usbnet->kevent"
>
> But somebody like Oliver is really the right person to check this. For
> example, it's entirely possible that we should just instead do
>
>         cancel_work_sync(&dev->kevent);
>
> before the "free_netdev(net)" in the "out1" label.
>
> And there might be other things that bind() can have touched than the
> kevent workqueue.
>
>                Linus
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
