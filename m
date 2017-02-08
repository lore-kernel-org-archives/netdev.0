From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch net-next 12/15] ipv4: fib: Notify about nexthop status changes
Date: Wed, 8 Feb 2017 10:27:05 -0500
Message-ID: <CAHashqC0vQsvnRefEaBuK3zvvM6NpW98KcRMT9DMRbTCLYO8MQ@mail.gmail.com>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us> <1486549002-2056-13-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, idosch@mellanox.com,
        eladr@mellanox.com, mlxsw@mellanox.com,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35189 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751913AbdBHPiN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 10:38:13 -0500
Received: by mail-qk0-f194.google.com with SMTP id u25so18209328qki.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 07:37:08 -0800 (PST)
In-Reply-To: <1486549002-2056-13-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 8, 2017 at 5:16 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Ido Schimmel <idosch@mellanox.com>
>
> When a multipath route is hit the kernel doesn't consider nexthops that
> are DEAD or LINKDOWN when IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN is set.
> Devices that offload multipath routes need to be made aware of nexthop
> status changes. Otherwise, the device will keep forwarding packets to
> non-functional nexthops.
>
> Add the FIB_EVENT_NH_{ADD,DEL} events to the fib notification chain,
> which notify capable devices when they should add or delete a nexthop
> from their tables.

This looks good -- thanks for doing this.

IIUC the hardware forwarding use case for your hardware covered by David
Ahern's patch[1] to the ipv4 software path selection is already covered,
so this is probably the last known link/neighbor forwarding issue for
ipv4 that needs coverage.

1. a6db449 net: ipv4: Consider failed nexthops in multipath routes

> Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> Cc: David Ahern <dsa@cumulusnetworks.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>

Reviewed-by Andy Gospodarek <gospo@broadcom.com>

> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/ip_fib.h     |  7 +++++++
>  net/ipv4/fib_semantics.c | 33 +++++++++++++++++++++++++++++++++
>  2 files changed, 40 insertions(+)
>
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 57c2a86..45a184e 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -214,11 +214,18 @@ struct fib_entry_notifier_info {
>         u32 nlflags;
>  };
>
> +struct fib_nh_notifier_info {
> +       struct fib_notifier_info info; /* must be first */
> +       struct fib_nh *fib_nh;
> +};
> +
>  enum fib_event_type {
>         FIB_EVENT_ENTRY_ADD,
>         FIB_EVENT_ENTRY_DEL,
>         FIB_EVENT_RULE_ADD,
>         FIB_EVENT_RULE_DEL,
> +       FIB_EVENT_NH_ADD,
> +       FIB_EVENT_NH_DEL,
>  };
>
>  int register_fib_notifier(struct notifier_block *nb,
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 6306a67..317026a 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -1355,6 +1355,36 @@ int fib_sync_down_addr(struct net_device *dev, __be32 local)
>         return ret;
>  }
>
> +static int call_fib_nh_notifiers(struct fib_nh *fib_nh,
> +                                enum fib_event_type event_type)
> +{
> +       struct in_device *in_dev = __in_dev_get_rtnl(fib_nh->nh_dev);
> +       struct fib_nh_notifier_info info = {
> +               .fib_nh = fib_nh,
> +       };
> +
> +       switch (event_type) {
> +       case FIB_EVENT_NH_ADD:
> +               if (fib_nh->nh_flags & RTNH_F_DEAD)
> +                       break;
> +               if (IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
> +                   fib_nh->nh_flags & RTNH_F_LINKDOWN)
> +                       break;
> +               return call_fib_notifiers(dev_net(fib_nh->nh_dev), event_type,
> +                                         &info.info);
> +       case FIB_EVENT_NH_DEL:
> +               if ((IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
> +                    fib_nh->nh_flags & RTNH_F_LINKDOWN) ||
> +                   (fib_nh->nh_flags & RTNH_F_DEAD))
> +                       return call_fib_notifiers(dev_net(fib_nh->nh_dev),
> +                                                 event_type, &info.info);
> +       default:
> +               break;
> +       }
> +
> +       return NOTIFY_DONE;
> +}
> +
>  /* Event              force Flags           Description
>   * NETDEV_CHANGE      0     LINKDOWN        Carrier OFF, not for scope host
>   * NETDEV_DOWN        0     LINKDOWN|DEAD   Link down, not for scope host
> @@ -1396,6 +1426,8 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event, bool force)
>                                         nexthop_nh->nh_flags |= RTNH_F_LINKDOWN;
>                                         break;
>                                 }
> +                               call_fib_nh_notifiers(nexthop_nh,
> +                                                     FIB_EVENT_NH_DEL);
>                                 dead++;
>                         }
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
> @@ -1550,6 +1582,7 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
>                                 continue;
>                         alive++;
>                         nexthop_nh->nh_flags &= ~nh_flags;
> +                       call_fib_nh_notifiers(nexthop_nh, FIB_EVENT_NH_ADD);
>                 } endfor_nexthops(fi)
>
>                 if (alive > 0) {
> --
> 2.7.4
>
