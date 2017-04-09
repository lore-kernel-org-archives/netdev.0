From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next RFC] Generic XDP
Date: Sun, 9 Apr 2017 01:17:26 -0400
Message-ID: <CAHashqAZHOJAqF43pRC4fwN-pwp-uWmDxUBCaLUPMoQqeF_OPA@mail.gmail.com>
References: <20170408.200721.109499285021338999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34431 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751321AbdDIFRr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 01:17:47 -0400
Received: by mail-qk0-f194.google.com with SMTP id p68so15179648qke.1
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 22:17:47 -0700 (PDT)
In-Reply-To: <20170408.200721.109499285021338999.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 8, 2017 at 11:07 PM, David Miller <davem@davemloft.net> wrote:
>
> This provides a generic non-optimized XDP implementation when the
> device driver does not provide an optimized one.
>
> It is arguable that perhaps I should have required something like
> this as part of the initial XDP feature merge.
>
> I believe this is critical for two reasons:
>
> 1) Accessibility.  More people can play with XDP with less
>    dependencies.  Yes I know we have XDP support in virtio_net, but
>    that just creates another depedency for learning how to use this
>    facility.
>
>    I wrote this to make life easier for the XDP newbies.
>
> 2) As a model for what the expected semantics are.  If there is a pure
>    generic core implementation, it serves as a semantic example for
>    driver folks adding XDP support.
>
> This is just a rough draft and is untested.

Overall I like the idea.  It does reduce the complexity and would
allow anyone to kick the tires with XDP more easily. I did some quick
inspection of the offset calculations coming back from the program and
I _think_ that looks correct.  It might also be too late.  :-)

I should be able to run this on Monday and see how the performance
compares to the driver/native XDP case on some bnxt_en-based hardware.

