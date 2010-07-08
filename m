From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next-2.6] bnx2: 64 bit stats on all arches
Date: Thu, 8 Jul 2010 07:00:37 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B842BD250@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1278583542.2651.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3520 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753261Ab0GHOAt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 10:00:49 -0400
In-Reply-To: <1278583542.2651.19.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Now core network is able to handle 64 bit netdevice stats on 32 bit
> arches, we can provide them for bnx2, since hardware maintains some 64
> bit counters.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  drivers/net/bnx2.c |   22 +++++++---------------
>  1 file changed, 7 insertions(+), 15 deletions(-)
>
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 22fa1e9..2975bf9 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -6589,36 +6589,28 @@ bnx2_save_stats(struct bnx2 *bp)
>               temp_stats[i] += hw_stats[i];
>  }
>
> -#define GET_64BIT_NET_STATS64(ctr)                           \
> -     (unsigned long) ((unsigned long) (ctr##_hi) << 32) +    \
> -     (unsigned long) (ctr##_lo)
> +#define GET_64BIT_NET_STATS64(ctr)           \
> +     (((u64) (ctr##_hi) << 32) + (u64) (ctr##_lo))
>
>  #define GET_64BIT_NET_STATS32(ctr)                           \
>       (ctr##_lo)

It seems that GET_64BIT_NET_STATS32 is no longer needed.
Other than that,

Acked-by: Michael Chan <mchan@broadcom.com>

Thanks.

>
> -#if (BITS_PER_LONG == 64)
>  #define GET_64BIT_NET_STATS(ctr)                             \
>       GET_64BIT_NET_STATS64(bp->stats_blk->ctr) +             \
>       GET_64BIT_NET_STATS64(bp->temp_stats_blk->ctr)
> -#else
> -#define GET_64BIT_NET_STATS(ctr)                             \
> -     GET_64BIT_NET_STATS32(bp->stats_blk->ctr) +             \
> -     GET_64BIT_NET_STATS32(bp->temp_stats_blk->ctr)
> -#endif
>
>  #define GET_32BIT_NET_STATS(ctr)                             \
>       (unsigned long) (bp->stats_blk->ctr +                   \
>                        bp->temp_stats_blk->ctr)
>
> -static struct net_device_stats *
> -bnx2_get_stats(struct net_device *dev)
> +static struct rtnl_link_stats64 *
> +bnx2_get_stats64(struct net_device *dev, struct
> rtnl_link_stats64 *net_stats)
>  {
>       struct bnx2 *bp = netdev_priv(dev);
> -     struct net_device_stats *net_stats = &dev->stats;
>
> -     if (bp->stats_blk == NULL) {
> +     if (bp->stats_blk == NULL)
>               return net_stats;
> -     }
> +
>       net_stats->rx_packets =
>               GET_64BIT_NET_STATS(stat_IfHCInUcastPkts) +
>               GET_64BIT_NET_STATS(stat_IfHCInMulticastPkts) +
> @@ -8289,7 +8281,7 @@ static const struct net_device_ops
> bnx2_netdev_ops = {
>       .ndo_open               = bnx2_open,
>       .ndo_start_xmit         = bnx2_start_xmit,
>       .ndo_stop               = bnx2_close,
> -     .ndo_get_stats          = bnx2_get_stats,
> +     .ndo_get_stats64        = bnx2_get_stats64,
>       .ndo_set_rx_mode        = bnx2_set_rx_mode,
>       .ndo_do_ioctl           = bnx2_ioctl,
>       .ndo_validate_addr      = eth_validate_addr,
>
>
>
>

