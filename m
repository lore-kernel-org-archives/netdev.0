From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net-next 1/3] net: stmmac: add gmac autoneg set for SGMII,
 TBI, and RTBI
Date: Wed, 23 Jan 2013 10:42:44 +0100
Message-ID: <50FFB094.5000100@st.com>
References: <00c001cdf369$9b25bdf0$d17139d0$@samsung.com> <50F6568D.3060703@st.com> <01e201cdf5a3$1f3e1890$5dba49b0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	kgene.kim@samsung.com, cpgs@samsung.com
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <01e201cdf5a3$1f3e1890$5dba49b0$@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Byungho

On 1/18/2013 6:41 PM, Byungho An wrote:
> Hello Peppe,
>
> On 1/15/2013 11:28 PM, Giuseppe CAVALLARO write:
>> On 1/15/2013 10:45 PM, Byungho An wrote:
>>>
>>> This patch adds gmac autoneg set function for SGMII, TBI, or RTBI
>>> interface. In case of PHY's autoneg is set, gmac's autoneg enable bit
>>> should set. After checking phy's autoneg if phydev's autoneg is '1'
>>> gmac's ANE bit set for those interface.
>>
>> Sorry I've some doubts about these patches.
>>
>> Firstly if the MAC is able to manage RGMII/SGMII etc this should be
> verified
>> by looking at the HW cap register: i.e. PCS bit.
>>
>>     (I have no HW that support this so I cannot do any tests).
>>
> I agree with you and actually I tried to use a PCS bit previously.
> (PCS bit indicates TBI, SGMII, or RTBI PHY interface)
> But I was confused which one I should use among PSC, ACTPHYIF or phydev to
> recognize the interface.
> At this time, I want to add auto-negotiation enable because sgmii interface
> is not working without ANE using PCS bit(in H/W feature register).
>

really strange, from the synopsys databook we should only look at the RO 
bit in the HW cap reg just to understand if the feature is supported.

>> In case of this feature is actually supported then the driver could manage
>> everything bypassing the MDIO.
>> IMO, we could not need to call the stmmac_phy_init and we should not use
>> the PHYLIB.
>> I mean if we have the PCS module we could have a minimal support to get
>> link status, restart ANE etc w/o using at all the PHYLIB (so w/o touching
> the
>> PHY regs via the MDIO/MDC).
>>
> Yes. For example SGMII/RGMII/SMII Status Register is useful to know status
> so we can use this register to manage status of SGMII/RGMII/SMII
>
>
>>     It could also be useful to complete the support with the RGMII... no
>>     extra effort should be needed while adding SGMII if you look at the
>>     core registers.
>>     If you add the RGMII on some platforms we could guarantee to manage
>>     the fix_mac_speed (see stmmac doc).
>>
> Unfortunately I have only the SGMII.

no problem, I'll complete it by my hand later.

>
>> Looking at the other your patches, the ethtool support is not completed. I
>> expected to restart ANE, get/set link property etc.
>>
> What is link property? It means link up, speed and duplex mode.
> Are there anything else?
> I think get link property is already working using ethtool.
> In case of SGMII/RGMII/SMII, I think we can use SGMII/RGMII/SMII Status
> Register for link status.
>
> I have a question regarding it.
> In the mainline code, there is hardcode interrupt mask in
> dwmac1000_core_init function.
> When I try to get interrupt for link change, interrupt is not occurred
> because of this mask.
> Can we modify that?

yes you can. I had wrote an initial patch that started doing something.
I have tested it on my boards and I can send it to the mailing list to 
be reviewed. Maybe you can build your patch on top of it.

>> Also pay attention to properly treat EEE. Maybe, as first stage we should
>> disable the feature in this case. We will see it later.
>> The question is that we could not be able to use some extra features that
>> currently need to dialog more with the PHY device. I mean what we actually
>> do by using PHYLIB.
> OK. As I understood, using gmac register instead of phydev or phylib...
> I agree. In my opinion gmac and phy communicate using mdio each other, after
> that gmac can get updated status.

yep, this is the point :-)

