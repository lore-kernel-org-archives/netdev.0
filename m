From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Tue, 07 Sep 2010 22:34:59 -0400
Message-ID: <4C86F653.6070707@hp.com>
References: <4C865C21.5010803@ans.pl>	 <1283877391.2313.62.camel@edumazet-laptop>	 <1283887569.2634.95.camel@edumazet-laptop>	 <20100907.125947.39192078.davem@davemloft.net> <1283895316.2634.248.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ole@ans.pl,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:25335 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab0IHCfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 22:35:03 -0400
In-Reply-To: <1283895316.2634.248.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2010 05:35 PM, Eric Dumazet wrote:
> Problem is ip4_datagram_connect() also sets inet->inet_rcv_saddr (from
> INADDR_ANY to IP source address, given the current route to remote end
> point). Only the first connect() on the socket does this. Following ones
> dont change the (possibly wrong) source address.
> 
> This breaks the secondary UDP hash, based on (ADDRESS, port), that was
> computed by inet_autobind(). If more than 10 sockets are linked in
> primary hash chain, we can drop incoming packets because searches are
> done in wrong secondary hash chain.

I can't confirm this since I don't have 10 sockets in my primary hash
chain at the moment...

> This also potentially breaks multiple connect() to change remote
> endpoints, because old source address might be non usable for packets to
> new destination.
> 
> If route happens to change, then we should automatically change our
> source address too, at next sendmsg() call, and UDP code deals with this
> just fine.
> 
> If an application needs to specify a precise source address, it must use
> bind() system call. connect() man page only refers to remote address,
> not local one.

Is this really the right thing to do?  Linux has been doing this forever,
right?  Just like BSD has done it forever.  The way I've always "cleared"
a local address is to set the address family to AF_UNSPEC on the next
connect() call, as mentioned on the man page.  I just want to make sure
we're not changing something just to work around a broken application,
sendto()/sendmsg() work perfect in this case by not setting the local address.

BTW, it seems as though the reason this might only happen sometimes is
that if the first connect() is to 127.0.0.1, you won't be able to then
try and connect to say, 192.168.1.1.  If you first connect() to a remote
address things will probably just work.

My possibly wrong $.02

-Brian
