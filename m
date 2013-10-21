From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH RFC 5/5] net:stmmac: asynchronous tx_clean
Date: Mon, 21 Oct 2013 15:52:12 +0200
Message-ID: <5265318C.5050307@st.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com> <1381937052-8999-6-git-send-email-jimmy.perchet@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jimmy Perchet <jimmy.perchet@parrot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog121.obsmtp.com ([207.126.144.151]:41547 "EHLO
	eu1sys200aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753084Ab3JUNwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 09:52:17 -0400
In-Reply-To: <1381937052-8999-6-git-send-email-jimmy.perchet@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jimmy

On 10/16/2013 5:24 PM, Jimmy Perchet wrote:
> Tx descriptor's cleanup and preparation are serialized, which is not necessary
> and decrease performance.
> In addition TX descriptor's cleanup is performed on NET_RX softirq, this is
> confusing.

hmm, here you are changing the logic behind the tx/rx processes.

As done in many drivers, the stmmac cleans the tx resources in
NAPI context and this is not a confuse approach ;-).

It gave me some performance improvements especially on TCP benchmarks.

> This patch unserialize tx descriptor's cleanup and preparation
> and defer cleanup in workqueue.

So you decide to use workqueue and I kindly ask you to give me more
details about the performance improvements (UDP/TCP) and cpu usage.

I can try to do some tests on my side too. This could take a while
unfortunately.

peppe

