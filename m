From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: Re: [PATCH 4/4] ipv4: mark nexthop as dead when it's subnet becomes unreachable
Date: Thu, 23 Jan 2014 17:05:27 +0200
Message-ID: <2208170.gq1LW14mJ5@tuxracer>
References: <cover.1390304505.git.popovich_sergei@mail.ru> <40044b636dbf7ae5bba5fe2873451e14438ec170.1390304505.git.popovich_sergei@mail.ru> <alpine.LFD.2.11.1401231158510.2682@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback2.mail.ru ([94.100.176.87]:42381 "EHLO
	fallback2.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497AbaAWPIQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 10:08:16 -0500
Received: from smtp37.i.mail.ru (smtp37.i.mail.ru [94.100.177.97])
	by fallback2.mail.ru (mPOP.Fallback_MX) with ESMTP id 17843FC68254
	for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 19:05:43 +0400 (MSK)
Received: from [2a01:6d80:103:13::c3ea:4404] (port=47837 helo=tuxracer.localnet)
	by smtp37.i.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1W6LqV-0003fe-1s
	for netdev@vger.kernel.org; Thu, 23 Jan 2014 19:05:31 +0400
In-Reply-To: <alpine.LFD.2.11.1401231158510.2682@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D0=BF=D0=B8=D1=81=D1=8C=D0=BC=D0=B5 =D0=BE=D1=82 23 =D1=8F=D0=BD=
=D0=B2=D0=B0=D1=80=D1=8F 2014 12:06:30 =D0=BF=D0=BE=D0=BB=D1=8C=D0=B7=D0=
=BE=D0=B2=D0=B0=D1=82=D0=B5=D0=BB=D1=8C Julian Anastasov =D0=BD=D0=B0=D0=
=BF=D0=B8=D1=81=D0=B0=D0=BB:
> 	Hello,
>=20
> On Tue, 21 Jan 2014, Sergey Popovich wrote:
> > +			if (nexthop_nh->nh_dev !=3D dev ||
> > +			    nexthop_nh->nh_scope =3D=3D scope ||
> > +			    (ifa && !inet_ifa_match(nexthop_nh->nh_gw, ifa)))
>=20
> 	What if nh_gw is part from another smaller/larger subnet?
> For example, what if we still have 10.0.0.200/8 ? 10.0.10.5 is
> still reachable, i.e. fib_check_nh() would create such NH.


Please correct me if I dont understand something:

1. fib_sync_down_dev() is used when interface is going down
to remove entires with stray nexthops (including multipath routes).

2. It takes as its argument device on which event (DOWN for short) is r=
eceived
and force argument to force fib info entry deletion (which is true when
fib_sync_down_dev() called from fib_disable_ip() with 2 on UNREGISTER e=
vent.

Case, that patch is tries to address happens when we have two
or more addresses on interface, and NH exists in one of such subnet.

With two or more address on iface, fib_disable_ip() is not called on si=
ngle=20
address removal, so fib_sync_down_dev() also not called, and we end wit=
h=20
routes with stray nexthop.

There is no problem with single address and NH in its subnet, as=20
fib_sync_down_dev() called from fib_disable_ip().

When deleting IP address, we have net_device where address deleted
and deleted ifa entry.

Only thing that I miss is RTNH_F_ONLINK NH flag, should be consulted
before marking nexthop as dead. I will fix this in v2.


> IMHO, marking NH by exact nh_gw looks more acceptable because
> the exact GW becomes unreachable. Otherwise, you will need
> fib_lookup() as in fib_check_nh() to check that NH becomes
> unreachable.

Not sure that I fully understand you.

When deleting address and removing its subnet, instead of removing rout=
e from=20
the FIB, resolve new NH with fib_lookup() if possible, as this done in=20
fib_check_nh(), and leave route with modified NH?

Well, sounds good, but what to do with multipath routes?
Is this correct at all?

Thanks revieving my patches.

>=20
> Regards
>=20
> --
> Julian Anastasov <ja@ssi.bg>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
SP5474-RIPE
Sergey Popovich
