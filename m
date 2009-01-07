From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 15:37:41 +0300
Message-ID: <20090107123741.GA31255@ioremap.net>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106183704.GC32491@kernel.dk> <20090107044232.GA22218@gondor.apana.org.au> <20090107112906.GA28161@ioremap.net> <20090107115032.GA25198@gondor.apana.org.au> <20090107115605.GA29250@ioremap.net> <20090107115921.GA25323@gondor.apana.org.au> <20090107121530.GA30164@ioremap.net> <20090107122238.GB25673@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, Willy Tarreau <w@1wt.eu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:55196 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081AbZAGMhm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 07:37:42 -0500
Content-Disposition: inline
In-Reply-To: <20090107122238.GB25673@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 11:22:38PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > Looks like we are talking about different directions of the dataflow.
> > I meant that set of pages submitted into the sending part will be copied
> > if sending interface does not support acceleration, and thus it will
> > copy part of the page corresponding to the linear part of the skb prior
> > the transmission, so even if skb will be freed right after that call
> > (prior data transmission by the hardware), it should not affect copied
> > data.
> 
> You must be looking at a different tcp.c than the one I've got
> because mine clearly always uses skb frags in sendpage regardless
> of SG support.

Doesn't your tcp fallbacks to kernel_sendmsg() without sg in
tcp_sendpage()? And then just feeds data into the stack the same way it
happens with send() i.e. by copying it.

> Yes we will linearize the packet in dev_queue_xmit but as soon
> as the netdev stops the tx queue you'll get corruption.

That's perfectly valid when sendpage() returns and holds a reference to
the pages but not skb->head, so freed skb will free (and potentially
reuse) that area which has not been transmitted yet.
But without acceleration it will copy data and the whole original skb
may be freed without any problems.

-- 
	Evgeniy Polyakov
