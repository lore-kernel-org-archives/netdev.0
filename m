From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Wed, 22 Apr 2015 16:22:54 -0700
Message-ID: <55382D4E.5070708@gmail.com>
References: <32501816.HtkLenWQpn@wasted.cogentembedded.com> <552C4554.2070608@gmail.com> <552D8898.3060905@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <552D8898.3060905@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/04/15 14:37, Sergei Shtylyov wrote:
> 
>>> +    /* Wait for stopping the hardware TX process */
>>> +    ravb_wait(ndev, TCCR, TCCR_TSRQ0 | TCCR_TSRQ1 | TCCR_TSRQ2 |
>>> TCCR_TSRQ3,
>>> +          0);
>>> +
>>> +    ravb_wait(ndev, CSR, CSR_TPO0 | CSR_TPO1 | CSR_TPO2 | CSR_TPO3, 0);
>>> +
>>> +    /* Stop the E-MAC's RX processes. */
>>> +    ravb_write(ndev, ravb_read(ndev, ECMR) & ~ECMR_RE, ECMR);
> 
>> [snip]
> 
>>> +        /* Transmited network control queue */
>>> +        if (tis & TIS_FTF1) {
>>> +            ravb_tx_free(ndev, RAVB_NC);
>>> +            netif_wake_queue(ndev);
> 
>> This would be better moved to the NAPI handler.
> 
>    Maybe, not sure...
> 
>>> +            result = IRQ_HANDLED;
>>> +        }
> 
>> [snip]
> 
>>> +    if (ecmd->duplex == DUPLEX_FULL)
>>> +        priv->duplex = 1;
>>> +    else
>>> +        priv->duplex = 0;
> 
>> Why not use what priv->phydev->duplex has cached for you?
> 
>    Because we compare 'priv->duplex' with 'priv->phydev->duplex' in
> ravb_adjust_link(). Or what did you mean?

Oh I see how you are using this now, but it does not look like it is
necessary, since you use phy_ethtool_sset() using phydev->duplex
directly ought to be enough anywhere in your driver? Unless there is a
mode where you are running PHY-less, and not using a fixed PHY to
emulate a PHY...

