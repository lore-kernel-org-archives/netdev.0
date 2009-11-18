From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH 3/3] TI Davinci EMAC : Abstract Buffer address translation
 logic.
Date: Wed, 18 Nov 2009 12:15:22 -0700
Message-ID: <4B0447CA.6040607@boundarydevices.com>
References: <1258537328-31527-1-git-send-email-srk@ti.com>	<1258537328-31527-2-git-send-email-srk@ti.com>	<1258537328-31527-3-git-send-email-srk@ti.com> <1258537328-31527-4-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: Sriramakrishnan <srk@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpauth03.csee.onr.siteprotect.com ([64.26.60.137]:52194 "EHLO
	smtpauth03.csee.onr.siteprotect.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932549AbZKRTPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 14:15:21 -0500
In-Reply-To: <1258537328-31527-4-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sriramakrishnan wrote:
> When programming the DMA engine, the next pointers must be
> programmed with physical address as seen from the DMA master
> address space. This address may be different from physical
> address of the buffer RAM area. This patch abstracts the
> buffer address translation logic.
> 
> Signed-off-by: Sriramakrishnan <srk@ti.com>
> Acked-by: Chaithrika U S <chaithrika@ti.com>
> ---
>  drivers/net/davinci_emac.c   |   41 ++++++++++++++++++++++++-----------------
>  include/linux/davinci_emac.h |    1 +
>  2 files changed, 25 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 81931f8..d4e173b 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -464,6 +464,7 @@ struct emac_priv {
>  	void __iomem *ctrl_base;
>  	void __iomem *emac_ctrl_ram;
>  	u32 ctrl_ram_size;
> +	u32 hw_ram_addr;
>  	struct emac_txch *txch[EMAC_DEF_MAX_TX_CH];
>  	struct emac_rxch *rxch[EMAC_DEF_MAX_RX_CH];
>  	u32 link; /* 1=link on, 0=link off */
> @@ -497,11 +498,9 @@ static struct clk *emac_clk;
>  static unsigned long emac_bus_frequency;
>  static unsigned long mdio_max_freq;
>  
> -/* EMAC internal utility function */
> -static inline u32 emac_virt_to_phys(void __iomem *addr)
> -{
> -	return (u32 __force) io_v2p(addr);
> -}
> +#define emac_virt_to_phys(addr, priv) \
> +	(((u32 __force)(addr) - (u32 __force)(priv->emac_ctrl_ram)) \
> +	+ priv->hw_ram_addr)


Maybe instead of hw_ram_addr, you could use virtual_to_phys_translation
where virtual_to_phys_translation = your hw_ram_addr - emac_ctrl_ram

I'm fine with your way too though.

>  
>  /* Cache macros - Packet buffers would be from skb pool which is cached */
>  #define EMAC_VIRT_NOCACHE(addr) (addr)
> @@ -1309,7 +1308,7 @@ static int emac_tx_bdproc(struct emac_priv *priv, u32 ch, u32 budget)
>  	curr_bd = txch->active_queue_head;
>  	if (NULL == curr_bd) {
>  		emac_write(EMAC_TXCP(ch),
> -			   emac_virt_to_phys(txch->last_hw_bdprocessed));
> +			   emac_virt_to_phys(txch->last_hw_bdprocessed, priv));
>  		txch->no_active_pkts++;
>  		spin_unlock_irqrestore(&priv->tx_lock, flags);
>  		return 0;
> @@ -1319,7 +1318,7 @@ static int emac_tx_bdproc(struct emac_priv *priv, u32 ch, u32 budget)
>  	while ((curr_bd) &&
>  	      ((frame_status & EMAC_CPPI_OWNERSHIP_BIT) == 0) &&
>  	      (pkts_processed < budget)) {
> -		emac_write(EMAC_TXCP(ch), emac_virt_to_phys(curr_bd));
> +		emac_write(EMAC_TXCP(ch), emac_virt_to_phys(curr_bd, priv));
>  		txch->active_queue_head = curr_bd->next;
>  		if (frame_status & EMAC_CPPI_EOQ_BIT) {
>  			if (curr_bd->next) {	/* misqueued packet */
> @@ -1406,7 +1405,7 @@ static int emac_send(struct emac_priv *priv, struct emac_netpktobj *pkt, u32 ch)
>  		txch->active_queue_tail = curr_bd;
>  		if (1 != txch->queue_active) {
>  			emac_write(EMAC_TXHDP(ch),
> -					emac_virt_to_phys(curr_bd));
> +					emac_virt_to_phys(curr_bd, priv));
>  			txch->queue_active = 1;
>  		}
>  		++txch->queue_reinit;
> @@ -1418,10 +1417,11 @@ static int emac_send(struct emac_priv *priv, struct emac_netpktobj *pkt, u32 ch)
>  		tail_bd->next = curr_bd;
>  		txch->active_queue_tail = curr_bd;
>  		tail_bd = EMAC_VIRT_NOCACHE(tail_bd);
> -		tail_bd->h_next = (int)emac_virt_to_phys(curr_bd);
> +		tail_bd->h_next = (int)emac_virt_to_phys(curr_bd, priv);
>  		frame_status = tail_bd->mode;
>  		if (frame_status & EMAC_CPPI_EOQ_BIT) {
> -			emac_write(EMAC_TXHDP(ch), emac_virt_to_phys(curr_bd));
> +			emac_write(EMAC_TXHDP(ch),
> +				emac_virt_to_phys(curr_bd, priv));
>  			frame_status &= ~(EMAC_CPPI_EOQ_BIT);
>  			tail_bd->mode = frame_status;
>  			++txch->end_of_queue_add;
> @@ -1611,7 +1611,8 @@ static int emac_init_rxch(struct emac_priv *priv, u32 ch, char *param)
>  		}
>  
>  		/* populate the hardware descriptor */
> -		curr_bd->h_next = emac_virt_to_phys(rxch->active_queue_head);
> +		curr_bd->h_next = emac_virt_to_phys(rxch->active_queue_head,
> +				priv);
>  		/* FIXME buff_ptr = dma_map_single(... data_ptr ...) */
>  		curr_bd->buff_ptr = virt_to_phys(curr_bd->data_ptr);
>  		curr_bd->off_b_len = rxch->buf_size;
> @@ -1886,7 +1887,7 @@ static void emac_addbd_to_rx_queue(struct emac_priv *priv, u32 ch,
>  		rxch->active_queue_tail = curr_bd;
>  		if (0 != rxch->queue_active) {
>  			emac_write(EMAC_RXHDP(ch),
> -				   emac_virt_to_phys(rxch->active_queue_head));
> +			   emac_virt_to_phys(rxch->active_queue_head, priv));
>  			rxch->queue_active = 1;
>  		}
>  	} else {
> @@ -1897,11 +1898,11 @@ static void emac_addbd_to_rx_queue(struct emac_priv *priv, u32 ch,
>  		rxch->active_queue_tail = curr_bd;
>  		tail_bd->next = curr_bd;
>  		tail_bd = EMAC_VIRT_NOCACHE(tail_bd);
> -		tail_bd->h_next = emac_virt_to_phys(curr_bd);
> +		tail_bd->h_next = emac_virt_to_phys(curr_bd, priv);
>  		frame_status = tail_bd->mode;
>  		if (frame_status & EMAC_CPPI_EOQ_BIT) {
>  			emac_write(EMAC_RXHDP(ch),
> -					emac_virt_to_phys(curr_bd));
> +					emac_virt_to_phys(curr_bd, priv));
>  			frame_status &= ~(EMAC_CPPI_EOQ_BIT);
>  			tail_bd->mode = frame_status;
>  			++rxch->end_of_queue_add;
> @@ -1994,7 +1995,7 @@ static int emac_rx_bdproc(struct emac_priv *priv, u32 ch, u32 budget)
>  		curr_pkt->num_bufs = 1;
>  		curr_pkt->pkt_length =
>  			(frame_status & EMAC_RX_BD_PKT_LENGTH_MASK);
> -		emac_write(EMAC_RXCP(ch), emac_virt_to_phys(curr_bd));
> +		emac_write(EMAC_RXCP(ch), emac_virt_to_phys(curr_bd, priv));
>  		++rxch->processed_bd;
>  		last_bd = curr_bd;
>  		curr_bd = last_bd->next;
> @@ -2005,7 +2006,7 @@ static int emac_rx_bdproc(struct emac_priv *priv, u32 ch, u32 budget)
>  			if (curr_bd) {
>  				++rxch->mis_queued_packets;
>  				emac_write(EMAC_RXHDP(ch),
> -					   emac_virt_to_phys(curr_bd));
> +					   emac_virt_to_phys(curr_bd, priv));
>  			} else {
>  				++rxch->end_of_queue;
>  				rxch->queue_active = 0;
> @@ -2106,7 +2107,7 @@ static int emac_hw_enable(struct emac_priv *priv)
>  		emac_write(EMAC_RXINTMASKSET, BIT(ch));
>  		rxch->queue_active = 1;
>  		emac_write(EMAC_RXHDP(ch),
> -			   emac_virt_to_phys(rxch->active_queue_head));
> +			   emac_virt_to_phys(rxch->active_queue_head, priv));
>  	}
>  
>  	/* Enable MII */
> @@ -2705,6 +2706,12 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
>  	priv->ctrl_ram_size = pdata->ctrl_ram_size;
>  	priv->emac_ctrl_ram = priv->remap_addr + pdata->ctrl_ram_offset;
>  
> +	if (pdata->hw_ram_addr)
> +		priv->hw_ram_addr = pdata->hw_ram_addr;
> +	else
> +		priv->hw_ram_addr = (u32 __force)res->start +
> +					pdata->ctrl_ram_offset;
> +
>  	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
>  	if (!res) {
>  		dev_err(emac_dev, "DaVinci EMAC: Error getting irq res\n");
> diff --git a/include/linux/davinci_emac.h b/include/linux/davinci_emac.h
> index eb24dc0..b318dfd 100644
> --- a/include/linux/davinci_emac.h
> +++ b/include/linux/davinci_emac.h
> @@ -19,6 +19,7 @@ struct emac_platform_data {
>  	u32 ctrl_reg_offset;
>  	u32 ctrl_mod_reg_offset;
>  	u32 ctrl_ram_offset;
> +	u32 hw_ram_addr;
>  	u32 mdio_reg_offset;
>  	u32 ctrl_ram_size;
>  	u32 phy_mask;

