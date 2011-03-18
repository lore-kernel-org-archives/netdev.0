From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Fri, 18 Mar 2011 15:15:58 +0200
Message-ID: <20110318131558.GC4221@redhat.com>
References: <1300320775.3255.34.camel@localhost.localdomain>
 <20110317050242.GC32049@redhat.com>
 <1300375115.3255.45.camel@localhost.localdomain>
 <1300418927.3255.62.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754261Ab1CRNQT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 09:16:19 -0400
Content-Disposition: inline
In-Reply-To: <1300418927.3255.62.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2011 at 08:28:47PM -0700, Shirley Ma wrote:
> On Thu, 2011-03-17 at 08:18 -0700, Shirley Ma wrote:
> > On Thu, 2011-03-17 at 07:02 +0200, Michael S. Tsirkin wrote:
> > > So, this just tries to make sure there's enough space for
> > > max packet in the ring, if not - drop and return OK.
> > > Why bother checking beforehand though?
> > > If that's what we want to do, we can just call add_buf and see
> > > if it fails?
> > 
> > In add_buf, there is an additional kick, see below. I added check
> > capacity to avoid this, thought it would be better performance. I will
> > retest it w/i add_buf to see the performance difference.
> > 
> >         if (vq->num_free < out + in) {
> >                 pr_debug("Can't add buf len %i - avail = %i\n",
> >                          out + in, vq->num_free);
> >                 /* FIXME: for historical reasons, we force a notify
> > here
> > if
> >                  * there are outgoing parts to the buffer.  Presumably
> > the
> >                  * host should service the ring ASAP. */
> >                 if (out)
> >                         vq->notify(&vq->vq);
> >                 END_USE(vq);
> >                 return -ENOSPC;
> >         }
> > 

Rusty, could you pls clarify what are the historical reasons here?
Are they still valid?
If yes we could dedicate a feature flag to disabling this,
or guess that the host is new by looking at some
other feature flag.

> More test results:
> 
> UDP_STREAM test results (% is guest vcpu, guest has 2 vpus):
> 
> Send(netperf)
> ----
> 
> size	2.6.38-rc8	2.6.38-rc8+	2.6.38-rc8
> 			addbuf failure	check capacity
> -----------------------------------------------------
> 1K	1541.0/50.14%	2169.1/50.03%	3018.9/50%
> 2K	1649.7/33.74%	3362.6/50.18%	4518.8/50.47%	
> 4K	2957.8/44.83%	5965.9/50.03%	9592.5/50%
> 8K	3788/39.01%	9852.8/50.25%	15483.8/50%
> 16K	4736.1/34.13%	14946.5/50.01%	21645.0/50%

Is this the local or remote throughput?
With UDP_STREAM you are mostly interested in
remote throughput, local one can be pretty high
while most packets get dropped.

> Looks like the additional guest notify in add_buf doesn't cost that much
> than I thought to be.
> 
> Thanks
> Shirley
