From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT]: Networking
Date: Wed, 05 Aug 2009 09:19:32 +0200
Message-ID: <4A793284.8000401@gmail.com>
References: <20090804.125742.32009006.davem@davemloft.net> <20090805070205.GA8741@elte.hu> <20090805071411.GA9217@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Jiri Pirko <jpirko@redhat.com>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33079 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933684AbZHEHUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 03:20:52 -0400
In-Reply-To: <20090805071411.GA9217@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar a =E9crit :
> * Ingo Molnar <mingo@elte.hu> wrote:
>=20
>> FYI, -tip testing found that these bits trigger a missing lockdep=20
>> annotation warning:
>=20
> it's apparently using an zero-initialized spinlock. This is a=20
> side-effect of:
>=20
>         dev_unicast_init(dev);
>=20
> in alloc_netdev_mq() making use of dev->addr_list_lock.
>=20
> Wouldnt the patch below be the right fix? The device has just been=20
> allocated freshly, it's not accessible anywhere yet so no locking is=20
> needed at all - in fact it's wrong to lock it here (the lock isnt=20
> initialized yet).
>=20
> This bug was apparently introduced via:
>=20
> | commit a6ac65db2329e7685299666f5f7b6093c7b0f3a0
> | Author: Jiri Pirko <jpirko@redhat.com>
> | Date:   Thu Jul 30 01:06:12 2009 +0000
> |
> |     net: restore the original spinlock to protect unicast list
>=20
> it needlessly added new locking and apparently nobody ran this patch=20
> with lockdep.
>=20
> 	Ingo
>=20
> Index: linux2/net/core/dev.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux2.orig/net/core/dev.c
> +++ linux2/net/core/dev.c
> @@ -4007,9 +4007,7 @@ static void dev_unicast_flush(struct net
> =20
>  static void dev_unicast_init(struct net_device *dev)
>  {
> -	netif_addr_lock_bh(dev);
>  	__hw_addr_init(&dev->uc);
> -	netif_addr_unlock_bh(dev);
>  }
> =20
> =20


Indeed, this function is static and thus only called from alloc_netdev_=
mq()

