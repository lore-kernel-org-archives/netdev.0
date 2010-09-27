From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 07:39:01 +0200
Message-ID: <20100927053901.GL12373@1wt.eu>
References: <20100926225440.GH12373@1wt.eu> <20100926.160838.246540910.davem@davemloft.net> <20100926232530.GK12373@1wt.eu> <20100926.181202.28824153.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45711 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751888Ab0I0FjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 01:39:06 -0400
Content-Disposition: inline
In-Reply-To: <20100926.181202.28824153.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 26, 2010 at 06:12:02PM -0700, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Mon, 27 Sep 2010 01:25:30 +0200
> 
> > Agreed. But that's not a reason for killing outgoing data that is
> > being sent when there are some data left in the rcv buffer.
> 
> What alternative notification to the peer do you suggest other than a
> reset, then?  TCP gives us no other.

I know, and I agree to send the reset, but after the data are correctly
transferred. This reset's purpose is only to inform the other side that
the data it sent were destroyed. It is not a requirement to tell it they
were destroyed earlier or later. What matters is that it's informed they
were destroyed.

That's why I think that it is perfectly reasonable to either destroy them
after the ACK or simply notify about their destruction after the ACK.

Instead of having :

        A                                               B

       --->     <SEQ=100><ACK=300>                     --->
       <---     <SEQ=300><ACK=100><DATA=10>            <---
       --->     <SEQ=100><ACK=310>                     --->
       send(100)
       shutdown()
       close()
       --->     <SEQ=100><CTL=RST>                     --->

We would just have :

        A                                               B

       --->     <SEQ=100><ACK=300>                     --->
       <---     <SEQ=300><ACK=100><DATA=10>            <---
       --->     <SEQ=100><ACK=310>                     --->
       send(100)
       shutdown()
       close()
       --->     <SEQ=100><ACK=310><DATA=100><CTL=FIN>  --->
       <---     <SEQ=300><ACK=111>                     <---
       --->     <SEQ=111><CTL=RST>                     --->

Note that the notification is exactly the same as if we wanted
to notify B about the destruction of data that were sent just
after the close, because the RST only carries a SEQ field and
no ACK indicating what it destroyed :

        A                                               B

       --->     <SEQ=100><ACK=300>                     --->
       send(100)
       shutdown()
       --->     <SEQ=100><ACK=310><DATA=100><CTL=FIN>  --->
       <---     <SEQ=300><ACK=111><DATA=10>            <---
       close()
       --->     <SEQ=111><CTL=RST>                     --->

In my opinion, last two examples are perfectly valid, they just mean
"after that, I close and don't want to hear about you again".

> That's the thing, data integrity is full duplex, thus once it has been
> compromised in one direction everything currently in flight must be
> zapped.

I'm well aware of that, and even though that's an annoying method, we
must live with it, it's probably one of the things that contribute TCP
its well known reliability. But I think that RFC 2525 abused the TCP
use based on traces showing a bad behaviour and overlooked all impacts
(nothing there talks about the case of data being sent or in flight at
the moment of the close).

Regards,
Willy

