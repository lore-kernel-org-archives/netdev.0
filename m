From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH] usbnet: improve/fix status interrupt endpoint interval
Date: Thu, 6 Jun 2013 09:33:28 +0800
Message-ID: <CACVXFVMGs3Mh8QG5R0+HS_32q44xfa_h6iBH5jpuNrnHeuHbfA@mail.gmail.com>
References: <20130604182830.GA13186@rhlx01.hs-esslingen.de>
	<CACVXFVOYMGjGLmyGy=pQwkcuFshLmdNcLZKfqUDazge45GMBPA@mail.gmail.com>
	<20130605163426.GA18818@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	OndrejZary <linux@rainbow-software.org>
To: Andreas Mohr <andi@lisas.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130605163426.GA18818@rhlx01.hs-esslingen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 6, 2013 at 12:34 AM, Andreas Mohr <andi@lisas.de> wrote:
> Hi,
>
> On Wed, Jun 05, 2013 at 09:22:25AM +0800, Ming Lei wrote:
>> On Wed, Jun 5, 2013 at 2:28 AM, Andreas Mohr <andi@lisas.de> wrote:
>> >
>> > From 307685fe8e6dfc8181e30167b9c31479332cb22f Mon Sep 17 00:00:00 2001
>> > From: Andreas Mohr <andim2@users.sourceforge.net>
>> > Date: Sun, 2 Jun 2013 20:37:05 +0200
>> > Subject: [PATCH] usbnet: improve/fix status interrupt endpoint interval
>> >  tweaking.
>> >
>> > - failed to take super-speed into account
>> > - <= full-speed seems to have wrong value (specified as frames [ms],
>> >   thus 3 is not suitable to achieve 8ms)
>>
>> The above change is correct.
>>
>> >   Value 8 now managed to reduce powertop wakeups from ~ 540 to ~ 155
>>
>> It means that your device only returns current link status instead of link
>> change. IMO, it isn't a good behaviour for the device.
>
> I don't quite understand that.

It is only concluded by the data you provided,  when you get ~540 wakeups,
that means basically device will return data for each polling from HC.

Also I am wondering why you get ~540 wakeups, instead of ~360(330 + 30)
(30 is guessed from ~155 wakup in 8ms interval)

Did you check intr_complete() returns OK every time?

> The way I see it is that there's the "20 times same value" averaging,
> and once that was successful, a link change gets communicated
> (usbnet_link_change()). Thus that merely results in a *delay*
> in signalling the link change...
>
>> In fact, you still can increase the period only for your device, for example,
>> 128ms/256ms/512ms should be accepted.
>
> Possibly.
>
>> > - add detailed docs and question marks about current practice
>>
>> But the doc need to be fixed.
>
> Hmm.
>
>> >         /* avoid 1 msec chatter:  min 8 msec poll rate */
>> > +       /* High/SuperSpeed expresses intervals in microframes
>> > +        * (in logarithmic encoding, PRIOR to encoding in URB)
>> > +        * rather than frames.
>> > +        * Thus, for >= HighSpeed: == X [microframes] * 125us [-> 8ms],
>> > +        * <= FullSpeed: == X [ms] [-> 8ms].
>> > +        * Finally, it's questionable whether we'll even get away unscathed
>> > +        * with doing such rate tweaking at all:
>> > +        * bInterval value is declared as being a hard demand by a device
>>
>> It isn't a hard demand, which only means the poll interval by which HC
>> sends IN token to device.
>
> I believe this number is meant to be a hard demand by the *device*,
> since a device is the authoritative party to know best about its
> own servicing requirements.

Actually, just see quirks for USB devices, there are many devices which
isn't worthy of trust, :-)

Also some problems should have been reported on current interval
value(larger than interval of endpoint) if it was hard demand, but luckly
looks no such report found.

As I said before, the link change is a low frequency event, so longer
interval used by usbnet driver should be OK, right?

> Or, IOW, the thing that is a USB descriptor is to be seen as a *protocol*
> where a device signals its requirements (hopefully accurately, though!).
> And if it indicates a 1ms bInterval (which is "the requested maximum(!!)
> number of milliseconds between transaction attempts" [lvr usbfaq]),

USB spec 2.0 doesn't say it is a maximum period between transactions,
and only mentions that is a "desired bus access period", see "5.7.4
Interrupt Transfer Bus Access Constraints".

> then one could argue that the servicing party (the kernel) damn well
> ought to follow through (unless it reliably knows that it can violate
> some parts of these demands without getting caught).
>
>> > +        * in order to guarantee having its I/O needs serviced properly...
>> > +        * if we don't do this, then... [overruns], [fire], [apocalypse]?
>>
>> Not so serious, if one packet is ready, the late poll from HC may still
>> get the packet since device can buffer the packet, but if it is too late,
>> the successor packet might be missed by device.
>
> Is proper damage-less (overflows...) handling here a promise/guarantee
> that's made by the USB specs?

Even there is overflow, it happens inside device, and it depends on
implementation of device itself.

> Otherwise I wouldn't be so confident that a device is acting this way ;)

If so, you can use the dev->status->desc.bInterval, so you may complain
too much wakeup and CPU power consumed, and we need leverage.

>
>> For usbnet, generally speaking, the interrupt pipe is for polling the
>> link change, which is a very low frequency event, so you don't need to
>> worry about missing events if the interval is increased.
>
> Yeah, but then those status bits also contain other error info for every packet
> processed, thus it's also very useful to achieve polling that's frequent
> enough to properly grab info for all transferred ether frames, rather
> than merely concentrating on link change info.

Actually, most of usbnet drivers only use interrupt pipe to retrieve link
change(asix, smsc, ...). But if your device may provide other information
via interrupt pipe and your driver requires that, you may keep the
desired interval with extra power if it is worthy.

Could you let us know what device may provide ether frame info
and how your drivers use that?

>
>> > +        * If this turns out to be problematic, such policy should be moved
>> > +        * to individual drivers (indicate flag to [dis]allow rate tweaking
>> > +        * as tolerated by specific devices).
>>
>> Yes, we can add quirk for such kind device by increasing polling
>> interval.
>
> Sure, but that handling seems a bit static. An ideal service level would be
> getting notified of all link changes in a sufficiently slow way,
> *and* always catching status flags of *all* frames, too.

I think we need to know how useful the status flags of all frames are first.

>
>> > +        */
>> >         period = max ((int) dev->status->desc.bInterval,
>> > -               (dev->udev->speed == USB_SPEED_HIGH) ? 7 : 3);
>> > +               ((dev->udev->speed == USB_SPEED_HIGH) ||
>> > +                (dev->udev->speed == USB_SPEED_SUPER)) ? 7 : 8);
>>
>> For the above change, please feel free to add my ack:
>>
>>               Acked-by: Ming Lei <ming.lei@canonical.com>
>
> Thanks!
>
>
> I'm still unsure how/whether to reword my documentation part, though.
> If you happen to have some ideas about some updates,
> that would be great.

Since the interval policy you concerned in the doc has been used so
long and we can discuss it further, also it is another problem, not much
related with the fix patch.

How about separating the document from the fix patch?

Thanks,
--
Ming Lei
