From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #2]
Date: Mon, 19 Mar 2007 12:59:14 +0000
Message-ID: <3728.1174309154@redhat.com>
References: <20070319130428.4b645207@lxorguk.ukuu.org.uk>  <20070318142315.6f881ec8@lxorguk.ukuu.org.uk> <20070316153408.3a9a244a@lxorguk.ukuu.org.uk> <20070316151305.04cbc352@lxorguk.ukuu.org.uk> <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <25571.1174054993@redhat.com> <26525.1174058071@redhat.com> <20070316171141.7a4de504@lxorguk.ukuu.org.uk> <076F1B35-BE08-41B4-8294-581EDAFF4ACC@mac.com> <2578.1174305403@redhat.com>
Cc: Kyle Moffett <mrmacman_g4@mac.com>, davem@davemloft.net,
	netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43579 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933850AbXCSM7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 08:59:40 -0400
In-Reply-To: <20070319130428.4b645207@lxorguk.ukuu.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > message transmission.  You yourself defined RDM to be a datagram service.
> > RxRPC is not, in my opinion, a datagram service, and neither is it a stream
> > service.
> 
> Message is what I should have said.

socket(2) also says datagram...

> Which is just fine, does it need to be one or the other. SOCK_DGRAM an be
> both connection oriented or connectionless.

Is SOCK_DGRAM ever connection-oriented?  Over an AF_INET socket it isn't really
so.  Yes, you can use connect() to point a UDP socket at a particular target,
but you haven't really made a connection.

> > Well, I suggest SOCK_RPC, not SOCK_RXRPC.  There's no particular reason
> > such a flow type has to be limited to RxRPC.
> 
> Other RPC types use normal socket types.

They do?  Examples please.  I didn't think Linux, at least, has any other RPC
socket families, though I could be wrong as I haven't made a thorough study of
them.

> > I'd say that that precludes applicability on two points: firstly, RxRPC is
> > not a datagram layer by the definition I provided in a previous email; and
> > secondly, RxRPC *does* provide some ordering guarantees.
> 
> So you want SOCK_SEQPACKET perhaps then ?

Perhaps; but I think that's wrong also.  You yourself defined SEQPACKET to be a
datagram service, and FC6 socket(2) agrees.  The POSIX definition, however
disagrees[*]: it claims that SEQPACKET is a stream-based service that permits
record markers to be embedded in the stream.  I can see how the two can be two
views of the same thing, but it looks like in either case the two flows are
independent at the socket level - which is not so for RxRPC as requests,
replies and ACKs are obviously not independent.

Furthermore:

 (1) The message flow in RxRPC is not completely ordered as seems to be
     required in SEQPACKET: packets going into the Tx socket need not come out
     of the Rx socket in the same order.  The only ordering is over the packets
     of a particular operation (as labelled by the control data).

 (2) The RxRPC sockets don't actually require a formal connection.  Even at the
     protocol level, there is no connection negotiation and no disconnection.
     A virtual connection more or less springs up spontaneously when the first
     data packet on it arrives.  Virtual connections are really only ways of
     avoiding having to set up the security for every call.

     I have made my client sockets use connect(), but that's just a convenience
     and I need to make it possible to avoid doing that to make it useful to
     the kernel.  It's similar to SOCK_DGRAM sockets in this respect.

David

[*] There has been discussion on this.
