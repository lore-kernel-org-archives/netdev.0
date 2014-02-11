From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V3] net/dt: Add support for overriding phy configuration
 from device tree
Date: Tue, 11 Feb 2014 09:43:57 -0800
Message-ID: <CAGVrzca7CV1SM0PfV2o=02Zd8z-65002kq6e-fhG6gWdkCadGA@mail.gmail.com>
References: <7510122.cayuQ6qt8r@wuerfel> <CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com>
 <52F8FB03.6040606@keymile.com> <29007785.iYrLORbRAN@lenovo> <52F9E8E6.1090006@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthew Garrett <matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
To: Gerlando Falauto <gerlando.falauto-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52F9E8E6.1090006-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Gerlando,

2014-02-11 1:09 GMT-08:00 Gerlando Falauto <gerlando.falauto-SkAbAL50j+6IwRZHo2/mJg@public.gmane.org=
m>:
> Hi Florian,
>
> first of all, thank you for your answer.
>
>
> On 02/10/2014 06:09 PM, Florian Fainelli wrote:
>>
>> Hi Gerlando,
>>
>> Le lundi 10 f=C3=A9vrier 2014, 17:14:59 Gerlando Falauto a =C3=A9cri=
t :
>>>
>>> Hi,
>>>
>>> I'm currently trying to fix an issue for which this patch provides =
a
>>> partial solution, so apologies in advance for jumping into the
>>> discussion for my own purposes...
>>>
>>> On 02/04/2014 09:39 PM, Florian Fainelli wrote:> 2014-01-17 Matthew
>>>
>>> Garrett <matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org>:
>>>   >> Some hardware may be broken in interesting and board-specific =
ways,
>>> such
>>>   >> that various bits of functionality don't work. This patch prov=
ides a
>>>   >> mechanism for overriding mii registers during init based on th=
e
>>>
>>> contents of
>>>
>>>   >> the device tree data, allowing board-specific fixups without h=
aving
>>> to
>>>   >> pollute generic code.
>>>   >
>>>   > It would be good to explain exactly how your hardware is broken
>>>   > exactly. I really do not think that such a fine-grained setting=
 where
>>>   > you could disable, e.g: 100BaseT_Full, but allow 100BaseT_Half =
to
>>>   > remain usable makes that much sense. In general, Gigabit might =
be
>>>   > badly broken, but 100 and 10Mbits/sec should work fine. How abo=
ut the
>>>   > MASTER-SLAVE bit, is overriding it really required?
>>>   >
>>>   > Is not a PHY fixup registered for a specific OUI the solution y=
ou are
>>>   > looking for? I am also concerned that this creates PHY
>>> troubleshooting
>>>   > issues much harder to debug than before as we may have no idea =
about
>>>   > how much information has been put in Device Tree to override th=
at.
>>>   >
>>>   > Finally, how about making this more general just like the BCM87=
xx PHY
>>>   > driver, which is supplied value/reg pairs directly? There are 1=
6
>>>   > common MII registers, and 16 others for vendor specific registe=
rs,
>>>   > this is just covering for about 2% of the possible changes.
>>>
>>> Good point. That would easily help me with my current issue, which
>>> requires autoneg to be disabled to begin with (by clearing BMCR_ANE=
NABLE
>>> from register 0).
>>
>>
>> Is there a point in time (e.g: after some specific initial configura=
tion
>> has
>> been made) where BMCR_ANENABLE can be used?
>
>
> What do you mean? In my case, for some HW-related reason (due to the =
PHY
> counterpart I guess) autoneg needs to be disabled.
> This is currently done by the bootloader code (which clears the bit).
> What I'm looking for is some way for the kernel to either reinforce t=
his
> setting, or just take that into account and skip autoneg.
> On top of that, there's a HW errata about that particular PHY, which
> requires certain operations to be performed on the PHY as a workaroun=
d *WHEN
> AUTONEG IS DISABLED*. That I'd implement on a PHY-specif driver.

Ok.

>
>
>>> This would not however fix it entirely (I tried a quick hardwired
>>> implementation), as the whole PHY machinery would not take that int=
o
>>> account and would re-enable autoneg anyway.
>>> I also tried changing the patch so that phydev->support gets update=
d
>>
>>
>> There are multiple things that you could try doing here:
>>
>> - override the PHY state machine in your read_status callback to mak=
e sure
>> that you always set phydev->autoneg set to AUTONEG_ENABLE
>
>
> [you mean AUTONEG_DISABLE, right?]

Right, I fat fingered here.

> Uhm, but I don't want to implement a driver for that PHY that always
> disables autoneg. I only want to disable autoneg for that particular =
board.
> I figure I might register a fixup for that board, but that kindof mak=
es
> everything more complicated and less clear. Plus, what should be the
> criterion to determine whether we're running on that particular hardw=
are?

