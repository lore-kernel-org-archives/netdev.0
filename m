From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 2/9] ipv6: sr: add code base for control plane support
 of SR-IPv6
Date: Thu, 27 Oct 2016 19:52:15 -0700
Message-ID: <CALx6S35WPxzAoetc5+=XRsMyyDHUwN-x64Tv+YsBu+MAgnDNRg@mail.gmail.com>
References: <1477497292-22155-1-git-send-email-david.lebrun@uclouvain.be> <1477497292-22155-3-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34438 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbcJ1D6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 23:58:46 -0400
Received: by mail-qt0-f194.google.com with SMTP id p53so464850qtp.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 20:58:45 -0700 (PDT)
In-Reply-To: <1477497292-22155-3-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 8:54 AM, David Lebrun <david.lebrun@uclouvain.be> wrote:
> This patch adds the necessary hooks and structures to provide support
> for SR-IPv6 control plane, essentially the Generic Netlink commands
> that will be used for userspace control over the Segment Routing
> kernel structures.
>
> The genetlink commands provide control over two different structures:
> tunnel source and HMAC data. The tunnel source is the source address
> that will be used by default when encapsulating packets into an
> outer IPv6 header + SRH. If the tunnel source is set to :: then an
> address of the outgoing interface will be selected as the source.
>
> The HMAC commands currently just return ENOTSUPP and will be implemented
> in a future patch.
>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
> ---
>  include/linux/seg6_genl.h      |   6 ++
>  include/net/netns/ipv6.h       |   1 +
>  include/net/seg6.h             |  30 ++++++
>  include/uapi/linux/seg6_genl.h |  32 ++++++
>  net/ipv6/Makefile              |   2 +-
>  net/ipv6/seg6.c                | 214 +++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 284 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/seg6_genl.h
>  create mode 100644 include/net/seg6.h
>  create mode 100644 include/uapi/linux/seg6_genl.h
>  create mode 100644 net/ipv6/seg6.c
>
> diff --git a/include/linux/seg6_genl.h b/include/linux/seg6_genl.h
> new file mode 100644
> index 0000000..d6c3fb4f
> --- /dev/null
> +++ b/include/linux/seg6_genl.h
> @@ -0,0 +1,6 @@
> +#ifndef _LINUX_SEG6_GENL_H
> +#define _LINUX_SEG6_GENL_H
> +
> +#include <uapi/linux/seg6_genl.h>
> +
> +#endif
> diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
> index 10d0848..de7745e 100644
> --- a/include/net/netns/ipv6.h
> +++ b/include/net/netns/ipv6.h
> @@ -85,6 +85,7 @@ struct netns_ipv6 {
>  #endif
>         atomic_t                dev_addr_genid;
>         atomic_t                fib6_sernum;
> +       struct seg6_pernet_data *seg6_data;
>  };
>
>  #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
> diff --git a/include/net/seg6.h b/include/net/seg6.h
> new file mode 100644
> index 0000000..a9d9a9b
> --- /dev/null
> +++ b/include/net/seg6.h
> @@ -0,0 +1,30 @@
> +/*
> + *  SR-IPv6 implementation
> + *
> + *  Author:
> + *  David Lebrun <david.lebrun@uclouvain.be>
> + *
> + *
> + *  This program is free software; you can redistribute it and/or
> + *      modify it under the terms of the GNU General Public License
> + *      as published by the Free Software Foundation; either version
> + *      2 of the License, or (at your option) any later version.
> + */
> +
> +#ifndef _NET_SEG6_H
> +#define _NET_SEG6_H
> +
> +#include <linux/net.h>
> +#include <linux/ipv6.h>
> +
> +struct seg6_pernet_data {
> +       struct mutex lock;
> +       struct in6_addr __rcu *tun_src;
> +};
> +
> +static inline struct seg6_pernet_data *seg6_pernet(struct net *net)
> +{
> +       return net->ipv6.seg6_data;
> +}
> +
> +#endif
> diff --git a/include/uapi/linux/seg6_genl.h b/include/uapi/linux/seg6_genl.h
> new file mode 100644
> index 0000000..fcf1c60
> --- /dev/null
> +++ b/include/uapi/linux/seg6_genl.h
> @@ -0,0 +1,32 @@
> +#ifndef _UAPI_LINUX_SEG6_GENL_H
> +#define _UAPI_LINUX_SEG6_GENL_H
> +
> +#define SEG6_GENL_NAME         "SEG6"
> +#define SEG6_GENL_VERSION      0x1
> +
> +enum {
> +       SEG6_ATTR_UNSPEC,
> +       SEG6_ATTR_DST,
> +       SEG6_ATTR_DSTLEN,
> +       SEG6_ATTR_HMACKEYID,
> +       SEG6_ATTR_SECRET,
> +       SEG6_ATTR_SECRETLEN,
> +       SEG6_ATTR_ALGID,
> +       SEG6_ATTR_HMACINFO,
> +       __SEG6_ATTR_MAX,
> +};
> +
> +#define SEG6_ATTR_MAX (__SEG6_ATTR_MAX - 1)
> +
> +enum {
> +       SEG6_CMD_UNSPEC,
> +       SEG6_CMD_SETHMAC,
> +       SEG6_CMD_DUMPHMAC,
> +       SEG6_CMD_SET_TUNSRC,
> +       SEG6_CMD_GET_TUNSRC,
> +       __SEG6_CMD_MAX,
> +};
> +
> +#define SEG6_CMD_MAX (__SEG6_CMD_MAX - 1)
> +
> +#endif
> diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
> index c174ccb..29a77d3 100644
> --- a/net/ipv6/Makefile
> +++ b/net/ipv6/Makefile
> @@ -45,7 +45,7 @@ obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
>  obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
>  obj-$(CONFIG_IPV6_FOU) += fou6.o
>
> -obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
> +obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o seg6.o
>  obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
>
>  obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
> diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
> new file mode 100644
> index 0000000..24111662
> --- /dev/null
> +++ b/net/ipv6/seg6.c
> @@ -0,0 +1,214 @@
> +/*
> + *  SR-IPv6 implementation
> + *
> + *  Author:
> + *  David Lebrun <david.lebrun@uclouvain.be>
> + *
> + *
> + *  This program is free software; you can redistribute it and/or
> + *       modify it under the terms of the GNU General Public License
> + *       as published by the Free Software Foundation; either version
> + *       2 of the License, or (at your option) any later version.
> + */
> +
> +#include <linux/errno.h>
> +#include <linux/types.h>
> +#include <linux/socket.h>
> +#include <linux/net.h>
> +#include <linux/in6.h>
> +#include <linux/slab.h>
> +
> +#include <net/ipv6.h>
> +#include <net/protocol.h>
> +
> +#include <net/seg6.h>
> +#include <net/genetlink.h>
> +#include <linux/seg6.h>
> +#include <linux/seg6_genl.h>
> +
> +static const struct nla_policy seg6_genl_policy[SEG6_ATTR_MAX + 1] = {
> +       [SEG6_ATTR_DST]                         = { .type = NLA_BINARY,
> +               .len = sizeof(struct in6_addr) },
> +       [SEG6_ATTR_DSTLEN]                      = { .type = NLA_S32, },
> +       [SEG6_ATTR_HMACKEYID]           = { .type = NLA_U32, },
> +       [SEG6_ATTR_SECRET]                      = { .type = NLA_BINARY, },
> +       [SEG6_ATTR_SECRETLEN]           = { .type = NLA_U8, },
> +       [SEG6_ATTR_ALGID]                       = { .type = NLA_U8, },
> +       [SEG6_ATTR_HMACINFO]            = { .type = NLA_NESTED, },
> +};
> +
> +static struct genl_family seg6_genl_family = {
> +       .id = GENL_ID_GENERATE,
> +       .hdrsize = 0,
> +       .name = SEG6_GENL_NAME,
> +       .version = SEG6_GENL_VERSION,
> +       .maxattr = SEG6_ATTR_MAX,
> +       .netnsok = true,
> +};
> +
> +static int seg6_genl_sethmac(struct sk_buff *skb, struct genl_info *info)
> +{
> +       return -ENOTSUPP;
> +}
> +
> +static int seg6_genl_set_tunsrc(struct sk_buff *skb, struct genl_info *info)
> +{
> +       struct net *net = genl_info_net(info);
> +       struct in6_addr *val, *t_old, *t_new;
> +       struct seg6_pernet_data *sdata;
> +
> +       sdata = seg6_pernet(net);
> +
> +       if (!info->attrs[SEG6_ATTR_DST])
> +               return -EINVAL;
> +
> +       val = nla_data(info->attrs[SEG6_ATTR_DST]);
> +       t_new = kmemdup(val, sizeof(*val), GFP_KERNEL);
> +
> +       mutex_lock(&sdata->lock);
> +
> +       t_old = sdata->tun_src;
> +       rcu_assign_pointer(sdata->tun_src, t_new);
> +
> +       mutex_unlock(&sdata->lock);
> +
> +       synchronize_net();
> +       kfree(t_old);
> +
> +       return 0;
> +}
> +
> +static int seg6_genl_get_tunsrc(struct sk_buff *skb, struct genl_info *info)
> +{
> +       struct net *net = genl_info_net(info);
> +       struct in6_addr *tun_src;
> +       struct sk_buff *msg;
> +       void *hdr;
> +
> +       msg = genlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +       if (!msg)
> +               return -ENOMEM;
> +
> +       hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
> +                         &seg6_genl_family, 0, SEG6_CMD_GET_TUNSRC);
> +       if (!hdr)
> +               goto free_msg;
> +
> +       rcu_read_lock();
> +       tun_src = rcu_dereference(seg6_pernet(net)->tun_src);
> +
> +       if (nla_put(msg, SEG6_ATTR_DST, sizeof(struct in6_addr), tun_src))
> +               goto nla_put_failure;
> +
> +       rcu_read_unlock();
> +
> +       genlmsg_end(msg, hdr);
> +       genlmsg_reply(msg, info);
> +
> +       return 0;
> +
> +nla_put_failure:
> +       rcu_read_unlock();
> +       genlmsg_cancel(msg, hdr);
> +free_msg:
> +       nlmsg_free(msg);
> +       return -ENOMEM;
> +}
> +
> +static int seg6_genl_dumphmac(struct sk_buff *skb, struct netlink_callback *cb)
> +{
> +       return -ENOTSUPP;
> +}
> +
> +static const struct genl_ops seg6_genl_ops[] = {
> +       {
> +               .cmd    = SEG6_CMD_SETHMAC,
> +               .doit   = seg6_genl_sethmac,
> +               .policy = seg6_genl_policy,
> +               .flags  = GENL_ADMIN_PERM,
> +       },
> +       {
> +               .cmd    = SEG6_CMD_DUMPHMAC,
> +               .dumpit = seg6_genl_dumphmac,
> +               .policy = seg6_genl_policy,
> +               .flags  = GENL_ADMIN_PERM,
> +       },
> +       {
> +               .cmd    = SEG6_CMD_SET_TUNSRC,
> +               .doit   = seg6_genl_set_tunsrc,
> +               .policy = seg6_genl_policy,
> +               .flags  = GENL_ADMIN_PERM,
> +       },
> +       {
> +               .cmd    = SEG6_CMD_GET_TUNSRC,
> +               .doit   = seg6_genl_get_tunsrc,
> +               .policy = seg6_genl_policy,
> +               .flags  = GENL_ADMIN_PERM,
> +       },
> +};
> +
> +static int __net_init seg6_net_init(struct net *net)
> +{
> +       struct seg6_pernet_data *sdata;
> +
> +       sdata = kzalloc(sizeof(*sdata), GFP_KERNEL);
> +       if (!sdata)
> +               return -ENOMEM;
> +
> +       mutex_init(&sdata->lock);
> +
> +       sdata->tun_src = kzalloc(sizeof(*sdata->tun_src), GFP_KERNEL);
> +       if (!sdata->tun_src) {
> +               kfree(sdata);
> +               return -ENOMEM;
> +       }
> +
> +       net->ipv6.seg6_data = sdata;
> +
> +       return 0;
> +}
> +
> +static void __net_exit seg6_net_exit(struct net *net)
> +{
> +       struct seg6_pernet_data *sdata = seg6_pernet(net);
> +
> +       kfree(sdata->tun_src);
> +       kfree(sdata);
> +}
> +
> +static struct pernet_operations ip6_segments_ops = {
> +       .init = seg6_net_init,
> +       .exit = seg6_net_exit,
> +};
> +
> +static int __init seg6_init(void)
> +{
> +       int err = -ENOMEM;
> +
> +       err = genl_register_family_with_ops(&seg6_genl_family, seg6_genl_ops);
> +       if (err)
> +               goto out;
> +
> +       err = register_pernet_subsys(&ip6_segments_ops);
> +       if (err)
> +               goto out_unregister_genl;
> +
> +       pr_info("Segment Routing with IPv6\n");
> +
> +out:
> +       return err;
> +out_unregister_genl:
> +       genl_unregister_family(&seg6_genl_family);
> +       goto out;
> +}
> +module_init(seg6_init);
> +
> +static void __exit seg6_exit(void)
> +{
> +       unregister_pernet_subsys(&ip6_segments_ops);
> +       genl_unregister_family(&seg6_genl_family);
> +}
> +module_exit(seg6_exit);
> +
> +MODULE_DESCRIPTION("Segment Routing with IPv6");
> +MODULE_LICENSE("GPL v2");
> --
> 2.7.3
>

Acked-by: Tom Herbert <tom@herbertland.com>
