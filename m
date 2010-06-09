From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: gen_kill_estimator() rcu fixes
Date: Wed, 9 Jun 2010 12:50:35 +0000
Message-ID: <20100609125035.GD7308@ff.dom.local>
References: <1275921171.2545.102.camel@edumazet-laptop> <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com> <1275924638.2545.121.camel@edumazet-laptop> <1275926151.2545.126.camel@edumazet-laptop> <1275929761.2545.159.camel@edumazet-laptop> <1276076415.2442.92.camel@edumazet-laptop> <1276077416.2442.97.camel@edumazet-laptop> <20100609104100.GB7308@ff.dom.local> <1276085363.2442.125.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33706 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757391Ab0FIMuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 08:50:39 -0400
Received: by fxm8 with SMTP id 8so3550377fxm.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 05:50:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1276085363.2442.125.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 09, 2010 at 02:09:23PM +0200, Eric Dumazet wrote:
> Le mercredi 09 juin 2010 ?? 10:41 +0000, Jarek Poplawski a =E9crit :
>=20
> > Spelling suggestion: xt_rateest_free_rcu?
> >=20
> > Since it's only 3 places I'd consider adding little comments,
> > who needs this call_rcu (like in qdisc_destroy).
> >=20
> > Anyway this patch looks OK to me.
> >=20
>=20
> Thanks for reviewing, you are right about typo and adding some commen=
ts.
>=20
> What about following ?

Very nice! (But let's remember these comments aren't very precise
wrt. bstats at the moment ;-)

Thanks,
Jarek P.