> 
> [...]
> 
>>> +static int ravb_nway_reset(struct net_device *ndev)
>>> +{
>>> +    struct ravb_private *priv = netdev_priv(ndev);
>>> +    int error = -ENODEV;
>>> +    unsigned long flags;
>>> +
>>> +    if (priv->phydev) {
> 
>> Is checking against priv->phydev really necessary, it does not look like
>> the driver will work or accept an invalid PHY device at all anyway?
> 
>    You still can run 'ethtool' on a closed network device.

Sure, but that does not mean that priv->phydev becomes NULL, even if you
have called phy_disconnect() in your ndo_close() function, you should
still have a correct priv->phydev reference to the PHY device, no?

> 
> [...]
> 
>>> +/* Network device open function for Ethernet AVB */
>>> +static int ravb_open(struct net_device *ndev)
>>> +{
>>> +    struct ravb_private *priv = netdev_priv(ndev);
>>> +    int error;
>>> +
>>> +    napi_enable(&priv->napi);
>>> +
>>> +    error = request_irq(ndev->irq, ravb_interrupt, IRQF_SHARED,
>>> ndev->name,
>>> +                ndev);
>>> +    if (error) {
>>> +        netdev_err(ndev, "cannot request IRQ\n");
>>> +        goto out_napi_off;
>>> +    }
>>> +
>>> +    /* Descriptor set */
>>> +    /* +26 gets the maximum ethernet encapsulation, +7 & ~7 because the
>>> +     * card needs room to do 8 byte alignment, +2 so we can reserve
>>> +     * the first 2 bytes, and +16 gets room for the status word from
>>> the
>>> +     * card.
>>> +     */
>>> +    priv->rx_buffer_size = (ndev->mtu <= 1492 ? PKT_BUF_SZ :
>>> +                (((ndev->mtu + 26 + 7) & ~7) + 2 + 16));
> 
>> Is not that something that should be moved to a local ndo_change_mtu()
> 
>    That was copied from sh_eth.c verbatim, I even doubt that the formula
> is correct for EtherAVB...
> 
>> function? What happens if I change the MTU of an interface running, does
>> not that completely break this RX buffer estimation?
> 
>    Well, not completely, I think. eth_change_mtu() doesn't allow MTU >
> 1500 bytes, so it looks like we just need to change 1492 to 1500 here.
> 
> [...]
> 
>>> +static int ravb_start_xmit(struct sk_buff *skb, struct net_device
>>> *ndev)
>>> +{
>>> +    struct ravb_private *priv = netdev_priv(ndev);
>>> +    struct ravb_tstamp_skb *ts_skb = NULL;
>>> +    struct ravb_tx_desc *desc;
>>> +    unsigned long flags;
>>> +    void *buffer;
>>> +    u32 entry;
>>> +    u32 tccr;
>>> +    int q;
>>> +
>>> +    /* If skb needs TX timestamp, it is handled in network control
>>> queue */
>>> +    q = (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) ? RAVB_NC :
>>> RAVB_BE;
>>> +
>>> +    spin_lock_irqsave(&priv->lock, flags);
>>> +    if (priv->cur_tx[q] - priv->dirty_tx[q] >= priv->num_tx_ring[q]
>>> - 4) {
> 
>> What's so special about 4 here, you don't seem to be using 4 descriptors
> 
>    Not sure, this was clearly copied from sh_eth.c. Perhaps it's just a
> threshold for calling ravb_tx_free()...

Then 1 inclusive or 0 exclusive is probably what you should be comparing
to, otherwise you may just stop the tx queue earlier than needed.

> 
>>> +        if (!ravb_tx_free(ndev, q)) {
>>> +            netif_warn(priv, tx_queued, ndev, "TX FD exhausted.\n");
>>> +            netif_stop_queue(ndev);
>>> +            spin_unlock_irqrestore(&priv->lock, flags);
>>> +            return NETDEV_TX_BUSY;
>>> +        }
>>> +    }
>>> +    entry = priv->cur_tx[q] % priv->num_tx_ring[q];
>>> +    priv->cur_tx[q]++;
>>> +    spin_unlock_irqrestore(&priv->lock, flags);
>>> +
>>> +    if (skb_put_padto(skb, ETH_ZLEN))
>>> +        return NETDEV_TX_OK;
>>> +
>>> +    priv->tx_skb[q][entry] = skb;
>>> +    buffer = PTR_ALIGN(priv->tx_buffers[q][entry], RAVB_ALIGN);
>>> +    memcpy(buffer, skb->data, skb->len);
> 
>> ~1500 bytes memcpy(), not good...
> 
>    I'm looking in the manual and not finding the hard requirement to
> have the buffer address aligned to 128 bytes (RAVB_ALIGN), sigh...
> Kimura-san?
> 
>>> +    desc = &priv->tx_ring[q][entry];
> 
>> Since we have released the spinlock few lines above, is there something
>> protecting ravb_tx_free() from concurrently running with this xmit()
>> call and trashing this entry?
> 
>    Probably nothing... :-)
> 
>>> +    desc->ds = skb->len;
>>> +    desc->dptr = dma_map_single(&ndev->dev, buffer, skb->len,
>>> +                    DMA_TO_DEVICE);
>>> +    if (dma_mapping_error(&ndev->dev, desc->dptr)) {
>>> +        dev_kfree_skb_any(skb);
>>> +        priv->tx_skb[q][entry] = NULL;
> 
>> Don't you need to make sure this NULL is properly seen by ravb_tx_free()?
> 
>    You mean doing this before releasing the spinlock? Or what?

Yes, the locking your transmit function seems to open windows during
which it is possible for the interrupt handler running on another CPU to
mess up with the data you are using here.
--
Florian
