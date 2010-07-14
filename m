From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] act_cpu: packet distributing
Date: Wed, 14 Jul 2010 05:41:15 +0200
Message-ID: <1279078875.2444.103.camel@edumazet-laptop>
References: <1279077475-2956-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38348 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121Ab0GNDlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 23:41:21 -0400
Received: by wyb42 with SMTP id 42so654121wyb.19
        for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 20:41:19 -0700 (PDT)
In-Reply-To: <1279077475-2956-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 juillet 2010 =C3=A0 11:17 +0800, Changli Gao a =C3=A9cri=
t :
> I want to know if I can assign the sk to skb as nf_tproxy_core does t=
o avoid
> the duplicate search later. Thanks.
>=20

I suggest we first correct bugs before adding new features.

=46or me, tproxy is a high suspect at this moment, I would not use it o=
n
production machine.

> act_cpu: packet distributing
>=20
> This TC action can be used to redirect packets to the CPU:
>  * specified by the cpuid option
>  * specified by the class minor ID obtained previously
>  * on which the corresponding application runs
>=20
> It supports the similar functions of RPS and RFS, but is more flexibl=
e.
>=20

Thins kind of claims is disgusting.

No documentation,  I have no idea how you setup the thing.

RPS still misses documentation, but activating it is easy.


> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  include/linux/netdevice.h     |    2=20
>  include/linux/tc_act/tc_cpu.h |   31 +++++
>  include/net/sock.h            |   24 +++
>  include/net/tc_act/tc_cpu.h   |   18 ++
>  net/core/dev.c                |    4=20
>  net/core/sock.c               |    1=20
>  net/sched/Kconfig             |   12 +
>  net/sched/Makefile            |    1=20
>  net/sched/act_cpu.c           |  260 +++++++++++++++++++++++++++++++=
+++++++++++
>  9 files changed, 350 insertions(+), 3 deletions(-)
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index c4fedf0..318d422 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1435,6 +1435,8 @@ static inline void input_queue_tail_incr_save(s=
truct softnet_data *sd,
> =20
>  DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
> =20
> +int enqueue_to_backlog(struct sk_buff *skb, int cpu, unsigned int *q=
tail);
> +
>  #define HAVE_NETIF_QUEUE
> =20
>  extern void __netif_schedule(struct Qdisc *q);
> diff --git a/include/linux/tc_act/tc_cpu.h b/include/linux/tc_act/tc_=
cpu.h
> new file mode 100644
> index 0000000..2704607
> --- /dev/null
> +++ b/include/linux/tc_act/tc_cpu.h
> @@ -0,0 +1,31 @@
> +#ifndef __LINUX_TC_CPU_H
> +#define __LINUX_TC_CPU_H
> +
> +#include <linux/pkt_cls.h>
> +#include <linux/types.h>
> +
> +#define TCA_ACT_CPU 12
> +
> +enum {
> +	TCA_CPU_UNSPEC,
> +	TCA_CPU_PARMS,
> +	TCA_CPU_TM,
> +	__TCA_CPU_MAX
> +};
> +#define TCA_CPU_MAX (__TCA_CPU_MAX - 1)
> +
> +enum {
> +	TCA_CPU_TYPE_MAP,
> +	TCA_CPU_TYPE_CPUID,
> +	TCA_CPU_TYPE_SOCKET,
> +	__TCA_CPU_TYPE_MAX
> +};
> +#define TCA_CPU_TYPE_MAX (__TCA_CPU_TYPE_MAX - 1)
> +
> +struct tc_cpu {
> +	tc_gen;
> +	__u32		type;
> +	__u32		value;
> +};
> +
> +#endif /* __LINUX_TC_CPU_H */
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 3100e71..7913158 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -200,6 +200,7 @@ struct sock_common {
>    *	@sk_rcvtimeo: %SO_RCVTIMEO setting
>    *	@sk_sndtimeo: %SO_SNDTIMEO setting
>    *	@sk_rxhash: flow hash received from netif layer
> +  *	@sk_cpu: the CPU on which the corresponding process works.
>    *	@sk_filter: socket filtering instructions
>    *	@sk_protinfo: private area, net family specific, when not using =
slab
>    *	@sk_timer: sock cleanup timer
> @@ -284,6 +285,9 @@ struct sock {
>  #ifdef CONFIG_RPS
>  	__u32			sk_rxhash;
>  #endif
> +#if defined(CONFIG_NET_ACT_CPU) || defined(CONFIG_NET_ACT_CPU_MODULE=
)
> +	int			sk_cpu;
> +#endif
>  	unsigned long 		sk_flags;
>  	unsigned long	        sk_lingertime;
>  	struct sk_buff_head	sk_error_queue;
> @@ -639,7 +643,24 @@ static inline int sk_backlog_rcv(struct sock *sk=
, struct sk_buff *skb)
>  	return sk->sk_backlog_rcv(sk, skb);
>  }
> =20
> -static inline void sock_rps_record_flow(const struct sock *sk)
> +static inline void sock_reset_cpu(struct sock *sk)
> +{
> +#if defined(CONFIG_NET_ACT_CPU) || defined(CONFIG_NET_ACT_CPU_MODULE=
)
> +	sk->sk_cpu =3D nr_cpumask_bits;
> +#endif
> +}
> +
> +static inline void sock_save_cpu(struct sock *sk)
> +{
> +#if defined(CONFIG_NET_ACT_CPU) || defined(CONFIG_NET_ACT_CPU_MODULE=
)
> +	int cpu =3D get_cpu();
> +	if (sk->sk_cpu !=3D cpu)
> +		sk->sk_cpu =3D cpu;
> +	put_cpu();

