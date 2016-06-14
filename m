From: Li Dongpo <lidongpo@hisilicon.com>
Subject: Re: [PATCH 3/3] net: hisilicon: Add Fast Ethernet MAC driver
Date: Tue, 14 Jun 2016 21:17:44 +0800
Message-ID: <576003F8.3090000@hisilicon.com>
References: <1465798076-176393-1-git-send-email-lidongpo@hisilicon.com>
 <1465798076-176393-4-git-send-email-lidongpo@hisilicon.com>
 <4004629.ilZU8AvAjF@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <f.fainelli@gmail.com>, <robh+dt@kernel.org>,
	<mark.rutland@arm.com>, <davem@davemloft.net>,
	<xuejiancheng@hisilicon.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4004629.ilZU8AvAjF@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/6/13 17:06, Arnd Bergmann wrote:
> On Monday, June 13, 2016 2:07:56 PM CEST Dongpo Li wrote:
> 
>> +- reset-names: should contain the reset signal name "mac_reset"(required)
>> +	and "phy_reset"(optional).
> 
> Maybe just name the resets 'mac' and 'phy'? The '_reset' part is
> implied by the property.
> 
Hi, Arnd,
Thank you for your advice. It's ok to omit the '_reset', I'll fix it in next version.

> I gave the driver a brief review and basically everything looks
> great, very nice work!
> 
> There are two small things that I noticed:
> 
>> +
>> +       do {
>> +               hisi_femac_xmit_reclaim(dev);
>> +               num = hisi_femac_rx(dev, task);
>> +               work_done += num;
>> +               task -= num;
>> +               if ((work_done >= budget) || (num == 0))
>> +                       break;
>> +
>> +               ints = readl(priv->glb_base + GLB_IRQ_STAT);
>> +               writel(ints & DEF_INT_MASK,
>> +                      priv->glb_base + GLB_IRQ_RAW);
>> +       } while (ints & DEF_INT_MASK);
>> +
>> +       if (work_done < budget) {
>> +               napi_complete(napi);
>> +               hisi_femac_irq_enable(priv, DEF_INT_MASK);
>> +       }
> 
> You tx function uses BQL to optimize the queue length, and that
> is great. You also check xmit reclaim for rx interrupts, so
> as long as you have both rx and tx traffic, this should work
> great.
> 
> However, I notice that you only have a 'tx fifo empty'
> interrupt triggering the napi poll, so I guess on a tx-only
> workload you will always end up pushing packets into the
> queue until BQL throttles tx, and then get the interrupt
> after all packets have been sent, which will cause BQL to
> make the queue longer up to the maximum queue size, and that
> negates the effect of BQL.
> 
> Is there any way you can get a tx interrupt earlier than
> this in order to get a more balanced queue, or is it ok
> to just rely on rx packets to come in occasionally, and
> just use the tx fifo empty interrupt as a fallback?
> 
In tx direction, there are only two kinds of interrupts, 'tx fifo empty'
and 'tx one packet finish'. I didn't use 'tx one packet finish' because
it would lead to high hardware interrupts rate. This has been verified in
our chips. It's ok to just use tx fifo empty interrupt.

>> +	priv->phy_mode = of_get_phy_mode(node);
>> +	if (priv->phy_mode < 0) {
>> +		dev_err(dev, "not find phy-mode\n");
>> +		ret = -EINVAL;
>> +		goto out_disable_clk;
>> +	}
>> +
>> +	priv->phy_node = of_parse_phandle(node, "phy-handle", 0);
>> +	if (!priv->phy_node) {
>> +		dev_err(dev, "not find phy-handle\n");
>> +		ret = -EINVAL;
>> +		goto out_disable_clk;
>> +	}
>> +
>> +	priv->phy = of_phy_connect(ndev, priv->phy_node,
>> +				   hisi_femac_adjust_link, 0, priv->phy_mode);
>> +	if (!(priv->phy) || IS_ERR(priv->phy)) {
>> +		dev_err(dev, "connect to PHY failed!\n");
>> +		ret = -ENODEV;
>> +		goto out_phy_node;
>> +	}
> 
> I wonder if we could generalize this set of three calls, I
> get the impression that we duplicate this across several
> drivers that shouldn't need to bother with the specific
> phy-handle and phy-mode properties.
> 
Some drivers only call 'of_phy_connect' when ndo_open called,
some call when driver probed. But 'phy_mode' and 'phy_node' are
usually initialized when driver probed.
So I think it's not suitable to combine 'of_phy_connect' with
'of_get_phy_mode' and 'of_parse_phandle'.
Do you have any more suggestions ?

> 	Arnd
> 
> 
> .
> 
	Regards,
	Dongpo


.
