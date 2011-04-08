From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH] igb: restore EEPROM 16kB access limit
Date: Fri, 8 Apr 2011 13:10:30 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F0137E85E47@orsmsx508.amr.corp.intel.com>
References: <1302269695-27188-1-git-send-email-sassmann@kpanic.de>
 <EDC0E76513226749BFBC9C3FB031318F0137E85A8E@orsmsx508.amr.corp.intel.com>
 <4D9F6A44.7060809@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28341 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757840Ab1DHUKc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 16:10:32 -0400
In-Reply-To: <4D9F6A44.7060809@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Stefan Assmann [mailto:sassmann@kpanic.de]
>Sent: Friday, April 08, 2011 1:04 PM
>To: Wyborny, Carolyn
>Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net; Kirsher,
>Jeffrey T; Pieper, Jeffrey E; Ronciak, John
>Subject: Re: [PATCH] igb: restore EEPROM 16kB access limit
>
>On 08.04.2011 18:40, Wyborny, Carolyn wrote:
>>
>>
>>> -----Original Message-----
>>> From: Stefan Assmann [mailto:sassmann@kpanic.de]
>>> Sent: Friday, April 08, 2011 6:35 AM
>>> To: netdev@vger.kernel.org
>>> Cc: e1000-devel@lists.sourceforge.net; Kirsher, Jeffrey T; Pieper,
>>> Jeffrey E; Wyborny, Carolyn; Ronciak, John
>>> Subject: [PATCH] igb: restore EEPROM 16kB access limit
>>>
>>> The check limiting the EEPROM access up to 16kB was removed by
>>> commit 4322e561a93ec7ee034b603a6c610e7be90d4e8a. Without this check
>>> the kernel will try to checksum the EEPROM up to 2MB (observed with
>>> a 8086:10c9 NIC) and fail.
>>>
>>> igb 0000:03:00.0: 0 vfs allocated
>>> igb 0000:03:00.0: The NVM Checksum Is Not Valid
>>> ACPI: PCI interrupt for device 0000:03:00.0 disabled
>>> igb: probe of 0000:03:00.0 failed with error -5
>>>
>>> Reason for that being an overflow in u16 e1000_nvm_info->nvm
>>> while doing "nvm->word_size = 1 << size;" with size == 21.
>>> Putting the check back in place.
>>>
>>> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
>>> ---
>>> drivers/net/igb/e1000_82575.c |    4 ++++
>>> 1 files changed, 4 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/drivers/net/igb/e1000_82575.c
>>> b/drivers/net/igb/e1000_82575.c
>>> index 6b256c2..5cfa37f 100644
>>> --- a/drivers/net/igb/e1000_82575.c
>>> +++ b/drivers/net/igb/e1000_82575.c
>>> @@ -244,6 +244,10 @@ static s32 igb_get_invariants_82575(struct
>e1000_hw
>>> *hw)
>>> 	 */
>>> 	size += NVM_WORD_SIZE_BASE_SHIFT;
>>>
>>> +	/* EEPROM access above 16k is unsupported */
>>> +	if (size > 14)
>>> +		size = 14;
>>> +
>>> 	nvm->word_size = 1 << size;
>>> 	if (nvm->word_size == (1 << 15))
>>> 		nvm->page_size = 128;
>>> --
>>> 1.7.4
>> NACK
>>
>> This doesn't apply against current upstream RC kernel.  There was more
>changed in that commit than just the removal of this.  There is a
>missing section of code that is needed, but not this.  This starts at
>line 251 in e1000_82575.c
>
>Carolyn,
>
>the patch applies against latest net-next-2.6
>(782d640afd15af7a1faf01cfe566ca4ac511319d).
>
>How do you explain the behaviour observed in the patch description?
>
>>
>> --snip--
>>         /* NVM Function Pointers */
>>         nvm->ops.acquire = igb_acquire_nvm_82575;
>>         if (nvm->word_size < (1 << 15))
>>                 nvm->ops.read = igb_read_nvm_eerd;
>>         else
>>                 nvm->ops.read = igb_read_nvm_spi;
>> --snip--
>
>Ok, so I assume some new NICs allow access beyond the 16k boundary.
>In that case we should identify which NICs and treat them separately,
>keeping the behaviour identical for the others.
>
>  Stefan

Yes, there's more code changed than just the removal of what you're trying to add back.  The snip is the replacement but those function need to exist as well.  I believe that the commit referenced did not completely apply and you're missing some critical code.  The problem you are seeing should not occur with full patch.

The version of e1000_82575.c in 2.6.39-rc2 has all the changes needed for this to work correctly.

Carolyn

