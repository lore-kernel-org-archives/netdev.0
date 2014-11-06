From: Christoph Hellwig <hch@infradead.org>
Subject: Re: getting rid of ->splice_write?
Date: Wed, 5 Nov 2014 23:55:23 -0800
Message-ID: <20141106075523.GA15966@infradead.org>
References: <20140922173053.GA13109@infradead.org>
 <20141105184945.GS7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49792 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbaKFHzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 02:55:25 -0500
Content-Disposition: inline
In-Reply-To: <20141105184945.GS7996@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2014 at 06:49:45PM +0000, Al Viro wrote:
> Not really.  A minor nitpick is that you've missed port_fops_splice_write(),
> but the real bitch isn't that and not even the sockets (see the fun with
> iov_iter sendmsg/recvmsg work getting resurrected).  It's that NULL
> ->splice_write() means default_file_splice_write.  IOW, you'd need either
> ->write_iter() for _everything_ (with support of bvec-backed ones included,
> since that's what iter_file_splice_write() will feed to ->write_iter()),
> or you need to have do_splice_from() check if ->write_iter is NULL and
> go for default_file_splice_write() instead of iter_file_splice_write().
> 
> The latter might be doable, but the former is really over the top - for
> that we'd need to touch every driver instance of ->write() out there.
> You want to do that, it's your funeral...

The latter is what I thought off.  And yes, the socket work looks good,
especially if we can get rid of ->sendpage as well.  That'll require
passing new flags somewhere, the ones in the iocb added for
preadv2/pwritev2 might be usable.

> > Similarly it seems to be like we could kill ->splice_read by
> > implementing an equivalent iteration over ->read_iter.
> 
> Hard to do.  I agree that we want to, but it'll take quite a bit of work
> on iov_iter primitives, I'm afraid.  At the very least, we want a variant
> of iov_iter that could steal pages.  Don't forget that a large part of
> the rationale behind splice_read was the ability to play zero-copy games.
> 
> I'm not sure if it will happen this cycle; there's more than enough fun
> on the net/* side.  _If_ that ends up done faster than I expect it to be,
> ->splice_read() is the obvious next target.

And zero copy games would become a lot less nasty if they could go
straight through ->read_iter instead of the current abuses of splice
infrastructure.

Same for sendfile, btw.
