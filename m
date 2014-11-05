From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: getting rid of ->splice_write?
Date: Wed, 5 Nov 2014 18:49:45 +0000
Message-ID: <20141105184945.GS7996@ZenIV.linux.org.uk>
References: <20140922173053.GA13109@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:44493 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbaKEStt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 13:49:49 -0500
Content-Disposition: inline
In-Reply-To: <20140922173053.GA13109@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2014 at 10:30:53AM -0700, Christoph Hellwig wrote:
> Currently only /dev/null, fusedev and the socket code have a
> splice_write implementation that isn't iter_file_splice_write, and
> it seems like these three could easily be switched over if they
> implemented a ->write_iter.

Not really.  A minor nitpick is that you've missed port_fops_splice_write(),
but the real bitch isn't that and not even the sockets (see the fun with
iov_iter sendmsg/recvmsg work getting resurrected).  It's that NULL
->splice_write() means default_file_splice_write.  IOW, you'd need either
->write_iter() for _everything_ (with support of bvec-backed ones included,
since that's what iter_file_splice_write() will feed to ->write_iter()),
or you need to have do_splice_from() check if ->write_iter is NULL and
go for default_file_splice_write() instead of iter_file_splice_write().

The latter might be doable, but the former is really over the top - for
that we'd need to touch every driver instance of ->write() out there.
You want to do that, it's your funeral...

> Similarly it seems to be like we could kill ->splice_read by
> implementing an equivalent iteration over ->read_iter.

Hard to do.  I agree that we want to, but it'll take quite a bit of work
on iov_iter primitives, I'm afraid.  At the very least, we want a variant
of iov_iter that could steal pages.  Don't forget that a large part of
the rationale behind splice_read was the ability to play zero-copy games.

I'm not sure if it will happen this cycle; there's more than enough fun
on the net/* side.  _If_ that ends up done faster than I expect it to be,
->splice_read() is the obvious next target.