>
> Signed-off-by: Jimmy Perchet <jimmy.perchet@parrot.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |  6 +--
>   drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  6 ++-
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 52 +++++++++++++----------
>   3 files changed, 37 insertions(+), 27 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> index d6ed0ce..8ab83cb 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> @@ -120,7 +120,7 @@ static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
>   		 * to keep explicit chaining in the descriptor.
>   		 */
>   		p->des3 = (unsigned int)(priv->dma_rx_phy +
> -					 (((priv->dirty_rx) + 1) %
> +					 ((priv->dirty_rx + 1) %
>   					  priv->dma_rx_size) *
>   					 sizeof(struct dma_desc));
>   }
> @@ -135,9 +135,9 @@ static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
>   		 * to keep explicit chaining in the descriptor.
>   		 */
>   		p->des3 = (unsigned int)(priv->dma_tx_phy +
> -					 (((priv->dirty_tx + 1) %
> +					 ((atomic_read(&priv->dirty_tx) + 1) %
>   					   priv->dma_tx_size) *
> -					  sizeof(struct dma_desc)));
> +					  sizeof(struct dma_desc));
>   }
>
>   const struct stmmac_chain_mode_ops chain_mode_ops = {
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index f16a9bd..d5b8906 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -38,8 +38,8 @@ struct stmmac_priv {
>   	struct dma_extended_desc *dma_etx ____cacheline_aligned_in_smp;
>   	struct dma_desc *dma_tx;
>   	struct sk_buff **tx_skbuff;
> -	unsigned int cur_tx;
> -	unsigned int dirty_tx;
> +	atomic_t cur_tx;
> +	atomic_t dirty_tx;
>   	unsigned int dma_tx_size;
>   	u32 tx_count_frames;
>   	u32 tx_coal_frames;
> @@ -106,6 +106,8 @@ struct stmmac_priv {
>   	u32 adv_ts;
>   	int use_riwt;
>   	spinlock_t ptp_lock;
> +	struct work_struct txclean_work;
> +	struct workqueue_struct *wq;
>   };
>
>   extern int phyaddr;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 5873246..de614ad 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -48,6 +48,7 @@
>   #include <linux/seq_file.h>
>   #endif /* CONFIG_STMMAC_DEBUG_FS */
>   #include <linux/net_tstamp.h>
> +#include <linux/workqueue.h>
>   #include "stmmac_ptp.h"
>   #include "stmmac.h"
>
> @@ -205,7 +206,8 @@ static void print_pkt(unsigned char *buf, int len)
>
>   static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
>   {
> -	return priv->dirty_tx + priv->dma_tx_size - priv->cur_tx - 1;
> +	return atomic_read(&priv->dirty_tx) + priv->dma_tx_size
> +					 - atomic_read(&priv->cur_tx) - 1;
>   }
>
>   /**
> @@ -230,7 +232,7 @@ static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
>   static void stmmac_enable_eee_mode(struct stmmac_priv *priv)
>   {
>   	/* Check and enter in LPI mode */
> -	if ((priv->dirty_tx == priv->cur_tx) &&
> +	if ((atomic_read(&priv->dirty_tx) == atomic_read(&priv->cur_tx)) &&
>   	    (priv->tx_path_in_lpi_mode == false))
>   		priv->hw->mac->set_eee_mode(priv->ioaddr);
>   }
> @@ -1118,8 +1120,8 @@ static int init_dma_desc_rings(struct net_device *dev)
>   		priv->tx_skbuff[i] = NULL;
>   	}
>
> -	priv->dirty_tx = 0;
> -	priv->cur_tx = 0;
> +	atomic_set(&priv->dirty_tx, 0);
> +	atomic_set(&priv->cur_tx, 0);
>
>   	stmmac_clear_descriptors(priv);
>
> @@ -1264,17 +1266,17 @@ static void stmmac_dma_operation_mode(int mtu, struct stmmac_priv *priv)
>    * @priv: driver private structure
>    * Description: it reclaims resources after transmission completes.
>    */
> -static void stmmac_tx_clean(struct stmmac_priv *priv)
> +static void stmmac_tx_clean(struct work_struct *work)
>   {
> +	struct stmmac_priv *priv =
> +			container_of(work, struct stmmac_priv, txclean_work);
>   	unsigned int txsize = priv->dma_tx_size;
>
> -	spin_lock(&priv->tx_lock);
> -
>   	priv->xstats.tx_clean++;
>
> -	while (priv->dirty_tx != priv->cur_tx) {
> +	while (atomic_read(&priv->dirty_tx) != atomic_read(&priv->cur_tx)) {
>   		int last;
> -		unsigned int entry = priv->dirty_tx % txsize;
> +		unsigned int entry = atomic_read(&priv->dirty_tx) % txsize;
>   		struct sk_buff *skb = priv->tx_skbuff[entry];
>   		struct dma_desc *p;
>
> @@ -1308,7 +1310,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>   		}
>   		if (netif_msg_tx_done(priv))
>   			pr_debug("%s: curr %d, dirty %d\n", __func__,
> -				 priv->cur_tx, priv->dirty_tx);
> +				 atomic_read(&priv->cur_tx),
> +				 atomic_read(&priv->dirty_tx));
>
>   		if (likely(priv->tx_skbuff_dma[entry])) {
>   			dma_unmap_single(priv->device,
> @@ -1326,7 +1329,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>
>   		priv->hw->desc->release_tx_desc(p, priv->mode);
>
> -		priv->dirty_tx++;
> +		wmb();
> +		atomic_inc(&priv->dirty_tx);
>   	}
>   	if (unlikely(netif_queue_stopped(priv->dev) &&
>   		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv))) {
> @@ -1344,7 +1348,6 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>   		stmmac_enable_eee_mode(priv);
>   		mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_T(eee_timer));
>   	}
> -	spin_unlock(&priv->tx_lock);
>   }
>
>   static inline void stmmac_enable_dma_irq(struct stmmac_priv *priv)
> @@ -1380,8 +1383,8 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
>   			priv->hw->desc->init_tx_desc(&priv->dma_tx[i],
>   						     priv->mode,
>   						     (i == txsize - 1));
> -	priv->dirty_tx = 0;
> -	priv->cur_tx = 0;
> +	atomic_set(&priv->dirty_tx, 0);
> +	atomic_set(&priv->cur_tx, 0);
>   	priv->hw->dma->start_tx(priv->ioaddr);
>
>   	priv->dev->stats.tx_errors++;
> @@ -1401,12 +1404,16 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
>   	int status;
>
>   	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
> -	if (likely((status & handle_rx)) || (status & handle_tx)) {
> +	if (likely(status & handle_rx)) {
>   		if (likely(napi_schedule_prep(&priv->napi))) {
>   			stmmac_disable_dma_irq(priv);
>   			__napi_schedule(&priv->napi);
>   		}
>   	}
> +	if (likely(status & handle_tx))
> +		queue_work(priv->wq, &priv->txclean_work);
> +
> +
>   	if (unlikely(status & tx_hard_error_bump_tc)) {
>   		/* Try to bump up the dma threshold on this failure */
>   		if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
> @@ -1596,8 +1603,7 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>   static void stmmac_tx_timer(unsigned long data)
>   {
>   	struct stmmac_priv *priv = (struct stmmac_priv *)data;
> -
> -	stmmac_tx_clean(priv);
> +	queue_work(priv->wq, &priv->txclean_work);
>   }
>
>   /**
> @@ -1876,7 +1882,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>   	if (priv->tx_path_in_lpi_mode)
>   		stmmac_disable_eee_mode(priv);
>
> -	first_entry = entry = priv->cur_tx % txsize;
> +	first_entry = entry = atomic_read(&priv->cur_tx) % txsize;
>
>   	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
>   	/* To program the descriptors according to the size of the frame */
> @@ -1944,12 +1950,13 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>   	priv->hw->desc->set_tx_owner(first);
>   	wmb();
>
> -	priv->cur_tx += nb_desc;
> +	atomic_add(nb_desc, &priv->cur_tx);
>
>   	if (netif_msg_pktdata(priv)) {
>   		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
> -			__func__, (priv->cur_tx % txsize),
> -			(priv->dirty_tx % txsize), entry, first, nfrags);
> +			__func__, (atomic_read(&priv->cur_tx) % txsize),
> +			(atomic_read(&priv->dirty_tx) % txsize), entry,
> +			first, nfrags);
>
>   		if (priv->extend_desc)
>   			stmmac_display_ring((void *)priv->dma_etx, txsize, 1);
> @@ -2171,7 +2178,6 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>   	int work_done = 0;
>
>   	priv->xstats.napi_poll++;
> -	stmmac_tx_clean(priv);
>
>   	work_done = stmmac_rx(priv, budget);
>   	if (work_done < budget) {
> @@ -2747,6 +2753,8 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>
>   	spin_lock_init(&priv->lock);
>   	spin_lock_init(&priv->tx_lock);
> +	priv->wq = create_singlethread_workqueue("stmmac_wq");
> +	INIT_WORK(&priv->txclean_work, stmmac_tx_clean);
>
>   	ret = register_netdev(ndev);
>   	if (ret) {
>
