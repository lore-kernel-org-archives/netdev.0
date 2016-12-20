From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] stmmac: enable rx queues
Date: Tue, 20 Dec 2016 14:59:18 +0000
Message-ID: <bb31d7ca-667a-65cc-4c93-76688ef95ccb@synopsys.com>
References: <9a8911dfd2ed07391106e9cd0f90475742a798dc.1482238007.git.jpinto@synopsys.com>
 <ba998f36-4ae2-10f3-2483-14b0bf351037@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <hock.leong.kweh@intel.com>, <niklas.cassel@axis.com>,
        <pavel@ucw.cz>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: Seraphin BONNAFFE <seraphin.bonnaffe@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <peppe.cavallaro@st.com>,
        <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ba998f36-4ae2-10f3-2483-14b0bf351037@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Séraphin,

Às 2:52 PM de 12/20/2016, Seraphin BONNAFFE escreveu:
> Hi Joao,
> 
> Please see my in-line comments.
> 
> Regards,
> Séraphin
> -- 
> Seraphin BONNAFFE | Tel: +33244027061
> STMicroelectronics | ADG | S/W Design
> 
> On 12/20/2016 01:55 PM, Joao Pinto wrote:
>> When the hardware is synthesized with multiple queues, all queues are
>> disabled for default. This patch adds the rx queues configuration.
>> This patch was successfully tested in a Synopsys QoS Reference design.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/common.h      |  2 ++
>>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  4 ++++
>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 11 +++++++++++
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 21 +++++++++++++++++++++
>>  4 files changed, 38 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h
>> b/drivers/net/ethernet/stmicro/stmmac/common.h
>> index b13a144..61bab50 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
>> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
>> @@ -454,6 +454,8 @@ struct stmmac_ops {
>>      void (*core_init)(struct mac_device_info *hw, int mtu);
>>      /* Enable and verify that the IPC module is supported */
>>      int (*rx_ipc)(struct mac_device_info *hw);
>> +    /* Enable RX Queues */
>> +    void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
>>      /* Dump MAC registers */
>>      void (*dump_regs)(struct mac_device_info *hw);
>>      /* Handle extra events on specific interrupts hw dependent */
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>> b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>> index 3e8d4fe..fd013bd 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>> @@ -22,6 +22,7 @@
>>  #define GMAC_HASH_TAB_32_63        0x00000014
>>  #define GMAC_RX_FLOW_CTRL        0x00000090
>>  #define GMAC_QX_TX_FLOW_CTRL(x)        (0x70 + x * 4)
>> +#define GMAC_RXQ_CTRL0            0x000000a0
>>  #define GMAC_INT_STATUS            0x000000b0
>>  #define GMAC_INT_EN            0x000000b4
>>  #define GMAC_PCS_BASE            0x000000e0
>> @@ -44,6 +45,9 @@
>>
>>  #define GMAC_MAX_PERFECT_ADDRESSES    128
>>
>> +/* MAC RX Queue Enable*/
>> +#define GMAC_RX_QUEUE_ENABLE(queue)    BIT(queue * 2)
> 
> According to the GMAC_RXQ0 register description from the dwc_ether_qos_databok,
> I guess this will enable the queues in AV only.
> What if we would like to enable them in DCB (10)b ?

Correct, I am enabling AV only. What you are saying makes perfect sense. What
about adding a variable to plat in order to configure the RX queue type?
Example:
plat->rx_queue_type = RX_QUEUE_DCB or plat->rx_queue_type = RX_QUEUE_AV


> 
> 
>> +
>>  /* MAC Flow Control RX */
>>  #define GMAC_RX_FLOW_CTRL_RFE        BIT(0)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
>> b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
>> index eaed7cb..7ec1887 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
>> @@ -59,6 +59,16 @@ static void dwmac4_core_init(struct mac_device_info *hw,
>> int mtu)
>>      writel(value, ioaddr + GMAC_INT_EN);
>>  }
>>
>> +static void dwmac4_rx_queue_enable(struct mac_device_info *hw, u32 queue)
>> +{
>> +    void __iomem *ioaddr = hw->pcsr;
>> +    u32 value = readl(ioaddr + GMAC_RXQ_CTRL0);
>> +
>> +    value |= GMAC_RX_QUEUE_ENABLE(queue);
> 
> What happen if for some reason the previous value of the register was 0xffff ?
> The OR mask, by itself, won't clear the bits. AFAIU each queue is enabled with a
> 2-bit value, and (11)b don't have the same effect as (01)b, does it ?
> 
> I would suggest to clear the RXQ-enable bits before writing a new value.
> Something like
>   value &= GMAC_RX_QUEUE_CLEAR(queue)
>   value |= GMAC_RX_QUEUE_ENABLE(queue);
> 
> What do you think about that ?

According to the databook, these values are always reset, but we can force it to
clear as you suggest.

> 
>> +
>> +    writel(value, ioaddr + GMAC_RXQ_CTRL0);
>> +}
>> +
>>  static void dwmac4_dump_regs(struct mac_device_info *hw)
>>  {
>>      void __iomem *ioaddr = hw->pcsr;
>> @@ -392,6 +402,7 @@ static void dwmac4_debug(void __iomem *ioaddr, struct
>> stmmac_extra_stats *x)
>>  static const struct stmmac_ops dwmac4_ops = {
>>      .core_init = dwmac4_core_init,
>>      .rx_ipc = dwmac4_rx_ipc_enable,
>> +    .rx_queue_enable = dwmac4_rx_queue_enable,
>>      .dump_regs = dwmac4_dump_regs,
>>      .host_irq_status = dwmac4_irq_status,
>>      .flow_ctrl = dwmac4_flow_ctrl,
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 3e40578..e30034d 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -1271,6 +1271,24 @@ static void free_dma_desc_resources(struct stmmac_priv
>> *priv)
>>  }
>>
>>  /**
>> + *  stmmac_mac_enable_rx_queues - Enable MAC rx queues
>> + *  @priv: driver private structure
>> + *  Description: It is used for enabling the rx queues in the MAC
>> + */
>> +static void stmmac_mac_enable_rx_queues(struct stmmac_priv *priv)
>> +{
>> +    int rx_count = priv->dma_cap.number_rx_channel;
>> +    int queue = 0;
>> +
>> +    /* If GMAC does not have multiqueues, then this is not necessary*/
>> +    if (rx_count == 1)
>> +        return;
>> +
>> +    for (queue = 0; queue < rx_count; queue++)
>> +        priv->hw->mac->rx_queue_enable(priv->hw, queue);
> 
> 
> Maybe it is worth checking if (priv->hw->mac->rx_queue_enable)
> before actually calling this callback ?
> I can see you have implemented it for dwmac4, but not for dwmac100 and dwmac100
> In that case we may have a null pointer exception here.

Yes, you are absolutely correct. Since I am using gmac4, I forgot that stmmac
can use other types.

> 
>> +}
>> +
>> +/**
>>   *  stmmac_dma_operation_mode - HW DMA operation mode
>>   *  @priv: driver private structure
>>   *  Description: it is used for configuring the DMA operation mode register in
>> @@ -1691,6 +1709,9 @@ static int stmmac_hw_setup(struct net_device *dev, bool
>> init_ptp)
>>      /* Initialize the MAC Core */
>>      priv->hw->mac->core_init(priv->hw, dev->mtu);
>>
>> +    /* Initialize MAC RX Queues */
>> +    stmmac_mac_enable_rx_queues(priv);
>> +
>>      ret = priv->hw->mac->rx_ipc(priv->hw);
>>      if (!ret) {
>>          netdev_warn(priv->dev, "RX IPC Checksum Offload disabled\n");
>>

Thanks.
