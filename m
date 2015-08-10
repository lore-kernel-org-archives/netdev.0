From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [PATCH v3 18/20] net/xen-netback: Make it running on 64KB page
 granularity
Date: Mon, 10 Aug 2015 10:57:48 +0100
Message-ID: <55C8759C.3010507@citrix.com>
References: <1438966019-19322-1-git-send-email-julien.grall@citrix.com>
 <1438966019-19322-19-git-send-email-julien.grall@citrix.com>
 <20150808145534.GB14214@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150808145534.GB14214@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wei,

On 08/08/2015 15:55, Wei Liu wrote:
>>   struct xenvif_rx_meta {
>>   	int id;
>> @@ -80,16 +81,18 @@ struct xenvif_rx_meta {
>>   /* Discriminate from any valid pending_idx value. */
>>   #define INVALID_PENDING_IDX 0xFFFF
>>
>> -#define MAX_BUFFER_OFFSET PAGE_SIZE
>> +#define MAX_BUFFER_OFFSET XEN_PAGE_SIZE
>>
>>   #define MAX_PENDING_REQS XEN_NETIF_TX_RING_SIZE
>>
>> +#define MAX_XEN_SKB_FRAGS (65536 / XEN_PAGE_SIZE + 1)
>> +
>
> It might be clearer if you add a comment saying the maximum number of
> frags is derived from the page size of the grant page, which happens to
> be XEN_PAGE_SIZE at the moment.

Will do.


> In the future we need to figure out the page size of grant page in a
> dynamic way. We shall cross the bridge when we get there.

Right, there is few other places where we would need to do that too (see 
MAX_BUFFER_OFFSET for instance).


[..]

>> +		info.page = page;
>> +		gnttab_foreach_grant_in_range(page, offset, bytes,
>> +					      xenvif_gop_frag_copy_grant,
>> +					      &info);
>
> Looks like I need to at least wait until the API is settle before giving
> my ack.
>
>>   		size -= bytes;
>> +		offset = 0;
>
> This looks wrong. Should be offset += bytes.

With the new implementation of the loop, each iteration will be on a 
different page.
So only the first page has an offset different than zero.

>
>>
>> -		/* Next frame */
>> -		if (offset == PAGE_SIZE && size) {
>> +		/* Next page */
>> +		if (size) {
>>   			BUG_ON(!PageCompound(page));
>>   			page++;
>> -			offset = 0;
>
> And this should not be deleted, I think.
>
> What is the reason for changing offset calculation? I think there is
> still compound page when using 64K page.

The compound pages are still working ... gnttab_foreach_grant_in_range 
is called once per page. So the offset can be reset to 0 every time. No 
need to add code which would make the result less clear.

We only need to know if the size is not 0 to get the next page.

The patch may not be clear enough to see it's working so I've copied the 
result loop below:

         while (size > 0) {
                 BUG_ON(offset >= PAGE_SIZE);

                 bytes = PAGE_SIZE - offset;
                 if (bytes > size)
                         bytes = size;

                 info.page = page;
                 gnttab_foreach_grant_in_range(page, offset, bytes,
                                              xenvif_gop_frag_copy_grant,
                                               &info);
                 size -= bytes;
                 offset = 0;

                 /* Next page */
                 if (size) {
                         BUG_ON(!PageCompound(page));
                         page++;
                 }
         }

Regards,

-- 
Julien Grall
