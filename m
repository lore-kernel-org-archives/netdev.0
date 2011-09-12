From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC/PATCH] net: add deferred flow cache flush function to be
 used in xfrm
Date: Mon, 12 Sep 2011 15:58:07 +0200
Message-ID: <1315835887.2318.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1315829846-15016-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, timo.teras@iki.fi
To: madalin.bucur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44374 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754774Ab1ILN6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 09:58:04 -0400
Received: by bkbzt4 with SMTP id zt4so2627450bkb.19
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2011 06:58:03 -0700 (PDT)
In-Reply-To: <1315829846-15016-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 septembre 2011 =C3=A0 15:17 +0300, Madalin Bucur a =C3=A9cr=
it :
> The xfrm garbage collector calls flow_cache_flush() that might sleep.
> The xfrm garbage collector can be called from softirq context, such a=
s from
> net_rx_action() through ip_forward(). Added flow_cache_flush_deferred=
()
> function that uses the kernel-global work queue to leave the actual
> cache flush processing outside the softirq context.
>=20
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> ---
>  include/net/flow.h     |    1 +
>  net/core/flow.c        |   12 ++++++++++++
>  net/xfrm/xfrm_policy.c |    2 +-
>  3 files changed, 14 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/net/flow.h b/include/net/flow.h
> index c6d5fe5..7b4bc88 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -188,6 +188,7 @@ extern struct flow_cache_object *flow_cache_looku=
p(
>  		u8 dir, flow_resolve_t resolver, void *ctx);
> =20
>  extern void flow_cache_flush(void);
> +extern void flow_cache_flush_deferred(void);
>  extern atomic_t flow_cache_genid;
> =20
>  #endif
> diff --git a/net/core/flow.c b/net/core/flow.c
> index 990703b..4edef63 100644
> --- a/net/core/flow.c
> +++ b/net/core/flow.c
> @@ -352,6 +352,18 @@ void flow_cache_flush(void)
>  	put_online_cpus();
>  }
> =20
> +static void flow_cache_flush_wq(struct work_struct *work)
> +{
> +	flow_cache_flush();
> +}
> +
> +static DECLARE_WORK(flow_cache_flush_work, flow_cache_flush_wq);
> +
> +void flow_cache_flush_deferred(void)
> +{
> +	schedule_work(&flow_cache_flush_work);
> +}
> +
>  static int __cpuinit flow_cache_cpu_prepare(struct flow_cache *fc, i=
nt cpu)
>  {
>  	struct flow_cache_percpu *fcp =3D per_cpu_ptr(fc->percpu, cpu);
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 5ce74a3..62b1af8 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -2274,7 +2274,7 @@ static void __xfrm_garbage_collect(struct net *=
net)
>  {
>  	struct dst_entry *head, *next;
> =20
> -	flow_cache_flush();
> +	flow_cache_flush_deferred();
> =20
>  	spin_lock_bh(&xfrm_policy_sk_bundle_lock);
>  	head =3D xfrm_policy_sk_bundles;

Problem is sometime we dont want to defer and are in process context.

xfrm_dev_event(  event =3D=3D NETDEV_DOWN) is probably a place we dont =
want
to defer the garbage collection.
