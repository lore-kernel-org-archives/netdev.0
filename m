From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: bonding xmit_policy
Date: Sun, 13 Nov 2011 21:26:50 +0100
Message-ID: <4EC0280A.3060100@gmail.com>
References: <CANj2Ebfj+7R+wCK7jJennBN7_6THJGqs8FWSAPOv7BYYsR=u9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:39331 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab1KMU0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 15:26:52 -0500
Received: by wwi18 with SMTP id 18so4056035wwi.1
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2011 12:26:51 -0800 (PST)
In-Reply-To: <CANj2Ebfj+7R+wCK7jJennBN7_6THJGqs8FWSAPOv7BYYsR=u9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/11/2011 03:55, Simon Chen a =E9crit :
> Hi folks,
>
> It looks like that there are three entries in xmit_policy (hashing fo=
r
> deciding egress phy int) for bonded interfaces:
>
> const struct bond_parm_tbl xmit_hashtype_tbl[] =3D {
> {       "layer2",               BOND_XMIT_POLICY_LAYER2},
> {       "layer3+4",             BOND_XMIT_POLICY_LAYER34},
> {       "layer2+3",             BOND_XMIT_POLICY_LAYER23},
> {       NULL,                   -1},
> };
>
>
> We can set the xmit_policy either at module initiation, or later via
> /sys. However, this xmit_policy isn't really read anywhere. Are
> different policies really implemented?

The table is used in two different locations:

In drivers/net/bonding/bond_main.c:

	xmit_hashtype =3D bond_parse_parm(xmit_hash_policy, xmit_hashtype_tbl)=
;
	[...]
	params->xmit_policy =3D xmit_hashtype;

In drivers/net/bonding/bond_sysfs.c:

	new_value =3D bond_parse_parm(buf, xmit_hashtype_tbl);
	[...]
	bonds->params.xmit_policy =3D new_value;

Then, in drivers/net/bonding/bond_main.c, the value in bonds->params.xm=
it_policy is used to setup a=20
callback into bond->xmit_hash_policy.

	static void bond_set_xmit_hash_policy(struct bonding *bond)
	{
	        switch (bond->params.xmit_policy) {
	        case BOND_XMIT_POLICY_LAYER23:
	                bond->xmit_hash_policy =3D bond_xmit_hash_policy_l23;
	                break;
	        case BOND_XMIT_POLICY_LAYER34:
	                bond->xmit_hash_policy =3D bond_xmit_hash_policy_l34;
	                break;
	        case BOND_XMIT_POLICY_LAYER2:
         	default:
	                bond->xmit_hash_policy =3D bond_xmit_hash_policy_l2;
	                break;
	        }
	}

Then, in drivers/net/bonding/bond_3ad.c and in drivers/net/bonding/bond=
_main.c, the callback is used=20
to select a slave for xmit, for the two modes where xmit_hash_policy ha=
ve a meaning:

         slave_agg_no =3D bond->xmit_hash_policy(skb, slaves_in_agg);

         slave_no =3D bond->xmit_hash_policy(skb, bond->slave_cnt);


So, yes, those policies are really implemented.

	Nicolas.
