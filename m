From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v3 1/9] xen-netback: Introduce TX grant map definitions
Date: Thu, 9 Jan 2014 19:53:05 +0000
Message-ID: <52CEFE21.8060608@citrix.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com> <1389139818-24458-2-git-send-email-zoltan.kiss@citrix.com> <20140109153010.GE12164@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>,
	=?ISO-8859-1?Q?Roger_Pau_Monn=E9?= <roger.pau@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:63124 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755982AbaAITxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 14:53:09 -0500
In-Reply-To: <20140109153010.GE12164@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/14 15:30, Wei Liu wrote:
> On Wed, Jan 08, 2014 at 12:10:10AM +0000, Zoltan Kiss wrote:
>> v3:
>> - fix comment in xenvif_tx_dealloc_action()
>> - call unmap hypercall directly instead of gnttab_unmap_refs(), which does
>>    unnecessary m2p_override. Also remove pages_to_[un]map members
>
> Is it worthy to have another function call
> gnttab_unmap_refs_no_m2p_override in Xen core driver, or just add a
> parameter to control wether we need to touch m2p_override? I *think* it
> will benefit block driver as well?
>
> (CC Roger and David for input)

Yep, it worth, but let's make it a different patch

>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -771,6 +771,19 @@ static struct page *xenvif_alloc_page(struct xenvif *vif,
>>   	return page;
>>   }
>>
>> +static inline void xenvif_tx_create_gop(struct xenvif *vif, u16 pending_idx,
>> +	       struct xen_netif_tx_request *txp,
>> +	       struct gnttab_map_grant_ref *gop)
>
> Indentation.
I fixed it and the later ones up, hopefully I haven't missed anything.

>
>> +
>> +	spin_lock_irqsave(&vif->dealloc_lock, flags);
>> +	do {
>> +		pending_idx = ubuf->desc;
>> +		ubuf = (struct ubuf_info *) ubuf->ctx;
>> +		index = pending_index(vif->dealloc_prod);
>> +		vif->dealloc_ring[index] = pending_idx;
>> +		/* Sync with xenvif_tx_action_dealloc:
>
> xenvif_tx_dealloc_action I suppose.
Yes.

>> +			/* Already unmapped? */
>> +			if (vif->grant_tx_handle[pending_idx] ==
>> +				NETBACK_INVALID_HANDLE) {
>> +				netdev_err(vif->dev,
>> +					"Trying to unmap invalid handle! "
>> +					"pending_idx: %x\n", pending_idx);
>> +				continue;
>
> You seemed to miss the BUG_ON we discussed?
>
> See thread starting <52AF1A84.3090304@citrix.com>.
Indeed, despite I wrote it in the version history :)