>
> Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index cc07c3b..7cfb355 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1892,6 +1892,7 @@ struct net_device {
>         struct lock_class_key   *qdisc_tx_busylock;
>         struct lock_class_key   *qdisc_running_key;
>         bool                    proto_down;
> +       struct bpf_prog         *xdp_prog;
>  };
>  #define to_net_dev(d) container_of(d, struct net_device, dev)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7efb417..e4c7927 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -95,6 +95,7 @@
>  #include <linux/notifier.h>
>  #include <linux/skbuff.h>
>  #include <linux/bpf.h>
> +#include <linux/bpf_trace.h>
>  #include <net/net_namespace.h>
>  #include <net/sock.h>
>  #include <net/busy_poll.h>
> @@ -4247,6 +4248,80 @@ static int __netif_receive_skb(struct sk_buff *skb)
>         return ret;
>  }
>
> +static struct static_key generic_xdp_needed __read_mostly;
> +
> +static int generic_xdp_install(struct net_device *dev, struct netdev_xdp *xdp)
> +{
> +       struct bpf_prog *new = xdp->prog;
> +       int ret = 0;
> +
> +       switch (xdp->command) {
> +       case XDP_SETUP_PROG: {
> +               struct bpf_prog *old;
> +
> +               old = xchg(&dev->xdp_prog, new);
> +               if (old)
> +                       bpf_prog_put(old);
> +
> +               if (old && !new)
> +                       static_key_slow_dec(&generic_xdp_needed);
> +               else if (new && !old)
> +                       static_key_slow_inc(&generic_xdp_needed);
> +               break;
> +       }
> +       case XDP_QUERY_PROG:
> +               xdp->prog_attached = !!dev->xdp_prog;
> +               ret = 0;
> +               break;
> +       default:
> +               ret = -EINVAL;
> +               break;
> +       }
> +
> +       return ret;
> +}
> +
> +static u32 netif_receive_generic_xdp(struct sk_buff *skb,
> +                                    struct bpf_prog *xdp_prog)
> +{
> +       struct xdp_buff xdp;
> +       u32 act = XDP_DROP;
> +       void *orig_data;
> +       int hlen, off;
> +
> +       if (skb_linearize(skb))
> +               goto do_drop;
> +
> +       hlen = skb_headlen(skb);
> +       xdp.data = skb->data;
> +       xdp.data_end = xdp.data + hlen;
> +       xdp.data_hard_start = xdp.data - skb_headroom(skb);
> +       orig_data = xdp.data;
> +
> +       act = bpf_prog_run_xdp(xdp_prog, &xdp);
> +
> +       off = xdp.data - orig_data;
> +       if (off)
> +               __skb_push(skb, off);
> +
> +       switch (act) {
> +       case XDP_PASS:
> +       case XDP_TX:
> +               break;
> +
> +       default:
> +               bpf_warn_invalid_xdp_action(act);
> +       case XDP_ABORTED:
> +               trace_xdp_exception(skb->dev, xdp_prog, act);
> +       case XDP_DROP:
> +       do_drop:
> +               kfree_skb(skb);
> +               break;
> +       }
> +
> +       return act;
> +}
> +
>  static int netif_receive_skb_internal(struct sk_buff *skb)
>  {
>         int ret;
> @@ -4258,6 +4333,21 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
>
>         rcu_read_lock();
>
> +       if (static_key_false(&generic_xdp_needed)) {
> +               struct bpf_prog *xdp_prog = READ_ONCE(skb->dev->xdp_prog);
> +
> +               if (xdp_prog) {
> +                       u32 act = netif_receive_generic_xdp(skb, xdp_prog);
> +
> +                       if (act != XDP_PASS) {
> +                               rcu_read_unlock();
> +                               if (act == XDP_TX)
> +                                       dev_queue_xmit(skb);
> +                               return NET_RX_DROP;
> +                       }
> +               }
> +       }
> +
>  #ifdef CONFIG_RPS
>         if (static_key_false(&rps_needed)) {
>                 struct rps_dev_flow voidflow, *rflow = &voidflow;
> @@ -6718,6 +6808,7 @@ EXPORT_SYMBOL(dev_change_proto_down);
>   */
>  int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
>  {
> +       int (*xdp_op)(struct net_device *dev, struct netdev_xdp *xdp);
>         const struct net_device_ops *ops = dev->netdev_ops;
>         struct bpf_prog *prog = NULL;
>         struct netdev_xdp xdp;
> @@ -6725,14 +6816,16 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
>
>         ASSERT_RTNL();
>
> -       if (!ops->ndo_xdp)
> -               return -EOPNOTSUPP;
> +       xdp_op = ops->ndo_xdp;
> +       if (!xdp_op)
> +               xdp_op = generic_xdp_install;
> +
>         if (fd >= 0) {
>                 if (flags & XDP_FLAGS_UPDATE_IF_NOEXIST) {
>                         memset(&xdp, 0, sizeof(xdp));
>                         xdp.command = XDP_QUERY_PROG;
>
> -                       err = ops->ndo_xdp(dev, &xdp);
> +                       err = xdp_op(dev, &xdp);
>                         if (err < 0)
>                                 return err;
>                         if (xdp.prog_attached)
> @@ -6748,7 +6841,7 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
>         xdp.command = XDP_SETUP_PROG;
>         xdp.prog = prog;
>
> -       err = ops->ndo_xdp(dev, &xdp);
> +       err = xdp_op(dev, &xdp);
>         if (err < 0 && prog)
>                 bpf_prog_put(prog);
>
> @@ -7807,6 +7900,11 @@ void free_netdev(struct net_device *dev)
>         free_percpu(dev->pcpu_refcnt);
>         dev->pcpu_refcnt = NULL;
>
> +       if (dev->xdp_prog) {
> +               bpf_prog_put(dev->xdp_prog);
> +               static_key_slow_dec(&generic_xdp_needed);
> +       }
> +
>         /*  Compatibility with error handling in drivers */
>         if (dev->reg_state == NETREG_UNINITIALIZED) {
>                 netdev_freemem(dev);
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index b2bd4c9..fe1abba 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -896,15 +896,12 @@ static size_t rtnl_port_size(const struct net_device *dev,
>                 return port_self_size;
>  }
>
> -static size_t rtnl_xdp_size(const struct net_device *dev)
> +static size_t rtnl_xdp_size(void)
>  {
>         size_t xdp_size = nla_total_size(0) +   /* nest IFLA_XDP */
>                           nla_total_size(1);    /* XDP_ATTACHED */
>
> -       if (!dev->netdev_ops->ndo_xdp)
> -               return 0;
> -       else
> -               return xdp_size;
> +       return xdp_size;
>  }
>
>  static noinline size_t if_nlmsg_size(const struct net_device *dev,
> @@ -943,7 +940,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>                + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
>                + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
>                + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
> -              + rtnl_xdp_size(dev) /* IFLA_XDP */
> +              + rtnl_xdp_size() /* IFLA_XDP */
>                + nla_total_size(4)  /* IFLA_EVENT */
>                + nla_total_size(1); /* IFLA_PROTO_DOWN */
>
> @@ -1252,20 +1249,25 @@ static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device *dev)
>
>  static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
>  {
> -       struct netdev_xdp xdp_op = {};
>         struct nlattr *xdp;
>         int err;
> +       u8 val;
>
> -       if (!dev->netdev_ops->ndo_xdp)
> -               return 0;
>         xdp = nla_nest_start(skb, IFLA_XDP);
>         if (!xdp)
>                 return -EMSGSIZE;
> -       xdp_op.command = XDP_QUERY_PROG;
> -       err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
> -       if (err)
> -               goto err_cancel;
> -       err = nla_put_u8(skb, IFLA_XDP_ATTACHED, xdp_op.prog_attached);
> +       if (dev->netdev_ops->ndo_xdp) {
> +               struct netdev_xdp xdp_op = {};
> +
> +               xdp_op.command = XDP_QUERY_PROG;
> +               err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
> +               if (err)
> +                       goto err_cancel;
> +               val = xdp_op.prog_attached;
> +       } else {
> +               val = dev->xdp_prog ? 1 : 0;
> +       }
> +       err = nla_put_u8(skb, IFLA_XDP_ATTACHED, val);
>         if (err)
>                 goto err_cancel;
>
