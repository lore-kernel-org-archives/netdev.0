From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2] vlan: Keep NETIF_F_HW_CSUM similar to other software devices
Date: Fri, 5 May 2017 13:37:23 -0700
Message-ID: <CAKgT0Uf36kYzeSM5UJ9QFRpc_pwCvCGPMMeNkchb7du=4g2qJA@mail.gmail.com>
References: <1494015461-12192-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Michal Kubecek <mkubecek@suse.cz>,
        avagin@openvz.org, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34214 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751466AbdEEUhZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 16:37:25 -0400
Received: by mail-it0-f67.google.com with SMTP id c26so2134986itd.1
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 13:37:24 -0700 (PDT)
In-Reply-To: <1494015461-12192-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 5, 2017 at 1:17 PM, Vladislav Yasevich <vyasevich@gmail.com> wrote:
> Vlan devices, like all other software devices, enable
> NETIF_F_HW_CSUM feature.  However, unlike all the othe other
> software devices, vlans will switch to using IP|IPV6_CSUM
> features, if the underlying devices uses them.  In these situations,
> checksum offload features on the vlan device can't be controlled
> via ethtool.
>
> This patch makes vlans keep HW_CSUM feature if the underlying
> device supports checksum offloading.  This makes vlan devices
> behave like other software devices, and restores control to the
> user.
>
> A side-effect is that some offload settings (typically UFO)
> may be enabled on the vlan device while being disabled on the HW.
> However, the GSO code will correctly process the packets. This
> actually results in slightly better raw throughput.
>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>

> ---
> V2:  posted the right patch.
>
>  net/8021q/vlan_dev.c | 13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
>
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 9ee5787..ff12cf3 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -626,11 +626,18 @@ static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
>  {
>         struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
>         netdev_features_t old_features = features;
> +       netdev_features_t lower_features;
>
> -       features = netdev_intersect_features(features, real_dev->vlan_features);
> -       features |= NETIF_F_RXCSUM;
> -       features = netdev_intersect_features(features, real_dev->features);
> +       lower_features = netdev_intersect_features((real_dev->vlan_features |
> +                                                   NETIF_F_RXCSUM),
> +                                                  real_dev->features);
>
> +       /* Add HW_CSUM setting to preserve user ability to control
> +        * checksum offload on the vlan device.
> +        */
> +       if (lower_features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
> +               lower_features |= NETIF_F_HW_CSUM;
> +       features = netdev_intersect_features(features, lower_features);
>         features |= old_features & (NETIF_F_SOFT_FEATURES | NETIF_F_GSO_SOFTWARE);
>         features |= NETIF_F_LLTX;
>
> --
> 2.7.4
>
