From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Poll about irqsafe_cpu_add and others
Date: Thu, 17 Mar 2011 17:53:21 +0100
Message-ID: <1300380801.6315.306.camel@edumazet-laptop>
References: <1300371834.6315.93.camel@edumazet-laptop>
	 <20110317.081420.71114992.davem@davemloft.net>
	 <alpine.DEB.2.00.1103171016270.12540@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1103171016270.12540@router.home>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 17 mars 2011 =C3=A0 10:18 -0500, Christoph Lameter a =C3=A9cri=
t :
> On Thu, 17 Mar 2011, David Miller wrote:
>=20
> >
> > I had been meaning to bring this up from another perspective.
> >
> > In networking, we often only ever access objects in base or
> > BH context.  Therefore in BH context cases we can do just
> > normal counter bumps without any of the special atomic or
> > IRQ disabling code at all.
>=20
> We have the __ functions for that purpose. __this_cpu_inc f.e. falls =
back
> to a simply ++ operation if the arch cannot provide something better.
> irqsafe_xx are only used if the context does not provide any protecti=
on
> and if there is the potential of the counter being incremented from a=
n
> interrupt context.
>=20

What David and I have in mind is to use one array per mib instead of
two. This is an old idea.

https://patchwork.kernel.org/patch/15883/

When we know we run from BH context, we can use __this_cpu_inc(), but i=
f
we dont know or run from user/process context, we would need irqsafe_in=
c
variant.

=46or x86 this maps to same single instruction, but for other arches, t=
his
might be too expensive.

BTW, I think following patch is possible to save some text and useless
tests (on 64bit platform at least)

size vmlinux.old vmlinux

Thanks

[PATCH] snmp: SNMP_UPD_PO_STATS_BH() always called from softirq

We dont need to test if we run from softirq context.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 include/net/snmp.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/snmp.h b/include/net/snmp.h
index 762e2ab..be2424d 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -149,8 +149,8 @@ struct linux_xfrm_mib {
 	} while (0)
 #define SNMP_UPD_PO_STATS_BH(mib, basefield, addend)	\
 	do { \
-		__typeof__(*mib[0]) *ptr =3D \
-			__this_cpu_ptr((mib)[!in_softirq()]); \
+		__typeof__(*mib[0]) *ptr =3D __this_cpu_ptr((mib)[0]);	\
+									\
 		ptr->mibs[basefield##PKTS]++; \
 		ptr->mibs[basefield##OCTETS] +=3D addend;\
 	} while (0)
