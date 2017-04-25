From: "lipeng (Y)" <lipeng321@huawei.com>
Subject: Re: [PATCH net v2 1/3] net: hns: support deferred probe when can not
 obtain irq
Date: Tue, 25 Apr 2017 16:21:47 +0800
Message-ID: <48430275-67b8-987c-1c7a-9252c0094513@huawei.com>
References: <1492760684-117205-1-git-send-email-yankejian@huawei.com>
 <1492760684-117205-2-git-send-email-yankejian@huawei.com>
 <f9ebfcdf-daa2-2722-1f12-fb34e24adc24@gmail.com>
 <a64b254a-d5b4-287e-1f76-ec6f8189609a@huawei.com>
 <377d3197-9b88-b95a-ae79-4348d1448f92@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <charles.chenxin@huawei.com>,
        <linuxarm@huawei.com>
To: Matthias Brugger <matthias.bgg@gmail.com>,
        Yankejian <yankejian@huawei.com>, <davem@davemloft.net>,
        <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <huangdaode@hisilicon.com>, <zhouhuiru@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:2527 "EHLO
        dggrg04-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1165482AbdDYIXD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 04:23:03 -0400
In-Reply-To: <377d3197-9b88-b95a-ae79-4348d1448f92@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/4/24 22:47, Matthias Brugger wrote:
>
>
> On 24/04/17 13:43, lipeng (Y) wrote:
>>
>>
>> On 2017/4/24 18:28, Matthias Brugger wrote:
>>> On 21/04/17 09:44, Yankejian wrote:
>>>> From: lipeng <lipeng321@huawei.com>
>>>>
>>>> In the hip06 and hip07 SoCs, the interrupt lines from the
>>>> DSAF controllers are connected to mbigen hw module.
>>>> The mbigen module is probed with module_init, and, as such,
>>>> is not guaranteed to probe before the HNS driver. So we need
>>>> to support deferred probe.
>>>>
>>>> We check for probe deferral in the hw layer probe, so we not
>>>> probe into the main layer and memories, etc., to later learn
>>>> that we need to defer the probe.
>>>>
>>>
>>> Why? This looks like a hack.
>>> From what I see, we can handle EPROBE_DEFER easily inside hns_ppe_init
>>> checking the return value of hns_rcb_get_cfg. Like you do in 2/3 of
>>> this series.
>>>
>>> Regards,
>>> Matthias
>> Hi Matthias,
>>
>> mdio && phy is not necessary condition, and port can work well  for port
>> + SFP (without mdio &&phy).
>>
>> BUT irq is the necessary condition,  port can not work well without irq.
>>
>> So, I check IRQ first,and do not probe dsaf if can't obtain irq(1/3 of
>> this series),   and check mdio only when there is phy(2/3 of this 
>> series).
>>
>> And thanks for your review.
>
> I think I didn't explained myself good enough.
> I was suggesting the following (not even compile tested):
>
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c 
> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
> index eba406bea52f..be38d47bc399 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
> @@ -510,7 +510,9 @@ int hns_ppe_init(struct dsaf_device *dsaf_dev)
>
>                 hns_ppe_get_cfg(dsaf_dev->ppe_common[i]);
>
> -               hns_rcb_get_cfg(dsaf_dev->rcb_common[i]);
> +               ret = hns_rcb_get_cfg(dsaf_dev->rcb_common[i]);
> +               if (reg < 0)
> +                       goto get_cfg_fail;
>         }
>
>         for (i = 0; i < HNS_PPE_COM_NUM; i++)
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c 
> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> index c20a0f4f8f02..c7e801d0c3b7 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> @@ -492,7 +492,7 @@ static int hns_rcb_get_base_irq_idx(struct 
> rcb_common_cb *rcb_common)
>   *hns_rcb_get_cfg - get rcb config
>   *@rcb_common: rcb common device
>   */
> -void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
> +int hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
>  {
>         struct ring_pair_cb *ring_pair_cb;
>         u32 i;
> @@ -517,10 +517,18 @@ void hns_rcb_get_cfg(struct rcb_common_cb 
> *rcb_common)
>                 ring_pair_cb->virq[HNS_RCB_IRQ_IDX_RX] =
>                 is_ver1 ? platform_get_irq(pdev, base_irq_idx + i * 2 
> + 1) :
>                           platform_get_irq(pdev, base_irq_idx + i * 3);
> +
> +               if ((ring_pair_cb->virq[HNS_RCB_IRQ_IDX_TX] == 
> -EPROBE_DEFER) ||
> +                   (ring_pair_cb->virq[HNS_RCB_IRQ_IDX_RX] == 
> -EPROBE_DEFER)) {
> +                       return -EPROBE_DEFER;
> +               }
> +
>                 ring_pair_cb->q.phy_base =
>
> RCB_COMM_BASE_TO_RING_BASE(rcb_common->phy_base, i);
>                 hns_rcb_ring_pair_get_cfg(ring_pair_cb);
>         }
> +
> +       return 0;
>  }
>
>  /**
>
>
> Regards,
> Matthias
Thanks,  I will take your advice and test it.

>
>>
>> lipeng
>>
>>>
>>>> Signed-off-by: lipeng <lipeng321@huawei.com>
>>>> Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
>>>> ---
>>>>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 12 ++++++++++++
>>>>  1 file changed, 12 insertions(+)
>>>>
>>>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
>>>> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
>>>> index 403ea9d..2da5b42 100644
>>>> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
>>>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
>>>> @@ -2971,6 +2971,18 @@ static int hns_dsaf_probe(struct
>>>> platform_device *pdev)
>>>>      struct dsaf_device *dsaf_dev;
>>>>      int ret;
>>>>
>>>> +    /*
>>>> +     * Check if we should defer the probe before we probe the
>>>> +     * dsaf, as it's hard to defer later on.
>>>> +     */
>>>> +    ret = platform_get_irq(pdev, 0);
>>>> +    if (ret < 0) {
>>>> +        if (ret != -EPROBE_DEFER)
>>>> +            dev_err(&pdev->dev, "Cannot obtain irq\n");
>>>> +
>>>> +        return ret;
>>>> +    }
>>>> +
>>>>      dsaf_dev = hns_dsaf_alloc_dev(&pdev->dev, sizeof(struct
>>>> dsaf_drv_priv));
>>>>      if (IS_ERR(dsaf_dev)) {
>>>>          ret = PTR_ERR(dsaf_dev);
>>>>
>>>
>>> .
>>>
>>
> .
>
