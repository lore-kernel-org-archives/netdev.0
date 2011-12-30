From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [BUG] SIOCSIFFLAGS returns -EIO on SMSC LAN911x
Date: Fri, 30 Dec 2011 13:58:18 +0100
Message-ID: <CAAwP0s0Y329AAXpHW9muOECt5DpgpDm6kefXR7uE1233A1LGWg@mail.gmail.com>
References: <CAAwP0s37E=9J-KR397snkvq=idrc7nmELDJKrm33reeK84wJYQ@mail.gmail.com>
 <1325242573.13595.71.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Enric Balletbo i Serra <eballetbo@iseebcn.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:54138 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825Ab1L3M6k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 07:58:40 -0500
Received: by yhr47 with SMTP id 47so8455888yhr.19
        for <netdev@vger.kernel.org>; Fri, 30 Dec 2011 04:58:40 -0800 (PST)
In-Reply-To: <1325242573.13595.71.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 30, 2011 at 11:56 AM, Ben Hutchings <ben@decadent.org.uk> w=
rote:
> On Fri, 2011-12-30 at 10:44 +0100, Javier Martinez Canillas wrote:
>> Hello,
>>
>> We have an issue with the SMSC LAN911x driver with today linux-2.6 [=
1]
>> executing on an IGEPv2 [2] board using omap2plus_defconfig.
>>
>> When I try to bring up the network interface, the ioctl set interfac=
e
>> flags command (SIOCSIFFLAGS) =C2=A0fails returning -EIO:
> [...]
>> By doing a git bisect we found that this strange behavior exists whe=
n
>> the Kconfig tristate compilation condition SMSC_PHY has the value ye=
s
>> to be compiled built-in:
>>
>> SMSC_PHY=3Dy
>>
>> If this config symbol has the value module (m) or not build at all,
>> then bringing up the network interface never fails.
>
> So the PHY driver is doing something that interferes with soft reset.
>

We have more information about the issue. It seems that the LAN9221i
network device has inside a lan8700 phy chip. When we compile with
SMSC_PHY and the smsc.c driver is included the lan8700 phy_driver
enable the energy detect mode for the transceiver.

> The data sheet for this part
> <http://www.smsc.com/media/Downloads_Public/Data_Sheets/9221.pdf> say=
s
> that soft reset does not work if the PHY is in certain states. =C2=A0=
Also, it
> doesn't seem to specify a maximum time for soft reset to complete,
> though it does say that PHY reset takes 100 us.
>

One of the states that prevents software reseting the chip is when the
phy is in low power mode. So the reset fails in the ndo_open handler
(ifconfig ethx up).

>> Did anyone have the same problem?
>>
>> The problem is really strange to me, especially since we are sure th=
at
>> all the requirements to software reset the device are meet in both
>> cases (with SMSC_PHY compiled built-in and without it)
>
> I don't know about that. =C2=A0smsc_phy_config_init() attempts to ena=
ble
> power-saving on the PHY, but it is writing to a bit that is reserved
> according to the data sheet for the combined MAC/PHY chip. =C2=A0dwei=
n

Since the PHY chip is a lan8700, the power-saving seems to be correct.
But the problem is when latter in the open handler a software reset is
attempt.

Probably I can protect the software reset and only try to reset the
device if the PHY is now in a low power mode. But if we don't reset
the device at interface bringing up, when should we do a the reset?

I'm not that familiarized with the networking layer, if someone can
give me some light I can fix the issue and send a patch.

Thanks a lot and best regards,

--=20
Javier Mart=C3=ADnez Canillas
(+34) 682 39 81 69
Barcelona, Spain
