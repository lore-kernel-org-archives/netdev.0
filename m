From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Thu, 28 Jul 2016 14:12:41 -0500
Message-ID: <579A5929.4010908@codeaurora.org>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
 <577999EC.1010104@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org, shankerd@codeaurora.org,
	vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
	robh+dt@kernel.org, andrew@lunn.ch, bjorn.andersson@linaro.org,
	mlangsdo@redhat.com, jcm@redhat.com, agross@codeaurora.org,
	davem@davemloft.net, f.fainelli@gmail.com
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <577999EC.1010104@gmx.de>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lino Sanfilippo wrote:

>> +		skb = dev_alloc_skb(adpt->rxbuf_size + NET_IP_ALIGN);
>> +		if (!skb)
>> +			break;
>> +
>> +		/* Make buffer alignment 2 beyond a 16 byte boundary
>> +		 * this will result in a 16 byte aligned IP header after
>> +		 * the 14 byte MAC header is removed
>> +		 */
>> +		skb_reserve(skb, NET_IP_ALIGN);
>
> __netdev_alloc_skb_ip_align will do this for you.

Will fix.

>> +		curr_rxbuf->dma_addr = dma_map_single(adpt->netdev->dev.parent,
>> +						      skb_data,
>> +						      curr_rxbuf->length,
>> +						      DMA_FROM_DEVICE);
>
>
> Mapping can fail. You should check the result via dma_mapping_error().
> There are several other places in which dma_map_single() is called and the return value
> is not checked.

Will fix.

