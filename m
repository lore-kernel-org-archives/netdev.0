From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/2] net: Allow no-cache copy from user on transmit
Date: Wed, 9 Mar 2011 14:04:14 +0100
Message-ID: <AANLkTikFSRr649_P8V8J7Xj_KY8hSEw23RBAyyV2wUQr@mail.gmail.com>
References: <alpine.DEB.2.00.1103082053350.1433@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:36412 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932144Ab1CINEP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 08:04:15 -0500
Received: by qyg14 with SMTP id 14so396056qyg.19
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2011 05:04:14 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1103082053350.1433@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/9 Tom Herbert <therbert@google.com>:
> This patch uses __copy_from_user_nocache (from skb_copy_to_page)
> on transmit to bypass data cache for a performance improvement.
> This functionality is configurable per device using ethtool, the
> device must also be doing TX csum offload to enable. =A0It seems
> reasonable to set this when the device does not copy or
> otherwise touch the data.
>
> This patch was tested using 200 instances of netperf TCP_RR with
> 1400 byte request and one byte reply. =A0Platform is 16 core AMD.
>
> No-cache copy disabled:
> =A0 672703 tps, 97.13% client utilization
> =A0 50/90/99% latency 244.31 484.205 1028.41
>
> No-cache copy enabled:
> =A0 702113 tps, 96.16% client utilization,
> =A0 50/90/99% latency 238.56 467.56 956.955
>
> This seems to provide a nice little performance improvement and is
> consistent in the tests I ran. =A0Presumably, this would provide
> the greatest =A0benfits in the presence of an application workload
> stressing the cache and a lot of transmit data happening. =A0I don't
> yet see a downside to using this.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> =A0include/linux/ethtool.h =A0 | =A0 =A04 ++++
> =A0include/linux/netdevice.h | =A0 =A04 +++-
> =A0include/net/sock.h =A0 =A0 =A0 =A0| =A0 =A05 +++++
> =A0net/core/ethtool.c =A0 =A0 =A0 =A0| =A0 11 ++++++++++-
> =A04 files changed, 22 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index aac3e2e..2cf3cc9 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -833,6 +833,10 @@ struct ethtool_ops {
> =A0#define ETHTOOL_GFEATURES =A0 =A0 =A00x0000003a /* Get device offl=
oad settings */
> =A0#define ETHTOOL_SFEATURES =A0 =A0 =A00x0000003b /* Change device o=
ffload settings */
>
> +#define ETHTOOL_GNCCOPY =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x0000003c /*=
 Get no-cache-copy enable
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 * (ethtool_value). */
> +#define ETHTOOL_SNCCOPY =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x0000003d /*=
 Set no-cache-copy enable
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 * (ethtool_value). */

Please don't add new get/set ops for netdev features - G/SFEATURES
handle them all.

Proper way is to modify NETIF_F_ETHTOOL_BITS, netdev_fix_features()
and, if needed for now,
legacy get/set ops (they will go away, eventually).

> =A0/* compatibility with older code */
> =A0#define SPARC_ETH_GSET =A0 =A0 =A0 =A0 ETHTOOL_GSET
> =A0#define SPARC_ETH_SSET =A0 =A0 =A0 =A0 ETHTOOL_SSET
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 71563e7..1b72f29 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -978,6 +978,7 @@ struct net_device {
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
> @@ -1020,7 +1021,8 @@ struct net_device {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NETIF=
_F_FRAGLIST)
>
> =A0 =A0 =A0 =A0/* changeable features with no special hardware requir=
ements */
> -#define NETIF_F_SOFT_FEATURES =A0(NETIF_F_GSO | NETIF_F_GRO)
> +#define NETIF_F_SOFT_FEATURES =A0(NETIF_F_GSO | NETIF_F_GRO | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NETI=
=46_F_NOCACHE_COPY)
>
> =A0 =A0 =A0 =A0/* Interface index. Unique device identifier =A0 =A0*/
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ifindex;
> diff --git a/include/net/sock.h b/include/net/sock.h
> index da0534d..55b1385 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1401,6 +1401,11 @@ static inline int skb_copy_to_page(struct sock=
 *sk, char __user *from,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->csum =3D csum_block_add(skb->csum=
, csum, skb->len);
> + =A0 =A0 =A0 } else if (sk->sk_route_caps & NETIF_F_NOCACHE_COPY) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!access_ok(VERIFY_READ, from, copy)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|| __copy_from_user_nocache(page=
_address(page) + off,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0from, copy))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> =A0 =A0 =A0 =A0} else if (copy_from_user(page_address(page) + off, fr=
om, copy))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EFAULT;
>
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index c1a71bb..a8b2638 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -328,6 +328,7 @@ static const char netdev_features_strings[ETHTOOL=
_DEV_FEATURE_WORDS * 32][ETH_GS
> =A0 =A0 =A0 =A0/* NETIF_F_NETNS_LOCAL */ =A0 =A0 "netns-local",
> =A0 =A0 =A0 =A0/* NETIF_F_GRO */ =A0 =A0 =A0 =A0 =A0 =A0 "rx-gro",
> =A0 =A0 =A0 =A0/* NETIF_F_LRO */ =A0 =A0 =A0 =A0 =A0 =A0 "rx-lro",
> + =A0 =A0 =A0 /* NETIF_F_NOCACHE_COPY */ =A0 =A0"tx-nocache-copy",
>
> =A0 =A0 =A0 =A0/* NETIF_F_TSO */ =A0 =A0 =A0 =A0 =A0 =A0 "tx-tcp-segm=
entation",
> =A0 =A0 =A0 =A0/* NETIF_F_UFO */ =A0 =A0 =A0 =A0 =A0 =A0 "tx-udp-frag=
mentation",

You can't put the strings in the middle of this array. Positions in
the array are dependent on flag bit position.

[...]

Best Regards,
Micha=B3 Miros=B3aw
