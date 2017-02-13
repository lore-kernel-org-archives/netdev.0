From: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: Use net_device_stats from struct net_device
Date: Mon, 13 Feb 2017 11:17:18 +0100
Message-ID: <c21b6055-2f98-45e4-7414-bf66f4bff4d8@broadcom.com>
References: <20170213101409.8205-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>, franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170213101409.8205-1-tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 13-2-2017 11:14, Tobias Klauser wrote:
> Instead of using a private copy of struct net_device_stats in struct
> brcm_if, use stats from struct net_device.  Also remove the now
> unnecessary .ndo_get_stats function.

Acked-by: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
> ---
>  .../wireless/broadcom/brcm80211/brcmfmac/core.c    | 26 +++++++---------------
>  .../wireless/broadcom/brcm80211/brcmfmac/core.h    |  2 --
>  2 files changed, 8 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> index b73a55b00fa7..60da86a8d95b 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> @@ -249,10 +249,10 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
>  
>  done:
>  	if (ret) {
> -		ifp->stats.tx_dropped++;
> +		ndev->stats.tx_dropped++;
>  	} else {
> -		ifp->stats.tx_packets++;
> -		ifp->stats.tx_bytes += skb->len;
> +		ndev->stats.tx_packets++;
> +		ndev->stats.tx_bytes += skb->len;
>  	}
>  
>  	/* Return ok: we always eat the packet */
> @@ -296,15 +296,15 @@ void brcmf_txflowblock(struct device *dev, bool state)
>  void brcmf_netif_rx(struct brcmf_if *ifp, struct sk_buff *skb)
>  {
>  	if (skb->pkt_type == PACKET_MULTICAST)
> -		ifp->stats.multicast++;
> +		ifp->ndev->stats.multicast++;
>  
>  	if (!(ifp->ndev->flags & IFF_UP)) {
>  		brcmu_pkt_buf_free_skb(skb);
>  		return;
>  	}
>  
> -	ifp->stats.rx_bytes += skb->len;
> -	ifp->stats.rx_packets++;
> +	ifp->ndev->stats.rx_bytes += skb->len;
> +	ifp->ndev->stats.rx_packets++;
>  
>  	brcmf_dbg(DATA, "rx proto=0x%X\n", ntohs(skb->protocol));
>  	if (in_interrupt())
> @@ -327,7 +327,7 @@ static int brcmf_rx_hdrpull(struct brcmf_pub *drvr, struct sk_buff *skb,
>  
>  	if (ret || !(*ifp) || !(*ifp)->ndev) {
>  		if (ret != -ENODATA && *ifp)
> -			(*ifp)->stats.rx_errors++;
> +			(*ifp)->ndev->stats.rx_errors++;
>  		brcmu_pkt_buf_free_skb(skb);
>  		return -ENODATA;
>  	}
> @@ -388,7 +388,7 @@ void brcmf_txfinalize(struct brcmf_if *ifp, struct sk_buff *txp, bool success)
>  	}
>  
>  	if (!success)
> -		ifp->stats.tx_errors++;
> +		ifp->ndev->stats.tx_errors++;
>  
>  	brcmu_pkt_buf_free_skb(txp);
>  }
> @@ -411,15 +411,6 @@ void brcmf_txcomplete(struct device *dev, struct sk_buff *txp, bool success)
>  	}
>  }
>  
> -static struct net_device_stats *brcmf_netdev_get_stats(struct net_device *ndev)
> -{
> -	struct brcmf_if *ifp = netdev_priv(ndev);
> -
> -	brcmf_dbg(TRACE, "Enter, bsscfgidx=%d\n", ifp->bsscfgidx);
> -
> -	return &ifp->stats;
> -}
> -
>  static void brcmf_ethtool_get_drvinfo(struct net_device *ndev,
>  				    struct ethtool_drvinfo *info)
>  {
> @@ -492,7 +483,6 @@ static int brcmf_netdev_open(struct net_device *ndev)
>  static const struct net_device_ops brcmf_netdev_ops_pri = {
>  	.ndo_open = brcmf_netdev_open,
>  	.ndo_stop = brcmf_netdev_stop,
> -	.ndo_get_stats = brcmf_netdev_get_stats,
>  	.ndo_start_xmit = brcmf_netdev_start_xmit,
>  	.ndo_set_mac_address = brcmf_netdev_set_mac_address,
>  	.ndo_set_rx_mode = brcmf_netdev_set_multicast_list
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
> index de3197be5491..6aecd8dfd824 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
> @@ -171,7 +171,6 @@ enum brcmf_netif_stop_reason {
>   * @drvr: points to device related information.
>   * @vif: points to cfg80211 specific interface information.
>   * @ndev: associated network device.
> - * @stats: interface specific network statistics.
>   * @multicast_work: worker object for multicast provisioning.
>   * @ndoffload_work: worker object for neighbor discovery offload configuration.
>   * @fws_desc: interface specific firmware-signalling descriptor.
> @@ -187,7 +186,6 @@ struct brcmf_if {
>  	struct brcmf_pub *drvr;
>  	struct brcmf_cfg80211_vif *vif;
>  	struct net_device *ndev;
> -	struct net_device_stats stats;
>  	struct work_struct multicast_work;
>  	struct work_struct ndoffload_work;
>  	struct brcmf_fws_mac_descriptor *fws_desc;
> 
