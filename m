From: Jon Mason <jon.mason@myri.com>
Subject: Re: [PATCH net-next-2.6] myricom: remove stats_lock
Date: Mon, 20 Jun 2011 13:00:45 -0500
Message-ID: <BANLkTim-Akor_QuFsF+SM0u5=BwjdwYr2g@mail.gmail.com>
References: <1308550066.3539.129.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:54576 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755462Ab1FTSAq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 14:00:46 -0400
Received: by iyb12 with SMTP id 12so2176385iyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 11:00:46 -0700 (PDT)
In-Reply-To: <1308550066.3539.129.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2011 at 1:07 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> stats_lock is non useless, lets remove it.
>
> Also, ndo_get_stats64() doesnt have to clear the stats, caller takes
> care of this.
>
> Note: folding 32bit fields in 64bit one is problematic when one of 32=
bit
> values wraps : SNMP reader will see a ~2^32 back change in a 64bit
> value. A future patch should fix this.

Good point, I'll push a patch shortly to increase the size of the
slice stats to 64b.

>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Andrew Gallatin <gallatin@myri.com>
> CC: Brice Goglin <brice@myri.com>

Acked-by: Jon Mason <mason@myri.com>

> ---
> =A0drivers/net/myri10ge/myri10ge.c | =A0 10 +++-------
> =A01 file changed, 3 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/m=
yri10ge.c
> index 04e10f4..3e89a84 100644
> --- a/drivers/net/myri10ge/myri10ge.c
> +++ b/drivers/net/myri10ge/myri10ge.c
> @@ -210,7 +210,6 @@ struct myri10ge_priv {
> =A0 =A0 =A0 =A0int big_bytes;
> =A0 =A0 =A0 =A0int max_intr_slots;
> =A0 =A0 =A0 =A0struct net_device *dev;
> - =A0 =A0 =A0 spinlock_t stats_lock;
> =A0 =A0 =A0 =A0u8 __iomem *sram;
> =A0 =A0 =A0 =A0int sram_size;
> =A0 =A0 =A0 =A0unsigned long board_span;
> @@ -1837,6 +1836,7 @@ myri10ge_get_ethtool_stats(struct net_device *n=
etdev,
> =A0 =A0 =A0 =A0int i;
>
> =A0 =A0 =A0 =A0/* force stats update */
> + =A0 =A0 =A0 memset(&link_stats, 0, sizeof(link_stats));
> =A0 =A0 =A0 =A0(void)myri10ge_get_stats(netdev, &link_stats);
> =A0 =A0 =A0 =A0for (i =3D 0; i < MYRI10GE_NET_STATS_LEN; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data[i] =3D ((u64 *)&link_stats)[i];
> @@ -2981,12 +2981,10 @@ drop:
> =A0static struct rtnl_link_stats64 *myri10ge_get_stats(struct net_dev=
ice *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct rtnl_link_stats64 *stats)
> =A0{
> - =A0 =A0 =A0 struct myri10ge_priv *mgp =3D netdev_priv(dev);
> - =A0 =A0 =A0 struct myri10ge_slice_netstats *slice_stats;
> + =A0 =A0 =A0 const struct myri10ge_priv *mgp =3D netdev_priv(dev);
> + =A0 =A0 =A0 const struct myri10ge_slice_netstats *slice_stats;
> =A0 =A0 =A0 =A0int i;
>
> - =A0 =A0 =A0 spin_lock(&mgp->stats_lock);
> - =A0 =A0 =A0 memset(stats, 0, sizeof(*stats));
> =A0 =A0 =A0 =A0for (i =3D 0; i < mgp->num_slices; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slice_stats =3D &mgp->ss[i].stats;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stats->rx_packets +=3D slice_stats->rx=
_packets;
> @@ -2996,7 +2994,6 @@ static struct rtnl_link_stats64 *myri10ge_get_s=
tats(struct net_device *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stats->rx_dropped +=3D slice_stats->rx=
_dropped;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stats->tx_dropped +=3D slice_stats->tx=
_dropped;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 spin_unlock(&mgp->stats_lock);
> =A0 =A0 =A0 =A0return stats;
> =A0}
>
> @@ -3966,7 +3963,6 @@ static int myri10ge_probe(struct pci_dev *pdev,=
 const struct pci_device_id *ent)
> =A0 =A0 =A0 =A0setup_timer(&mgp->watchdog_timer, myri10ge_watchdog_ti=
mer,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long)mgp);
>
> - =A0 =A0 =A0 spin_lock_init(&mgp->stats_lock);
> =A0 =A0 =A0 =A0SET_ETHTOOL_OPS(netdev, &myri10ge_ethtool_ops);
> =A0 =A0 =A0 =A0INIT_WORK(&mgp->watchdog_work, myri10ge_watchdog);
> =A0 =A0 =A0 =A0status =3D register_netdev(netdev);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