of_machine_is_compatible() plus reading the specific PHY OUI should
provide you with with an unique machine + PHY tuple. If your machine
name is too generic.

>
>
>> - clear the SUPPORTED_Autoneg bits from phydev->supported right afte=
r PHY
>> registration and before the call to phy_start()
>
>
> I actually tried clearing it by tweaking the patch on this thread, bu=
t the
> end result is that it does not produce any effect (see further commen=
ts
> below). Only thing that seems to play a role here is explictly settin=
g
> phydev->autoneg =3D AUTONEG_DISABLE.
>
>
>> - set the PHY_HAS_MAGICANEG bit in your PHY driver flag
>
>
> Again, this seems to play no role whatsoever here:
>
>                         } else if (0 =3D=3D phydev->link_timeout--) {
>                                 needs_aneg =3D 1;
>                                 /* If we have the magic_aneg bit,
>                                  * we try again */
>                                 if (phydev->drv->flags & PHY_HAS_MAGI=
CANEG)
>                                         break;
>                         }
>                         break;
>                 case PHY_NOLINK:
>
> This code might have made sense when it was written in 2006 -- back t=
hen,
> the break statement was skipping some fallback code. But now it seems=
 to do
> nothing.
>
>
>>
>>>
>>> (instead of phydev->advertising):
>>>   >> +               if (!of_property_read_u32(np, override->prop, =
&tmp))
>>> {
>>>   >> +                       if (tmp) {
>>>   >> +                               *val |=3D override->value;
>>>   >> +                               phydev->advertising |=3D
>>>
>>> override->supported;
>>>
>>>   >> +                       } else {
>>>   >> +                               phydev->advertising &=3D
>>>
>>> ~(override->supported);
>>>
>>>   >> +                       }
>>>   >> +
>>>   >> +                       *mask |=3D override->value;
>>>
>>> What I find weird is that the only way phydev->autoneg could ever b=
e set
>>> to disabled is from here (phy.c):
>>>
>>> static void phy_sanitize_settings(struct phy_device *phydev)
>>> {
>>>         u32 features =3D phydev->supported;
>>>         int idx;
>>>
>>>         /* Sanitize settings based on PHY capabilities */
>>>         if ((features & SUPPORTED_Autoneg) =3D=3D 0)
>>>                 phydev->autoneg =3D AUTONEG_DISABLE;
>>>
>>> which is in turn only called when phydev->autoneg is set to
>>> AUTONEG_DISABLE to begin with:
>>>
>>> int phy_start_aneg(struct phy_device *phydev)
>>> {
>>>         int err;
>>>
>>>         mutex_lock(&phydev->lock);
>>>
>>>         if (AUTONEG_DISABLE =3D=3D phydev->autoneg)
>>>                 phy_sanitize_settings(phydev);
>>>
>>> So could someone please help me figure out what I'm missing here?
>>
>>
>> At first glance it looks like the PHY driver should be reading the p=
hydev-
>>>
>>> autoneg value when the PHY driver config_aneg() callback is called =
to be
>>
>> allowed to set the forced speed and settings.
>>
>> The way phy_sanitize_settings() is coded does not make it return a m=
ask of
>> features, but only the forced supported speed and duplex. Then when =
the
>> link
>> is forced but we are having some issues getting a link status, libph=
y
>> tries
>> lower speeds and this function is used again to provide the next
>> speed/duplex
>> pair to try.
>>
>
> What I was trying to say is that phy_sanitize_settings() is only call=
ed when
> phydev->autoneg =3D=3D AUTONEG_DISABLE, and in turn it's the only gen=
eric
> function setting phydev->autoneg =3D AUTONEG_DISABLE.
> So perhaps the condition should read:
>
> -       if (AUTONEG_DISABLE =3D=3D phydev->autoneg)
> +       if ((features & SUPPORTED_Autoneg) =3D=3D 0)
>                 phy_sanitize_settings(phydev);
>
> Or else, some other parts of the generic code should take care of set=
ting it
> to AUTONEG_DISABLE, depending on whether the feature is supported or =
not.
> What I found weird is explicitly setting a value (phydev->autoneg =3D
> AUTONEG_DISABLE), from a static function which is only called when th=
at
> condition is already true.

I do not think that this change is correct either, let me cook a patch
for you to allow disabling autoneg from the start.

>
> BTW, I feel like disabling autoneg from the start has never been a us=
e case
> before, am I right?

Not really no, and that is because most hardware does not need quirks
to work correctly.

>
> Thanks!
> Gerlando



--=20
=46lorian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
