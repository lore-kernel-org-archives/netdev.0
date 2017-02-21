From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH RFC v3 3/8] nfp: Changes to use generic XDP
 infrastructure
Date: Tue, 21 Feb 2017 15:10:07 -0800
Message-ID: <20170221151007.4461e516@cakuba.netronome.com>
References: <20170221193417.3641224-1-tom@herbertland.com>
        <20170221193417.3641224-4-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:17795 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752819AbdBUXKb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 18:10:31 -0500
In-Reply-To: <20170221193417.3641224-4-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Feb 2017 11:34:12 -0800, Tom Herbert wrote:
> Change XDP program management functional interface to correspond to new
> XDP API.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  drivers/net/ethernet/netronome/nfp/nfp_net.h       |   5 +-
>  .../net/ethernet/netronome/nfp/nfp_net_common.c    | 172 ++++++++++-----------
>  .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  12 +-
>  3 files changed, 87 insertions(+), 102 deletions(-)
> 
> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
> index e614a37..732e40b 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
> @@ -503,14 +503,13 @@ struct nfp_net {
>  	unsigned is_vf:1;
>  	unsigned bpf_offload_skip_sw:1;
>  	unsigned bpf_offload_xdp:1;
> +	unsigned xdp_enabled:1;
>  
>  	u32 ctrl;
>  	u32 fl_bufsz;
>  
>  	u32 rx_offset;
>  
> -	struct bpf_prog *xdp_prog;
> -
>  	struct nfp_net_tx_ring *tx_rings;
>  	struct nfp_net_rx_ring *rx_rings;
>  
> @@ -788,7 +787,7 @@ void
>  nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
>  		    unsigned int n);
>  int
> -nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
> +nfp_net_ring_reconfig(struct nfp_net *nn,
>  		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx);
>  
>  #ifdef CONFIG_NFP_DEBUG
> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> index 074259c..6200035 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> @@ -65,6 +65,7 @@
>  
>  #include <net/pkt_cls.h>
>  #include <net/vxlan.h>
> +#include <net/xdp.h>
>  
>  #include "nfp_net_ctrl.h"
>  #include "nfp_net.h"
> @@ -1169,10 +1170,10 @@ nfp_net_napi_alloc_one(struct nfp_net *nn, int direction, dma_addr_t *dma_addr)
>  {
>  	void *frag;
>  
> -	if (!nn->xdp_prog)
> -		frag = napi_alloc_frag(nn->fl_bufsz);
> -	else
> +	if (nn->xdp_enabled)
>  		frag = page_address(alloc_page(GFP_ATOMIC | __GFP_COLD));
> +	else
> +		frag = napi_alloc_frag(nn->fl_bufsz);
>  	if (!frag) {
>  		nn_warn_ratelimit(nn, "Failed to alloc receive page frag\n");
>  		return NULL;
> @@ -1180,7 +1181,7 @@ nfp_net_napi_alloc_one(struct nfp_net *nn, int direction, dma_addr_t *dma_addr)
>  
>  	*dma_addr = nfp_net_dma_map_rx(nn, frag, nn->fl_bufsz, direction);
>  	if (dma_mapping_error(&nn->pdev->dev, *dma_addr)) {
> -		nfp_net_free_frag(frag, nn->xdp_prog);
> +		nfp_net_free_frag(frag, nn->xdp_enabled);
>  		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
>  		return NULL;
>  	}
> @@ -1251,17 +1252,15 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
>   * nfp_net_rx_ring_bufs_free() - Free any buffers currently on the RX ring
>   * @nn:		NFP Net device
>   * @rx_ring:	RX ring to remove buffers from
> - * @xdp:	Whether XDP is enabled
>   *
>   * Assumes that the device is stopped and buffers are in [0, ring->cnt - 1)
>   * entries.  After device is disabled nfp_net_rx_ring_reset() must be called
>   * to restore required ring geometry.
>   */
>  static void
> -nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
> -			  bool xdp)
> +nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)

You can't do that.  NFP has runtime reconfiguration mechanism which
allocates new rings before it stops the device.  All those methods need
to take XDP program or xdp bool as parameter.