>=20
> [PATCH v2] pkt_sched: gen_kill_estimator() rcu fixes
>=20
> gen_kill_estimator() API is incomplete or not well documented, since
> caller should make sure an RCU grace period is respected before
> freeing stats_lock.
>=20
> This was partially addressed in commit 5d944c640b4=20
> (gen_estimator: deadlock fix), but same problem exist for all
> gen_kill_estimator() users, if lock they use is not already RCU
> protected.
>=20
> A code review shows xt_RATEEST.c, act_api.c, act_police.c have this
> problem. Other are ok because they use qdisc lock, already RCU
> protected.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  include/net/act_api.h              |    2 ++
>  include/net/netfilter/xt_rateest.h |    1 +
>  net/core/gen_estimator.c           |    1 +
>  net/netfilter/xt_RATEEST.c         |   12 +++++++++++-
>  net/sched/act_api.c                |   11 ++++++++++-
>  net/sched/act_police.c             |   12 +++++++++++-
>  6 files changed, 36 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/net/act_api.h b/include/net/act_api.h
> index c05fd71..bab385f 100644
> --- a/include/net/act_api.h
> +++ b/include/net/act_api.h
> @@ -20,6 +20,7 @@ struct tcf_common {
>  	struct gnet_stats_queue		tcfc_qstats;
>  	struct gnet_stats_rate_est	tcfc_rate_est;
>  	spinlock_t			tcfc_lock;
> +	struct rcu_head			tcfc_rcu;
>  };
>  #define tcf_next	common.tcfc_next
>  #define tcf_index	common.tcfc_index
> @@ -32,6 +33,7 @@ struct tcf_common {
>  #define tcf_qstats	common.tcfc_qstats
>  #define tcf_rate_est	common.tcfc_rate_est
>  #define tcf_lock	common.tcfc_lock
> +#define tcf_rcu		common.tcfc_rcu
> =20
>  struct tcf_police {
>  	struct tcf_common	common;
> diff --git a/include/net/netfilter/xt_rateest.h b/include/net/netfilt=
er/xt_rateest.h
> index ddbf37e..5e14277 100644
> --- a/include/net/netfilter/xt_rateest.h
> +++ b/include/net/netfilter/xt_rateest.h
> @@ -9,6 +9,7 @@ struct xt_rateest {
>  	struct gnet_estimator		params;
>  	struct gnet_stats_rate_est	rstats;
>  	struct gnet_stats_basic_packed	bstats;
> +	struct rcu_head			rcu;
>  };
> =20
>  extern struct xt_rateest *xt_rateest_lookup(const char *name);
> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
> index 785e527..9fbe7f7 100644
> --- a/net/core/gen_estimator.c
> +++ b/net/core/gen_estimator.c
> @@ -263,6 +263,7 @@ static void __gen_kill_estimator(struct rcu_head =
*head)
>   *
>   * Removes the rate estimator specified by &bstats and &rate_est.
>   *
> + * Note : Caller should respect an RCU grace period before freeing s=
tats_lock
>   */
>  void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
>  			struct gnet_stats_rate_est *rate_est)
> diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
> index 69c01e1..de079ab 100644
> --- a/net/netfilter/xt_RATEEST.c
> +++ b/net/netfilter/xt_RATEEST.c
> @@ -60,13 +60,22 @@ struct xt_rateest *xt_rateest_lookup(const char *=
name)
>  }
>  EXPORT_SYMBOL_GPL(xt_rateest_lookup);
> =20
> +static void xt_rateest_free_rcu(struct rcu_head *head)
> +{
> +	kfree(container_of(head, struct xt_rateest, rcu));
> +}
> +
>  void xt_rateest_put(struct xt_rateest *est)
>  {
>  	mutex_lock(&xt_rateest_mutex);
>  	if (--est->refcnt =3D=3D 0) {
>  		hlist_del(&est->list);
>  		gen_kill_estimator(&est->bstats, &est->rstats);
> -		kfree(est);
> +		/*
> +		 * gen_estimator est_timer() might access est->lock or bstats,
> +		 * wait a RCU grace period before freeing 'est'
> +		 */
> +		call_rcu(&est->rcu, xt_rateest_free_rcu);
>  	}
>  	mutex_unlock(&xt_rateest_mutex);
>  }
> @@ -179,6 +188,7 @@ static int __init xt_rateest_tg_init(void)
>  static void __exit xt_rateest_tg_fini(void)
>  {
>  	xt_unregister_target(&xt_rateest_tg_reg);
> +	rcu_barrier(); /* Wait for completion of call_rcu()'s (xt_rateest_f=
ree_rcu) */
>  }
> =20
> =20
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 972378f..23b25f8 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -26,6 +26,11 @@
>  #include <net/act_api.h>
>  #include <net/netlink.h>
> =20
> +static void tcf_common_free_rcu(struct rcu_head *head)
> +{
> +	kfree(container_of(head, struct tcf_common, tcfc_rcu));
> +}
> +
>  void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hin=
fo)
>  {
>  	unsigned int h =3D tcf_hash(p->tcfc_index, hinfo->hmask);
> @@ -38,7 +43,11 @@ void tcf_hash_destroy(struct tcf_common *p, struct=
 tcf_hashinfo *hinfo)
>  			write_unlock_bh(hinfo->lock);
>  			gen_kill_estimator(&p->tcfc_bstats,
>  					   &p->tcfc_rate_est);
> -			kfree(p);
> +			/*
> +			 * gen_estimator est_timer() might access p->tcfc_lock
> +			 * or bstats, wait a RCU grace period before freeing p
> +			 */
> +			call_rcu(&p->tcfc_rcu, tcf_common_free_rcu);
>  			return;
>  		}
>  	}
> diff --git a/net/sched/act_police.c b/net/sched/act_police.c
> index 654f73d..537a487 100644
> --- a/net/sched/act_police.c
> +++ b/net/sched/act_police.c
> @@ -97,6 +97,11 @@ nla_put_failure:
>  	goto done;
>  }
> =20
> +static void tcf_police_free_rcu(struct rcu_head *head)
> +{
> +	kfree(container_of(head, struct tcf_police, tcf_rcu));
> +}
> +
>  static void tcf_police_destroy(struct tcf_police *p)
>  {
>  	unsigned int h =3D tcf_hash(p->tcf_index, POL_TAB_MASK);
> @@ -113,7 +118,11 @@ static void tcf_police_destroy(struct tcf_police=
 *p)
>  				qdisc_put_rtab(p->tcfp_R_tab);
>  			if (p->tcfp_P_tab)
>  				qdisc_put_rtab(p->tcfp_P_tab);
> -			kfree(p);
> +			/*
> +			 * gen_estimator est_timer() might access p->tcf_lock
> +			 * or bstats, wait a RCU grace period before freeing p
> +			 */
> +			call_rcu(&p->tcf_rcu, tcf_police_free_rcu);
>  			return;
>  		}
>  	}
> @@ -397,6 +406,7 @@ static void __exit
>  police_cleanup_module(void)
>  {
>  	tcf_unregister_action(&act_police_ops);
> +	rcu_barrier(); /* Wait for completion of call_rcu()'s (tcf_police_f=
ree_rcu) */
>  }
> =20
>  module_init(police_init_module);
>=20
>=20
