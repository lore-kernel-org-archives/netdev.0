From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Tue, 05 Jun 2007 17:31:20 -0700 (PDT)
Message-ID: <20070605.173120.59467114.davem@davemloft.net>
References: <E1HubUt-0004Hb-00@dorka.pomaz.szeredi.hu>
	<E1Hv980-0006gQ-00@dorka.pomaz.szeredi.hu>
	<20070605.000247.18308209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45944
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761956AbXFFAbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 20:31:06 -0400
In-Reply-To: <20070605.000247.18308209.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 05 Jun 2007 00:02:47 -0700 (PDT)

> From: Miklos Szeredi <miklos@szeredi.hu>
> Date: Mon, 04 Jun 2007 11:45:32 +0200
> 
> > > A recv() on an AF_UNIX, SOCK_STREAM socket can race with a
> > > send()+close() on the peer, causing recv() to return zero, even though
> > > the sent data should be received.
> > > 
> > > This happens if the send() and the close() is performed between
> > > skb_dequeue() and checking sk->sk_shutdown in unix_stream_recvmsg():
> > > 
> > > process A  skb_dequeue() returns NULL, there's no data in the socket queue
> > > process B  new data is inserted onto the queue by unix_stream_sendmsg()
> > > process B  sk->sk_shutdown is set to SHUTDOWN_MASK by unix_release_sock()
> > > process A  sk->sk_shutdown is checked, unix_release_sock() returns zero
> > 
> > This is only part of the story.  It turns out, there are other races
> > involving the garbage collector, that can throw away perfectly good
> > packets with AF_UNIX sockets in them.
> > 
> > The problems arise when a socket goes from installed to in-flight or
> > vica versa during garbage collection.  Since gc is done with a
> > spinlock held, this only shows up on SMP.
> > 
> > The following patch fixes it for me, but it's possibly the wrong
> > approach.
> > 
> > Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>

Concerning this specific patch I think we need to rethink it
a bit.

Holding a global mutex over recvmsg() calls under AF_UNIX is pretty
much a non-starter, this will kill performance for multi-threaded
apps.

One possible solution is for the garbage collection code to hold the
u->readlock while processing a socket, but be careful about deadlocks.

Anyone want to give that a try?
