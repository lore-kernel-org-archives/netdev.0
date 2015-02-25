From: B Viswanath <marichika4@gmail.com>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Thu, 26 Feb 2015 01:03:21 +0530
Message-ID: <CAN+pFwKisJH3+LNGQNYDaaAt_vY4i0gEQmd6r-bQVw=ENwz=1Q@mail.gmail.com>
References: <54E76EFA.1050209@cumulusnetworks.com>
	<54E7876A.3060303@gmail.com>
	<FFEDCF9956066D4D97C463CC178C7F69F22E02@SJEXCHMB06.corp.ad.broadcom.com>
	<54E8CE77.3050709@cumulusnetworks.com>
	<CAE4R7bAPS1GZKaC4M6x9cqfTOkVju1+Po4KzanfSniEFX9oi1w@mail.gmail.com>
	<20150225143113.GD17992@lunn.ch>
	<20150225164303.GC25241@roeck-us.net>
	<CAN+pFwKft-f8wPuYbL7MB7O3UdqbKRACoEX44z4iM3BMkuu9eQ@mail.gmail.com>
	<20150225183939.GA4231@roeck-us.net>
	<CAN+pFwJZX1jbdyWiV6jamq9Tj_aiyCtpe8ETRtMfM-R6wuWbxQ@mail.gmail.com>
	<20150225191543.GA6153@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>, Scott Feldman <sfeldma@gmail.com>,
	roopa <roopa@cumulusnetworks.com>,
	Viswanath Bandaru <vbandaru@broadcom.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:46412 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbbBYTdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 14:33:21 -0500
Received: by pdjy10 with SMTP id y10so6990864pdj.13
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 11:33:21 -0800 (PST)
In-Reply-To: <20150225191543.GA6153@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 February 2015 at 00:45, Guenter Roeck <linux@roeck-us.net> wrote:
> On Thu, Feb 26, 2015 at 12:21:47AM +0530, B Viswanath wrote:
>> On 26 February 2015 at 00:09, Guenter Roeck <linux@roeck-us.net> wrote:
>> > On Wed, Feb 25, 2015 at 11:01:00PM +0530, B Viswanath wrote:
>> >> On 25 February 2015 at 22:13, Guenter Roeck <linux@roeck-us.net> wrote:
>> >> >
>> >> <snip>
>> >>
>> >> > > >
>> >> > > > You'll want to turn learning off on the bridge, and enable learning (and
>> >> > > > learning_sync) in hardware.  The hw driver will install an FDB entry in the
>> >> > > > bridge's FDB and mark it "external".  The entry will also appear in the
>> >> > > > device's FDB.
>> >> > >
>> >> > > I don't think this is going to work. There is no efficient way to get
>> >> > > the hardware tables out of the hardware. We don't get notification of
>> >> > > additions or removals. We can only read the whole table. And it can be
>> >> > > expensive to read the whole table, since it can be 1K or more entries,
>> >> > > going over an MDIO bus, which in the worst case can be bit banging on
>> >> > > gpio lines.
>> >> > >
>> >> > Which, coincidentially, is the case in my application. The newer
>> >> > Marvell switches support up to 8k forwarding table entries, so that
>> >> > would be really awkward.
>> >> >
>> >> > > We probably need a design for devices where we can efficiently get
>> >> > > access to the hardware table, and use it in the software bridge. But
>> >> > > we also need a design where the SW and HW bridges have independently
>> >> > > tables.
>> >> > >
>> >>
>> >> I do agree that reading all of FDB into CPU is a pain. Given the table
>> >> size of 1K or 8K, I am (probably incorrectly) speculating that the
>> >> device may be a router primarily. Also, not having means of
>> >
>> > No. I don't think any of the Marvell or Broadcom entry level
>> > switch chips supports L3.
>> >
>> > See http://www.marvell.com/switching/link-street/ and
>> > http://community.broadcom.com/docs/DOC-1724.
>> >
>> > Forwarding table size in those chips is from 1k all the way up to 16k.
>> >
>> > It is correct to assume that some of those chips are _used_ in
>> > routers/L3 switches, but that would not be used for L3 data but
>> > to interrconnect the various cards in the system, primarily for
>> > internal management traffic.
>>
>> I didn't mean that the chips support L3 in hardware, as you said they
>> don't. I meant that these chips are used in routers which have routing
>> done by CPU. Typically the OPENWRT class devices, SOHO or similar
>> devices.
>>
> No, that is not the use case in any of the use cases I am aware of
> and have been involved with.

Ok.
>
>> For these routers, exposing FDB to CPU is not really a requirement. So
>> the hardware is not built to have learn/age-notifications or efficient
>> access to FDB.  This is the reason I asked you whether the driver you
>> are developing really needs to expose FDB to CPU.
>>
>> >
>> >> learn-notifications and/or a quick (hw) interface to get all the
>> >> table, I (again probably incorrectly) speculate that there are not
>> >> many use cases associated with FDB and end-user/CPU for this silicon.
>> >>
>> >> So I am thinking why would you want to read FDB to CPU ? You can
>> >> disable learning on the bridge and have the driver not send any
>> >> learning notifications to kernel, while the silicon continues to learn
>> >> and forward.  The end user may not be able see the FDB on a command,
>> >> but is this a requirement for you ?
>> >>
>> >> I may be missing some use cases here, so would you mind mentioning ?
>> >>
>> > A bridge can span multiple switch chips as well as some local interfaces.
>> > In that case, it would be beneficial if the switch would be able to share
>> > its fdb with the CPU, but I don't think it is mandatory. I may be missing
>> > something, though.
>>
>> This is a general usecase and is usually with chips that can support
>> learning notifications and other CPU controls on FDB. It can be
>> implemented via bridge controlling the FDB. But I suspect this usecase
>> won't be applicable for the device you are attempting to port the
>> driver to.
>>
>
> What do you mean with "bridge controlling the FDB" ? You mean by software ?
> That would not scale for the reasons mentioned earlier; the switch chips
> need to be able to populate their own FDBs.

Yes, I mean software. I think the scalability issue is not applicable
for chips (in the end-devices) which don't have the need to have CPU
looking at FDB. Those chips can maintain their own FDB but don't need
to inform CPU, therefore bypassing the scalability issue.  Please also
see my note below.

>
> Note that I am not that much concerned about "my" use cases, at least not
> for now. For those cases, there will in general only be one port connected
> to the CPU, and a bridge group is not shared across multiple ethernet ports
> conneted to the CPU and some of the switch ports. But that doesn't mean
> that we should ignore that possibility.

The general usecases are those that deal with CPU looking at the FDB
and/or somehow trying to manipulate. I guess I am trying to say that
these usecases are really applicable to devices/silicon where FDB
addition/ageing notifications are supported by the silicon and where
FDB can be read quickly (than MDIO/SPI/I2C) by CPU. Therefore  the
drivers can afford to learn the FDB additions/deletions and update the
bridge, thus the bridge and the hardware FDB can be in sync.

For those devices/silicon which don't offer these capabilities, the
use cases themselves are not applicable. The driver can afford to not
read FDB from silicon. Therefore, the scalability issues (reading huge
data from MDIO/SPI/I2C) don't really come into play.

>
> Thanks,
> Guenter
