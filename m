From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Fri, 24 Apr 2015 21:53:23 +0300
Message-ID: <553A9123.3010906@cogentembedded.com>
References: <32501816.HtkLenWQpn@wasted.cogentembedded.com> <552C4554.2070608@gmail.com> <552D8898.3060905@cogentembedded.com> <55382D4E.5070708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Ben Hutchings <ben.hutchings@codethink.co.uk>
To: Florian Fainelli <f.fainelli@gmail.com>, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <55382D4E.5070708@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/23/2015 02:22 AM, Florian Fainelli wrote:

[...]

>>>> +    if (ecmd->duplex == DUPLEX_FULL)
>>>> +        priv->duplex = 1;
>>>> +    else
>>>> +        priv->duplex = 0;

>>> Why not use what priv->phydev->duplex has cached for you?

>>     Because we compare 'priv->duplex' with 'priv->phydev->duplex' in
>> ravb_adjust_link(). Or what did you mean?

> Oh I see how you are using this now, but it does not look like it is
> necessary, since you use phy_ethtool_sset() using phydev->duplex

   It only writes to it, doesn't use it AFAICS...

> directly ought to be enough anywhere in your driver?

    'priv->phydev' is NULL when the device is closed, so I just can't call 
phy_ethtool_sset().

> Unless there is a
> mode where you are running PHY-less, and not using a fixed PHY to
> emulate a PHY...

    No such mode.

>> [...]

>>>> +static int ravb_nway_reset(struct net_device *ndev)
>>>> +{
>>>> +    struct ravb_private *priv = netdev_priv(ndev);
>>>> +    int error = -ENODEV;
>>>> +    unsigned long flags;
>>>> +
>>>> +    if (priv->phydev) {

>>> Is checking against priv->phydev really necessary, it does not look like
>>> the driver will work or accept an invalid PHY device at all anyway?

    This check was copied from sh_eth that was fixed by Ben ot to crash due to
'ethtool' being called on closed device, see:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/net/ethernet/renesas/sh_eth.c?id=4f9dce230b32eec45cec8c28cae61efdfa2f7d57

    That commit refers to a dangling pointer, not sure what does this mean...
The PHy device doesn't seem to be freed by phy_disconnect(). Ben?

>>     You still can run 'ethtool' on a closed network device.

> Sure, but that does not mean that priv->phydev becomes NULL, even if you

    It does with 'sh_eth' and hence with 'ravb' too.

> have called phy_disconnect() in your ndo_close() function, you should
> still have a correct priv->phydev reference to the PHY device, no?

    PHY device is returned by of_phy_connect() each time the device is opened, 
see ravb_phy_init().
    We could indeed remove NULLifying 'priv->phydev' from ravb_close() though, 
needs testing...

[...]

>>>> +static int ravb_start_xmit(struct sk_buff *skb, struct net_device
>>>> *ndev)
>>>> +{
>>>> +    struct ravb_private *priv = netdev_priv(ndev);
>>>> +    struct ravb_tstamp_skb *ts_skb = NULL;
>>>> +    struct ravb_tx_desc *desc;
>>>> +    unsigned long flags;
>>>> +    void *buffer;
>>>> +    u32 entry;
>>>> +    u32 tccr;
>>>> +    int q;
>>>> +
>>>> +    /* If skb needs TX timestamp, it is handled in network control
>>>> queue */
>>>> +    q = (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) ? RAVB_NC :
>>>> RAVB_BE;
>>>> +
>>>> +    spin_lock_irqsave(&priv->lock, flags);
>>>> +    if (priv->cur_tx[q] - priv->dirty_tx[q] >= priv->num_tx_ring[q]
>>>> - 4) {

>>> What's so special about 4 here, you don't seem to be using 4 descriptors

>>     Not sure, this was clearly copied from sh_eth.c. Perhaps it's just a
>> threshold for calling ravb_tx_free()...

> Then 1 inclusive or 0 exclusive is probably what you should be comparing
> to, otherwise you may just stop the tx queue earlier than needed.

    Will look into this...

[...]

>>>> +    desc->ds = skb->len;
>>>> +    desc->dptr = dma_map_single(&ndev->dev, buffer, skb->len,
>>>> +                    DMA_TO_DEVICE);
>>>> +    if (dma_mapping_error(&ndev->dev, desc->dptr)) {
>>>> +        dev_kfree_skb_any(skb);
>>>> +        priv->tx_skb[q][entry] = NULL;

>>> Don't you need to make sure this NULL is properly seen by ravb_tx_free()?

>>     You mean doing this before releasing the spinlock? Or what?

> Yes, the locking your transmit function seems to open windows during
> which it is possible for the interrupt handler running on another CPU to
> mess up with the data you are using here.

    Will look into that too...

> --
> Florian

WBR, Sergei

