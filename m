From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v2 0/2] net: ethernet: ti: cpsw: delete rx_descs property
Date: Mon, 13 Jun 2016 13:52:25 +0530
Message-ID: <575E6D41.8080806@ti.com>
References: <1465307976-12235-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <5756E7A8.6090703@ti.com> <57582535.5020608@linaro.org>
 <57582650.5010409@linaro.org> <5758A625.3090707@ti.com>
 <5758B236.5000401@linaro.org> <575B4780.9050103@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <grygorii.strashko-l0cyMroinI0@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Schuyler Patton <spatton-l0cyMroinI0@public.gmane.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <575B4780.9050103-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 11 June 2016 04:34 AM, Schuyler Patton wrote:
> 
> 
> On 06/08/2016 07:03 PM, Ivan Khoronzhuk wrote:
>>
>>
>> On 09.06.16 02:11, Schuyler Patton wrote:
>>>
>>>
>>> On 06/08/2016 09:06 AM, Ivan Khoronzhuk wrote:
>>>>
>>>>
>>>> On 08.06.16 17:01, Ivan Khoronzhuk wrote:
>>>>> Hi Schuyer,
>>>>>
>>>>> On 07.06.16 18:26, Schuyler Patton wrote:
>>>>>> Hi,
>>>>>>
>>>>>> On 06/07/2016 08:59 AM, Ivan Khoronzhuk wrote:
>>>>>>> There is no reason in rx_descs property because davinici_cpdma
>>>>>>> driver splits pool of descriptors equally between tx and rx
>>>>>>> channels.
>>>>>>> So, this patch series makes driver to use available number of
>>>>>>> descriptors for rx channels.
>>>>>>
>>>>>> I agree with the idea of consolidating how the descriptors are
>>>>>> defined because of
>>>>>> the two variable components, number and size of the pool can be
>>>>>> confusing to
>>>>>> end users. I would like to request to change how it is being
>>>>>> proposed here.
>>>>>>
>>>>>> I think the number of descriptors should be left in the device
>>>>>> tree source file as
>>>>>> is and remove the BD size variable and have the driver calculate
>>>>>> the size of the
>>>>>> pool necessary to support the descriptor request. From an user
>>>>>> perspective it is
>>>>>> easier I think to be able to list the number of descriptors
>>>>>> necessary vs. the size
>>>>>> of the pool.
>>>>>>
>>>>>> Since the patch series points out how it is used so in the driver
>>>>>> so to make that
>>>>>> consistent is perhaps change rx_descs to total_descs.
>>>>>>
>>>>>> Regards,
>>>>>> Schuyler
>>>>>
>>>>> The DT entry for cpsw doesn't have property for size of the pool.
>>>>> It contains only BD ram size, if you mean this. The size of the
>>>>> pool is
>>>>> software decision. Current version of DT entry contain only rx desc
>>>>> number.
>>>>> That is not correct, as it depends on the size of the descriptor,
>>>>> which is also
>>>>> h/w parameter. The DT entry has to describe only h/w part and
>>>>> shouldn't contain
>>>>> driver implementation details, and I'm looking on it from this
>>>>> perspective.
>>>>>
>>>>> Besides, rx_descs describes only rx number of descriptors, that are
>>>>> taken from
>>>>> the same pool as tx descriptors, and setting rx desc to some new
>>>>> value doesn't
>>>>> mean that rest of them are freed for tx. Also, I'm going to send
>>>>> series that
>>>>> adds multi channel support to the driver, and in this case,
>>>>> splitting of the
>>>>> pool will be more sophisticated than now, after what setting those
>>>>> parameters
>>>>> for user (he should do this via device tree) can be even more
>>>>> confusing. But,
>>>> should -> shouldn't
>>>>
>>>>> as it's supposed, it's software decision that shouldn't leak to the
>>>>> DT.
>>>
>>> If this rx-desc field is removed how will the number of descriptors
>>> be set?
>>>
>>> This field has been used to increase the number of descriptors so high
>>> volume short packets are not dropped due to descriptor exhaustion.
>>> The current
>>> default number of 64 rx descriptors is too low for gigabit networks.
>>> Some users
>>> have a strong requirement for zero loss of UDP packets setting this
>>> field to a
>>> larger number and setting the descriptors off-chip was a means to solve
>>> the problem.
>> The current implementation of cpdma driver splits descs num on 2 parts
>> equally.
>> Total number = 256, then 128 reserved for rx and 128 for tx, but
>> setting this to
>> 64, simply limits usage of reserved rx descriptors to 64, so that:
>> 64 rx descs, 128 tx descs and 64 are always present in the pool but
>> cannot be used,
>> (as new rx descriptor is allocated only after previous was freed).
>> That means, 64 rx descs are unused. In case of rx descriptor
>> exhaustion, an user can
>> set rx_descs to 128, for instance, in this case all descriptors will
>> be in use, but then question,
>> why intentionally limit number of rx descs, anyway rest 64 descs
>> cannot be used for other
>> purposes. In case of this patch, all rx descs are in use, and no need
>> to correct number
>> of rx descs anymore, use all of them....and it doesn't have impact on
>> performance, as
>> anyway, bunch of rx descs were simply limited by DT and unused. So,
>> probably, there is no
>> reason to worry about that.
> 
> When we see this issue we set the descriptors to DDR and put a large number
> in the desc count. unfortunately I wish I could provide a number,
> usually the issue
> is a volume burst of short UDP packets.
> 
>>
>> PS:
>> It doesn't concern this patch, but, which PPS makes rx descs to be
>> exhausted?...
>> (In this case "desc_alloc_fail" counter contains some value for rx
>> channel,
>> and can be read with "ethtool -S eth0". Also, the user will be WARNed
>> ON by the driver)
>>
>> it's interesting to test it, I'm worrying about, because in case of
>> multichannel,
>> the pool is split between all channels... they are throughput limited,
>> but
>> anyway, it's good to correlate the number of descs with throughput
>> assigned to
>> a channel, if possible. That has to be possible, if setting to 128
>> helps, then
>> has to be value between 64 and 128 to make handling of rx packets fast
>> enough.
>> After what, can be calculated correlation between number of rx descs
>> and throughput
>> split between channels....
> 
> With gigabit networks 64 or 128 rx descriptors is not going to enough to
> fix the
> DMA overrun problem. Usually we set this number to an arbitrarily large
> 2000
> descriptors in external DDR to demonstrate it is possible to not drop
> packets. All
> this does is move the problem higher up so that the drops occur in network
> stack if the ARM is overloaded. With the high speed networks I would like
> to propose that the descriptor pool or pools are moved to DDR by
> default. It would
> be nice to have some reconfigurability or set a pool size that reduces
> or eliminates
> the DMA issue that is seen in these types of applications.
> 
> This test gets used a lot, which is to send very short UDP packets. If I
> have the math
> right, a 52 byte (64 byte with the inter-frame gap) UDP packet the
> default 64
> descriptors gets consumed in roughly 33uS. There are the switch fifos
> which will also
> allow some headroom, but a user was dropping packets at the switch when
> they
> were bursting 360 packets at the processor on a gigabit link
> 

I too agree that rx-descs can be derived from the pool size and
descriptor size in driver itself. The current driver uses bd_ram_size to
set the pool size when the descriptors are placed in DDR which is wrong.

Here I propose an idea to solve Schuyler's concern to keep the
descriptors in DDR when a system need more rx descriptors for lossless
UDB performance.

The DT property rx-descs can be removed and add a new DT property
*pool_size* to add support for descriptors memory size in DDR and define
a pool size which the system needs for a network to have lossless UDP
transfers.

So based on no_bd_ram DT entry, the driver can decide whether it can use
internal BD-ram or DDR to initialize the cpdma driver.

Regards
Mugunthan V N
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
