From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Sat, 3 Jul 2010 17:12:37 +0800
Message-ID: <20100703091237.GA6632@gondor.apana.org.au>
References: <F2E9EB7348B8264F86B6AB8151CE2D79134F9AA999@shsmsx502.ccr.corp.intel.com> <20100617112119.GB1515@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CC@shsmsx502.ccr.corp.intel.com> <1A42CE6F5F474C41B63392A5F80372B21F58CD9A@shsmsx501.ccr.corp.intel.com> <20100623095254.GA32491@gondor.apana.org.au> <1A42CE6F5F474C41B63392A5F80372B21F58CE7F@shsmsx501.ccr.corp.intel.com> <20100624100836.GA16220@gondor.apana.org.au> <1A42CE6F5F474C41B63392A5F80372B21F58D666@shsmsx501.ccr.corp.intel.com> <20100627061455.GA16782@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D7916B0129230@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Dong, Eddie" <eddie.dong@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56054 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396Ab0GCJMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 05:12:49 -0400
Content-Disposition: inline
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D7916B0129230@shsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 28, 2010 at 05:56:07PM +0800, Xin, Xiaohui wrote:
>
> >OK, if I understand you correctly then I don't think have a
> >problem.  With your current patch-set you have exactly the same
> >situation when the skb->data is reallocated as a kernel buffer.
> 
> When will skb->data to be reallocated? May you point me the code path?

Anything that calls pskb_expand_head.

> >This is OK because as you correctly argue, it is a rare situation.
> >
> >With my proposal you will need to get this extra external buffer
> >in even less cases, because you'd only need to do it if the skb
> >head grows, which only happens if it becomes encapsulated.
> >So let me explain it in a bit more detail:
> >
> >Our packet starts out as a purely non-linear skb, i.e., skb->head
> >contains nothing and all the page frags come from the guest.
> >
> >During host processing we may pull data into skb->head but the
> >first frag will remain unless we pull all of it.  If we did do
> >that then you would have a free external buffer anyway.
> >
> >Now in the common case the header may be modified or pulled, but
> >it very rarely grows.  So you can just copy the header back into
> >the first frag just before we give it to the guest.
> >
> Since the data is still there, so recompute the page offset and size is ok, right?

Right, you just move the page offset back and increase the size.
However, to do this safely we'd need to have a way of knowing
whether the skb head has been modified.

It may well turn out to be just as effective to do something like

	if (memcmp(skb->data, page frag head, skb_headlen))
		memcpy(page frag head, skb->data, skb_headlen)

As the page frag head should be in cache since it would've been
used to populate skb->data.

It'd be good to run some benchmarks with this to see whether
adding a bit to sk_buff to avoid the memcmp is worth it or not.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
