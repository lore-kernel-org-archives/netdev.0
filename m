From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Mon, 4 Jul 2016 01:04:12 +0200
Message-ID: <577999EC.1010104@gmx.de>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org, shankerd@codeaurora.org,
	vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
	robh+dt@kernel.org, andrew@lunn.ch, bjorn.andersson@linaro.org,
	mlangsdo@redhat.com, jcm@redhat.com, agross@codeaurora.org,
	davem@davemloft.net, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:56900 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932237AbcGCXEn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jul 2016 19:04:43 -0400
In-Reply-To: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

some remarks below.

> +/* Fill up receive queue's RFD with preallocated receive buffers */
> +static void emac_mac_rx_descs_refill(struct emac_adapter *adpt,
> +				    struct emac_rx_queue *rx_q)
> +{
> +	struct emac_buffer *curr_rxbuf;
> +	struct emac_buffer *next_rxbuf;
> +	unsigned int count = 0;
> +	u32 next_produce_idx;
> +
> +	next_produce_idx = rx_q->rfd.produce_idx + 1;
> +	if (next_produce_idx == rx_q->rfd.count)
> +		next_produce_idx = 0;
> +
> +	curr_rxbuf = GET_RFD_BUFFER(rx_q, rx_q->rfd.produce_idx);
> +	next_rxbuf = GET_RFD_BUFFER(rx_q, next_produce_idx);
> +
> +	/* this always has a blank rx_buffer*/
> +	while (!next_rxbuf->dma_addr) {
> +		struct sk_buff *skb;
> +		void *skb_data;
> +
> +		skb = dev_alloc_skb(adpt->rxbuf_size + NET_IP_ALIGN);
> +		if (!skb)
> +			break;
> +
> +		/* Make buffer alignment 2 beyond a 16 byte boundary
> +		 * this will result in a 16 byte aligned IP header after
> +		 * the 14 byte MAC header is removed
> +		 */
> +		skb_reserve(skb, NET_IP_ALIGN);

__netdev_alloc_skb_ip_align will do this for you.


> +		skb_data = skb->data;
> +		curr_rxbuf->skb = skb;
> +		curr_rxbuf->length = adpt->rxbuf_size;
> +		curr_rxbuf->dma_addr = dma_map_single(adpt->netdev->dev.parent,
> +						      skb_data,
> +						      curr_rxbuf->length,
> +						      DMA_FROM_DEVICE);


Mapping can fail. You should check the result via dma_mapping_error(). 
There are several other places in which dma_map_single() is called and the return value 
is not checked.

> +/* Bringup the interface/HW */
> +int emac_mac_up(struct emac_adapter *adpt)
> +{
> +	struct net_device *netdev = adpt->netdev;
> +	struct emac_irq	*irq = &adpt->irq;
> +	int ret;
> +
> +	emac_mac_rx_tx_ring_reset_all(adpt);
> +	emac_mac_config(adpt);
> +
> +	ret = request_irq(irq->irq, emac_isr, 0, EMAC_MAC_IRQ_RES, irq);
> +	if (ret) {
> +		netdev_err(adpt->netdev,
> +			   "error:%d on request_irq(%d:%s flags:0)\n", ret,
> +			   irq->irq, EMAC_MAC_IRQ_RES);
> +		return ret;
> +	}
> +
> +	emac_mac_rx_descs_refill(adpt, &adpt->rx_q);
> +
> +	ret = phy_connect_direct(netdev, adpt->phydev, emac_adjust_link,
> +				 PHY_INTERFACE_MODE_SGMII);
> +	if (ret) {
> +		netdev_err(adpt->netdev,
> +			   "error:%d on request_irq(%d:%s flags:0)\n", ret,
> +			   irq->irq, EMAC_MAC_IRQ_RES);

freeing the irq is missing


> +
> +/* Bring down the interface/HW */
> +void emac_mac_down(struct emac_adapter *adpt, bool reset)
> +{
> +	struct net_device *netdev = adpt->netdev;
> +	unsigned long flags;
> +
> +	netif_stop_queue(netdev);
> +	napi_disable(&adpt->rx_q.napi);
> +
> +	phy_disconnect(adpt->phydev);
> +
> +	/* disable mac irq */
> +	writel(DIS_INT, adpt->base + EMAC_INT_STATUS);
> +	writel(0, adpt->base + EMAC_INT_MASK);
> +	synchronize_irq(adpt->irq.irq);
> +	free_irq(adpt->irq.irq, &adpt->irq);
> +	clear_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
> +
> +	cancel_work_sync(&adpt->tx_ts_task);
> +	spin_lock_irqsave(&adpt->tx_ts_lock, flags);

Maybe I am missing something but AFAICS tx_ts_lock is never called from irq context, so 
there is no reason to disable irqs. 

> +
> +/* Push the received skb to upper layers */
> +static void emac_receive_skb(struct emac_rx_queue *rx_q,
> +			     struct sk_buff *skb,
> +			     u16 vlan_tag, bool vlan_flag)
> +{
> +	if (vlan_flag) {
> +		u16 vlan;
> +
> +		EMAC_TAG_TO_VLAN(vlan_tag, vlan);
> +		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan);
> +	}
> +
> +	napi_gro_receive(&rx_q->napi, skb);

napi_gro_receive requires rx checksum offload. However emac_receive_skb() is also called if
hardware checksumming is disabled. 

> +
> +/* Transmit the packet using specified transmit queue */
> +int emac_mac_tx_buf_send(struct emac_adapter *adpt, struct emac_tx_queue *tx_q,
> +			 struct sk_buff *skb)
> +{
> +	struct emac_tpd tpd;
> +	u32 prod_idx;
> +
> +	if (!emac_tx_has_enough_descs(tx_q, skb)) {

Drivers should avoid this situation right from the start by checking after each transmission if the max number
 of possible descriptors is still available for a further transmission and stop the queue if there are not.
Furthermore there does not seem to be any function that wakes the queue up again once it has been stopped.

> +
> +/* reinitialize */
> +void emac_reinit_locked(struct emac_adapter *adpt)
> +{
> +	while (test_and_set_bit(EMAC_STATUS_RESETTING, &adpt->status))
> +		msleep(20); /* Reset might take few 10s of ms */
> +
> +	emac_mac_down(adpt, true);
> +
> +	emac_sgmii_reset(adpt);
> +	emac_mac_up(adpt);

emac_mac_up() may fail, so this case should be handled properly.

> +/* Change the Maximum Transfer Unit (MTU) */
> +static int emac_change_mtu(struct net_device *netdev, int new_mtu)
> +{
> +	unsigned int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
> +	struct emac_adapter *adpt = netdev_priv(netdev);
> +	unsigned int old_mtu = netdev->mtu;
> +
> +	if ((max_frame < EMAC_MIN_ETH_FRAME_SIZE) ||
> +	    (max_frame > EMAC_MAX_ETH_FRAME_SIZE)) {
> +		netdev_err(adpt->netdev, "error: invalid MTU setting\n");
> +		return -EINVAL;
> +	}
> +
> +	if ((old_mtu != new_mtu) && netif_running(netdev)) {

Setting the new mtu in case that the interface is down is missing.
Also the first check is not needed, since this function is only called if
there is a change of the mtu. 


> +/* Provide network statistics info for the interface */
> +static struct rtnl_link_stats64 *emac_get_stats64(struct net_device *netdev,
> +						  struct rtnl_link_stats64 *net_stats)
> +{
> +	struct emac_adapter *adpt = netdev_priv(netdev);
> +	unsigned int addr = REG_MAC_RX_STATUS_BIN;
> +	struct emac_stats *stats = &adpt->stats;
> +	u64 *stats_itr = &adpt->stats.rx_ok;
> +	u32 val;
> +
> +	mutex_lock(&stats->lock);

It is not allowed to sleep in this function, so you have to use something else for locking,
e.g. a spinlock.

> +static int emac_probe(struct platform_device *pdev)
> +{
> +	struct net_device *netdev;
> +	struct emac_adapter *adpt;
> +	struct emac_phy *phy;
> +	u16 devid, revid;
> +	u32 reg;
> +	int ret;
> +
> +	/* The EMAC itself is capable of 64-bit DMA. If the SOC limits that
> +	 * range, then we expect platform code to adjust the mask accordingly.
> +	 */
> +	ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
> +	if (ret) {
> +		dev_err(&pdev->dev, "could not set DMA mask\n");
> +		return ret;
> +	}
> +
> +	netdev = alloc_etherdev(sizeof(struct emac_adapter));
> +	if (!netdev)
> +		return -ENOMEM;
> +
> +	dev_set_drvdata(&pdev->dev, netdev);
> +	SET_NETDEV_DEV(netdev, &pdev->dev);
> +
> +	adpt = netdev_priv(netdev);
> +	adpt->netdev = netdev;
> +	phy = &adpt->phy;
> +	adpt->msg_enable = EMAC_MSG_DEFAULT;
> +
> +	mutex_init(&adpt->stats.lock);
> +
> +	adpt->irq.mask = RX_PKT_INT0 | IMR_NORMAL_MASK;
> +
> +	ret = emac_probe_resources(pdev, adpt);
> +	if (ret)
> +		goto err_undo_netdev;
> +
> +	/* initialize clocks */
> +	ret = emac_clks_phase1_init(pdev, adpt);
> +	if (ret)
> +		goto err_undo_resources;
> +
> +	netdev->watchdog_timeo = EMAC_WATCHDOG_TIME;
> +	netdev->irq = adpt->irq.irq;
> +
> +	if (adpt->timestamp_en)
> +		adpt->rrd_size = EMAC_TS_RRD_SIZE;
> +	else
> +		adpt->rrd_size = EMAC_RRD_SIZE;
> +
> +	adpt->tpd_size = EMAC_TPD_SIZE;
> +	adpt->rfd_size = EMAC_RFD_SIZE;
> +
> +	/* init netdev */
> +	netdev->netdev_ops = &emac_netdev_ops;
> +
> +	/* init adapter */
> +	emac_init_adapter(adpt);
> +
> +	/* init phy */
> +	ret = emac_phy_config(pdev, adpt);
> +	if (ret)
> +		goto err_undo_clk_phase1;
> +
> +	/* enable clocks */
> +	ret = emac_clks_phase2_init(pdev, adpt);
> +	if (ret)
> +		goto err_undo_clk_phase2;
> +
> +	/* reset mac */
> +	emac_mac_reset(adpt);
> +
> +	/* set hw features */
> +	netdev->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
> +			NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_HW_VLAN_CTAG_RX |
> +			NETIF_F_HW_VLAN_CTAG_TX;
> +	netdev->hw_features = netdev->features;
> +
> +	netdev->vlan_features |= NETIF_F_SG | NETIF_F_HW_CSUM |
> +				 NETIF_F_TSO | NETIF_F_TSO6;
> +
> +	INIT_WORK(&adpt->work_thread, emac_work_thread);
> +
> +	/* Initialize queues */
> +	emac_mac_rx_tx_ring_init_all(pdev, adpt);
> +
> +	netif_napi_add(netdev, &adpt->rx_q.napi, emac_napi_rtx, 64);
> +
> +	spin_lock_init(&adpt->tx_ts_lock);
> +	skb_queue_head_init(&adpt->tx_ts_pending_queue);
> +	skb_queue_head_init(&adpt->tx_ts_ready_queue);
> +	INIT_WORK(&adpt->tx_ts_task, emac_mac_tx_ts_periodic_routine);
> +
> +	strlcpy(netdev->name, "eth%d", sizeof(netdev->name));

This is already done by alloc_etherdev.


Regards,
Lino
