From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH net 1/1] driver: macvlan: Destroy new macvlan port if
 macvlan_common_newlink failed.
Date: Mon, 7 Nov 2016 21:11:11 +0800
Message-ID: <CA+6hz4qQvepY_JMtdETkZZCwq1s38xNjYcyB2T1k9AyCs2xw8Q@mail.gmail.com>
References: <1478226529-26766-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gao Feng <fgao@ikuai8.com>
To: "David S. Miller" <davem@davemloft.net>,
        Patrick McHardy <kaber@trash.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Feng Gao <gfree.wind@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:34986 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752677AbcKGNLM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:11:12 -0500
Received: by mail-vk0-f66.google.com with SMTP id x186so6049725vkd.2
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 05:11:12 -0800 (PST)
In-Reply-To: <1478226529-26766-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 4, 2016 at 10:28 AM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> When there is no existing macvlan port in lowdev, one new macvlan port
> would be created. But it doesn't be destoried when something failed later.
> It casues some memleak.
>
> Now add one flag to indicate if new macvlan port is created.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  drivers/net/macvlan.c | 31 ++++++++++++++++++++++---------
>  1 file changed, 22 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 3234fcd..d2d6f12 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -1278,6 +1278,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>         struct net_device *lowerdev;
>         int err;
>         int macmode;
> +       bool create = false;
>
>         if (!tb[IFLA_LINK])
>                 return -EINVAL;
> @@ -1304,12 +1305,18 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>                 err = macvlan_port_create(lowerdev);
>                 if (err < 0)
>                         return err;
> +               create = true;
>         }
>         port = macvlan_port_get_rtnl(lowerdev);
>
>         /* Only 1 macvlan device can be created in passthru mode */
> -       if (port->passthru)
> -               return -EINVAL;
> +       if (port->passthru) {
> +               /* The macvlan port must be not created this time,
> +                * still goto destroy_macvlan_port for readability.
> +                */
> +               err = -EINVAL;
> +               goto destroy_macvlan_port;
> +       }
>
>         vlan->lowerdev = lowerdev;
>         vlan->dev      = dev;
> @@ -1325,24 +1332,28 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>                 vlan->flags = nla_get_u16(data[IFLA_MACVLAN_FLAGS]);
>
>         if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
> -               if (port->count)
> -                       return -EINVAL;
> +               if (port->count) {
> +                       err = -EINVAL;
> +                       goto destroy_macvlan_port;
> +               }
>                 port->passthru = true;
>                 eth_hw_addr_inherit(dev, lowerdev);
>         }
>
>         if (data && data[IFLA_MACVLAN_MACADDR_MODE]) {
> -               if (vlan->mode != MACVLAN_MODE_SOURCE)
> -                       return -EINVAL;
> +               if (vlan->mode != MACVLAN_MODE_SOURCE) {
> +                       err = -EINVAL;
> +                       goto destroy_macvlan_port;
> +               }
>                 macmode = nla_get_u32(data[IFLA_MACVLAN_MACADDR_MODE]);
>                 err = macvlan_changelink_sources(vlan, macmode, data);
>                 if (err)
> -                       return err;
> +                       goto destroy_macvlan_port;
>         }
>
>         err = register_netdevice(dev);
>         if (err < 0)
> -               return err;
> +               goto destroy_macvlan_port;
>
>         dev->priv_flags |= IFF_MACVLAN;
>         err = netdev_upper_dev_link(lowerdev, dev);
> @@ -1357,7 +1368,9 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>
>  unregister_netdev:
>         unregister_netdevice(dev);
> -
> +destroy_macvlan_port:
> +       if (create)
> +               macvlan_port_destroy(port->dev);
>         return err;
>  }
>  EXPORT_SYMBOL_GPL(macvlan_common_newlink);
> --
> 1.9.1
>
>

Hi all,

How about this fix ? Is there any issue ?

Regards
Feng
