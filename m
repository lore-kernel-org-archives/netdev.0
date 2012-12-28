From: canqun zhang <canqunzhang@gmail.com>
Subject: Re: [PATCH 01/19] netfilter: move nf_conntrack initialize out of
 pernet operations
Date: Fri, 28 Dec 2012 11:52:13 +0800
Message-ID: <CAFFEFTXT_fkF2pPSxDEEgic80NVWLqBWtFuvs6W9uDUW2aCnqw@mail.gmail.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, pablo@netfilter.org,
	ebiederm@xmission.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all
As discussed above,if the host machine create several linux
containers, there will be several  net namespaces.Resources with "nf
conntrack" are registered or unregistered on the first net
namespace(init_net),But init_net is not unregistered lastly,so
cleanuping other net namespaces  will triger painic.
If net namespaces are created  with the order of 1,2,...n,they should
be cleaned with the order of n,...2,1,so in this case init_net will be
unregistered lastly.
I fixed it up (see below). I have taken a lot of test!

diff -r 6a1a258923f5 -r 2667e89e6f50 net/core/net_namespace.c
--- a/net/core/net_namespace.c  Fri Dec 28 11:01:17 2012 +0800
+++ b/net/core/net_namespace.c  Fri Dec 28 11:05:12 2012 +0800
@@ -450,7 +450,7 @@

        list_del(&ops->list);
        for_each_net(net)
