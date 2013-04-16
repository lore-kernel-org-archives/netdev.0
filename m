From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v2 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Tue, 16 Apr 2013 16:39:23 +0100
Message-ID: <1366126763.2645.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <y> <1366108587-3866-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15420 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935808Ab3DPPj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 11:39:27 -0400
In-Reply-To: <1366108587-3866-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-16 at 11:36 +0100, Jim Baxter wrote:
> Enables hardware generatation of IP header and
> protocol specific checksums for transmitted
> packets.
> 
> Enabled hardware discarding of received packets with
> invalid IP header or protocol specific checksums.
> 
> The feature is enabled by default but can be
> enabled/disabled by ethtool.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> ---
>  drivers/net/ethernet/freescale/fec.h      |    9 +-
>  drivers/net/ethernet/freescale/fec_main.c |  134 +++++++++++++++++++++++++++++
>  2 files changed, 142 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
> index eb43729..f558a1a 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -52,6 +52,7 @@
>  #define FEC_R_FIFO_RSEM		0x194 /* Receive FIFO section empty threshold */
>  #define FEC_R_FIFO_RAEM		0x198 /* Receive FIFO almost empty threshold */
>  #define FEC_R_FIFO_RAFL		0x19c /* Receive FIFO almost full threshold */
> +#define FEC_RACC		0x1C4 /* Receive Accelerator function */
>  #define FEC_MIIGSK_CFGR		0x300 /* MIIGSK Configuration reg */
>  #define FEC_MIIGSK_ENR		0x308 /* MIIGSK Enable reg */
>  
> @@ -164,9 +165,11 @@ struct bufdesc_ex {
>  #define BD_ENET_TX_CSL          ((ushort)0x0001)
>  #define BD_ENET_TX_STATS        ((ushort)0x03ff)        /* All status bits */
>  
> -/*enhanced buffer desciptor control/status used by Ethernet transmit*/
> +/*enhanced buffer descriptor control/status used by Ethernet transmit*/
>  #define BD_ENET_TX_INT          0x40000000
>  #define BD_ENET_TX_TS           0x20000000
> +#define BD_ENET_TX_PINS         0x10000000
> +#define BD_ENET_TX_IINS         0x08000000
>  
> 
>  /* This device has up to three irqs on some platforms */
> @@ -190,6 +193,9 @@ struct bufdesc_ex {
>  
>  #define BD_ENET_RX_INT          0x00800000
>  #define BD_ENET_RX_PTP          ((ushort)0x0400)
> +#define BD_ENET_RX_ICE	    0x00000020
> +#define BD_ENET_RX_PCR		0x00000010
> +#define FLAG_RX_CSUM_ENABLED	(BD_ENET_RX_ICE | BD_ENET_RX_PCR)
>
>  /* The FEC buffer descriptors track the ring buffers.  The rx_bd_base and
>   * tx_bd_base always point to the base of the buffer descriptors.  The
> @@ -247,6 +253,7 @@ struct fec_enet_private {
>  	int	pause_flag;
>  
>  	struct	napi_struct napi;
> +	int	csum_flags;
>  
>  	struct ptp_clock *ptp_clock;
>  	struct ptp_clock_info ptp_caps;
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index d7657a4..738a57d 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -34,6 +34,12 @@
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
>  #include <linux/skbuff.h>
> +#include <linux/in.h>
> +#include <linux/ip.h>
> +#include <net/ip.h>
> +#include <linux/tcp.h>
> +#include <linux/udp.h>
> +#include <linux/icmp.h>
>  #include <linux/spinlock.h>
>  #include <linux/workqueue.h>
>  #include <linux/bitops.h>
> @@ -181,6 +187,10 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
>  #define PKT_MINBUF_SIZE		64
>  #define PKT_MAXBLR_SIZE		1520
>  
> +/* FEC receive accleration */
> +#define FEC_RACC_IPDIS		(1 << 1)
> +#define FEC_RACC_PRODIS		(1 << 2)
> +
>  /*
>   * The 5270/5271/5280/5282/532x RX control register also contains maximum frame
>   * size bits. Other FEC hardware does not, so we need to take that into
> @@ -241,6 +251,52 @@ static void *swap_buffer(void *bufaddr, int len)
>  	return bufaddr;
>  }
>  
> +static void
> +fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	if (!(ndev->features & NETIF_F_HW_CSUM))
> +		return;

Don't check features.  You must fill in the checksum for every packet
with ip_summed == CHECKSUM_PARTIAL, regardless of whether there has been
a change to features since it was queued.

> +	/* Only run for packets requiring a checksum. */
> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
> +		return;
> +	if (skb->len < (ETH_HLEN + sizeof(struct iphdr)))
> +		return;
> +
> +	if (skb->protocol == htons(ETH_P_IP)) {
> +		ip_hdr(skb)->check = 0;

You must use skb_cow_head() before editing the header.

> +		switch (ip_hdr(skb)->protocol) {
> +		case IPPROTO_UDP:
> +			if (skb->len < (ETH_HLEN +
> +				(ip_hdr(skb)->ihl << 2) +
> +				sizeof(struct udphdr)))
> +				return;
> +			skb_set_transport_header(skb,
> +					ETH_HLEN + ip_hdrlen(skb));
> +			udp_hdr(skb)->check = 0;
> +			break;
> +		case IPPROTO_TCP:
> +			if (skb->len < (ETH_HLEN +
> +				(ip_hdr(skb)->ihl << 2) +
> +				sizeof(struct tcphdr)))
> +				return;
> +			if (tcp_hdr(skb))
> +				tcp_hdr(skb)->check = 0;
> +			break;
> +		case IPPROTO_ICMP:
> +			if (skb->len < (ETH_HLEN +
> +				(ip_hdr(skb)->ihl << 2) +
> +				sizeof(struct icmphdr)))
> +				return;
> +			if (icmp_hdr(skb))
> +				icmp_hdr(skb)->checksum = 0;
> +			break;
> +		default:
> +			break;
> +		}
> +	}
> +}
> +
>  static netdev_tx_t
>  fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  {
> @@ -277,6 +333,9 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	bufaddr = skb->data;
>  	bdp->cbd_datlen = skb->len;
>  
> +	/* HW accleration for ICMP TCP UDP checksum */
> +	fec_enet_clear_csum(skb, ndev);
> +
>  	/*
>  	 * On some FEC implementations data must be aligned on
>  	 * 4-byte boundaries. Use bounce buffers to copy data
> @@ -328,6 +387,10 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  		} else {
>  
>  			ebdp->cbd_esc = BD_ENET_TX_INT;
> +			if ((ndev->features & NETIF_F_HW_CSUM) &&

Don't check features.

> +					(skb->ip_summed == CHECKSUM_PARTIAL))
> +				ebdp->cbd_esc |= BD_ENET_TX_PINS
> +						| BD_ENET_TX_IINS;
>  		}
>  	}
>  	/* If this was the last BD in the ring, start at the beginning again. */
> @@ -407,6 +470,7 @@ fec_restart(struct net_device *ndev, int duplex)
>  	const struct platform_device_id *id_entry =
>  				platform_get_device_id(fep->pdev);
>  	int i;
> +	u32 val;
>  	u32 temp_mac[2];
>  	u32 rcntl = OPT_FRAME_SIZE | 0x04;
>  	u32 ecntl = 0x2; /* ETHEREN */
> @@ -473,6 +537,14 @@ fec_restart(struct net_device *ndev, int duplex)
>  	/* Set MII speed */
>  	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
>  
> +	/* set RX checksum */
> +	val = readl(fep->hwp + FEC_RACC);
> +	if (fep->csum_flags & FLAG_RX_CSUM_ENABLED)
> +		val |= (FEC_RACC_IPDIS | FEC_RACC_PRODIS);
> +	else
> +		val &= ~(FEC_RACC_IPDIS | FEC_RACC_PRODIS);
> +	writel(val, fep->hwp + FEC_RACC);
> +
>  	/*
>  	 * The phy interface and speed need to get configured
>  	 * differently on enet-mac.
> @@ -818,6 +890,19 @@ fec_enet_rx(struct net_device *ndev, int budget)
>  				spin_unlock_irqrestore(&fep->tmreg_lock, flags);
>  			}
>  
> +			if (fep->bufdesc_ex &&
> +				(fep->csum_flags & FLAG_RX_CSUM_ENABLED)) {
> +				struct bufdesc_ex *ebdp =
> +					(struct bufdesc_ex *)bdp;
> +				if (!(ebdp->cbd_esc & FLAG_RX_CSUM_ENABLED)) {
> +					/* don't check it */
> +					skb->ip_summed = CHECKSUM_UNNECESSARY;

This looks very strange.  Presumably the RX_ICE and RX_PCR flags
indicate checksum errors, and therefore !(ebdp->cbd_esc &
FLAG_RX_CSUM_ENABLED) means the checksum(s) are good?  This would be
clearer if you defined FLAG_RX_CSUM_ERROR as well (with the same numeric
value).

> +				} else {
> +					ndev->stats.rx_errors++;

Layer 3 and 4 errors should not be counted in the net device stats.

> +					skb_checksum_none_assert(skb);
> +				}
> +			}
> +
>  			if (!skb_defer_rx_timestamp(skb))
>  				napi_gro_receive(&fep->napi, skb);
>  		}
> @@ -1439,6 +1524,9 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
>  		if (fep->bufdesc_ex) {
>  			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
>  			ebdp->cbd_esc = BD_ENET_TX_INT;
> +			if (ndev->features & NETIF_F_HW_CSUM)
> +				ebdp->cbd_esc |= BD_ENET_TX_PINS
> +						| BD_ENET_TX_IINS;
>  		}
>  
>  		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> @@ -1457,6 +1545,7 @@ fec_enet_open(struct net_device *ndev)
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	int ret;
>  
> +	ndev->features |= NETIF_F_GRO;

