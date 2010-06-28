From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Mon, 28 Jun 2010 13:00:01 +0300
Message-ID: <20100628100000.GA30628@redhat.com>
References: <F2E9EB7348B8264F86B6AB8151CE2D79134F9AA999@shsmsx502.ccr.corp.intel.com> <20100617112119.GB1515@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CC@shsmsx502.ccr.corp.intel.com> <1A42CE6F5F474C41B63392A5F80372B21F58CD9A@shsmsx501.ccr.corp.intel.com> <20100623095254.GA32491@gondor.apana.org.au> <1A42CE6F5F474C41B63392A5F80372B21F58CE7F@shsmsx501.ccr.corp.intel.com> <20100624100836.GA16220@gondor.apana.org.au> <1A42CE6F5F474C41B63392A5F80372B21F58D666@shsmsx501.ccr.corp.intel.com> <20100627061455.GA16782@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D7916B0129230@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"Dong, Eddie" <eddie.dong@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D7916B0129230@shsmsx502.ccr.corp.intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 28, 2010 at 05:56:07PM +0800, Xin, Xiaohui wrote:
> >-----Original Message-----
> >From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
> >Sent: Sunday, June 27, 2010 2:15 PM
> >To: Dong, Eddie
> >Cc: Xin, Xiaohui; Stephen Hemminger; netdev@vger.kernel.org; kvm@vger.kernel.org;
> >linux-kernel@vger.kernel.org; mst@redhat.com; mingo@elte.hu; davem@davemloft.net;
> >jdike@linux.intel.com
> >Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from external.
> >
> >On Fri, Jun 25, 2010 at 09:03:46AM +0800, Dong, Eddie wrote:
> >>
> >> In current patch, each SKB for the assigned device (SRIOV VF or NIC or a complete
> >queue pairs) uses the buffer from guest, so it eliminates copy completely in software and
> >requires hardware to do so. If we can have an additonal place to store the buffer per skb (may
> >cause copy later on), we can do copy later on or re-post the buffer to assigned NIC driver
> >later on. But that may be not very clean either :(
> >
> >OK, if I understand you correctly then I don't think have a
> >problem.  With your current patch-set you have exactly the same
> >situation when the skb->data is reallocated as a kernel buffer.
> >
> 
> When will skb->data to be reallocated? May you point me the code path?
> 
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

Question: can devices use parts of the same page
in frags of different skbs (or for other purposes)? If they do,
we'll corrupt that memory if we try to stick the header there.

We have another option, reserve some buffers
posted by guest and use them if we need to copy
the header. This seems the most straight-forward to me.

> >Only in the case where the packet header grows (e.g., encapsulation)
> >would you need to get an extra external buffer.
> >
> >Cheers,
> >--
> >Email: Herbert Xu <herbert@gondor.apana.org.au>
> >Home Page: http://gondor.apana.org.au/~herbert/
> >PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
