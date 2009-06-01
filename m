From: Andy Fleming <afleming@freescale.com>
Subject: Re: NIU driver unmap_page call
Date: Mon, 1 Jun 2009 15:58:32 -0500
Message-ID: <558C09D0-FEBE-4DC8-A137-AF40FF711A69@freescale.com>
References: <71C5D403-0A82-45E6-8FEF-2911B7BB9C24@freescale.com> <20090601.031104.187911913.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:53486 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755315AbZFAU6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 16:58:38 -0400
In-Reply-To: <20090601.031104.187911913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 1, 2009, at 5:11 AM, David Miller wrote:

> From: Andy Fleming <afleming@freescale.com>
> Date: Fri, 29 May 2009 17:38:50 -0500
>
>> I'm trying to figure out what this code does:
>>
>>               if ((page->index + rp->rbr_block_size) - rcr_size ==  
>> addr) {
>>                       *link = (struct page *) page->mapping;
>>                       np->ops->unmap_page(np->device, page->index,
>>                                           PAGE_SIZE,  
>> DMA_FROM_DEVICE);
>>                       page->index = 0;
>>                       page->mapping = NULL;
>>                       rp->rbr_refill_pending++;
>>               } else
>>                       get_page(page);
>>
>> It's clear it's taking the opportunity to remove the page from the
>> hash table, and to unmap the page, but I'm not familiar enough with
>> this nic to understand what the if statement is looking for.  My  
>> first
>> thought was that it was looking to see if this was the first buffer  
>> in
>> the page?
>
> It's looking to see if this is the LAST chunk in the page, not the
> first.


Hmm... I'm still misunderstanding something.  rbr_blocks_per_page  
implies that each page has multiple blocks.  This looks like it is  
checking to see if the current buffer is the last buffer in the  
block.  There is similar code in the niu_rx_pkt_ignore function, which  
uses PAGE_SIZE in place of rbr_block_size.


>
>
> rcr_size is the size of the sub-buffers within the page that the
> chip is carving out of the page.
>
> Since when we allocated the page initially this obtained on reference
> to the page, we increment for every chunk given out to an SKB except
> the last one.

But in niu_rbr_add_page(), the function does:

                 atomic_add(rp->rbr_blocks_per_page - 1,
                            &compound_head(page)->_count);

Which I thought was already doing the necessary accounting.

Andy
