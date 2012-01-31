From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [RFC PATCH V3 15/16] netfront: multi page ring
 support.
Date: Tue, 31 Jan 2012 09:53:24 +0000
Message-ID: <4F27C8240200007800070110@nat28.tlf.novell.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
 <1327934734-8908-16-git-send-email-wei.liu2@citrix.com>
 <20120130213926.GB16261@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xensource.com>,
	<netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:59591 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419Ab2AaJx3 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Tue, 31 Jan 2012 04:53:29 -0500
In-Reply-To: <20120130213926.GB16261@phenom.dumpdata.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 30.01.12 at 22:39, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:
> On Mon, Jan 30, 2012 at 02:45:33PM +0000, Wei Liu wrote:
>> @@ -1496,50 +1523,105 @@ static int setup_netfront(struct xenbus_device *dev, 
> struct netfront_info *info)
>>  		goto fail;
>>  	}
>>  
>> -	txs = (struct xen_netif_tx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
>> +	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
>> +			   "max-tx-ring-page-order", "%u",
>> +			   &max_tx_ring_page_order);
>> +	if (err < 0) {
>> +		info->tx_ring_page_order = 0;
>> +		dev_info(&dev->dev, "single tx ring\n");
>> +	} else {
>> +		info->tx_ring_page_order = max_tx_ring_page_order;
>> +		dev_info(&dev->dev, "multi page tx ring, order = %d\n",
>> +			 max_tx_ring_page_order);
>> +	}
>> +	info->tx_ring_pages = (1U << info->tx_ring_page_order);
>> +
>> +	txs = (struct xen_netif_tx_sring *)
>> +		dma_alloc_coherent(NULL, PAGE_SIZE * info->tx_ring_pages,
>> +				   &info->tx_ring_dma_handle,
>> +				   __GFP_ZERO | GFP_NOIO | __GFP_HIGH);
> 
> Hm, so I see you are using 'NULL' which is a big nono (the API docs say 
> that).
> But the other reason why it is a no-no, is b/c this way the generic DMA 
> engine has no
> clue whether you are OK getting pages under 4GB or above it (so 64-bit 
> support).
> 
> If you don't supply a 'dev' it will assume 4GB. But when you are run this as 
> a
> pure PV guest that won't matter the slighest b/I there are no DMA code in 
> action
> (well, there is dma_alloc_coherent - which looking at the code would NULL it 
> seems).
> 
> Anyhow, if you get to have more than 4GB in the guest or do PCI passthrough 
> and use
> 'iommu=soft'- at which point the Xen SWIOTLB will kick and you will end up 
> 'swizzling'
> the pages to be under 4GB. That can be fixed if you declerae a 'fake' device 
> where you set
> the coherent_dma_mask to DMA_BIT_MASK(64).
> 
> But if you boot the guest under HVM, then it will use the generic SWIOTLB 
> code, which
> won't guaranteeing the pages to be "machine" contingous but will be "guest 
> machine"
> contingous. Is that sufficient for this?
> 
> How did you test this? Did you supply iommu=soft  to your guest or booted it
> with more than 4GB?

Imo the use of the DMA API is a mistake here anyway. There's no need
for anything to be contiguous in a PV frontend/backend handshake
protocol, or if one finds there is it's very likely just because of trying to
avoid doing something properly.

Jan