-               list_add_tail(&net->exit_list, &net_exit_list);
+              list_add(&net->exit_list, &net_exit_list);
        ops_exit_list(ops, &net_exit_list);
        ops_free_list(ops, &net_exit_lis

2012/12/28 Gao feng <gaofeng@cn.fujitsu.com>:
> canqun zhang reported a panic BUG,kernel may panic when
> unloading nf_conntrack module.
>
> It's because we reset nf_ct_destroy to NULL when we deal
> with init_net,it's too early.Some packets belongs to other
> netns still refers to the conntrack.when these packets need
> to be freed, kfree_skb will call nf_ct_destroy which is
> NULL.
>
> fix this bug by moving the nf_conntrack initialize and cleanup
> codes out of the pernet operations,this job should be done
> in module_init/exit.We can't use init_net to identify if
> it's the right time.
>
> Reported-by: canqun zhang <canqunzhang@gmail.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  include/net/netfilter/nf_conntrack_core.h | 10 +++-
>  net/netfilter/nf_conntrack_core.c         | 99 ++++++++++++-------------------
>  net/netfilter/nf_conntrack_standalone.c   | 29 ++++++---
>  3 files changed, 67 insertions(+), 71 deletions(-)
>
> diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
> index d8f5b9f..ec51a3c 100644
> --- a/include/net/netfilter/nf_conntrack_core.h
> +++ b/include/net/netfilter/nf_conntrack_core.h
> @@ -25,8 +25,14 @@ extern unsigned int nf_conntrack_in(struct net *net,
>                                     unsigned int hooknum,
>                                     struct sk_buff *skb);
>
> -extern int nf_conntrack_init(struct net *net);
> -extern void nf_conntrack_cleanup(struct net *net);
> +extern int nf_conntrack_init_net(struct net *net);
> +extern void nf_conntrack_cleanup_net(struct net *net);
> +
> +extern int nf_conntrack_init_start(void);
> +extern void nf_conntrack_cleanup_start(void);
> +
> +extern void nf_conntrack_init_end(void);
> +extern void nf_conntrack_cleanup_end(void);
>
>  extern int nf_conntrack_proto_init(struct net *net);
>  extern void nf_conntrack_proto_fini(struct net *net);
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 08cdc71..ffb2463 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1331,18 +1331,23 @@ static int untrack_refs(void)
>         return cnt;
>  }
>
> -static void nf_conntrack_cleanup_init_net(void)
> +void nf_conntrack_cleanup_start(void)
>  {
> -       while (untrack_refs() > 0)
> -               schedule();
> -
> -#ifdef CONFIG_NF_CONNTRACK_ZONES
> -       nf_ct_extend_unregister(&nf_ct_zone_extend);
> -#endif
> +       RCU_INIT_POINTER(ip_ct_attach, NULL);
>  }
>
> -static void nf_conntrack_cleanup_net(struct net *net)
> +/*
> + * Mishearing the voices in his head, our hero wonders how he's
> + * supposed to kill the mall.
> + */
> +void nf_conntrack_cleanup_net(struct net *net)
>  {
> +       /*
> +        * This makes sure all current packets have passed through
> +        * netfilter framework.  Roll on, two-stage module
> +        * delete...
> +        */
> +       synchronize_net();
>   i_see_dead_people:
>         nf_ct_iterate_cleanup(net, kill_all, NULL);
>         nf_ct_release_dying_list(net);
> @@ -1352,6 +1357,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
>         }
>
>         nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
> +       nf_conntrack_proto_fini(net);
>         nf_conntrack_helper_fini(net);
>         nf_conntrack_timeout_fini(net);
>         nf_conntrack_ecache_fini(net);
> @@ -1363,24 +1369,15 @@ static void nf_conntrack_cleanup_net(struct net *net)
>         free_percpu(net->ct.stat);
>  }
>
> -/* Mishearing the voices in his head, our hero wonders how he's
> -   supposed to kill the mall. */
> -void nf_conntrack_cleanup(struct net *net)
> +void nf_conntrack_cleanup_end(void)
>  {
> -       if (net_eq(net, &init_net))
> -               RCU_INIT_POINTER(ip_ct_attach, NULL);
> -
> -       /* This makes sure all current packets have passed through
> -          netfilter framework.  Roll on, two-stage module
> -          delete... */
> -       synchronize_net();
> -       nf_conntrack_proto_fini(net);
> -       nf_conntrack_cleanup_net(net);
> +       RCU_INIT_POINTER(nf_ct_destroy, NULL);
> +       while (untrack_refs() > 0)
> +               schedule();
>
> -       if (net_eq(net, &init_net)) {
> -               RCU_INIT_POINTER(nf_ct_destroy, NULL);
> -               nf_conntrack_cleanup_init_net();
> -       }
> +#ifdef CONFIG_NF_CONNTRACK_ZONES
> +       nf_ct_extend_unregister(&nf_ct_zone_extend);
> +#endif
>  }
>
>  void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls)
> @@ -1473,7 +1470,7 @@ void nf_ct_untracked_status_or(unsigned long bits)
>  }
>  EXPORT_SYMBOL_GPL(nf_ct_untracked_status_or);
>
> -static int nf_conntrack_init_init_net(void)
> +int nf_conntrack_init_start(void)
>  {
>         int max_factor = 8;
>         int ret, cpu;
> @@ -1527,7 +1524,7 @@ err_extend:
>  #define UNCONFIRMED_NULLS_VAL  ((1<<30)+0)
>  #define DYING_NULLS_VAL                ((1<<30)+1)
>
> -static int nf_conntrack_init_net(struct net *net)
> +int nf_conntrack_init_net(struct net *net)
>  {
>         int ret;
>
> @@ -1580,7 +1577,12 @@ static int nf_conntrack_init_net(struct net *net)
>         ret = nf_conntrack_helper_init(net);
>         if (ret < 0)
>                 goto err_helper;
> +       ret = nf_conntrack_proto_init(net);
> +       if (ret < 0)
> +               goto out_proto;
>         return 0;
> +out_proto:
> +       nf_conntrack_helper_fini(net);
>  err_helper:
>         nf_conntrack_timeout_fini(net);
>  err_timeout:
> @@ -1603,42 +1605,17 @@ err_stat:
>         return ret;
>  }
>
> +void nf_conntrack_init_end(void)
> +{
> +       /* For use by REJECT target */
> +       RCU_INIT_POINTER(ip_ct_attach, nf_conntrack_attach);
> +       RCU_INIT_POINTER(nf_ct_destroy, destroy_conntrack);
> +
> +       /* Howto get NAT offsets */
> +       RCU_INIT_POINTER(nf_ct_nat_offset, NULL);
> +}
> +
>  s16 (*nf_ct_nat_offset)(const struct nf_conn *ct,
>                         enum ip_conntrack_dir dir,
>                         u32 seq);
>  EXPORT_SYMBOL_GPL(nf_ct_nat_offset);
> -
> -int nf_conntrack_init(struct net *net)
> -{
> -       int ret;
> -
> -       if (net_eq(net, &init_net)) {
> -               ret = nf_conntrack_init_init_net();
> -               if (ret < 0)
> -                       goto out_init_net;
> -       }
> -       ret = nf_conntrack_proto_init(net);
> -       if (ret < 0)
> -               goto out_proto;
> -       ret = nf_conntrack_init_net(net);
> -       if (ret < 0)
> -               goto out_net;
> -
> -       if (net_eq(net, &init_net)) {
> -               /* For use by REJECT target */
> -               RCU_INIT_POINTER(ip_ct_attach, nf_conntrack_attach);
> -               RCU_INIT_POINTER(nf_ct_destroy, destroy_conntrack);
> -
> -               /* Howto get NAT offsets */
> -               RCU_INIT_POINTER(nf_ct_nat_offset, NULL);
> -       }
> -       return 0;
> -
> -out_net:
> -       nf_conntrack_proto_fini(net);
> -out_proto:
> -       if (net_eq(net, &init_net))
> -               nf_conntrack_cleanup_init_net();
> -out_init_net:
> -       return ret;
> -}
> diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
> index 363285d..00bf93c 100644
> --- a/net/netfilter/nf_conntrack_standalone.c
> +++ b/net/netfilter/nf_conntrack_standalone.c
> @@ -530,11 +530,11 @@ static void nf_conntrack_standalone_fini_sysctl(struct net *net)
>  }
>  #endif /* CONFIG_SYSCTL */
>
> -static int nf_conntrack_net_init(struct net *net)
> +static int nf_conntrack_pernet_init(struct net *net)
>  {
>         int ret;
>
> -       ret = nf_conntrack_init(net);
> +       ret = nf_conntrack_init_net(net);
>         if (ret < 0)
>                 goto out_init;
>         ret = nf_conntrack_standalone_init_proc(net);
> @@ -550,31 +550,44 @@ static int nf_conntrack_net_init(struct net *net)
>  out_sysctl:
>         nf_conntrack_standalone_fini_proc(net);
>  out_proc:
> -       nf_conntrack_cleanup(net);
> +       nf_conntrack_cleanup_net(net);
>  out_init:
>         return ret;
>  }
>
> -static void nf_conntrack_net_exit(struct net *net)
> +static void nf_conntrack_pernet_exit(struct net *net)
>  {
>         nf_conntrack_standalone_fini_sysctl(net);
>         nf_conntrack_standalone_fini_proc(net);
> -       nf_conntrack_cleanup(net);
> +       nf_conntrack_cleanup_net(net);
>  }
>
>  static struct pernet_operations nf_conntrack_net_ops = {
> -       .init = nf_conntrack_net_init,
> -       .exit = nf_conntrack_net_exit,
> +       .init = nf_conntrack_pernet_init,
> +       .exit = nf_conntrack_pernet_exit,
>  };
>
>  static int __init nf_conntrack_standalone_init(void)
>  {
> -       return register_pernet_subsys(&nf_conntrack_net_ops);
> +       int ret = nf_conntrack_init_start();
> +       if (ret < 0)
> +               goto out_start;
> +       ret = register_pernet_subsys(&nf_conntrack_net_ops);
> +       if (ret < 0)
> +               goto out_pernet;
> +       nf_conntrack_init_end();
> +       return 0;
> +out_pernet:
> +       nf_conntrack_cleanup_end();
> +out_start:
> +       return ret;
>  }
>
>  static void __exit nf_conntrack_standalone_fini(void)
>  {
> +       nf_conntrack_cleanup_start();
>         unregister_pernet_subsys(&nf_conntrack_net_ops);
> +       nf_conntrack_cleanup_end();
>  }
>
>  module_init(nf_conntrack_standalone_init);
> --
> 1.7.11.7
>
