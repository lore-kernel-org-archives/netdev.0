From: Andrey Konovalov <andreyknvl@gmail.com>
Subject: Re: Possible double-free in the usbnet driver
Date: Sat, 5 Mar 2016 02:00:02 +0300
Message-ID: <CA+fCnZdfYxAR_ccD1ZL7qA4YwrwTKdBLztfrn9JmQyztBJBsMA@mail.gmail.com>
References: <CA+55aFxqwjs5gs6Fw2jmTteWM4hZTnr7Ls111ExNTieObLs82Q@mail.gmail.com>
	<CA+fCnZfS51F7WZEM1YTSPDMWSzvBTJWGf5cRWv5LrNCSOf_-qA@mail.gmail.com>
	<CA+55aFwxbs_hLG58Q_xSK2vpufjmwMk-xkqxTNh_5h-A8y4vbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Oliver Neukum <oneukum@suse.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Alexander Potapenko <glider@google.com>,
	USB list <linux-usb@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:36540 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759087AbcCDXAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 18:00:03 -0500
In-Reply-To: <CA+55aFwxbs_hLG58Q_xSK2vpufjmwMk-xkqxTNh_5h-A8y4vbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 5, 2016 at 1:43 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Mar 4, 2016 at 2:26 PM, Andrey Konovalov <andreyknvl@gmail.com> wrote:
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
>
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

Yes, KASAN doesn't report anything with your patch.

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
