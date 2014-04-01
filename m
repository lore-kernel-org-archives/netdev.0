From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH] vlan: Try to adjust lower device mtu when configuring
 802.1AD vlans
Date: Tue, 1 Apr 2014 14:34:53 -0700
Message-ID: <CAGVrzcakmGf5sj-yrB9+g-OX+psVGgBREnzOs=ZaHe5FiKP2QQ@mail.gmail.com>
References: <1396387054-4510-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Patrik McHardy <kaber@trash.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32970 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbaDAVfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 17:35:34 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so10466414pab.38
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 14:35:33 -0700 (PDT)
In-Reply-To: <1396387054-4510-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

2014-04-01 14:17 GMT-07:00 Vlad Yasevich <vyasevic@redhat.com>:
> 802.1AD vlans supposed to encapsulate 802.1Q vlans.  To
> do this, we need an extra 4 bytes of header which are typically
> not accounted for by lower devices.  Some devices can not
> support frames longer then 1522 bytes at all.  Such devices
> can not really support 802.1AD, even in software, without
> the vlan reducing its mtu value.
>
> This patch propses to increate the lower devices MTU to 1504
> in case of 802.1AD configuration, and if device doesn't
> support it, fail the creation of the vlan.  The user has an
> option to configure older-style Q-in-Q vlans and manually
> lower the mtu to support such encapsulation.
>
> CC: Patrik McHardy <kaber@trash.net>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  net/8021q/vlan.c         | 17 +++++++++++++++++
>  net/8021q/vlan_netlink.c | 11 ++++++++---
>  2 files changed, 25 insertions(+), 3 deletions(-)
>
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 175273f..0328d73 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -126,6 +126,7 @@ int vlan_check_real_dev(struct net_device *real_dev,
>                         __be16 protocol, u16 vlan_id)
>  {
>         const char *name = real_dev->name;
> +       int err;
>
>         if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
>                 pr_info("VLANs not supported on %s\n", name);
> @@ -135,6 +136,21 @@ int vlan_check_real_dev(struct net_device *real_dev,
>         if (vlan_find_dev(real_dev, protocol, vlan_id) != NULL)
>                 return -EEXIST;
>
> +       if (protocol == htons(ETH_P_8021AD)) {
> +               /* 8021AD vlan is meant to encapsulate 8021Q and thus we
> +                * need to make sure that lower device can handle a
> +                * larger mtu.
> +                * If the lower device still has a default ethernet mtu,
> +                * bump it up 4 bytes.  If not, it was set by user and
> +                * we'll trust the user knows what he is doing.
> +                */
> +               if (real_dev->mtu == VLAN_ETH_DATA_LEN &&
> +                   dev_set_mtu(real_dev, real_dev->mtu + VLAN_HLEN))
> +                       pr_warn("802.1AD mode is not supported on %s due to mtu limitations.\n", name);
> +                       return -EOPNOTSUPP

Missing semicolon here.

> +               }
> +       }
> +
>         return 0;
>  }
>
> @@ -259,6 +275,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
>          * hope the underlying device can handle it.
>          */
>         new_dev->mtu = real_dev->mtu;
> +
>         new_dev->priv_flags |= (real_dev->priv_flags & IFF_UNICAST_FLT);
>
>         vlan = vlan_dev_priv(new_dev);
> diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
> index c7e634a..a925a8d 100644
> --- a/net/8021q/vlan_netlink.c
> +++ b/net/8021q/vlan_netlink.c
> @@ -144,10 +144,15 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
>         if (err < 0)
>                 return err;
>
> -       if (!tb[IFLA_MTU])
> -               dev->mtu = real_dev->mtu;
> -       else if (dev->mtu > real_dev->mtu)
> +       if (!tb[IFLA_MTU]) {
> +               if (vlan->vlan_proto == htons(ETH_P_8021AD) &&
> +                   real_dev->mtu == VLAN_ETH_DATA_LEN + VLAN_HLEN)

Parenthesis for the add operation would help clarifying things. Should
not that be a >= comparison? We want to make sure that real_dev has
enough MTU room for allowing the default MTU size on 802.1AD VLAN
device, or does the initial comment vlan_check_real_dev() also apply
here?

> +                       dev->mtu = VLAN_ETH_DATA_LEN;
> +               else
> +                       dev->mtu = real_dev->mtu;
> +       } else if (dev->mtu > real_dev->mtu) {
>                 return -EINVAL;
> +       }
>
>         err = vlan_changelink(dev, tb, data);
>         if (err < 0)
> --
> 1.8.5.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
