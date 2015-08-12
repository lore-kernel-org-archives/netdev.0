From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 0/2] of: fsl/fman: reuse the fixed node parsing code
Date: Wed, 12 Aug 2015 18:09:48 +0300
Message-ID: <55CB61BC.1050209@list.ru>
References: <1438785745-15517-1-git-send-email-madalin.bucur@freescale.com>
 <55C63D3B.5020005@gmail.com> <55CA1C14.3000202@list.ru>
 <BL2PR03MB545D4E18DE41AE01AFC37D6E67F0@BL2PR03MB545.namprd03.prod.outlook.com>
 <55CA29C8.5000707@list.ru>
 <BL2PR03MB545929237EF33BA13089EC1E67E0@BL2PR03MB545.namprd03.prod.outlook.com>
 <55CB50F1.7050308@list.ru>
 <BL2PR03MB5458B9D2402DE68E9B9014AE67E0@BL2PR03MB545.namprd03.prod.outlook.com>
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
In-Reply-To: <BL2PR03MB5458B9D2402DE68E9B9014AE67E0@BL2PR03MB545.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

12.08.2015 17:43, Madalin-Cristian Bucur =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>> -----Original Message-----
>> From: Stas Sergeev [mailto:stsp@list.ru]
>>
>> 12.08.2015 16:26, Madalin-Cristian Bucur =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
>>>>> I've tried to make the smallest changes that allow me to retrieve=
 those
>>>>> without modifying existing API.
>>>>> Why is it important to hide the default values from the MAC drive=
r?
>>>> My worry is that the fixed values are not really fixed, and
>>>> therefore are not always useful to access directly. It is likely
>>>> not a problem for your use-case, as, as you say, the AN is
>>>> disabled, but this is probably not the best to do in general.
>>> Yes, not a problem in my case.
>>>
>>>> And also you do:
>>>> ---
>>>>
>>>> -		err =3D of_phy_register_fixed_link(mac_node);
>>>> -		if (err)
>>>> +		struct phy_device *phy;
>>>> +
>>>> +		mac_dev->fixed_link =3D kzalloc(sizeof(*mac_dev-
>>>>> fixed_link),
>>>> +					      GFP_KERNEL);
>>>> +		if (of_phy_parse_fixed_link(mac_node, mac_dev-
>>>>> fixed_link))
>>>> +			goto _return_dev_set_drvdata;
>>>> +
>>>> +		phy =3D fixed_phy_register(PHY_POLL, mac_dev->fixed_link,
>>>> +					 mac_node);
>>>>
>>>> ---
>>>>
>>>> which means you really want to circumvent the current OF
>>>> api quite a lot, without saying why in the patch description.
>>> I circumvent the API because I din not want to change existing API.
>>> If I could get a reference to the status struct without changing an=
y code
>>> or without being required to call by myself fixed_phy_register(), I
>>> would of done that. Given the existing code in
>> of_phy_register_fixed_link(),
>>> this was my only option. I could have broken of_phy_register_fixed_=
link()
>>> in two functions:
>>>
>>> of_phy_parse_fixed_link() and of_phy_register_fixed_link(), the lat=
ter
>> doing only
>>> the call to fixed_phy_register()
>>>
>>> that would allow to keep of_phy_register_fixed_link() as it is, bro=
ken in
>> two stages:
>>> - parsing
>>> - registering
>>>
>>> than can be used by other drivers in order to get the status but I =
think it's
>> overkill.
>> What I referred to as "circumventing an API" is that you do
>> phy =3D fixed_phy_register(PHY_POLL, mac_dev->fixed_link, + mac_node=
);
>> by hands, instead of letting the of_phy_register_fixed_link() doing =
so.
>>
>> How about a smaller circumvention, like this for instance:
>> ---
>> err =3D of_phy_register_fixed_link(mac_node);
>> phy =3D of_phy_find_device(dn);
>> status =3D fixed_phy_get_link_status(phy);    // no such func, to be=
 coded up
>> ---
>>
>> Or even like this:
>> ---
>> err =3D of_phy_register_fixed_link(mac_node);
>> phy =3D of_phy_find_device(dn);
>> set_speed_and_duplex(phy->speed, phy->duplex);    // not sure if the=
se
>> values are available that early
>> ---
> After my patch, all that of_phy_register_fixed_link() does is to call
> the new parsing function I introduced then register the fixed PHY.
> I could have done this (pseudocode):
>
> - add of_phy_parse_fixed_link() as seen in the patch
> - add of_phy_register_fixed_phy() that just calls fixed_phy_register(=
):
>
> int of_phy_register_fixed_phy(node)
> {
> 	phy =3D fixed_phy_register(PHY_POLL, mac_dev->fixed_link,
> 				     mac_node);
> 	return (!phy);
> }
>
> - change of_phy_register_fixed_link() to contain only this:
>
> int of_phy_register_fixed_link(node)
> {
> 	of_phy_parse_fixed_link(node, &status);
>
> 	return of_phy_register_fixed_phy(node);
> }
But have you looked into the patch I pointed previously?
https://lkml.org/lkml/2015/7/20/711
You code will likely clash with it because my patch extends
of_phy_register_fixed_link().

> Then I could call only of_* functions but the end result would be the=
 same and
> of_phy_register_fixed_phy() would not justify its existence that much=
=2E..
You didn't say you wanted to obsolete the of_phy_register_fixed_phy().
Since it is there (and even changed by me in a way your
patch will likely clash), IMHO it would be better if it is used,
rather than copy/pasted into the driver.

> The getter for status you suggest would be fine, but not sure how one=
 would retrieve
> it from the mac_node unless we change of_phy_register_fixed_link() to=
 return the
> pointer to phy (and all the drivers that use it...).
If you look for instance to mvneta.c, you'll find the following:
---
err =3D of_phy_register_fixed_link(dn);
/* In the case of a fixed PHY, the DT node associated
  * to the PHY is the Ethernet MAC DT node.
  */
  phy_node =3D of_node_get(dn);
=2E..
phy =3D of_phy_find_device(dn);
---

So the answer is: just use the same mac_node for both.

>> Also I meant the description should have been in the patch,
>> not in the e-mail. :) You only wrote _what_ the patch does
>> (which is of course obvious from the code itself), but not
>> _why_ and _what was fixed_ (what didn't work).
>>
> If you refer to the first, separation patch, I thought the descriptio=
n was enough:
>
>      of: separate fixed link parsing from registration
>     =20
>      Some drivers may need
"may need"? I don't understand.
If it is a fix, then they _do need_, and in this case it should
be specified what was broken and what is fixed.
If it is just a clean-up, then "may need" may suffice, but it
was not mentioned it is a clean-up. So I still don't know what
this patch is all about.
"Some drivers" - which ones? The ones that are limited to
the purely fixed links, and never support AN or MDIO?
Or some other drivers too?
So really, the description sounds very cryptic to me.

>   to parse the fixed link values before registering
>      the fixed link phy. Separate the parsing from the actual registr=
ation
>      and provide an export for the added parsing function.
>     =20
>      Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
>
> For this one it was a bit brief, I admit - the longer version would b=
e that before it
> we were not using from fixed link anything else but the fact the link=
 was fixed
> (ignored actual speed, duplex values there)
And what didn't work as the result?

>   and this patch tries to fix that.
What started to work after that patch that didn't without it?
