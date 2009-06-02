From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of queueing an extra skb.
Date: Tue, 2 Jun 2009 23:25:57 +0930
Message-ID: <200906022325.57961.rusty@rustcorp.com.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <20090602090552.GA26611@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43316 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371AbZFBN4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 09:56:01 -0400
In-Reply-To: <20090602090552.GA26611@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Jun 2009 06:35:52 pm Herbert Xu wrote:
> On Fri, May 29, 2009 at 11:46:04PM +0930, Rusty Russell wrote:
> > This effectively reverts 99ffc696d10b28580fe93441d627cf290ac4484c
> > "virtio: wean net driver off NETDEV_TX_BUSY".
> >
> > The complexity of queuing an skb (setting a tasklet to re-xmit) is
> > questionable, especially once we get rid of the other reason for the
> > tasklet in the next patch.
> >
> > If the skb won't fit in the tx queue, just return NETDEV_TX_BUSY.  It
> > might be frowned upon, but it's common and not going away any time
> > soon.
>
> This looks like a step backwards to me.  If we have to do this
> to fix a bug, sure.  But just doing it for the sake of it smells
> wrong.

I disagree.  We've introduced a third queue, inside the driver, one element 
long.  That feels terribly, terribly hacky and wrong.

What do we do if it overflows?  Discard the packet, even if we have room in the 
tx queue.   And when do we flush this queue?  Well, that's a bit messy.  
Obviously we need to enable the tx interrupt when the tx queue is full, but we 
can't just netif_wake_queue, we have to also flush the queue.  We can't do that 
in an irq handler, since we need to block the normal tx path (or introduce 
another lock and disable interrupts in our xmit routine).  So we add a tasklet 
to do this re-transmission.

Or, we could just "return NETDEV_TX_BUSY;".  I like that :)

Hope that clarifies,
Rusty.



>
> Cheers,

