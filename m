From: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: Re: [PATCH 3/3] net: hisilicon: Add Fast Ethernet MAC driver
Date: Tue, 28 Jun 2016 17:21:19 +0800
Message-ID: <5772418F.9040101@hisilicon.com>
References: <1465798076-176393-1-git-send-email-lidongpo@hisilicon.com>
 <4004629.ilZU8AvAjF@wuerfel> <576003F8.3090000@hisilicon.com>
 <247637090.PhpfAhp4VJ@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <247637090.PhpfAhp4VJ@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2016/6/15 5:20, Arnd Bergmann wrote:
> On Tuesday, June 14, 2016 9:17:44 PM CEST Li Dongpo wrote:
>> On 2016/6/13 17:06, Arnd Bergmann wrote:
>>> On Monday, June 13, 2016 2:07:56 PM CEST Dongpo Li wrote:
>>> You tx function uses BQL to optimize the queue length, and that
>>> is great. You also check xmit reclaim for rx interrupts, so
>>> as long as you have both rx and tx traffic, this should work
>>> great.
>>>
>>> However, I notice that you only have a 'tx fifo empty'
>>> interrupt triggering the napi poll, so I guess on a tx-only
>>> workload you will always end up pushing packets into the
>>> queue until BQL throttles tx, and then get the interrupt
>>> after all packets have been sent, which will cause BQL to
>>> make the queue longer up to the maximum queue size, and that
>>> negates the effect of BQL.
>>>
>>> Is there any way you can get a tx interrupt earlier than
>>> this in order to get a more balanced queue, or is it ok
>>> to just rely on rx packets to come in occasionally, and
>>> just use the tx fifo empty interrupt as a fallback?
>>>
>> In tx direction, there are only two kinds of interrupts, 'tx fifo empty'
>> and 'tx one packet finish'. I didn't use 'tx one packet finish' because
>> it would lead to high hardware interrupts rate. This has been verified in
>> our chips. It's ok to just use tx fifo empty interrupt.
> 
> I'm not convinced by the explanation, I don't think that has anything
> to do with the hardware design, but instead is about the correctness
> of the BQL logic with your driver.
> 
> Maybe your xmit function can do something like
> 
> 	if (dql_avail(netdev_get_tx_queue(dev, 0)->dql) < 0)
> 		enable per-packet interrupt
> 	else
> 		use only fifo-empty interrupt
> 
> That way, you don't get a lot of interrupts when the system is
> in a state of packets being received and sent continuously,
> but if you get to the point where your tx queue fills up
> and no rx interrupts arrive, you don't have to wait for it
> to become completely empty before adding new packets, and
> BQL won't keep growing the queue.
> 
Hi, Arnd
I tried enable per-packet interrupt when tx queue full in xmit function
and disable it in NAPI poll. But the number of interrupts are a little
bigger than only using fifo-empty interrupt.
The other hand, this is a fast ethernet MAC. Its maximum speed is 100Mbps.
This speed is very easily achived and the efficiency of the BQL is not
so important. What we focus on is the lower cpu utilization.
So I think it is okay to just use the tx fifo empty interrupt.

>>>> +    priv->phy_mode = of_get_phy_mode(node);
>>>> +    if (priv->phy_mode < 0) {
>>>> +            dev_err(dev, "not find phy-mode\n");
>>>> +            ret = -EINVAL;
>>>> +            goto out_disable_clk;
>>>> +    }
>>>> +
>>>> +    priv->phy_node = of_parse_phandle(node, "phy-handle", 0);
>>>> +    if (!priv->phy_node) {
>>>> +            dev_err(dev, "not find phy-handle\n");
>>>> +            ret = -EINVAL;
>>>> +            goto out_disable_clk;
>>>> +    }
>>>> +
>>>> +    priv->phy = of_phy_connect(ndev, priv->phy_node,
>>>> +                               hisi_femac_adjust_link, 0, priv->phy_mode);
>>>> +    if (!(priv->phy) || IS_ERR(priv->phy)) {
>>>> +            dev_err(dev, "connect to PHY failed!\n");
>>>> +            ret = -ENODEV;
>>>> +            goto out_phy_node;
>>>> +    }
>>>
>>> I wonder if we could generalize this set of three calls, I
>>> get the impression that we duplicate this across several
>>> drivers that shouldn't need to bother with the specific
>>> phy-handle and phy-mode properties.
>>>
>> Some drivers only call 'of_phy_connect' when ndo_open called,
>> some call when driver probed. But 'phy_mode' and 'phy_node' are
>> usually initialized when driver probed.
>> So I think it's not suitable to combine 'of_phy_connect' with
>> 'of_get_phy_mode' and 'of_parse_phandle'.
>> Do you have any more suggestions ?
> 
> My idea was to add another interface that drivers could optionally
> call if they use the logic that you have here, but other drivers
> could keep using the plain of_phy_connect.
> 
> Anyway, this was just an idea, it's not important.
> 
> 	Arnd
> 
> .
> 

    Regards,
    Dongpo

.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
