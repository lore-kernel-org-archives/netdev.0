From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [BUG] SIOCSIFFLAGS returns -EIO on SMSC LAN911x
Date: Tue, 3 Jan 2012 08:44:25 +0100
Message-ID: <CAAwP0s36dvw7d5LLs4LGZ8_ANiCHpCSWLSrUObF6thziY9JpsQ@mail.gmail.com>
References: <CAAwP0s37E=9J-KR397snkvq=idrc7nmELDJKrm33reeK84wJYQ@mail.gmail.com>
 <1325242573.13595.71.camel@deadeye> <CAAwP0s0Y329AAXpHW9muOECt5DpgpDm6kefXR7uE1233A1LGWg@mail.gmail.com>
 <1325250948.13595.100.camel@deadeye> <CAAwP0s1KV0gCWXB4-sNDjyVKETGrp9xO8VmAnbJHHCupf4P5pg@mail.gmail.com>
 <1325533505.13595.246.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Enric Balletbo i Serra <eballetbo@iseebcn.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:63324 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab2ACHor convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 02:44:47 -0500
Received: by ghbg21 with SMTP id g21so3362420ghb.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 23:44:46 -0800 (PST)
In-Reply-To: <1325533505.13595.246.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 2, 2012 at 8:45 PM, Ben Hutchings <ben@decadent.org.uk> wro=
te:
> On Mon, 2012-01-02 at 19:37 +0100, Javier Martinez Canillas wrote:
> [...]
>> Thanks for your help.
>>
>> Finally, what I did was to bring to operational mode the integrated
>> PHY chip by disabling the energy detect power-down mode before doing=
 a
>> software reset and re-enabling after it.
>>
>> Does that solution make sense to you? I've sent the patch-set to the
>> list for review. The patch-set is composed of the following patches:
> [...]
>
> I think that if the data sheet says the power-down bit is reserved on
> the 9221i then it is better not to set it at all. =C2=A0However, give=
n that
> you actually have hardware to test on, you are in a better position t=
o
> say what actually works.
>
> Ben.
>

Hello Ben,

I didn't find on the LAN9221/LAN9221i data-sheet where it says that
this bit 0x17.13 is reserved.

In fact if you look at Section 5.5 "PHY Registers" (page 117) you will
see that the PHY register 0x17 "Mode Control/Status Register" (page
122) is a valid PHY register address and can be used to enable and
disable the Energy Detect Power-Down mode by writing to the bit-field
13 (EDPWRDOWN). Also a functional description of this behavior is
explanied in Section "3.10.3.2 Energy Detect Power-Down" (page 47).

Since in drivers/net/phy/smsc.c the phy is initialized with:

#define MII_LAN83C185_CTRL_STATUS 17 /* Mode/Status Register */
#define MII_LAN83C185_EDPWRDOWN (1 << 13) /* EDPWRDOWN */

static int smsc_phy_config_init(struct phy_device *phydev)
{
        int rc =3D phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
        if (rc < 0)
                return rc;

        /* Enable energy detect mode for this SMSC Transceivers */
        rc =3D phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
                       rc | MII_LAN83C185_EDPWRDOWN);
        if (rc < 0)
                return rc;

        return smsc_phy_ack_interrupt (phydev);
}

I think that the enabling of the Energy Detect Power-Down mode is corre=
ct.

On section 5.3.9 "HW_CFG=E2=80=94Hardware Configuration Register" it sa=
ys that:

"Soft Reset Timeout (SRST_TO). If a software reset is attempted when
the PHY is not in the operational state (RX_CLK and TX_CLK running),
the reset will not
complete and the soft reset operation will timeout and this bit will
be set to a =E2=80=981=E2=80=99."

Is exactly the behavior we have when the PHY is in low power mode
because the energy detect power-down mode is enabled and no energy is
detected.

That's why I thought to use the bit-field EDPWRDOWN to disable the
energy detect power-down mode before making the software reset. This
brings the PHY to operational mode so the software reset never fails.
After the software reset was successful we can re-enable the energy
detect power-down mode to take advantage of the automatic energy
detection supported by the device.

I have tested on the hardware and seems to work properly, but I don't
know if is the best approach.

Best regards,

--=20
Javier Mart=C3=ADnez Canillas
(+34) 682 39 81 69
Barcelona, Spain
