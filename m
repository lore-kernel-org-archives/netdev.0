From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 06:54:15 +0200
Message-ID: <1274331255.2658.24.camel@edumazet-laptop>
References: <4BF4517F.1010206@athenacr.com>
	 <20100519.195533.22536631.davem@davemloft.net>
	 <20100520025741.GA6129@gondor.apana.org.au>
	 <20100519.200522.140743640.davem@davemloft.net>
	 <20100520033446.GA6434@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:62300 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460Ab0ETEyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 00:54:25 -0400
Received: by wwb18 with SMTP id 18so249817wwb.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 21:54:23 -0700 (PDT)
In-Reply-To: <20100520033446.GA6434@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 mai 2010 =C3=A0 13:34 +1000, Herbert Xu a =C3=A9crit :
> On Wed, May 19, 2010 at 08:05:22PM -0700, David Miller wrote:
> > Ok, looking forward to it.
>=20
> Here we go:
>=20
> cls_cgroup: Store classid in struct sock
>=20
> Up until now cls_cgroup has relied on fetching the classid out of
> the current executing thread.  This runs into trouble when a packet
> processing is delayed in which case it may execute out of another
> thread's context.
>=20
> Furthermore, even when a packet is not delayed we may fail to
> classify it if soft IRQs have been disabled, because this scenario
> is indistinguishable from one where a packet unrelated to the
> current thread is processed by a real soft IRQ.
>=20
> As we already have a concept of packet ownership for accounting
> purposes in the skb->sk pointer, this is a natural place to store
> the classid in a persistent manner.
>=20
> This patch adds the cls_cgroup classid in struct sock, filling up
> an existing hole on 64-bit :)
>=20
> The value is set at socket creation time.  So all sockets created
> via socket(2) automatically gains the ID of the thread creating it.
> Now you may argue that this may not be the same as the thread that
> is sending the packet.  However, we already have a precedence where
> an fd is passed to a different thread, its security property is
> inherited.  In this case, inheriting the classid of the thread
> creating the socket is also the logical thing to do.
>=20
> For sockets created on inbound connections through accept(2), we
> inherit the classid of the original listening socket through
> sk_clone, possibly preceding the actual accept(2) call.
>=20
> In order to minimise risks, I have not made this the authoritative
> classid.  For now it is only used as a backup when we execute
> with soft IRQs disabled.  Once we're completely happy with its
> semantics we can use it as the sole classid.
>=20
> Footnote: I have rearranged the error path on cls_group module
> creation.  If we didn't do this, then there is a window where
> someone could create a tc rule using cls_group before the cgroup
> subsystem has been registered.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>=20
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 8f78073..63c5036 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -410,6 +410,12 @@ struct cgroup_scanner {
>  	void *data;
>  };
> =20
> +struct cgroup_cls_state
> +{
> +	struct cgroup_subsys_state css;
> +	u32 classid;
> +};
> +
>  /*
>   * Add a new file to the given cgroup directory. Should only be
>   * called by subsystems from within a populate() method
> @@ -515,6 +521,10 @@ struct cgroup_subsys {
>  	struct module *module;
>  };
> =20
> +#ifndef CONFIG_NET_CLS_CGROUP
> +extern int net_cls_subsys_id;
> +#endif
> +
>  #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
>  #include <linux/cgroup_subsys.h>
>  #undef SUBSYS
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 1ad6435..361a5dc 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -307,7 +307,7 @@ struct sock {
>  	void			*sk_security;
>  #endif
>  	__u32			sk_mark;
> -	/* XXX 4 bytes hole on 64 bit */
> +	u32			sk_classid;
>  	void			(*sk_state_change)(struct sock *sk);
>  	void			(*sk_data_ready)(struct sock *sk, int bytes);
>  	void			(*sk_write_space)(struct sock *sk);
> diff --git a/net/core/sock.c b/net/core/sock.c
> index c5812bb..70bc529 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -110,6 +110,7 @@
>  #include <linux/tcp.h>
>  #include <linux/init.h>
>  #include <linux/highmem.h>
> +#include <linux/cgroup.h>
> =20
>  #include <asm/uaccess.h>
>  #include <asm/system.h>
> @@ -217,6 +218,32 @@ __u32 sysctl_rmem_default __read_mostly =3D SK_R=
MEM_MAX;
>  int sysctl_optmem_max __read_mostly =3D sizeof(unsigned long)*(2*UIO=
_MAXIOV+512);
>  EXPORT_SYMBOL(sysctl_optmem_max);
> =20
> +#ifdef CONFIG_NET_CLS_CGROUP
> +static inline u32 task_cls_classid(struct task_struct *p)
> +{
> +	return container_of(task_subsys_state(p, net_cls_subsys_id),
> +			    struct cgroup_cls_state, css).classid;
> +}
> +#else
> +int net_cls_subsys_id =3D -1;
> +EXPORT_SYMBOL_GPL(net_cls_subsys_id);
> +
> +static inline u32 task_cls_classid(struct task_struct *p)
> +{
> +	int id;
> +	u32 classid;
> +
> +	rcu_read_lock();
> +	id =3D rcu_dereference(net_cls_subsys_id);
> +	if (id >=3D 0)
> +		classid =3D container_of(task_subsys_state(p, id),
> +				       struct cgroup_cls_state, css)->classid;
> +	rcu_read_unlock();
> +
> +	return classid;
> +}
> +#endif
> +
>  static int sock_set_timeout(long *timeo_p, char __user *optval, int =
optlen)
>  {
>  	struct timeval tv;
> @@ -1064,6 +1091,9 @@ struct sock *sk_alloc(struct net *net, int fami=
ly, gfp_t priority,
>  		sock_lock_init(sk);
>  		sock_net_set(sk, get_net(net));
>  		atomic_set(&sk->sk_wmem_alloc, 1);
> +
> +		if (!in_interrupt())
> +			sk->sk_classid =3D task_cls_classid(current);

It means we cache current classid of this process.

Can it change later ?


>  	}
> =20
>  	return sk;
> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> index 2211803..32c1296 100644
> --- a/net/sched/cls_cgroup.c
> +++ b/net/sched/cls_cgroup.c
> @@ -16,14 +16,10 @@
>  #include <linux/errno.h>
>  #include <linux/skbuff.h>
>  #include <linux/cgroup.h>
> +#include <linux/rcupdate.h>
>  #include <net/rtnetlink.h>
>  #include <net/pkt_cls.h>
> -
> -struct cgroup_cls_state
> -{
> -	struct cgroup_subsys_state css;
> -	u32 classid;
> -};
> +#include <net/sock.h>
> =20
>  static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys =
*ss,
>  					       struct cgroup *cgrp);
> @@ -112,6 +108,10 @@ static int cls_cgroup_classify(struct sk_buff *s=
kb, struct tcf_proto *tp,
>  	struct cls_cgroup_head *head =3D tp->root;
>  	u32 classid;
> =20
> +	rcu_read_lock();
> +	classid =3D task_cls_state(current)->classid;
> +	rcu_read_unlock();
> +

It would be more readable to use :

static inline int task_cls_state(struct task_struct *p)
{
	int classid;

	rcu_read_lock();
	classid =3D container_of(task_subsys_state(p, net_cls_subsys_id),
				struct cgroup_cls_state, css)->classid;
	rcu_read_unlock();
	return classid;
}

=2E..

classid =3D task_cls_classid(current);

>  	/*
>  	 * Due to the nature of the classifier it is required to ignore all
>  	 * packets originating from softirq context as accessing `current'
> @@ -122,12 +122,12 @@ static int cls_cgroup_classify(struct sk_buff *=
skb, struct tcf_proto *tp,
>  	 * calls by looking at the number of nested bh disable calls becaus=
e
>  	 * softirqs always disables bh.
>  	 */
> -	if (softirq_count() !=3D SOFTIRQ_OFFSET)
> -		return -1;
> -
> -	rcu_read_lock();
> -	classid =3D task_cls_state(current)->classid;
> -	rcu_read_unlock();
> +	if (softirq_count() !=3D SOFTIRQ_OFFSET) {

Why do we still need this previous test ?

> +	 	/* If there is an sk_classid we'll use that. */
> +		if (!skb->sk)
> +			return -1;
> +		classid =3D skb->sk->sk_classid;
> +	}
> =20
>  	if (!classid)
>  		return -1;
> @@ -289,18 +289,35 @@ static struct tcf_proto_ops cls_cgroup_ops __re=
ad_mostly =3D {
> =20
>  static int __init init_cgroup_cls(void)
>  {
> -	int ret =3D register_tcf_proto_ops(&cls_cgroup_ops);
> -	if (ret)
> -		return ret;
> +	int ret;
> +
>  	ret =3D cgroup_load_subsys(&net_cls_subsys);
>  	if (ret)
> -		unregister_tcf_proto_ops(&cls_cgroup_ops);
> +		goto out;
> +
> +#ifndef CONFIG_NET_CLS_CGROUP
> +	/* We can't use rcu_assign_pointer because this is an int. */
> +	smp_wmb();
> +	net_cls_subsys_id =3D net_cls_subsys.subsys_id;
> +#endif
> +
> +	ret =3D register_tcf_proto_ops(&cls_cgroup_ops);
> +	if (ret)
> +		cgroup_unload_subsys(&net_cls_subsys);
> +
> +out:
>  	return ret;
>  }
> =20
>  static void __exit exit_cgroup_cls(void)
>  {
>  	unregister_tcf_proto_ops(&cls_cgroup_ops);
> +
> +#ifndef CONFIG_NET_CLS_CGROUP
> +	net_cls_subsys_id =3D -1;
> +	synchronize_rcu();
> +#endif
> +
>  	cgroup_unload_subsys(&net_cls_subsys);
>  }
> =20
>=20
> Thanks,


