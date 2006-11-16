From: David Howells <dhowells@redhat.com>
Subject: [RFC] AF_RXRPC proposal
Date: Thu, 16 Nov 2006 11:30:30 +0000
Message-ID: <25069.1163676630@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:26520 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1031163AbWKPLcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 06:32:42 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id kAGBWfid013424
	for <netdev@vger.kernel.org>; Thu, 16 Nov 2006 06:32:41 -0500
Received: from warthog.cambridge.redhat.com (warthog.cambridge.redhat.com [172.16.18.73])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id kAGBWeTl014957
	for <netdev@vger.kernel.org>; Thu, 16 Nov 2006 06:32:41 -0500
Received: from redhat.com (localhost.localdomain [127.0.0.1])
	by warthog.cambridge.redhat.com (8.13.8/8.13.8) with ESMTP id kAGBUUHf025070
	for <netdev@vger.kernel.org>; Thu, 16 Nov 2006 11:30:30 GMT
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

I've written a document to lay out what I'd like to do to make an AF_RXRPC
network protocol for Linux, with intent to replacing the current net/rxrpc/ in
the kernel and also providing an RxRPC transport for userspace.

Can you look it over and see what you think?

Also, is it feasible to add a new socket type?  I'm thinking of adding
SOCK_RPC to be used rathet than SOCK_DGRAM, SOCK_STREAM or whatever, since the
usage model doesn't fit the ones the currently exist.

Thanks!
David


			   =========================
			   AF_RXRPC NETWORK PROTOCOL
			   =========================

RxRPC is in essence a two-part protocol.  There is a session layer which
provides reliable virtual connections using UDP over IPv4 or IPv6 as the
transport layer, but implements a real network protocol, and there's the
presentation layer which renders structured data to binary blobs and back again
using XDR (as does SunRPC):

		+-------------+
		| Application |
		+-------------+
		|     XDR     |		Presentation
		+-------------+
		|    RxRPC    |		Session
		+-------------+
		|     UDP     |		Transport
		+-------------+

(Very OSI, I know, and probably wrong).


AF_RXRPC would provide:

 (1) Part of an RxRPC facility for both kernel and userspace applications by
     making the session part of it a Linux network protocol (AF_RXRPC).

 (2) A two-phase protocol.  The client transmits a blob and then receives a
     blob, and the server receives a blob and then transmits a blob.

 (3) Retention of the reusable bits of the transport system set up for one call
     to speed up subsequent calls.

 (4) A secure protocol, using the Linux kernel's key retention facility to
     manage security on the client end.  The server end must of necessity be
     more active in security negotiations.

AF_RXRPC would not provide XDR marshalling facilities.  That would be left to
the application.


Sockets of AF_RXRPC family would be:

 (1) created as type SOCK_RPC;

 (2) provided with a protocol of the type of underlying transport they're going
     to use - currently only PF_INET and PF_INET6 are supported.


The Andrew File System (AFS) is an example of an application that uses this and
that has both kernel (filesystem) and userspace (utility) components.


=====================
PROTOCOL DRIVER MODEL
=====================

An overview of the RxRPC protocol:

 (*) RxRPC sits on top of another networking protocol (UDP is the only option
     currently), and uses this to provide network transport.  UDP ports, for
     example, provide transport endpoints.

 (*) RxRPC supports multiple virtual "connections" from any given transport
     endpoint, thus allowing the endpoints to be shared, even to the same
     remote endpoint.

 (*) Each connection goes to a particular "service".  A connection may not go
     to multiple services.  A service may be considered the RxRPC equivalent of
     a port number.

 (*) Client-originating packets are marked, thus a transport endpoint can be
     shared between client and server connections (connections have a
     direction).

 (*) Up to about a billion connections may be supported concurrently between
     one local transport endpoint and one service on one remote endpoint.  An
     RxRPC connection is described by seven numbers:

	Local address	}
	Local port	} Transport (UDP) address
	Remote address	}
	Remote port	}
	Direction
	Connection ID
	Service ID

 (*) Each RxRPC operation is a "call".  A connection may make up to four
     billion calls, but only up to four calls may be in progress on a
     connection at any one time.

 (*) Calls are two-phase and asymmetric: the client sends its request data,
     which the service receives; then the service sends the reply data which
     the client receives.

 (*) The data are of indefinite size, the end of a phase is marked with a flag
     in the packet.

 (*) The first four bytes of the request data are the service operation ID.

 (*) Security is handled on a per-connection basis.  The connection is
     initiated by the first data packet on it arriving.  If security is
     requested, the server then issues a "challenge" and then the client
     replies with a "response".  If the response is successful, the security is
     set for the lifetime of that connection, and all subsequent calls made
     upon it use that same security.


About the AF_RXRPC driver:

 (*) The AF_RXRPC protocol would transparently use internal sockets of the
     transport protocol to represent transport endpoints.

 (*) AF_RXRPC sockets map onto RxRPC calls, not RxRPC connections.  RxRPC
     connections would also be handled transparently.

 (*) Additional parallel client connections would be initiated to support extra
     concurrent calls, up to a limit [tunable].

 (*) Each connection would be retained for a certain amount of time [tunable]
     after the last call currently using it has completed, in case a new call
     is made that could use it.

 (*) Each internal UDP socket would be retained [tunable] for a certain amount
     of time [tunable] after the last connection using it discarded, in case a
     new connection is made that could use it.

 (*) A client-side connection could only be shared between calls if they have
     have the same key struct describing their security (and assuming the calls
     would otherwise share the connection).  Non-secured calls would also be
     able to share connections with each other.

 (*) ACK'ing would be handled by the protocol driver automatically, including
     ping replying.

 (*) SO_KEEPALIVE would automatically ping the other side.