>> +	if (ret) {
>> +		netdev_err(adpt->netdev,
>> +			   "error:%d on request_irq(%d:%s flags:0)\n", ret,
>> +			   irq->irq, EMAC_MAC_IRQ_RES);
>
> freeing the irq is missing

Will fix.

>> +	/* disable mac irq */
>> +	writel(DIS_INT, adpt->base + EMAC_INT_STATUS);
>> +	writel(0, adpt->base + EMAC_INT_MASK);
>> +	synchronize_irq(adpt->irq.irq);
>> +	free_irq(adpt->irq.irq, &adpt->irq);
>> +	clear_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
>> +
>> +	cancel_work_sync(&adpt->tx_ts_task);
>> +	spin_lock_irqsave(&adpt->tx_ts_lock, flags);
>
> Maybe I am missing something but AFAICS tx_ts_lock is never called from irq context, so
> there is no reason to disable irqs.

It might have been that way in an older version of the code, but it 
appears you are correct.  I will change it to a normal spinlock.  Thanks.

>> +/* Push the received skb to upper layers */
>> +static void emac_receive_skb(struct emac_rx_queue *rx_q,
>> +			     struct sk_buff *skb,
>> +			     u16 vlan_tag, bool vlan_flag)
>> +{
>> +	if (vlan_flag) {
>> +		u16 vlan;
>> +
>> +		EMAC_TAG_TO_VLAN(vlan_tag, vlan);
>> +		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan);
>> +	}
>> +
>> +	napi_gro_receive(&rx_q->napi, skb);
>
> napi_gro_receive requires rx checksum offload. However emac_receive_skb() is also called if
> hardware checksumming is disabled.

So the hardware is a little weird here.  Apparently, there is a bug in 
the parsing of the packet headers that is avoided if we disable hardware 
checksumming.

In emac_mac_rx_process(), right before it calls emac_receive_skb(), it 
does this:

if (netdev->features & NETIF_F_RXCSUM)
	skb->ip_summed = RRD_L4F(&rrd) ?
			  CHECKSUM_NONE : CHECKSUM_UNNECESSARY;
else
	skb_checksum_none_assert(skb);

RRD_L4F(&rrd) is always zero and NETIF_F_RXCSUM is set by default, so 
ip_summed is set to CHECKSUM_UNNECESSARY.

So you're saying that if NETIF_F_RXCSUM is not set, then 
napi_gro_receive() should not be called?

I see examples of other drivers that *appear* to call napi_gro_receive() 
even when hardware checksumming is disabled.

For example, bfin_mac_rx() in adi/bfin_mac.c does this:

/*
  * Disable hardware checksum for bug #5600 if writeback cache is
  * enabled. Otherwize, corrupted RX packet will be sent up stack
  * without error mark.
  */
#ifndef CONFIG_BFIN_EXTMEM_WRITEBACK
#define BFIN_MAC_CSUM_OFFLOAD
#endif

...

#if defined(BFIN_MAC_CSUM_OFFLOAD)
...
#endif
	napi_gro_receive(&lp->napi, skb);

Shouldn't the call to napi_gro_receive() be before the #endif?

Function i40e_receive_skb() has similar code to my driver.

In fact, I have not been able to find any clear example of a driver that 
intentionally avoids calling napi_gro_receive() if hardware checksumming 
is disabled.

>> +/* Transmit the packet using specified transmit queue */
>> +int emac_mac_tx_buf_send(struct emac_adapter *adpt, struct emac_tx_queue *tx_q,
>> +			 struct sk_buff *skb)
>> +{
>> +	struct emac_tpd tpd;
>> +	u32 prod_idx;
>> +
>> +	if (!emac_tx_has_enough_descs(tx_q, skb)) {
>
> Drivers should avoid this situation right from the start by checking after each transmission if the max number
>   of possible descriptors is still available for a further transmission and stop the queue if there are not.

Ok, to be clear, you're saying I should do what bcmgenet_xmit() does.

	if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
		netif_tx_stop_queue(txq);

At the end of emac_mac_tx_buf_send(), I should call 
emac_tpd_num_free_descs() and check to see whether the number of free 
descriptors is <= (MAX_SKB_FRAGS + 1).

> Furthermore there does not seem to be any function that wakes the queue up again once it has been stopped.

If I make the above fix, won't that also fix this bug?

>> +/* reinitialize */
>> +void emac_reinit_locked(struct emac_adapter *adpt)
>> +{
>> +	while (test_and_set_bit(EMAC_STATUS_RESETTING, &adpt->status))
>> +		msleep(20); /* Reset might take few 10s of ms */
>> +
>> +	emac_mac_down(adpt, true);
>> +
>> +	emac_sgmii_reset(adpt);
>> +	emac_mac_up(adpt);
>
> emac_mac_up() may fail, so this case should be handled properly.

Ok.

>
>> +/* Change the Maximum Transfer Unit (MTU) */
>> +static int emac_change_mtu(struct net_device *netdev, int new_mtu)
>> +{
>> +	unsigned int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
>> +	struct emac_adapter *adpt = netdev_priv(netdev);
>> +	unsigned int old_mtu = netdev->mtu;
>> +
>> +	if ((max_frame < EMAC_MIN_ETH_FRAME_SIZE) ||
>> +	    (max_frame > EMAC_MAX_ETH_FRAME_SIZE)) {
>> +		netdev_err(adpt->netdev, "error: invalid MTU setting\n");
>> +		return -EINVAL;
>> +	}
>> +
>> +	if ((old_mtu != new_mtu) && netif_running(netdev)) {
>
> Setting the new mtu in case that the interface is down is missing.

Should I just move the "netdev->mtu = new_mtu" line outside of the 
if-statement?

> Also the first check is not needed, since this function is only called if
> there is a change of the mtu.

Will fix.

>> +/* Provide network statistics info for the interface */
>> +static struct rtnl_link_stats64 *emac_get_stats64(struct net_device *netdev,
>> +						  struct rtnl_link_stats64 *net_stats)
>> +{
>> +	struct emac_adapter *adpt = netdev_priv(netdev);
>> +	unsigned int addr = REG_MAC_RX_STATUS_BIN;
>> +	struct emac_stats *stats = &adpt->stats;
>> +	u64 *stats_itr = &adpt->stats.rx_ok;
>> +	u32 val;
>> +
>> +	mutex_lock(&stats->lock);
>
> It is not allowed to sleep in this function, so you have to use something else for locking,
> e.g. a spinlock.

Will fix.

>> +	strlcpy(netdev->name, "eth%d", sizeof(netdev->name));
>
> This is already done by alloc_etherdev.

Will fix.

Thank you very much for reviewing my code.  I hope my questions haven't 
been too stupid.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
