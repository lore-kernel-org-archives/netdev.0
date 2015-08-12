From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 0/2] of: fsl/fman: reuse the fixed node parsing code
Date: Wed, 12 Aug 2015 16:58:09 +0300
Message-ID: <55CB50F1.7050308@list.ru>
References: <1438785745-15517-1-git-send-email-madalin.bucur@freescale.com>
 <55C63D3B.5020005@gmail.com> <55CA1C14.3000202@list.ru>
 <BL2PR03MB545D4E18DE41AE01AFC37D6E67F0@BL2PR03MB545.namprd03.prod.outlook.com>
 <55CA29C8.5000707@list.ru>
 <BL2PR03MB545929237EF33BA13089EC1E67E0@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Liberman Igal <Igal.Liberman@freescale.com>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	"joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BL2PR03MB545929237EF33BA13089EC1E67E0@BL2PR03MB545.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

12.08.2015 16:26, Madalin-Cristian Bucur =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>> I've tried to make the smallest changes that allow me to retrieve t=
hose
>>> without modifying existing API.
>>> Why is it important to hide the default values from the MAC driver?
>> My worry is that the fixed values are not really fixed, and
>> therefore are not always useful to access directly. It is likely
>> not a problem for your use-case, as, as you say, the AN is
>> disabled, but this is probably not the best to do in general.
> Yes, not a problem in my case.
>
>> And also you do:
>> ---
>>
>> -		err =3D of_phy_register_fixed_link(mac_node);
>> -		if (err)
>> +		struct phy_device *phy;
>> +
>> +		mac_dev->fixed_link =3D kzalloc(sizeof(*mac_dev-
>>> fixed_link),
>> +					      GFP_KERNEL);
>> +		if (of_phy_parse_fixed_link(mac_node, mac_dev-
>>> fixed_link))
>> +			goto _return_dev_set_drvdata;
>> +
>> +		phy =3D fixed_phy_register(PHY_POLL, mac_dev->fixed_link,
>> +					 mac_node);
>>
>> ---
>>
>> which means you really want to circumvent the current OF
>> api quite a lot, without saying why in the patch description.
> I circumvent the API because I din not want to change existing API.
> If I could get a reference to the status struct without changing any =
code
> or without being required to call by myself fixed_phy_register(), I
> would of done that. Given the existing code in of_phy_register_fixed_=
link(),
> this was my only option. I could have broken of_phy_register_fixed_li=
nk()
> in two functions:
>
> of_phy_parse_fixed_link() and of_phy_register_fixed_link(), the latte=
r doing only
> the call to fixed_phy_register()
>
> that would allow to keep of_phy_register_fixed_link() as it is, broke=
n in two stages:
>
> - parsing
> - registering
>
> than can be used by other drivers in order to get the status but I th=
ink it's overkill.
What I referred to as "circumventing an API" is that you do
phy =3D fixed_phy_register(PHY_POLL, mac_dev->fixed_link, + mac_node);
by hands, instead of letting the of_phy_register_fixed_link() doing so.

How about a smaller circumvention, like this for instance:
---
err =3D of_phy_register_fixed_link(mac_node);
phy =3D of_phy_find_device(dn);
status =3D fixed_phy_get_link_status(phy);    // no such func, to be co=
ded up
---

Or even like this:
---
err =3D of_phy_register_fixed_link(mac_node);
phy =3D of_phy_find_device(dn);
set_speed_and_duplex(phy->speed, phy->duplex);    // not sure if these=20
values are available that early
---

Also I meant the description should have been in the patch,
not in the e-mail. :) You only wrote _what_ the patch does
(which is of course obvious from the code itself), but not
_why_ and _what was fixed_ (what didn't work).

>> As to your problem: would it be possible to set speed & duplex
>> after you do of_phy_connect()? It returns the phy_device
>> pointer, and perhaps you can look into phydev->speed and
>> phydev->duplex at that point?
> It would be possible but un-natural as I'd have probing information o=
nly available at
> runtime.
This is un-natural only if you deal just with a fixed case.
If your driver can deal also with the non-fixed cases
(either AN or MDIO), then this looks more natural as the
non-fixed management should be done at any point of time,
and certainly _after_ of_phy_connect(). So if your driver is
universal, this look like the natural choise to me, but if it is
limited to the fixed case, then, as a simplification, you move
that to the init time.
But I am not argueing what is more natural. Maybe the
above approaches with of_phy_find_device() can be used
in init time?

>   That would just complicate matters for my particular case ans I sus=
pect there
> will be other drivers that get into this situation.
I suspect only those that are limited to the fixed-link case.
Only then they may decide to move phy management to
init time, but IMHO this is just an optimization.

>   You are concerned about people
> abusing this API to read fixed link status when the link is not reall=
y fixed, I'm concerned
> about declaring the link as fixed-link when it's not. Maybe the namin=
g/binding needs to be
> revised to cover the case when all is fixed but the link.
Yes, naming is the problem. fixed-link is just a bad name.
See how it is defined:
---
Some Ethernet MACs have a "fixed link", and are not connected to a
normal MDIO-managed PHY device.
---
To me this means any non-MDIO PHY connection, but
unfortunately the name "fixed-link" suggests a bit more
than advertised. :(
