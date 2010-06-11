From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Fri, 11 Jun 2010 15:21:12 +1000
Message-ID: <20100611052112.GA25649@gondor.apana.org.au>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com> <20100606161348.427822fb@nehalam> <20100608052744.GA21547@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D791100848F9F@shsmsx502.ccr.corp.intel.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D791100848F9F@shsmsx502.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 09, 2010 at 05:54:02PM +0800, Xin, Xiaohui wrote:
>
> I'm not sure if I understand your way correctly:
> 1) Does the way only deal with driver with SG feature? Since packet 
> is non-linear...

No the hardware doesn't have to support SG.  You just need to
place the entire packet contents in a page instead of skb->head.

> 2) Is skb->data still pointing to guest user buffers?
> If yes, how to avoid the modifications to net core change to skb?

skb->data would not point to guest user buffers.  In the common
case the packet is not modified on its way to the guest so this
is not an issue.

In the rare case where it is modified, you only have to copy the
bits which are modified and the cost of that is inconsequential
since you have to write to that memory anyway.

> 3) In our way only parts of drivers need be modified to support zero-copy.
> and here, need we modify all the drivers?

If you're asking the portion of each driver supporting zero-copy
that needs to be modified, then AFAICS this doesn't change that
very much at all.

> I think to make skb->head empty at first will cause more effort to pass the check with 
> skb header. Have I missed something here? I really make the skb->head NULL
> just before kfree(skb) in skb_release_data(), it's done by callback we have made for skb.

No I'm not suggesting you set it to NULL.  It should have some
memory allocated, but skb_headlen(skb) should be zero.

Please have a look at how the napi_gro_frags interface works (e.g.,
in drivers/net/cxgb3/sge.c).  This is exactly the model that I am
suggesting.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
