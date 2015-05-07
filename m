From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Fri, 08 May 2015 00:10:36 +0300
Message-ID: <554BD4CC.3020308@cogentembedded.com>
References: <32501816.HtkLenWQpn@wasted.cogentembedded.com> <552C4554.2070608@gmail.com> <552D8898.3060905@cogentembedded.com> <55382D4E.5070708@gmail.com> <553A9123.3010906@cogentembedded.com>
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
In-Reply-To: <553A9123.3010906@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/24/2015 09:53 PM, Sergei Shtylyov wrote:

[...]

>>>>> +static int ravb_start_xmit(struct sk_buff *skb, struct net_device
>>>>> *ndev)
>>>>> +{
>>>>> +    struct ravb_private *priv = netdev_priv(ndev);
>>>>> +    struct ravb_tstamp_skb *ts_skb = NULL;
>>>>> +    struct ravb_tx_desc *desc;
>>>>> +    unsigned long flags;
>>>>> +    void *buffer;
>>>>> +    u32 entry;
>>>>> +    u32 tccr;
>>>>> +    int q;
>>>>> +
>>>>> +    /* If skb needs TX timestamp, it is handled in network control
>>>>> queue */
>>>>> +    q = (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) ? RAVB_NC :
>>>>> RAVB_BE;
>>>>> +
>>>>> +    spin_lock_irqsave(&priv->lock, flags);
>>>>> +    if (priv->cur_tx[q] - priv->dirty_tx[q] >= priv->num_tx_ring[q]
>>>>> - 4) {

>>>> What's so special about 4 here, you don't seem to be using 4 descriptors

>>>     Not sure, this was clearly copied from sh_eth.c. Perhaps it's just a
>>> threshold for calling ravb_tx_free()...
>
>> Then 1 inclusive or 0 exclusive is probably what you should be comparing
>> to, otherwise you may just stop the tx queue earlier than needed.

>     Will look into this...

     OK, I've fixed this.

[...]

>>>>> +    desc->ds = skb->len;
>>>>> +    desc->dptr = dma_map_single(&ndev->dev, buffer, skb->len,
>>>>> +                    DMA_TO_DEVICE);
>>>>> +    if (dma_mapping_error(&ndev->dev, desc->dptr)) {
>>>>> +        dev_kfree_skb_any(skb);
>>>>> +        priv->tx_skb[q][entry] = NULL;

>>>> Don't you need to make sure this NULL is properly seen by ravb_tx_free()?

>>>     You mean doing this before releasing the spinlock? Or what?

>> Yes, the locking your transmit function seems to open windows during
>> which it is possible for the interrupt handler running on another CPU to
>> mess up with the data you are using here.

>     Will look into that too...

    I have looked into the code and I must admit I don't understand how the 
data can be messed up with. ravb_tx_free() only advances 'priv->dirty_tx' and 
doesn't go beyond (or change) 'priv->cur_tx' which is used here...

>> --
>> Florian

WBR, Sergei

