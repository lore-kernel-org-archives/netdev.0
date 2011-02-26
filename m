From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Sat, 26 Feb 2011 08:57:18 +0800
Message-ID: <20110226005718.GA19889@gondor.apana.org.au>
References: <20110225.112019.48513284.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, tgraf@infradead.org, therbert@google.com,
	wsommerfeld@google.com, daniel.baluta@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42500 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755065Ab1BZA5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 19:57:52 -0500
Content-Disposition: inline
In-Reply-To: <20110225.112019.48513284.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> I think this is fundamentally a bind problem as well.

I'm fairly certain the bottleneck is indeed in the kernel, and
in the UDP stack in particular.

This is born out by a test where I used two named worker threads,
both working on the same socket.  Stracing shows that they're
working flat out only doing sendmsg/recvmsg.

The result was that they obtained (in aggregate) half the throughput
of a single worker thread.

I then retested by having them use two sockets and the performance
greatly improved.

Now this is actually expected since our UDP stack is essentially
single-threaded on the send side when only one socket is being
used, mostly due to the corking functionality.

I'm unsure how big a role the receive side scalability actually
plays in this case, but I suspect it isn't great.

Which is why I'm quite skeptical about this REUSEPORT patch as
IMHO the only reason it produces a great result is solely because
it is allowing parallel sends going out.

Rather than modifying all UDP applications out there to fix what
is fundamentally a kernel problem, I think what we should do is
fix the UDP stack so that it actually scales.

It isn't all that hard since the easy way would be to only take
the lock if we're already corked or about to cork.

For the receive side we also don't need REUSEPORT as we can simply
make our UDP stack multiqueue.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
