From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] network device ops phase 1
Date: Mon, 10 Nov 2008 17:21:07 -0800
Message-ID: <20081110172107.4285b5b8@extreme>
References: <20081107155023.2dea5e0f@extreme>
	<20081110.170211.149124971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37286 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753538AbYKKBVL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 20:21:11 -0500
In-Reply-To: <20081110.170211.149124971.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Nov 2008 17:02:11 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 7 Nov 2008 15:50:23 -0800
>=20
> > This early work on a series of patches to separate the management p=
ortions
> > of the network device (immutable function pointers) from the data
> > structure part of the network device.
>  ...
>=20
> I think this is a good way to attack this kind of transition.
>=20
> Fix the build errors, do some testing, and please resubmit:
>=20
> net/core/dev.c: In function =E2=80=98register_netdevice=E2=80=99:
> net/core/dev.c:4075: error: =E2=80=98struct net_device_ops=E2=80=99 h=
as no member named =E2=80=98poll_controller=E2=80=99
> net/core/dev.c:4075: error: =E2=80=98struct net_device=E2=80=99 has n=
o member named =E2=80=98poll_controller=E2=80=99
> make[2]: *** [net/core/dev.o] Error 1
> make[1]: *** [net/core] Error 2
> make: *** [net] Error 2
> make: *** Waiting for unfinished jobs....
>=20
> Thanks.

This is one case where I wish GCC had more C++ style anonymous structur=
es
so the following would work, and avoid the copying and allocation.

struct net_device_ops {
   int (*init)(struct net_device *);
=2E..
};

struct net_device {
=2E..
#ifdef CONFIG_COMPAT_XXX
   struct net_device_ops;
#endif
   struct net_device_ops *ops;
};


void register_netdevice(struct net_device *dev)
{
=2E..

#ifdef CONFIG_COMPAT_XXX
      if (ops =3D=3D NULL) {
         printk("loser device %s", dev->name);
         dev->ops =3D (struct net_device_ops *) dev->init;
      }
#endif

}

