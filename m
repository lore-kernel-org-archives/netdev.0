From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [2/2] igb: Replace LRO with GRO
Date: Wed, 14 Jan 2009 03:49:35 -0800
Message-ID: <9929d2390901140349v4483bd23wac254673de591bec@mail.gmail.com>
References: <20090113092625.GA28015@gondor.apana.org.au>
	 <20090113092828.GA28052@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.188]:37136 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757664AbZANLth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 06:49:37 -0500
Received: by rn-out-0910.google.com with SMTP id k40so382754rnd.17
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 03:49:35 -0800 (PST)
In-Reply-To: <20090113092828.GA28052@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2009 at 1:28 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Hi:
>
> And here is the first real conversion.
>
> I can't test this one because I don't have the hardware.  However,
> GRO is a software feature and I have tested the various code paths
> using e1000e.
>
> igb: Replace LRO with GRO
>
> This patch makes igb invoke the GRO hooks instead of LRO.  As
> GRO has a compatible external interface to LRO this is a very
> straightforward replacement.
>
> Three things of note:
>
> 1) I've kept the LRO Kconfig option until we decide to enable
> GRO across the board at which point it can also be killed.
>
> 2) The poll_controller stuff is broken in igb as it tries to do
> the same work as the normal poll routine.  Since poll_controller
> can be called in the middle of a poll, this can't be good.
>
> I noticed this because poll_controller can invoke the GRO hooks
> without flushing held GRO packets.
>
> However, this should be harmless (assuming the poll_controller
> bug above doesn't kill you first :) since the next ->poll will
> clear the backlog.  The only time when we'll have a problem is
> if we're already executing the GRO code on the same ring, but
> that's no worse than what happens now.
>
> 3) I kept the ip_summed check before calling GRO so that we're
> on par with previous behaviour.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 65afda4..cf4fea0 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2022,7 +2022,6 @@ config IGB
>  config IGB_LRO
>        bool "Use software LRO"
>        depends on IGB && INET
> -       select INET_LRO
>        ---help---
>          Say Y here if you want to use large receive offload.
>
> diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
> index 5a27825..7d8c887 100644
> --- a/drivers/net/igb/igb.h
> +++ b/drivers/net/igb/igb.h
> @@ -36,12 +36,6 @@
>
>  struct igb_adapter;
>
> -#ifdef CONFIG_IGB_LRO
> -#include <linux/inet_lro.h>
> -#define MAX_LRO_AGGR                      32
> -#define MAX_LRO_DESCRIPTORS                8
> -#endif
> -
>  /* Interrupt defines */
>  #define IGB_MIN_DYN_ITR 3000
>  #define IGB_MAX_DYN_ITR 96000
> @@ -176,10 +170,6 @@ struct igb_ring {
>                        struct napi_struct napi;
>                        int set_itr;
>                        struct igb_ring *buddy;
> -#ifdef CONFIG_IGB_LRO
> -                       struct net_lro_mgr lro_mgr;
> -                       bool lro_used;
> -#endif
>                };
>        };
>
> @@ -288,12 +278,6 @@ struct igb_adapter {
>        int need_ioport;
>
>        struct igb_ring *multi_tx_table[IGB_MAX_TX_QUEUES];
> -#ifdef CONFIG_IGB_LRO
> -       unsigned int lro_max_aggr;
> -       unsigned int lro_aggregated;
> -       unsigned int lro_flushed;
> -       unsigned int lro_no_desc;
> -#endif
>        unsigned int tx_ring_count;
>        unsigned int rx_ring_count;
>  };
> diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
> index 3c831f1..4606e63 100644
> --- a/drivers/net/igb/igb_ethtool.c
> +++ b/drivers/net/igb/igb_ethtool.c
> @@ -93,11 +93,6 @@ static const struct igb_stats igb_gstrings_stats[] = {
>        { "tx_smbus", IGB_STAT(stats.mgptc) },
>        { "rx_smbus", IGB_STAT(stats.mgprc) },
>        { "dropped_smbus", IGB_STAT(stats.mgpdc) },
> -#ifdef CONFIG_IGB_LRO
> -       { "lro_aggregated", IGB_STAT(lro_aggregated) },
> -       { "lro_flushed", IGB_STAT(lro_flushed) },
> -       { "lro_no_desc", IGB_STAT(lro_no_desc) },
> -#endif
>  };
>
>  #define IGB_QUEUE_STATS_LEN \
> @@ -1921,18 +1916,6 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
>        int stat_count = sizeof(struct igb_queue_stats) / sizeof(u64);
>        int j;
>        int i;
> -#ifdef CONFIG_IGB_LRO
> -       int aggregated = 0, flushed = 0, no_desc = 0;
> -
> -       for (i = 0; i < adapter->num_rx_queues; i++) {
> -               aggregated += adapter->rx_ring[i].lro_mgr.stats.aggregated;
> -               flushed += adapter->rx_ring[i].lro_mgr.stats.flushed;
> -               no_desc += adapter->rx_ring[i].lro_mgr.stats.no_desc;
> -       }
> -       adapter->lro_aggregated = aggregated;
> -       adapter->lro_flushed = flushed;
> -       adapter->lro_no_desc = no_desc;
> -#endif
>
>        igb_update_stats(adapter);
>        for (i = 0; i < IGB_GLOBAL_STATS_LEN; i++) {
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index b82b0fb..ed3d881 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -115,9 +115,6 @@ static bool igb_clean_tx_irq(struct igb_ring *);
>  static int igb_poll(struct napi_struct *, int);
>  static bool igb_clean_rx_irq_adv(struct igb_ring *, int *, int);
>  static void igb_alloc_rx_buffers_adv(struct igb_ring *, int);
> -#ifdef CONFIG_IGB_LRO
> -static int igb_get_skb_hdr(struct sk_buff *skb, void **, void **, u64 *, void *);
> -#endif
>  static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
>  static void igb_tx_timeout(struct net_device *);
>  static void igb_reset_task(struct work_struct *);
> @@ -1189,7 +1186,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
>        netdev->features |= NETIF_F_TSO6;
>
>  #ifdef CONFIG_IGB_LRO
> -       netdev->features |= NETIF_F_LRO;
> +       netdev->features |= NETIF_F_GRO;
>  #endif
>
>        netdev->vlan_features |= NETIF_F_TSO;
> @@ -1739,14 +1736,6 @@ int igb_setup_rx_resources(struct igb_adapter *adapter,
>        struct pci_dev *pdev = adapter->pdev;
>        int size, desc_len;
>
> -#ifdef CONFIG_IGB_LRO
> -       size = sizeof(struct net_lro_desc) * MAX_LRO_DESCRIPTORS;
> -       rx_ring->lro_mgr.lro_arr = vmalloc(size);
> -       if (!rx_ring->lro_mgr.lro_arr)
> -               goto err;
> -       memset(rx_ring->lro_mgr.lro_arr, 0, size);
> -#endif
> -
>        size = sizeof(struct igb_buffer) * rx_ring->count;
>        rx_ring->buffer_info = vmalloc(size);
>        if (!rx_ring->buffer_info)
> @@ -1773,10 +1762,6 @@ int igb_setup_rx_resources(struct igb_adapter *adapter,
>        return 0;
>
>  err:
> -#ifdef CONFIG_IGB_LRO
> -       vfree(rx_ring->lro_mgr.lro_arr);
> -       rx_ring->lro_mgr.lro_arr = NULL;
> -#endif
>        vfree(rx_ring->buffer_info);
>        dev_err(&adapter->pdev->dev, "Unable to allocate memory for "
>                "the receive descriptor ring\n");
> @@ -1930,16 +1915,6 @@ static void igb_configure_rx(struct igb_adapter *adapter)
>                rxdctl |= IGB_RX_HTHRESH << 8;
>                rxdctl |= IGB_RX_WTHRESH << 16;
>                wr32(E1000_RXDCTL(j), rxdctl);
> -#ifdef CONFIG_IGB_LRO
> -               /* Intitial LRO Settings */
> -               ring->lro_mgr.max_aggr = MAX_LRO_AGGR;
> -               ring->lro_mgr.max_desc = MAX_LRO_DESCRIPTORS;
> -               ring->lro_mgr.get_skb_header = igb_get_skb_hdr;
> -               ring->lro_mgr.features = LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
> -               ring->lro_mgr.dev = adapter->netdev;
> -               ring->lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
> -               ring->lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
> -#endif
>        }
>
>        if (adapter->num_rx_queues > 1) {
> @@ -2128,11 +2103,6 @@ void igb_free_rx_resources(struct igb_ring *rx_ring)
>        vfree(rx_ring->buffer_info);
>        rx_ring->buffer_info = NULL;
>
> -#ifdef CONFIG_IGB_LRO
> -       vfree(rx_ring->lro_mgr.lro_arr);
> -       rx_ring->lro_mgr.lro_arr = NULL;
> -#endif
> -
>        pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
>
>        rx_ring->desc = NULL;
> @@ -3768,39 +3738,6 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
>        return (count < tx_ring->count);
>  }
>
> -#ifdef CONFIG_IGB_LRO
> - /**
> - * igb_get_skb_hdr - helper function for LRO header processing
> - * @skb: pointer to sk_buff to be added to LRO packet
> - * @iphdr: pointer to ip header structure
> - * @tcph: pointer to tcp header structure
> - * @hdr_flags: pointer to header flags
> - * @priv: pointer to the receive descriptor for the current sk_buff
> - **/
> -static int igb_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **tcph,
> -                           u64 *hdr_flags, void *priv)
> -{
> -       union e1000_adv_rx_desc *rx_desc = priv;
> -       u16 pkt_type = rx_desc->wb.lower.lo_dword.pkt_info &
> -                      (E1000_RXDADV_PKTTYPE_IPV4 | E1000_RXDADV_PKTTYPE_TCP);
> -
> -       /* Verify that this is a valid IPv4 TCP packet */
> -       if (pkt_type != (E1000_RXDADV_PKTTYPE_IPV4 |
> -                         E1000_RXDADV_PKTTYPE_TCP))
> -               return -1;
> -
> -       /* Set network headers */
> -       skb_reset_network_header(skb);
> -       skb_set_transport_header(skb, ip_hdrlen(skb));
> -       *iphdr = ip_hdr(skb);
> -       *tcph = tcp_hdr(skb);
> -       *hdr_flags = LRO_IPV4 | LRO_TCP;
> -
> -       return 0;
> -
> -}
> -#endif /* CONFIG_IGB_LRO */
> -
>  /**
>  * igb_receive_skb - helper function to handle rx indications
>  * @ring: pointer to receive ring receving this packet
> @@ -3815,28 +3752,20 @@ static void igb_receive_skb(struct igb_ring *ring, u8 status,
>        struct igb_adapter * adapter = ring->adapter;
>        bool vlan_extracted = (adapter->vlgrp && (status & E1000_RXD_STAT_VP));
>
> -#ifdef CONFIG_IGB_LRO
> -       if (adapter->netdev->features & NETIF_F_LRO &&
> -           skb->ip_summed == CHECKSUM_UNNECESSARY) {
> +       if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
>                if (vlan_extracted)
> -                       lro_vlan_hwaccel_receive_skb(&ring->lro_mgr, skb,
> -                                          adapter->vlgrp,
> -                                          le16_to_cpu(rx_desc->wb.upper.vlan),
> -                                          rx_desc);
> +                       vlan_gro_receive(&ring->napi, adapter->vlgrp,
> +                                        le16_to_cpu(rx_desc->wb.upper.vlan),
> +                                        skb);
>                else
> -                       lro_receive_skb(&ring->lro_mgr,skb, rx_desc);
> -               ring->lro_used = 1;
> +                       napi_gro_receive(&ring->napi, skb);
>        } else {
> -#endif
>                if (vlan_extracted)
>                        vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
>                                          le16_to_cpu(rx_desc->wb.upper.vlan));
>                else
> -
>                        netif_receive_skb(skb);
> -#ifdef CONFIG_IGB_LRO
>        }
> -#endif
>  }
>
>
> @@ -3991,13 +3920,6 @@ next_desc:
>        rx_ring->next_to_clean = i;
>        cleaned_count = IGB_DESC_UNUSED(rx_ring);
>
> -#ifdef CONFIG_IGB_LRO
> -       if (rx_ring->lro_used) {
> -               lro_flush_all(&rx_ring->lro_mgr);
> -               rx_ring->lro_used = 0;
> -       }
> -#endif
> -
>        if (cleaned_count)
>                igb_alloc_rx_buffers_adv(rx_ring, cleaned_count);
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

Ok, a couple of things...
First is that we should have the patch in testing (most likely today,
do not worry dave, it won't take a week)
Second is I am not sure you need to keep this code wraped in CONFIG_IGB_LRO...

  #ifdef CONFIG_IGB_LRO
 -       netdev->features |= NETIF_F_LRO;
 +       netdev->features |= NETIF_F_GRO;
  #endif

Also, you left part of the lro code in igb_receive_skb and then put in
the GRO code.  Our preference is that you mirrored what you did with
e1000e and just replaced the main vlan_hwacel and netif_receive_skb
calls.

-- 
Cheers,
Jeff
