From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: clean up code in xennet_release_rx_bufs
Date: Wed, 15 Jan 2014 22:17:08 +0800
Message-ID: <52D69864.9030207@oracle.com>
References: <1389307718-2845-1-git-send-email-Annie.li@oracle.com> <52D66F11.204@citrix.com> <20140115114208.GK5698@zion.uk.xensource.com> <52D67677.4050407@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, ian.campbell@citrix.com
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36517 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbaAOORW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:17:22 -0500
In-Reply-To: <52D67677.4050407@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014-1-15 19:52, David Vrabel wrote:
> On 15/01/14 11:42, Wei Liu wrote:
>> On Wed, Jan 15, 2014 at 11:20:49AM +0000, David Vrabel wrote:
>>> On 09/01/14 22:48, Annie Li wrote:
>>>> Current netfront only grants pages for grant copy, not for grant transfer, so
>>>> remove corresponding transfer code and add receiving copy code in
>>>> xennet_release_rx_bufs.
>>> While netfront only supports a copying backend, I don't see anything
>>> preventing the backend from retaining mappings to netfront's Rx buffers...
>>>
>> Correct.
>>
>>>> Signed-off-by: Annie Li <Annie.li@oracle.com>
>>>> ---
>>>>   drivers/net/xen-netfront.c |   60 ++-----------------------------------------
>>>>   1 files changed, 3 insertions(+), 57 deletions(-)
>>>>
>>>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>>>> index e59acb1..692589e 100644
>>>> --- a/drivers/net/xen-netfront.c
>>>> +++ b/drivers/net/xen-netfront.c
>>>> @@ -1134,78 +1134,24 @@ static void xennet_release_tx_bufs(struct netfront_info *np)
>>>>   
>>>>   static void xennet_release_rx_bufs(struct netfront_info *np)
>>>>   {
>>> [...]
>>>> -		mfn = gnttab_end_foreign_transfer_ref(ref);
>>>> +		gnttab_end_foreign_access_ref(ref, 0);
>>> ... the gnttab_end_foreign_access_ref() may then fail and...
>>>
>> Oh, I see. Andrew was actually referencing this function. Yes, it can
>> fail. Since he omitted "_ref" I looked at the other function when I
>> replied to him...
>>
>>>>   		gnttab_release_grant_reference(&np->gref_rx_head, ref);
>>>>   		np->grant_rx_ref[id] = GRANT_INVALID_REF;
>>> [...]
>>>> +		kfree_skb(skb);
>>> ... this could then potentially free pages that the backend still has
>>> mapped.  If the pages are then reused, this would leak information to
>>> the backend.
>>>
>>> Since only a buggy backend would result in this, leaking the skbs and
>>> grant refs would be acceptable here.  I would also print an error.
>>>
>> How about using gnttab_end_foreign_access. The deferred queue looks like
>> a right solution -- pending page won't get freed until gref is
>> quiescent.
> This is more like the correct approach but I don't think it still quite
> right.  The skb owns the pages so we don't want
> gnttab_end_foreign_access() to free them as freeing the skb will attempt
> to free them again.
>
> Having gnttab_end_foreign_access() do a free just looks odd to me, the
> free isn't paired with any alloc in the grant table code.
>
> It seems more logical to me that granting access takes an additional
> page ref, and then ending access releases that ref.

I am thinking of two ways, and they can be implemented in new patches.
1. If gnttab_end_foreign_access_ref succeeds, then kfree_skb is called 
to free skb. Otherwise, using gnttab_end_foreign_access to release ref 
and pages.
2. Add a similar deferred way of gnttab_end_foreign_access in 
gnttab_end_foreign_access_ref.

Thanks
Annie
