From: Stas Sergeev <stsp-cmBhpYW9OiY@public.gmane.org>
Subject: Re: [PATCH 0/2] of: fsl/fman: reuse the fixed node parsing code
Date: Wed, 12 Aug 2015 19:03:01 +0300
Message-ID: <55CB6E35.4020808@list.ru>
References: <1438785745-15517-1-git-send-email-madalin.bucur@freescale.com>
 <55C63D3B.5020005@gmail.com> <55CA1C14.3000202@list.ru>
 <BL2PR03MB545D4E18DE41AE01AFC37D6E67F0@BL2PR03MB545.namprd03.prod.outlook.com>
 <55CA29C8.5000707@list.ru>
 <BL2PR03MB545929237EF33BA13089EC1E67E0@BL2PR03MB545.namprd03.prod.outlook.com>
 <55CB50F1.7050308@list.ru>
 <BL2PR03MB5458B9D2402DE68E9B9014AE67E0@BL2PR03MB545.namprd03.prod.outlook.com>
 <55CB61BC.1050209@list.ru>
 <BL2PR03MB545A213D584384018CCB30CE67E0@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liberman Igal <Igal.Liberman-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Stas Sergeev <stsp-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"joakim.tjernlund-SNLAxHN9vbcOP4wsBPIw7w@public.gmane.org" <joakim.tjernlund-SNLAxHN9vbcOP4wsBPIw7w@public.gmane.org>,
	Shaohui Xie <Shaohui.Xie-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Madalin-Cristian Bucur <madalin.bucur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BL2PR03MB545A213D584384018CCB30CE67E0-AZ66ij2kwaa1tTsckATbNOO6mTEJWrR4XA4E9RH9d+qIuWR1G4zioA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

12.08.2015 18:27, Madalin-Cristian Bucur =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>> Then I could call only of_* functions but the end result would be t=
he same
>>> and  of_phy_register_fixed_phy() would not justify its existence th=
at much...
>> You didn't say you wanted to obsolete the of_phy_register_fixed_phy(=
).
>> Since it is there (and even changed by me in a way your
>> patch will likely clash), IMHO it would be better if it is used,
>> rather than copy/pasted into the driver.
> Please note I was referring to a fictional new function that would em=
bed the call to
> fixed_phy_register(). I was not talking about some existing API, just=
 about a new
> of_call  named of_phy_register_fixed_phy()  that would in the end be =
called by
> of_phy_register_fixed_link() and by some drivers that want to get in =
the middle
> of things and get a hold on status.
Hmm, and for exactly unknown reason in your pseudocode
of_phy_register_fixed_phy() doesn't take status as an argument. :)
So I didn't see its point.
If you fix your pseudo-code, you'll add the status argument,
because it is needed for fixed_phy_register() anyway.
After that, the drivers that want to provide the status, will
just use it rather than to call fixed_phy_register() directly.
And with my changes it really have even more merits to exist.

> Maybe the fact we're reviewing two patches in one thread is what make=
s the
> discussion less than optimal.
I guess the bugs in the pseudo-code made me to miss its point.

>>> The getter for status you suggest would be fine, but not sure how o=
ne
>>> would retrieve
>>> it from the mac_node unless we change of_phy_register_fixed_link() =
to
>>> return the
>>> pointer to phy (and all the drivers that use it...).
>> If you look for instance to mvneta.c, you'll find the following:
>> ---
>> err =3D of_phy_register_fixed_link(dn);
>> /* In the case of a fixed PHY, the DT node associated
>>    * to the PHY is the Ethernet MAC DT node.
>>    */
>>    phy_node =3D of_node_get(dn);
>> ...
>> phy =3D of_phy_find_device(dn);
>> ---
>>
>> So the answer is: just use the same mac_node for both.
> I understand, I'll use this approach although is suboptimal imho to
Exactly!
But at least this way is used in many currently existing
drivers, while getting the fixed-link parameters directly from
DT - is a new way of circumventing the existing API.
So I'd vote for the currently existing hacks, and in fact
I already tried to start a discussion about getting rid of the
need for of_phy_find_device(), but it didn't go.

> scan the device tree again to get a phy pointer that you need just
> to get some of info that was parsed in a call you just made.
Maybe (just maybe) of_phy_register_fixed_link() could
return the phy_device pointer. At least it will solve your
problem very cheaply. But I am sure such API additions
require a separate discussion, can't be done in a context
of discussing a small fix. If you have some free time, feel
free to raise such a discussion with API extension proposals.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
