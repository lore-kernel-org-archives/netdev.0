From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Sat, 30 Jul 2016 12:26:05 +0200
Message-ID: <d41488bf-ef79-ab11-f5fd-5ab15195c932@gmx.de>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
 <577999EC.1010104@gmx.de> <579A5929.4010908@codeaurora.org>
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
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <579A5929.4010908@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28.07.2016 21:12, Timur Tabi wrote:

> 
>>> +	if (ret) {
>>> +		netdev_err(adpt->netdev,
>>> +			   "error:%d on request_irq(%d:%s flags:0)\n", ret,
>>> +			   irq->irq, EMAC_MAC_IRQ_RES);
>>
>> freeing the irq is missing
> 
> Will fix.
> 
>>> +	/* disable mac irq */
>>> +	writel(DIS_INT, adpt->base + EMAC_INT_STATUS);
>>> +	writel(0, adpt->base + EMAC_INT_MASK);
>>> +	synchronize_irq(adpt->irq.irq);
>>> +	free_irq(adpt->irq.irq, &adpt->irq);
>>> +	clear_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
>>> +
>>> +	cancel_work_sync(&adpt->tx_ts_task);
>>> +	spin_lock_irqsave(&adpt->tx_ts_lock, flags);
>>
>> Maybe I am missing something but AFAICS tx_ts_lock is never called from irq context, so
>> there is no reason to disable irqs.
> 
> It might have been that way in an older version of the code, but it 
> appears you are correct.  I will change it to a normal spinlock.  Thanks.

By looking closer to the code, the lock seems to serve the protection of a list of skbs that
are queued to be timestamped. However there is nothing that ever enqueues those skbs, is it? 
I assume that this is a leftover of a previous version of that driver. Code to be merged into 
mailine has to be completely cleaned up and must not contains any functions which are never 
called. So either you implement the timestamping feature completely or you remove the concerning 
code altogether for the initial mainline driver version. You can add that feature any time later. 

> 
>>> +/* Push the received skb to upper layers */
>>> +static void emac_receive_skb(struct emac_rx_queue *rx_q,
>>> +			     struct sk_buff *skb,
>>> +			     u16 vlan_tag, bool vlan_flag)
>>> +{
>>> +	if (vlan_flag) {
>>> +		u16 vlan;
>>> +
>>> +		EMAC_TAG_TO_VLAN(vlan_tag, vlan);
>>> +		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan);
>>> +	}
>>> +
>>> +	napi_gro_receive(&rx_q->napi, skb);
>>
>> napi_gro_receive requires rx checksum offload. However emac_receive_skb() is also called if
>> hardware checksumming is disabled.
> 
> So the hardware is a little weird here.  Apparently, there is a bug in 
> the parsing of the packet headers that is avoided if we disable hardware 
> checksumming.
> 
> In emac_mac_rx_process(), right before it calls emac_receive_skb(), it 
> does this:
> 
> if (netdev->features & NETIF_F_RXCSUM)
> 	skb->ip_summed = RRD_L4F(&rrd) ?
> 			  CHECKSUM_NONE : CHECKSUM_UNNECESSARY;
> else
> 	skb_checksum_none_assert(skb);
> 
> RRD_L4F(&rrd) is always zero and NETIF_F_RXCSUM is set by default, so 
> ip_summed is set to CHECKSUM_UNNECESSARY.
> 
> So you're saying that if NETIF_F_RXCSUM is not set, then 
> napi_gro_receive() should not be called?

This requirement seems indeed to be obsolete now so you can ignore my former complaint and
leave it as it is. 

> In fact, I have not been able to find any clear example of a driver that 
> intentionally avoids calling napi_gro_receive() if hardware checksumming 
> is disabled.

Some drivers still make the differentiation:
http://lxr.free-electrons.com/source/drivers/net/ethernet/marvell/sky2.c#L2656
http://lxr.free-electrons.com/source/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c#L1548
and several more.

>>> +/* Transmit the packet using specified transmit queue */
>>> +int emac_mac_tx_buf_send(struct emac_adapter *adpt, struct emac_tx_queue *tx_q,
>>> +			 struct sk_buff *skb)
>>> +{
>>> +	struct emac_tpd tpd;
>>> +	u32 prod_idx;
>>> +
>>> +	if (!emac_tx_has_enough_descs(tx_q, skb)) {
>>
>> Drivers should avoid this situation right from the start by checking after each transmission if the max number
>>   of possible descriptors is still available for a further transmission and stop the queue if there are not.
> 
> Ok, to be clear, you're saying I should do what bcmgenet_xmit() does.
> 
> 	if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
> 		netif_tx_stop_queue(txq);
> 
> At the end of emac_mac_tx_buf_send(), I should call 
> emac_tpd_num_free_descs() and check to see whether the number of free 
> descriptors is <= (MAX_SKB_FRAGS + 1).

Right. The current implemented approach to check the number of descs at the beginning instead of at the
end of a transmission is not wrong but it leads to one extra call of xmit if the driver is running
out of descs. So most drivers avoid this by stopping the queue as soon as they detect that the max 
required number of descs for a further transmission is not available. 

> 
>> Furthermore there does not seem to be any function that wakes the queue up again once it has been stopped.
> 
> If I make the above fix, won't that also fix this bug?

No, how should it? There still is nothing that wakes up the queue once it is stopped. Stopping and 
restarting/waking up a queue is up to the driver, since the network stack cant know if the hw is
ready to queue another transmission or not. Usually the queue is stopped in the xmit function
as soon as there are not enough descs left. Stopping the queue tells the network stack not to 
call the xmit function any more. When there are enough descs available again the driver
has to wake up the queue. This is normally done in the tx completion handler (emac_mac_tx_process()
in your case) as soon as enough free list elements are available again. Take a look at other
drivers and when they call netif_wake_queue (or one of its variants).


> 
>>
>>> +/* Change the Maximum Transfer Unit (MTU) */
>>> +static int emac_change_mtu(struct net_device *netdev, int new_mtu)
>>> +{
>>> +	unsigned int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
>>> +	struct emac_adapter *adpt = netdev_priv(netdev);
>>> +	unsigned int old_mtu = netdev->mtu;
>>> +
>>> +	if ((max_frame < EMAC_MIN_ETH_FRAME_SIZE) ||
>>> +	    (max_frame > EMAC_MAX_ETH_FRAME_SIZE)) {
>>> +		netdev_err(adpt->netdev, "error: invalid MTU setting\n");
>>> +		return -EINVAL;
>>> +	}
>>> +
>>> +	if ((old_mtu != new_mtu) && netif_running(netdev)) {
>>
>> Setting the new mtu in case that the interface is down is missing.
> 
> Should I just move the "netdev->mtu = new_mtu" line outside of the 
> if-statement?

You can do that, but take care to ajdust dpt->rxbuf_size to the correct
value as soon as the interface is brought up. (The same applies to the
initialization of the mac with the new mtu value of course).

Regards,
Lino
