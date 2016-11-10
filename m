From: "ivan.khoronzhuk" <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH] net: ethernet: ti: davinci_cpdma: fix fixed prio cpdma
 ctlr configuration
Date: Thu, 10 Nov 2016 21:52:24 +0200
Message-ID: <1501d6bd-ef97-cfb4-f02b-2b03b97ae636@globallogic.com>
References: <1478610656-24634-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <a20ab87c-4f9d-0eaa-e486-156d9f359866@ti.com>
 <592966c0-ae4c-ba6b-43ba-8ca837e9a700@linaro.org>
 <37548a54-c54b-3194-691a-22fa8118ed3d@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        mugunthanvnm@ti.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:36101 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935677AbcKJTw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 14:52:29 -0500
Received: by mail-lf0-f43.google.com with SMTP id t196so198957272lff.3
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 11:52:28 -0800 (PST)
In-Reply-To: <37548a54-c54b-3194-691a-22fa8118ed3d@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10.11.16 18:37, Grygorii Strashko wrote:
>
>
> On 11/09/2016 05:56 PM, Ivan Khoronzhuk wrote:
>>
>>
>> On 09.11.16 23:09, Grygorii Strashko wrote:
>>>
>>>
>>> On 11/08/2016 07:10 AM, Ivan Khoronzhuk wrote:
>>>> The dma ctlr is reseted to 0 while cpdma start, thus cpdma ctlr
>>>
>>> I assume this is because cpdma_ctlr_start() does soft reset. Is it
>>> correct?
>> Probably not. I've seen this register doesn't hold any previous settings
>> (just trash)
>
> What register CPDMA_DMACONTROL or CPSW_DMACTRL?
>
>> after cpdma_ctlr_stop(), actually after last channel is stopped (inside
>> of cpdma_ctlr_stop()).
>
> So, You are stating that Registers context is changed after stop?
>
>> Then cpdma_ctlr_start() just reset it to 0.
>
> "just trash" or "0".
>
> Sry, I do not see how cpdma_ctlr_stop() can affect on registers state :(
> and I'd very appreciated if can provide more detailed information.
>
I've checked again, it was my mistake. It simply reset to 0 while soft reset.

>>
>>>
>>>> cannot be configured after cpdma is stopped. So, restore content
>>>> of cpdma ctlr while off/on procedure.
>>>>
>>>> Based on net-next/master
>>>
>>> ^ remove it
>> sure
>>
>>>
>>>>
>>>> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>>>> ---
>>>>  drivers/net/ethernet/ti/cpsw.c          |   6 +-
>>>>  drivers/net/ethernet/ti/davinci_cpdma.c | 103
>>>> +++++++++++++++++---------------
>>>>  drivers/net/ethernet/ti/davinci_cpdma.h |   2 +
>>>>  3 files changed, 58 insertions(+), 53 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>>>> b/drivers/net/ethernet/ti/cpsw.c
>>>> index b1ddf89..4d04b8e 100644
>>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>>> @@ -1376,10 +1376,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
>>>>                    ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
>>>>
>>>>      if (!cpsw_common_res_usage_state(cpsw)) {
>>>> -        /* setup tx dma to fixed prio and zero offset */
>>>> -        cpdma_control_set(cpsw->dma, CPDMA_TX_PRIO_FIXED, 1);
>>>> -        cpdma_control_set(cpsw->dma, CPDMA_RX_BUFFER_OFFSET, 0);
>>>> -
>>>>          /* disable priority elevation */
>>>>          __raw_writel(0, &cpsw->regs->ptype);
>>>>
>>>> @@ -2710,6 +2706,8 @@ static int cpsw_probe(struct platform_device
>>>> *pdev)
>>>>      dma_params.desc_align        = 16;
>>>>      dma_params.has_ext_regs        = true;
>>>>      dma_params.desc_hw_addr         = dma_params.desc_mem_phys;
>>>> +    dma_params.rxbuf_offset        = 0;
>>>> +    dma_params.fixed_prio        = 1;
>>>
>>> Do we really need this new parameters? Do you have plans to use other
>>> values?
>> I'm ok if this is static (equally as a bunch of rest in dma_params), no
>> see reason to use other values,
>
> That's what i wanted to know :) - go static, pls.
>
>> it at least now. But the issue is not only in these two parameters and
>> not only in cpsw_ndo_open().
>> It touches cpsw_set_channels() also, where ctlr stop/start is present.
>> In order to not copy cpdma_control_set(cpsw->dma, CPDMA_TX_PRIO_FIXED,
>> 1)...
>> in all such kind places in eth drivers, better to allow the cpdma to
>> control it's parameters...
>>
>> The cpdma ctlr register holds a little more parameters (but only two of
>> them are set in cpsw)
>> Maybe there is reason to save them also. Actually I'd seen this problem
>> when playing with
>> on/off channel shapers, unfortunately the cpdma ctlr holds this info
>> also, and it was lost
>> while on/off (but I'm going to restore it in chan_start()).
>>
>
> I understand you change, but I'm note sure about real root cause :(
so, are you Ok with current version?

>
