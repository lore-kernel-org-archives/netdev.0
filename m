From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Tue, 07 Sep 2010 20:34:10 -0700 (PDT)
Message-ID: <20100907.203410.245386536.davem@davemloft.net>
References: <20100907.125947.39192078.davem@davemloft.net>
	<1283895316.2634.248.camel@edumazet-laptop>
	<4C86F653.6070707@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ole@ans.pl, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52829
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751147Ab0IHDdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 23:33:52 -0400
In-Reply-To: <4C86F653.6070707@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 07 Sep 2010 22:34:59 -0400

> Is this really the right thing to do?  Linux has been doing this forever,
> right?  Just like BSD has done it forever.

Indeed, I checked for this in Stevens volume 2 when I reviewed
Eric's patch, the logic is identical.

> The way I've always "cleared" a local address is to set the address
> family to AF_UNSPEC on the next connect() call, as mentioned on the
> man page.  I just want to make sure we're not changing something
> just to work around a broken application, sendto()/sendmsg() work
> perfect in this case by not setting the local address.
> 
> BTW, it seems as though the reason this might only happen sometimes is
> that if the first connect() is to 127.0.0.1, you won't be able to then
> try and connect to say, 192.168.1.1.  If you first connect() to a remote
> address things will probably just work.

Actually I have enough doubts about this too.  So I'm going to hold
off on the patch until we sort this out.

As Eric stated, sendmsg() on raw and UDP sockets pick the source
address based upon the bound or looked up route anyways.  But still
I think something still might end up being not-kosher with Eric's
change.

More so, I suspect, the issue is simply that the ordering of events
is simply inconvenient for the secondary hash implementation :-)
The port bind happens before the source address is bound, and that
is what screws everything up.

In this sense leaving the source addresses at INADDR_ANY is just a
workaround for the secondary hash table :-)
