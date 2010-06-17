From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Thu, 17 Jun 2010 21:20:23 +1000
Message-ID: <20100617112023.GA1515@gondor.apana.org.au>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com> <20100606161348.427822fb@nehalam> <20100608052744.GA21547@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D791100848F9F@shsmsx502.ccr.corp.intel.com> <20100611052112.GA25649@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D791210AA4475@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:41316 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757094Ab0FQLUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 07:20:33 -0400
Content-Disposition: inline
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D791210AA4475@shsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 12, 2010 at 05:31:10PM +0800, Xin, Xiaohui wrote:
> 
> 1) Modify driver from netdev_alloc_skb() to alloc user pages if dev is zero-copyed.
>   If the driver support PS mode, then modify alloc_page() too.

Well if you were doing this then the driver won't be generating
skbs at all.  So you don't need to change netdev_alloc_skb.

The driver would currently do alloc_page, so you would replace
that with netdev_alloc_page, which can call your new function
to allocate an external page where appropriate.

IOW you just need one change in the driver if it already uses
the skbless interface, to replace with alloc_page.

If the driver doesn't use the skbless interface then you need
to make a few more changes but it isn't too hard either, it'll
also mean that the driver will have less overhead even for normal
use which is a win-win situation.

> 2) Add napi_gro_frags() in driver to receive the user pages instead of driver's receiving 
> function.
>
> 3) napi_gro_frags() will allocate small skb and pull the header data from 
> the first page to skb->data.
> 
> Is above the way what you have suggested?

Yes.

> I have thought something in detail about the way.
> 
> 1) The first page will have an offset after the header is copied into allocated kernel skb. 
> The offset should be recalculated when the user page data is transferred to guest. This 
> may modify some of the gro code.

We could keep track whether the stack has modified the header,
since you can simply ignore it if it doesn't modify it, which
should be the common case for virt.

> 2) napi_gro_frags() may remove a page when it's data is totally be pulled, but we cannot 
> put a user page as normally. This may modify the gro code too.

If it does anything like that, then we're not in the fast-path
case so you can just fall back to copying.

> 3) When the user buffer returned to guest, some of them need to be appended a vnet header.
> That means for some pages, the vnet header room should be reserved when allocated.
> But we cannot know which one will be used as the first page when allocated. If we reserved vnet header for each page, since the set_skb_frag() in guest driver only use the offset 0 for second pages, then page data will be wrong.

I don't see why this would be a problem, since as far as what
the driver is putting onto the physical RX ring nothing has
changed.  IOW if you want to designate a certain page as special,
or the first page, you can still do so.

So can you explain which bits of your patches would be affected
by this?

> 4) Since the user buffer pages should be released, so we still need a dtor callback to do that, and then I still need a place to hold it. How do you think about to put it in skb_shinfo?

While I don't like that very much I guess I can live with that
if nobody else objects.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
