From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH] bonding: require speed/duplex only for 802.3ad, alb and tlb
Date: Thu, 10 Aug 2017 12:04:01 -0700
Message-ID: <CAF2d9jjGWw6dveYtibCzgKofGugxbnuq8oHyVEjRNd99RURYVA@mail.gmail.com>
References: <20170810044144.17398-1-futur.andy@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-netdev <netdev@vger.kernel.org>
To: Andreas Born <futur.andy@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:38581 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753217AbdHJTEX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 15:04:23 -0400
Received: by mail-io0-f173.google.com with SMTP id g71so12858849ioe.5
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 12:04:22 -0700 (PDT)
In-Reply-To: <20170810044144.17398-1-futur.andy@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 9, 2017 at 9:41 PM, Andreas Born <futur.andy@googlemail.com> wrote:
> The patch c4adfc822bf5 ("bonding: make speed, duplex setting consistent
> with link state") puts the link state to down if
> bond_update_speed_duplex() cannot retrieve speed and duplex settings.
> Assumably the patch was written with 802.3ad mode in mind which relies
> on link speed/duplex settings. For other modes like active-backup these
> settings are not required.
> Thus, only for these other modes, this patch
> reintroduces support for slaves that do not support reporting speed or
> duplex such as wireless devices. This fixes the regression reported in
> bug 196547 (https://bugzilla.kernel.org/show_bug.cgi?id=196547).
>
> Fixes: c4adfc822bf5 ("bonding: make speed, duplex setting consistent
> with link state")
> Signed-off-by: Andreas Born <futur.andy@googlemail.com>
Acked-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_main.c | 6 ++++--
>  include/net/bonding.h           | 5 +++++
>  2 files changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 9bee6c1c70cc..85bb272d2a34 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1569,7 +1569,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>         new_slave->delay = 0;
>         new_slave->link_failure_count = 0;
>
> -       if (bond_update_speed_duplex(new_slave))
> +       if (bond_update_speed_duplex(new_slave) &&
> +           bond_needs_speed_duplex(bond))
>                 new_slave->link = BOND_LINK_DOWN;
>
>         new_slave->last_rx = jiffies -
> @@ -2140,7 +2141,8 @@ static void bond_miimon_commit(struct bonding *bond)
>                         continue;
>
>                 case BOND_LINK_UP:
> -                       if (bond_update_speed_duplex(slave)) {
> +                       if (bond_update_speed_duplex(slave) &&
> +                           bond_needs_speed_duplex(bond)) {
>                                 slave->link = BOND_LINK_DOWN;
>                                 netdev_warn(bond->dev,
>                                             "failed to get link speed/duplex for %s\n",
> diff --git a/include/net/bonding.h b/include/net/bonding.h
> index b00508d22e0a..b2e68657a216 100644
> --- a/include/net/bonding.h
> +++ b/include/net/bonding.h
> @@ -277,6 +277,11 @@ static inline bool bond_is_lb(const struct bonding *bond)
>                BOND_MODE(bond) == BOND_MODE_ALB;
>  }
>
> +static inline bool bond_needs_speed_duplex(const struct bonding *bond)
> +{
> +       return BOND_MODE(bond) == BOND_MODE_8023AD || bond_is_lb(bond);
> +}
> +
>  static inline bool bond_is_nondyn_tlb(const struct bonding *bond)
>  {
>         return (BOND_MODE(bond) == BOND_MODE_TLB)  &&
> --
> 2.14.0
>
