From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #3]
Date: Tue, 20 Mar 2007 22:10:10 +0000
Message-ID: <14961.1174428610@redhat.com>
References: <20070320211222.62dae706@lxorguk.ukuu.org.uk>  <20070320195856.12853.63473.stgit@warthog.cambridge.redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, David Howells <dhowells@redhat.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51882 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017AbXCTWKm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 18:10:42 -0400
In-Reply-To: <20070320211222.62dae706@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> >  (*) SOCK_RPC has been removed.  AF_RXRPC sockets now simply ignore the
> >      "type" argument to socket().
>
> This is also incorrect

Sigh.

And what would you have me do?  There *isn't* an appropriate SOCK_xxx constant
available, and you won't let me add one that is.  Maybe I should just pick
SOCK_DCCP and have done with it; it's as appropriate as DGRAM, RDM, SEQPACKET
or STREAM - except that would be silly.  I assert that RAW and PACKET are both
even less appropriate than any of the other choices.


Let me explain again why I think each choice is incorrect.  You gave me four
choices, which you and POSIX classify thus:

	Constant	Your Service type	POSIX Service Type
	===============	=======================	=======================
	SOCK_DGRAM	Datagram		Datagram
	SOCK_RDM	Datagram		Datagram
	SOCK_SEQPACKET	Datagram		Stream (maybe Datagram)
	SOCK_STREAM	Stream			Stream

A datagram service by definition (as can be found on various websites),
transfers a piece of data from one place to another with no dependence on and
no regard to any other pieces of data that the service is asked to transport.
At its simplest level (SOCK_DGRAM), that's _all_ it does.  SOCK_DGRAM makes no
assertions about whether the datagram will get there, and requires no report
that it did get there.  Furthermore, no ordering at all is imposed on the
sequence in which the far side sees any such pieces of data.

SOCK_RDM is a step up from that.  Again, like SOCK_DGRAM, it presents a
datagram service to the application.  But unlike SOCK_DGRAM, it will attempt to
report the success or failure of the attempt to transfer the data.  This may
involve exchanging further packets with the peer behind the scenes, but
ultimately, all it does is to transfer one piece of data from one peer to
another; the added value is that the sender can attempt to determine whether
this worked.  Furthermore, as for SOCK_DGRAM, no ordering at all is imposed on
the sequence in which the far side sees any such pieces of data.

SOCK_SEQPACKET can be considered a step up from SOCK_RDM.  It can be considered
to provide a reliable datagram service to the application (as SOCK_RDM), but
one in which the datagrams are guaranteed to be seen by the receiver in
precisely the same order as they are sent by the sender, with no datagrams
being lost from the sequence.  In this model, SOCK_SEQPACKET would be seen as
providing two independent, independently ordered streams of datagrams, one in
each direction.

SOCK_STREAM is a data streaming service in which data is guaranteed to come out
of the receiver in precisely the same order as it was put into the transmitter.
Furthermore, SOCK_STREAM can be seen as providing two independent,
independently ordered streams of data, one in each direction.

SOCK_SEQPACKET can also be considered to provide a streaming service (similar
to SOCK_STREAM) in which record boundaries are maintained.  Data is guaranteed
to come out of the receiver in precisely the order as it was put in to the
transmitter, but the receiver will break off and flag MSG_EOR at points in the
data flow that correspond to those at which the sender flagged a record
boundary.  In this model, SOCK_SEQPACKET would be seen as providing two
independent, independently ordered streams of data and record markers, one in
each direction.


In effect, SOCK_STREAM and SOCK_SEQPACKET can each be viewed as a pair of
independent, symmetric unidirectional services, one for each direction:

	+--------+                           +--------+
	|        |      +-------------+      |        |
	|        |----->|  Tx Stream  |----->|        |
	| Local  |      +-------------+      | Remote |
	| Socket |                           | Socket |
   _____|        |___________________________|        |_____
	|        |                           |        |
	|        |      +-------------+      |        |
	|        |<-----|  Rx Stream  |<-----|        |
	|        |      +-------------+      |        |
	+--------+                           +--------+

SOCK_SEQPACKET can give the appearance of being an ordered, reliable datagram
service simply by the application using it assuming that the record boundaries
delimit separate datagrams.

