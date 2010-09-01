From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Wed, 01 Sep 2010 15:57:41 +0200
Message-ID: <1283349461.2556.333.camel@edumazet-laptop>
References: <4LwrqITm-eJ.A.r8G.eFueMB@chimera>
	 <4AUWBNzTkbD.A.ey.cGueMB@chimera> <courier.4C7C99F2.00001F74@fs.ru.acad.bg>
	 <20100831192659.GA3093@del.dom.local>
	 <1283338251.2556.124.camel@edumazet-laptop>
	 <20100901112026.GA9468@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100901112026.GA9468-8HppEYmqbBCE+EvaaNYduQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mercredi 01 septembre 2010 =C3=A0 11:20 +0000, Jarek Poplawski a =C3=
=A9crit :
> On Wed, Sep 01, 2010 at 12:50:51PM +0200, Eric Dumazet wrote:
> > Plamen, could you test following patch ?
> >=20
> > I reproduced problem on a dev machine and following patch cured it.
> >=20
> > Thanks
> >=20
> > [PATCH] gro: fix different skb headrooms
> >=20
> > packets entering GRO might have different headrooms, even for a giv=
en
> > flow (because of implementation details in drivers, like copybreak)=
=2E
> > We cant force drivers to deliver packets with a fixed headroom.
> >=20
> > 1) fix skb_segment()
> >=20
> > skb_segment() makes the false assumption headrooms of fragments are=
 same
> > than the head. When CHECKSUM_PARTIAL is used, this can give csum_st=
art
> > errors, and crash later in skb_copy_and_csum_dev()
>=20
> Eric, probably I missed something, but since the same test as in
> skb_copy_and_csum_dev() gave different result a bit earlier on exactl=
y
> the same skb, I've suspected some sharing (or use after free)
> problems, so I'm not sure your current diagnose can explain this.
> (Unless this old test was dismissed later.)

Oh, this is because your patch had an error for the gso part that read =
:

-               rc =3D ops->ndo_start_xmit(nskb, dev);
+               if (skb_csum_start_bug(skb, 50)) {
+                       kfree_skb(skb);
+                       rc =3D NETDEV_TX_OK;
+               } else
+                       rc =3D ops->ndo_start_xmit(nskb, dev);
+
                if (unlikely(rc !=3D NETDEV_TX_OK)) {
                        if (rc & ~NETDEV_TX_MASK)
                                goto out_kfree_gso_skb;

You called skb_csum_start_bug(skb, 50) instead of
skb_csum_start_bug(nskb, 50)

Hope this clarify a bit ;)

Thanks
