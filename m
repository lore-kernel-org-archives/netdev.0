From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: usbnet: fix softirq storm on suspend
Date: Tue, 04 Sep 2012 09:49:14 +0200
Message-ID: <87y5kqcjnp.fsf@nemi.mork.no>
References: <1346660778-24539-1-git-send-email-bjorn@mork.no>
	<CACVXFVNykwxe-PYP_nin32htFmrFL4d=3DEhZMo3UwTEpb81+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVNykwxe-PYP_nin32htFmrFL4d=3DEhZMo3UwTEpb81+A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Ming Lei's message of "Tue, 4 Sep 2012 12:19:28 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
> On Mon, Sep 3, 2012 at 4:26 PM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote=
:
>
>> Sorry for not noticing this before, but commit 65841fd5
>> makes usbnet autosuspend completely unusable.  The device
>> is suspended fine, but burning one CPU core at full load
>> uses a tiny bit more power making the power saving
>> negative...
>
> I am wondering how you can reproduce the issue.

That's easy:

- Take any usbnet device supporting remote wakeup (and of course with a
  minidriver supporting it as well),
- enable autosuspend,
- ip link set dev ethX/usbX/wwanX up

And watch ksoftirqd/X use 100% of one of your CPU cores.

I'd very much like to hear the details if you are unable to reproduce
the bug using this simple test.

> usbnet_terminate_urbs is called inside usbnet_suspend to
> consume all URBs and SKBs, and rx_alloc_submit can't be
> called during the period because of !netif_device_present().

Huh???? We do support suspending a USB device while the network device
is up and running. That's the whole idea here, isn't it? I.e.
netif_device_present() is *expected* to be true while the USB device is
suspended.

> Once usbnet_terminate_urbs and netif_device_attach() are
> completed, who will schedule tasklet to trigger rx_alloc_submit?

That's a good question.  It sure would be nice if that never happened
without waking the device first.  But there are just too many call site=
s
for me to follow:

bjorn@nemi:/usr/local/src/git/linux$ grep tasklet_schedule drivers/net/=
usb/usbnet.c
                tasklet_schedule(&dev->bh);
 * but tasklet_schedule() doesn't.  hope the failure is rare.
                        tasklet_schedule (&dev->bh);
        tasklet_schedule(&dev->bh);
                tasklet_schedule(&dev->bh);
        tasklet_schedule (&dev->bh);
                        tasklet_schedule (&dev->bh);
                                tasklet_schedule (&dev->bh);
        tasklet_schedule (&dev->bh);
                                tasklet_schedule (&dev->bh);
                        tasklet_schedule (&dev->bh);


And I do believe the code before your change demonstrated that the
original authors had the same view.  There was an explicit exception fo=
r
just this case, and I do assume that was put there for a good
reason. usbnet_bh() will be called while the device is suspended, and w=
e
must avoid making it reschedule itself in this case.

Anyway, the ENOLINK test was there.  You removed it with no explanation
whatsoever. It is *your* call to verify and explain to us why this test
is unnecessary, not mine.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
