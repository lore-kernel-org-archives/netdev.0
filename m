From: Willy Tarreau <w@1wt.eu>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 07:38:59 +0100
Message-ID: <20090107063859.GA30749@1wt.eu>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106183704.GC32491@kernel.dk> <20090107044232.GA22218@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1150 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557AbZAGGm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 01:42:28 -0500
Content-Disposition: inline
In-Reply-To: <20090107044232.GA22218@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 03:42:32PM +1100, Herbert Xu wrote:
> On Tue, Jan 06, 2009 at 06:37:05PM +0000, Jens Axboe wrote:
> > 
> > I'll give this a spin tomorrow as well. A hunch tells me that this is
> > likely a page reuse issue, that splice is getting the reference to the
> > buffer dropped before the data has really been transmitted. IOW, the
> > page is likely fine reaching the ->sendpage() bit, but will be reused
> > before the data has actually been transmitted. So once you get that far,
> > other random data from that page is going out.
> 
> I see the problem.
> 
> The socket pipes in net/core/skbuff.c use references on the skb
> to hold down the memory in skb->head as well as the pages in the
> skb.
> 
> Unfortunately, once the pipe is fed into sendpage we only use
> page reference counting to pin down the memory.  So as soon as
> sendpage returns we drop the ref count on the skb, thus freeing
> the memory in skb->head, which is yet to be transmitted.

So this means that anything relying on sendpage() is at risk ? What
I find really strange is that I can only reproduce the issue if the
spliced data come from a real interface. If they come from the loopback
or from a file, there is no problem. Maybe the ref counting is different
depending on the origin of the data ?

> Moral: Using page reference counts on skb->head is wrong.

My question will sound stupid to some of you, but wouldn't increasing
the refcount on those skb solve the problem (and decreasing it once
the skb is effectively sent) ?

Regards,
Willy

