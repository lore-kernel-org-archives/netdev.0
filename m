From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v2] net: Allow no-cache copy from user on transmit
Date: Wed, 23 Mar 2011 19:42:20 +0100
Message-ID: <AANLkTi=Tg4jW7hZZ43E71GNi+d8JWMJQcv3ExZA6zJQW@mail.gmail.com>
References: <alpine.DEB.2.00.1103231003120.16608@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:59762 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756166Ab1CWSml convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 14:42:41 -0400
Received: by qwk3 with SMTP id 3so6164490qwk.19
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 11:42:40 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1103231003120.16608@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/23 Tom Herbert <therbert@google.com>:
> This patch uses __copy_from_user_nocache (from skb_copy_to_page)
> on transmit to bypass data cache for a performance improvement.
> This functionality is configurable per device using ethtool, the
> device must also be doing TX csum offload to enable. =A0It seems
> reasonable to set this when the netdevice does not copy or
> otherwise touch the data.
>
> This patch was tested using 200 instances of netperf TCP_RR with
> 1400 byte request and one byte reply. =A0Platform is 16 core AMD x86.
>
> No-cache copy disabled:
> =A0 672703 tps, 97.13% utilization
> =A0 50/90/99% latency:244.31 484.205 1028.41
>
> No-cache copy enabled:
> =A0 702113 tps, 96.16% utilization,
> =A0 50/90/99% latency 238.56 467.56 956.955
>
> Using 14000 byte request and response sizes demonstrate the
> effects more dramatically:
>
> No-cache copy disabled:
> =A0 79571 tps, 34.34 %utlization
> =A0 50/90/95% latency 1584.46 2319.59 5001.76
>
> No-cache copy enabled:
> =A0 83856 tps, 34.81% utilization
> =A0 50/90/95% latency 2508.42 2622.62 2735.88
>
> Note especially the effect on tail latency (95th percentile).
>
> This seems to provide a nice performance improvement and is
> consistent in the tests I ran. =A0Presumably, this would provide
> the greatest benfits in the presence of an application workload
> stressing the cache and a lot of transmit data happening. =A0I don't
> yet see a downside to using this.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> =A0include/linux/netdevice.h | =A0 10 ++++++++--
> =A0include/net/sock.h =A0 =A0 =A0 =A0| =A0 =A05 +++++
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0net/core/ethtool.c =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A04 files changed, 15 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 5eeb2cd..52d444f 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1066,6 +1066,7 @@ struct net_device {
> =A0#define NETIF_F_NTUPLE =A0 =A0 =A0 =A0 (1 << 27) /* N-tuple filter=
s supported */
> =A0#define NETIF_F_RXHASH =A0 =A0 =A0 =A0 (1 << 28) /* Receive hashin=
g offload */
> =A0#define NETIF_F_RXCSUM =A0 =A0 =A0 =A0 (1 << 29) /* Receive checks=
umming offload */
> +#define NETIF_F_NOCACHE_COPY =A0 (1 << 30) /* Use no-cache copyfromu=
ser */
>
> =A0 =A0 =A0 =A0/* Segmentation offload features */
> =A0#define NETIF_F_GSO_SHIFT =A0 =A0 =A016
> @@ -1081,7 +1082,7 @@ struct net_device {
> =A0 =A0 =A0 =A0/* =3D all defined minus driver/device-class-related *=
/
> =A0#define NETIF_F_NEVER_CHANGE =A0 (NETIF_F_HIGHDMA | NETIF_F_VLAN_C=
HALLENGED | \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NE=
TIF_F_LLTX | NETIF_F_NETNS_LOCAL)
> -#define NETIF_F_ETHTOOL_BITS =A0 (0x3f3fffff & ~NETIF_F_NEVER_CHANGE=
)
> +#define NETIF_F_ETHTOOL_BITS =A0 (0x7f3fffff & ~NETIF_F_NEVER_CHANGE=
)
>
> =A0 =A0 =A0 =A0/* List of features with software fallbacks. */
> =A0#define NETIF_F_GSO_SOFTWARE =A0 (NETIF_F_TSO | NETIF_F_TSO_ECN | =
\
> @@ -1108,7 +1109,12 @@ struct net_device {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NETIF=
_F_FRAGLIST)
>
> =A0 =A0 =A0 =A0/* changeable features with no special hardware requir=
ements */
> -#define NETIF_F_SOFT_FEATURES =A0(NETIF_F_GSO | NETIF_F_GRO)
> +#define NETIF_F_SOFT_FEATURES =A0(NETIF_F_GSO | NETIF_F_GRO | =A0 =A0=
\
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NETI=
=46_F_NOCACHE_COPY)
> +
> + =A0 =A0 =A0 /* soft features automatically enabled */
> +#define NETIF_F_SOFT_FEAT_ENAB (NETIF_F_GSO | NETIF_F_GRO)
> +
>
> =A0 =A0 =A0 =A0/* Interface index. Unique device identifier =A0 =A0*/
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ifindex;
> diff --git a/include/net/sock.h b/include/net/sock.h
> index da0534d..74ce586 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1401,6 +1401,11 @@ static inline int skb_copy_to_page(struct sock=
 *sk, char __user *from,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->csum =3D csum_block_add(skb->csum=
, csum, skb->len);
> + =A0 =A0 =A0 } else if (sk->sk_route_caps & NETIF_F_NOCACHE_COPY) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!access_ok(VERIFY_READ, from, copy)=
 ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __copy_from_user_nocache(page_a=
ddress(page) + off,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 from, copy))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> =A0 =A0 =A0 =A0} else if (copy_from_user(page_address(page) + off, fr=
om, copy))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EFAULT;
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0b88eba..c3ed95e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5435,7 +5435,7 @@ int register_netdevice(struct net_device *dev)
> =A0 =A0 =A0 =A0 * software offloads (GSO and GRO).
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0dev->hw_features |=3D NETIF_F_SOFT_FEATURES;
> - =A0 =A0 =A0 dev->features |=3D NETIF_F_SOFT_FEATURES;
> + =A0 =A0 =A0 dev->features |=3D NETIF_F_SOFT_FEAT_ENAB;
> =A0 =A0 =A0 =A0dev->wanted_features =3D dev->features & dev->hw_featu=
res;
>
> =A0 =A0 =A0 =A0/* Avoid warning from netdev_fix_features() for GSO wi=
thout SG */
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index c1a71bb..40b6fe0 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -344,7 +344,7 @@ static const char netdev_features_strings[ETHTOOL=
_DEV_FEATURE_WORDS * 32][ETH_GS
> =A0 =A0 =A0 =A0/* NETIF_F_NTUPLE */ =A0 =A0 =A0 =A0 =A0"rx-ntuple-fil=
ter",
> =A0 =A0 =A0 =A0/* NETIF_F_RXHASH */ =A0 =A0 =A0 =A0 =A0"rx-hashing",
> =A0 =A0 =A0 =A0/* NETIF_F_RXCSUM */ =A0 =A0 =A0 =A0 =A0"rx-checksum",
> - =A0 =A0 =A0 "",
> + =A0 =A0 =A0 /* NETIF_F_NOCACHE_COPY */ =A0 =A0"tx-nocache-copy"
> =A0 =A0 =A0 =A0"",
> =A0};

I would rather see it enabled by default, including "hacks" in
register_netdev() like for GSO. Otherwise not much people will test
this. There should also be constraints for it in
netdev_fix_features().

BTW, what happens if this is used on e.g. bridge device or veth and
later packet ends up going to device which needs to do checksumming in
software?

Best Regards,
Micha=B3 Miros=B3aw
