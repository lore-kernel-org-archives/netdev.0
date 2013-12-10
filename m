From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [patch net-next v2 4/5] neigh: restore old behaviour of default
 parms values
Date: Tue, 10 Dec 2013 16:09:05 +0200
Message-ID: <CAJZOPZ+9uFxfSbatKmOUy1pqPC9qQPnH5O90YzB8VAMK-p72VQ@mail.gmail.com>
References: <1386440817-7846-1-git-send-email-jiri@resnulli.us>
	<1386440817-7846-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:47555 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766Ab3LJOJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 09:09:07 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so7713707pbb.32
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 06:09:05 -0800 (PST)
In-Reply-To: <1386440817-7846-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 7, 2013 at 8:26 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Previously inet devices were only constructed when addresses are added.
> Therefore the default neigh parms values they get are the ones at the
> time of these operations.

>
> Now that we're creating inet devices earlier, this changes the behaviour
> of default neigh parms values in an incompatible way (see bug #8519).
>
> This patch creates a compromise by setting the default values at the
> same point as before but only for those that have not been explicitly
> set by the user since the inet device's creation.
>
> Introduced by:
> commit 8030f54499925d073a88c09f30d5d844fb1b3190
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Thu Feb 22 01:53:47 2007 +0900
>
>     [IPV4] devinet: Register inetdev earlier.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/linux/inetdevice.h |  7 +++++
>  include/net/neighbour.h    | 13 ++++++++
>  net/core/neighbour.c       | 74 ++++++++++++++++++++++++++++++++++++++++++----
>  net/ipv4/devinet.c         |  2 ++
>  net/ipv4/ipmr.c            |  2 ++
>  5 files changed, 92 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
> index 0d678ae..ae174ca 100644
> --- a/include/linux/inetdevice.h
> +++ b/include/linux/inetdevice.h
> @@ -220,6 +220,13 @@ static inline struct in_device *__in_dev_get_rtnl(const struct net_device *dev)
>         return rtnl_dereference(dev->ip_ptr);
>  }
>
> +static inline struct neigh_parms *__in_dev_arp_parms_get_rcu(const struct net_device *dev)
> +{
> +       struct in_device *in_dev = __in_dev_get_rcu(dev);
> +
> +       return in_dev ? in_dev->arp_parms : NULL;
> +}
> +
>  void in_dev_finish_destroy(struct in_device *idev);
>
>  static inline void in_dev_put(struct in_device *idev)
> diff --git a/include/net/neighbour.h b/include/net/neighbour.h
> index 95615c9..41b1ce6 100644
> --- a/include/net/neighbour.h
> +++ b/include/net/neighbour.h
> @@ -21,6 +21,7 @@
>  #include <linux/skbuff.h>
>  #include <linux/rcupdate.h>
>  #include <linux/seq_file.h>
> +#include <linux/bitmap.h>
>
>  #include <linux/err.h>
>  #include <linux/sysctl.h>
> @@ -81,16 +82,28 @@ struct neigh_parms {
>
>         int     reachable_time;
>         int     data[NEIGH_VAR_DATA_MAX];
> +       DECLARE_BITMAP(data_state, NEIGH_VAR_DATA_MAX);
>  };
>
>  static inline void neigh_var_set(struct neigh_parms *p, int index, int val)
>  {
> +       set_bit(index, p->data_state);
>         p->data[index] = val;
>  }
>
>  #define NEIGH_VAR(p, attr) ((p)->data[NEIGH_VAR_ ## attr])
>  #define NEIGH_VAR_SET(p, attr, val) neigh_var_set(p, NEIGH_VAR_ ## attr, val)
>
> +static inline void neigh_parms_data_state_setall(struct neigh_parms *p)
> +{
> +       bitmap_fill(p->data_state, NEIGH_VAR_DATA_MAX);
> +}
> +
> +static inline void neigh_parms_data_state_cleanall(struct neigh_parms *p)
> +{
> +       bitmap_zero(p->data_state, NEIGH_VAR_DATA_MAX);
> +}
> +
>  struct neigh_statistics {
>         unsigned long allocs;           /* number of allocated neighs */
>         unsigned long destroys;         /* number of destroyed neighs */
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 65ead08..c4a7879 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -38,6 +38,7 @@
>  #include <linux/random.h>
>  #include <linux/string.h>
>  #include <linux/log2.h>
> +#include <linux/inetdevice.h>
>
>  #define DEBUG
>  #define NEIGH_DEBUG 1
> @@ -1464,6 +1465,8 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
>                 p->next         = tbl->parms.next;
>                 tbl->parms.next = p;
>                 write_unlock_bh(&tbl->lock);
> +
> +               neigh_parms_data_state_cleanall(p);
>         }
>         return p;
>  }
> @@ -2813,22 +2816,68 @@ static int proc_unres_qlen(struct ctl_table *ctl, int write,
>         return ret;
>  }
>
> +static struct neigh_parms *neigh_get_dev_parms_rcu(struct net_device *dev,
> +                                                  int family)
> +{
> +       if (family == AF_INET)
> +               return __in_dev_arp_parms_get_rcu(dev);
> +       return NULL;
> +}
> +
> +static void neigh_copy_dflt_parms(struct net *net, struct neigh_parms *p,
> +                                 int index)
> +{
> +       struct net_device *dev;
> +       int family = neigh_parms_family(p);
> +
> +       rcu_read_lock();
> +       for_each_netdev_rcu(net, dev) {
> +               struct neigh_parms *dst_p =
> +                               neigh_get_dev_parms_rcu(dev, family);
> +
> +               if (dst_p && !test_bit(index, dst_p->data_state))
> +                       dst_p->data[index] = p->data[index];
> +       }
> +       rcu_read_unlock();
> +}
> +
> +static void neigh_proc_update(struct ctl_table *ctl, int write)
> +{
> +       struct net_device *dev = ctl->extra1;
> +       struct neigh_parms *p = ctl->extra2;
> +       struct net *net = p->net;


Jiri, net-next build fails as of this line, if one doesn't have
CONFIG_NET_NS on their .config

net/core/neighbour.c: In function neigh_proc_update:
net/core/neighbour.c:2853: error: struct neigh_parms has no member named net

can you please fix?

Or.




> +       int index = (int *) ctl->data - p->data;
> +
> +       if (!write)
> +               return;
> +
> +       set_bit(index, p->data_state);
> +       if (!dev) /* NULL dev means this is default value */
> +               neigh_copy_dflt_parms(net, p, index);
> +}
> +
>  static int neigh_proc_dointvec_zero_intmax(struct ctl_table *ctl, int write,
>                                            void __user *buffer,
>                                            size_t *lenp, loff_t *ppos)
>  {
>         struct ctl_table tmp = *ctl;
> +       int ret;
>
>         tmp.extra1 = &zero;
>         tmp.extra2 = &int_max;
>
> -       return proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
> +       ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
> +       neigh_proc_update(ctl, write);
> +       return ret;
>  }
>
>  int neigh_proc_dointvec(struct ctl_table *ctl, int write,
>                         void __user *buffer, size_t *lenp, loff_t *ppos)
>  {
> -       return proc_dointvec(ctl, write, buffer, lenp, ppos);
> +       int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
> +
> +       neigh_proc_update(ctl, write);
> +       return ret;
>  }
>  EXPORT_SYMBOL(neigh_proc_dointvec);
>
> @@ -2836,7 +2885,10 @@ int neigh_proc_dointvec_jiffies(struct ctl_table *ctl, int write,
>                                 void __user *buffer,
>                                 size_t *lenp, loff_t *ppos)
>  {
> -       return proc_dointvec_jiffies(ctl, write, buffer, lenp, ppos);
> +       int ret = proc_dointvec_jiffies(ctl, write, buffer, lenp, ppos);
> +
> +       neigh_proc_update(ctl, write);
> +       return ret;
>  }
>  EXPORT_SYMBOL(neigh_proc_dointvec_jiffies);
>
> @@ -2844,14 +2896,20 @@ static int neigh_proc_dointvec_userhz_jiffies(struct ctl_table *ctl, int write,
>                                               void __user *buffer,
>                                               size_t *lenp, loff_t *ppos)
>  {
> -       return proc_dointvec_userhz_jiffies(ctl, write, buffer, lenp, ppos);
> +       int ret = proc_dointvec_userhz_jiffies(ctl, write, buffer, lenp, ppos);
> +
> +       neigh_proc_update(ctl, write);
> +       return ret;
>  }
>
>  int neigh_proc_dointvec_ms_jiffies(struct ctl_table *ctl, int write,
>                                    void __user *buffer,
>                                    size_t *lenp, loff_t *ppos)
>  {
> -       return proc_dointvec_ms_jiffies(ctl, write, buffer, lenp, ppos);
> +       int ret = proc_dointvec_ms_jiffies(ctl, write, buffer, lenp, ppos);
> +
> +       neigh_proc_update(ctl, write);
> +       return ret;
>  }
>  EXPORT_SYMBOL(neigh_proc_dointvec_ms_jiffies);
>
> @@ -2859,7 +2917,10 @@ static int neigh_proc_dointvec_unres_qlen(struct ctl_table *ctl, int write,
>                                           void __user *buffer,
>                                           size_t *lenp, loff_t *ppos)
>  {
> -       return proc_unres_qlen(ctl, write, buffer, lenp, ppos);
> +       int ret = proc_unres_qlen(ctl, write, buffer, lenp, ppos);
> +
> +       neigh_proc_update(ctl, write);
> +       return ret;
>  }
>
>  #define NEIGH_PARMS_DATA_OFFSET(index) \
> @@ -2962,6 +3023,7 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
>         for (i = 0; i < ARRAY_SIZE(t->neigh_vars); i++) {
>                 t->neigh_vars[i].data += (long) p;
>                 t->neigh_vars[i].extra1 = dev;
> +               t->neigh_vars[i].extra2 = p;
>         }
>
>         if (dev) {
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index e1c1953..43065be 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -500,6 +500,7 @@ static int inet_set_ifa(struct net_device *dev, struct in_ifaddr *ifa)
>                 return -ENOBUFS;
>         }
>         ipv4_devconf_setall(in_dev);
> +       neigh_parms_data_state_setall(in_dev->arp_parms);
>         if (ifa->ifa_dev != in_dev) {
>                 WARN_ON(ifa->ifa_dev);
>                 in_dev_hold(in_dev);
> @@ -747,6 +748,7 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
>                 goto errout;
>
>         ipv4_devconf_setall(in_dev);
> +       neigh_parms_data_state_setall(in_dev->arp_parms);
>         in_dev_hold(in_dev);
>
>         if (tb[IFA_ADDRESS] == NULL)
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 62212c7..421a249 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -425,6 +425,7 @@ struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
>                                 goto failure;
>
>                         ipv4_devconf_setall(in_dev);
> +                       neigh_parms_data_state_setall(in_dev->arp_parms);
>                         IPV4_DEVCONF(in_dev->cnf, RP_FILTER) = 0;
>
>                         if (dev_open(dev))
> @@ -517,6 +518,7 @@ static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
>         }
>
>         ipv4_devconf_setall(in_dev);
> +       neigh_parms_data_state_setall(in_dev->arp_parms);
>         IPV4_DEVCONF(in_dev->cnf, RP_FILTER) = 0;
>         rcu_read_unlock();
>
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
