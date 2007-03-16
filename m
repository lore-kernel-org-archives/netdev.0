From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #2]
Date: Fri, 16 Mar 2007 15:14:31 +0000
Message-ID: <26525.1174058071@redhat.com>
References: <20070316153408.3a9a244a@lxorguk.ukuu.org.uk>  <20070316151305.04cbc352@lxorguk.ukuu.org.uk> <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <25571.1174054993@redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46177 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965378AbXCPPOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 11:14:51 -0400
In-Reply-To: <20070316153408.3a9a244a@lxorguk.ukuu.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> So your messages are neither reliable not unreliable, nor ordered, nor
> unordered.

If you look at the LHS of each of your list of mappings again, you'll see
you've made an assumption there in considering it to be an exhaustive list.
You've assumed a service must be either a datagram service or a stream service;
I content that RxRPC is neither.

Let me explain.

RxRPC is not a datagram service because:

	A datagram is, to quote the Internet's Request for Comments 1594, "a
	self-contained, independent entity of data carrying sufficient
	information to be routed from the source to the destination computer
	without reliance on earlier exchanges between this source and
	destination computer and the transporting network.

An RxRPC operation fails the "without reliance on earlier exchanges" bit, and
I'd argue that it possibly fails the "self-contained" and "independent" bits
too.

RxRPC does use a datagram service as its transport, but it takes a minimum of
three packets to complete an operation: a request from the client, a reply from
the server and a final ACK from the client.  The second and third packets are
dependent on the first to give them meaning.

Looking at RxRPC from a client app point of view, you have to issue a request
packet and then await for the reply _associated_ with it (as marked by the
control data).  In the server app, you receive a request message, and then have
to make a reply _associated_ with that request.

Furthermore, you can have several operations in progress simultaneously on a
socket.  They are ordered with respect to themselves only; they are not ordered
with respect to each other.


RxRPC is also not a streamed data service because it doesn't have a stream of
data (either continuous [STREAM] or broken [SEQPACKET]) of indefinite length.
It has operations, each of which follows a sequence of discrete phases
(request, secure, secured, reply, final ACK).  Each operation is independent of
the other operations, and may overlap temporally with those others.


So, to summarise, I think this is a "new" type of flow model because:

 (1) It has discrete components (operations) rather than a flow.

 (2) The discrete components may overlap temporally (are unordered with respect
     to each other).

 (3) Each discrete component consists of a sequence of phases, first in one
     direction then the other and then back again rather than discrete
     independent messages (are ordered with respect to themselves).

 (4) It is reliable.

It also has security features, but I don't think that needs to be part of the
definition, even though negotiating it does require the use of extra packets of
special types.

> Until you work out what your messages actually are

I know what they are; and I don't think that what's available covers it.

> and use a proper standard socket type.

Assuming that that list is exhaustive...

> And "but there are higher layers" isn't relevant here, this is true for
> Appletalk as well and it doesn't have to go inventing new types for
> everything as you seem to.

The fact that there are higher layers is irrelevant.

David
