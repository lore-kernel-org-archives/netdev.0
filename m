From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Sun, 04 Mar 2012 07:44:41 -0800
Message-ID: <1330875881.2730.15.camel@edumazet-laptop>
References: <20120304093727.GA5115@Spy32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, davem@davemloft.net, netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:42796 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518Ab2CDPoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 10:44:44 -0500
Received: by dadp12 with SMTP id p12so3953038dad.11
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2012 07:44:44 -0800 (PST)
In-Reply-To: <20120304093727.GA5115@Spy32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 04 mars 2012 =C3=A0 17:37 +0800, Junchang Wang a =C3=A9crit=
 :
> I submitted this two months ago. This is a resubmission. Thanks.
>=20
> Switch to use ndo_get_stats64 to get 64bit statistics.
> Two sync entries are used (one for Rx and one for Tx).
>=20
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c |   61 ++++++++++++++++++++++++=
+++++-----
>  1 files changed, 52 insertions(+), 9 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index fbd855b..c1e2421 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -675,6 +675,12 @@ enum rtl_flag {
>  	RTL_FLAG_MAX
>  };
> =20
> +struct rtl8169_stats {
> +	struct u64_stats_sync	syncp;

small point : Using this means you have a 32bit hole here (on 32bit
build). Its minor, you dont need to change.

> +	u64			packets;
> +	u64			bytes;
> +};
> +
>  struct rtl8169_private {
>  	void __iomem *mmio_addr;	/* memory map physical address */
>  	struct pci_dev *pci_dev;
> @@ -689,6 +695,8 @@ struct rtl8169_private {
>  	u32 dirty_tx;
>  	struct TxDesc *TxDescArray;	/* 256-aligned Tx descriptor ring */
>  	struct RxDesc *RxDescArray;	/* 256-aligned Rx descriptor ring */
> +	struct rtl8169_stats rx_stats;
> +	struct rtl8169_stats tx_stats;

	You could try to put these somewhere else, to try to keep this portion
as read only memory, to be more SMP friendly.
(Some loaded server could have one CPU serving RX stuff, and other cpus
doing TX stuff)=20

>  	dma_addr_t TxPhyAddr;
>  	dma_addr_t RxPhyAddr;
>  	void *Rx_databuff[NUM_RX_DESC];	/* Rx data buffers */
> @@ -775,7 +783,9 @@ static void rtl_hw_start(struct net_device *dev);
>  static int rtl8169_close(struct net_device *dev);
>  static void rtl_set_rx_mode(struct net_device *dev);
>  static void rtl8169_tx_timeout(struct net_device *dev);
> -static struct net_device_stats *rtl8169_get_stats(struct net_device =
*dev);
> +static struct rtnl_link_stats64 *rtl8169_get_stats64(struct net_devi=
ce *dev,
> +						    struct rtnl_link_stats64
> +						    *stats);
>  static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
>  static void rtl8169_rx_clear(struct rtl8169_private *tp);
>  static int rtl8169_poll(struct napi_struct *napi, int budget);
> @@ -3521,7 +3531,7 @@ static void rtl_disable_msi(struct pci_dev *pde=
v, struct rtl8169_private *tp)
>  static const struct net_device_ops rtl8169_netdev_ops =3D {
>  	.ndo_open		=3D rtl8169_open,
>  	.ndo_stop		=3D rtl8169_close,
> -	.ndo_get_stats		=3D rtl8169_get_stats,
> +	.ndo_get_stats64	=3D rtl8169_get_stats64,
>  	.ndo_start_xmit		=3D rtl8169_start_xmit,
>  	.ndo_tx_timeout		=3D rtl8169_tx_timeout,
>  	.ndo_validate_addr	=3D eth_validate_addr,
> @@ -5658,8 +5668,10 @@ static void rtl_tx(struct net_device *dev, str=
uct rtl8169_private *tp)
>  		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
>  				     tp->TxDescArray + entry);
>  		if (status & LastFrag) {
> -			dev->stats.tx_packets++;
> -			dev->stats.tx_bytes +=3D tx_skb->skb->len;
> +			u64_stats_update_begin(&tp->tx_stats.syncp);
> +			tp->tx_stats.packets++;
> +			tp->tx_stats.bytes +=3D tx_skb->skb->len;
> +			u64_stats_update_end(&tp->tx_stats.syncp);
>  			dev_kfree_skb(tx_skb->skb);
>  			tx_skb->skb =3D NULL;
>  		}
> @@ -5807,8 +5819,10 @@ process_pkt:
> =20
>  			napi_gro_receive(&tp->napi, skb);
> =20
> -			dev->stats.rx_bytes +=3D pkt_size;
> -			dev->stats.rx_packets++;
> +			u64_stats_update_begin(&tp->rx_stats.syncp);
> +			tp->rx_stats.packets++;
> +			tp->rx_stats.bytes +=3D pkt_size;
> +			u64_stats_update_end(&tp->rx_stats.syncp);
>  		}
> =20
>  		/* Work around for AMD plateform. */
> @@ -6070,20 +6084,49 @@ static void rtl_set_rx_mode(struct net_device=
 *dev)
>  }
> =20
>  /**
> - *  rtl8169_get_stats - Get rtl8169 read/write statistics
> + *  rtl8169_get_stats64 - Get rtl8169 read/write statistics
>   *  @dev: The Ethernet Device to get statistics for

missing @stats

>   *
>   *  Get TX/RX statistics for rtl8169
>   */
> -static struct net_device_stats *rtl8169_get_stats(struct net_device =
*dev)
> +static struct rtnl_link_stats64 *
> +rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64=
 *stats)
>  {
>  	struct rtl8169_private *tp =3D netdev_priv(dev);
>  	void __iomem *ioaddr =3D tp->mmio_addr;
> +	u64 _packets, _bytes;
> +	unsigned int start;
> =20
>  	if (netif_running(dev))
>  		rtl8169_rx_missed(dev, ioaddr);
> =20
> -	return &dev->stats;
> +	do {
> +		start =3D u64_stats_fetch_begin_bh(&tp->rx_stats.syncp);
> +		_packets =3D tp->rx_stats.packets;
> +		_bytes =3D tp->rx_stats.bytes;
> +	} while (u64_stats_fetch_retry_bh(&tp->rx_stats.syncp, start));
> +
> +	stats->rx_packets =3D _packets;
> +	stats->rx_bytes	=3D _bytes;

You dont need _bytes and _packets temp variables, as @stats points to a
private memory, we can use it as working storage, just do :

       do {
               start =3D u64_stats_fetch_begin_bh(&tp->rx_stats.syncp);
               stats->rx_packets =3D tp->rx_stats.packets;
               stats->rx_bytes =3D tp->rx_stats.bytes;
       } while (u64_stats_fetch_retry_bh(&tp->rx_stats.syncp, start));


> +
> +	do {
> +		start =3D u64_stats_fetch_begin_bh(&tp->tx_stats.syncp);
> +		_packets =3D tp->tx_stats.packets;
> +		_bytes =3D tp->tx_stats.bytes;
> +	} while (u64_stats_fetch_retry_bh(&tp->tx_stats.syncp, start));

same here.

> +
> +	stats->tx_packets =3D _packets;
> +	stats->tx_bytes	=3D _bytes;
> +
