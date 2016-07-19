From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH 4/4] net: ethernet: ti: cpsw: add ethtool channels support
Date: Tue, 19 Jul 2016 16:39:32 +0300
Message-ID: <578E2D94.3010508@linaro.org>
References: <1467313478-22919-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1467313478-22919-5-git-send-email-ivan.khoronzhuk@linaro.org>
 <577FAB95.9010407@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	nsekhar@ti.com
To: Grygorii Strashko <grygorii.strashko@ti.com>, davem@davemloft.net,
	netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <577FAB95.9010407@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08.07.16 16:33, Grygorii Strashko wrote:
> On 06/30/2016 10:04 PM, Ivan Khoronzhuk wrote:
>> These ops allow to control number of channels driver is allowed to
>> work with. The maximum number of channels is 8 for rx and 8 for tx.
>> After this patch the following commands are possible:
>>
>> $ ethtool -l eth0
>> $ ethtool -L eth0 rx 6 tx 6
>
>
> Could you add some description here about switch vs dual_mac behavior?
I will add, but, maybe here should be some changes + info about how to share channels
between two interfaces. Would you like me to add some concrete description?

>
>>
>> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>> ---
>>    drivers/net/ethernet/ti/cpsw.c | 188 +++++++++++++++++++++++++++++++++++++++++
>>    1 file changed, 188 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index 595ed56..729b8be 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -740,6 +740,11 @@ static void cpsw_rx_handler(void *token, int len, int status)
>>    	}
>>
>>    requeue:
>> +	if (netif_dormant(ndev)) {
>> +		dev_kfree_skb_any(new_skb);
>> +		return;
>> +	}
>> +
>>    	ch = priv->rxch[skb_get_queue_mapping(new_skb)];
>>    	ret = cpdma_chan_submit(ch, new_skb, new_skb->data,
>>    				skb_tailroom(new_skb), 0);
>> @@ -2077,6 +2082,187 @@ static void cpsw_ethtool_op_complete(struct net_device *ndev)
>>    		cpsw_err(priv, drv, "ethtool complete failed %d\n", ret);
>>    }
>>
>> +static void cpsw_get_channels(struct net_device *dev,
>> +			      struct ethtool_channels *ch)
>> +{
>> +	struct cpsw_priv *priv = netdev_priv(dev);
>> +
>> +	ch->max_combined = 0;
>> +	ch->max_rx = CPSW_MAX_QUEUES;
>> +	ch->max_tx = CPSW_MAX_QUEUES;
>> +	ch->max_other = 0;
>> +	ch->other_count = 0;
>> +	ch->rx_count = priv->rx_ch_num;
>> +	ch->tx_count = priv->tx_ch_num;
>> +	ch->combined_count = 0;
>> +}
>> +
>> +static int cpsw_check_ch_settings(struct cpsw_priv *priv,
>> +				  struct ethtool_channels *ch)
>> +{
>> +	if (ch->combined_count)
>> +		return -EINVAL;
>> +
>> +	/* verify we have at least one channel in each direction */
>> +	if (!ch->rx_count || !ch->tx_count)
>> +		return -EINVAL;
>> +
>> +	if (ch->rx_count > priv->data.channels ||
>> +	    ch->tx_count > priv->data.channels)
>> +		return -EINVAL;
>> +
>> +	return 0;
>> +}
>> +
>> +static void cpsw_sync_dual_ch_list(struct net_device *sdev,
>> +				   struct net_device *ddev)
>> +{
>> +	struct cpsw_priv *priv_s, *priv_d;
>> +	int i;
>> +
>> +	priv_s = netdev_priv(sdev);
>> +	priv_d = netdev_priv(ddev);
>> +
>> +	priv_d->rx_ch_num = priv_s->rx_ch_num;
>> +	priv_d->tx_ch_num = priv_s->tx_ch_num;
>> +
>> +	for (i = 0; i < priv_d->tx_ch_num; i++)
>> +		priv_d->txch[i] = priv_s->txch[i];
>> +	for (i = 0; i < priv_d->rx_ch_num; i++)
>> +		priv_d->rxch[i] = priv_s->rxch[i];
>> +}
>> +
>> +static int cpsw_update_channels_res(struct cpsw_priv *priv, int ch_num, int rx)
>> +{
>> +	int (*poll)(struct napi_struct *, int);
>> +	void (*handler)(void *, int, int);
>> +	struct cpdma_chan **chan;
>> +	int *ch;
>> +	int ret;
>> +
>> +	if (rx) {
>> +		ch = &priv->rx_ch_num;
>> +		chan = priv->rxch;
>> +		handler = cpsw_rx_handler;
>> +		poll = cpsw_rx_poll;
>> +	} else {
>> +		ch = &priv->tx_ch_num;
>> +		chan = priv->txch;
>> +		handler = cpsw_tx_handler;
>> +		poll = cpsw_tx_poll;
>> +	}
>> +
>> +	while (*ch < ch_num) {
>> +		chan[*ch] = cpdma_chan_create(priv->dma, *ch, handler, rx);
>> +
>> +		if (IS_ERR(chan[*ch]))
>> +			return PTR_ERR(chan[*ch]);
>> +
>> +		if (!chan[*ch])
>> +			return -EINVAL;
>> +
>> +		dev_info(priv->dev, "created new %d %s channel\n", *ch,
>> +			 (rx ? "rx" : "tx"));
>> +		(*ch)++;
>> +	}
>> +
>> +	while (*ch > ch_num) {
>> +		int tch = *ch - 1;
>
> why tch? can you use more informative names
Yep. Will correct.

>
>> +
>> +		ret = cpdma_chan_destroy(chan[tch]);
>> +		if (ret)
>> +			return ret;
>> +
>> +		dev_info(priv->dev, "destroyed %d %s channel\n", tch,
>> +			 (rx ? "rx" : "tx"));
>> +		(*ch)--;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static int cpsw_update_channels(struct net_device *dev,
>> +				struct ethtool_channels *ch)
>> +{
>> +	struct cpsw_priv *priv;
>> +	int ret;
>> +
>> +	priv = netdev_priv(dev);
>> +
>> +	ret = cpsw_update_channels_res(priv, ch->rx_count, 1);
>> +	if (ret)
>> +		return ret;
>> +
>> +	ret = cpsw_update_channels_res(priv, ch->tx_count, 0);
>> +	if (ret)
>> +		return ret;
>> +
>> +	if (priv->data.dual_emac) {
>> +		int i;
>> +		/* mirror channels for another SL */
>> +		for (i = 0; i < priv->data.slaves; i++) {
>> +			if (priv->slaves[i].ndev == dev)
>> +				continue;
>> +
>> +			cpsw_sync_dual_ch_list(dev, priv->slaves[i].ndev);
>> +		}
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static int cpsw_set_channels(struct net_device *ndev,
>> +			     struct ethtool_channels *chs)
>> +{
>> +	struct cpsw_priv *priv = netdev_priv(ndev);
>> +	int ret;
>> +
>> +	ret = cpsw_check_ch_settings(priv, chs);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	if (netif_running(ndev)) {
>> +		netif_tx_stop_all_queues(ndev);
>> +		cpsw_intr_disable(priv);
>> +		netif_dormant_on(ndev);
>> +		cpdma_ctlr_stop(priv->dma);
>> +	}
>> +
>> +	ret = cpsw_update_channels(ndev, chs);
>> +	if (ret)
>> +		goto err;
>> +
>> +	if (netif_running(ndev)) {
>> +		/* inform stach about new count of queues */
>> +		ret = netif_set_real_num_tx_queues(ndev, priv->tx_ch_num);
>> +		if (ret) {
>> +			dev_err(priv->dev, "cannot set real number of tx queues\n");
>> +			goto err;
>> +		}
>> +
>> +		ret = netif_set_real_num_rx_queues(ndev, priv->rx_ch_num);
>> +		if (ret) {
>> +			dev_err(priv->dev, "cannot set real number of rx queues\n");
>> +			goto err;
>> +		}
>
> You're synchronizing slaves channels for dual_mac mode above, but updating netif real_num_XY_queues()
> only for current netdev. Is it correct?
It seems to be an issue. I'm going to change behavior for dual mode a little, and will keep it in mind.

>
>> +
>> +		netif_dormant_off(ndev);
>> +
>> +		if (cpsw_fill_rx_channels(ndev))
>> +			goto err;
>> +
>> +		cpdma_ctlr_start(priv->dma);
>> +		cpsw_intr_enable(priv);
>> +		netif_tx_start_all_queues(ndev);
>> +	}
>> +
>> +	return 0;
>> +err:
>> +	dev_err(priv->dev, "cannot update channels number, closing device\n");
>> +	dev_close(ndev);
>> +	return ret;
>> +}
>> +
>>    static const struct ethtool_ops cpsw_ethtool_ops = {
>>    	.get_drvinfo	= cpsw_get_drvinfo,
>>    	.get_msglevel	= cpsw_get_msglevel,
>> @@ -2098,6 +2284,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
>>    	.get_regs	= cpsw_get_regs,
>>    	.begin		= cpsw_ethtool_op_begin,
>>    	.complete	= cpsw_ethtool_op_complete,
>> +	.get_channels	= cpsw_get_channels,
>> +	.set_channels	= cpsw_set_channels,
>>    };
>>
>>    static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
>>
>
>

-- 
Regards,
Ivan Khoronzhuk
