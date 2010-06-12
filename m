From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Sat, 12 Jun 2010 17:31:10 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D791210AA4475@shsmsx502.ccr.corp.intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
 <20100606161348.427822fb@nehalam>
 <20100608052744.GA21547@gondor.apana.org.au>
 <F2E9EB7348B8264F86B6AB8151CE2D791100848F9F@shsmsx502.ccr.corp.intel.com>
 <20100611052112.GA25649@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39839 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752939Ab0FLJbP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jun 2010 05:31:15 -0400
In-Reply-To: <20100611052112.GA25649@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
>Sent: Friday, June 11, 2010 1:21 PM
>To: Xin, Xiaohui
>Cc: Stephen Hemminger; netdev@vger.kernel.org; kvm@vger.kernel.org;
>linux-kernel@vger.kernel.org; mst@redhat.com; mingo@elte.hu; davem@davemloft.net;
>jdike@linux.intel.com
>Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from external.
>
>On Wed, Jun 09, 2010 at 05:54:02PM +0800, Xin, Xiaohui wrote:
>>
>> I'm not sure if I understand your way correctly:
>> 1) Does the way only deal with driver with SG feature? Since packet
>> is non-linear...
>
>No the hardware doesn't have to support SG.  You just need to
>place the entire packet contents in a page instead of skb->head.
>
>> 2) Is skb->data still pointing to guest user buffers?
>> If yes, how to avoid the modifications to net core change to skb?
>
>skb->data would not point to guest user buffers.  In the common
>case the packet is not modified on its way to the guest so this
>is not an issue.
>
>In the rare case where it is modified, you only have to copy the
>bits which are modified and the cost of that is inconsequential
>since you have to write to that memory anyway.
>
>> 3) In our way only parts of drivers need be modified to support zero-copy.
>> and here, need we modify all the drivers?
>
>If you're asking the portion of each driver supporting zero-copy
>that needs to be modified, then AFAICS this doesn't change that
>very much at all.
>
>> I think to make skb->head empty at first will cause more effort to pass the check with
>> skb header. Have I missed something here? I really make the skb->head NULL
>> just before kfree(skb) in skb_release_data(), it's done by callback we have made for skb.
>
>No I'm not suggesting you set it to NULL.  It should have some
>memory allocated, but skb_headlen(skb) should be zero.
>
>Please have a look at how the napi_gro_frags interface works (e.g.,
>in drivers/net/cxgb3/sge.c).  This is exactly the model that I am
>suggesting.
>
>Cheers,
>--
>Visit Openswan at http://www.openswan.org/
>Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
>Home Page: http://gondor.apana.org.au/~herbert/
>PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

Herbert,
I explained what I think the thought in your mind here, please clarify if 
something missed.

1) Modify driver from netdev_alloc_skb() to alloc user pages if dev is zero-copyed.
  If the driver support PS mode, then modify alloc_page() too.
2) Add napi_gro_frags() in driver to receive the user pages instead of driver's receiving 
function.
3) napi_gro_frags() will allocate small skb and pull the header data from 
the first page to skb->data.

Is above the way what you have suggested?
I have thought something in detail about the way.

1) The first page will have an offset after the header is copied into allocated kernel skb. 
The offset should be recalculated when the user page data is transferred to guest. This 
may modify some of the gro code.

2) napi_gro_frags() may remove a page when it's data is totally be pulled, but we cannot 
put a user page as normally. This may modify the gro code too.

3) When the user buffer returned to guest, some of them need to be appended a vnet header.
That means for some pages, the vnet header room should be reserved when allocated.
But we cannot know which one will be used as the first page when allocated. If we reserved vnet header for each page, since the set_skb_frag() in guest driver only use the offset 0 for second pages, then page data will be wrong.

4) Since the user buffer pages should be released, so we still need a dtor callback to do that, and then I still need a place to hold it. How do you think about to put it in skb_shinfo?

Currently I can only think of this.
How do you think about then?

Thanks
Xiaohui 



