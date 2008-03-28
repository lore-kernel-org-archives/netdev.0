From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-2.6.26 5/5][LIB]: Forget the pcounter abstraction.
Date: Fri, 28 Mar 2008 10:46:30 +0100
Message-ID: <47ECBE76.4090809@cosmosbay.com>
References: <47ECB555.1000302@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.151]:50630 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751151AbYC1Jqg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 05:46:36 -0400
In-Reply-To: <47ECB555.1000302@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =E9crit :
> It was used by proto.inuse only. Now it's reworked and we can
> drop the pcounter, all the more so this was intended to be done.
>
> Not sure whether this should go via netdev tree, but as far as
> I remember it was added via this one...
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>  =20

I believe this will be Acked-by Andrew himself, dont worry :)

> ---
>  include/linux/pcounter.h |   74 ------------------------------------=
----------
>  lib/Makefile             |    1 -
>  lib/pcounter.c           |   58 ------------------------------------
>  3 files changed, 0 insertions(+), 133 deletions(-)
>  delete mode 100644 include/linux/pcounter.h
>  delete mode 100644 lib/pcounter.c
>
> diff --git a/include/linux/pcounter.h b/include/linux/pcounter.h
> deleted file mode 100644
> index a82d9f2..0000000
> --- a/include/linux/pcounter.h
> +++ /dev/null
> @@ -1,74 +0,0 @@
> -#ifndef __LINUX_PCOUNTER_H
> -#define __LINUX_PCOUNTER_H
> -/*
> - * Using a dynamic percpu 'int' variable has a cost :
> - * 1) Extra dereference
> - * Current per_cpu_ptr() implementation uses an array per 'percpu va=
riable'.
> - * 2) memory cost of NR_CPUS*(32+sizeof(void *)) instead of num_poss=
ible_cpus()*4
> - *
> - * This pcounter implementation is an abstraction to be able to use
> - * either a static or a dynamic per cpu variable.
> - * One dynamic per cpu variable gets a fast & cheap implementation, =
we can
> - * change pcounter implementation too.
> - */
> -struct pcounter {
> -#ifdef CONFIG_SMP
> -	void		(*add)(struct pcounter *self, int inc);
> -	int		(*getval)(const struct pcounter *self, int cpu);
> -	int		*per_cpu_values;
> -#else
> -	int		val;
> -#endif
> -};
> -
> -#ifdef CONFIG_SMP
> -#include <linux/percpu.h>
> -
> -#define DEFINE_PCOUNTER(NAME)						\
> -static DEFINE_PER_CPU(int, NAME##_pcounter_values);			\
> -static void NAME##_pcounter_add(struct pcounter *self, int val)		\
> -{									\
> -       __get_cpu_var(NAME##_pcounter_values) +=3D val;			\
> -}									\
> -static int NAME##_pcounter_getval(const struct pcounter *self, int c=
pu)	\
> -{									\
> -	return per_cpu(NAME##_pcounter_values, cpu);			\
> -}									\
> -
> -#define PCOUNTER_MEMBER_INITIALIZER(NAME, MEMBER)		\
> -	MEMBER =3D {						\
> -		.add	=3D NAME##_pcounter_add,			\
> -		.getval =3D NAME##_pcounter_getval,		\
> -	}
> -
> -
> -static inline void pcounter_add(struct pcounter *self, int inc)
> -{
> -	self->add(self, inc);
> -}
> -
> -extern int pcounter_getval(const struct pcounter *self);
> -extern int pcounter_alloc(struct pcounter *self);
> -extern void pcounter_free(struct pcounter *self);
> -
> -
> -#else /* CONFIG_SMP */
> -
> -static inline void pcounter_add(struct pcounter *self, int inc)
> -{
> -	self->val +=3D inc;
> -}
> -
> -static inline int pcounter_getval(const struct pcounter *self)
> -{
> -	return self->val;
> -}
> -
> -#define DEFINE_PCOUNTER(NAME)
> -#define PCOUNTER_MEMBER_INITIALIZER(NAME, MEMBER)
> -#define pcounter_alloc(self) 0
> -#define pcounter_free(self)
> -
> -#endif /* CONFIG_SMP */
> -
> -#endif /* __LINUX_PCOUNTER_H */
> diff --git a/lib/Makefile b/lib/Makefile
> index 23de261..4d059d4 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -61,7 +61,6 @@ obj-$(CONFIG_TEXTSEARCH_KMP) +=3D ts_kmp.o
>  obj-$(CONFIG_TEXTSEARCH_BM) +=3D ts_bm.o
>  obj-$(CONFIG_TEXTSEARCH_FSM) +=3D ts_fsm.o
>  obj-$(CONFIG_SMP) +=3D percpu_counter.o
> -obj-$(CONFIG_SMP) +=3D pcounter.o
>  obj-$(CONFIG_AUDIT_GENERIC) +=3D audit.o
> =20
>  obj-$(CONFIG_SWIOTLB) +=3D swiotlb.o
> diff --git a/lib/pcounter.c b/lib/pcounter.c
> deleted file mode 100644
> index 9b56807..0000000
> --- a/lib/pcounter.c
> +++ /dev/null
> @@ -1,58 +0,0 @@
> -/*
> - * Define default pcounter functions
> - * Note that often used pcounters use dedicated functions to get a s=
peed increase.
> - * (see DEFINE_PCOUNTER/REF_PCOUNTER_MEMBER)
> - */
> -
> -#include <linux/module.h>
> -#include <linux/pcounter.h>
> -#include <linux/smp.h>
> -#include <linux/cpumask.h>
> -
> -static void pcounter_dyn_add(struct pcounter *self, int inc)
> -{
> -	per_cpu_ptr(self->per_cpu_values, smp_processor_id())[0] +=3D inc;
> -}
> -
> -static int pcounter_dyn_getval(const struct pcounter *self, int cpu)
> -{
> -	return per_cpu_ptr(self->per_cpu_values, cpu)[0];
> -}
> -
> -int pcounter_getval(const struct pcounter *self)
> -{
> -	int res =3D 0, cpu;
> -
> -	for_each_possible_cpu(cpu)
> -		res +=3D self->getval(self, cpu);
> -
> -	return res;
> -}
> -EXPORT_SYMBOL_GPL(pcounter_getval);
> -
> -int pcounter_alloc(struct pcounter *self)
> -{
> -	int rc =3D 0;
> -	if (self->add =3D=3D NULL) {
> -		self->per_cpu_values =3D alloc_percpu(int);
> -		if (self->per_cpu_values !=3D NULL) {
> -			self->add    =3D pcounter_dyn_add;
> -			self->getval =3D pcounter_dyn_getval;
> -		} else
> -			rc =3D 1;
> -	}
> -	return rc;
> -}
> -EXPORT_SYMBOL_GPL(pcounter_alloc);
> -
> -void pcounter_free(struct pcounter *self)
> -{
> -	if (self->per_cpu_values !=3D NULL) {
> -		free_percpu(self->per_cpu_values);
> -		self->per_cpu_values =3D NULL;
> -		self->getval =3D NULL;
> -		self->add =3D NULL;
> -	}
> -}
> -EXPORT_SYMBOL_GPL(pcounter_free);
> -
>  =20




