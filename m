From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH v2 2/4] net: ethoc: don't advertise gigabit speed on
 attached PHY
Date: Fri, 31 Jan 2014 10:07:06 +0400
Message-ID: <CAMo8BfKkZOhsXBXWXS5scc5zN6qQnvk51HOCxAJmDWW19wFM-Q@mail.gmail.com>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
	<1390975218-13863-3-git-send-email-jcmvbkbc@gmail.com>
	<52E8A407.1020809@gmail.com>
	<CAMo8BfJ_nce_H_8HJ7iw9ME=8C+sjF_Q43RaDG+1eVrpxWRvdQ@mail.gmail.com>
	<CAGVrzcboHp8-qHZseGOVm14u1-cTcOjRZGExFxNu_nbK__XCSA@mail.gmail.com>
	<CAMo8BfK-3-B-n7gxLaSO3JXSNNT_HwF0yTAMd+L5pp6odJKFTg@mail.gmail.com>
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
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:51679 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbaAaGHH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 01:07:07 -0500
In-Reply-To: <CAMo8BfK-3-B-n7gxLaSO3JXSNNT_HwF0yTAMd+L5pp6odJKFTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 29, 2014 at 10:32 PM, Max Filippov <jcmvbkbc@gmail.com> wro=
te:
> On Wed, Jan 29, 2014 at 9:12 PM, Florian Fainelli <f.fainelli@gmail.c=
om> wrote:
>> On Jan 28, 2014 11:01 PM, "Max Filippov" <jcmvbkbc@gmail.com> wrote:
>>>
>>> On Wed, Jan 29, 2014 at 10:47 AM, Florian Fainelli <f.fainelli@gmai=
l.com>
>>> wrote:
>>> > Hi Max,
>>> >
>>> > Le 28/01/2014 22:00, Max Filippov a =C3=A9crit :
>>> >
>>> >> OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbps=
, but
>>> >> does
>>> >> not disable advertisement when PHY supports them. This results i=
n
>>> >> non-functioning network when the MAC is connected to a gigabit P=
HY
>>> >> connected
>>> >> to a gigabit switch.
>>> >>
>>> >> The fix is to disable gigabit speed advertisement on attached PH=
Y
>>> >> unconditionally.
>>> >>
>>> >> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
>>> >> ---
>>> >> Changes v1->v2:
>>> >> - disable both gigabit advertisement and support.
>>> >>
>>> >>   drivers/net/ethernet/ethoc.c | 8 ++++++++
>>> >>   1 file changed, 8 insertions(+)
>>> >>
>>> >> diff --git a/drivers/net/ethernet/ethoc.c
>>> >> b/drivers/net/ethernet/ethoc.c
>>> >> index 4de8cfd..5643b2d 100644
>>> >> --- a/drivers/net/ethernet/ethoc.c
>>> >> +++ b/drivers/net/ethernet/ethoc.c
>>> >> @@ -688,6 +688,14 @@ static int ethoc_mdio_probe(struct net_devi=
ce
>>> >> *dev)
>>> >>         }
>>> >>
>>> >>         priv->phy =3D phy;
>>> >> +       phy_update_advert(phy,
>>> >> +                         ADVERTISED_1000baseT_Full |
>>> >> +                         ADVERTISED_1000baseT_Half, 0);
>>> >> +       phy_start_aneg(phy);
>>> >
>>> >
>>> > This does not look necessary, you should not have to call
>>> > phy_start_aneg()
>>> > because the PHY state machine is not yet started, at best this ca=
lls
>>> > does
>>> > nothing.
>>>
>>> This call actually makes the whole thing work, because otherwise on=
ce
>>> gigabit
>>> support is cleared from the supported mask genphy_config_advert doe=
s not
>>> update gigabit advertisement register, leaving it enabled.
>>
>> OK, then we need to figure out what is wrong with ethoc since this i=
s
>> unusual.
>
> Maybe they boot up with gigabit advertisement disabled in their PHY
> and thus they don't see the problem?
>
>> Other drivers do the following:
>>
>> - connect to the PHY
>> - phydev->supported =3D PHY_BASIC_FEATURES
>> - phydev->advertising &=3D phydev->supported
>> - start the PHY state machine
>>
>> And they work just fine. Is the PHY driver you are bound to the "Gen=
eric
>> PHY" or something else which does something funky in config_aneg()?
>
> It's marvell 88E1111 from the KC-705 board, but the behaviour doesn't
> change if I disable it and the generic phy is used.

=46lorian,

I don't see how the generic genphy_config_advert can ever change
gigabit advertisement if phydev->supported has gigabit speeds masked
off. So I'm pretty sure that other 10/100 cards would exhibit the same
issue if their PHY started with gigabit advertisement enabled. Maybe
we need to fix those other drivers? Or maybe we need to track what
PHY really supports vs. what we report it supports, so that gigabit
advertisement could be changed even when the PHY no longer
appears to support gigabit?

--=20
Thanks.
-- Max
