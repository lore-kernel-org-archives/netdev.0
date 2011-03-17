From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Poll about irqsafe_cpu_add and others
Date: Thu, 17 Mar 2011 19:55:39 +0100
Message-ID: <1300388139.6315.418.camel@edumazet-laptop>
References: <1300371834.6315.93.camel@edumazet-laptop>
	 <20110317.081420.71114992.davem@davemloft.net>
	 <alpine.DEB.2.00.1103171016270.12540@router.home>
	 <1300380801.6315.306.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1103171245430.16620@router.home>
	 <1300386569.6315.404.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1103171338350.18529@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1103171338350.18529@router.home>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 17 mars 2011 =C3=A0 13:42 -0500, Christoph Lameter a =C3=A9cri=
t :
> On Thu, 17 Mar 2011, Eric Dumazet wrote:
>=20
> > By the way, I noticed :
> >
> > DECLARE_PER_CPU(u64, xt_u64);
> > __this_cpu_add(xt_u64, 2) translates to following x86_32 code :
> >
> > 	mov	$xt_u64,%eax
> > 	add	%fs:0x0,%eax
> > 	addl	$0x2,(%eax)
> > 	adcl	$0x0,0x4(%eax)
> >
> >
> > I wonder why we dont use :
> >
> > 	addl	$0x2,%fs:xt_u64
> > 	addcl	$0x0,%fs:xt_u64+4
>=20
> The compiler is fed the following
>=20
> 	*__this_cpu_ptr(xt_u64) +=3D 2
>=20
> __this_cpu_ptr makes it:
>=20
> 	*(xt_u64 + __my_cpu_offset) +=3D 2
>=20
> So the compiler calculates the address first and then increments it.
>=20
> The compiler could optimize this I think. Wonder why that does not ha=
ppen.

Compiler is really forced to compute addr, thats why.

Hmm, we should not fallback to generic ops I think, but tweak=20

percpu_add_op() {=20
=2E..
	case 8:=20
#if CONFIG_X86_64_SMP
                if (pao_ID__ =3D=3D 1)                                 =
     \
                        asm("incq "__percpu_arg(0) : "+m" (var));      =
 \
                else if (pao_ID__ =3D=3D -1)                           =
     \
                        asm("decq "__percpu_arg(0) : "+m" (var));      =
 \
                else                                                   =
 \
                        asm("addq %1, "__percpu_arg(0)                 =
 \
                            : "+m" (var)                               =
 \
                            : "re" ((pao_T__)(val)));                  =
 \
                break;                                                 =
 \

#else
                asm("addl %1, "__percpu_arg(0)                  	\
                            : "+m" (var)                               =
 \
                            : "ri" ((u32)(val)));                   	\
		asm("adcl %1, "__percpu_arg(0) 				\
			: "+m" ((char *)var+4)				\
			: "ri" ((u32)(val>>32));			\
                break;                                                 =
 \

#endif
=2E...
}
