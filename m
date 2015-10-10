From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: switchdev and VLAN ranges
Date: Sat, 10 Oct 2015 12:36:26 +0200
Message-ID: <5618EA2A.3020900@cumulusnetworks.com>
References: <493168159.229458.1444433451493.JavaMail.zimbra@savoirfairelinux.com>
 <BF3B1B92-E7B5-4C49-9B56-FBD36E546F28@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ido Schimmel <idosch@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Elad Raz <eladr@mellanox.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33819 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbbJJKgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 06:36:31 -0400
Received: by wicfx3 with SMTP id fx3so99350248wic.1
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 03:36:29 -0700 (PDT)
In-Reply-To: <BF3B1B92-E7B5-4C49-9B56-FBD36E546F28@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2015 09:49 AM, Elad Raz wrote:
>=20
>> On Oct 10, 2015, at 2:30 AM, Vivien Didelot <vivien.didelot@savoirfa=
irelinux.com> wrote:
>>
>> I have two concerns in mind:
>>
>> a) if we imagine that drivers like Rocker allocate memory in the pre=
pare
>> phase for each VID, preparing a range like 100-4000 would definitely=
 not
>> be recommended.
>>
>> b) imagine that you have two Linux bridges on a switch, one using th=
e
>> hardware VLAN 100. If you request the VLAN range 99-101 for the othe=
r
>> bridge members, it is not possible for the driver to say "I can
>> accelerate VLAN 99 and 101, but not 100". It must return OPNOTSUPP f=
or
>> the whole range.
>=20
> Another concern I have with vid_being..vid_end range is the =E2=80=9C=
flags=E2=80=9D. Where flags can be BRIDGE_VLAN_INFO_PVID.
> There is no sense having more than one VLAN as a PVID.
> This leave the HW vendor the choice which VLAN id they will use as th=
e PVID.
>=20

iproute2 doesn't allow to do it but I can see that someone can actually=
 make it
so the flags for the range have it and it doesn't look correct. Perhaps=
 we need
something like the patch below to enforce this from kernel-side.


diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index d78b4429505a..02b17b53e9a6 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -524,6 +524,9 @@ static int br_afspec(struct net_bridge *br,
 			if (vinfo_start)
 				return -EINVAL;
 			vinfo_start =3D vinfo;
+			/* don't allow range of pvids */
+			if (vinfo_start->flags & BRIDGE_VLAN_INFO_PVID)
+				return -EINVAL;
 			continue;
 		}
=20
