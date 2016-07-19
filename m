From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH 2/4] net: ethernet: ti: cpsw: add multi queue support
Date: Tue, 19 Jul 2016 16:24:41 +0300
Message-ID: <578E2A19.1000508@linaro.org>
References: <1467313478-22919-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1467313478-22919-3-git-send-email-ivan.khoronzhuk@linaro.org>
 <577FA6CA.508@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	nsekhar@ti.com
To: Grygorii Strashko <grygorii.strashko@ti.com>, davem@davemloft.net,
	netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33849 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271AbcGSNYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 09:24:44 -0400
Received: by mail-lf0-f47.google.com with SMTP id l69so14219602lfg.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 06:24:43 -0700 (PDT)
In-Reply-To: <577FA6CA.508@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08.07.16 16:12, Grygorii Strashko wrote:
> On 06/30/2016 10:04 PM, Ivan Khoronzhuk wrote:
>> The cpsw h/w supports up to 8 tx and 8 rx channels.This patch adds
>> multi-queue support to the driver. An ability to configure h/w
>> shaper will be added with separate patch. Default shaper mode, as
>> before, priority mode.
>>
>> The poll function handles all unprocessed channels, till all of
>> them are free, beginning from hi priority channel.
>>
>> The statistic for every channel can be read with:
>> ethtool -S ethX
>>
>> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>> ---
>>    drivers/net/ethernet/ti/cpsw.c          | 334 +++++++++++++++++++++-----------
>>    drivers/net/ethernet/ti/davinci_cpdma.c |  12 ++
>>    drivers/net/ethernet/ti/davinci_cpdma.h |   2 +
>>    3 files changed, 237 insertions(+), 111 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index a713336..14d53eb 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -140,6 +140,8 @@ do {								\
>>    #define CPSW_CMINTMAX_INTVL	(1000 / CPSW_CMINTMIN_CNT)
>>    #define CPSW_CMINTMIN_INTVL	((1000 / CPSW_CMINTMAX_CNT) + 1)
>>
>> +#define CPSW_MAX_QUEUES		8
>> +
>>    #define cpsw_slave_index(priv)				\
>>    		((priv->data.dual_emac) ? priv->emac_port :	\
>>    		priv->data.active_slave)
>> @@ -383,7 +385,8 @@ struct cpsw_priv {
>>    	u8				mac_addr[ETH_ALEN];
>>    	struct cpsw_slave		*slaves;
>>    	struct cpdma_ctlr		*dma;
>> -	struct cpdma_chan		*txch, *rxch;
>> +	struct cpdma_chan		*txch[CPSW_MAX_QUEUES];
>> +	struct cpdma_chan		*rxch[CPSW_MAX_QUEUES];
>>    	struct cpsw_ale			*ale;
>>    	bool				rx_pause;
>>    	bool				tx_pause;
>> @@ -395,6 +398,7 @@ struct cpsw_priv {
>>    	u32 num_irqs;
>>    	struct cpts *cpts;
>>    	u32 emac_port;
>> +	int rx_ch_num, tx_ch_num;
>>    };
>>
>
> [...]
>
>>
>> @@ -989,26 +1024,50 @@ update_return:
>>
>>    static int cpsw_get_sset_count(struct net_device *ndev, int sset)
>>    {
>> +	struct cpsw_priv *priv = netdev_priv(ndev);
>> +
>>    	switch (sset) {
>>    	case ETH_SS_STATS:
>> -		return CPSW_STATS_LEN;
>> +		return (CPSW_STATS_COMMON_LEN +
>> +		       (priv->rx_ch_num + priv->tx_ch_num) *
>> +		       CPSW_STATS_CH_LEN);
>>    	default:
>>    		return -EOPNOTSUPP;
>>    	}
>>    }
>>
>> +static void cpsw_add_ch_strings(u8 **p, int ch_num, int rx_dir)
>> +{
>> +	int ch_stats_len;
>> +	int line;
>> +	int i;
>> +
>> +	ch_stats_len = CPSW_STATS_CH_LEN * ch_num;
>> +	for (i = 0; i < ch_stats_len; i++) {
>> +		line = i % CPSW_STATS_CH_LEN;
>> +		sprintf(*p, "%s DMA chan %d: %s", rx_dir ? "Rx" : "Tx",
>> +			i / CPSW_STATS_CH_LEN,
>
> snprintf(,ETH_GSTRING_LEN,) ?
It's number of channel.

>
>> +			cpsw_gstrings_ch_stats[line].stat_string);
>> +		*p += ETH_GSTRING_LEN;
>> +	}
>> +}
>> +
>>    static void cpsw_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
>>    {
>> +	struct cpsw_priv *priv = netdev_priv(ndev);
>>    	u8 *p = data;
>>    	int i;
>>
>>    	switch (stringset) {
>>    	case ETH_SS_STATS:
>> -		for (i = 0; i < CPSW_STATS_LEN; i++) {
>> +		for (i = 0; i < CPSW_STATS_COMMON_LEN; i++) {
>>    			memcpy(p, cpsw_gstrings_stats[i].stat_string,
>>    			       ETH_GSTRING_LEN);
>>    			p += ETH_GSTRING_LEN;
>>    		}
>> +
>> +		cpsw_add_ch_strings(&p, priv->rx_ch_num, 1);
>> +		cpsw_add_ch_strings(&p, priv->tx_ch_num, 0);
>>    		break;
>>    	}
>>    }
>> @@ -1017,35 +1076,38 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
>>    				    struct ethtool_stats *stats, u64 *data)
>>    {
>>    	struct cpsw_priv *priv = netdev_priv(ndev);
>> -	struct cpdma_chan_stats rx_stats;
>> -	struct cpdma_chan_stats tx_stats;
>> -	u32 val;
>> +	struct cpdma_chan_stats ch_stats;
>> +	int i, l, ch, ret;
>>    	u8 *p;
>> -	int i;
>> +
>> +	ret = pm_runtime_get_sync(&priv->pdev->dev);
>> +	if (ret < 0) {
>> +		pm_runtime_put_noidle(&priv->pdev->dev);
>> +		return;
>> +	}
>
> You probably need to base you work on top of net-next.git
Yep. Will correct.

>
>>
>>    	/* Collect Davinci CPDMA stats for Rx and Tx Channel */
>> -	cpdma_chan_get_stats(priv->rxch, &rx_stats);
>> -	cpdma_chan_get_stats(priv->txch, &tx_stats);
>> -
>> -	for (i = 0; i < CPSW_STATS_LEN; i++) {
>> -		switch (cpsw_gstrings_stats[i].type) {
>> -		case CPSW_STATS:
>> -			val = readl(priv->hw_stats +
>> -				    cpsw_gstrings_stats[i].stat_offset);
>> -			data[i] = val;
>> -			break;
>> +	for (l = 0; l < CPSW_STATS_COMMON_LEN; l++)
>> +		data[l] = readl(priv->hw_stats +
>> +				cpsw_gstrings_stats[l].stat_offset);
>>
>> -		case CPDMA_RX_STATS:
>> -			p = (u8 *)&rx_stats +
>> -				cpsw_gstrings_stats[i].stat_offset;
>> -			data[i] = *(u32 *)p;
>> -			break;
>> +	pm_runtime_put(&priv->pdev->dev);
>>
>> -		case CPDMA_TX_STATS:
>> -			p = (u8 *)&tx_stats +
>> -				cpsw_gstrings_stats[i].stat_offset;
>> -			data[i] = *(u32 *)p;
>> -			break;
>> +	for (ch = 0; ch < priv->rx_ch_num; ch++) {
>> +		cpdma_chan_get_stats(priv->rxch[ch], &ch_stats);
>> +		for (i = 0; i < CPSW_STATS_CH_LEN; i++, l++) {
>> +			p = (u8 *)&ch_stats +
>> +				cpsw_gstrings_ch_stats[i].stat_offset;
>> +			data[l] = *(u32 *)p;
>> +		}
>> +	}
>> +
>> +	for (ch = 0; ch < priv->tx_ch_num; ch++) {
>> +		cpdma_chan_get_stats(priv->txch[ch], &ch_stats);
>> +		for (i = 0; i < CPSW_STATS_CH_LEN; i++, l++) {
>> +			p = (u8 *)&ch_stats +
>> +				cpsw_gstrings_ch_stats[i].stat_offset;
>> +			data[l] = *(u32 *)p;
>>    		}
>>    	}
>
> I think, it's better to do pm_runtime_put() here even if now cpdma does'n access
> HW from cpdma_chan_get_stats it may change in fufture.
> And it's not critical from PM point of view
This part is not going to access h/w.
The function is ethtool op, and after adding pm_runtime in begin/end ops no need in it.
Will correct it in next version.

>
>>    }
>> @@ -1065,19 +1127,29 @@ static int cpsw_common_res_usage_state(struct cpsw_priv *priv)
>>    	return usage_count;
>>    }
>>
>> +static inline struct cpdma_chan *
>> +cpsw_tx_queue_mapping(struct cpsw_priv *priv, struct sk_buff *skb)
>> +{
>> +	unsigned int q_idx = skb_get_queue_mapping(skb);
>> +
>> +	if (q_idx >= priv->tx_ch_num)
>> +		q_idx = q_idx % priv->tx_ch_num;
>> +
>> +	return priv->txch[q_idx];
>> +}
>> +
>>    static inline int cpsw_tx_packet_submit(struct net_device *ndev,
>> -			struct cpsw_priv *priv, struct sk_buff *skb)
>> +					struct cpsw_priv *priv,
>> +					struct sk_buff *skb,
>> +					struct cpdma_chan *txch)
>>    {
>>    	if (!priv->data.dual_emac)
>> -		return cpdma_chan_submit(priv->txch, skb, skb->data,
>> -				  skb->len, 0);
>> +		return cpdma_chan_submit(txch, skb, skb->data, skb->len, 0);
>>
>>    	if (ndev == cpsw_get_slave_ndev(priv, 0))
>> -		return cpdma_chan_submit(priv->txch, skb, skb->data,
>> -				  skb->len, 1);
>> +		return cpdma_chan_submit(txch, skb, skb->data, skb->len, 1);
>>    	else
>> -		return cpdma_chan_submit(priv->txch, skb, skb->data,
>> -				  skb->len, 2);
>> +		return cpdma_chan_submit(txch, skb, skb->data, skb->len, 2);
>>    }
>>
>>    static inline void cpsw_add_dual_emac_def_ale_entries(
>
> [...]
>
>>
>> @@ -1614,12 +1713,16 @@ static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
>>    static void cpsw_ndo_tx_timeout(struct net_device *ndev)
>>    {
>>    	struct cpsw_priv *priv = netdev_priv(ndev);
>> +	int ch;
>>
>>    	cpsw_err(priv, tx_err, "transmit timeout, restarting dma\n");
>>    	ndev->stats.tx_errors++;
>>    	cpsw_intr_disable(priv);
>> -	cpdma_chan_stop(priv->txch);
>> -	cpdma_chan_start(priv->txch);
>> +	for (ch = 0; ch < priv->tx_ch_num; ch++) {
>> +		cpdma_chan_stop(priv->txch[ch]);
>> +		cpdma_chan_start(priv->txch[ch]);
>> +	}
>> +
>>    	cpsw_intr_enable(priv);
>>    }
>>
>> @@ -1833,7 +1936,7 @@ static void cpsw_get_drvinfo(struct net_device *ndev,
>>    	struct cpsw_priv *priv = netdev_priv(ndev);
>>
>>    	strlcpy(info->driver, "cpsw", sizeof(info->driver));
>> -	strlcpy(info->version, "1.0", sizeof(info->version));
>> +	strlcpy(info->version, "1.1", sizeof(info->version));
>
> Not sure about this change, at least not as part of this patch.
The possibilities of the driver are changed. Now it's multichannel.
If you think it's not needed I can drop it otherwise will send it with separate patch.

>
>>    	strlcpy(info->bus_info, priv->pdev->name, sizeof(info->bus_info));
>>    }
>>
>> @@ -2181,7 +2284,7 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
>>    	struct cpsw_priv		*priv_sl2;
>>    	int ret = 0, i;
>>
>> -	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
>> +	ndev = alloc_etherdev_mq(sizeof(struct cpsw_priv), CPSW_MAX_QUEUES);
>>    	if (!ndev) {
>>    		dev_err(&pdev->dev, "cpsw: error allocating net_device\n");
>>    		return -ENOMEM;
>> @@ -2216,8 +2319,15 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
>>    	priv_sl2->wr_regs = priv->wr_regs;
>>    	priv_sl2->hw_stats = priv->hw_stats;
>>    	priv_sl2->dma = priv->dma;
>> -	priv_sl2->txch = priv->txch;
>> -	priv_sl2->rxch = priv->rxch;
>
> [...]
>
>>
>> -	if (WARN_ON(!priv->txch || !priv->rxch)) {
>> +	if (WARN_ON(!priv->rxch[0] || !priv->txch[0])) {
>>    		dev_err(priv->dev, "error initializing dma channels\n");
>>    		ret = -ENOMEM;
>>    		goto clean_dma_ret;
>> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
>> index 2f4b571..a4b299d 100644
>> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
>> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
>> @@ -481,6 +481,18 @@ void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr, u32 value)
>>    }
>>    EXPORT_SYMBOL_GPL(cpdma_ctlr_eoi);
>>
>> +u32 cpdma_ctrl_rxchs_state(struct cpdma_ctlr *ctlr)
>> +{
>> +	return dma_reg_read(ctlr, CPDMA_RXINTSTATMASKED);
>> +}
>> +EXPORT_SYMBOL_GPL(cpdma_ctrl_rxchs_state);
>> +
>> +u32 cpdma_ctrl_txchs_state(struct cpdma_ctlr *ctlr)
>> +{
>> +	return dma_reg_read(ctlr, CPDMA_TXINTSTATMASKED);
>
> TRM: CPDMA_INT TX INTERRUPT STATUS REGISTER (MASKED VALUE)
>
>> +}
>> +EXPORT_SYMBOL_GPL(cpdma_ctrl_txchs_state);
>
> This is interrupt status, so may be cpdma_ctrl_tx[rx]chs_intr_status() name
> will be more appropriate?
Not sure. It's not exacly interrupt status as can give status of channel even if the intertupt was disabled.
And it can be used w/o interrupt at all, just polling. The interrupt status can be read with another register.
This one continue to mirror descriptors presence for channels till they are all correctly handled.

>
>> +
>>    /**
>>     * cpdma_chan_split_pool - Splits ctrl pool between all channels.
>>     * Has to be called under ctlr lock
>> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
>> index 0308b67..3ce91a1 100644
>> --- a/drivers/net/ethernet/ti/davinci_cpdma.h
>> +++ b/drivers/net/ethernet/ti/davinci_cpdma.h
>> @@ -96,6 +96,8 @@ int cpdma_chan_process(struct cpdma_chan *chan, int quota);
>>    int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable);
>>    void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr, u32 value);
>>    int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable);
>> +u32 cpdma_ctrl_rxchs_state(struct cpdma_ctlr *ctlr);
>> +u32 cpdma_ctrl_txchs_state(struct cpdma_ctlr *ctlr);
>>    bool cpdma_check_free_tx_desc(struct cpdma_chan *chan);
>>
>>    enum cpdma_control {
>>
>
>

-- 
Regards,
Ivan Khoronzhuk
