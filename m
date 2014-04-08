From: zhangfei <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Tue, 08 Apr 2014 22:47:25 +0800
Message-ID: <53440BFD.3000805@linaro.org>
References: <1396672506-9296-1-git-send-email-zhangfei.gao@linaro.org>	<1396672506-9296-4-git-send-email-zhangfei.gao@linaro.org> <20140407.145356.928382660541891827.davem@davemloft.net> <5343AE45.4020308@linaro.org> <063D6719AE5E284EB5DD2968C1650D6D0F6F1434@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org" <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	"arnd-r2nGTMty4D4@public.gmane.org" <arnd-r2nGTMty4D4@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org"
	<sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	"mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6F1434-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear David,

On 04/08/2014 04:30 PM, David Laight wrote:
> From: zhangfei [mailto:zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org]
>> On 04/08/2014 02:53 AM, David Miller wrote:
>>> From: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>>> Date: Sat,  5 Apr 2014 12:35:06 +0800
>>>
>>>> +struct tx_desc {
>>>> +	u32 send_addr;
>>>> +	u16 reserved_16;
>>>> +	u16 send_size;
>
> The above doesn't look right for endianness independence.
> I'd guess the hardware spec shows a 32bit word with the 'send size'
> in one half - that is what you need to define.
>
> Since this is a tx descriptor (and written by the host) you
> can't have 'reserved' field - the host has to write it.
> probably these are 'must be zero' fields.

Yes, it is not endianness independence.
In fact, we have switched the layout since it is u16 for doing the 
switch endianness.

The reserved_16 is the part not used.
So it is simpler to define u32 here.
If upper 16 bits also need to be set, usually we still use the u32, and 
organize dynamically, right?

>
>>>> +	u32 reserved_32;
>>>> +	u32 cfg;
>>>> +	u32 wb_addr;
>>>> +} ____cacheline_aligned;
>>>
>>> I do not think that ____cacheline_aligned is appropriate at all here.
>>>
>>> First of all, this is a hardware descriptor, so it has a fixed layout
>>> and therefore size.
>
> The structure also isn't even a multiple of a power of two.
> So there will be implicit padding at the end.
>
> Since there isn't a 'pointer to next' I presume the hardware accesses
> the descriptors from adjacent physical addresses.
> So you need to explicitly pad to that size.
> If the cache line size were 128 byte the above wouldn't work at all.
Yes, __aligned(64) can be used here, when I though directly use 64 is 
not good.
The requirement is desc address should be align to 0x40, since desc phys 
is send to register whose [31:6] is used.

>
>>>
>>> Secondly, unless you declare this object statically in the data section
>>> of the object file, the alignment doesn't matter.  These descriptors
>>> are always dynamically allocated, rather than instantiated in the
>>> kernel/driver image.
>>
>> The ____cacheline_aligned used here is only for the requirement of
>> alignment, and use dma_alloc_coherent, while at first dma_pool is used
>> for the requirement of alignment.
>> Otherwise desc[1] is not aligned and can not be used directly, the
>> structure is smaller.
>
> It sounds like you should be explicitly padding the structure
> to 32 bytes - whether or not that is the cache line size.
Got it, understand now.

>
> ...
>> I am sorry, but unfortunately this series really does NOT have TX done
>> interrupt after checked with hardware guy many times.
>> And next series will add TX done interrupt according to the feedback.
>>
>> There are two reasons of removing the TX done interrupt when the chip is
>> designed.
>> 1. The specific product does not care the latency, only care the throughput.
>> 2. When doing many experiment, the tx done interrupt will impact the
>> throughput, as a result reclaim is moved to xmit as one of
>> optimizations, then finally tx done interrupt is removed at all.
>>
>> Is it acceptable of removing timer as well as latency handling, or any
>> other work around of this kind of hardware?
>
> If you don't have a global 'TX done' interrupt, you need a per
> descriptor one.
> Otherwise you cannot send at maximum rate in the absence of
> receive traffic.
>

Global 'TX done' interrupt means interrupt for desc chain (several desc 
link together), right?
There is no interrupt for either desc chain or single desc.

By the way, if single desc interrupt, is it can be optimized like napi, 
disable the interrupt and re-enable the interrupt until all buffers are 
reclaimed?

Thanks
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
