From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: allocate mac filtering pending list
 in PAGE_SIZE increments
Date: Tue, 20 Sep 2016 10:52:20 -0400
Message-ID: <57E14D24.40504@akamai.com>
References: <cover.1474060371.git.jbaron@akamai.com>
 <d46b4fa36c32affff20fcc92148e33ee6176f899.1474060371.git.jbaron@akamai.com>
 <BL2PR07MB2306CEA6AD75D9D4EB77FB1F8DF50@BL2PR07MB2306.namprd07.prod.outlook.com>
 <57E02F82.9060903@akamai.com>
 <BL2PR07MB23061EAE5CF41EE56A1ED99B8DF70@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:46404 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753483AbcITOwW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 10:52:22 -0400
In-Reply-To: <BL2PR07MB23061EAE5CF41EE56A1ED99B8DF70@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/20/2016 03:41 AM, Mintz, Yuval wrote:
>>>> Currently, we can have high order page allocations that specify
>>>> GFP_ATOMIC when configuring multicast MAC address filters.
>>>>
>>>> For example, we have seen order 2 page allocation failures with
>>>> ~500 multicast addresses configured.
>>>>
>>>> Convert the allocation for the pending list to be done in PAGE_SIZE
>>>> increments.
>>>>
>>>> Signed-off-by: Jason Baron <jbaron@akamai.com>
>>>
>>> While I appreciate the effort, I wonder whether it's worth it:
>>>
>>> - The hardware [even in its newer generation] provides an approximate
>>> based classification [I.e., hashed] with 256 bins.
>>> When configuring 500 multicast addresses, one can argue the difference
>>> between multicast-promisc mode and actual configuration is
>>> insignificant.
>>
>> With 256 bins, I think it takes close to: 256*lg(256) or 2,048 multicast addresses
>> to expect to have all bins have at least one hash, assuming a uniform distribution
>> of the hashes.
>>
>>> Perhaps the easier-to-maintain alternative would simply be to
>>> determine the maximal number of multicast addresses that can be
>>> configured using a single PAGE, and if in need of more than that
>>> simply move into multicast-promisc.
>>>
>>
>> sizeof(struct bnx2x_mcast_list_elem) = 24. So there are 170 per page on x86. So
>> if we want to fit 2,048 elements, we need 12 pages.
>
> That's not exactly what I mean - let's assume you'd have problems
> allocating more than a PAGE. According to your calculation, that
> means you're already using more than 170 multicast addresses.
> I didn't bother trying to solve the combinatorics question of how
> many bins you'd use on average for 170 filters given there are only
> 256 bins, but that would be a significant portion.

On average for 170 filters, I get an average of 124 bins in use out
of 256 possible bins.

> The question I rose was whether it actually makes a difference
> under such circumstances whether the device would actually filter
> those multicast addresses or be completely multicast promiscuous.
> e.g., whether it's significant to be filtering out multicast ingress
> traffic when you're already allowing 1/2 of all random multicast
> packets to be classified for the interface.
>

Agreed, I think this is the more interesting question here. I thought 
that we would want to make sure we are using most of the bins before 
falling back to multicast ingress. The reason being that even if its 
more expensive for the NIC to do the filtering than the multicast mode, 
it would be more than made up for by having to drop the traffic higher 
up the stack. So I think if we can determine the percent of the bins 
that we want to use, we can then back into the average number of filters 
required to get there. As I said, I thought we would want to make sure 
we filled basically all the bins (with a high probability that is) 
before falling back to multicast, and so I threw out 2,048.

Thanks,

-Jason
