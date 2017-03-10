From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH 4/7] net: stmmac: Parse FIFO sizes from feature registers
Date: Fri, 10 Mar 2017 10:32:47 +0000
Message-ID: <74ca0a6d-909e-4ccf-2ab2-33a4c2aa544b@synopsys.com>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-5-thierry.reding@gmail.com>
 <b74f9b19-4315-1349-88c0-b549a2f8ef5d@synopsys.com>
 <20170309194104.GC5554@ulmo.ba.sec>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        "Rob Herring" <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Alexandre Courbot <gnurou@gmail.com>,
        Jon Hunter <jonathanh@nvidia.com>, <netdev@vger.kernel.org>,
        <linux-tegra@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Thierry Reding <thierry.reding@gmail.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170309194104.GC5554@ulmo.ba.sec>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Às 7:41 PM de 3/9/2017, Thierry Reding escreveu:
> On Thu, Mar 02, 2017 at 03:09:11PM +0000, Joao Pinto wrote:
>> Hi Thierry,
>>
>> Às 5:24 PM de 2/23/2017, Thierry Reding escreveu:
>>> From: Thierry Reding <treding@nvidia.com>
>>>
>>> New version of this core encode the FIFO sizes in one of the feature
>>> registers. Use these sizes as default, but still allow device tree to
>>> override them for backwards compatibility.
>>>
>>> Signed-off-by: Thierry Reding <treding@nvidia.com>
>>> ---
>>>  drivers/net/ethernet/stmicro/stmmac/common.h      | 3 +++
>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  | 2 ++
>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 +++
>>>  3 files changed, 8 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
>>> index 144fe84e8a53..6ac653845d82 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
>>> @@ -324,6 +324,9 @@ struct dma_features {
>>>  	unsigned int number_tx_queues;
>>>  	/* Alternate (enhanced) DESC mode */
>>>  	unsigned int enh_desc;
>>> +	/* TX and RX FIFO sizes */
>>> +	unsigned int tx_fifo_size;
>>> +	unsigned int rx_fifo_size;
>>>  };
>>>  
>>>  /* GMAC TX FIFO is 8K, Rx FIFO is 16K */
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
>>> index 377d1b44d4f2..8d249f3b34c8 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
>>> @@ -296,6 +296,8 @@ static void dwmac4_get_hw_feature(void __iomem *ioaddr,
>>>  	hw_cap = readl(ioaddr + GMAC_HW_FEATURE1);
>>>  	dma_cap->av = (hw_cap & GMAC_HW_FEAT_AVSEL) >> 20;
>>>  	dma_cap->tsoen = (hw_cap & GMAC_HW_TSOEN) >> 18;
>>> +	dma_cap->tx_fifo_size = 128 << ((hw_cap >> 6) & 0x1f);
>>> +	dma_cap->rx_fifo_size = 128 << ((hw_cap >> 0) & 0x1f);
>>
>> I suggest you follow the way that has been done for other parameters:
>>
>> dma_cap->rx_fifo_size = (hw_cap & GMAC_HW_RXFIFOSIZE) >> 0; where
>> GMAC_HW_RXFIFOSIZE is GENMASK(4, 0)
>> dma_cap->tx_fifo_size = (hw_cap & GMAC_HW_TXFIFOSIZE) >> 6; where
>> GMAC_HW_TXFIFOSIZE is GENMASK(10, 6)
> 
> Okay, can do.
> 
>>>  	/* MAC HW feature2 */
>>>  	hw_cap = readl(ioaddr + GMAC_HW_FEATURE2);
>>>  	/* TX and RX number of channels */
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> index d7387919bdb6..291e34f0ca94 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> @@ -1281,6 +1281,9 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
>>>  {
>>>  	int rxfifosz = priv->plat->rx_fifo_size;
>>>  
>>> +	if (rxfifosz == 0)
>>> +		rxfifosz = priv->dma_cap.rx_fifo_size;
>>> +
>>>  	if (priv->plat->force_thresh_dma_mode)
>>>  		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc, rxfifosz);
>>>  	else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
>>>
>>
>> In my current patch for adding support for MTL in stmmac, I also had this
>> approach (sizes comming from feature register and platform data) so nice to see
>> it here, because I will be able to reutilize it in my future versions.
>>
>> There is only a slight twist that we have to pay attention to it. The RX and TX
>> queue size configuration needs to be one the following values:
>>
>> FIFO_256 = 0x0,
>> FIFO_512 = 0x1,
>> FIFO_1k = 0x3,
>> FIFO_2k = 0x7,
>> FIFO_4k = 0xf,
>> FIFO_8k = 0x1f,
>> FIFO_16k = 0x3f,
>> FIFO_32k = 0x7f
>>
>> These are the values you get from the features register, but are these the
>> values that users will configure in "plat->rx_fifo_size"? From a quick grep you
>> can see that users use real units:
>>
>> arch/arm/boot/dts/socfpga.dtsi:			rx-fifo-depth = <4096>;
>> arch/arm/boot/dts/socfpga.dtsi:			rx-fifo-depth = <4096>;
>> arch/arm/boot/dts/socfpga_arria10.dtsi:			rx-fifo-depth = <16384>;
>> arch/arm/boot/dts/socfpga_arria10.dtsi:			rx-fifo-depth = <16384>;
>> arch/arm/boot/dts/socfpga_arria10.dtsi:			rx-fifo-depth = <16384>;
>> arch/arm/boot/dts/lpc18xx.dtsi:			rx-fifo-depth = <256>;
>> arch/nios2/boot/dts/3c120_devboard.dts:				rx-fifo-depth = <8192>;
>> arch/nios2/boot/dts/10m50_devboard.dts:			rx-fifo-depth = <8192>;
>>
>> So in order to have it configurable from platform and features register you need
>> to convert the features values to "real" units and then in the end when you
>> write to the DMA Op Mode you need to convert it back to the required values.
> 
> That's what the "128 << " part in dwmac4_get_hw_feature() does. As far
> as I can tell, that's equivalent to dwmac4_get_real_fifo_sz() function
> from your patch, but it's more compact.

Ok, great, but I suggest you put the operation clearer then (a convert macro
maybe), because this way will be more obvious.

> 
>> You can check my patch here that already has this done:
>> https://urldefense.proofpoint.com/v2/url?u=http-3A__patchwork.ozlabs.org_patch_728566_&d=DwIFaQ&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=vfSNvldRkxJ8_e-lvP03KElsSdtNkACrt5RZt47TVZE&s=KByW4fH0QMLR16vmW6ekKqBC-cvqe0nBeOWpXB6uG_4&e= 
> 
> I see that there's a bit of overlap between that patch and this series.
> How do you want to handle this? Do you want me to rebase on top of your
> patch, or would you prefer this series to get merged first and rework
> your patch on top of it?

I suggest you go first, and then I will adapt my development since I still
submiting the multiple queues MAC related operations.

Thanks.

> 
> Thanks,
> Thierry
> 
