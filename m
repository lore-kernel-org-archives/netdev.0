From: Stefan Rompf <stefan@loplof.de>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Thu, 6 Dec 2007 11:56:48 +0100
Message-ID: <200712061156.48810.stefan@loplof.de>
References: <200712051939.08384.stefan@loplof.de> <200712060949.02524.stefan@loplof.de> <20071206.005344.74817074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, simon@fire.lp0.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.188]:11129 "EHLO
	mo-p07-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbXLFK6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 05:58:45 -0500
In-Reply-To: <20071206.005344.74817074.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 6. Dezember 2007 09:53 schrieb David Miller:

> > I think the words "shall fail" and "immediately" are quite clear.
>
> They are, but the context in which they apply is vague.

"socket is connection-mode" => SOCK_STREAM

> I can equally generate examples where the non-blocking behavior you
> are a proponent of would break non-blocking UDP apps during a
> sendmsg() call when we hit IPSEC resolution.  Yet similar language on
> blocking semantics exists for sendmsg() in the standards.

I am not a good enough kernel hacker to exactly understand the code flow in 
udp_sendmsg(). However, it seems that it first checks destination validity 
via ip_route_output_flow() and queues the message then. The sendmsg() 
documentation only talks about buffer space. I can see your dilemma.

The reason why I'm pushing this issue another time is that I know quite a 
bit about system level application development. A very typical design pattern 
for non-naive single or multi threaded programs is that they set all 
communication sockets to be nonblocking and use a select()/epoll() based loop 
to dispatch IO. This often includes initiating a TCP connect() and 
asynchronously waiting for it to finish or fail from the main loop.

The dangerous situation here is that in 99% of all cases things will just work 
because the phase 2 SA exists. In 0.8%, the SA will be established in <1 sec. 
However, in the rest of time the server application that you have considered 
to be stable will end up sleeping with all threads in a connect() call that 
is supposed to return immediatly.

> The world is shades of gray, implying anything else is foolhardy and
> that's how I'm handling this.

Even though I consider programmers that ignore the result code on a 
nonblocking UDP sendmsg() fools, I agree. May be the best compromise is what 
Herbert Xu suggested in <20071205001230.GA11391@gondor.apana.org.au> in this 
thread: At least, for connect() O_NONBLOCK ist ALWAYS respected. Because this 
is where the chance for breakage is highest.

Stefan
