From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/3] net: stmmac: change GMAC control register for SGMII
Date: Tue, 04 Dec 2012 13:34:48 +0100
Message-ID: <50BDEDE8.4030105@st.com>
References: <004b01cdc959$80af8030$820e8090$%an@samsung.com> <50B344FC.4070405@st.com> <009401cdcd57$18b275d0$4a176170$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, kgene.kim@samsung.com,
	linux-kernel@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <009401cdcd57$18b275d0$4a176170$%an@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/28/2012 11:57 AM, Byungho An wrote:
> On 11/26/2012 07:31 PM, Giuseppe CABALLARO wrote:
>> On 11/23/2012 10:04 AM, Byungho An wrote:
>>>
>>> This patch changes GMAC control register (TC(Transmit
>>> Configuration) and PS(Port Selection) bit for SGMII.
>>> In case of SGMII, TC bit is '1' and PS bit is 0.
>>
>> IMO this new support that should be released for net-next and further
>> effort is actually needed.
>>
> OK, I see but if possible, I want to support the new features which is
> included in this patch from v3.8

ok I agree and I can support you.

>
>> The availability of the PCS registers is given by looking at the HW
>> feature register. In fact, these are optional registers.
>> I don't want to break the compatibility with old chips.
>>
> It means that old chip doesn't have this bit or this register? If that, how
> about using compatible in DT blob like snps,dwmac-3.70a and then in just
> this case trying to read this bit and this register.

The driver also works on mac 10/100 Databook 2.0 that has not these 
registers.

>> I do not see why we have to use Kconfig macro to select ANE etc (as
>> you do in your patches).
> OK. I agree with you.

we have to use the HW feature reg.

>
>> The driver could directly manage the phy device by itself if possible
>> and the stmmac_init_phy should be reworked.
>>
> Could you explain more detail? As I understood, after set ANE bit in MAC
> side then PHY auto-negotiation can be enabled. If I'm wrong let me know.
> According to your mention, MAC and PHY auto-negotiation can be managed in
> stmmac_init_phy?

Currently the driver uses the Physical Abstraction Layer (PAL) to dialog 
with a PHY. On all the platforms supported (not only ST) we have always 
used it. Personally, I tested several phy devices with different MII 
interfaces (MII/RMII/GMII/RGMII ... ) but not TBI/RTBI/SGMII interfaces.

>> There are several things that need to be implemented. For example:
>>
>> The ISR (e.g. priv->hw->mac->host_irq_status) should be able to manage
>> these new interrupts.
> I think that there would be two additional interrupts."PCS Auto-Negotiation
> Complete" and "PCS Link Status Changed". These two interrupts are added to
> "stmmac_interrupt". In my opinion, there are no specific processing for
> these two irqs. What do you think about it?

if the link changes this has to be logged in the driver.
For example, depending on the link speed on some platforms we need to 
call dedicated call-back to set sysconfig registers or custom clocks.

>> The code has to be able to maintain the user interface.
>> For example if you want to enable ANE or manage Advertisement caps.
>>
> Does it mean that command line or other network command(e.g. ifconfig...) or
> ioctol? Actually I don't understand exact user interface way. Could you
> recommend the method for user interface?

Using ethtool or mii-tool the user want to know the link status. So 
these kind of information have to be maintained.

Take a look at the stmmac_adjust_link that is called by the PAL.

>>> Signed-off-by: Byungho An <bh74.an@samsung.com>
>>> ---
>>
>> [snip]
>>
>>> +	if (priv->phydev->interface == PHY_INTERFACE_MODE_SGMII) {
>>> +		value = readl(priv->ioaddr);
>>> +		/* GMAC_CONTROL_TC : transmit config in RGMII/SGMII */
>>> +		value |= 0x1000000;
>>> +		/* GMAC_CONTROL_PS : Port Selection for GMII */
>>> +		value &= ~(0x8000);
>>> +		writel(value, priv->ioaddr);
>>> +	}
>>> +
>>
>>
>> This parts of code have to be moved in
>> drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>>
> OK.
>
>> Pls, do not use value |= 0x1000000 but provide the appropriate defines.
>>
> OK.
>
>>>    	/* Request the IRQ lines */
>>>    	ret = request_irq(dev->irq, stmmac_interrupt,
>>>    			 IRQF_SHARED, dev->name, dev);
>>>
> Thank you.

you are welcome
Peppe

> Byungho An.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