SOCK_DGRAM and SOCK_RDM, on the other hand, can be viewed as being a pair of
independent unidirectional asymmetric services, one that spits out packets and
one that collects datagrams.

	+--------+     +--+                   +--------+
	|        |     |Tx|----------         |        |
	|        |     +--+          \        |        |
	|        |    /               \       |        |
	|        |   /   +--+          \      |        |
	|        |->+--->|Tx|---------------->|        |
	| Local  |   \   +--+            \    | Remote |
	| Socket |    \                   --->| Socket |
	|        |     +--+                   |        |
	|        |     |Tx|--------X          |        |
	|        |     +--+                   |        |
   _____|        |____________________________|        |_____
	|        |                            |        |
	|        |                    +--+    |        |
	|        |              X-----|Rx|    |        |
	|        |                    +--+    |        |
	|        |                        \   |        |
	|        |                         +<-|        |
	|        |                        /   |        |
	|        |                    +--+    |        |
	|        |<-------------------|Rx|    |        |
	+--------+                    +--+    +--------+

The fact that SOCK_RDM may exchange extra packets behind the scenes is more or
less transparent to the application, and doesn't affect the apparent data flow
model.

Another way to look at it is that with all these four types, a half-way
shutdown() operation makes sense.  With SOCK_STREAM or SOCK_SEQPACKET it just
eliminates one of the two independent stream services; with SOCK_DGRAM or
SOCK_RDM, it eliminates the either capability to send datagrams or capability
to receive datagrams.

So, a quick summary of the guarantees:

 (1) SOCK_DGRAM: Datagram passing service.  Totally unordered and unreliable;
     the presentation of received packets is totally independent of the
     datagrams accepted for transmission - either side might be shut down
     without affecting the other.

 (2) SOCK_RDM: As SOCK_DGRAM, but includes reporting of lost datagrams and
     presumably resending and duplication elimination.  Again, reception is
     apparently (to the application) independent of transmission, and either
     side may be shut down without affecting the other.

 (3) SOCK_STREAM: Reliable and precisely ordered.  The data coming in is
     totally independent of the data going out as far as the application need
     be concerned.  Either side might be shut down without affecting the other.

 (4) SOCK_SEQPACKET: As SOCK_STREAM, but record boundaries may be placed in the
     transmission data stream by the sender, and these are also precisely
     ordered with respect to that data stream (and each other).  The input and
     output data streams are totally independent as far as the application need
     be concerned.  Either side might be shut down without affecting the other.

Now, do you note a common theme.  In each case, you can draw a line through a
pair of sockets; as far as the application is concerned, all the Tx side is on
one side of the line, and all the Rx side is on the other side of the line.
Either side might be shut down without affecting the other.  What goes on
underneath is (or should be) transparent to the application.

Furthermore, the above are either totally unordered or precisely ordered, but
only with respect to each side.  There is no ordering between sides at all
(they're completely independent to the application).

Do you agree with what I've said so far in my explanation?


Okay, now to RxRPC:

 (1) In RxRPC the sending side and the transmission side are irrevocably
     intertwined.  The reply phase of a call is dependent on the preceding
     request phase, despite the fact they go in opposite directions.  Both
     phases must take place in order to complete a call, and so there's a
     partial ordering across the two sides.

 (2) The messages that make up a particular request and its corresponding reply
     are precisely ordered with respect to each other, but are in no way
     ordered with respect to the messages that make up another request and its
     corresponding reply that go over the same socket.  This is something the
     application sees and has to deal with.

 (3) Partial shutdown() makes no sense with RxRPC sockets.  Shutting down the
     receiver in a client socket, for example, means that the app can't be
     presented with the reply to any call it sent, in which case the call would
     have to automatically be aborted.

 (4) A socket may maintain many simultaneous but independent calls.  The
     messages passed to sendmsg() for these may be interleaved at will, and
     recvmsg() will present them to the application in some random interleaving
     (though the ordering of the messages making up a particular call will be
     maintained).

Based on (1), (2) and (3), RxRPC is not a datagram service, and so neither
SOCK_DGRAM nor SOCK_RDM are correct.

Based on (1), (2), (3) and (4), RxRPC is not a streaming service, and so
neither SOCK_STREAM nor SOCK_DGRAM are correct.


Note also, the fact that RxRPC transits a SOCK_DGRAM protocol is irrelevant.
The application does not see that (though it may need to note it in its
address).  Similarly, an application does not see that TCP (SOCK_STREAM) deals
with the raw IP datagram protocol or an ethernet protocol (SOCK_RAW)
underneath.

David
