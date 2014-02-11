From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: Re: [PATCH V3] net/dt: Add support for overriding phy configuration
 from device tree
Date: Tue, 11 Feb 2014 10:09:58 +0100
Message-ID: <52F9E8E6.1090006@keymile.com>
References: <7510122.cayuQ6qt8r@wuerfel> <CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com> <52F8FB03.6040606@keymile.com> <29007785.iYrLORbRAN@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthew Garrett <matthew.garrett@nebula.com>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kishon Vijay Abraham I <kishon@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:35948 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbaBKJQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 04:16:08 -0500
In-Reply-To: <29007785.iYrLORbRAN@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

first of all, thank you for your answer.

On 02/10/2014 06:09 PM, Florian Fainelli wrote:
> Hi Gerlando,
>
> Le lundi 10 f=E9vrier 2014, 17:14:59 Gerlando Falauto a =E9crit :
>> Hi,
>>
>> I'm currently trying to fix an issue for which this patch provides a
>> partial solution, so apologies in advance for jumping into the
>> discussion for my own purposes...
>>
>> On 02/04/2014 09:39 PM, Florian Fainelli wrote:> 2014-01-17 Matthew
>>
>> Garrett <matthew.garrett@nebula.com>:
>>   >> Some hardware may be broken in interesting and board-specific w=
ays, such
>>   >> that various bits of functionality don't work. This patch provi=
des a
>>   >> mechanism for overriding mii registers during init based on the
>>
>> contents of
>>
>>   >> the device tree data, allowing board-specific fixups without ha=
ving to
>>   >> pollute generic code.
>>   >
>>   > It would be good to explain exactly how your hardware is broken
>>   > exactly. I really do not think that such a fine-grained setting =
where
>>   > you could disable, e.g: 100BaseT_Full, but allow 100BaseT_Half t=
o
>>   > remain usable makes that much sense. In general, Gigabit might b=
e
>>   > badly broken, but 100 and 10Mbits/sec should work fine. How abou=
t the
>>   > MASTER-SLAVE bit, is overriding it really required?
>>   >
>>   > Is not a PHY fixup registered for a specific OUI the solution yo=
u are
>>   > looking for? I am also concerned that this creates PHY troublesh=
ooting
>>   > issues much harder to debug than before as we may have no idea a=
bout
>>   > how much information has been put in Device Tree to override tha=
t.
>>   >
>>   > Finally, how about making this more general just like the BCM87x=
x PHY
>>   > driver, which is supplied value/reg pairs directly? There are 16
>>   > common MII registers, and 16 others for vendor specific register=
s,
>>   > this is just covering for about 2% of the possible changes.
>>
>> Good point. That would easily help me with my current issue, which
>> requires autoneg to be disabled to begin with (by clearing BMCR_ANEN=
ABLE
>> from register 0).
>
> Is there a point in time (e.g: after some specific initial configurat=
ion has
> been made) where BMCR_ANENABLE can be used?

What do you mean? In my case, for some HW-related reason (due to the PH=
Y=20
counterpart I guess) autoneg needs to be disabled.
This is currently done by the bootloader code (which clears the bit).
What I'm looking for is some way for the kernel to either reinforce thi=
s=20
setting, or just take that into account and skip autoneg.
On top of that, there's a HW errata about that particular PHY, which=20
requires certain operations to be performed on the PHY as a workaround=20
*WHEN AUTONEG IS DISABLED*. That I'd implement on a PHY-specif driver.

>> This would not however fix it entirely (I tried a quick hardwired
>> implementation), as the whole PHY machinery would not take that into
>> account and would re-enable autoneg anyway.
>> I also tried changing the patch so that phydev->support gets updated
>
> There are multiple things that you could try doing here:
>
> - override the PHY state machine in your read_status callback to make=
 sure
> that you always set phydev->autoneg set to AUTONEG_ENABLE