Interaction with the user of the RxRPC socket:

 (*) In the client, sending a request would be achieved with one or more
     sendmsgs, followed by the reply received with one or more recvmsgs.

 (*) Once the client has received the last bit of the reply with recvmsg, the
     socket would be again available to send a new call with sendmsg.

 (*) In the server, receiving a request would be achieved with one or more
     recvmsgs, followed by the reply transmitted with one or more sendmsgs.

     (*) The server could invoke a final recvmsg to pick up the success or
     	 failure of the reply reception.

     (*) The server could ACK the receipt of the request phase by doing an
     	 sendmsg() with a special control message if the request is going to
     	 take a long time to process.  Normally the first packet of the reply
     	 suffices to ACK the entire request.

 (*) Switching from sendmsg() to recvmsg() or vice versa would shift the state
     of the RPC operation, giving a final ACK on that phase of the protocol.

 (*) select() and poll() would show a socket as being writable if sendmsg() can
     be used to send a request or a reply, and readable if recvmsg() can be
     used to receive a request or a reply.  It would not be both readable and
     writable simultaneously.

 (*) The control data part of the msghdr struct would be used for a number of
     things:

     (*) Sending or receiving errors (aborts).

     (*) Sending ping requests and receiving ping replies.

     (*) Sending debug requests and receiving debug replies.

 (*) The server would have to assist in the setting up of security.  The server
     sends a challenge packet to the client and receives a response packet.


====================
EXAMPLE CLIENT USAGE
====================

A client would issue an operation by:

 (1) An RxRPC socket would be set up by:

	client = socket(AF_RXRPC, SOCK_RPC, PF_INET);

     Where the third parameter indicates the address type of the transport
     socket used - usually IPv4.

 (2) A local address could optionally be bound:

	struct sockaddr_rxrpc srx = {
		.srx_family	= AF_RXRPC,
		.srx_service	= 0,  /* we're a client */
		.transport_type	= SOCK_DGRAM,	/* type of transport socket */
		.transport.sin_family	= AF_INET,
		.transport.sin_port	= htons(7000), /* AFS callback */
		.transport.sin_address	= 0,  /* all local interfaces */
	};
	bind(client, &srx, sizeof(srx));

     This would specify the local UDP port to be used.  If not given, a random
     non-privileged port would be used.  A UDP port may be shared between
     several unrelated RxRPC sockets.  Security is handled on a basis of
     per-RxRPC virtual connection.

 (3) The security would be set:

	const char *key = "AFS:cambridge.redhat.com";
	setsockopt(client, SOL_RXRPC, RXRPC_SECURITY_KEY, key, strlen(key));

     This would issue a request_key() to get the security context.

 (4) The server would then be contacted:

	struct sockaddr_rxrpc srx = {
		.srx_family	= AF_RXRPC,
		.srx_service	= VL_SERVICE_ID,
		.transport_type	= SOCK_DGRAM,	/* type of transport socket */
		.transport.sin_family	= AF_INET,
		.transport.sin_port	= htons(7005), /* AFS volume manager */
		.transport.sin_address	= ...,
	};
	connect(client, &srx, sizeof(srx));

 (5) The request would be sent:

	sendmsg(client, msg, 0);

 (6) And then the reply received:

	recvmsg(client, msg, 0);

     If an abort/error was returned by the server, this will be returned in the
     control data buffer.

 (7) Then the socket would be closed or used to make another call.


====================
EXAMPLE SERVER USAGE
====================

A server would accept operations by:

 (1) An RxRPC socket would be set up by:

	server = socket(AF_RXRPC, SOCK_RPC, PF_INET);

     Where the third parameter indicates the address type of the transport
     socket used - usually IPv4.

 (2) A local address would be bound:

	struct sockaddr_rxrpc srx = {
		.srx_family	= AF_RXRPC,
		.srx_service	= VL_SERVICE_ID, /* RxRPC service ID */
		.transport_type	= SOCK_DGRAM,	/* type of transport socket */
		.transport.sin_family	= AF_INET,
		.transport.sin_port	= htons(7000), /* AFS callback */
		.transport.sin_address	= 0,  /* all local interfaces */
	};
	bind(server, &srx, sizeof(srx));

 (3) The server would then listen out for incoming calls:

	listen(server, 100);

 (4) It would accept calls that were made:

	struct sockaddr_rxrpc srx;
	socken_t slen = sizeof(srx)
	call = accept(server, &src, &slen);

 (5) The first data packet would then be received:

	recvmsg(call, msg, 0);

     A connection is discovered on the server by reception of the first data
     packet holding its connection ID.  Only then can security be set up.

 (6) The security context might need to be set up:

     (a) The security index can be examined:

	uint16_t sectype;
	socklen_t len = sizeof(sectype);
	getsockopt(call, SOL_RXRPC, RXRPC_GET_SECURITY_INDEX, &sectype, &len);

     (b) A security challenge can be made:

	sendmsg(call, msg, 0);

         The control message will contain the challenge; there would be no
         data.

     (c) And the security response received:

	recvmsg(call, msg, 0);

         The control message will contain the response; there would be no data.

     (d) The security context can then be set:

	setsockopt(call, SOL_RXRPC, RXRPC_SET_SECURITY, buffer, buflen);

     If the virtual RxRPC connection already has security set up, the
     getsockopt will indicate this, and steps (b) to (d) can be skipped.

     A security rejection would be achieved simply by closing the socket before
     step (d).

 (7) The data could then be received:

	recvmsg(call, msg, 0);

 (8) And then the reply transmitted:

	sendmsg(client, msg, 0);

     If an abort/error is to be served instead, that would be placed in the
     control data, and no data would be attached.

 (9) Then the socket would be closed.
