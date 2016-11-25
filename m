From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH] net: stmmac: enable tx queue 0 for gmac4 IPs synthesized
 with multiple TX queues
Date: Fri, 25 Nov 2016 13:14:18 +0100
Message-ID: <c97ee9f8-c656-20a9-c41a-e66041540013@axis.com>
References: <1479998194-7113-1-git-send-email-niklass@axis.com>
 <0516ebe9-6b66-5991-1f96-1cc10178977a@st.com>
 <95ed6d38-cc5e-402f-6772-710b6ad0c930@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <95ed6d38-cc5e-402f-6772-710b6ad0c930@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/25/2016 01:10 PM, Niklas Cassel wrote:
> On 11/24/2016 07:11 PM, Alexandre Torgue wrote:
>> Hi Niklas,
> Hello Alexandre
>
>> On 11/24/2016 03:36 PM, Niklas Cassel wrote:
>>> From: Niklas Cassel <niklas.cassel@axis.com>
>>>
>>> The dwmac4 IP can synthesized with 1-8 number of tx queues.
>>> On an IP synthesized with DWC_EQOS_NUM_TXQ > 1, all txqueues are disabled
>>> by default. For these IPs, the bitfield TXQEN is R/W.
>>>
>>> Always enable tx queue 0. The write will have no effect on IPs synthesized
>>> with DWC_EQOS_NUM_TXQ == 1.
>>>
>>> The driver does still not utilize more than one tx queue in the IP.
>>>
>>> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
>>> ---
>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h     |  3 +++
>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c | 12 +++++++++++-
>>>  2 files changed, 14 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>>> index 6f4f5ce25114..3e8d4fefa5e0 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>>> @@ -155,8 +155,11 @@ enum power_event {
>>>  #define MTL_CHAN_RX_DEBUG(x)        (MTL_CHANX_BASE_ADDR(x) + 0x38)
>>>
>>>  #define MTL_OP_MODE_RSF            BIT(5)
>>> +#define MTL_OP_MODE_TXQEN        BIT(3)
>>>  #define MTL_OP_MODE_TSF            BIT(1)
>>>
>>> +#define MTL_OP_MODE_TQS_MASK        GENMASK(24, 16)
>>> +
>>>  #define MTL_OP_MODE_TTC_MASK        0x70
>>>  #define MTL_OP_MODE_TTC_SHIFT        4
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
>>> index 116151cd6a95..577316de6ba8 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
>>> @@ -213,7 +213,17 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
>>>          else
>>>              mtl_tx_op |= MTL_OP_MODE_TTC_512;
>>>      }
>>> -
>>> +    /* For an IP with DWC_EQOS_NUM_TXQ == 1, the fields TXQEN and TQS are RO
>>> +     * with reset values: TXQEN on, TQS == DWC_EQOS_TXFIFO_SIZE.
>>> +     * For an IP with DWC_EQOS_NUM_TXQ > 1, the fields TXQEN and TQS are R/W
>>> +     * with reset values: TXQEN off, TQS 256 bytes.
>>> +     *
>>> +     * Write the bits in both cases, since it will have no effect when RO.
>>> +     * For DWC_EQOS_NUM_TXQ > 1, the top bits in MTL_OP_MODE_TQS_MASK might
>>> +     * be RO, however, writing the whole TQS field will result in a value
>>> +     * equal to DWC_EQOS_TXFIFO_SIZE, just like for DWC_EQOS_NUM_TXQ == 1.
>>> +     */
>>> +    mtl_tx_op |= MTL_OP_MODE_TXQEN | MTL_OP_MODE_TQS_MASK;
>> Your patch sounds good. Just one question:
>>
>> In synopsys databook I use, I see that MTL_OP_MODE_TXQEN for channel 2 can take several values "disabled / enabled / Enabled in AV mode":
>>
>> Transmit Queue Enable
>> This field is used to enable/disable the transmit queue 1. 00 R/W
>> ■ 2'b00 - Not enabled
>> ■ 2'b01 - Enable in AV mode (Reserved when Enable Audio Video
>> Bridging is not selected while configuring the core)
>> ■ 2'b10 - Enabled
>> ■ 2'b11 - Reserved
>>
>> Do you plan to manage av mode in a future patch ?
> We are not planning on using the AV mode.
> We will probably not use TXQ1 at all.
>
> I noticed that the MAC_HW_Feature2 Register actually has a TXQCNT field.
> It is currently saved in priv->dma_cap.number_tx_channel.
> If you prefer, I could do a patch V2 where we only set the bits if
> priv->dma_cap.number_tx_channel > 1

Oh, sorry, that was number of tx _channels_,
not number of tx _queues_.

However, we could add a number_tx_queue to struct dma_features,
if you would prefer that.

>
> However, I don't think the current patch is too bad either, since the bits
> are RO when number_tx_channel == 1.
>
>
>> Regards
>> Alex
>>
>>>      writel(mtl_tx_op, ioaddr +  MTL_CHAN_TX_OP_MODE(channel));
>>>
>>>      mtl_rx_op = readl(ioaddr + MTL_CHAN_RX_OP_MODE(channel));
>>>
