From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH V2 net] netdevice: Include NETIF_F_HW_CSUM when
 intersecting features
Date: Thu, 20 Apr 2017 15:31:51 -0700
Message-ID: <CAKgT0UcHtWYQDcYda+i8R8WhBKeWbOBZRHDcAmJXZYuP1RM7-Q@mail.gmail.com>
References: <1492715844-30273-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Vladislav Yasevich <vyasevic@redhat.com>,
        Michal Kubecek <mkubecek@suse.cz>,
        Tom Herbert <tom@herbertland.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35051 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970504AbdDTWbx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 18:31:53 -0400
Received: by mail-io0-f194.google.com with SMTP id d203so21759495iof.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 15:31:53 -0700 (PDT)
In-Reply-To: <1492715844-30273-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 12:17 PM, Vladislav Yasevich
<vyasevich@gmail.com> wrote:
> While hardware device use either NETIF_F_(IP|IPV6)_CSUM or
> NETIF_F_HW_CSUM, all of the software devices use HW_CSUM.
> This results in an interesting situation when the software
> device is configured on top of hw device using (IP|IPV6)_CSUM.
> In this situation, the user can't turn off checksum offloading
> features on the software device.

Why wouldn't they be able to? It seems like the software device
shouldn't be setting IP_CSUM or IPV6_CSUM feature flags, but they will
be set in the intersect features. The result won't have
NETIF_F_HW_CSUM set, but it should advertise the features of the lower
device instead.

> This patch resolves that by adding NETIF_F_HW_CSUM to the mask
> if a feature set includes only IP|IPV6 csum.  This allows the user
> to control the upper (software) device checksum, while at the same
> time correctly propagating lower device changes up.

You can't go this way. HW_CSUM is an all inclusive feature flag,
whereas IP_CSUM and IPV6_CSUM specify only specific offload types.
With your change the lower device could disable IPV6_CSUM for instance
but you would still end up advertising checksum offload via HW_CSUM.

> CC: Michal Kubecek <mkubecek@suse.cz>
> CC: Alexander Duyck <alexander.duyck@gmail.com>
> CC: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>
> ---
>
> V2: Addressed comments from Alex Duyck.  I tested this with hacked virtio
> device that set IP|IPV6 checksums instead of HW.  Configuring a vlan on
> top gave the vlan device with 'ip-generic: on' setting (using HW checksum).
> This allows me to change vlan checksum offloads independent of virt-io nic.
> Changes to virtio-nic propagated up to vlan, turning off the offloading
> correctly.
>
>  include/linux/netdevice.h | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index b0aa089..81aed2f 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -4009,10 +4009,10 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
>                                                           netdev_features_t f2)
>  {
>         if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
> -               if (f1 & NETIF_F_HW_CSUM)
> -                       f1 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
> -               else
> -                       f2 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
> +               if (f1 & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))
> +                       f1 |= NETIF_F_HW_CSUM;
> +               if(f2 & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))
> +                       f2 |= NETIF_F_HW_CSUM;
>         }
>
>         return f1 & f2;
> --
> 2.7.4
>

This doesn't work. "NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM" doesn't
equate to "NETIF_F_HW_CSUM". The problem is NETIF_F_HW_CSUM is a
catch-all, the IP and IPV6 CSUM flags are not. Right now you would
introduce escapes on devices that enable IP but not IPv6, or the other
way around.

Can you point to the exact case where this code is an issue? It seems
like maybe you are wanting to have NETIF_F_HW_CSUM set if you support
offloading a given protocol. You might want to look at how we dealt
with this in the GSO code path so that if we could offload the
checksum we set NETIF_F_HW_CSUM based on protocol and the CSUM offload
feature bit for that protocol.

- Alex
