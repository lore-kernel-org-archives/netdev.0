From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 0/2] of: fsl/fman: reuse the fixed node parsing code
Date: Tue, 11 Aug 2015 19:58:48 +0300
Message-ID: <55CA29C8.5000707@list.ru>
References: <1438785745-15517-1-git-send-email-madalin.bucur@freescale.com>
 <55C63D3B.5020005@gmail.com> <55CA1C14.3000202@list.ru>
 <BL2PR03MB545D4E18DE41AE01AFC37D6E67F0@BL2PR03MB545.namprd03.prod.outlook.com>
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
In-Reply-To: <BL2PR03MB545D4E18DE41AE01AFC37D6E67F0@BL2PR03MB545.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

11.08.2015 19:33, Madalin-Cristian Bucur =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
> + Joakim, Shaohui
>
>> -----Original Message-----
>> From: Stas Sergeev [mailto:stsp@list.ru]
>>
>> 08.08.2015 20:32, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> CC'ing Stas,
>> Hi.
>>
>>> Le 08/05/15 07:42, Madalin Bucur a =C3=A9crit :
>>>> The FMan MAC configuration code needs the speed and duplex
>> information
>>>> for fixed-link interfaces that is parsed now by the of function
>>>> of_phy_register_fixed_link(). This parses the fixed-link parameter=
s but
>>>> does not expose to the caller neither the phy_device pointer nor t=
he
>>>> status struct where it loads the fixed-link params.
>> I have only barely touched that code, but IMO both things
>> are by design. There are some API deficiencies, and so, many
>> drivers still use of_phy_find_device() to circumvent the encapsulati=
on
>> and get the phy_device pointer, but this is unlikely a good thing
>> to do. I even proposed some API extensions, but there was no
>> interest.
>>
>>>>    By extracting the
>>>> fixed-link parsing code from of_phy_register_fixed_link() into a
>>>> separate function the parsed values are made available without cha=
nging
>>>> the existing API. This change also removes a small redundancy in t=
he
>>>> previous code calling fixed_phy_register().
>> Today, the fixed_link is not always fixed.
>> See for example this patch (already mainlined):
>> https://lkml.org/lkml/2015/7/20/711
>> of_phy_is_fixed_link() returns 'true' if you have
>> managed=3D"in-band-status", and so the SGMII in-band status
>> can update fixed-link params.
>>
>> So my question is: why do you even need to know whether
>> the link is fixed or not? IIRC you can check the phy_device
>> pointer in the adjust_link callback of of_phy_connect() to get
>> the current link status values. Why is this not enough for your
>> task? Maybe the patch description should be updated to include
>> why the current technique is bad, what is actually fixed by the
>> change.
>> I think using the fixed-link DT values directly is not something
>> to be done. The encapsulation is there for a reason, so maybe
>> instead we can see what API additions do we need to avoid the
>> current limitations that force people to use of_phy_find_device()
>> and other work-arounds.
> I need to be able to determine the imposed speed and duplex for fixed=
 link
> external PHYs because I need to configure the internal PHY with match=
ing
> values. If I do not set the same speed, given the fact that AN needs =
to be off,
> there will be no link and no adjust link to fix things later (and the=
 internal PHY is
> not updated by adjust link anyway). I do not have access at the phy p=
ointer at
> the time I need the speed and duplex, to retrieve the defaults from t=
here and
> I've tried to make the smallest changes that allow me to retrieve tho=
se without
> modifying existing API.
> Why is it important to hide the default values from the MAC driver?
My worry is that the fixed values are not really fixed, and
therefore are not always useful to access directly. It is likely
not a problem for your use-case, as, as you say, the AN is
disabled, but this is probably not the best to do in general.
And also you do:
---

-		err =3D of_phy_register_fixed_link(mac_node);
-		if (err)
+		struct phy_device *phy;
+
+		mac_dev->fixed_link =3D kzalloc(sizeof(*mac_dev->fixed_link),
+					      GFP_KERNEL);
+		if (of_phy_parse_fixed_link(mac_node, mac_dev->fixed_link))
+			goto _return_dev_set_drvdata;
+
+		phy =3D fixed_phy_register(PHY_POLL, mac_dev->fixed_link,
+					 mac_node);

---

which means you really want to circumvent the current OF
api quite a lot, without saying why in the patch description.
As such, it may be difficult to review. Could you please write
a more complete description to the patch?

As to your problem: would it be possible to set speed & duplex
after you do of_phy_connect()? It returns the phy_device
pointer, and perhaps you can look into phydev->speed and
phydev->duplex at that point?