>>
>>>
>>> Signed-off-by: Byungho An <bh74.an@samsung.com>
>>> ---
>>>    drivers/net/ethernet/stmicro/stmmac/common.h         |    1 +
>>>    drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c |   11
>> +++++++++++
>>>    drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |    9 +++++++++
>>>    3 files changed, 21 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h
>>> b/drivers/net/ethernet/stmicro/stmmac/common.h
>>> index 186d148..72ba769 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
>>> @@ -344,6 +344,7 @@ struct stmmac_ops {
>>>    	void (*reset_eee_mode) (void __iomem *ioaddr);
>>>    	void (*set_eee_timer) (void __iomem *ioaddr, int ls, int tw);
>>>    	void (*set_eee_pls) (void __iomem *ioaddr, int link);
>>> +	void (*set_autoneg) (void __iomem *ioaddr);
>>>    };
>>>
>>>    struct mac_link {
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>>> b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>>> index bfe0226..a0737b39 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>>> @@ -297,6 +297,16 @@ static void  dwmac1000_set_eee_timer(void
>> __iomem
>>> *ioaddr, int ls, int tw)
>>>    	writel(value, ioaddr + LPI_TIMER_CTRL);
>>>    }
>>>
>>> +static void dwmac1000_set_autoneg(void __iomem *ioaddr) {
>>> +	u32 value;
>>> +
>>> +	value = readl(ioaddr + GMAC_AN_CTRL);
>>> +	value |= 0x1000;
>>
>> pls use define instead of raw values ... see below.
>>
>>> +	writel(value, ioaddr + GMAC_AN_CTRL); }
>>> +
>>> +
>>>    static const struct stmmac_ops dwmac1000_ops = {
>>>    	.core_init = dwmac1000_core_init,
>>>    	.rx_ipc = dwmac1000_rx_ipc_enable,
>>> @@ -311,6 +321,7 @@ static const struct stmmac_ops dwmac1000_ops = {
>>>    	.reset_eee_mode =  dwmac1000_reset_eee_mode,
>>>    	.set_eee_timer =  dwmac1000_set_eee_timer,
>>>    	.set_eee_pls =  dwmac1000_set_eee_pls,
>>> +	.set_autoneg =  dwmac1000_set_autoneg,
>>>    };
>>>
>>>    struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr) diff
>>> --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> index f07c061..3e28934 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> @@ -1007,6 +1007,7 @@ static int stmmac_open(struct net_device *dev)
>>>    {
>>>    	struct stmmac_priv *priv = netdev_priv(dev);
>>>    	int ret;
>>> +	int interface = priv->plat->interface;
>>>
>>>    	clk_prepare_enable(priv->stmmac_clk);
>>>
>>> @@ -1041,6 +1042,14 @@ static int stmmac_open(struct net_device *dev)
>>>    	/* Initialize the MAC Core */
>>>    	priv->hw->mac->core_init(priv->ioaddr);
>>>
>>> +	/* If phy autoneg is on, set gmac autoneg for SGMII, TBI and RTBI*/
>>> +	if (interface == PHY_INTERFACE_MODE_SGMII ||
>>> +	    interface == PHY_INTERFACE_MODE_TBI ||
>>> +	    interface == PHY_INTERFACE_MODE_RTBI) {
>>> +		if (priv->phydev->autoneg)
>>> +			priv->hw->mac->set_autoneg(priv->ioaddr);
>>> +	}
>>
>> we could use the following instead of priv->hw->mac->set_autoneg:
>>
>> static void dwmac1000_ctrl_ane(void __iomem *ioaddr, bool restart) {
>>       int value = GMAC_CTRL_ANE_EN;
>>
>>       if (restart)
>>           value |= GMAC_CTRL_ANE_RESTART;
>>
>>       writel(value, ioaddr +GMAC_AN_CTRL); }
>>
>> where we should defines all the missing macros for the registers 48, 49
> ...
> Actually I tested this code for restart autonegotiation, but even though I
> changed link (1Gb -> 100Mb) phy's link is not changed.
> For more detail, first time 1Gb I changed the link during system working and
> then check speed using ethtool/mii-tool.
> I think phy also should do autonegotiation (I'm not sure this is just for
> the SGMII). Without phy auto negotiation  gmac is not working.
>
> OK, I'll try to check functionality and make macros.
> Anyway as a first step, I want to complete to the code regarding ANE (ctrl
> function, macros, ethtool support for link status etc..)
> I'll send new code before making patch soon.

thanks you

>>
>> /* RGMI/SGMII defines */
>> #define GMAC_CTRL_ANE_SGMII_RAL (1 << 18)
>> #define GMAC_CTRL_ANE_EN       (1 << 12)
>> #define GMAC_CTRL_ANE_RESTART  (1 << 9)
>>
>> The handler should store the link status that will be used to pass the
> info to
>> the ethtool for example. We need to manage speed and duplex etc.
>>
>> What happens if you run "ethtool eth0" command?
>> Or if you run mii-tool?
>> I expect to get the right speed and duplex at least.
> So far, I can get right data speed and duplex and autoneg.
>
>>
>> Concerning the stmmac_set_pauseparam I'm also not sure you are doing the
>> right thing. Note that you are not restarting the ANE at all ... (this is
> what the
>> phy_start_aneg does). If set the bit 12 then you are enabling the ane. To
>> restart it, you need to set the bit 9 in the reg 48.
>>
>> I can support you on all the points above. Let me know.
>>
>> BR,
>> peppe
>>
> OK, thank you and happy new year.

Also to you :-)

let me know for any progresses etc.

Peppe

> Byungho An
>
>>> +
>>>    	/* Request the IRQ lines */
>>>    	ret = request_irq(dev->irq, stmmac_interrupt,
>>>    			 IRQF_SHARED, dev->name, dev);
>>>
>
>
>
