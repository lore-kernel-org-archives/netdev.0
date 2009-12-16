From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 1/4] Defer skb allocation -- add destroy buffers function for virtio
Date: Wed, 16 Dec 2009 15:34:00 +1030
Message-ID: <200912161534.00461.rusty@rustcorp.com.au>
References: <1258697359.7416.14.camel@localhost.localdomain> <200912160906.12430.rusty@rustcorp.com.au> <20091215224002.GA27034@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <mashirle@us.ibm.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45278 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751105AbZLPFEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2009 00:04:04 -0500
In-Reply-To: <20091215224002.GA27034@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Dec 2009 09:10:02 am Michael S. Tsirkin wrote:
> On Wed, Dec 16, 2009 at 09:06:12AM +1030, Rusty Russell wrote:
> > On Tue, 15 Dec 2009 06:52:53 am Michael S. Tsirkin wrote:
> > > On Mon, Dec 14, 2009 at 12:08:05PM -0800, Shirley Ma wrote:
> > > > Hello Michael,
> > > > 
> > > > I agree with the comments (will have two patches instead of 4 based on
> > > > Rusty's comments) except below one.
> > > > 
> > > > On Sun, 2009-12-13 at 12:26 +0200, Michael S. Tsirkin wrote:
> > > > > That said - do we have to use a callback?
> > > > > I think destroy_buf which returns data pointer,
> > > > > and which we call repeatedly until we get NULL
> > > > > or error, would be an a better, more flexible API.
> > > > > This is not critical though.
> > > > 
> > > > The reason to use this is because in virtio_net remove, it has
> > > > BUG_ON(vi->num != 0), which will be consistent with small skb packet. If
> > > > we use NULL, error then we lose the track for vi->num, since we don't
> > > > know how many buffers have been passed to ULPs or still unused.
> > > > 
> > > > Thanks
> > > > Shirley
> > > 
> > > I dont insist, but my idea was
> > > 
> > > for (;;) {
> > > 	b = vq->destroy(vq);
> > > 	if (!b)
> > > 		break;
> > > 	--vi->num;
> > > 	put_page(b);
> > > }
> > 
> > In this case it should be called "get_unused_buf" or something.  But I like
> > Shirley's approach here; destroy (with callback) accurately reflects the only
> > time this can be validly used.
> > 
> > Cheers,
> > Rusty.
> 
> I guess the actual requirement is that device must be
> inactive.

Technically, the vq has to be inactive.  (This distinction may matter for
the multiport virtio_console work).

> 
> As I said this is fine with me as well.
> But I think the callback should get vq pointer besides the
> data pointer, so that it can e.g. find the device if it needs to.
> In case of virtio net this makes it possible
> to decrement the outstanding skb counter in the callback.
> Makes sense?

Sure.  I don't really mind either way, and I'm warming to the name
detach_buf :)

Cheers,
Rusty.
