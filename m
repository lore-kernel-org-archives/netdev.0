From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH] stmmac: enable rx queues
Date: Tue, 20 Dec 2016 16:05:39 +0100
Message-ID: <a345494e-0e8b-9233-ed13-9dedc88328c2@axis.com>
References: <9a8911dfd2ed07391106e9cd0f90475742a798dc.1482238007.git.jpinto@synopsys.com>
 <f5cda4a7-8c41-86b7-b133-cf41eaec0370@axis.com>
 <020e1c77-504e-3cfc-e526-ce1645fd6b32@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <hock.leong.kweh@intel.com>, <pavel@ucw.cz>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>, <peppe.cavallaro@st.com>,
        <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <020e1c77-504e-3cfc-e526-ce1645fd6b32@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/20/2016 03:52 PM, Joao Pinto wrote:
> Hi Niklas,
>
> Às 2:43 PM de 12/20/2016, Niklas Cassel escreveu:
>>
>> On 12/20/2016 01:55 PM, Joao Pinto wrote:
>>> When the hardware is synthesized with multiple queues, all queues are
>>> disabled for default. This patch adds the rx queues configuration.
>>> This patch was successfully tested in a Synopsys QoS Reference design.
>>>
>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>>> ---
>>>  drivers/net/ethernet/stmicro/stmmac/common.h      |  2 ++
>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  4 ++++
>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 11 +++++++++++
>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 21 +++++++++++++++++++++
>>>  4 files changed, 38 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
>>> index b13a144..61bab50 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
>>> @@ -454,6 +454,8 @@ struct stmmac_ops {
>>>  	void (*core_init)(struct mac_device_info *hw, int mtu);
>>>  	/* Enable and verify that the IPC module is supported */
>>>  	int (*rx_ipc)(struct mac_device_info *hw);
>>> +	/* Enable RX Queues */
>>> +	void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
>>>  	/* Dump MAC registers */
>>>  	void (*dump_regs)(struct mac_device_info *hw);
>>>  	/* Handle extra events on specific interrupts hw dependent */
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>>> index 3e8d4fe..fd013bd 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>>> @@ -22,6 +22,7 @@
>>>  #define GMAC_HASH_TAB_32_63		0x00000014
>>>  #define GMAC_RX_FLOW_CTRL		0x00000090
>>>  #define GMAC_QX_TX_FLOW_CTRL(x)		(0x70 + x * 4)
>>> +#define GMAC_RXQ_CTRL0			0x000000a0
>>>  #define GMAC_INT_STATUS			0x000000b0
>>>  #define GMAC_INT_EN			0x000000b4
>>>  #define GMAC_PCS_BASE			0x000000e0
>>> @@ -44,6 +45,9 @@
>>>  
>>>  #define GMAC_MAX_PERFECT_ADDRESSES	128
>>>  
>>> +/* MAC RX Queue Enable*/
>>> +#define GMAC_RX_QUEUE_ENABLE(queue)	BIT(queue * 2)
>> Always have parentheses around a variable in a
>> macro, otherwise strange things could happen.
>> Imagine if you send 5 - 4 as argument,
>> it will then expand to 5 - 4 * 2 = -3,
>> instead of (5 - 4) * 2 = 2
> Right. I am going to do that.
>
>>> +
>>>  /* MAC Flow Control RX */
>>>  #define GMAC_RX_FLOW_CTRL_RFE		BIT(0)
>>>  
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
>>> index eaed7cb..7ec1887 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
>>> @@ -59,6 +59,16 @@ static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
>>>  	writel(value, ioaddr + GMAC_INT_EN);
>>>  }
>>>  
>>> +static void dwmac4_rx_queue_enable(struct mac_device_info *hw, u32 queue)
>>> +{
>>> +	void __iomem *ioaddr = hw->pcsr;
>>> +	u32 value = readl(ioaddr + GMAC_RXQ_CTRL0);
>>> +
>>> +	value |= GMAC_RX_QUEUE_ENABLE(queue);
>>> +
>>> +	writel(value, ioaddr + GMAC_RXQ_CTRL0);
>>> +}
>>> +
>>>  static void dwmac4_dump_regs(struct mac_device_info *hw)
>>>  {
>>>  	void __iomem *ioaddr = hw->pcsr;
>>> @@ -392,6 +402,7 @@ static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
>>>  static const struct stmmac_ops dwmac4_ops = {
>>>  	.core_init = dwmac4_core_init,
>>>  	.rx_ipc = dwmac4_rx_ipc_enable,
>>> +	.rx_queue_enable = dwmac4_rx_queue_enable,
>>>  	.dump_regs = dwmac4_dump_regs,
>>>  	.host_irq_status = dwmac4_irq_status,
>>>  	.flow_ctrl = dwmac4_flow_ctrl,
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> index 3e40578..e30034d 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> @@ -1271,6 +1271,24 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
>>>  }
>>>  
>>>  /**
>>> + *  stmmac_mac_enable_rx_queues - Enable MAC rx queues
>>> + *  @priv: driver private structure
>>> + *  Description: It is used for enabling the rx queues in the MAC
>>> + */
>>> +static void stmmac_mac_enable_rx_queues(struct stmmac_priv *priv)
>>> +{
>>> +	int rx_count = priv->dma_cap.number_rx_channel;
>> priv->dma_cap.number_rx_channel
>> actually contains the value from register
>> MAC_HW_Feature2, field RXCHCNT,
>> which is the number of DMA rx channels.
>>
>> This is not the same as the number of MTL
>> receive queues, field RXQCNT in MAC_HW_Feature2.
>>
>> I guess they will often have the same value,
>> but since there actually are two different fields
>> for them, I suppose that is not always the case.
> Yes, you typically have a match between channels and queues.
> But I can use RXQCNT of course, I agree.
>
>>
>>
>> Reading the comments in dwmac4_dma.*
>>
>> #define DMA_CHANNEL_NB_MAX              1
>>
>> "Only Channel 0 is actually configured and used"
>>
>> "Following code only done for channel 0, other channels not yet supported"
>>
>> Is there any point in actually enabling more than RX queue 0 if the
>> driver does not yet support more than one channel.
>> Can RXCHCNT ever be different from RXQCNT?
>> If so, when? Maybe when using an external DMA IP?
> Yes, currently stmmac only supports 1 Channel. Bt it needs this feature if the
> hardware is multi-channel. The hardware I have is multi-channel and so you have
> to enable RX queue for it to work and that's why I made this fix.
> In the future I will develope multi channel support for stmmac and this RX queue
> enable will be already made.

I understand that for multi-queue hardware, RX queue 0 is default off,
but perhaps it is safer to only enable RX queue 0,
even if you have more than one RX queue.
(Only until you have implemented actual support for multi-queues
in the driver.)

But if you know that it's safe to enable all RX queues even if the
driver only uses RX queue 0, then perhaps it doesn't matter.


>
>>
>>> +	int queue = 0;
>>> +
>>> +	/* If GMAC does not have multiqueues, then this is not necessary*/
>>> +	if (rx_count == 1)
>>> +		return;
>>> +
>>> +	for (queue = 0; queue < rx_count; queue++)
>>> +		priv->hw->mac->rx_queue_enable(priv->hw, queue);
>>> +}
>>> +
>>> +/**
>>>   *  stmmac_dma_operation_mode - HW DMA operation mode
>>>   *  @priv: driver private structure
>>>   *  Description: it is used for configuring the DMA operation mode register in
>>> @@ -1691,6 +1709,9 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
>>>  	/* Initialize the MAC Core */
>>>  	priv->hw->mac->core_init(priv->hw, dev->mtu);
>>>  
>>> +	/* Initialize MAC RX Queues */
>>> +	stmmac_mac_enable_rx_queues(priv);
>>> +
>>>  	ret = priv->hw->mac->rx_ipc(priv->hw);
>>>  	if (!ret) {
>>>  		netdev_warn(priv->dev, "RX IPC Checksum Offload disabled\n");
