From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [PATCHv2 bluetooth-next 04/10] ndisc: add addr_len parameter to
 ndisc_opt_addr_space
Date: Sun, 8 May 2016 12:39:40 +0200
Message-ID: <cdf01ed0-2cc1-667d-40ef-34dcaddce099@pengutronix.de>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-5-git-send-email-aar@pengutronix.de>
 <109698cb-18ae-abdb-34a5-1db5a2e8dc6b@stressinduktion.org>
 <800c5c08-c2c8-3b44-d457-cdcf6374f280@pengutronix.de>
 <240084aa-2751-6f24-c07b-662b19a74475@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, stefan@osg.samsung.com,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:56653 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750734AbcEHKk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 06:40:28 -0400
In-Reply-To: <240084aa-2751-6f24-c07b-662b19a74475@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 05/07/2016 12:23 AM, Hannes Frederic Sowa wrote:
> On 04.05.2016 14:30, Alexander Aring wrote:
>> Hi,
>>
>> On 05/02/2016 09:37 PM, Hannes Frederic Sowa wrote:
>>> On 20.04.2016 10:19, Alexander Aring wrote:
>>>> This patch makes the address length as argument for the
>>>> ndisc_opt_addr_space function. This is necessary to handle addresses
>>>> which don't use dev->addr_len as address length.
>>>
>>> Would it make sense for patch 4, 5 and 6 to add the operation to ndisc_ops?
>>>
>>
>> not sure if I understand this question right,
>>
>> We have now the ndisc_ops where we can could change the send/recv of
>> NS/NA, also is_useropt (for add 6CO RA is userspace option field).
>>
>> In case of 802.15.4 we have two MAC addresses with different length:
>>
>>  - extended address - 8 bytes => EUI64
>>  - short address - 2 bytes
>>
>> Now [0] describes how to make the source/target address option for
>> NS/NA/RS/RA/... to deal with both addresses.
>>
>> The short address is a special case in 802.15.4 and not always
>> available. If available we add both addresses as option field in
>> NS/NA (RS/RA will follow in future, but currently NS/NA only).
>>
>> At this point the understanding of [0] differs in 6LoWPAN
>> implementations.
>>
>> Some people handles it like:
>>
>> Handle the short address/extended address in XOR case of 6LoWPAN
>> interface. The interface has as MAC address the extended XOR short (if
>> available), depends on setting.
>>
>> Then dev->addr_len is 8 XOR 2.
>>
>> Other people (inclusive me) handle it like:
>>
>> Handle the short/extended address in case of OR, but never short address
>> alone. The interface can be accessed by extended address or short
>> address and each neighbour stores both information.
>>
>> The case "short address never alone" means that the extended address is
>> always available and MUST be there.
>>
>> Furthermore, depends on L3 addressing it could be useful to have the
>> possibility to decide if using or short OR extended address as L2 address
>> for do better compressing stuff.
>>
>> ---
>>
>> I implement it as OR case, so we add both addresses when short address
>> is available. Also we drop NS/NA when the short address is given only,
>> in theory we could also react on this and store a "dummy" 0x00..00
>> address for extended address then.
>>
>> Not sure how it need to be handled correctly, for now I implemented how
>> I understand it.
>>
>> In case of the OR case, we need to add two option fields for the
>> address, extended and short. This is why I do the calculation stuff more
>> accessible with different address lengths, so we can use 8 or 2 and not
>> dev->addr_len which stores always the 802.15.4 EUI64 address length.
>>
>> And the answer would be, no it makes no sense because we need to call
>> these functions with 8 (dev->addr_len) and 2 (if short addr is
>> available).
> 
> I had to understand the usage in patch 9. It seems you are right, the
> decision cannot be done based on the protocol alone but based on the
> context, so we need to pass in different lengths based on the context.
> Thanks for your explanation.
> 
> I would still suggest to not use net_device as an argument but just the
> type and length to keep the API cleaner, but this is not a strong opinion.
> 

yes, I agree. I will try to change it without any dev argument.

The general question would also here, if we just not "simple" support
for general IPv6 implementation a mapping where:

L2+ (in meaning of one or more) addresses <-> one L3 address

Which means e.g. two ethernet addresses can be mapped to one L3 address.
I don't know if this makes sense somehow, but I have such use-case for
802.15.4 but it's even complicated because different address lengths.

Additional to this feature, we add also supporting of multiple L2
addresses for a net_device with different address lengths.

---

I wrote "simple" but it isn't simple, but I suppose the truly mainline
solution.

What I did in the patch series to store short address in neighbour
private data, which makes everything 802.15.4 6lowpan specific. We
currently store the short address as part of 802.15.4 interface type
in netdev_priv also.

This requires lot of changes which are not easy, also dev_hard_header
callback does not contain any length information in context when calling
this function. Btw: 0xffff (short address) in 802.15.4 is the broadcast
address, which currently works because a workaround by mapping 0xff..ff
dev->broadcast (8 bytes) to 0xffff short.

Big question is also if it's valid to make such mapping in all link-layers
e.g. ethernet, because Linux filters multiple target/source link address
option fields in NS/NA/RS/etc. Anyway could be also some flag if valid
or not.

I think this more something for future, because it's really big work. :-)

- Alex
