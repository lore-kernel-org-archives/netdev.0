From: Andreas Mohr <andi@lisas.de>
Subject: Re: [PATCH] usbnet: improve/fix status interrupt endpoint interval
Date: Wed, 5 Jun 2013 18:34:26 +0200
Message-ID: <20130605163426.GA18818@rhlx01.hs-esslingen.de>
References: <20130604182830.GA13186@rhlx01.hs-esslingen.de>
 <CACVXFVOYMGjGLmyGy=pQwkcuFshLmdNcLZKfqUDazge45GMBPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Mohr <andi@lisas.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	OndrejZary <linux@rainbow-software.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACVXFVOYMGjGLmyGy=pQwkcuFshLmdNcLZKfqUDazge45GMBPA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Jun 05, 2013 at 09:22:25AM +0800, Ming Lei wrote:
> On Wed, Jun 5, 2013 at 2:28 AM, Andreas Mohr <andi@lisas.de> wrote:
> >
> > From 307685fe8e6dfc8181e30167b9c31479332cb22f Mon Sep 17 00:00:00 2001
> > From: Andreas Mohr <andim2@users.sourceforge.net>
> > Date: Sun, 2 Jun 2013 20:37:05 +0200
> > Subject: [PATCH] usbnet: improve/fix status interrupt endpoint interval
> >  tweaking.
> >
> > - failed to take super-speed into account
> > - <= full-speed seems to have wrong value (specified as frames [ms],
> >   thus 3 is not suitable to achieve 8ms)
> 
> The above change is correct.
> 
> >   Value 8 now managed to reduce powertop wakeups from ~ 540 to ~ 155
> 
> It means that your device only returns current link status instead of link
> change. IMO, it isn't a good behaviour for the device.

I don't quite understand that.
The way I see it is that there's the "20 times same value" averaging,
and once that was successful, a link change gets communicated
(usbnet_link_change()). Thus that merely results in a *delay*
in signalling the link change...

> In fact, you still can increase the period only for your device, for example,
> 128ms/256ms/512ms should be accepted.

Possibly.

> > - add detailed docs and question marks about current practice
> 
> But the doc need to be fixed.

Hmm.

> >         /* avoid 1 msec chatter:  min 8 msec poll rate */
> > +       /* High/SuperSpeed expresses intervals in microframes
> > +        * (in logarithmic encoding, PRIOR to encoding in URB)
> > +        * rather than frames.
> > +        * Thus, for >= HighSpeed: == X [microframes] * 125us [-> 8ms],
> > +        * <= FullSpeed: == X [ms] [-> 8ms].
> > +        * Finally, it's questionable whether we'll even get away unscathed
> > +        * with doing such rate tweaking at all:
> > +        * bInterval value is declared as being a hard demand by a device
> 
> It isn't a hard demand, which only means the poll interval by which HC
> sends IN token to device.

I believe this number is meant to be a hard demand by the *device*,
since a device is the authoritative party to know best about its
own servicing requirements.
Or, IOW, the thing that is a USB descriptor is to be seen as a *protocol*
where a device signals its requirements (hopefully accurately, though!).
And if it indicates a 1ms bInterval (which is "the requested maximum(!!)
number of milliseconds between transaction attempts" [lvr usbfaq]),
then one could argue that the servicing party (the kernel) damn well
ought to follow through (unless it reliably knows that it can violate
some parts of these demands without getting caught).

> > +        * in order to guarantee having its I/O needs serviced properly...
> > +        * if we don't do this, then... [overruns], [fire], [apocalypse]?
> 
> Not so serious, if one packet is ready, the late poll from HC may still
> get the packet since device can buffer the packet, but if it is too late,
> the successor packet might be missed by device.

Is proper damage-less (overflows...) handling here a promise/guarantee
that's made by the USB specs?
Otherwise I wouldn't be so confident that a device is acting this way ;)

> For usbnet, generally speaking, the interrupt pipe is for polling the
> link change, which is a very low frequency event, so you don't need to
> worry about missing events if the interval is increased.

Yeah, but then those status bits also contain other error info for every packet
processed, thus it's also very useful to achieve polling that's frequent
enough to properly grab info for all transferred ether frames, rather
than merely concentrating on link change info.

> > +        * If this turns out to be problematic, such policy should be moved
> > +        * to individual drivers (indicate flag to [dis]allow rate tweaking
> > +        * as tolerated by specific devices).
> 
> Yes, we can add quirk for such kind device by increasing polling
> interval.

Sure, but that handling seems a bit static. An ideal service level would be
getting notified of all link changes in a sufficiently slow way,
*and* always catching status flags of *all* frames, too.

> > +        */
> >         period = max ((int) dev->status->desc.bInterval,
> > -               (dev->udev->speed == USB_SPEED_HIGH) ? 7 : 3);
> > +               ((dev->udev->speed == USB_SPEED_HIGH) ||
> > +                (dev->udev->speed == USB_SPEED_SUPER)) ? 7 : 8);
> 
> For the above change, please feel free to add my ack:
> 
>               Acked-by: Ming Lei <ming.lei@canonical.com>

Thanks!


I'm still unsure how/whether to reword my documentation part, though.
If you happen to have some ideas about some updates,
that would be great.

Thanks!

Andreas Mohr
