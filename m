From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 11:36:18 +0100
Message-ID: <CAAP7uc+3sJRJ9khC6x58ULy2vR8fTCi6gMwtgV_0GAWW49AwLg@mail.gmail.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
	<201511021916.18117.marex@denx.de>
	<666821254.20151102231521@cogentembedded.com>
	<201511022125.47892.marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:36193 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbbKCKgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 05:36:19 -0500
Received: by oiao187 with SMTP id o187so6233375oia.3
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 02:36:18 -0800 (PST)
In-Reply-To: <201511022125.47892.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey!

On Mon, Nov 2, 2015 at 9:25 PM, Marek Vasut <marex@denx.de> wrote:
>> > I was thinking about this and I mostly agree with you. Obviously, copying
>> > the code this way was dumb. On the other hand, ARINC and CAN are two
>> > different sort of busses, so I'd propose something slightly different
>> > here to avoid confusion and prevent the future extensions (or protocols)
>> > from adding unrelated cruft into the CAN stack.
>>

I'd keep them separate not because ARINC may add unrelated cruft into
the CAN stack, but because ARINC is much simpler than CAN already...

>> Another  major  difference  between  CAN and ARINC429 is that ARINC is
>> simplex.  It  does  not  need  loopback  and echo. For example HOLT IC
>> chip  HI-3593  has  two receivers and single transmitter, which
>> should  be  instantiated as separate devices, as each channel could be
>> connected to different network.
>
> So this would effectively be three devices, correct ?  I think you can just
> register a regular ARINC device for each channel and be done with it. Loopback
> and echo can be configurable.
>

I tend to agree with Andrey here; I'm not sure I see any use case for
the echo feature (a TX channel is a TX channel, you don't expect
anything back), and just testing purposes for the loopback.

>> It  would  be nice if new ARINC framework will provide means to create
>> RX  or  TX  only  network device and have -rx- or -tx- as part of device
>> name.
>
> I'd say you can fail the TX if you're trying to send via an RX-only channel.
> The naming can probably be also tweaked, but I don't see much value in that,
> especially since you can rename those interfaces by using udev rules. Checking
> if the interface supports RX/TX should be done by other means, not the name.
>

I don't like the naming change specifying whether -rx or -tx, but it's
true that there are no real channels doing RX and TX at the same time.
You may have a device with multiple channels, and in that case you may
have RX channels and TX channels in the same device, but then the RX
and TX channels may be connected to different buses. Systems will
usually do either TX or RX; and for the case where both things could
make sense (I have a simulator setup that I use that way), the direct
way is to interconnect a TX port with a RX port physically.

>> Label  space in ARINC is much smaller than in CAN, is it really needed
>> to  have  hash  and  masks? May be simple bitmap for 256 bits will fit
>> better.  At least it could be directly provided to mentioned HOLT chip
>> to do filtering in hardware.
>
> CAN does the can_id filtering this way and I find it familiar and convenient,
> so I don't see a reason not to re-use it. If the hardware has some special
> support for the frame filtering, it's the driver that should convert the
> filter specification into form which the hardware understands -- this sort
> of configuration is done only once at the beginning of operation, so some
> small overhead of the conversion of the filter setting should be acceptable,
> we're talking about generating 256 entries for the hardware from ID/mask tuple,
> no big deal here.

I also tend to see this filtering setup a bit of over-engineered for
ARINC429. A fixed-sized 256 bitmask per socket to specify which labels
are wanted is more than enough. And that will then actually have a
direct relationship with the hardware label filtering setup. It's true
that the filter list is built at the beginning, but the filters then
need to get applied per ARINC word received.

Also, this setup is forcing users to look for the minimum set of
filters to match the labels they want to receive. In practice, users
will just want to receive a given set of labels and would likely end
up with one filter per label wanted with a 0xFF mask to match the full
label they want. I'd prefer if the users could just give a 256 bit
mask, one bit per ARINC label wanted, it would make much more sense.
All this complex filtering setup, including the inverse filter (no
clear usecase for that), looks a bit out of context in ARINC429. The
filtering interface and implementation could be much simpler and I
believe it would actually fit better what users expect from it.


Unrelated to all this, another key point in ARINC is the timing for
each label when transmitting. The common case you get is different
labels being sent continuously with a given rate for each. E.g. labels
310 and 311 every 80ms, label 312 every 120ms and so on. I'm not sure
the HOLT chips have any specific way of configuring this, but I've
seen some USB devices which actually have APIs to say e.g. "send label
310 every 80ms" and then you can just update the value being sent
without needing to take care of the TX rate. I'd have loved to see
that instead of the complex filtering :) I know this is way too much
for the generic kernel driver, though, so just a heads up of how this
usually works.

-- 
Aleksander
https://aleksander.es
