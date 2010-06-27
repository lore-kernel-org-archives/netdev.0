From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Sun, 27 Jun 2010 16:14:55 +1000
Message-ID: <20100627061455.GA16782@gondor.apana.org.au>
References: <20100611052112.GA25649@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D791210AA4475@shsmsx502.ccr.corp.intel.com> <F2E9EB7348B8264F86B6AB8151CE2D79134F9AA999@shsmsx502.ccr.corp.intel.com> <20100617112119.GB1515@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CC@shsmsx502.ccr.corp.intel.com> <1A42CE6F5F474C41B63392A5F80372B21F58CD9A@shsmsx501.ccr.corp.intel.com> <20100623095254.GA32491@gondor.apana.org.au> <1A42CE6F5F474C41B63392A5F80372B21F58CE7F@shsmsx501.ccr.corp.intel.com> <20100624100836.GA16220@gondor.apana.org.au> <1A42CE6F5F474C41B63392A5F80372B21F58D666@shsmsx501.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Xin, Xiaohui" <xiaohui.xin@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Dong, Eddie" <eddie.dong@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40147 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab0F0GPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 02:15:04 -0400
Content-Disposition: inline
In-Reply-To: <1A42CE6F5F474C41B63392A5F80372B21F58D666@shsmsx501.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 25, 2010 at 09:03:46AM +0800, Dong, Eddie wrote:
> 
> In current patch, each SKB for the assigned device (SRIOV VF or NIC or a complete queue pairs) uses the buffer from guest, so it eliminates copy completely in software and requires hardware to do so. If we can have an additonal place to store the buffer per skb (may cause copy later on), we can do copy later on or re-post the buffer to assigned NIC driver later on. But that may be not very clean either :(

OK, if I understand you correctly then I don't think have a
problem.  With your current patch-set you have exactly the same
situation when the skb->data is reallocated as a kernel buffer.

This is OK because as you correctly argue, it is a rare situation.

With my proposal you will need to get this extra external buffer
in even less cases, because you'd only need to do it if the skb
head grows, which only happens if it becomes encapsulated.

So let me explain it in a bit more detail:

Our packet starts out as a purely non-linear skb, i.e., skb->head
contains nothing and all the page frags come from the guest.

During host processing we may pull data into skb->head but the
first frag will remain unless we pull all of it.  If we did do
that then you would have a free external buffer anyway.

Now in the common case the header may be modified or pulled, but
it very rarely grows.  So you can just copy the header back into
the first frag just before we give it to the guest.

Only in the case where the packet header grows (e.g., encapsulation)
would you need to get an extra external buffer.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
