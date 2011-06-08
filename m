From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Date: Wed, 08 Jun 2011 23:22:29 +0200
Message-ID: <1307568149.3980.3.camel@edumazet-laptop>
References: <20110601011527.GN19505@random.random>
	 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>
	 <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>
	 <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com>
	 <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com>
	 <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com>
	 <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>
	 <isavsg$3or$1@dough.gmane.org> <4DE906C0.6060901@fnarfbargle.com>
	 <4DED344D.7000005@pandora.be> <4DED9C23.2030408@fnarfbargle.com>
	 <4DEE27DE.7060004@trash.net> <4DEE3859.6070808@fnarfbargle.com>
	 <4DEE4538.1020404@trash.net> <1307471484.3091.43.camel@edumazet-laptop>
	 <4DEEACC3.3030509@trash.net>  <4DEEBFC2.4060102@fnarfbargle.com>
	 <1307505541.3102.12.camel@edumazet-laptop>
	 <4DEFAB15.2060905@fnarfbargle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Patrick McHardy <kaber@trash.net>, Bart De Schuymer
 <bdschuym@pandora.be>,  kvm@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  netdev@vger.kernel.org,
 netfilter-devel@vger.kernel.org
To: Brad Campbell <brad@fnarfbargle.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4DEFAB15.2060905@fnarfbargle.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le jeudi 09 juin 2011 =C3=A0 01:02 +0800, Brad Campbell a =C3=A9crit :
> On 08/06/11 11:59, Eric Dumazet wrote:
>=20
> > Well, a bisection definitely should help, but needs a lot of time in
> > your case.
>=20
> Yes. compile, test, crash, walk out to the other building to press=20
> reset, lather, rinse, repeat.
>=20
> I need a reset button on the end of a 50M wire, or a hardware watchdog!
>=20
> Actually it's not so bad. If I turn off slub debugging the kernel panic=
s=20
> and reboots itself.
>=20
> This.. :
> [    2.913034] netconsole: remote ethernet address 00:16:cb:a7:dd:d1
> [    2.913066] netconsole: device eth0 not up yet, forcing it
> [    3.660062] Refined TSC clocksource calibration: 3213.422 MHz.
> [    3.660118] Switching to clocksource tsc
> [   63.200273] r8169 0000:03:00.0: eth0: unable to load firmware patch=20
> rtl_nic/rtl8168e-1.fw (-2)
> [   63.223513] r8169 0000:03:00.0: eth0: link down
> [   63.223556] r8169 0000:03:00.0: eth0: link down
>=20
> ..is slowing down reboots considerably. 3.0-rc does _not_ like some=20
> timing hardware in my machine. Having said that, at least it does not=20
> randomly panic on SCSI like 2.6.39 does.
>=20
> Ok, I've ruled out TCPMSS. Found out where it was being set and neutere=
d=20
> it. I've replicated it with only the single DNAT rule.
>=20
>=20
> > Could you try following patch, because this is the 'usual suspect' I =
had
> > yesterday :
> >
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 46cbd28..9f548f9 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -792,6 +792,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhe=
ad, int ntail,
> >   		fastpath =3D atomic_read(&skb_shinfo(skb)->dataref) =3D=3D delta;
> >   	}
> >
> > +#if 0
> >   	if (fastpath&&
> >   	size + sizeof(struct skb_shared_info)<=3D ksize(skb->head)) {
> >   		memmove(skb->head + size, skb_shinfo(skb),
> > @@ -802,7 +803,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhe=
ad, int ntail,
> >   		off =3D nhead;
> >   		goto adjust_others;
> >   	}
> > -
> > +#endif
> >   	data =3D kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
> >   	if (!data)
> >   		goto nodata;
> >
> >
> >
>=20
> Nope.. that's not it. <sigh> That might have changed the characteristic=
=20
> of the fault slightly, but unfortunately I got caught with a couple of=20
> fsck's, so I only got to test it 3 times tonight.
>=20
> It's unfortunate that this is a production system, so I can only take i=
t=20
> down between about 9pm and 1am. That would normally be pretty=20
> productive, except that an fsck of a 14TB ext4 can take 30 minutes if i=
t=20
> panics at the wrong time.
>=20
> I'm out of time tonight, but I'll have a crack at some bisection=20
> tomorrow night. Now I just have to go back far enough that it works, an=
d=20
> be near enough not to have to futz around with /proc /sys or drivers.
>=20
> I really, really, really appreciate you guys helping me with this. It=20
> has been driving me absolutely bonkers. If I'm ever in the same town as=
=20
> any of you, dinner and drinks are on me.

Hmm, I wonder if kmemcheck could help you, but its slow as hell, so not
appropriate for production :(



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
