From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: allocate mac filtering pending list
 in PAGE_SIZE increments
Date: Mon, 19 Sep 2016 14:33:38 -0400
Message-ID: <57E02F82.9060903@akamai.com>
References: <cover.1474060371.git.jbaron@akamai.com>
 <d46b4fa36c32affff20fcc92148e33ee6176f899.1474060371.git.jbaron@akamai.com>
 <BL2PR07MB2306CEA6AD75D9D4EB77FB1F8DF50@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:14196 "EHLO
        prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932237AbcISSdl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 14:33:41 -0400
In-Reply-To: <BL2PR07MB2306CEA6AD75D9D4EB77FB1F8DF50@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2016 06:25 AM, Mintz, Yuval wrote:
>> Currently, we can have high order page allocations that specify
>> GFP_ATOMIC when configuring multicast MAC address filters.
>>
>> For example, we have seen order 2 page allocation failures with
>> ~500 multicast addresses configured.
>>
>> Convert the allocation for the pending list to be done in PAGE_SIZE
>> increments.
>>
>> Signed-off-by: Jason Baron <jbaron@akamai.com>
>
> While I appreciate the effort, I wonder whether it's worth it:
>
> - The hardware [even in its newer generation] provides an approximate
> based classification [I.e., hashed] with 256 bins.
> When configuring 500 multicast addresses, one can argue the
> difference between multicast-promisc mode and actual configuration
> is insignificant.

With 256 bins, I think it takes close to: 256*lg(256) or 2,048
multicast addresses to expect to have all bins have at least one hash, 
assuming a uniform distribution of the hashes.

> Perhaps the easier-to-maintain alternative would simply be to
> determine the maximal number of multicast addresses that can be
> configured using a single PAGE, and if in need of more than that
> simply move into multicast-promisc.
>

sizeof(struct bnx2x_mcast_list_elem) = 24. So there are 170 per
page on x86. So if we want to fit 2,048 elements, we need 12 pages.

>   - While GFP_ATOMIC is required in this flow due to the fact it's being
> called from sleepless context, I do believe this is mostly a remnant -
> it's possible that by slightly changing the locking scheme we can have
> the configuration done from sleepless context and simply switch to
> GFP_KERNEL instead.
>

Ok if its GFP_KERNEL, I think its still undesirable to do large page 
order allocations (unless of course its converted to a single page, but
I'm not sure this makes sense as mentioned).

> Regarding the patch itself, only comment I have:
>> +			elem_group = (struct bnx2x_mcast_elem_group *)
>> +				     elem_group->mcast_group_link.next;
> Let's use list_next_entry() instead.
>
>

Yes, agreed.

I think it would be easy to add a check to bnx2x_set_rx_mode_inner() to
enforce some maximum number of elements (perhaps 2,048 based on the
above math) for the !CHIP_IS_E1() case on top of what I already posted.

Thanks,

-Jason
