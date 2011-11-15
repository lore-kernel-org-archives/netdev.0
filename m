From: Simon Chen <simonchennj@gmail.com>
Subject: Re: bonding xmit_policy
Date: Tue, 15 Nov 2011 01:20:36 -0500
Message-ID: <CANj2EbfM+5+AFYkU+erMZBtf0cCXkoDGRrXLGQFHYVL_6qvWFw@mail.gmail.com>
References: <CANj2Ebfj+7R+wCK7jJennBN7_6THJGqs8FWSAPOv7BYYsR=u9w@mail.gmail.com>
	<4EC0280A.3060100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65349 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120Ab1KOGUh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 01:20:37 -0500
Received: by mail-fx0-f46.google.com with SMTP id n18so71878fag.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 22:20:37 -0800 (PST)
In-Reply-To: <4EC0280A.3060100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, my bad.

It is pretty strange that when I use 802.3ad mode, all my packets
(from different TCP flows) egress the same NIC even though I choose
xmit_policy to be layer3+4. That's why I wasn't quite sure whether the
policy is indeed in place.

When I switch to balance-xor mode, the packets are roughly evenly
distributed across two NICs.

-Simon

On Sun, Nov 13, 2011 at 3:26 PM, Nicolas de Peslo=FCan
<nicolas.2p.debian@gmail.com> wrote:
> Le 13/11/2011 03:55, Simon Chen a =E9crit :
>>
>> Hi folks,
>>
>> It looks like that there are three entries in xmit_policy (hashing f=
or
>> deciding egress phy int) for bonded interfaces:
>>
>> const struct bond_parm_tbl xmit_hashtype_tbl[] =3D {
>> { =A0 =A0 =A0 "layer2", =A0 =A0 =A0 =A0 =A0 =A0 =A0 BOND_XMIT_POLICY=
_LAYER2},
>> { =A0 =A0 =A0 "layer3+4", =A0 =A0 =A0 =A0 =A0 =A0 BOND_XMIT_POLICY_L=
AYER34},
>> { =A0 =A0 =A0 "layer2+3", =A0 =A0 =A0 =A0 =A0 =A0 BOND_XMIT_POLICY_L=
AYER23},
>> { =A0 =A0 =A0 NULL, =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 -1},
>> };
>>
>>
>> We can set the xmit_policy either at module initiation, or later via
>> /sys. However, this xmit_policy isn't really read anywhere. Are
>> different policies really implemented?
>
> The table is used in two different locations:
>
> In drivers/net/bonding/bond_main.c:
>
> =A0 =A0 =A0 =A0xmit_hashtype =3D bond_parse_parm(xmit_hash_policy, xm=
it_hashtype_tbl);
> =A0 =A0 =A0 =A0[...]
> =A0 =A0 =A0 =A0params->xmit_policy =3D xmit_hashtype;
>
> In drivers/net/bonding/bond_sysfs.c:
>
> =A0 =A0 =A0 =A0new_value =3D bond_parse_parm(buf, xmit_hashtype_tbl);
> =A0 =A0 =A0 =A0[...]
> =A0 =A0 =A0 =A0bonds->params.xmit_policy =3D new_value;
>
> Then, in drivers/net/bonding/bond_main.c, the value in
> bonds->params.xmit_policy is used to setup a callback into
> bond->xmit_hash_policy.
>
> =A0 =A0 =A0 =A0static void bond_set_xmit_hash_policy(struct bonding *=
bond)
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (bond->params.xmit_policy) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BOND_XMIT_POLICY_LAYER23:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bond->xmit_hash_policy=
 =3D bond_xmit_hash_policy_l23;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BOND_XMIT_POLICY_LAYER34:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bond->xmit_hash_policy=
 =3D bond_xmit_hash_policy_l34;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BOND_XMIT_POLICY_LAYER2:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bond->xmit_hash_policy=
 =3D bond_xmit_hash_policy_l2;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> Then, in drivers/net/bonding/bond_3ad.c and in
> drivers/net/bonding/bond_main.c, the callback is used to select a sla=
ve for
> xmit, for the two modes where xmit_hash_policy have a meaning:
>
> =A0 =A0 =A0 =A0slave_agg_no =3D bond->xmit_hash_policy(skb, slaves_in=
_agg);
>
> =A0 =A0 =A0 =A0slave_no =3D bond->xmit_hash_policy(skb, bond->slave_c=
nt);
>
>
> So, yes, those policies are really implemented.
>
> =A0 =A0 =A0 =A0Nicolas.
>
