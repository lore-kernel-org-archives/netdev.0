From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [BUG] SIOCSIFFLAGS returns -EIO on SMSC LAN911x
Date: Fri, 30 Dec 2011 13:04:31 +0100
Message-ID: <CAAwP0s0SdsPhLL1LzcAzDEnJou_FWQeaGg=h9Du6Sxw99JRwRQ@mail.gmail.com>
References: <CAAwP0s37E=9J-KR397snkvq=idrc7nmELDJKrm33reeK84wJYQ@mail.gmail.com>
 <1325242573.13595.71.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Enric Balletbo i Serra <eballetbo@iseebcn.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:63394 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063Ab1L3MEx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 07:04:53 -0500
Received: by yhr47 with SMTP id 47so8443593yhr.19
        for <netdev@vger.kernel.org>; Fri, 30 Dec 2011 04:04:53 -0800 (PST)
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

Hello Ben, thanks for answering.

> So the PHY driver is doing something that interferes with soft reset.
>
> The data sheet for this part
> <http://www.smsc.com/media/Downloads_Public/Data_Sheets/9221.pdf> say=
s
> that soft reset does not work if the PHY is in certain states. =C2=A0=
Also, it
> doesn't seem to specify a maximum time for soft reset to complete,
> though it does say that PHY reset takes 100 us.
>

Yes, it seems that the PHY driver is the responsible of that.

Something I forgot to mention, the ethernet chip we are using is a
SMSC LAN 9221i.

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
> according to the data sheet for the combined MAC/PHY chip. =C2=A0You =
might
> want to try reverting:
>
> commit 698244ace8b63896565022143ab19f141bc48993
> Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Date: =C2=A0 Wed Jan 6 20:35:14 2010 -0800
>
> =C2=A0 =C2=A0phy: SMSC device Energy Detect power-down mode
>
> Ben.

Thanks a lot, reverting that patch solves the issue.

I've looked at that patch before but since we are using the smsc911x
and that patch made an exception for the lan911x phy_driver I thought
it wasn't the responsible for this:

+static int lan911x_config_init(struct phy_device *phydev)
+{
+       return smsc_phy_ack_interrupt(phydev);
+}

@@ -147,7 +164,7 @@ static struct phy_driver lan911x_int_driver =3D {
        /* basic functions */
        .config_aneg    =3D genphy_config_aneg,
        .read_status    =3D genphy_read_status,
-       .config_init    =3D smsc_phy_config_init,
+       .config_init    =3D lan911x_config_init,

But now I realized that the lan911x phy driver is not being used but
the lan8700_driver phy_driver, and the modified smsc_phy_config_init
was executed.

thanks a lot and best regards,

--=20
Javier Mart=C3=ADnez Canillas
(+34) 682 39 81 69
Barcelona, Spain
