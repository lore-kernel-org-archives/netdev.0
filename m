From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v13 3/3] net: hisilicon: new hip04 ethernet
 driver
Date: Wed, 14 Jan 2015 20:39:02 -0800
Message-ID: <1421296742.25598.3.camel@perches.com>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com>
	 <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, robh+dt@kernel.org, davem@davemloft.net,
	grant.likely@linaro.org, agraf@suse.de,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, zhangfei.gao@linaro.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0008.hostedemail.com ([216.40.44.8]:43578 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751159AbbAOEjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 23:39:07 -0500
In-Reply-To: <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-14 at 14:34 +0800, Ding Tianhong wrote:
> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.

Mostly trivial comments:

> +++ b/drivers/net/ethernet/hisilicon/hip04_eth.c

[]

> +#define GMAC_MAX_PKT_LEN		1516

[]

> +static int hip04_rx_poll(struct napi_struct *napi, int budget)
> +{
[]
> +	while (cnt && !last) {
[]
> +		desc = (struct rx_desc *)skb->data;
> +		len = be16_to_cpu(desc->pkt_len);
> +		err = be32_to_cpu(desc->pkt_err);
> +
> +		if (0 == len) {
> +			dev_kfree_skb_any(skb);
> +			last = true;
> +		} else if ((err & RX_PKT_ERR) || (len >= GMAC_MAX_PKT_LEN)) {

Is this ">=" correct?  Maybe it should be ">" ?

[]

> +static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev = (struct net_device *)dev_id;

Unnecessary cast of void *

[]

> +static int hip04_set_coalesce(struct net_device *netdev,
> +			      struct ethtool_coalesce *ec)
> +{
> +	struct hip04_priv *priv = netdev_priv(netdev);
> +
> +	/* Check not supported parameters  */
> +	if ((ec->rx_max_coalesced_frames) || (ec->rx_coalesce_usecs_irq) ||
> +	    (ec->rx_max_coalesced_frames_irq) || (ec->tx_coalesce_usecs_irq) ||
> +	    (ec->use_adaptive_rx_coalesce) || (ec->use_adaptive_tx_coalesce) ||
> +	    (ec->pkt_rate_low) || (ec->rx_coalesce_usecs_low) ||
> +	    (ec->rx_max_coalesced_frames_low) || (ec->tx_coalesce_usecs_high) ||
> +	    (ec->tx_max_coalesced_frames_low) || (ec->pkt_rate_high) ||
> +	    (ec->tx_coalesce_usecs_low) || (ec->rx_coalesce_usecs_high) ||
> +	    (ec->rx_max_coalesced_frames_high) || (ec->rx_coalesce_usecs) ||
> +	    (ec->tx_max_coalesced_frames_irq) ||
> +	    (ec->stats_block_coalesce_usecs) ||
> +	    (ec->tx_max_coalesced_frames_high) || (ec->rate_sample_interval))
> +		return -EOPNOTSUPP;

Rather than a somewhat haphazard mix of these values, 
this might be simpler to read as something like:

	/* Check not supported parameters  */
	if (ec->pkt_rate_low ||
	    ec->pkt_rate_high ||

	    ec->use_adaptive_rx_coalesce ||
	    ec->rx_coalesce_usecs ||
	    ec->rx_coalesce_usecs_low ||
	    ec->rx_coalesce_usecs_high ||
	    ec->rx_coalesce_usecs_irq ||
	    ec->rx_max_coalesced_frames ||
	    ec->rx_max_coalesced_frames_low ||
	    ec->rx_max_coalesced_frames_high ||
	    ec->rx_max_coalesced_frames_irq ||
	    
	    ec->use_adaptive_tx_coalesce ||
	    ec->tx_coalesce_usecs_low ||
	    ec->tx_coalesce_usecs_high ||
	    ec->tx_max_coalesced_frames_low ||
	    ec->tx_max_coalesced_frames_high ||
	    ec->tx_max_coalesced_frames_irq ||

	    ec->stats_block_coalesce_usecs ||
	    ec->rate_sample_interval)
		return -EOPNOTSUPP;


> +static void hip04_free_ring(struct net_device *ndev, struct device *d)
> +{
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	int i;
> +
> +	for (i = 0; i < RX_DESC_NUM; i++)
> +		if (priv->rx_buf[i])
> +			put_page(virt_to_head_page(priv->rx_buf[i]));

It's generally nicer to use braces around
for loops with single ifs.

> +
> +	for (i = 0; i < TX_DESC_NUM; i++)
> +		if (priv->tx_skb[i])
> +			dev_kfree_skb_any(priv->tx_skb[i]);
