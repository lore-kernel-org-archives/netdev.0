From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next v2] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Fri, 17 Jan 2014 14:25:40 +0800
Message-ID: <52D8CCE4.9010804@oracle.com>
References: <1389830228-2381-1-git-send-email-Annie.li@oracle.com> <52D7BE19.2010009@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xen.org,
	andrew.bennieston@citrix.com, davem@davemloft.net
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37255 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbaAQGZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 01:25:52 -0500
In-Reply-To: <52D7BE19.2010009@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014/1/16 19:10, David Vrabel wrote:
> On 15/01/14 23:57, Annie Li wrote:
>> This patch implements two things:
>>
>> * release grant reference and skb for rx path, this fixex resource leaking.
>> * clean up grant transfer code kept from old netfront(2.6.18) which grants
>> pages for access/map and transfer. But grant transfer is deprecated in current
>> netfront, so remove corresponding release code for transfer.
>>
>> gnttab_end_foreign_access_ref may fail when the grant entry is currently used
>> for reading or writing. But this patch does not cover this and improvement for
>> this failure may be implemented in a separate patch.
> I don't think replacing a resource leak with a security bug is a good idea.
>
> If you would prefer not to fix the gnttab_end_foreign_access() call, I
> think you can fix this in netfront by taking a reference to the page
> before calling gnttab_end_foreign_access().  This will ensure the page
> isn't freed until the subsequent kfree_skb(), or the gref is released by
> the foreign domain (whichever is later).

Taking a reference to the page before calling 
gnttab_end_foreign_access() delays the free work until kfree_skb(). 
Simply adding put_page before kfree_skb() does not make things different 
from gnttab_end_foreign_access_ref(), and the pages will be freed by 
kfree_skb(), problem will be hit in gnttab_handle_deferred() when 
freeing pages which already be freed.

So put_page is required in gnttab_end_foreign_access(), this will ensure 
either free is taken by kfree_skb or gnttab_handle_deferred. This 
involves changes in blkfront/pcifront/tpmfront(just like your patch), 
this way ensure page is released when ref is end.

Another solution I am thinking is calling gnttab_end_foreign_access() 
with page parameter as NULL, then gnttab_end_foreign_access will only do 
ending grant reference work and releasing page work is done by kfree_skb().

Thanks
Annie