Definitely don't do this.  Let the networking core take care of feature
configuration.

>  	napi_enable(&fep->napi);
>  
>  	/* I should reset the ring buffers here, but I don't yet know
> @@ -1618,6 +1707,44 @@ static void fec_poll_controller(struct net_device *dev)
>  }
>  #endif
>  
> +static netdev_features_t fec_fix_features(struct net_device *netdev,
> +	netdev_features_t features)
> +{
> +	return features;
> +}

Why?

> +static int fec_set_features(struct net_device *netdev,
> +	netdev_features_t features)
> +{
> +	struct fec_enet_private *fep = netdev_priv(netdev);
> +	netdev_features_t changed = features ^ netdev->features;
> +	bool restart_required = false;
> +
> +	netdev->features = features;
> +
> +	/* Receive checksum has been changed */
> +	if (changed & NETIF_F_GRO) {
> +		restart_required = true;
> +		if (features & NETIF_F_GRO)
> +			fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
> +		else
> +			fep->csum_flags &= ~FLAG_RX_CSUM_ENABLED;
> +	}

RX checksum offload is independent of GRO.

> +	/* Restart the network interface */
> +	if (true == restart_required) {
> +		if (netif_running(netdev)) {
> +			fec_stop(netdev);
> +			fec_restart(netdev, fep->phy_dev->duplex);
> +			netif_wake_queue(netdev);
> +		} else {
> +			fec_restart(netdev, fep->phy_dev->duplex);
> +		}
> +	}
> +
> +	return 0;
> +}
> +
>  static const struct net_device_ops fec_netdev_ops = {
>  	.ndo_open		= fec_enet_open,
>  	.ndo_stop		= fec_enet_close,
> @@ -1631,6 +1758,8 @@ static const struct net_device_ops fec_netdev_ops = {
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	= fec_poll_controller,
>  #endif
> +	.ndo_fix_features	= fec_fix_features,
> +	.ndo_set_features	= fec_set_features,
>  };
>  
>   /*
> @@ -1672,6 +1801,11 @@ static int fec_enet_init(struct net_device *ndev)
>  	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
>  	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
>  
> +	/* enable hw accelerator */
> +	ndev->features |= (NETIF_F_HW_CSUM | NETIF_F_GRO);
> +	ndev->hw_features |= (NETIF_F_HW_CSUM | NETIF_F_GRO);

Now try passing IPv6 traffic.  You mean NETIF_F_IP_CSUM, not
NETIF_F_HW_CSUM.

Also you mean NETIF_F_RX_CSUM, not NETIF_F_GRO.

Ben.

> +	fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
> +
>  	fec_restart(ndev, 0);
>  
>  	return 0;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
