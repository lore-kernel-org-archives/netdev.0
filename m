From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH 3/3] net: stmmac: Use AVB mode by default
Date: Tue, 21 Mar 2017 16:52:42 +0000
Message-ID: <c233aec8-c14c-52f6-8d76-59a4c3ad1eb8@synopsys.com>
References: <20170321151211.31841-1-thierry.reding@gmail.com>
 <20170321151211.31841-3-thierry.reding@gmail.com>
 <bac4dbe3-dd38-8b2b-71f1-dbb04d8298bd@synopsys.com>
 <20170321164249.GB31875@ulmo.ba.sec>
 <d2e17311-548f-db2d-6e23-4ffa9214f5eb@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        "LABBE Corentin" <clabbe.montjoie@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Thierry Reding <thierry.reding@gmail.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d2e17311-548f-db2d-6e23-4ffa9214f5eb@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Às 4:50 PM de 3/21/2017, Joao Pinto escreveu:
> Às 4:42 PM de 3/21/2017, Thierry Reding escreveu:
>> On Tue, Mar 21, 2017 at 03:23:00PM +0000, Joao Pinto wrote:
>>> Às 3:12 PM de 3/21/2017, Thierry Reding escreveu:
>>>> From: Thierry Reding <treding@nvidia.com>
>>>>
>>>> Prior to the recent multi-queue changes the driver would configure the
>>>> queues to use the AVB mode, but the mode then got switched to DCB. The
>>>> hardware still works fine in DCB mode, but my testing capabilities are
>>>> limited, so it's safer to revert to the prior setting anyway.
>>>>
>>>> Signed-off-by: Thierry Reding <treding@nvidia.com>
>>>> ---
>>>>  include/linux/stmmac.h | 4 ++--
>>>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
>>>> index be47b859e954..8349a5c1537b 100644
>>>> --- a/include/linux/stmmac.h
>>>> +++ b/include/linux/stmmac.h
>>>> @@ -56,8 +56,8 @@
>>>>  #define MTL_RX_ALGORITHM_WSP	0x5
>>>>  
>>>>  /* RX/TX Queue Mode */
>>>> -#define MTL_QUEUE_DCB		0x0
>>>> -#define MTL_QUEUE_AVB		0x1
>>>> +#define MTL_QUEUE_AVB		0x0
>>>> +#define MTL_QUEUE_DCB		0x1
>>>>  
>>>>  /* The MDC clock could be set higher than the IEEE 802.3
>>>>   * specified frequency limit 0f 2.5 MHz, by programming a clock divider
>>>>
>>>
>>> Thierry, I don't understand this patch. It will have 0 impact.
>>>
>>> In stmmac_platform configuration, 0 impact:
>>>
>>> 		if (of_property_read_bool(q_node, "snps,dcb-algorithm"))
>>> 			plat->rx_queues_cfg[queue].mode_to_use = MTL_QUEUE_DCB;
>>> 		else if (of_property_read_bool(q_node, "snps,avb-algorithm"))
>>> 			plat->rx_queues_cfg[queue].mode_to_use = MTL_QUEUE_AVB;
>>> 		else
>>> **			plat->rx_queues_cfg[queue].mode_to_use = MTL_QUEUE_DCB;
>>>
>>> In dwmac4_core, 0 impact:
>>>
>>> 	value &= GMAC_RX_QUEUE_CLEAR(queue);
>>> 	if (mode == MTL_QUEUE_AVB)
>>> 		value |= GMAC_RX_AV_QUEUE_ENABLE(queue);
>>> 	else if (mode == MTL_QUEUE_DCB)
>>> 		value |= GMAC_RX_DCB_QUEUE_ENABLE(queue);
>>>
>>> I think you should set the default mode in (**).
>>
>> That was my initial attempt, but then I realized that for old DTBs,
>> stmmac_mtl_setup() will already exit prematurely because of the missing
>> snps,mtl-{rx,tx}-config properties. It's pretty much for the same reason
>> as the separate assignment of the default {rx,tx}_queues_to_use. In this
>> case it's somewhat more obfuscated, though. Changing AVB to be mode 0
>> means that plat->rx_queues_cfg[].mode_to_use will contain AVB as default
>> because plat is devm_kzalloc()'ed.
>>
>> Effectively this change makes all queues use AVB by default unless they
>> are configured using the new device tree bindings.
> 
> Yes I keep forgeting that :), but you are assuming that
> plat->rx_queues_cfg[queue].mode_to_use is 0 by default, which might not be the
> case, but I agree with you that this is the simpler approach. Let's see what
> others have to say.

Forget what I said, yes devm_kzalloc() in plat guarantees this. I need a cup of
coffee :).

Acked-By: Joao Pinto <jpinto@synopsys.com>
>>
>> Thierry
>>
> 
