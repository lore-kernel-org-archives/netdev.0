From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/4] net: ethoc: don't advertise gigabit speed on
 attached PHY
Date: Fri, 31 Jan 2014 16:40:06 -0800
Message-ID: <CAGVrzcaN=noWOoMj0w720H5TUBypOv2HAFPPzJRAfA=R4RLUmw@mail.gmail.com>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
 <1390975218-13863-3-git-send-email-jcmvbkbc@gmail.com> <52E8A407.1020809@gmail.com>
 <CAMo8BfJ_nce_H_8HJ7iw9ME=8C+sjF_Q43RaDG+1eVrpxWRvdQ@mail.gmail.com>
 <CAGVrzcboHp8-qHZseGOVm14u1-cTcOjRZGExFxNu_nbK__XCSA@mail.gmail.com>
 <CAMo8BfK-3-B-n7gxLaSO3JXSNNT_HwF0yTAMd+L5pp6odJKFTg@mail.gmail.com> <CAMo8BfKkZOhsXBXWXS5scc5zN6qQnvk51HOCxAJmDWW19wFM-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Gauthier <marc@cadence.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Chris Zankel <chris@zankel.net>,
	"linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>,
	netdev <netdev@vger.kernel.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMo8BfKkZOhsXBXWXS5scc5zN6qQnvk51HOCxAJmDWW19wFM-Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-01-30 Max Filippov <jcmvbkbc@gmail.com>:
> On Wed, Jan 29, 2014 at 10:32 PM, Max Filippov <jcmvbkbc@gmail.com> w=
rote:
>> On Wed, Jan 29, 2014 at 9:12 PM, Florian Fainelli <f.fainelli@gmail.=
com> wrote:
>>> On Jan 28, 2014 11:01 PM, "Max Filippov" <jcmvbkbc@gmail.com> wrote=
:
>>>>
>>>> On Wed, Jan 29, 2014 at 10:47 AM, Florian Fainelli <f.fainelli@gma=
il.com>
>>>> wrote:
>>>> > Hi Max,
>>>> >
>>>> > Le 28/01/2014 22:00, Max Filippov a =C3=A9crit :
>>>> >
>>>> >> OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbp=
s, but
>>>> >> does
>>>> >> not disable advertisement when PHY supports them. This results =
in
>>>> >> non-functioning network when the MAC is connected to a gigabit =
PHY
>>>> >> connected
>>>> >> to a gigabit switch.
>>>> >>
>>>> >> The fix is to disable gigabit speed advertisement on attached P=
HY
>>>> >> unconditionally.
>>>> >>
>>>> >> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
>>>> >> ---
>>>> >> Changes v1->v2:
>>>> >> - disable both gigabit advertisement and support.
>>>> >>
>>>> >>   drivers/net/ethernet/ethoc.c | 8 ++++++++
>>>> >>   1 file changed, 8 insertions(+)
>>>> >>
>>>> >> diff --git a/drivers/net/ethernet/ethoc.c
>>>> >> b/drivers/net/ethernet/ethoc.c
>>>> >> index 4de8cfd..5643b2d 100644
>>>> >> --- a/drivers/net/ethernet/ethoc.c
>>>> >> +++ b/drivers/net/ethernet/ethoc.c
>>>> >> @@ -688,6 +688,14 @@ static int ethoc_mdio_probe(struct net_dev=
ice
>>>> >> *dev)
>>>> >>         }
>>>> >>
>>>> >>         priv->phy =3D phy;
>>>> >> +       phy_update_advert(phy,
>>>> >> +                         ADVERTISED_1000baseT_Full |
>>>> >> +                         ADVERTISED_1000baseT_Half, 0);
>>>> >> +       phy_start_aneg(phy);
>>>> >
>>>> >
>>>> > This does not look necessary, you should not have to call
>>>> > phy_start_aneg()
>>>> > because the PHY state machine is not yet started, at best this c=
alls
>>>> > does
>>>> > nothing.
>>>>
>>>> This call actually makes the whole thing work, because otherwise o=
nce
>>>> gigabit
>>>> support is cleared from the supported mask genphy_config_advert do=
es not
>>>> update gigabit advertisement register, leaving it enabled.
>>>
>>> OK, then we need to figure out what is wrong with ethoc since this =
is
>>> unusual.
>>
>> Maybe they boot up with gigabit advertisement disabled in their PHY
>> and thus they don't see the problem?
>>
>>> Other drivers do the following:
>>>
>>> - connect to the PHY
>>> - phydev->supported =3D PHY_BASIC_FEATURES
>>> - phydev->advertising &=3D phydev->supported
>>> - start the PHY state machine
>>>
>>> And they work just fine. Is the PHY driver you are bound to the "Ge=
neric
>>> PHY" or something else which does something funky in config_aneg()?
>>
>> It's marvell 88E1111 from the KC-705 board, but the behaviour doesn'=
t
>> change if I disable it and the generic phy is used.
>
> Florian,
>
> I don't see how the generic genphy_config_advert can ever change
> gigabit advertisement if phydev->supported has gigabit speeds masked
> off.

It does not, but it makes sure that phydev->advertising gets masked
with phydev->supported. So, prior to starting your PHY state machine,
if you do:

phydev->supported &=3D PHY_BASIC_FEATURES;
phydev->advertising =3D phydev->supported;

you should get the expected results. Just make sure that
phydev->autoneg is not set to AUTONEG_DISABLE, otherwise
phy_start_aneg() will not call phy_sanitize_settings(), and this might
be the problem.

> So I'm pretty sure that other 10/100 cards would exhibit the same
> issue if their PHY started with gigabit advertisement enabled.

If the speed is not restricted, yes that will be the case, but most
drivers seem to correctly set both phydev->supported and
phydev->advertising.

> Maybe
> we need to fix those other drivers? Or maybe we need to track what
> PHY really supports vs. what we report it supports, so that gigabit
> advertisement could be changed even when the PHY no longer
> appears to support gigabit?

This is supposedly already taken care of provided that you correctly
restrict the PHY supported/advertising bits with respect to what the
HW really supports.
--=20
=46lorian