[you mean AUTONEG_DISABLE, right?]
Uhm, but I don't want to implement a driver for that PHY that always=20
disables autoneg. I only want to disable autoneg for that particular=20
board. I figure I might register a fixup for that board, but that kindo=
f=20
makes everything more complicated and less clear. Plus, what should be=20
the criterion to determine whether we're running on that particular=20
hardware?

> - clear the SUPPORTED_Autoneg bits from phydev->supported right after=
 PHY
> registration and before the call to phy_start()

I actually tried clearing it by tweaking the patch on this thread, but=20
the end result is that it does not produce any effect (see further=20
comments below). Only thing that seems to play a role here is explictly=
=20
setting phydev->autoneg =3D AUTONEG_DISABLE.

> - set the PHY_HAS_MAGICANEG bit in your PHY driver flag

Again, this seems to play no role whatsoever here:

			} else if (0 =3D=3D phydev->link_timeout--) {
				needs_aneg =3D 1;
				/* If we have the magic_aneg bit,
				 * we try again */
				if (phydev->drv->flags & PHY_HAS_MAGICANEG)
					break;
			}
			break;
		case PHY_NOLINK:

This code might have made sense when it was written in 2006 -- back=20
then, the break statement was skipping some fallback code. But now it=20
seems to do nothing.

>
>>
>> (instead of phydev->advertising):
>>   >> +               if (!of_property_read_u32(np, override->prop, &=
tmp)) {
>>   >> +                       if (tmp) {
>>   >> +                               *val |=3D override->value;
>>   >> +                               phydev->advertising |=3D
>>
>> override->supported;
>>
>>   >> +                       } else {
>>   >> +                               phydev->advertising &=3D
>>
>> ~(override->supported);
>>
>>   >> +                       }
>>   >> +
>>   >> +                       *mask |=3D override->value;
>>
>> What I find weird is that the only way phydev->autoneg could ever be=
 set
>> to disabled is from here (phy.c):
>>
>> static void phy_sanitize_settings(struct phy_device *phydev)
>> {
>> 	u32 features =3D phydev->supported;
>> 	int idx;
>>
>> 	/* Sanitize settings based on PHY capabilities */
>> 	if ((features & SUPPORTED_Autoneg) =3D=3D 0)
>> 		phydev->autoneg =3D AUTONEG_DISABLE;
>>
>> which is in turn only called when phydev->autoneg is set to
>> AUTONEG_DISABLE to begin with:
>>
>> int phy_start_aneg(struct phy_device *phydev)
>> {
>> 	int err;
>>
>> 	mutex_lock(&phydev->lock);
>>
>> 	if (AUTONEG_DISABLE =3D=3D phydev->autoneg)
>> 		phy_sanitize_settings(phydev);
>>
>> So could someone please help me figure out what I'm missing here?
>
> At first glance it looks like the PHY driver should be reading the ph=
ydev-
>> autoneg value when the PHY driver config_aneg() callback is called t=
o be
> allowed to set the forced speed and settings.
>
> The way phy_sanitize_settings() is coded does not make it return a ma=
sk of
> features, but only the forced supported speed and duplex. Then when t=
he link
> is forced but we are having some issues getting a link status, libphy=
 tries
> lower speeds and this function is used again to provide the next spee=
d/duplex
> pair to try.
>

What I was trying to say is that phy_sanitize_settings() is only called=
=20
when phydev->autoneg =3D=3D AUTONEG_DISABLE, and in turn it's the only=20
generic function setting phydev->autoneg =3D AUTONEG_DISABLE.
So perhaps the condition should read:

- 	if (AUTONEG_DISABLE =3D=3D phydev->autoneg)
+ 	if ((features & SUPPORTED_Autoneg) =3D=3D 0)
  		phy_sanitize_settings(phydev);

Or else, some other parts of the generic code should take care of=20
setting it to AUTONEG_DISABLE, depending on whether the feature is=20
supported or not.
What I found weird is explicitly setting a value (phydev->autoneg =3D=20
AUTONEG_DISABLE), from a static function which is only called when that=
=20
condition is already true.

BTW, I feel like disabling autoneg from the start has never been a use=20
case before, am I right?

Thanks!
Gerlando
