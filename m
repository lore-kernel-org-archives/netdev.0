From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 21 May 2009 13:27:53 -0300
Message-ID: <20090521162753.GI5956@ghostprotocols.net>
References: <20090520230652.GB5956@ghostprotocols.net> <20090521161000.GA6638@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56901 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753999AbZEUQ2C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 12:28:02 -0400
Content-Disposition: inline
In-Reply-To: <20090521161000.GA6638@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, May 21, 2009 at 08:10:00PM +0400, Evgeniy Polyakov escreveu:
> Hi Arnaldo.
> 
> On Wed, May 20, 2009 at 08:06:52PM -0300, Arnaldo Carvalho de Melo (acme@redhat.com) wrote:
> > Meaning receive multiple messages, reducing the number of syscalls and
> > net stack entry/exit operations.
> > 
> > Next patches will introduce mechanisms where protocols that want to
> > optimize this operation will provide an unlocked_recvmsg operation.
>  
> What's the difference from the single msg with multiple iovecs?

recvmsg consumes just one skb, a datagram, truncating if it has more
bytes than asked and giving less bytes than asked for if the skb being
consumer is smaller than requested.

WRT iovec, it gets this skb/datagram and goes on filling iovec entry by
entry, till it exhausts the skb.

The usecase here is: UDP socket has multiple skbs in its receive queue,
so application will make several syscalls to get those skbs while we
could return multiple datagrams in just one syscall + fd lookup + LSM
validation + lock_sock + release_sock.

We could use some sort of setsockopt to instead put a datagram per iovec
entry, but that would be cumbersome, using recvmsg + recvmmsg on the
same code should be possible without require setsockopts to switch
modes.

The proposed API just adds an "array mode" for recvmsg, keeping the
existing semantics as much as possible, to ease converting applications
to it, libraries would just do some internal caching and its users
wouldn't notice the change.
 
> Can we implement receiving from multiple sockets using this or similar interface?

Not really, we don't pass something like a poll_fd array, the operation
as proposed is per socket.

- Arnaldo
