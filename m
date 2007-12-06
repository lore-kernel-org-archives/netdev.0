From: David Miller <davem@davemloft.net>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Thu, 06 Dec 2007 03:13:02 -0800 (PST)
Message-ID: <20071206.031302.201608796.davem@davemloft.net>
References: <200712060949.02524.stefan@loplof.de>
	<20071206.005344.74817074.davem@davemloft.net>
	<200712061156.48810.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, simon@fire.lp0.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: stefan@loplof.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37367
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751901AbXLFLND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 06:13:03 -0500
In-Reply-To: <200712061156.48810.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Rompf <stefan@loplof.de>
Date: Thu, 6 Dec 2007 11:56:48 +0100

> Am Donnerstag, 6. Dezember 2007 09:53 schrieb David Miller:
> 
> > > I think the words "shall fail" and "immediately" are quite clear.
> >
> > They are, but the context in which they apply is vague.
> 
> "socket is connection-mode" => SOCK_STREAM

I meant whether "immediately" mean in reference to socket
state or includes auxiliary things like route lookups.

When you do a non-blocking write on a socket, things like
memory allocations can block, potentially for a long time.
It is an example where there are definite boundaries to where
the non-blocking'ness applies.

And therefore it is not so cut and dry and you present this
issue.

> The reason why I'm pushing this issue another time is that I know quite a 
> bit about system level application development. A very typical design pattern 
> for non-naive single or multi threaded programs is that they set all 
> communication sockets to be nonblocking and use a select()/epoll() based loop 
> to dispatch IO. This often includes initiating a TCP connect() and 
> asynchronously waiting for it to finish or fail from the main loop.
>
> The dangerous situation here is that in 99% of all cases things will just work 
> because the phase 2 SA exists. In 0.8%, the SA will be established in <1 sec. 
> However, in the rest of time the server application that you have considered 
> to be stable will end up sleeping with all threads in a connect() call that 
> is supposed to return immediatly.

And that connect() call can hang for a long time due to any memory
allocation done in the connect() path.

You are not avoiding blocking by setting O_NONBLOCK on the socket, it
is quite foolhardy to think that it does so unilaterally.

And that's why this is a grey area.  Why is waiting for memory
allocation on a O_NONBLOCK socket OK but waiting for IPSEC route
resolution is not?
