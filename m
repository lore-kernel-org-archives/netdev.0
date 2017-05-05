From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] vlan: Keep NETIF_F_HW_CSUM similar to other software devices
Date: Fri, 5 May 2017 13:01:03 -0700
Message-ID: <CAKgT0UdF_Mk4aEDKS2L_qNOTk_UhSpBP6dHeTN2Y_wz1vj-B2g@mail.gmail.com>
References: <1494012038-5776-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Michal Kubecek <mkubecek@suse.cz>,
        avagin@openvz.org, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33456 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbdEEUBE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 16:01:04 -0400
Received: by mail-it0-f65.google.com with SMTP id v135so2032939itv.0
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 13:01:04 -0700 (PDT)
In-Reply-To: <1494012038-5776-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 5, 2017 at 12:20 PM, Vladislav Yasevich <vyasevich@gmail.com> wrote:
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
> ---
>  net/8021q/vlan_dev.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 9ee5787..ffc8167 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -626,10 +626,16 @@ static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
>  {
>         struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
>         netdev_features_t old_features = features;
> +       netdev_features_t real_dev_features = real_dev->features;
>
> -       features = netdev_intersect_features(features, real_dev->vlan_features);
> +       features = netdev_intersect_features(features,
> +                                            (real_dev->vlan_features |
> +                                             NETIF_F_HW_CSUM));

You might want to change the ordering on all this.

You could start out with a value based on the intersection of
real_dev->features and real_dev->vlan_features. Then you don't need to
mess around with this extra piece where you are having OR in HW_CSUM.
That way you don't risk losing track of the state of the hardware
checksum offload in terms of vlan_features as it should completely
clear all of the checksums if none of them are supported in hardware.

>         features |= NETIF_F_RXCSUM;

This line would probably need to be changed to OR NETIF_F_RXCSUM with
the real_dev->vlan_features when we perform the first intersect test.
That way we are guaranteed to report RXCSUM if the underlying device
supports it. It might just be worth while to force this into the
vlan_features for all devices in register_netdevice() then we wouldn't
need this line at all and it probably makes sense since it would allow
us to save a few extra cycles/instructions by combining it with the
line that was adding high dma support.

> -       features = netdev_intersect_features(features, real_dev->features);
> +       if (real_dev_features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
> +               real_dev_features |= NETIF_F_HW_CSUM;
> +
> +       features = netdev_intersect_features(features, real_dev_features);

This part all looks good.

My only advice like I said would be to record the vlan_features
intersection first based on the real_dev. That way you don't risk
losing state data from real device if for some reason it doesn't
support checksum offload with VLAN tagged frames.

>         features |= old_features & (NETIF_F_SOFT_FEATURES | NETIF_F_GSO_SOFTWARE);
>         features |= NETIF_F_LLTX;
> --
> 2.7.4
>
