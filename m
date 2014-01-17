From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next v2] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Fri, 17 Jan 2014 20:32:29 +0800
Message-ID: <52D922DD.2060407@oracle.com>
References: <1389830228-2381-1-git-send-email-Annie.li@oracle.com> <52D7BE19.2010009@citrix.com> <52D8CCE4.9010804@oracle.com> <20140117120810.GA11681@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>, ian.campbell@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xen.org,
	andrew.bennieston@citrix.com, davem@davemloft.net
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40991 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbaAQMco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 07:32:44 -0500
In-Reply-To: <20140117120810.GA11681@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014-1-17 20:08, Wei Liu wrote:
> On Fri, Jan 17, 2014 at 02:25:40PM +0800, annie li wrote:
>> On 2014/1/16 19:10, David Vrabel wrote:
>>> On 15/01/14 23:57, Annie Li wrote:
>>>> This patch implements two things:
>>>>
>>>> * release grant reference and skb for rx path, this fixex resource leaking.
>>>> * clean up grant transfer code kept from old netfront(2.6.18) which grants
>>>> pages for access/map and transfer. But grant transfer is deprecated in current
>>>> netfront, so remove corresponding release code for transfer.
>>>>
>>>> gnttab_end_foreign_access_ref may fail when the grant entry is currently used
>>>> for reading or writing. But this patch does not cover this and improvement for
>>>> this failure may be implemented in a separate patch.
>>> I don't think replacing a resource leak with a security bug is a good idea.
>>>
>>> If you would prefer not to fix the gnttab_end_foreign_access() call, I
>>> think you can fix this in netfront by taking a reference to the page
>>> before calling gnttab_end_foreign_access().  This will ensure the page
>>> isn't freed until the subsequent kfree_skb(), or the gref is released by
>>> the foreign domain (whichever is later).
>> Taking a reference to the page before calling
>> gnttab_end_foreign_access() delays the free work until kfree_skb().
>> Simply adding put_page before kfree_skb() does not make things
>> different from gnttab_end_foreign_access_ref(), and the pages will
>> be freed by kfree_skb(), problem will be hit in
>> gnttab_handle_deferred() when freeing pages which already be freed.
>>
> I think David's idea is:
>
> 	get_page
> 	gnttab_end_foreign_access
> 	kfree_skb
>
> The get_page is to offset put_page in gnttab_end_foreign_access. You
> don't need to put page before kfree_skb.

Yes, this is what I described as following about David's patch.

>> So put_page is required in gnttab_end_foreign_access(), this will
>> ensure either free is taken by kfree_skb or gnttab_handle_deferred.
>> This involves changes in blkfront/pcifront/tpmfront(just like your
>> patch), this way ensure page is released when ref is end.

But this would has some issue in netfront tx path. Netfront ends all 
grant reference of one skb first and then release this skb. If the 
gnttab_end_foreign_access_ref fails in gnttab_end_foreign_access(), this 
frag page and corresponding grant reference will be put in entry and 
release work will be done in the timer routine. If some frag pages of 
one skb is free in this timer routine, then dev_kfree_skb_irq will free 
pages which have been freed.
So I prefer following way I mentioned, suggestions?

>> Another solution I am thinking is calling
>> gnttab_end_foreign_access() with page parameter as NULL, then
>> gnttab_end_foreign_access will only do ending grant reference work
>> and releasing page work is done by kfree_skb().

Thanks
Annie
