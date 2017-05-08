From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: ethernet: stmmac: properly set PS bit in MII
 configurations during reset
Date: Mon, 8 May 2017 16:28:21 +0200
Message-ID: <49297ed2-84dc-3e9b-8f40-af915476a091@st.com>
References: <1493286329-24448-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <deea272a-f0a9-ad0b-4ad6-387723938314@st.com> <20170503143032.GA22106@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170503143032.GA22106@Red>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

On 5/3/2017 4:30 PM, Corentin Labbe wrote:
> On Wed, May 03, 2017 at 10:13:56AM +0200, Giuseppe CAVALLARO wrote:
>> Hello Thomas
>>
>> this was initially set by using the hw->link.port; both the core_init
>> and adjust callback
>> should invoke the hook and tuning the PS bit according to the speed and
>> mode.
>> So maybe the ->set_ps is superfluous and you could reuse the existent hook
>>
>> let me know
>>
>> Regards
>> peppe
>>
> I just see that GMAC_CONTROL and MAC_CTRL_REG are the same, so why not create a custom adjust_link for each dwmac type ?
> This will permit to call it instead of set_ps() and remove lots of if (has_gmac) and co in stmmac_adjust_link()
> Basicly replace all between "ctrl = readl()... and writel(ctrl)" by a sot of priv->hw->mac->adjust_link()
>
> It will also help a lot for my dwmac-sun8i inclusion (since I add some if has_sun8i:))

Corentin, I think this is a good idea and maybe necessary now that the 
driver is supporting a lot of chips.
In the past it was sufficient to have a adjust link function and a 
stmmac_hw_fix_mac_speed
to invoke dedicated hook shared between MAC10/100 and GMAC inside STM 
platforms.

Thomas, I wonder if you could take a look at the 
priv->plat->fix_mac_speed. This can be used
for setting internal registers too.

Regards
Peppe

