From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: Re: [PATCH V3] net/dt: Add support for overriding phy configuration
 from device tree
Date: Wed, 12 Feb 2014 09:57:25 +0100
Message-ID: <52FB3775.10108@keymile.com>
References: <7510122.cayuQ6qt8r@wuerfel> <CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com> <52F8FB03.6040606@keymile.com> <29007785.iYrLORbRAN@lenovo> <52F9E8E6.1090006@keymile.com> <CAGVrzca7CV1SM0PfV2o=02Zd8z-65002kq6e-fhG6gWdkCadGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthew Garrett <matthew.garrett@nebula.com>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kishon Vijay Abraham I <kishon@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:37837 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbaBLJDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 04:03:30 -0500
In-Reply-To: <CAGVrzca7CV1SM0PfV2o=02Zd8z-65002kq6e-fhG6gWdkCadGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 02/11/2014 06:43 PM, Florian Fainelli wrote:
> Hi Gerlando,
>
> 2014-02-11 1:09 GMT-08:00 Gerlando Falauto <gerlando.falauto@keymile.=
com>:
>> Hi Florian,
>>
>> first of all, thank you for your answer.
>>
>>
>> On 02/10/2014 06:09 PM, Florian Fainelli wrote:
>>>
>>> Hi Gerlando,
>>>
>>> Le lundi 10 f=C3=A9vrier 2014, 17:14:59 Gerlando Falauto a =C3=A9cr=
it :
>>>>
>>>> Hi,
>>>>
>>>> I'm currently trying to fix an issue for which this patch provides=
 a
>>>> partial solution, so apologies in advance for jumping into the
>>>> discussion for my own purposes...
>>>>
>>>> On 02/04/2014 09:39 PM, Florian Fainelli wrote:> 2014-01-17 Matthe=
w
>>>>
>>>> Garrett <matthew.garrett@nebula.com>:
>>>>    >> Some hardware may be broken in interesting and board-specifi=
c ways,
>>>> such
>>>>    >> that various bits of functionality don't work. This patch pr=
ovides a
>>>>    >> mechanism for overriding mii registers during init based on =
the
>>>>
>>>> contents of
>>>>
>>>>    >> the device tree data, allowing board-specific fixups without=
 having
>>>> to
>>>>    >> pollute generic code.
>>>>    >
>>>>    > It would be good to explain exactly how your hardware is brok=
en
>>>>    > exactly. I really do not think that such a fine-grained setti=
ng where
>>>>    > you could disable, e.g: 100BaseT_Full, but allow 100BaseT_Hal=
f to
>>>>    > remain usable makes that much sense. In general, Gigabit migh=
t be
>>>>    > badly broken, but 100 and 10Mbits/sec should work fine. How a=
bout the
>>>>    > MASTER-SLAVE bit, is overriding it really required?
>>>>    >
>>>>    > Is not a PHY fixup registered for a specific OUI the solution=
 you are
>>>>    > looking for? I am also concerned that this creates PHY
>>>> troubleshooting
>>>>    > issues much harder to debug than before as we may have no ide=
a about
>>>>    > how much information has been put in Device Tree to override =
that.
>>>>    >
>>>>    > Finally, how about making this more general just like the BCM=
87xx PHY
>>>>    > driver, which is supplied value/reg pairs directly? There are=
 16
>>>>    > common MII registers, and 16 others for vendor specific regis=
ters,
>>>>    > this is just covering for about 2% of the possible changes.
>>>>
>>>> Good point. That would easily help me with my current issue, which
>>>> requires autoneg to be disabled to begin with (by clearing BMCR_AN=
ENABLE
>>>> from register 0).
>>>
>>>
>>> Is there a point in time (e.g: after some specific initial configur=
ation
>>> has
>>> been made) where BMCR_ANENABLE can be used?
>>
>>
>> What do you mean? In my case, for some HW-related reason (due to the=
 PHY
>> counterpart I guess) autoneg needs to be disabled.
>> This is currently done by the bootloader code (which clears the bit)=
=2E
>> What I'm looking for is some way for the kernel to either reinforce =
this
>> setting, or just take that into account and skip autoneg.
>> On top of that, there's a HW errata about that particular PHY, which
>> requires certain operations to be performed on the PHY as a workarou=
nd *WHEN
>> AUTONEG IS DISABLED*. That I'd implement on a PHY-specif driver.
>
> Ok.
>
>>
>>
>>>> This would not however fix it entirely (I tried a quick hardwired
>>>> implementation), as the whole PHY machinery would not take that in=
to
>>>> account and would re-enable autoneg anyway.
>>>> I also tried changing the patch so that phydev->support gets updat=
ed
>>>
>>>
>>> There are multiple things that you could try doing here:
>>>
>>> - override the PHY state machine in your read_status callback to ma=
ke sure
>>> that you always set phydev->autoneg set to AUTONEG_ENABLE
>>
>>
>> [you mean AUTONEG_DISABLE, right?]
>
> Right, I fat fingered here.
>
>> Uhm, but I don't want to implement a driver for that PHY that always
>> disables autoneg. I only want to disable autoneg for that particular=
 board.
>> I figure I might register a fixup for that board, but that kindof ma=
kes
>> everything more complicated and less clear. Plus, what should be the
>> criterion to determine whether we're running on that particular hard=
ware?
>
> of_machine_is_compatible() plus reading the specific PHY OUI should
> provide you with with an unique machine + PHY tuple. If your machine
> name is too generic.

Uhm, actually, my machine name ("model") is specific, but the compatibl=
e=20
string is indeed generic so this would mean adding an extra string=20
there. Not that it's a big issue, but it just seems too complicated and=
=20
hard to follow. After all, we wanted device tree in the first place to=20
get rid of board-sepcific files. To me, filtering by machine name looks=
=20
like a big step backwards, especially if it's all about a "pretty=20
standard feature" like disabling autoneg.