sk->sk_cpu =3D raw_smp_processor_id();

> +#endif
> +}
> +
> +static inline void sock_rps_record_flow(struct sock *sk)
>  {
>  #ifdef CONFIG_RPS
>  	struct rps_sock_flow_table *sock_flow_table;
> @@ -649,6 +670,7 @@ static inline void sock_rps_record_flow(const str=
uct sock *sk)
>  	rps_record_sock_flow(sock_flow_table, sk->sk_rxhash);
>  	rcu_read_unlock();
>  #endif
> +	sock_save_cpu(sk);
>  }
> =20
>  static inline void sock_rps_reset_flow(const struct sock *sk)
> diff --git a/include/net/tc_act/tc_cpu.h b/include/net/tc_act/tc_cpu.=
h
> new file mode 100644
> index 0000000..0504bf0
> --- /dev/null
> +++ b/include/net/tc_act/tc_cpu.h
> @@ -0,0 +1,18 @@
> +#ifndef __NET_TC_CPU_H
> +#define __NET_TC_CPU_H
> +
> +#include <linux/types.h>
> +#include <net/act_api.h>
> +
> +struct tcf_cpu {
> +	struct tcf_common	common;
> +	u32			type;
> +	u32			value;
> +};
> +
> +static inline struct tcf_cpu *to_tcf_cpu(struct tcf_common *pc)
> +{
> +	return container_of(pc, struct tcf_cpu, common);
> +}
> +
> +#endif /* __NET_TC_CPU_H */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index e2b9fa2..45e8a21 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2443,8 +2443,7 @@ static int rps_ipi_queued(struct softnet_data *=
sd)
>   * enqueue_to_backlog is called to queue an skb to a per CPU backlog
>   * queue (may be a remote CPU queue).
>   */
> -static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
> -			      unsigned int *qtail)
> +int enqueue_to_backlog(struct sk_buff *skb, int cpu, unsigned int *q=
tail)
>  {
>  	struct softnet_data *sd;
>  	unsigned long flags;
> @@ -2482,6 +2481,7 @@ enqueue:
>  	kfree_skb(skb);
>  	return NET_RX_DROP;
>  }
> +EXPORT_SYMBOL(enqueue_to_backlog);
> =20
>  /**
>   *	netif_rx	-	post buffer to the network code
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 363bc26..7a71e76 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1045,6 +1045,7 @@ static struct sock *sk_prot_alloc(struct proto =
*prot, gfp_t priority,
>  		if (!try_module_get(prot->owner))
>  			goto out_free_sec;
>  		sk_tx_queue_clear(sk);
> +		sock_reset_cpu(sk);
>  	}
> =20
>  	return sk;
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 2f691fb..a826758 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -427,6 +427,18 @@ config NET_CLS_ACT
>  	  A recent version of the iproute2 package is required to use
>  	  extended matches.
> =20
> +config NET_ACT_CPU
> +        tristate "Packet distributing"
> +        depends on NET_CLS_ACT
> +        depends on RPS
> +        ---help---
> +	  Say Y here to do packets distributing. With it, you can distribut=
e
> +	  the packets among the CPUs on the system in any way as you like. =
It
> +	  only works in ingress.
> +
> +	  To compile this code as a module, choose M here: the
> +	  module will be called act_cpu.
> +
>  config NET_ACT_POLICE
>  	tristate "Traffic Policing"
>          depends on NET_CLS_ACT=20
> diff --git a/net/sched/Makefile b/net/sched/Makefile
> index f14e71b..a9e0b96 100644
> --- a/net/sched/Makefile
> +++ b/net/sched/Makefile
> @@ -7,6 +7,7 @@ obj-y	:=3D sch_generic.o sch_mq.o
>  obj-$(CONFIG_NET_SCHED)		+=3D sch_api.o sch_blackhole.o
>  obj-$(CONFIG_NET_CLS)		+=3D cls_api.o
>  obj-$(CONFIG_NET_CLS_ACT)	+=3D act_api.o
> +obj-$(CONFIG_NET_ACT_CPU)	+=3D act_cpu.o
>  obj-$(CONFIG_NET_ACT_POLICE)	+=3D act_police.o
>  obj-$(CONFIG_NET_ACT_GACT)	+=3D act_gact.o
>  obj-$(CONFIG_NET_ACT_MIRRED)	+=3D act_mirred.o
> diff --git a/net/sched/act_cpu.c b/net/sched/act_cpu.c
> new file mode 100644
> index 0000000..6b7d7fc
> --- /dev/null
> +++ b/net/sched/act_cpu.c
> @@ -0,0 +1,260 @@
> +/*
> + * Packet distributing actions
> + *
> + * Copyright (c) 2010- Changli Gao <xiaosuo@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify it
> + * under the terms of the GNU General Public License as published by=
 the Free
> + * Software Foundation; either version 2 of the License, or (at your=
 option)
> + * any later version.
> + */
> +
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/string.h>
> +#include <linux/errno.h>
> +#include <linux/skbuff.h>
> +#include <linux/rtnetlink.h>
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/gfp.h>
> +#include <net/net_namespace.h>
> +#include <net/netlink.h>
> +#include <net/pkt_sched.h>
> +#include <net/tcp.h>
> +#include <net/udp.h>
> +#include <linux/tc_act/tc_cpu.h>
> +#include <net/tc_act/tc_cpu.h>
> +
> +#define CPU_TAB_MASK     15
> +static struct tcf_common *tcf_cpu_ht[CPU_TAB_MASK + 1];
> +static u32 cpu_idx_gen;
> +static DEFINE_RWLOCK(cpu_lock);
> +
> +static struct tcf_hashinfo cpu_hash_info =3D {
> +	.htab	=3D tcf_cpu_ht,
> +	.hmask	=3D CPU_TAB_MASK,
> +	.lock	=3D &cpu_lock
> +};
> +
> +static const struct nla_policy cpu_policy[TCA_CPU_MAX + 1] =3D {
> +	[TCA_CPU_PARMS]	=3D { .len =3D sizeof(struct tc_cpu) },
> +};
> +
> +static int tcf_cpu_init(struct nlattr *nla, struct nlattr *est,
> +			struct tc_action *a, int ovr, int bind)
> +{
> +	struct nlattr *tb[TCA_CPU_MAX + 1];
> +	struct tc_cpu *parm;
> +	struct tcf_cpu *p;
> +	struct tcf_common *pc;
> +	int ret;
> +
> +	if (nla =3D=3D NULL)
> +		return -EINVAL;
> +	ret =3D nla_parse_nested(tb, TCA_CPU_MAX, nla, cpu_policy);
> +	if (ret < 0)
> +		return ret;
> +	if (tb[TCA_CPU_PARMS] =3D=3D NULL)
> +		return -EINVAL;
> +	parm =3D nla_data(tb[TCA_CPU_PARMS]);
> +	if (parm->type > TCA_CPU_TYPE_MAX || parm->action !=3D TC_ACT_STOLE=
N)
> +		return -EINVAL;
> +
> +	pc =3D tcf_hash_check(parm->index, a, bind, &cpu_hash_info);
> +	if (!pc) {
> +		pc =3D tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
> +				     &cpu_idx_gen, &cpu_hash_info);
> +		if (IS_ERR(pc))
> +			return PTR_ERR(pc);
> +		ret =3D ACT_P_CREATED;
> +	} else {
> +		if (!ovr) {
> +			tcf_hash_release(pc, bind, &cpu_hash_info);
> +			return -EEXIST;
> +		}
> +		ret =3D 0;
> +	}
> +	p =3D to_tcf_cpu(pc);
> +
> +	spin_lock_bh(&p->tcf_lock);
> +	p->type =3D parm->type;
> +	p->value =3D parm->value;
> +	p->tcf_action =3D parm->action;
> +	spin_unlock_bh(&p->tcf_lock);
> +
> +	if (ret =3D=3D ACT_P_CREATED)
> +		tcf_hash_insert(pc, &cpu_hash_info);
> +
> +	return ret;
> +}
> +
> +static int tcf_cpu_cleanup(struct tc_action *a, int bind)
> +{
> +	struct tcf_cpu *p =3D a->priv;
> +
> +	return tcf_hash_release(&p->common, bind, &cpu_hash_info);
> +}
> +
> +static int tcf_cpu_from_sock(struct sk_buff *skb)
> +{
> +	struct iphdr *iph;
> +	struct sock *sk;
> +	struct {
> +		__be16 source, dest;
> +	} *ports;
> +	int cpu;
> +
> +	if (skb->dev =3D=3D NULL || skb->protocol !=3D __constant_htons(ETH=
_P_IP))
> +		goto err;
> +	if (!pskb_may_pull(skb, sizeof(*iph)))
> +		goto err;
> +	iph =3D (struct iphdr *) skb->data;
> +	if (!pskb_may_pull(skb, iph->ihl * 4 + 4))
> +		goto err;
> +	ports =3D (void *) (skb->data + iph->ihl * 4);

Why doing the search again, in case skb->sk already set by another
module before you, like tproxy ?

> +	switch (iph->protocol) {
> +	case IPPROTO_TCP:
> +		sk =3D __inet_lookup(dev_net(skb->dev), &tcp_hashinfo, iph->saddr,
> +				   ports->source, iph->daddr, ports->dest,
> +				   skb->dev->ifindex);
> +		break;
> +	case IPPROTO_UDP:
> +		sk =3D udp4_lib_lookup(dev_net(skb->dev), iph->saddr,
> +				     ports->source, iph->daddr, ports->dest,
> +				     skb->dev->ifindex);
> +		break;
> +	default:
> +		goto err;
> +	}
> +
> +	if (!sk)
> +		goto err;
> +	cpu =3D sk->sk_cpu;
> +	if (sk->sk_protocol =3D=3D IPPROTO_TCP && sk->sk_state =3D=3D TCP_T=
IME_WAIT)
> +		inet_twsk_put(inet_twsk(sk));
> +	else
> +		sock_put(sk);
> +
> +	return cpu;
> +
> +err:
> +	return smp_processor_id();
> +}
> +
> +static int tcf_cpu(struct sk_buff *skb, struct tc_action *a,
> +		   struct tcf_result *res)
> +{
> +	struct tcf_cpu *p =3D a->priv;
> +	u32 type;
> +	u32 value;
> +	int cpu, action;
> +	struct sk_buff *nskb;
> +	unsigned int qtail;
> +
> +	spin_lock(&p->tcf_lock);

Ok, the big lock...

We have a lockless TCP/UDP input path, and this modules adds a lock
again.

> +	p->tcf_tm.lastuse =3D jiffies;
> +	p->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
> +	p->tcf_bstats.packets++;
> +	type =3D p->type;
> +	value =3D p->value;
> +	action =3D p->tcf_action;
> +	spin_unlock(&p->tcf_lock);
> +

Please change all this crap  (legacy crap, copied from other tc
modules), by modern one, using RCU and no locking in hot path.



