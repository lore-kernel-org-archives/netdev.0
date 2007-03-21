From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #3]
Date: Wed, 21 Mar 2007 13:26:44 +0000
Message-ID: <31052.1174483604@redhat.com>
References: <15256.1174429573@redhat.com>  <20070320213657.15afe5fa@lxorguk.ukuu.org.uk> <20070320195856.12853.63473.stgit@warthog.cambridge.redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, dhowells@redhat.com
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45454 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824AbXCUN1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 09:27:09 -0400
In-Reply-To: <15256.1174429573@redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells <dhowells@redhat.com> wrote:

> > - Why does rxrpc_writable always return 0 ?
> 
> Good point.  That's slightly tricky to deal with as output messages don't
> remain queued on the socket struct itself.  Hmmm...

Okay, I've fixed that by changing it to:

	static inline int rxrpc_writable(struct sock *sk)
	{
		return atomic_read(&sk->sk_wmem_alloc) < (size_t) sk->sk_sndbuf;
	}

All the rest of the sk_wmem_alloc management should be automatic through my
use of sock_alloc_send_skb() to allocate Tx buffers.

I notice that AF_UNIX effectively divides sk_sndbuf by four before doing the
comparison.  Any idea why (there's no comment to say)?  I presume it's so that
we show willingness to accept any chunk of data up to 3/4 of sk_sndbuf in size
if we flag POLLOUT, rather than the app finding POLLOUT is set, but it can
only send one byte of data.


I've still got a problem with this, though, and I'm not sure it's easy to
solve.  An RxRPC socket may be performing several calls at once.  It may have
sufficient space on the *socket* to accept more Tx data, but it may not be
possible to do so because the ACK window on the intended call may be full.  So
POLLOUT could be set, and we might still block anyway:-/

This is unlike SOCK_STREAM sockets for TCP or AF_UNIX, I think, because each
of those has but a single transmit queue:-/

I'm not sure there's a lot I can do about that, but there are a few
possibilities:

 (1) Always send data in non-blocking mode if we know there are multiple calls
     and we don't want to get stuck.  We'll get a suitable error message, but
     there's no notification that the Tx queue is has been unblocked.  I could
     add such a notification (it shouldn't be hard), there are two immediately
     obvious ways of doing it:

     (a) Raise a one-shot pollable event to indicate that one of the
     	 in-progress calls' Tx queues have come unstuck.  This'd require
     	 trying the non-stuck calls individually to find out which one it was.

     (b) Queue a message for recvmsg() to grab that says a Tx queue has become
     	 unstuck.  This would permit the control message to indicate the call.

 (2) Require a separate socket for each individual call.  This is a very
     heavyweight way of doing things, as it would require socket inodes and
     other stuff per call.  On the other hand it would permit a certain amount
     more flexibility.  The real downside is that I wouldn't want to be doing
     this for the in-kernel AFS filesystem, but maybe that could bypass the
     use of sockets.

 (3) Allow the app to nominate which call on a socket it wants a poll() on
     that socket to probe next.

David