>
>>
>>
>>> - clear the SUPPORTED_Autoneg bits from phydev->supported right aft=
er PHY
>>> registration and before the call to phy_start()
>>
>>
>> I actually tried clearing it by tweaking the patch on this thread, b=
ut the
>> end result is that it does not produce any effect (see further comme=
nts
>> below). Only thing that seems to play a role here is explictly setti=
ng
>> phydev->autoneg =3D AUTONEG_DISABLE.
>>
>>
>>> - set the PHY_HAS_MAGICANEG bit in your PHY driver flag
>>
>>
>> Again, this seems to play no role whatsoever here:
>>
>>                          } else if (0 =3D=3D phydev->link_timeout--)=
 {
>>                                  needs_aneg =3D 1;
>>                                  /* If we have the magic_aneg bit,
>>                                   * we try again */
>>                                  if (phydev->drv->flags & PHY_HAS_MA=
GICANEG)
>>                                          break;
>>                          }
>>                          break;
>>                  case PHY_NOLINK:
>>
>> This code might have made sense when it was written in 2006 -- back =
then,
>> the break statement was skipping some fallback code. But now it seem=
s to do
>> nothing.
>>
>>
>>>
>>>>
>>>> (instead of phydev->advertising):
>>>>    >> +               if (!of_property_read_u32(np, override->prop=
, &tmp))
>>>> {
>>>>    >> +                       if (tmp) {
>>>>    >> +                               *val |=3D override->value;
>>>>    >> +                               phydev->advertising |=3D
>>>>
>>>> override->supported;
>>>>
>>>>    >> +                       } else {
>>>>    >> +                               phydev->advertising &=3D
>>>>
>>>> ~(override->supported);
>>>>
>>>>    >> +                       }
>>>>    >> +
>>>>    >> +                       *mask |=3D override->value;
>>>>
>>>> What I find weird is that the only way phydev->autoneg could ever =
be set
>>>> to disabled is from here (phy.c):
>>>>
>>>> static void phy_sanitize_settings(struct phy_device *phydev)
>>>> {
>>>>          u32 features =3D phydev->supported;
>>>>          int idx;
>>>>
>>>>          /* Sanitize settings based on PHY capabilities */
>>>>          if ((features & SUPPORTED_Autoneg) =3D=3D 0)
>>>>                  phydev->autoneg =3D AUTONEG_DISABLE;
>>>>
>>>> which is in turn only called when phydev->autoneg is set to
>>>> AUTONEG_DISABLE to begin with:
>>>>
>>>> int phy_start_aneg(struct phy_device *phydev)
>>>> {
>>>>          int err;
>>>>
>>>>          mutex_lock(&phydev->lock);
>>>>
>>>>          if (AUTONEG_DISABLE =3D=3D phydev->autoneg)
>>>>                  phy_sanitize_settings(phydev);
>>>>
>>>> So could someone please help me figure out what I'm missing here?
>>>
>>>
>>> At first glance it looks like the PHY driver should be reading the =
phydev-
>>>>
>>>> autoneg value when the PHY driver config_aneg() callback is called=
 to be
>>>
>>> allowed to set the forced speed and settings.
>>>
>>> The way phy_sanitize_settings() is coded does not make it return a =
mask of
>>> features, but only the forced supported speed and duplex. Then when=
 the
>>> link
>>> is forced but we are having some issues getting a link status, libp=
hy
>>> tries
>>> lower speeds and this function is used again to provide the next
>>> speed/duplex
>>> pair to try.
>>>
>>
>> What I was trying to say is that phy_sanitize_settings() is only cal=
led when
>> phydev->autoneg =3D=3D AUTONEG_DISABLE, and in turn it's the only ge=
neric
>> function setting phydev->autoneg =3D AUTONEG_DISABLE.
>> So perhaps the condition should read:
>>
>> -       if (AUTONEG_DISABLE =3D=3D phydev->autoneg)
>> +       if ((features & SUPPORTED_Autoneg) =3D=3D 0)
>>                  phy_sanitize_settings(phydev);
>>
>> Or else, some other parts of the generic code should take care of se=
tting it
>> to AUTONEG_DISABLE, depending on whether the feature is supported or=
 not.
>> What I found weird is explicitly setting a value (phydev->autoneg =3D
>> AUTONEG_DISABLE), from a static function which is only called when t=
hat
>> condition is already true.
>
> I do not think that this change is correct either, let me cook a patc=
h
> for you to allow disabling autoneg from the start.

Oh, OK, that would be great, thank you!
=46WIW, I've already spent quite some time trying to overcome this -- m=
y=20
understanding is that you somehow need to set phydev->autoneg to=20
AUTONEG_DISABLE at a very early stage (and that could of course be done=
=20
as a consequence of SUPPORTED_Autoneg being unset), otherwise the whole=
=20
software phy state machine and speed-matching algorithms will get confu=
sed.

>>
>> BTW, I feel like disabling autoneg from the start has never been a u=
se case
>> before, am I right?
>
> Not really no, and that is because most hardware does not need quirks
> to work correctly.

To be honest with you, I'm not long experienced on MII/PHY, but I've=20
already seen two completely unrelated cases where autoneg needs to be=20
disabled in order for the hardware to work correctly. Of course I'm onl=
y=20
talking about in-board connections (e.g. not PHYs connected to an RJ-45=
=20
jack), still...
In this particular hardware configuration, not only does autoneg need t=
o=20
be disabled in the first place (otherwise link won't work at all), but=20
the phy HW is also buggy so that when autoneg is disabled, it may still=
=20
occasionally not work (like 0.1% of the times).

Thank you so much!
Gerlando
