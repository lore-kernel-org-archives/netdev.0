From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH] skbuff: align sk_buff::cb to 64 bit
Date: Sat, 30 Jan 2010 00:09:14 +0100
Message-ID: <4B636A9A.2020803@openwrt.org>
References: <4B635CA1.8070803@openwrt.org> <4B63643B.3070400@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:54042 "EHLO ds10.nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869Ab0A2XJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 18:09:16 -0500
In-Reply-To: <4B63643B.3070400@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-01-29 11:42 PM, David Daney wrote:
> Felix Fietkau wrote:
>> The alignment requirement for 64-bit load/store instructions on ARM is
>> implementation defined. Some CPUs (such as Marvell Feroceon) do not
>> generate an exception, if such an instruction is executed with an
>> address that is not 64 bit aligned. 
>> In such a case, the Feroceon corrupts adjacent memory, which showed up
>> in my tests as a crash in the rx path of ath9k that only occured with
>> CONFIG_XFRM set. This crash happened, because the first field of the
>> mac80211 rx status info in the cb is an u64, and changing it corrupted
>> the skb->sp field.
>> 
>> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
>> Cc: stable@kernel.org
>> ---
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -329,7 +329,7 @@ struct sk_buff {
>>  	 * want to keep them across layers you have to do a skb_clone()
>>  	 * first. This is owned by whoever has the skb queued ATM.
>>  	 */
>> -	char			cb[48];
>> +	char			cb[48] __attribute__((aligned(8)));
>>  
> 
> 
> s/__attribute__((aligned(8)))/__aligned(8)/
OK. Will send a v2.

> Could the same thing be achieved by swapping the order of the dev and 
> tstamp fields instead of adding the alignment attribute?
> 
> What is the sizeof(void *) on this thing?
sizeof(void *) == 4
This is a 32 bit arch, which happens to have 64-bit load/store ops,
which the compiler emits where appropriate.
Reordering the dev and tstamp does not help, as the cb gets moved by 4
bytes, depending on whether CONFIG_XFRM is set or unset.
As far as I know, ARM EABI requires an 8 byte alignment anyway, so I
think it's better to make this explicit, since cb[] is meant to be used
as opaque storage for other data structures.

- Felix
