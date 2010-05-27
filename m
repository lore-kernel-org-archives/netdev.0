From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Warning in net/ipv4/af_inet.c:154
Date: Thu, 27 May 2010 06:21:15 +0200
Message-ID: <1274934075.2542.28.camel@edumazet-laptop>
References: <20100526.005634.48509140.davem@davemloft.net>
	 <1274868776.2672.96.camel@edumazet-laptop> <20100527035617.GB28295@kryten>
	 <20100526.210600.242135655.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: anton@samba.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65011 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933376Ab0E0EVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 00:21:20 -0400
Received: by wyb29 with SMTP id 29so3823102wyb.19
        for <netdev@vger.kernel.org>; Wed, 26 May 2010 21:21:18 -0700 (PDT)
In-Reply-To: <20100526.210600.242135655.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 mai 2010 =C3=A0 21:06 -0700, David Miller a =C3=A9crit :
> From: Anton Blanchard <anton@samba.org>
> Date: Thu, 27 May 2010 13:56:17 +1000
>=20
> > I'm somewhat confused by the two stage locking in the socket lock
> > (ie sk_lock.slock and sk_lock.owned).
> >=20
> > What state should the socket lock be in for serialising updates of
> > sk_forward_alloc? In some cases we appear to update it with sk_lock=
=2Eslock =3D
> > unlocked, sk_lock.owned =3D 1:
>=20
> If sh_lock.owned=3D1 the user has grabbed exclusive sleepable lock on=
 the
> socket, it does this via something approximating:
>=20
> retry:
> 	spin_lock(&sk_lock.slock);
> 	was_locked =3D sk_lock.owned;
> 	if (!was_locked)
> 		sk_lock.owned =3D 1;
> 	spin_unlock(&sk_lock.slock);
> 	if (was_locked) {
> 		sleep_on(condition(sk_lock.owned));
> 		goto retry;
> 	}
>=20
> This allows user context code to sleep with exclusive access to the
> socket.
>=20
> Code that cannot sleep takes the spinlock, and queues the work if the
> owner field if non-zero.  Else, it keeps the spinlock held and does
> the work.
>=20
> In either case, socket modifications are thus done completely protect=
ed
> from other contexts.
>=20
>=20

Yes, but not on the case one user context uses the 'slow locking', and
another uses the 'fast locking'.

I am working on a patch now.




