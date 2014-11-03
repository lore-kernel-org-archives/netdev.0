From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: fs: Use non-const iov in aio_read/aio_write
Date: Mon, 3 Nov 2014 00:45:03 +0000
Message-ID: <20141103004503.GX7996@ZenIV.linux.org.uk>
References: <20141102230552.GA26095@gondor.apana.org.au>
 <20141103001634.GV7996@ZenIV.linux.org.uk>
 <20141103002207.GA26588@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35439 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbaKCApG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 19:45:06 -0500
Content-Disposition: inline
In-Reply-To: <20141103002207.GA26588@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2014 at 08:22:07AM +0800, Herbert Xu wrote:
> On Mon, Nov 03, 2014 at 12:16:34AM +0000, Al Viro wrote:
> > 
> > NAK with extreme prejudice.  The right way to deal with that is
> > to convert the socket side of things to iov_iter.  And give it a
> > consistent behaviour, while we are at it (some protocols do advance
> > the damn thing, so do not).  There are _very_ good reasons to have those
> > iovecs unchanged - if you look at the callers on the socket side, you'll
> > see a bunch that has to _copy_ iovec just to avoid it being buggered.
> > And you get rather suboptimal behaviour in memcpy_fromiovec() and friends,
> > exactly because you have to skip through the emptied elements.
> > 
> > IOW, no way in hell.
> 
> You're welcome to send patches fix every spot in the network stack
> that writes to the iovec.  But until the network stack is all fixed
> up, having a const struct iovec in aio_read/aio_write is a delusion.

Check how many ->aio_read() and ->aio_write() instances are left.  If you
are implying that dealing with the ones in net/* is not feasible, I invite
you to check the situation in fs/*, where we used to have quite a few.
Compare it with what used to be there in e.g. January.

Note, BTW, that there's a damn good reason to convert the socket side of
things to iov_iter - as it is, ->splice_write() there is basically done with
page-by-page mapping and doing kernel_sendmsg(); being able to deal with
"map and copy" stuff *inside* ->sendmsg() would not only reduce the overhead,
it would allow to get rid of ->sendpage() completely.  Basically, let
->sendmsg() instances check the iov_iter type and play zerocopy games if
it's an "array of kernel pages" kind.  Compare ->sendpage() and ->sendmsg()
instances for the protocols that have nontrivial ->sendpage(); you'll see
that there's a lot of duplication.  Merging them looks very feasible, with
divergence happening only very deep in the call chain.
