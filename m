From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH] usbnet: improve/fix status interrupt endpoint interval
Date: Thu, 6 Jun 2013 19:05:19 +0800
Message-ID: <CACVXFVPyhNQ9_NL8jijV35i93N5rjLn8v5rAEoom-y=y1AqkRA@mail.gmail.com>
References: <20130604182830.GA13186@rhlx01.hs-esslingen.de>
	<CACVXFVOYMGjGLmyGy=pQwkcuFshLmdNcLZKfqUDazge45GMBPA@mail.gmail.com>
	<20130605163426.GA18818@rhlx01.hs-esslingen.de>
	<CACVXFVMGs3Mh8QG5R0+HS_32q44xfa_h6iBH5jpuNrnHeuHbfA@mail.gmail.com>
	<20130606065407.GA12910@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	OndrejZary <linux@rainbow-software.org>,
	linux-usb <linux-usb@vger.kernel.org>
To: Andreas Mohr <andi@lisas.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130606065407.GA12910@rhlx01.hs-esslingen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 6, 2013 at 2:54 PM, Andreas Mohr <andi@lisas.de> wrote:
> On Thu, Jun 06, 2013 at 09:33:28AM +0800, Ming Lei wrote:
>> On Thu, Jun 6, 2013 at 12:34 AM, Andreas Mohr <andi@lisas.de> wrote:
>> > Hi,
>> >
>> > On Wed, Jun 05, 2013 at 09:22:25AM +0800, Ming Lei wrote:
>> >> On Wed, Jun 5, 2013 at 2:28 AM, Andreas Mohr <andi@lisas.de> wrote:
>> >> >   Value 8 now managed to reduce powertop wakeups from ~ 540 to ~ 155
>> >>
>> >> It means that your device only returns current link status instead of link
>> >> change. IMO, it isn't a good behaviour for the device.
>> >
>> > I don't quite understand that.
>>
>> It is only concluded by the data you provided,  when you get ~540 wakeups,
>> that means basically device will return data for each polling from HC.
>>
>> Also I am wondering why you get ~540 wakeups, instead of ~360(330 + 30)
>> (30 is guessed from ~155 wakup in 8ms interval)
>
> Hmm, right, with raw interval value having been specified as 3,
> this should have ended up as a cooked value of 3ms on full-speed,
> thus, given no further mcs7830 wakeup activity, we should remain at 330 something.
> Will investigate some more (e.g. a quick look at usbmon log timing, too).
>
>
>> Did you check intr_complete() returns OK every time?
>
> Good hint, will check.
>
>
>> >> It isn't a hard demand, which only means the poll interval by which HC
>> >> sends IN token to device.
>> >
>> > I believe this number is meant to be a hard demand by the *device*,
>> > since a device is the authoritative party to know best about its
>> > own servicing requirements.
>>
>> Actually, just see quirks for USB devices, there are many devices which
>> isn't worthy of trust, :-)
>
> I can easily believe that, having had my more than fair share of trouble already ;)
>
>
>> Also some problems should have been reported on current interval
>> value(larger than interval of endpoint) if it was hard demand, but luckly
>> looks no such report found.
>
> Yep.
>
>
>> As I said before, the link change is a low frequency event, so longer
>> interval used by usbnet driver should be OK, right?
>
> ...minus the status flags for frames, which surely would be interesting, too :)
>
>
> (and minus the frequency requirements of the mcs7830 link change
> "20 times" averaging mechanism, which expects a sufficiently high rate)
>
>> > Or, IOW, the thing that is a USB descriptor is to be seen as a *protocol*
>> > where a device signals its requirements (hopefully accurately, though!).
>> > And if it indicates a 1ms bInterval (which is "the requested maximum(!!)
>> > number of milliseconds between transaction attempts" [lvr usbfaq]),
>>
>> USB spec 2.0 doesn't say it is a maximum period between transactions,
>> and only mentions that is a "desired bus access period", see "5.7.4
>> Interrupt Transfer Bus Access Constraints".
>
> Oh, so perhaps we have a usbfaq which actually is a FAQWBA? ;)
> (I should really have a look at the specs directly...)

AFAIK, linux-usb mailist is the best place for usbfaq, :-)

Cc linux-usb already

>
>
>> > Is proper damage-less (overflows...) handling here a promise/guarantee
>> > that's made by the USB specs?
>>
>> Even there is overflow, it happens inside device, and it depends on
>> implementation of device itself.
>
> IOW, the device is free to blow up on its own.
>
>
>> > Otherwise I wouldn't be so confident that a device is acting this way ;)
>>
>> If so, you can use the dev->status->desc.bInterval, so you may complain
>> too much wakeup and CPU power consumed, and we need leverage.
>
> Yep, would surely be very useful to come up with a usbnet-side mechanism which
> flexibly keeps wakeups at a minimum, while still retrieving all data
> that it can get, and this for all devices(drivers) as handled by usbnet.
>
>
>> >> For usbnet, generally speaking, the interrupt pipe is for polling the
>> >> link change, which is a very low frequency event, so you don't need to
>> >> worry about missing events if the interval is increased.
>> >
>> > Yeah, but then those status bits also contain other error info for every packet
>> > processed, thus it's also very useful to achieve polling that's frequent
>> > enough to properly grab info for all transferred ether frames, rather
>> > than merely concentrating on link change info.
>>
>> Actually, most of usbnet drivers only use interrupt pipe to retrieve link
>> change(asix, smsc, ...). But if your device may provide other information
>> via interrupt pipe and your driver requires that, you may keep the
>> desired interval with extra power if it is worthy.
>>
>> Could you let us know what device may provide ether frame info
>> and how your drivers use that?
>
> That should be all devices supported by mcs7830.c,
> where it's probably the
>
> +       MCS7830_STATUS_ETHER_FRAME_OK                   = 0x0001,
> +       MCS7830_STATUS_RETRIES_MORE_THAN_16             = 0x0002,
> +       MCS7830_STATUS_COLLISION_OCCURRED_AFTER_64BYTES = 0x0004,
> +       MCS7830_STATUS_PACKET_ABORTED_EXCESS_DEFERRAL   = 0x0008,
>
> +       MCS7830_STATUS_TX_STATUS_VECTOR_BITS_VALID      = 0x4000,
>
> bits, provided for all transferred ether frames, when polled frequently enough.

I don't know the exact meaning of the bits, but looks all are some
statistics information for tx/rx frames, so look no harm to read these
bits less frequently.

Could you share how you will use these bits and what you will use them for?


Thanks,
--
Ming Lei
