From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_unix: limit unix_tot_inflight
Date: Wed, 24 Nov 2010 16:18:26 +0100
Message-ID: <1290611906.3464.66.camel@edumazet-laptop>
References: <AANLkTi=Q967xpX0KLMwX-=_4_1AKO5wjHEuJ1TrNjCj9@mail.gmail.com>
	 <1290553918.2866.80.camel@edumazet-laptop>
	 <1290590335.3464.24.camel@edumazet-laptop>
	 <877hg2g4re.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vegard Nossum <vegard.nossum@gmail.com>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eugene Teo <eugene@redhat.com>, netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877hg2g4re.fsf@basil.nowhere.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 24 novembre 2010 =C3=A0 15:44 +0100, Andi Kleen a =C3=A9cri=
t :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> >
> > diff --git a/net/unix/garbage.c b/net/unix/garbage.c
> > index c8df6fd..40df93d 100644
> > --- a/net/unix/garbage.c
> > +++ b/net/unix/garbage.c
> > @@ -259,9 +259,16 @@ static void inc_inflight_move_tail(struct unix=
_sock *u)
> >  }
> > =20
> >  static bool gc_in_progress =3D false;
> > +#define UNIX_INFLIGHT_TRIGGER_GC 16000
>=20
> It would be better to define this as a percentage of
> lowmem.
>=20

I knew somebody would suggest this ;)

Hmm, why bother ?

Do you think 16000 is too big ? Too small ?

1) What would be the percentage of memory ? 1%, 0.001 % ?

  On a 16TB machine, a percentage will still give huge latencies to the
poor guy that hit the unix_gc().

With 16000, the max latency I had was 11.5 ms (on an Intel E5540
@2.53GHz), instead of more than 2000 ms

I guess it would make more sense to limit to the size of cpu cache
anyway.


2) We currently allocate 4096 bytes (on x86_64) to store one file
pointer, or 2048 bytes on x86_32.

But we can store in it up to 255 files.

 I posted a patch to shrink this to 32 or 16 bytes. Should we then
change the heuristic ?

3) Really who needs more than 16000 inflight unix files ?

  (inflight unix files means : af_unix file descriptors that were sent
(sendfd()) through af_unix, not yet garbage collected.).


4) If we autotune a limit at boot time as a lowmem percentage, some guy=
s
then want a /proc/sys/net/core/max_unix_inflight sysctl , just for
completeness. One extra sysctl...=20

I cant see valid uses but programs designed to stress our stack.
