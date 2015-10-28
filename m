From: Dan Streetman <dan.streetman@canonical.com>
Subject: Re: [PATCH] xfrm: dst_entries_init() per-net dst_ops
Date: Wed, 28 Oct 2015 09:32:47 -0400
Message-ID: <CAOZ2QJMuPoSrrFdudiGYQ4PjvELbonqg94X2mQaUhZ-R5yS0hw@mail.gmail.com>
References: <1445962519-16133-1-git-send-email-dan.streetman@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Dan Streetman <dan.streetman@canonical.com>,
	Dan Streetman <ddstreet@ieee.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35976 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932548AbbJ1Nd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 09:33:28 -0400
Received: by ioll68 with SMTP id l68so10261073iol.3
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 06:33:27 -0700 (PDT)
In-Reply-To: <1445962519-16133-1-git-send-email-dan.streetman@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 12:15 PM,  <dan.streetman@canonical.com> wrote:
> From: Dan Streetman <dan.streetman@canonical.com>
>
> The ipv4 and ipv6 xfrms each create a template dst_ops object, and
> perform dst_entries_init() on the template objects.  Then each net
> namespace has its net.xfrm.xfrm[46]_dst_ops field set to the template
> values.  The problem with that is the dst_ops.pcpuc_entries field is
> a percpu counter and cannot be used correctly by simply copying it to
> another object.
>
> The result of this is a very subtle bug; changes to the dst entries
> counter from one net namespace may sometimes get applied to a different
> net namespace dst entries counter.  This is because of how the percpu
> counter works; it has a main count field as well as a pointer to the
> percpu variables.  Each net namespace maintains its own main count
> variable, but all point to one set of percpu variables.  When any net
> namespace happens to change one of the percpu variables to outside its
> small batch range, its count is moved to the net namespace's main count
> variable.  So with multiple net namespaces operating concurrently, the
> dst_ops entries counter can stray from the actual value that it should
> be; if counts are consistently moved from one net namespace to another
> (which my testing showed is likely), then one net namespace winds up
> with a negative dst_ops count (which is reported as 0) while another
> winds up with a continually increasing count, eventually reaching its
> gc_thresh limit, which causes all new traffic on the net namespace to
> fail with -ENOBUFS.
>
> This removes the dst_entries_init (and dst_entries_destroy) call for
> the template dst_ops objects; their counters will never be used.
> Instead dst_entries_init is called for each net namespace's dst_ops
> object, right after copying its values from the template, and

Well I'm not sure why my test kernel booted, while the test robot
found the bug of GFP_KERNEL percpu counter alloc during atomic
context.  Thanks test robot!

I'll update the patch and resend.


> dst_entries_destroy is called when the net namespace is removed.
>
> Signed-off-by: Dan Streetman <dan.streetman@canonical.com>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
>  net/ipv4/xfrm4_policy.c |  5 +++--
>  net/ipv6/xfrm6_policy.c | 10 ++++------
>  net/xfrm/xfrm_policy.c  | 25 +++++++++++++++++++++++--
>  3 files changed, 30 insertions(+), 10 deletions(-)
>
> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
> index f2606b9..5f747ee 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -235,6 +235,9 @@ static void xfrm4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
>         xfrm_dst_ifdown(dst, dev);
>  }
>
> +/* This is used as a template only; the dst_entries counter is not
> + * initialized for this, but must be on per-net copies of this
> + */
>  static struct dst_ops xfrm4_dst_ops = {
>         .family =               AF_INET,
>         .gc =                   xfrm4_garbage_collect,
> @@ -325,8 +328,6 @@ static void __init xfrm4_policy_init(void)
>
>  void __init xfrm4_init(void)
>  {
> -       dst_entries_init(&xfrm4_dst_ops);
> -
>         xfrm4_state_init();
>         xfrm4_policy_init();
>         xfrm4_protocol_init();
> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
> index 2cc5840..b895ec1 100644
> --- a/net/ipv6/xfrm6_policy.c
> +++ b/net/ipv6/xfrm6_policy.c
> @@ -279,6 +279,9 @@ static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
>         xfrm_dst_ifdown(dst, dev);
>  }
>
> +/* This is used as a template only; the dst_entries counter is not
> + * initialized for this, but must be on per-net copies of this
> + */
>  static struct dst_ops xfrm6_dst_ops = {
>         .family =               AF_INET6,
>         .gc =                   xfrm6_garbage_collect,
> @@ -376,13 +379,9 @@ int __init xfrm6_init(void)
>  {
>         int ret;
>
> -       dst_entries_init(&xfrm6_dst_ops);
> -
>         ret = xfrm6_policy_init();
> -       if (ret) {
> -               dst_entries_destroy(&xfrm6_dst_ops);
> +       if (ret)
>                 goto out;
> -       }
>         ret = xfrm6_state_init();
>         if (ret)
>                 goto out_policy;
> @@ -411,5 +410,4 @@ void xfrm6_fini(void)
>         xfrm6_protocol_fini();
>         xfrm6_policy_fini();
>         xfrm6_state_fini();
> -       dst_entries_destroy(&xfrm6_dst_ops);
>  }
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 09bfcba..5381719 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -2896,12 +2896,32 @@ static void __net_init xfrm_dst_ops_init(struct net *net)
>
>         rcu_read_lock();
>         afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET]);
> -       if (afinfo)
> +       if (afinfo) {
>                 net->xfrm.xfrm4_dst_ops = *afinfo->dst_ops;
> +               dst_entries_init(&net->xfrm.xfrm4_dst_ops);
> +       }
>  #if IS_ENABLED(CONFIG_IPV6)
>         afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET6]);
> -       if (afinfo)
> +       if (afinfo) {
>                 net->xfrm.xfrm6_dst_ops = *afinfo->dst_ops;
> +               dst_entries_init(&net->xfrm.xfrm6_dst_ops);
> +       }
> +#endif
> +       rcu_read_unlock();
> +}
> +
> +static void xfrm_dst_ops_fini(struct net *net)
> +{
> +       struct xfrm_policy_afinfo *afinfo;
> +
> +       rcu_read_lock();
> +       afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET]);
> +       if (afinfo)
> +               dst_entries_destroy(&net->xfrm.xfrm4_dst_ops);
> +#if IS_ENABLED(CONFIG_IPV6)
> +       afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET6]);
> +       if (afinfo)
> +               dst_entries_destroy(&net->xfrm.xfrm6_dst_ops);
>  #endif
>         rcu_read_unlock();
>  }
> @@ -3085,6 +3105,7 @@ static void __net_exit xfrm_net_exit(struct net *net)
>  {
>         flow_cache_fini(net);
>         xfrm_sysctl_fini(net);
> +       xfrm_dst_ops_fini(net);
>         xfrm_policy_fini(net);
>         xfrm_state_fini(net);
>         xfrm_statistics_fini(net);
> --
> 2.5.0
>
