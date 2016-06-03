From: Ivan Khoronzhuk <ivan.khoronzhuk-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: remove rx_descs property
Date: Fri, 3 Jun 2016 22:36:14 +0300
Message-ID: <5751DC2E.5060405@linaro.org>
References: <1464907420-19694-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <5751B562.8020708@ti.com> <5751CB80.4060802@linaro.org>
 <5751D6E0.5040207@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>, mugunthanvnm-l0cyMroinI0@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5751D6E0.5040207-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 03.06.16 22:13, Grygorii Strashko wrote:
> On 06/03/2016 09:25 PM, Ivan Khoronzhuk wrote:
>>
>>
>> On 03.06.16 19:50, Grygorii Strashko wrote:
>>> On 06/03/2016 01:43 AM, Ivan Khoronzhuk wrote:
>>>> There is no reason to hold s/w dependent parameter in device tree.
>>>> Even more, there is no reason in this parameter because davinici_cpdma
>>>> driver splits pool of descriptors equally between tx and rx channels.
>>>> That is, if number of descriptors 256, 128 of them are for rx
>>>> channels. While receiving, the descriptor is freed to the pool and
>>>> then allocated with new skb. And if in DT the "rx_descs" is set to
>>>> 64, then 128 - 64 = 64 descriptors are always in the pool and cannot
>>>> be used, for tx, for instance. It's not correct resource usage,
>>>> better to set it to half of pool, then the rx pool can be used in
>>>> full. It will not have any impact on performance, as anyway, the
>>>> "redundant" descriptors were unused.
>>>>
>>>> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>>>> ---
>>>>
>>>> Based on master
>>>>
>>>>    Documentation/devicetree/bindings/net/cpsw.txt |  3 ---
>>>>    arch/arm/boot/dts/am33xx.dtsi                  |  1 -
>>>>    arch/arm/boot/dts/am4372.dtsi                  |  1 -
>>>>    arch/arm/boot/dts/dm814x.dtsi                  |  1 -
>>>>    arch/arm/boot/dts/dra7.dtsi                    |  1 -
>>>
>>>
>>> Pls, split DT and non-DT changes, seems code changes should go first.
>> Ok.
>>
>>>
>>>>    drivers/net/ethernet/ti/cpsw.c                 | 13 +++----------
>>>>    drivers/net/ethernet/ti/cpsw.h                 |  1 -
>>>>    drivers/net/ethernet/ti/davinci_cpdma.c        |  6 ++++++
>>>>    drivers/net/ethernet/ti/davinci_cpdma.h        |  1 +
>>>>    9 files changed, 10 insertions(+), 18 deletions(-)
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt
>>>> b/Documentation/devicetree/bindings/net/cpsw.txt
>>>> index 0ae0649..5fe6239 100644
>>>> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>>>> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>>>> @@ -15,7 +15,6 @@ Required properties:
>>>>    - cpdma_channels     : Specifies number of channels in CPDMA
>>>>    - ale_entries        : Specifies No of entries ALE can hold
>>>>    - bd_ram_size        : Specifies internal descriptor RAM size
>>>> -- rx_descs        : Specifies number of Rx descriptors
>>>>    - mac_control        : Specifies Default MAC control register content
>>>>                  for the specific platform
>>>>    - slaves        : Specifies number for slaves
>>>> @@ -70,7 +69,6 @@ Examples:
>>>
>>> [....]
>>>
>>>>                slaves = <2>;
>>>>                active_slave = <0>;
>>>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>>>> b/drivers/net/ethernet/ti/cpsw.c
>>>> index 4b08a2f..635be3e 100644
>>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>>> @@ -1277,6 +1277,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
>>>>                      ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
>>>>
>>>>        if (!cpsw_common_res_usage_state(priv)) {
>>>> +        int buf_num;
>>>>            struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
>>>>
>>>>            /* setup tx dma to fixed prio and zero offset */
>>>> @@ -1305,10 +1306,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
>>>>                enable_irq(priv->irqs_table[0]);
>>>>            }
>>>>
>>>> -        if (WARN_ON(!priv->data.rx_descs))
>>>> -            priv->data.rx_descs = 128;
>>>> -
>>>> -        for (i = 0; i < priv->data.rx_descs; i++) {
>>>> +        buf_num = cpdma_chan_get_buf_num(priv->dma) / 2;
>>>
>>> Could you get rid of "/ 2", pls?
>>>
>> Why? compiler is smart enough to translate it to shift.
>> And this is not time critical place.
>> Anyway, will change it to >> 1 while splitting.
>>
>
> I mean here that cpsw, in general, should not have any knowledge about rules
>   used by cpdma to split pool on rx and tx part. How about cpdma_chan_get_rx_buf_num()?
Yes, it be correct.
Will change it in v2

>
>

-- 
Regards,
Ivan Khoronzhuk
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
