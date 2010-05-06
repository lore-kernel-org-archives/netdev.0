From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer
Date: Thu, 06 May 2010 19:32:35 +0200
Message-ID: <1273167155.2853.49.camel@edumazet-laptop>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:53112 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756327Ab0EFRcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 13:32:42 -0400
Received: by bwz19 with SMTP id 19so125878bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 10:32:40 -0700 (PDT)
In-Reply-To: <20100506171639.GA5063@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 13:16 -0400, Neil Horman a =C3=A9crit :
> A while back there was a discussion regarding the rt_secret_interval =
timer.
> Given that we've had the ability to do emergency route cache rebuilds=
 for awhile
> now, based on a statistical analysis of the various hash chain length=
s in the
> cache, the use of the flush timer is somewhat redundant.  This patch =
removes the
> rt_secret_interval sysctl, allowing us to rely solely on the statisti=
cal
> analysis mechanism to determine the need for route cache flushes.
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20
>=20

Nice cleanup try Neil, but this gives to attackers more time to hit the
cache (infinite time should be enough as a matter of fact ;) )

Hints :=20

- What is the initial value of rt_genid ?

- How/When is it changed (full 32 bits are changed or small
perturbations ? check rt_cache_invalidate())

Thanks

>  include/net/netns/ipv4.h |    1=20
>  net/ipv4/route.c         |  108 ------------------------------------=
-----------
>  2 files changed, 2 insertions(+), 107 deletions(-)
>=20
> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
> index ae07fee..d68c3f1 100644
> --- a/include/net/netns/ipv4.h
> +++ b/include/net/netns/ipv4.h
> @@ -55,7 +55,6 @@ struct netns_ipv4 {
>  	int sysctl_rt_cache_rebuild_count;
>  	int current_rt_cache_rebuild_count;
> =20
> -	struct timer_list rt_secret_timer;
>  	atomic_t rt_genid;
> =20
>  #ifdef CONFIG_IP_MROUTE
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index a947428..ffd3da1 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -129,7 +129,6 @@ static int ip_rt_gc_elasticity __read_mostly	=3D =
8;
>  static int ip_rt_mtu_expires __read_mostly	=3D 10 * 60 * HZ;
>  static int ip_rt_min_pmtu __read_mostly		=3D 512 + 20 + 20;
>  static int ip_rt_min_advmss __read_mostly	=3D 256;
> -static int ip_rt_secret_interval __read_mostly	=3D 10 * 60 * HZ;
>  static int rt_chain_length_max __read_mostly	=3D 20;
> =20
>  static struct delayed_work expires_work;
> @@ -918,32 +917,11 @@ void rt_cache_flush_batch(void)
>  	rt_do_flush(!in_softirq());
>  }
> =20
> -/*
> - * We change rt_genid and let gc do the cleanup
> - */
> -static void rt_secret_rebuild(unsigned long __net)
> -{
> -	struct net *net =3D (struct net *)__net;
> -	rt_cache_invalidate(net);
> -	mod_timer(&net->ipv4.rt_secret_timer, jiffies + ip_rt_secret_interv=
al);
> -}
> -
> -static void rt_secret_rebuild_oneshot(struct net *net)
> -{
> -	del_timer_sync(&net->ipv4.rt_secret_timer);
> -	rt_cache_invalidate(net);
> -	if (ip_rt_secret_interval)
> -		mod_timer(&net->ipv4.rt_secret_timer, jiffies + ip_rt_secret_inter=
val);
> -}
> -
>  static void rt_emergency_hash_rebuild(struct net *net)
>  {
> -	if (net_ratelimit()) {
> +	if (net_ratelimit())
>  		printk(KERN_WARNING "Route hash chain too long!\n");
> -		printk(KERN_WARNING "Adjust your secret_interval!\n");
> -	}
> -
> -	rt_secret_rebuild_oneshot(net);
> +	rt_cache_invalidate(net);
>  }
> =20
>  /*
> @@ -3101,48 +3079,6 @@ static int ipv4_sysctl_rtcache_flush(ctl_table=
 *__ctl, int write,
>  	return -EINVAL;
>  }
> =20
> -static void rt_secret_reschedule(int old)
> -{
> -	struct net *net;
> -	int new =3D ip_rt_secret_interval;
> -	int diff =3D new - old;
> -
> -	if (!diff)
> -		return;
> -
> -	rtnl_lock();
> -	for_each_net(net) {
> -		int deleted =3D del_timer_sync(&net->ipv4.rt_secret_timer);
> -		long time;
> -
> -		if (!new)
> -			continue;
> -
> -		if (deleted) {
> -			time =3D net->ipv4.rt_secret_timer.expires - jiffies;
> -
> -			if (time <=3D 0 || (time +=3D diff) <=3D 0)
> -				time =3D 0;
> -		} else
> -			time =3D new;
> -
> -		mod_timer(&net->ipv4.rt_secret_timer, jiffies + time);
> -	}
> -	rtnl_unlock();
> -}
> -
> -static int ipv4_sysctl_rt_secret_interval(ctl_table *ctl, int write,
> -					  void __user *buffer, size_t *lenp,
> -					  loff_t *ppos)
> -{
> -	int old =3D ip_rt_secret_interval;
> -	int ret =3D proc_dointvec_jiffies(ctl, write, buffer, lenp, ppos);
> -
> -	rt_secret_reschedule(old);
> -
> -	return ret;
> -}
> -
>  static ctl_table ipv4_route_table[] =3D {
>  	{
>  		.procname	=3D "gc_thresh",
> @@ -3251,13 +3187,6 @@ static ctl_table ipv4_route_table[] =3D {
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec,
>  	},
> -	{
> -		.procname	=3D "secret_interval",
> -		.data		=3D &ip_rt_secret_interval,
> -		.maxlen		=3D sizeof(int),
> -		.mode		=3D 0644,
> -		.proc_handler	=3D ipv4_sysctl_rt_secret_interval,
> -	},
>  	{ }
>  };
> =20
> @@ -3337,36 +3266,6 @@ static __net_initdata struct pernet_operations=
 sysctl_route_ops =3D {
>  #endif
> =20
>=20
> -static __net_init int rt_secret_timer_init(struct net *net)
> -{
> -	atomic_set(&net->ipv4.rt_genid,
> -			(int) ((num_physpages ^ (num_physpages>>8)) ^
> -			(jiffies ^ (jiffies >> 7))));
> -
> -	net->ipv4.rt_secret_timer.function =3D rt_secret_rebuild;
> -	net->ipv4.rt_secret_timer.data =3D (unsigned long)net;
> -	init_timer_deferrable(&net->ipv4.rt_secret_timer);
> -
> -	if (ip_rt_secret_interval) {
> -		net->ipv4.rt_secret_timer.expires =3D
> -			jiffies + net_random() % ip_rt_secret_interval +
> -			ip_rt_secret_interval;
> -		add_timer(&net->ipv4.rt_secret_timer);
> -	}
> -	return 0;
> -}
> -
> -static __net_exit void rt_secret_timer_exit(struct net *net)
> -{
> -	del_timer_sync(&net->ipv4.rt_secret_timer);
> -}
> -
> -static __net_initdata struct pernet_operations rt_secret_timer_ops =3D=
 {
> -	.init =3D rt_secret_timer_init,
> -	.exit =3D rt_secret_timer_exit,
> -};
> -
> -
>  #ifdef CONFIG_NET_CLS_ROUTE
>  struct ip_rt_acct __percpu *ip_rt_acct __read_mostly;
>  #endif /* CONFIG_NET_CLS_ROUTE */
> @@ -3424,9 +3323,6 @@ int __init ip_rt_init(void)
>  	schedule_delayed_work(&expires_work,
>  		net_random() % ip_rt_gc_interval + ip_rt_gc_interval);
> =20
> -	if (register_pernet_subsys(&rt_secret_timer_ops))
> -		printk(KERN_ERR "Unable to setup rt_secret_timer\n");
> -
>  	if (ip_rt_proc_init())
>  		printk(KERN_ERR "Unable to create route proc files\n");
>  #ifdef CONFIG_XFRM
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


