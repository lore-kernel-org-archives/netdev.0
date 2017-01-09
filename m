From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 3/4] net: ethernet: ti: cpsw: don't duplicate ndev_running
Date: Mon, 9 Jan 2017 11:25:38 -0600
Message-ID: <c6dfedc3-d346-b9a4-f398-96ac7e57d0b8@ti.com>
References: <1483893663-15673-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1483893663-15673-4-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:44911 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035128AbdAIRZk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:25:40 -0500
In-Reply-To: <1483893663-15673-4-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/08/2017 10:41 AM, Ivan Khoronzhuk wrote:
> No need to create additional vars to identify if interface is running.
> So simplify code by removing redundant var and checking usage counter
> instead.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 14 ++++----------
>  1 file changed, 4 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 40d7fc9..daae87f 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -357,7 +357,6 @@ struct cpsw_slave {
>  	struct phy_device		*phy;
>  	struct net_device		*ndev;
>  	u32				port_vlan;
> -	u32				open_stat;
>  };
>  
>  static inline u32 slave_read(struct cpsw_slave *slave, u32 offset)
> @@ -1241,7 +1240,7 @@ static int cpsw_common_res_usage_state(struct cpsw_common *cpsw)
>  	u32 usage_count = 0;
>  
>  	for (i = 0; i < cpsw->data.slaves; i++)
> -		if (cpsw->slaves[i].open_stat)
> +		if (netif_running(cpsw->slaves[i].ndev))
>  			usage_count++;

Not sure this will work as you expected, but may be I've missed smth :(

code in static int __dev_open(struct net_device *dev)
..
	set_bit(__LINK_STATE_START, &dev->state);

	if (ops->ndo_validate_addr)
		ret = ops->ndo_validate_addr(dev);

	if (!ret && ops->ndo_open)
		ret = ops->ndo_open(dev);

	netpoll_poll_enable(dev);

	if (ret)
		clear_bit(__LINK_STATE_START, &dev->state);
..

so, netif_running(ndev) will start returning true before calling ops->ndo_open(dev);

>  
>  	return usage_count;
> @@ -1502,7 +1501,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
>  		 CPSW_RTL_VERSION(reg));
>  
>  	/* initialize host and slave ports */
> -	if (!cpsw_common_res_usage_state(cpsw))
> +	if (cpsw_common_res_usage_state(cpsw) < 2)

Ah. You've changed the condition here.

I think it might be reasonable to hide this inside cpsw_common_res_usage_state()
and seems it can be renamed to smth like cpsw_is_running().


>  		cpsw_init_host_port(priv);
>  	for_each_slave(priv, cpsw_slave_open, priv);
>  
> @@ -1513,7 +1512,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
>  		cpsw_ale_add_vlan(cpsw->ale, cpsw->data.default_vlan,
>  				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
>  
> -	if (!cpsw_common_res_usage_state(cpsw)) {
> +	if (cpsw_common_res_usage_state(cpsw) < 2) {
>  		/* disable priority elevation */
>  		__raw_writel(0, &cpsw->regs->ptype);
>  
> @@ -1556,9 +1555,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
>  	cpdma_ctlr_start(cpsw->dma);
>  	cpsw_intr_enable(cpsw);
>  
> -	if (cpsw->data.dual_emac)
> -		cpsw->slaves[priv->emac_port].open_stat = true;
> -
>  	return 0;
>  
>  err_cleanup:
> @@ -1578,7 +1574,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
>  	netif_tx_stop_all_queues(priv->ndev);
>  	netif_carrier_off(priv->ndev);
>  
> -	if (cpsw_common_res_usage_state(cpsw) <= 1) {
> +	if (!cpsw_common_res_usage_state(cpsw)) {

and here __LINK_STATE_START will be cleared before calling ops->ndo_stop(dev);
So, from one side netif_running(ndev) usage will simplify cpsw_common_res_usage_state() internals,
but from another side - it will make places where it's used even more entangled :( as for me,
because when cpsw_common_res_usage_state() will return 1 in cpsw_ndo_open() it will mean
"no interfaces is really running yet", but the same value 1 in cpsw_ndo_stop()
will mean "there are still one is running".

>  		napi_disable(&cpsw->napi_rx);
>  		napi_disable(&cpsw->napi_tx);
>  		cpts_unregister(cpsw->cpts);
> @@ -1592,8 +1588,6 @@ static int cpsw_ndo_stop(struct net_device *ndev)
>  		cpsw_split_res(ndev);
>  
>  	pm_runtime_put_sync(cpsw->dev);
> -	if (cpsw->data.dual_emac)
> -		cpsw->slaves[priv->emac_port].open_stat = false;
>  	return 0;
>  }
>  
> 

-- 
regards,
-grygorii
