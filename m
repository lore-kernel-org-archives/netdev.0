From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: splice from half-closed socket returning -EAGAIN
Date: Mon, 5 Jan 2009 09:28:17 +0100
Message-ID: <20090105082817.GD22131@xi.wantstofly.org>
References: <20090105064728.GE16185@xi.wantstofly.org> <20090104.235946.90553420.davem@davemloft.net> <20090105081136.GA4460@ff.dom.local> <20090105.001401.63730458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, jens.axboe@oracle.com, ben@zeus.com,
	opurdila@ixiacom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:32935 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbZAEI2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 03:28:20 -0500
Content-Disposition: inline
In-Reply-To: <20090105.001401.63730458.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 05, 2009 at 12:14:01AM -0800, David Miller wrote:

> > > > tcp: don't mask EOF and socket errors on nonblocking splice receive
> > > > 
> > > > Currently, setting SPLICE_F_NONBLOCK on splice from a TCP socket
> > > > results in masking of EOF (RDHUP) and error conditions on the socket
> > > > by an -EAGAIN return.  Move the NONBLOCK check in tcp_splice_read()
> > > > to be after the EOF and error checks to fix this.
> > > > 
> > > > Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> > > 
> > > This change looks like the perfect fix for this problem.
> > > 
> > 
> > Actually, I wonder why this "if (flags & SPLICE_F_NONBLOCK)" can't
> > be skipped at all. Isn't "if (!timeo)" enough now?
> 
> Is it really the same condition in the end?

It _seems_ to be?  This:

        timeo = sock_rcvtimeo(sk, flags & SPLICE_F_NONBLOCK);

sets 'timeo' to zero if SPLICE_F_NONBLOCK is set.  And when we get
to the timeo / SPLICE_F_NONBLOCK checks, it must be in the first
iteration of the loop, because if 'spliced' was nonzero, it would
have broken out of the loop earlier, and we wouldn't have reached
the check at all.

So it would seem that the SPLICE_F_NONBLOCK check can be deleted
entirely.