>
> Regards
>
>> On 4/27/2017 11:45 AM, Thomas Petazzoni wrote:
>>> On the SPEAr600 SoC, which has the dwmac1000 variant of the IP block,
>>> the DMA reset never succeeds when a MII PHY is used (no problem with a
>>> GMII PHY). The dwmac_dma_reset() function sets the
>>> DMA_BUS_MODE_SFT_RESET bit in the DMA_BUS_MODE register, and then
>>> polls until this bit clears. When a MII PHY is used, with the current
>>> driver, this bit never clears and the driver therefore doesn't work.
>>>
>>> The reason is that the PS bit of the GMAC_CONTROL register should be
>>> correctly configured for the DMA reset to work. When the PS bit is 0,
>>> it tells the MAC we have a GMII PHY, when the PS bit is 1, it tells
>>> the MAC we have a MII PHY.
>>>
>>> Doing a DMA reset clears all registers, so the PS bit is cleared as
>>> well. This makes the DMA reset work fine with a GMII PHY. However,
>>> with MII PHY, the PS bit should be set.
>>>
>>> We have identified this issue thanks to two SPEAr600 platform:
>>>
>>>    - One equipped with a GMII PHY, with which the existing driver was
>>>      working fine.
>>>
>>>    - One equipped with a MII PHY, where the current driver fails because
>>>      the DMA reset times out.
>>>
>>> This patch fixes the problem for the MII PHY configuration, and has
>>> been tested with a GMII PHY configuration as well.
>>>
>>> In terms of implement, since the ->reset() hook is implemented in the
>>> DMA related code, we do not want to touch directly from this function
>>> the MAC registers. Therefore, a ->set_ps() hook has been added to
>>> stmmac_ops, which gets called between the moment the reset is asserted
>>> and the polling loop waiting for the reset bit to clear.
>>>
>>> In order for this ->set_ps() hook to decide what to do, we pass it the
>>> "struct mac_device_info" so it can access the MAC registers, and the
>>> PHY interface type so it knows if we're using a MII PHY or not.
>>>
>>> The ->set_ps() hook is only implemented for the dwmac1000 case.
>>>
>>> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
>>> Cc: <stable@vger.kernel.org>
>>> ---
>>> Do not hesitate to suggest ideas for alternative implementations, I'm
>>> not sure if the current proposal is the one that fits best with the
>>> current design of the driver.
>>> ---
>>>    drivers/net/ethernet/stmicro/stmmac/common.h         | 12 +++++++++---
>>>    drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c | 16 ++++++++++++++++
>>>    drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h     |  3 ++-
>>>    drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c     |  7 ++++++-
>>>    drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h      |  3 ++-
>>>    drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c      |  6 +++++-
>>>    drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |  3 ++-
>>>    7 files changed, 42 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
>>> index 04d9245..d576f95 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
>>> @@ -407,10 +407,13 @@ struct stmmac_desc_ops {
>>>    extern const struct stmmac_desc_ops enh_desc_ops;
>>>    extern const struct stmmac_desc_ops ndesc_ops;
>>>    
>>> +struct mac_device_info;
>>> +
>>>    /* Specific DMA helpers */
>>>    struct stmmac_dma_ops {
>>>    	/* DMA core initialization */
>>> -	int (*reset)(void __iomem *ioaddr);
>>> +	int (*reset)(void __iomem *ioaddr, struct mac_device_info *hw,
>>> +		     phy_interface_t interface);
>>>    	void (*init)(void __iomem *ioaddr, struct stmmac_dma_cfg *dma_cfg,
>>>    		     u32 dma_tx, u32 dma_rx, int atds);
>>>    	/* Configure the AXI Bus Mode Register */
>>> @@ -445,12 +448,15 @@ struct stmmac_dma_ops {
>>>    	void (*enable_tso)(void __iomem *ioaddr, bool en, u32 chan);
>>>    };
>>>    
>>> -struct mac_device_info;
>>> -
>>>    /* Helpers to program the MAC core */
>>>    struct stmmac_ops {
>>>    	/* MAC core initialization */
>>>    	void (*core_init)(struct mac_device_info *hw, int mtu);
>>> +	/* Set port select. Called between asserting DMA reset and
>>> +	 * waiting for the reset bit to clear.
>>> +	 */
>>> +	void (*set_ps)(struct mac_device_info *hw,
>>> +		       phy_interface_t interface);
>>>    	/* Enable and verify that the IPC module is supported */
>>>    	int (*rx_ipc)(struct mac_device_info *hw);
>>>    	/* Enable RX Queues */
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>>> index 19b9b308..dfcbb5b 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>>> @@ -75,6 +75,21 @@ static void dwmac1000_core_init(struct mac_device_info *hw, int mtu)
>>>    #endif
>>>    }
>>>    
>>> +static void dwmac1000_set_ps(struct mac_device_info *hw,
>>> +			     phy_interface_t interface)
>>> +{
>>> +	void __iomem *ioaddr = hw->pcsr;
>>> +	u32 value = readl(ioaddr + GMAC_CONTROL);
>>> +
>>> +	/* When a MII PHY is used, we must set the PS bit for the DMA
>>> +	 * reset to succeed.
>>> +	 */
>>> +	if (interface == PHY_INTERFACE_MODE_MII)
>>> +		value |= GMAC_CONTROL_PS;
>>> +
>>> +	writel(value, ioaddr + GMAC_CONTROL);
>>> +}
>>> +
>>>    static int dwmac1000_rx_ipc_enable(struct mac_device_info *hw)
>>>    {
>>>    	void __iomem *ioaddr = hw->pcsr;
>>> @@ -488,6 +503,7 @@ static void dwmac1000_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
>>>    
>>>    static const struct stmmac_ops dwmac1000_ops = {
>>>    	.core_init = dwmac1000_core_init,
>>> +	.set_ps = dwmac1000_set_ps,
>>>    	.rx_ipc = dwmac1000_rx_ipc_enable,
>>>    	.dump_regs = dwmac1000_dump_regs,
>>>    	.host_irq_status = dwmac1000_irq_status,
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
>>> index 1b06df7..e9c6c49 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
>>> @@ -183,7 +183,8 @@
>>>    #define DMA_CHAN0_DBG_STAT_RPS		GENMASK(11, 8)
>>>    #define DMA_CHAN0_DBG_STAT_RPS_SHIFT	8
>>>    
>>> -int dwmac4_dma_reset(void __iomem *ioaddr);
>>> +int dwmac4_dma_reset(void __iomem *ioaddr, struct mac_device_info *hw,
>>> +		     phy_interface_t interface);
>>>    void dwmac4_enable_dma_transmission(void __iomem *ioaddr, u32 tail_ptr);
>>>    void dwmac4_enable_dma_irq(void __iomem *ioaddr);
>>>    void dwmac410_enable_dma_irq(void __iomem *ioaddr);
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
>>> index c7326d5..485eecb 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
>>> @@ -14,7 +14,8 @@
>>>    #include "dwmac4_dma.h"
>>>    #include "dwmac4.h"
>>>    
>>> -int dwmac4_dma_reset(void __iomem *ioaddr)
>>> +int dwmac4_dma_reset(void __iomem *ioaddr, struct mac_device_info *hw,
>>> +		     phy_interface_t interface)
>>>    {
>>>    	u32 value = readl(ioaddr + DMA_BUS_MODE);
>>>    	int limit;
>>> @@ -22,6 +23,10 @@ int dwmac4_dma_reset(void __iomem *ioaddr)
>>>    	/* DMA SW reset */
>>>    	value |= DMA_BUS_MODE_SFT_RESET;
>>>    	writel(value, ioaddr + DMA_BUS_MODE);
>>> +
>>> +	if (hw->mac->set_ps)
>>> +		hw->mac->set_ps(hw, interface);
>>> +
>>>    	limit = 10;
>>>    	while (limit--) {
>>>    		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
>>> index 56e485f..25ae028 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
>>> @@ -144,6 +144,7 @@ void dwmac_dma_stop_tx(void __iomem *ioaddr);
>>>    void dwmac_dma_start_rx(void __iomem *ioaddr);
>>>    void dwmac_dma_stop_rx(void __iomem *ioaddr);
>>>    int dwmac_dma_interrupt(void __iomem *ioaddr, struct stmmac_extra_stats *x);
>>> -int dwmac_dma_reset(void __iomem *ioaddr);
>>> +int dwmac_dma_reset(void __iomem *ioaddr, struct mac_device_info *hw,
>>> +		    phy_interface_t interface);
>>>    
>>>    #endif /* __DWMAC_DMA_H__ */
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
>>> index e60bfca..1a17df5 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
>>> @@ -23,7 +23,8 @@
>>>    
>>>    #define GMAC_HI_REG_AE		0x80000000
>>>    
>>> -int dwmac_dma_reset(void __iomem *ioaddr)
>>> +int dwmac_dma_reset(void __iomem *ioaddr, struct mac_device_info *hw,
>>> +		    phy_interface_t interface)
>>>    {
>>>    	u32 value = readl(ioaddr + DMA_BUS_MODE);
>>>    	int err;
>>> @@ -32,6 +33,9 @@ int dwmac_dma_reset(void __iomem *ioaddr)
>>>    	value |= DMA_BUS_MODE_SFT_RESET;
>>>    	writel(value, ioaddr + DMA_BUS_MODE);
>>>    
>>> +	if (hw->mac->set_ps)
>>> +		hw->mac->set_ps(hw, interface);
>>> +
>>>    	err = readl_poll_timeout(ioaddr + DMA_BUS_MODE, value,
>>>    				 !(value & DMA_BUS_MODE_SFT_RESET),
>>>    				 100000, 10000);
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> index 4498a38..66bc218 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> @@ -1585,7 +1585,8 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>>>    	if (priv->extend_desc && (priv->mode == STMMAC_RING_MODE))
>>>    		atds = 1;
>>>    
>>> -	ret = priv->hw->dma->reset(priv->ioaddr);
>>> +	ret = priv->hw->dma->reset(priv->ioaddr, priv->hw,
>>> +				   priv->plat->interface);
>>>    	if (ret) {
>>>    		dev_err(priv->device, "Failed to reset the dma\n");
>>>    		return ret;
>>
