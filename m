From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: a problem tcp_v4_err()
Date: Fri, 12 Nov 2010 19:21:54 +0100
Message-ID: <1289586114.3185.271.camel@edumazet-laptop>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
	 <00c201cb81eb$84e18160$8ea48420$@com>
	 <1289578108.3083.95.camel@localhost.localdomain>
	 <1289578532.3185.265.camel@edumazet-laptop>
	 <20101112163543.GB122902@jupiter.n2.diac24.net>
	 <4CDD7145.8070606@trash.net>  <20101112175715.GB16544@ms2.inr.ac.ru>
	 <1289585578.3185.268.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Lamparter <equinox@diac24.net>,
	Eric Paris <eparis@redhat.com>, Hua Zhong <hzhong@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, paul.moore@hp.com
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289585578.3185.268.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 12 novembre 2010 =C3=A0 19:12 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le vendredi 12 novembre 2010 =C3=A0 20:57 +0300, Alexey Kuznetsov a =C3=
=A9crit :
> > Hello!
> >=20
> > I looked at tcp_v4_err() and found something strange. Quite non-tri=
vial operations
> > are performed on unlocked sockets. It looks like at least this BUG_=
ON():
> >=20
> >                 skb =3D tcp_write_queue_head(sk);
> >                 BUG_ON(!skb);
> >=20
> > can be easily triggered.
> >=20
> > Do I miss something?
> >=20
>=20
> Hi Alexey !
>=20
> I see socket is locked around line 368,
>=20
>         bh_lock_sock(sk);
>         /* If too many ICMPs get dropped on busy
>          * servers this needs to be solved differently.
>          */
>         if (sock_owned_by_user(sk))
>                 NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
>=20
>=20
> Hmm, maybe some goto is missing ;)
>=20

Well, goto is not missing.

Why do you think BUG_ON(!skb) can be triggered ?

We test before :

	if (seq !=3D tp->snd_una  || !icsk->icsk_retransmits ||
		!icsk->icsk_backoff)
		break;

So a concurrent user only can add new skb(s) in the (non empty) queue ?
