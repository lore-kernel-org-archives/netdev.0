From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: why does there need to lock?
Date: Mon, 22 Mar 2010 09:05:26 +0100
Message-ID: <1269245126.3029.3.camel@edumazet-laptop>
References: <ffe582101003211741v59da3c56yaffdaa151a6821be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?=E6=9D=A8=E7=A1=95?= <shanqn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:37831 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815Ab0CVIFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 04:05:30 -0400
Received: by bwz3 with SMTP id 3so5105240bwz.29
        for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 01:05:28 -0700 (PDT)
In-Reply-To: <ffe582101003211741v59da3c56yaffdaa151a6821be@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 mars 2010 =C3=A0 08:41 +0800, =E6=9D=A8=E7=A1=95 a =C3=A9cr=
it :
> Hi, i'm confused about why does "rcu_assign_pointer(dev->ip_ptr,
> in_dev);" need to rcu lock?
>=20

I am confused by your question

rcu_assign_pointer doesnt need rcu lock.

It only makes sure all previous memory changes are committed to memory
before the "dev->ip_ptr =3D in_dev;" assignement, so that concurrent
readers cannot find the new pointer and read previous values of
dev->ip_ptr->fields


> TIA :)
>=20
> static struct in_device *inetdev_init(struct net_device *dev)
> {
> 	struct in_device *in_dev;
>=20
> 	ASSERT_RTNL();
>=20
> 	in_dev =3D kzalloc(sizeof(*in_dev), GFP_KERNEL);
> 	if (!in_dev)
> 		goto out;
> 	memcpy(&in_dev->cnf, dev_net(dev)->ipv4.devconf_dflt,
> 			sizeof(in_dev->cnf));
> 	in_dev->cnf.sysctl =3D NULL;
> 	in_dev->dev =3D dev;
> 	if ((in_dev->arp_parms =3D neigh_parms_alloc(dev, &arp_tbl)) =3D=3D =
NULL)
> 		goto out_kfree;
> 	if (IPV4_DEVCONF(in_dev->cnf, FORWARDING))
> 		dev_disable_lro(dev);
> 	/* Reference in_dev->dev */
> 	dev_hold(dev);
> 	/* Account for reference dev->ip_ptr (below) */
> 	in_dev_hold(in_dev);
>=20
> 	devinet_sysctl_register(in_dev);
> 	ip_mc_init_dev(in_dev);
> 	if (dev->flags & IFF_UP)
> 		ip_mc_up(in_dev);
>=20
> 	/* we can receive as soon as ip_ptr is set -- do this last */
> 	rcu_assign_pointer(dev->ip_ptr, in_dev);
> out:
> 	return in_dev;
> out_kfree:
> 	kfree(in_dev);
> 	in_dev =3D NULL;
> 	goto out;
> }


