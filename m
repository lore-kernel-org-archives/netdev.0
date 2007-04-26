From: David Howells <dhowells@redhat.com>
Subject: [PATCH 04/14] AF_RXRPC: Provide secure RxRPC sockets for use by
	userspace and kernel both [net-2.6]
Date: Thu, 26 Apr 2007 20:54:36 +0100
Message-ID: <20070426195436.24531.34654.stgit@warthog.cambridge.redhat.com>
References: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57870 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754992AbXDZTy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 15:54:56 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3QJsscX028488
	for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 15:54:54 -0400
In-Reply-To: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provide AF_RXRPC sockets that can be used to talk to AFS servers, or serve
answers to AFS clients.  KerberosIV security is fully supported.  The patches
and some example test programs can be found in:

	http://people.redhat.com/~dhowells/rxrpc/

This will eventually replace the old implementation of kernel-only RxRPC
currently resident in net/rxrpc/.

The following documentation is from Documentation/networking/rxrpc.txt:

			    ======================
			    RxRPC NETWORK PROTOCOL
			    ======================

The RxRPC protocol driver provides a reliable two-phase transport on top of UDP
that can be used to perform RxRPC remote operations.  This is done over sockets
of AF_RXRPC family, using sendmsg() and recvmsg() with control data to send and
receive data, aborts and errors.

Contents of this document:

 (*) Overview.

 (*) RxRPC protocol summary.

 (*) AF_RXRPC driver model.

 (*) Control messages.

 (*) Socket options.

 (*) Security.

 (*) Example client usage.

 (*) Example server usage.


========
OVERVIEW
========

RxRPC is a two-layer protocol.  There is a session layer which provides
reliable virtual connections using UDP over IPv4 (or IPv6) as the transport
layer, but implements a real network protocol; and there's the presentation
layer which renders structured data to binary blobs and back again using XDR
(as does SunRPC):

		+-------------+
		| Application |
		+-------------+
		|     XDR     |		Presentation
		+-------------+
		|    RxRPC    |		Session
		+-------------+
		|     UDP     |		Transport
		+-------------+


AF_RXRPC provides:

 (1) Part of an RxRPC facility for both kernel and userspace applications by
     making the session part of it a Linux network protocol (AF_RXRPC).

 (2) A two-phase protocol.  The client transmits a blob (the request) and then
     receives a blob (the reply), and the server receives the request and then
     transmits the reply.

 (3) Retention of the reusable bits of the transport system set up for one call
     to speed up subsequent calls.

 (4) A secure protocol, using the Linux kernel's key retention facility to
     manage security on the client end.  The server end must of necessity be
     more active in security negotiations.

AF_RXRPC does not provide XDR marshalling/presentation facilities.  That is
left to the application.  AF_RXRPC only deals in blobs.  Even the operation ID
is just the first four bytes of the request blob, and as such is beyond the
kernel's interest.


Sockets of AF_RXRPC family are:

 (1) created as type SOCK_DGRAM;

 (2) provided with a protocol of the type of underlying transport they're going
     to use - currently only PF_INET is supported.


The Andrew File System (AFS) is an example of an application that uses this and
that has both kernel (filesystem) and userspace (utility) components.


======================
RXRPC PROTOCOL SUMMARY
======================

An overview of the RxRPC protocol:

 (*) RxRPC sits on top of another networking protocol (UDP is the only option
     currently), and uses this to provide network transport.  UDP ports, for
     example, provide transport endpoints.

 (*) RxRPC supports multiple virtual "connections" from any given transport
     endpoint, thus allowing the endpoints to be shared, even to the same
     remote endpoint.

 (*) Each connection goes to a particular "service".  A connection may not go
     to multiple services.  A service may be considered the RxRPC equivalent of
     a port number.  AF_RXRPC permits multiple services to share an endpoint.

 (*) Client-originating packets are marked, thus a transport endpoint can be
     shared between client and server connections (connections have a
     direction).

 (*) Up to a billion connections may be supported concurrently between one
     local transport endpoint and one service on one remote endpoint.  An RxRPC
     connection is described by seven numbers:

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
     which the service receives; then the service transmits the reply data
     which the client receives.

 (*) The data blobs are of indefinite size, the end of a phase is marked with a
     flag in the packet.  The number of packets of data making up one blob may
     not exceed 4 billion, however, as this would cause the sequence number to
     wrap.

 (*) The first four bytes of the request data are the service operation ID.

 (*) Security is negotiated on a per-connection basis.  The connection is
     initiated by the first data packet on it arriving.  If security is
     requested, the server then issues a "challenge" and then the client
     replies with a "response".  If the response is successful, the security is
     set for the lifetime of that connection, and all subsequent calls made
     upon it use that same security.  In the event that the server lets a
     connection lapse before the client, the security will be renegotiated if
     the client uses the connection again.

 (*) Calls use ACK packets to handle reliability.  Data packets are also
     explicitly sequenced per call.

 (*) There are two types of positive acknowledgement: hard-ACKs and soft-ACKs.
     A hard-ACK indicates to the far side that all the data received to a point
     has been received and processed; a soft-ACK indicates that the data has
     been received but may yet be discarded and re-requested.  The sender may
     not discard any transmittable packets until they've been hard-ACK'd.

 (*) Reception of a reply data packet implicitly hard-ACK's all the data
     packets that make up the request.

 (*) An call is complete when the request has been sent, the reply has been
     received and the final hard-ACK on the last packet of the reply has
     reached the server.

 (*) An call may be aborted by either end at any time up to its completion.


=====================
AF_RXRPC DRIVER MODEL
=====================

About the AF_RXRPC driver:

 (*) The AF_RXRPC protocol transparently uses internal sockets of the transport
     protocol to represent transport endpoints.

 (*) AF_RXRPC sockets map onto RxRPC connection bundles.  Actual RxRPC
     connections are handled transparently.  One client socket may be used to
     make multiple simultaneous calls to the same service.  One server socket
     may handle calls from many clients.

 (*) Additional parallel client connections will be initiated to support extra
     concurrent calls, up to a tunable limit.

 (*) Each connection is retained for a certain amount of time [tunable] after
     the last call currently using it has completed in case a new call is made
     that could reuse it.

 (*) Each internal UDP socket is retained [tunable] for a certain amount of
     time [tunable] after the last connection using it discarded, in case a new
     connection is made that could use it.

 (*) A client-side connection is only shared between calls if they have have
     the same key struct describing their security (and assuming the calls
     would otherwise share the connection).  Non-secured calls would also be
     able to share connections with each other.

 (*) A server-side connection is shared if the client says it is.

 (*) ACK'ing is handled by the protocol driver automatically, including ping
     replying.

 (*) SO_KEEPALIVE automatically pings the other side to keep the connection
     alive [TODO].

 (*) If an ICMP error is received, all calls affected by that error will be
     aborted with an appropriate network error passed through recvmsg().


Interaction with the user of the RxRPC socket:

 (*) A socket is made into a server socket by binding an address with a
     non-zero service ID.

 (*) In the client, sending a request is achieved with one or more sendmsgs,
     followed by the reply being received with one or more recvmsgs.

 (*) The first sendmsg for a request to be sent from a client contains a tag to
     be used in all other sendmsgs or recvmsgs associated with that call.  The
     tag is carried in the control data.

 (*) connect() is used to supply a default destination address for a client
     socket.  This may be overridden by supplying an alternate address to the
     first sendmsg() of a call (struct msghdr::msg_name).

 (*) If connect() is called on an unbound client, a random local port will
     bound before the operation takes place.

 (*) A server socket may also be used to make client calls.  To do this, the
     first sendmsg() of the call must specify the target address.  The server's
     transport endpoint is used to send the packets.

 (*) Once the application has received the last message associated with a call,
     the tag is guaranteed not to be seen again, and so it can be used to pin
     client resources.  A new call can then be initiated with the same tag
     without fear of interference.

 (*) In the server, a request is received with one or more recvmsgs, then the
     the reply is transmitted with one or more sendmsgs, and then the final ACK
     is received with a last recvmsg.

 (*) When sending data for a call, sendmsg is given MSG_MORE if there's more
     data to come on that call.

 (*) When receiving data for a call, recvmsg flags MSG_MORE if there's more
     data to come for that call.

 (*) When receiving data or messages for a call, MSG_EOR is flagged by recvmsg
     to indicate the terminal message for that call.

 (*) A call may be aborted by adding an abort control message to the control
     data.  Issuing an abort terminates the kernel's use of that call's tag.
     Any messages waiting in the receive queue for that call will be discarded.

 (*) Aborts, busy notifications and challenge packets are delivered by recvmsg,
     and control data messages will be set to indicate the context.  Receiving
     an abort or a busy message terminates the kernel's use of that call's tag.

 (*) The control data part of the msghdr struct is used for a number of things:

     (*) The tag of the intended or affected call.

     (*) Sending or receiving errors, aborts and busy notifications.

     (*) Notifications of incoming calls.

     (*) Sending debug requests and receiving debug replies [TODO].

 (*) When the kernel has received and set up an incoming call, it sends a
     message to server application to let it know there's a new call awaiting
     its acceptance [recvmsg reports a special control message].  The server
     application then uses sendmsg to assign a tag to the new call.  Once that
     is done, the first part of the request data will be delivered by recvmsg.

 (*) The server application has to provide the server socket with a keyring of
     secret keys corresponding to the security types it permits.  When a secure
     connection is being set up, the kernel looks up the appropriate secret key
     in the keyring and then sends a challenge packet to the client and
     receives a response packet.  The kernel then checks the authorisation of
     the packet and either aborts the connection or sets up the security.

 (*) The name of the key a client will use to secure its communications is
     nominated by a socket option.


Notes on recvmsg:

 (*) If there's a sequence of data messages belonging to a particular call on
     the receive queue, then recvmsg will keep working through them until:

     (a) it meets the end of that call's received data,

     (b) it meets a non-data message,

     (c) it meets a message belonging to a different call, or

     (d) it fills the user buffer.

     If recvmsg is called in blocking mode, it will keep sleeping, awaiting the
     reception of further data, until one of the above four conditions is met.

 (2) MSG_PEEK operates similarly, but will return immediately if it has put any
     data in the buffer rather than sleeping until it can fill the buffer.

 (3) If a data message is only partially consumed in filling a user buffer,
     then the remainder of that message will be left on the front of the queue
     for the next taker.  MSG_TRUNC will never be flagged.

 (4) If there is more data to be had on a call (it hasn't copied the last byte
     of the last data message in that phase yet), then MSG_MORE will be
     flagged.


================
CONTROL MESSAGES
================

AF_RXRPC makes use of control messages in sendmsg() and recvmsg() to multiplex
calls, to invoke certain actions and to report certain conditions.  These are:

	MESSAGE ID		SRT DATA	MEANING
	=======================	=== ===========	===============================
	RXRPC_USER_CALL_ID	sr- User ID	App's call specifier
	RXRPC_ABORT		srt Abort code	Abort code to issue/received
	RXRPC_ACK		-rt n/a		Final ACK received
	RXRPC_NET_ERROR		-rt error num	Network error on call
	RXRPC_BUSY		-rt n/a		Call rejected (server busy)
	RXRPC_LOCAL_ERROR	-rt error num	Local error encountered
	RXRPC_NEW_CALL		-r- n/a		New call received
	RXRPC_ACCEPT		s-- n/a		Accept new call

	(SRT = usable in Sendmsg / delivered by Recvmsg / Terminal message)

 (*) RXRPC_USER_CALL_ID

     This is used to indicate the application's call ID.  It's an unsigned long
     that the app specifies in the client by attaching it to the first data
     message or in the server by passing it in association with an RXRPC_ACCEPT
     message.  recvmsg() passes it in conjunction with all messages except
     those of the RXRPC_NEW_CALL message.

 (*) RXRPC_ABORT

     This is can be used by an application to abort a call by passing it to
     sendmsg, or it can be delivered by recvmsg to indicate a remote abort was
     received.  Either way, it must be associated with an RXRPC_USER_CALL_ID to
     specify the call affected.  If an abort is being sent, then error EBADSLT
     will be returned if there is no call with that user ID.

 (*) RXRPC_ACK

     This is delivered to a server application to indicate that the final ACK
     of a call was received from the client.  It will be associated with an
     RXRPC_USER_CALL_ID to indicate the call that's now complete.

 (*) RXRPC_NET_ERROR

     This is delivered to an application to indicate that an ICMP error message
     was encountered in the process of trying to talk to the peer.  An
     errno-class integer value will be included in the control message data
     indicating the problem, and an RXRPC_USER_CALL_ID will indicate the call
     affected.

 (*) RXRPC_BUSY

     This is delivered to a client application to indicate that a call was
     rejected by the server due to the server being busy.  It will be
     associated with an RXRPC_USER_CALL_ID to indicate the rejected call.

 (*) RXRPC_LOCAL_ERROR

     This is delivered to an application to indicate that a local error was
     encountered and that a call has been aborted because of it.  An
     errno-class integer value will be included in the control message data
     indicating the problem, and an RXRPC_USER_CALL_ID will indicate the call
     affected.

 (*) RXRPC_NEW_CALL

     This is delivered to indicate to a server application that a new call has
     arrived and is awaiting acceptance.  No user ID is associated with this,
     as a user ID must subsequently be assigned by doing an RXRPC_ACCEPT.

 (*) RXRPC_ACCEPT

     This is used by a server application to attempt to accept a call and
     assign it a user ID.  It should be associated with an RXRPC_USER_CALL_ID
     to indicate the user ID to be assigned.  If there is no call to be
     accepted (it may have timed out, been aborted, etc.), then sendmsg will
     return error ENODATA.  If the user ID is already in use by another call,
     then error EBADSLT will be returned.


==============
SOCKET OPTIONS
==============

AF_RXRPC sockets support a few socket options at the SOL_RXRPC level:

 (*) RXRPC_SECURITY_KEY

     This is used to specify the description of the key to be used.  The key is
     extracted from the calling process's keyrings with request_key() and
     should be of "rxrpc" type.

     The optval pointer points to the description string, and optlen indicates
     how long the string is, without the NUL terminator.

 (*) RXRPC_SECURITY_KEYRING

     Similar to above but specifies a keyring of server secret keys to use (key
     type "keyring").  See the "Security" section.

 (*) RXRPC_EXCLUSIVE_CONNECTION

     This is used to request that new connections should be used for each call
     made subsequently on this socket.  optval should be NULL and optlen 0.

 (*) RXRPC_MIN_SECURITY_LEVEL

     This is used to specify the minimum security level required for calls on
     this socket.  optval must point to an int containing one of the following
     values:

     (a) RXRPC_SECURITY_PLAIN

     	 Encrypted checksum only.

     (b) RXRPC_SECURITY_AUTH

     	 Encrypted checksum plus packet padded and first eight bytes of packet
     	 encrypted - which includes the actual packet length.

     (c) RXRPC_SECURITY_ENCRYPTED

     	 Encrypted checksum plus entire packet padded and encrypted, including
     	 actual packet length.


========
SECURITY
========

Currently, only the kerberos 4 equivalent protocol has been implemented
(security index 2 - rxkad).  This requires the rxkad module to be loaded and,
on the client, tickets of the appropriate type to be obtained from the AFS
kaserver or the kerberos server and installed as "rxrpc" type keys.  This is
normally done using the klog program.  An example simple klog program can be
found at:

	http://people.redhat.com/~dhowells/rxrpc/klog.c

The payload provided to add_key() on the client should be of the following
form:

	struct rxrpc_key_sec2_v1 {
		uint16_t	security_index;	/* 2 */
		uint16_t	ticket_length;	/* length of ticket[] */
		uint32_t	expiry;		/* time at which expires */
		uint8_t		kvno;		/* key version number */
		uint8_t		__pad[3];
		uint8_t		session_key[8];	/* DES session key */
		uint8_t		ticket[0];	/* the encrypted ticket */
	};

Where the ticket blob is just appended to the above structure.


For the server, keys of type "rxrpc_s" must be made available to the server.
They have a description of "<serviceID>:<securityIndex>" (eg: "52:2" for an
rxkad key for the AFS VL service).  When such a key is created, it should be
given the server's secret key as the instantiation data (see the example
below).

	add_key("rxrpc_s", "52:2", secret_key, 8, keyring);

A keyring is passed to the server socket by naming it in a sockopt.  The server
socket then looks the server secret keys up in this keyring when secure
incoming connections are made.  This can be seen in an example program that can
be found at:

	http://people.redhat.com/~dhowells/rxrpc/listen.c


====================
EXAMPLE CLIENT USAGE
====================

A client would issue an operation by:

 (1) An RxRPC socket is set up by:

	client = socket(AF_RXRPC, SOCK_DGRAM, PF_INET);

     Where the third parameter indicates the protocol family of the transport
     socket used - usually IPv4 but it can also be IPv6 [TODO].

 (2) A local address can optionally be bound:

	struct sockaddr_rxrpc srx = {
		.srx_family	= AF_RXRPC,
		.srx_service	= 0,  /* we're a client */
		.transport_type	= SOCK_DGRAM,	/* type of transport socket */
		.transport.sin_family	= AF_INET,
		.transport.sin_port	= htons(7000), /* AFS callback */
		.transport.sin_address	= 0,  /* all local interfaces */
	};
	bind(client, &srx, sizeof(srx));

     This specifies the local UDP port to be used.  If not given, a random
     non-privileged port will be used.  A UDP port may be shared between
     several unrelated RxRPC sockets.  Security is handled on a basis of
     per-RxRPC virtual connection.

 (3) The security is set:

	const char *key = "AFS:cambridge.redhat.com";
	setsockopt(client, SOL_RXRPC, RXRPC_SECURITY_KEY, key, strlen(key));

     This issues a request_key() to get the key representing the security
     context.  The minimum security level can be set:

	unsigned int sec = RXRPC_SECURITY_ENCRYPTED;
	setsockopt(client, SOL_RXRPC, RXRPC_MIN_SECURITY_LEVEL,
		   &sec, sizeof(sec));

 (4) The server to be contacted can then be specified (alternatively this can
     be done through sendmsg):

	struct sockaddr_rxrpc srx = {
		.srx_family	= AF_RXRPC,
		.srx_service	= VL_SERVICE_ID,
		.transport_type	= SOCK_DGRAM,	/* type of transport socket */
		.transport.sin_family	= AF_INET,
		.transport.sin_port	= htons(7005), /* AFS volume manager */
		.transport.sin_address	= ...,
	};
	connect(client, &srx, sizeof(srx));

 (5) The request data should then be posted to the server socket using a series
     of sendmsg() calls, each with the following control message attached:

	RXRPC_USER_CALL_ID	- specifies the user ID for this call

     MSG_MORE should be set in msghdr::msg_flags on all but the last part of
     the request.  Multiple requests may be made simultaneously.

     If a call is intended to go to a destination other then the default
     specified through connect(), then msghdr::msg_name should be set on the
     first request message of that call.

 (6) The reply data will then be posted to the server socket for recvmsg() to
     pick up.  MSG_MORE will be flagged by recvmsg() if there's more reply data
     for a particular call to be read.  MSG_EOR will be set on the terminal
     read for a call.

     All data will be delivered with the following control message attached:

	RXRPC_USER_CALL_ID	- specifies the user ID for this call

     If an abort or error occurred, this will be returned in the control data
     buffer instead, and MSG_EOR will be flagged to indicate the end of that
     call.


====================
EXAMPLE SERVER USAGE
====================

A server would be set up to accept operations in the following manner:

 (1) An RxRPC socket is created by:

	server = socket(AF_RXRPC, SOCK_DGRAM, PF_INET);

     Where the third parameter indicates the address type of the transport
     socket used - usually IPv4.

 (2) Security is set up if desired by giving the socket a keyring with server
     secret keys in it:

	keyring = add_key("keyring", "AFSkeys", NULL, 0,
			  KEY_SPEC_PROCESS_KEYRING);

	const char secret_key[8] = {
		0xa7, 0x83, 0x8a, 0xcb, 0xc7, 0x83, 0xec, 0x94 };
	add_key("rxrpc_s", "52:2", secret_key, 8, keyring);

	setsockopt(server, SOL_RXRPC, RXRPC_SECURITY_KEYRING, "AFSkeys", 7);

     The keyring can be manipulated after it has been given to the socket. This
     permits the server to add more keys, replace keys, etc. whilst it is live.

 (2) A local address must then be bound:

	struct sockaddr_rxrpc srx = {
		.srx_family	= AF_RXRPC,
		.srx_service	= VL_SERVICE_ID, /* RxRPC service ID */
		.transport_type	= SOCK_DGRAM,	/* type of transport socket */
		.transport.sin_family	= AF_INET,
		.transport.sin_port	= htons(7000), /* AFS callback */
		.transport.sin_address	= 0,  /* all local interfaces */
	};
	bind(server, &srx, sizeof(srx));

 (3) The server is then set to listen out for incoming calls:

	listen(server, 100);

 (4) The kernel notifies the server of pending incoming connections by sending
     it a message for each.  This is received with recvmsg() on the server
     socket.  It has no data, and has a single dataless control message
     attached:

	RXRPC_NEW_CALL

     The address that can be passed back by recvmsg() at this point should be
     ignored since the call for which the message was posted may have gone by
     the time it is accepted - in which case the first call still on the queue
     will be accepted.

 (5) The server then accepts the new call by issuing a sendmsg() with two
     pieces of control data and no actual data:

	RXRPC_ACCEPT		- indicate connection acceptance
	RXRPC_USER_CALL_ID	- specify user ID for this call

 (6) The first request data packet will then be posted to the server socket for
     recvmsg() to pick up.  At that point, the RxRPC address for the call can
     be read from the address fields in the msghdr struct.

     Subsequent request data will be posted to the server socket for recvmsg()
     to collect as it arrives.  All but the last piece of the request data will
     be delivered with MSG_MORE flagged.

     All data will be delivered with the following control message attached:

	RXRPC_USER_CALL_ID	- specifies the user ID for this call

 (8) The reply data should then be posted to the server socket using a series
     of sendmsg() calls, each with the following control messages attached:

	RXRPC_USER_CALL_ID	- specifies the user ID for this call

     MSG_MORE should be set in msghdr::msg_flags on all but the last message
     for a particular call.

 (9) The final ACK from the client will be posted for retrieval by recvmsg()
     when it is received.  It will take the form of a dataless message with two
     control messages attached:

	RXRPC_USER_CALL_ID	- specifies the user ID for this call
	RXRPC_ACK		- indicates final ACK (no data)

     MSG_EOR will be flagged to indicate that this is the final message for
     this call.

(10) Up to the point the final packet of reply data is sent, the call can be
     aborted by calling sendmsg() with a dataless message with the following
     control messages attached:

	RXRPC_USER_CALL_ID	- specifies the user ID for this call
	RXRPC_ABORT		- indicates abort code (4 byte data)

     Any packets waiting in the socket's receive queue will be discarded if
     this is issued.

Note that all the communications for a particular service take place through
the one server socket, using control messages on sendmsg() and recvmsg() to
determine the call affected.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |  663 +++++++++++++++++++
 include/keys/rxrpc-type.h          |   22 +
 include/linux/net.h                |    2 
 include/linux/rxrpc.h              |   62 ++
 include/linux/socket.h             |    5 
 include/net/af_rxrpc.h             |   17 
 include/rxrpc/packet.h             |   85 ++
 net/Kconfig                        |    1 
 net/Makefile                       |    1 
 net/core/sock.c                    |    6 
 net/rxrpc/Kconfig                  |   37 +
 net/rxrpc/Makefile                 |   31 +
 net/rxrpc/af_rxrpc.c               |  754 ++++++++++++++++++++++
 net/rxrpc/ar-accept.c              |  399 +++++++++++
 net/rxrpc/ar-ack.c                 | 1250 ++++++++++++++++++++++++++++++++++++
 net/rxrpc/ar-call.c                |  787 +++++++++++++++++++++++
 net/rxrpc/ar-connection.c          |  895 ++++++++++++++++++++++++++
 net/rxrpc/ar-connevent.c           |  387 +++++++++++
 net/rxrpc/ar-error.c               |  253 +++++++
 net/rxrpc/ar-input.c               |  791 +++++++++++++++++++++++
 net/rxrpc/ar-internal.h            |  842 ++++++++++++++++++++++++
 net/rxrpc/ar-key.c                 |  334 ++++++++++
 net/rxrpc/ar-local.c               |  309 +++++++++
 net/rxrpc/ar-output.c              |  658 +++++++++++++++++++
 net/rxrpc/ar-peer.c                |  273 ++++++++
 net/rxrpc/ar-proc.c                |  247 +++++++
 net/rxrpc/ar-recvmsg.c             |  366 +++++++++++
 net/rxrpc/ar-security.c            |  258 +++++++
 net/rxrpc/ar-skbuff.c              |  118 +++
 net/rxrpc/ar-transport.c           |  276 ++++++++
 net/rxrpc/rxkad.c                  | 1153 +++++++++++++++++++++++++++++++++
 31 files changed, 11275 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
new file mode 100644
index 0000000..fb809b7
--- /dev/null
+++ b/Documentation/networking/rxrpc.txt
@@ -0,0 +1,663 @@
+			    ======================
+			    RxRPC NETWORK PROTOCOL
+			    ======================
+
+The RxRPC protocol driver provides a reliable two-phase transport on top of UDP
+that can be used to perform RxRPC remote operations.  This is done over sockets
+of AF_RXRPC family, using sendmsg() and recvmsg() with control data to send and
+receive data, aborts and errors.
+
+Contents of this document:
+
+ (*) Overview.
+
+ (*) RxRPC protocol summary.
+
+ (*) AF_RXRPC driver model.
+
+ (*) Control messages.
+
+ (*) Socket options.
+
+ (*) Security.
+
+ (*) Example client usage.
+
+ (*) Example server usage.
+
+
+========
+OVERVIEW
+========
+
+RxRPC is a two-layer protocol.  There is a session layer which provides
+reliable virtual connections using UDP over IPv4 (or IPv6) as the transport
+layer, but implements a real network protocol; and there's the presentation
+layer which renders structured data to binary blobs and back again using XDR
+(as does SunRPC):
+
+		+-------------+
+		| Application |
+		+-------------+
+		|     XDR     |		Presentation
+		+-------------+
+		|    RxRPC    |		Session
+		+-------------+
+		|     UDP     |		Transport
+		+-------------+
+
+
+AF_RXRPC provides:
+
+ (1) Part of an RxRPC facility for both kernel and userspace applications by
+     making the session part of it a Linux network protocol (AF_RXRPC).
+
+ (2) A two-phase protocol.  The client transmits a blob (the request) and then
+     receives a blob (the reply), and the server receives the request and then
+     transmits the reply.
+
+ (3) Retention of the reusable bits of the transport system set up for one call
+     to speed up subsequent calls.
+
+ (4) A secure protocol, using the Linux kernel's key retention facility to
+     manage security on the client end.  The server end must of necessity be
+     more active in security negotiations.
+
+AF_RXRPC does not provide XDR marshalling/presentation facilities.  That is
+left to the application.  AF_RXRPC only deals in blobs.  Even the operation ID
+is just the first four bytes of the request blob, and as such is beyond the
+kernel's interest.
+
+
+Sockets of AF_RXRPC family are:
+
+ (1) created as type SOCK_DGRAM;
+
+ (2) provided with a protocol of the type of underlying transport they're going
+     to use - currently only PF_INET is supported.
+
+
+The Andrew File System (AFS) is an example of an application that uses this and
+that has both kernel (filesystem) and userspace (utility) components.
+
+
+======================
+RXRPC PROTOCOL SUMMARY
+======================
+
+An overview of the RxRPC protocol:
+
+ (*) RxRPC sits on top of another networking protocol (UDP is the only option
+     currently), and uses this to provide network transport.  UDP ports, for
+     example, provide transport endpoints.
+
+ (*) RxRPC supports multiple virtual "connections" from any given transport
+     endpoint, thus allowing the endpoints to be shared, even to the same
+     remote endpoint.
+
+ (*) Each connection goes to a particular "service".  A connection may not go
+     to multiple services.  A service may be considered the RxRPC equivalent of
+     a port number.  AF_RXRPC permits multiple services to share an endpoint.
+
+ (*) Client-originating packets are marked, thus a transport endpoint can be
+     shared between client and server connections (connections have a
+     direction).
+
+ (*) Up to a billion connections may be supported concurrently between one
+     local transport endpoint and one service on one remote endpoint.  An RxRPC
+     connection is described by seven numbers:
+
+	Local address	}
+	Local port	} Transport (UDP) address
+	Remote address	}
+	Remote port	}
+	Direction
+	Connection ID
+	Service ID
+
+ (*) Each RxRPC operation is a "call".  A connection may make up to four
+     billion calls, but only up to four calls may be in progress on a
+     connection at any one time.
+
+ (*) Calls are two-phase and asymmetric: the client sends its request data,
+     which the service receives; then the service transmits the reply data
+     which the client receives.
+
+ (*) The data blobs are of indefinite size, the end of a phase is marked with a
+     flag in the packet.  The number of packets of data making up one blob may
+     not exceed 4 billion, however, as this would cause the sequence number to
+     wrap.
+
+ (*) The first four bytes of the request data are the service operation ID.
+
+ (*) Security is negotiated on a per-connection basis.  The connection is
+     initiated by the first data packet on it arriving.  If security is
+     requested, the server then issues a "challenge" and then the client
+     replies with a "response".  If the response is successful, the security is
+     set for the lifetime of that connection, and all subsequent calls made
+     upon it use that same security.  In the event that the server lets a
+     connection lapse before the client, the security will be renegotiated if
+     the client uses the connection again.
+
+ (*) Calls use ACK packets to handle reliability.  Data packets are also
+     explicitly sequenced per call.
+
+ (*) There are two types of positive acknowledgement: hard-ACKs and soft-ACKs.
+     A hard-ACK indicates to the far side that all the data received to a point
+     has been received and processed; a soft-ACK indicates that the data has
+     been received but may yet be discarded and re-requested.  The sender may
+     not discard any transmittable packets until they've been hard-ACK'd.
+
+ (*) Reception of a reply data packet implicitly hard-ACK's all the data
+     packets that make up the request.
+
+ (*) An call is complete when the request has been sent, the reply has been
+     received and the final hard-ACK on the last packet of the reply has
+     reached the server.
+
+ (*) An call may be aborted by either end at any time up to its completion.
+
+
+=====================
+AF_RXRPC DRIVER MODEL
+=====================
+
+About the AF_RXRPC driver:
+
+ (*) The AF_RXRPC protocol transparently uses internal sockets of the transport
+     protocol to represent transport endpoints.
+
+ (*) AF_RXRPC sockets map onto RxRPC connection bundles.  Actual RxRPC
+     connections are handled transparently.  One client socket may be used to
+     make multiple simultaneous calls to the same service.  One server socket
+     may handle calls from many clients.
+
+ (*) Additional parallel client connections will be initiated to support extra
+     concurrent calls, up to a tunable limit.
+
+ (*) Each connection is retained for a certain amount of time [tunable] after
+     the last call currently using it has completed in case a new call is made
+     that could reuse it.
+
+ (*) Each internal UDP socket is retained [tunable] for a certain amount of
+     time [tunable] after the last connection using it discarded, in case a new
+     connection is made that could use it.
+
+ (*) A client-side connection is only shared between calls if they have have
+     the same key struct describing their security (and assuming the calls
+     would otherwise share the connection).  Non-secured calls would also be
+     able to share connections with each other.
+
+ (*) A server-side connection is shared if the client says it is.
+
+ (*) ACK'ing is handled by the protocol driver automatically, including ping
+     replying.
+
+ (*) SO_KEEPALIVE automatically pings the other side to keep the connection
+     alive [TODO].
+
+ (*) If an ICMP error is received, all calls affected by that error will be
+     aborted with an appropriate network error passed through recvmsg().
+
+
+Interaction with the user of the RxRPC socket:
+
+ (*) A socket is made into a server socket by binding an address with a
+     non-zero service ID.
+
+ (*) In the client, sending a request is achieved with one or more sendmsgs,
+     followed by the reply being received with one or more recvmsgs.
+
+ (*) The first sendmsg for a request to be sent from a client contains a tag to
+     be used in all other sendmsgs or recvmsgs associated with that call.  The
+     tag is carried in the control data.
+
+ (*) connect() is used to supply a default destination address for a client
+     socket.  This may be overridden by supplying an alternate address to the
+     first sendmsg() of a call (struct msghdr::msg_name).
+
+ (*) If connect() is called on an unbound client, a random local port will
+     bound before the operation takes place.
+
+ (*) A server socket may also be used to make client calls.  To do this, the
+     first sendmsg() of the call must specify the target address.  The server's
+     transport endpoint is used to send the packets.
+
+ (*) Once the application has received the last message associated with a call,
+     the tag is guaranteed not to be seen again, and so it can be used to pin
+     client resources.  A new call can then be initiated with the same tag
+     without fear of interference.
+
+ (*) In the server, a request is received with one or more recvmsgs, then the
+     the reply is transmitted with one or more sendmsgs, and then the final ACK
+     is received with a last recvmsg.
+
+ (*) When sending data for a call, sendmsg is given MSG_MORE if there's more
+     data to come on that call.
+
+ (*) When receiving data for a call, recvmsg flags MSG_MORE if there's more
+     data to come for that call.
+
+ (*) When receiving data or messages for a call, MSG_EOR is flagged by recvmsg
+     to indicate the terminal message for that call.
+
+ (*) A call may be aborted by adding an abort control message to the control
+     data.  Issuing an abort terminates the kernel's use of that call's tag.
+     Any messages waiting in the receive queue for that call will be discarded.
+
+ (*) Aborts, busy notifications and challenge packets are delivered by recvmsg,
+     and control data messages will be set to indicate the context.  Receiving
+     an abort or a busy message terminates the kernel's use of that call's tag.
+
+ (*) The control data part of the msghdr struct is used for a number of things:
+
+     (*) The tag of the intended or affected call.
+
+     (*) Sending or receiving errors, aborts and busy notifications.
+
+     (*) Notifications of incoming calls.
+
+     (*) Sending debug requests and receiving debug replies [TODO].
+
+ (*) When the kernel has received and set up an incoming call, it sends a
+     message to server application to let it know there's a new call awaiting
+     its acceptance [recvmsg reports a special control message].  The server
+     application then uses sendmsg to assign a tag to the new call.  Once that
+     is done, the first part of the request data will be delivered by recvmsg.
+
+ (*) The server application has to provide the server socket with a keyring of
+     secret keys corresponding to the security types it permits.  When a secure
+     connection is being set up, the kernel looks up the appropriate secret key
+     in the keyring and then sends a challenge packet to the client and
+     receives a response packet.  The kernel then checks the authorisation of
+     the packet and either aborts the connection or sets up the security.
+
+ (*) The name of the key a client will use to secure its communications is
+     nominated by a socket option.
+
+
+Notes on recvmsg:
+
+ (*) If there's a sequence of data messages belonging to a particular call on
+     the receive queue, then recvmsg will keep working through them until:
+
+     (a) it meets the end of that call's received data,
+
+     (b) it meets a non-data message,
+
+     (c) it meets a message belonging to a different call, or
+
+     (d) it fills the user buffer.
+
+     If recvmsg is called in blocking mode, it will keep sleeping, awaiting the
+     reception of further data, until one of the above four conditions is met.
+
+ (2) MSG_PEEK operates similarly, but will return immediately if it has put any
+     data in the buffer rather than sleeping until it can fill the buffer.
+
+ (3) If a data message is only partially consumed in filling a user buffer,
+     then the remainder of that message will be left on the front of the queue
+     for the next taker.  MSG_TRUNC will never be flagged.
+
+ (4) If there is more data to be had on a call (it hasn't copied the last byte
+     of the last data message in that phase yet), then MSG_MORE will be
+     flagged.
+
+
+================
+CONTROL MESSAGES
+================
+
+AF_RXRPC makes use of control messages in sendmsg() and recvmsg() to multiplex
+calls, to invoke certain actions and to report certain conditions.  These are:
+
+	MESSAGE ID		SRT DATA	MEANING
+	=======================	=== ===========	===============================
+	RXRPC_USER_CALL_ID	sr- User ID	App's call specifier
+	RXRPC_ABORT		srt Abort code	Abort code to issue/received
+	RXRPC_ACK		-rt n/a		Final ACK received
+	RXRPC_NET_ERROR		-rt error num	Network error on call
+	RXRPC_BUSY		-rt n/a		Call rejected (server busy)
+	RXRPC_LOCAL_ERROR	-rt error num	Local error encountered
+	RXRPC_NEW_CALL		-r- n/a		New call received
+	RXRPC_ACCEPT		s-- n/a		Accept new call
+
+	(SRT = usable in Sendmsg / delivered by Recvmsg / Terminal message)
+
+ (*) RXRPC_USER_CALL_ID
+
+     This is used to indicate the application's call ID.  It's an unsigned long
+     that the app specifies in the client by attaching it to the first data
+     message or in the server by passing it in association with an RXRPC_ACCEPT
+     message.  recvmsg() passes it in conjunction with all messages except
+     those of the RXRPC_NEW_CALL message.
+
+ (*) RXRPC_ABORT
+
+     This is can be used by an application to abort a call by passing it to
+     sendmsg, or it can be delivered by recvmsg to indicate a remote abort was
+     received.  Either way, it must be associated with an RXRPC_USER_CALL_ID to
+     specify the call affected.  If an abort is being sent, then error EBADSLT
+     will be returned if there is no call with that user ID.
+
+ (*) RXRPC_ACK
+
+     This is delivered to a server application to indicate that the final ACK
+     of a call was received from the client.  It will be associated with an
+     RXRPC_USER_CALL_ID to indicate the call that's now complete.
+
+ (*) RXRPC_NET_ERROR
+
+     This is delivered to an application to indicate that an ICMP error message
+     was encountered in the process of trying to talk to the peer.  An
+     errno-class integer value will be included in the control message data
+     indicating the problem, and an RXRPC_USER_CALL_ID will indicate the call
+     affected.
+
+ (*) RXRPC_BUSY
+
+     This is delivered to a client application to indicate that a call was
+     rejected by the server due to the server being busy.  It will be
+     associated with an RXRPC_USER_CALL_ID to indicate the rejected call.
+
+ (*) RXRPC_LOCAL_ERROR
+
+     This is delivered to an application to indicate that a local error was
+     encountered and that a call has been aborted because of it.  An
+     errno-class integer value will be included in the control message data
+     indicating the problem, and an RXRPC_USER_CALL_ID will indicate the call
+     affected.
+
+ (*) RXRPC_NEW_CALL
+
+     This is delivered to indicate to a server application that a new call has
+     arrived and is awaiting acceptance.  No user ID is associated with this,
+     as a user ID must subsequently be assigned by doing an RXRPC_ACCEPT.
+
+ (*) RXRPC_ACCEPT
+
+     This is used by a server application to attempt to accept a call and
+     assign it a user ID.  It should be associated with an RXRPC_USER_CALL_ID
+     to indicate the user ID to be assigned.  If there is no call to be
+     accepted (it may have timed out, been aborted, etc.), then sendmsg will
+     return error ENODATA.  If the user ID is already in use by another call,
+     then error EBADSLT will be returned.
+
+
+==============
+SOCKET OPTIONS
+==============
+
+AF_RXRPC sockets support a few socket options at the SOL_RXRPC level:
+
+ (*) RXRPC_SECURITY_KEY
+
+     This is used to specify the description of the key to be used.  The key is
+     extracted from the calling process's keyrings with request_key() and
+     should be of "rxrpc" type.
+
+     The optval pointer points to the description string, and optlen indicates
+     how long the string is, without the NUL terminator.
+
+ (*) RXRPC_SECURITY_KEYRING
+
+     Similar to above but specifies a keyring of server secret keys to use (key
+     type "keyring").  See the "Security" section.
+
+ (*) RXRPC_EXCLUSIVE_CONNECTION
+
+     This is used to request that new connections should be used for each call
+     made subsequently on this socket.  optval should be NULL and optlen 0.
+
+ (*) RXRPC_MIN_SECURITY_LEVEL
+
+     This is used to specify the minimum security level required for calls on
+     this socket.  optval must point to an int containing one of the following
+     values:
+
+     (a) RXRPC_SECURITY_PLAIN
+
+	 Encrypted checksum only.
+
+     (b) RXRPC_SECURITY_AUTH
+
+	 Encrypted checksum plus packet padded and first eight bytes of packet
+	 encrypted - which includes the actual packet length.
+
+     (c) RXRPC_SECURITY_ENCRYPTED
+
+	 Encrypted checksum plus entire packet padded and encrypted, including
+	 actual packet length.
+
+
+========
+SECURITY
+========
+
+Currently, only the kerberos 4 equivalent protocol has been implemented
+(security index 2 - rxkad).  This requires the rxkad module to be loaded and,
+on the client, tickets of the appropriate type to be obtained from the AFS
+kaserver or the kerberos server and installed as "rxrpc" type keys.  This is
+normally done using the klog program.  An example simple klog program can be
+found at:
+
+	http://people.redhat.com/~dhowells/rxrpc/klog.c
+
+The payload provided to add_key() on the client should be of the following
+form:
+
+	struct rxrpc_key_sec2_v1 {
+		uint16_t	security_index;	/* 2 */
+		uint16_t	ticket_length;	/* length of ticket[] */
+		uint32_t	expiry;		/* time at which expires */
+		uint8_t		kvno;		/* key version number */
+		uint8_t		__pad[3];
+		uint8_t		session_key[8];	/* DES session key */
+		uint8_t		ticket[0];	/* the encrypted ticket */
+	};
+
+Where the ticket blob is just appended to the above structure.
+
+
+For the server, keys of type "rxrpc_s" must be made available to the server.
+They have a description of "<serviceID>:<securityIndex>" (eg: "52:2" for an
+rxkad key for the AFS VL service).  When such a key is created, it should be
+given the server's secret key as the instantiation data (see the example
+below).
+
+	add_key("rxrpc_s", "52:2", secret_key, 8, keyring);
+
+A keyring is passed to the server socket by naming it in a sockopt.  The server
+socket then looks the server secret keys up in this keyring when secure
+incoming connections are made.  This can be seen in an example program that can
+be found at:
+
+	http://people.redhat.com/~dhowells/rxrpc/listen.c
+
+
+====================
+EXAMPLE CLIENT USAGE
+====================
+
+A client would issue an operation by:
+
+ (1) An RxRPC socket is set up by:
+
+	client = socket(AF_RXRPC, SOCK_DGRAM, PF_INET);
+
+     Where the third parameter indicates the protocol family of the transport
+     socket used - usually IPv4 but it can also be IPv6 [TODO].
+
+ (2) A local address can optionally be bound:
+
+	struct sockaddr_rxrpc srx = {
+		.srx_family	= AF_RXRPC,
+		.srx_service	= 0,  /* we're a client */
+		.transport_type	= SOCK_DGRAM,	/* type of transport socket */
+		.transport.sin_family	= AF_INET,
+		.transport.sin_port	= htons(7000), /* AFS callback */
+		.transport.sin_address	= 0,  /* all local interfaces */
+	};
+	bind(client, &srx, sizeof(srx));
+
+     This specifies the local UDP port to be used.  If not given, a random
+     non-privileged port will be used.  A UDP port may be shared between
+     several unrelated RxRPC sockets.  Security is handled on a basis of
+     per-RxRPC virtual connection.
+
+ (3) The security is set:
+
+	const char *key = "AFS:cambridge.redhat.com";
+	setsockopt(client, SOL_RXRPC, RXRPC_SECURITY_KEY, key, strlen(key));
+
+     This issues a request_key() to get the key representing the security
+     context.  The minimum security level can be set:
+
+	unsigned int sec = RXRPC_SECURITY_ENCRYPTED;
+	setsockopt(client, SOL_RXRPC, RXRPC_MIN_SECURITY_LEVEL,
+		   &sec, sizeof(sec));
+
+ (4) The server to be contacted can then be specified (alternatively this can
+     be done through sendmsg):
+
+	struct sockaddr_rxrpc srx = {
+		.srx_family	= AF_RXRPC,
+		.srx_service	= VL_SERVICE_ID,
+		.transport_type	= SOCK_DGRAM,	/* type of transport socket */
+		.transport.sin_family	= AF_INET,
+		.transport.sin_port	= htons(7005), /* AFS volume manager */
+		.transport.sin_address	= ...,
+	};
+	connect(client, &srx, sizeof(srx));
+
+ (5) The request data should then be posted to the server socket using a series
+     of sendmsg() calls, each with the following control message attached:
+
+	RXRPC_USER_CALL_ID	- specifies the user ID for this call
+
+     MSG_MORE should be set in msghdr::msg_flags on all but the last part of
+     the request.  Multiple requests may be made simultaneously.
+
+     If a call is intended to go to a destination other then the default
+     specified through connect(), then msghdr::msg_name should be set on the
+     first request message of that call.
+
+ (6) The reply data will then be posted to the server socket for recvmsg() to
+     pick up.  MSG_MORE will be flagged by recvmsg() if there's more reply data
+     for a particular call to be read.  MSG_EOR will be set on the terminal
+     read for a call.
+
+     All data will be delivered with the following control message attached:
+
+	RXRPC_USER_CALL_ID	- specifies the user ID for this call
+
+     If an abort or error occurred, this will be returned in the control data
+     buffer instead, and MSG_EOR will be flagged to indicate the end of that
+     call.
+
+
+====================
+EXAMPLE SERVER USAGE
+====================
+
+A server would be set up to accept operations in the following manner:
+
+ (1) An RxRPC socket is created by:
+
+	server = socket(AF_RXRPC, SOCK_DGRAM, PF_INET);
+
+     Where the third parameter indicates the address type of the transport
+     socket used - usually IPv4.
+
+ (2) Security is set up if desired by giving the socket a keyring with server
+     secret keys in it:
+
+	keyring = add_key("keyring", "AFSkeys", NULL, 0,
+			  KEY_SPEC_PROCESS_KEYRING);
+
+	const char secret_key[8] = {
+		0xa7, 0x83, 0x8a, 0xcb, 0xc7, 0x83, 0xec, 0x94 };
+	add_key("rxrpc_s", "52:2", secret_key, 8, keyring);
+
+	setsockopt(server, SOL_RXRPC, RXRPC_SECURITY_KEYRING, "AFSkeys", 7);
+
+     The keyring can be manipulated after it has been given to the socket. This
+     permits the server to add more keys, replace keys, etc. whilst it is live.
+
+ (2) A local address must then be bound:
+
+	struct sockaddr_rxrpc srx = {
+		.srx_family	= AF_RXRPC,
+		.srx_service	= VL_SERVICE_ID, /* RxRPC service ID */
+		.transport_type	= SOCK_DGRAM,	/* type of transport socket */
+		.transport.sin_family	= AF_INET,
+		.transport.sin_port	= htons(7000), /* AFS callback */
+		.transport.sin_address	= 0,  /* all local interfaces */
+	};
+	bind(server, &srx, sizeof(srx));
+
+ (3) The server is then set to listen out for incoming calls:
+
+	listen(server, 100);
+
+ (4) The kernel notifies the server of pending incoming connections by sending
+     it a message for each.  This is received with recvmsg() on the server
+     socket.  It has no data, and has a single dataless control message
+     attached:
+
+	RXRPC_NEW_CALL
+
+     The address that can be passed back by recvmsg() at this point should be
+     ignored since the call for which the message was posted may have gone by
+     the time it is accepted - in which case the first call still on the queue
+     will be accepted.
+
+ (5) The server then accepts the new call by issuing a sendmsg() with two
+     pieces of control data and no actual data:
+
+	RXRPC_ACCEPT		- indicate connection acceptance
+	RXRPC_USER_CALL_ID	- specify user ID for this call
+
+ (6) The first request data packet will then be posted to the server socket for
+     recvmsg() to pick up.  At that point, the RxRPC address for the call can
+     be read from the address fields in the msghdr struct.
+
+     Subsequent request data will be posted to the server socket for recvmsg()
+     to collect as it arrives.  All but the last piece of the request data will
+     be delivered with MSG_MORE flagged.
+
+     All data will be delivered with the following control message attached:
+
+	RXRPC_USER_CALL_ID	- specifies the user ID for this call
+
+ (8) The reply data should then be posted to the server socket using a series
+     of sendmsg() calls, each with the following control messages attached:
+
+	RXRPC_USER_CALL_ID	- specifies the user ID for this call
+
+     MSG_MORE should be set in msghdr::msg_flags on all but the last message
+     for a particular call.
+
+ (9) The final ACK from the client will be posted for retrieval by recvmsg()
+     when it is received.  It will take the form of a dataless message with two
+     control messages attached:
+
+	RXRPC_USER_CALL_ID	- specifies the user ID for this call
+	RXRPC_ACK		- indicates final ACK (no data)
+
+     MSG_EOR will be flagged to indicate that this is the final message for
+     this call.
+
+(10) Up to the point the final packet of reply data is sent, the call can be
+     aborted by calling sendmsg() with a dataless message with the following
+     control messages attached:
+
+	RXRPC_USER_CALL_ID	- specifies the user ID for this call
+	RXRPC_ABORT		- indicates abort code (4 byte data)
+
+     Any packets waiting in the socket's receive queue will be discarded if
+     this is issued.
+
+Note that all the communications for a particular service take place through
+the one server socket, using control messages on sendmsg() and recvmsg() to
+determine the call affected.
diff --git a/include/keys/rxrpc-type.h b/include/keys/rxrpc-type.h
new file mode 100644
index 0000000..e2ee73a
--- /dev/null
+++ b/include/keys/rxrpc-type.h
@@ -0,0 +1,22 @@
+/* RxRPC key type
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _KEYS_RXRPC_TYPE_H
+#define _KEYS_RXRPC_TYPE_H
+
+#include <linux/key.h>
+
+/*
+ * key type for AF_RXRPC keys
+ */
+extern struct key_type key_type_rxrpc;
+
+#endif /* _KEYS_USER_TYPE_H */
diff --git a/include/linux/net.h b/include/linux/net.h
index 4db21e6..efc4517 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -24,7 +24,7 @@
 struct poll_table_struct;
 struct inode;
 
-#define NPROTO		33		/* should be enough for now..	*/
+#define NPROTO		34		/* should be enough for now..	*/
 
 #define SYS_SOCKET	1		/* sys_socket(2)		*/
 #define SYS_BIND	2		/* sys_bind(2)			*/
diff --git a/include/linux/rxrpc.h b/include/linux/rxrpc.h
new file mode 100644
index 0000000..f7b826b
--- /dev/null
+++ b/include/linux/rxrpc.h
@@ -0,0 +1,62 @@
+/* AF_RXRPC parameters
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _LINUX_RXRPC_H
+#define _LINUX_RXRPC_H
+
+#include <linux/in.h>
+#include <linux/in6.h>
+
+/*
+ * RxRPC socket address
+ */
+struct sockaddr_rxrpc {
+	sa_family_t	srx_family;	/* address family */
+	u16		srx_service;	/* service desired */
+	u16		transport_type;	/* type of transport socket (SOCK_DGRAM) */
+	u16		transport_len;	/* length of transport address */
+	union {
+		sa_family_t family;		/* transport address family */
+		struct sockaddr_in sin;		/* IPv4 transport address */
+		struct sockaddr_in6 sin6;	/* IPv6 transport address */
+	} transport;
+};
+
+/*
+ * RxRPC socket options
+ */
+#define RXRPC_SECURITY_KEY		1	/* [clnt] set client security key */
+#define RXRPC_SECURITY_KEYRING		2	/* [srvr] set ring of server security keys */
+#define RXRPC_EXCLUSIVE_CONNECTION	3	/* [clnt] use exclusive RxRPC connection */
+#define RXRPC_MIN_SECURITY_LEVEL	4	/* minimum security level */
+
+/*
+ * RxRPC control messages
+ * - terminal messages mean that a user call ID tag can be recycled
+ */
+#define RXRPC_USER_CALL_ID	1	/* user call ID specifier */
+#define RXRPC_ABORT		2	/* abort request / notification [terminal] */
+#define RXRPC_ACK		3	/* [Server] RPC op final ACK received [terminal] */
+#define RXRPC_NET_ERROR		5	/* network error received [terminal] */
+#define RXRPC_BUSY		6	/* server busy received [terminal] */
+#define RXRPC_LOCAL_ERROR	7	/* local error generated [terminal] */
+#define RXRPC_NEW_CALL		8	/* [Server] new incoming call notification */
+#define RXRPC_ACCEPT		9	/* [Server] accept request */
+
+/*
+ * RxRPC security levels
+ */
+#define RXRPC_SECURITY_PLAIN	0	/* plain secure-checksummed packets only */
+#define RXRPC_SECURITY_AUTH	1	/* authenticated packets */
+#define RXRPC_SECURITY_ENCRYPT	2	/* encrypted packets */
+
+
+#endif /* _LINUX_RXRPC_H */
diff --git a/include/linux/socket.h b/include/linux/socket.h
index fcd35a2..6e7c948 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -188,7 +188,8 @@ struct ucred {
 #define AF_TIPC		30	/* TIPC sockets			*/
 #define AF_BLUETOOTH	31	/* Bluetooth sockets 		*/
 #define AF_IUCV		32	/* IUCV sockets			*/
-#define AF_MAX		33	/* For now.. */
+#define AF_RXRPC	33	/* RxRPC sockets 		*/
+#define AF_MAX		34	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -222,6 +223,7 @@ struct ucred {
 #define PF_TIPC		AF_TIPC
 #define PF_BLUETOOTH	AF_BLUETOOTH
 #define PF_IUCV		AF_IUCV
+#define PF_RXRPC	AF_RXRPC
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
@@ -284,6 +286,7 @@ struct ucred {
 #define SOL_DCCP	269
 #define SOL_NETLINK	270
 #define SOL_TIPC	271
+#define SOL_RXRPC	272
 
 /* IPX options */
 #define IPX_TYPE	1
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
new file mode 100644
index 0000000..b01ca25
--- /dev/null
+++ b/include/net/af_rxrpc.h
@@ -0,0 +1,17 @@
+/* RxRPC definitions
+ *
+ * Copyright (C) 2006 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _NET_RXRPC_H
+#define _NET_RXRPC_H
+
+#include <linux/rxrpc.h>
+
+#endif /* _NET_RXRPC_H */
diff --git a/include/rxrpc/packet.h b/include/rxrpc/packet.h
index 1447f0a..452a9bb 100644
--- a/include/rxrpc/packet.h
+++ b/include/rxrpc/packet.h
@@ -33,7 +33,8 @@ struct rxrpc_header
 #define RXRPC_MAXCALLS		4			/* max active calls per conn */
 #define RXRPC_CHANNELMASK	(RXRPC_MAXCALLS-1)	/* mask for channel ID */
 #define RXRPC_CIDMASK		(~RXRPC_CHANNELMASK)	/* mask for connection ID */
-#define RXRPC_CIDSHIFT		2			/* shift for connection ID */
+#define RXRPC_CIDSHIFT		ilog2(RXRPC_MAXCALLS)	/* shift for connection ID */
+#define RXRPC_CID_INC		(1 << RXRPC_CIDSHIFT)	/* connection ID increment */
 
 	__be32		callNumber;	/* call ID (0 for connection-level packets) */
 #define RXRPC_PROCESS_MAXCALLS	(1<<2)	/* maximum number of active calls per conn (power of 2) */
@@ -62,7 +63,10 @@ struct rxrpc_header
 
 	uint8_t		userStatus;	/* app-layer defined status */
 	uint8_t		securityIndex;	/* security protocol ID */
-	__be16		_rsvd;		/* reserved (used by kerberos security as cksum) */
+	union {
+		__be16	_rsvd;		/* reserved */
+		__be16	cksum;		/* kerberos security checksum */
+	};
 	__be16		serviceId;	/* service ID */
 
 } __attribute__((packed));
@@ -124,4 +128,81 @@ struct rxrpc_ackpacket
 
 } __attribute__((packed));
 
+/*
+ * ACK packets can have a further piece of information tagged on the end
+ */
+struct rxrpc_ackinfo {
+	__be32		rxMTU;		/* maximum Rx MTU size (bytes) [AFS 3.3] */
+	__be32		maxMTU;		/* maximum interface MTU size (bytes) [AFS 3.3] */
+	__be32		rwind;		/* Rx window size (packets) [AFS 3.4] */
+	__be32		jumbo_max;	/* max packets to stick into a jumbo packet [AFS 3.5] */
+};
+
+/*****************************************************************************/
+/*
+ * Kerberos security type-2 challenge packet
+ */
+struct rxkad_challenge {
+	__be32		version;	/* version of this challenge type */
+	__be32		nonce;		/* encrypted random number */
+	__be32		min_level;	/* minimum security level */
+	__be32		__padding;	/* padding to 8-byte boundary */
+} __attribute__((packed));
+
+/*****************************************************************************/
+/*
+ * Kerberos security type-2 response packet
+ */
+struct rxkad_response {
+	__be32		version;	/* version of this reponse type */
+	__be32		__pad;
+
+	/* encrypted bit of the response */
+	struct {
+		__be32		epoch;		/* current epoch */
+		__be32		cid;		/* parent connection ID */
+		__be32		checksum;	/* checksum */
+		__be32		securityIndex;	/* security type */
+		__be32		call_id[4];	/* encrypted call IDs */
+		__be32		inc_nonce;	/* challenge nonce + 1 */
+		__be32		level;		/* desired level */
+	} encrypted;
+
+	__be32		kvno;		/* Kerberos key version number */
+	__be32		ticket_len;	/* Kerberos ticket length  */
+} __attribute__((packed));
+
+/*****************************************************************************/
+/*
+ * RxRPC-level abort codes
+ */
+#define RX_CALL_DEAD		-1	/* call/conn has been inactive and is shut down */
+#define RX_INVALID_OPERATION	-2	/* invalid operation requested / attempted */
+#define RX_CALL_TIMEOUT		-3	/* call timeout exceeded */
+#define RX_EOF			-4	/* unexpected end of data on read op */
+#define RX_PROTOCOL_ERROR	-5	/* low-level protocol error */
+#define RX_USER_ABORT		-6	/* generic user abort */
+#define RX_ADDRINUSE		-7	/* UDP port in use */
+#define RX_DEBUGI_BADTYPE	-8	/* bad debugging packet type */
+
+/*
+ * Rx kerberos security abort codes
+ * - unfortunately we have no generalised security abort codes to say things
+ *   like "unsupported security", so we have to use these instead and hope the
+ *   other side understands
+ */
+#define RXKADINCONSISTENCY	19270400	/* security module structure inconsistent */
+#define RXKADPACKETSHORT	19270401	/* packet too short for security challenge */
+#define RXKADLEVELFAIL		19270402	/* security level negotiation failed */
+#define RXKADTICKETLEN		19270403	/* ticket length too short or too long */
+#define RXKADOUTOFSEQUENCE	19270404	/* packet had bad sequence number */
+#define RXKADNOAUTH		19270405	/* caller not authorised */
+#define RXKADBADKEY		19270406	/* illegal key: bad parity or weak */
+#define RXKADBADTICKET		19270407	/* security object was passed a bad ticket */
+#define RXKADUNKNOWNKEY		19270408	/* ticket contained unknown key version number */
+#define RXKADEXPIRED		19270409	/* authentication expired */
+#define RXKADSEALEDINCON	19270410	/* sealed data inconsistent */
+#define RXKADDATALEN		19270411	/* user data too long */
+#define RXKADILLEGALLEVEL	19270412	/* caller not authorised to use encrypted conns */
+
 #endif /* _LINUX_RXRPC_PACKET_H */
diff --git a/net/Kconfig b/net/Kconfig
index ae1817d..2fc8e77 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -212,6 +212,7 @@ endmenu
 source "net/ax25/Kconfig"
 source "net/irda/Kconfig"
 source "net/bluetooth/Kconfig"
+source "net/rxrpc/Kconfig"
 
 config FIB_RULES
 	bool
diff --git a/net/Makefile b/net/Makefile
index 29bbe19..6b74d41 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -38,6 +38,7 @@ obj-$(CONFIG_IRDA)		+= irda/
 obj-$(CONFIG_BT)		+= bluetooth/
 obj-$(CONFIG_SUNRPC)		+= sunrpc/
 obj-$(CONFIG_RXRPC)		+= rxrpc/
+obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
 obj-$(CONFIG_ATM)		+= atm/
 obj-$(CONFIG_DECNET)		+= decnet/
 obj-$(CONFIG_ECONET)		+= econet/
diff --git a/net/core/sock.c b/net/core/sock.c
index 043bdc0..22183c2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -154,7 +154,8 @@ static const char *af_family_key_strings[AF_MAX+1] = {
   "sk_lock-21"       , "sk_lock-AF_SNA"      , "sk_lock-AF_IRDA"     ,
   "sk_lock-AF_PPPOX" , "sk_lock-AF_WANPIPE"  , "sk_lock-AF_LLC"      ,
   "sk_lock-27"       , "sk_lock-28"          , "sk_lock-29"          ,
-  "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-AF_MAX"
+  "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
+  "sk_lock-AF_RXRPC" , "sk_lock-AF_MAX"
 };
 static const char *af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@ -167,7 +168,8 @@ static const char *af_family_slock_key_strings[AF_MAX+1] = {
   "slock-21"       , "slock-AF_SNA"      , "slock-AF_IRDA"     ,
   "slock-AF_PPPOX" , "slock-AF_WANPIPE"  , "slock-AF_LLC"      ,
   "slock-27"       , "slock-28"          , "slock-29"          ,
-  "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_MAX"
+  "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
+  "slock-AF_RXRPC" , "slock-AF_MAX"
 };
 #endif
 
diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
new file mode 100644
index 0000000..d72380e
--- /dev/null
+++ b/net/rxrpc/Kconfig
@@ -0,0 +1,37 @@
+#
+# RxRPC session sockets
+#
+
+config AF_RXRPC
+	tristate "RxRPC session sockets"
+	depends on EXPERIMENTAL
+	help
+	  Say Y or M here to include support for RxRPC session sockets (just
+	  the transport part, not the presentation part: (un)marshalling is
+	  left to the application).
+
+	  These are used for AFS kernel filesystem and userspace utilities.
+
+	  This module at the moment only supports client operations and is
+	  currently incomplete.
+
+	  See Documentation/networking/rxrpc.txt.
+
+
+config AF_RXRPC_DEBUG
+	bool "RxRPC dynamic debugging"
+	depends on AF_RXRPC
+	help
+	  Say Y here to make runtime controllable debugging messages appear.
+
+	  See Documentation/networking/rxrpc.txt.
+
+
+config RXKAD
+	tristate "RxRPC Kerberos security"
+	depends on AF_RXRPC && KEYS
+	help
+	  Provide kerberos 4 and AFS kaserver security handling for AF_RXRPC
+	  through the use of the key retention service.
+
+	  See Documentation/networking/rxrpc.txt.
diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index 6efcb6f..07bf82f 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -4,6 +4,35 @@
 
 #CFLAGS += -finstrument-functions
 
+af-rxrpc-objs := \
+	af_rxrpc.o \
+	ar-accept.o \
+	ar-ack.o \
+	ar-call.o \
+	ar-connection.o \
+	ar-connevent.o \
+	ar-error.o \
+	ar-input.o \
+	ar-key.o \
+	ar-local.o \
+	ar-output.o \
+	ar-peer.o \
+	ar-recvmsg.o \
+	ar-security.o \
+	ar-skbuff.o \
+	ar-transport.o
+
+ifeq ($(CONFIG_PROC_FS),y)
+af-rxrpc-objs += ar-proc.o
+endif
+
+obj-$(CONFIG_AF_RXRPC) += af-rxrpc.o
+
+obj-$(CONFIG_RXKAD) += rxkad.o
+
+#
+# obsolete RxRPC interface, still used by fs/afs/
+#
 rxrpc-objs := \
 	call.o \
 	connection.o \
@@ -22,4 +51,4 @@ ifeq ($(CONFIG_SYSCTL),y)
 rxrpc-objs += sysctl.o
 endif
 
-obj-$(CONFIG_RXRPC) := rxrpc.o
+obj-$(CONFIG_RXRPC) += rxrpc.o
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
new file mode 100644
index 0000000..bfa8822
--- /dev/null
+++ b/net/rxrpc/af_rxrpc.c
@@ -0,0 +1,754 @@
+/* AF_RXRPC implementation
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/poll.h>
+#include <linux/proc_fs.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+MODULE_DESCRIPTION("RxRPC network protocol");
+MODULE_AUTHOR("Red Hat, Inc.");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_RXRPC);
+
+unsigned rxrpc_debug; // = RXRPC_DEBUG_KPROTO;
+module_param_named(debug, rxrpc_debug, uint, S_IWUSR | S_IRUGO);
+MODULE_PARM_DESC(rxrpc_debug, "RxRPC debugging mask");
+
+static int sysctl_rxrpc_max_qlen __read_mostly = 10;
+
+static struct proto rxrpc_proto;
+static const struct proto_ops rxrpc_rpc_ops;
+
+/* local epoch for detecting local-end reset */
+__be32 rxrpc_epoch;
+
+/* current debugging ID */
+atomic_t rxrpc_debug_id;
+
+/* count of skbs currently in use */
+atomic_t rxrpc_n_skbs;
+
+static void rxrpc_sock_destructor(struct sock *);
+
+/*
+ * see if an RxRPC socket is currently writable
+ */
+static inline int rxrpc_writable(struct sock *sk)
+{
+	return atomic_read(&sk->sk_wmem_alloc) < (size_t) sk->sk_sndbuf;
+}
+
+/*
+ * wait for write bufferage to become available
+ */
+static void rxrpc_write_space(struct sock *sk)
+{
+	_enter("%p", sk);
+	read_lock(&sk->sk_callback_lock);
+	if (rxrpc_writable(sk)) {
+		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+			wake_up_interruptible(sk->sk_sleep);
+		sk_wake_async(sk, 2, POLL_OUT);
+	}
+	read_unlock(&sk->sk_callback_lock);
+}
+
+/*
+ * validate an RxRPC address
+ */
+static int rxrpc_validate_address(struct rxrpc_sock *rx,
+				  struct sockaddr_rxrpc *srx,
+				  int len)
+{
+	if (len < sizeof(struct sockaddr_rxrpc))
+		return -EINVAL;
+
+	if (srx->srx_family != AF_RXRPC)
+		return -EAFNOSUPPORT;
+
+	if (srx->transport_type != SOCK_DGRAM)
+		return -ESOCKTNOSUPPORT;
+
+	len -= offsetof(struct sockaddr_rxrpc, transport);
+	if (srx->transport_len < sizeof(sa_family_t) ||
+	    srx->transport_len > len)
+		return -EINVAL;
+
+	if (srx->transport.family != rx->proto)
+		return -EAFNOSUPPORT;
+
+	switch (srx->transport.family) {
+	case AF_INET:
+		_debug("INET: %x @ %u.%u.%u.%u",
+		       ntohs(srx->transport.sin.sin_port),
+		       NIPQUAD(srx->transport.sin.sin_addr));
+		if (srx->transport_len > 8)
+			memset((void *)&srx->transport + 8, 0,
+			       srx->transport_len - 8);
+		break;
+
+	case AF_INET6:
+	default:
+		return -EAFNOSUPPORT;
+	}
+
+	return 0;
+}
+
+/*
+ * bind a local address to an RxRPC socket
+ */
+static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
+{
+	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *) saddr;
+	struct sock *sk = sock->sk;
+	struct rxrpc_local *local;
+	struct rxrpc_sock *rx = rxrpc_sk(sk), *prx;
+	__be16 service_id;
+	int ret;
+
+	_enter("%p,%p,%d", rx, saddr, len);
+
+	ret = rxrpc_validate_address(rx, srx, len);
+	if (ret < 0)
+		goto error;
+
+	lock_sock(&rx->sk);
+
+	if (rx->sk.sk_state != RXRPC_UNCONNECTED) {
+		ret = -EINVAL;
+		goto error_unlock;
+	}
+
+	memcpy(&rx->srx, srx, sizeof(rx->srx));
+
+	/* find a local transport endpoint if we don't have one already */
+	local = rxrpc_lookup_local(&rx->srx);
+	if (IS_ERR(local)) {
+		ret = PTR_ERR(local);
+		goto error_unlock;
+	}
+
+	rx->local = local;
+	if (srx->srx_service) {
+		service_id = htons(srx->srx_service);
+		write_lock_bh(&local->services_lock);
+		list_for_each_entry(prx, &local->services, listen_link) {
+			if (prx->service_id == service_id)
+				goto service_in_use;
+		}
+
+		rx->service_id = service_id;
+		list_add_tail(&rx->listen_link, &local->services);
+		write_unlock_bh(&local->services_lock);
+
+		rx->sk.sk_state = RXRPC_SERVER_BOUND;
+	} else {
+		rx->sk.sk_state = RXRPC_CLIENT_BOUND;
+	}
+
+	release_sock(&rx->sk);
+	_leave(" = 0");
+	return 0;
+
+service_in_use:
+	ret = -EADDRINUSE;
+	write_unlock_bh(&local->services_lock);
+error_unlock:
+	release_sock(&rx->sk);
+error:
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * set the number of pending calls permitted on a listening socket
+ */
+static int rxrpc_listen(struct socket *sock, int backlog)
+{
+	struct sock *sk = sock->sk;
+	struct rxrpc_sock *rx = rxrpc_sk(sk);
+	int ret;
+
+	_enter("%p,%d", rx, backlog);
+
+	lock_sock(&rx->sk);
+
+	switch (rx->sk.sk_state) {
+	case RXRPC_UNCONNECTED:
+		ret = -EADDRNOTAVAIL;
+		break;
+	case RXRPC_CLIENT_BOUND:
+	case RXRPC_CLIENT_CONNECTED:
+	default:
+		ret = -EBUSY;
+		break;
+	case RXRPC_SERVER_BOUND:
+		ASSERT(rx->local != NULL);
+		sk->sk_max_ack_backlog = backlog;
+		rx->sk.sk_state = RXRPC_SERVER_LISTENING;
+		ret = 0;
+		break;
+	}
+
+	release_sock(&rx->sk);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * find a transport by address
+ */
+static struct rxrpc_transport *rxrpc_name_to_transport(struct socket *sock,
+						       struct sockaddr *addr,
+						       int addr_len, int flags)
+{
+	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *) addr;
+	struct rxrpc_transport *trans;
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
+	struct rxrpc_peer *peer;
+
+	_enter("%p,%p,%d,%d", rx, addr, addr_len, flags);
+
+	ASSERT(rx->local != NULL);
+	ASSERT(rx->sk.sk_state > RXRPC_UNCONNECTED);
+
+	if (rx->srx.transport_type != srx->transport_type)
+		return ERR_PTR(-ESOCKTNOSUPPORT);
+	if (rx->srx.transport.family != srx->transport.family)
+		return ERR_PTR(-EAFNOSUPPORT);
+
+	/* find a remote transport endpoint from the local one */
+	peer = rxrpc_get_peer(srx, GFP_KERNEL);
+	if (IS_ERR(peer))
+		return ERR_PTR(PTR_ERR(peer));
+
+	/* find a transport */
+	trans = rxrpc_get_transport(rx->local, peer, GFP_KERNEL);
+	rxrpc_put_peer(peer);
+	_leave(" = %p", trans);
+	return trans;
+}
+
+/*
+ * connect an RxRPC socket
+ * - this just targets it at a specific destination; no actual connection
+ *   negotiation takes place
+ */
+static int rxrpc_connect(struct socket *sock, struct sockaddr *addr,
+			 int addr_len, int flags)
+{
+	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *) addr;
+	struct sock *sk = sock->sk;
+	struct rxrpc_transport *trans;
+	struct rxrpc_local *local;
+	struct rxrpc_sock *rx = rxrpc_sk(sk);
+	int ret;
+
+	_enter("%p,%p,%d,%d", rx, addr, addr_len, flags);
+
+	ret = rxrpc_validate_address(rx, srx, addr_len);
+	if (ret < 0) {
+		_leave(" = %d [bad addr]", ret);
+		return ret;
+	}
+
+	lock_sock(&rx->sk);
+
+	switch (rx->sk.sk_state) {
+	case RXRPC_UNCONNECTED:
+		/* find a local transport endpoint if we don't have one already */
+		ASSERTCMP(rx->local, ==, NULL);
+		rx->srx.srx_family = AF_RXRPC;
+		rx->srx.srx_service = 0;
+		rx->srx.transport_type = srx->transport_type;
+		rx->srx.transport_len = sizeof(sa_family_t);
+		rx->srx.transport.family = srx->transport.family;
+		local = rxrpc_lookup_local(&rx->srx);
+		if (IS_ERR(local)) {
+			release_sock(&rx->sk);
+			return PTR_ERR(local);
+		}
+		rx->local = local;
+		rx->sk.sk_state = RXRPC_CLIENT_BOUND;
+	case RXRPC_CLIENT_BOUND:
+		break;
+	case RXRPC_CLIENT_CONNECTED:
+		release_sock(&rx->sk);
+		return -EISCONN;
+	default:
+		release_sock(&rx->sk);
+		return -EBUSY; /* server sockets can't connect as well */
+	}
+
+	trans = rxrpc_name_to_transport(sock, addr, addr_len, flags);
+	if (IS_ERR(trans)) {
+		release_sock(&rx->sk);
+		_leave(" = %ld", PTR_ERR(trans));
+		return PTR_ERR(trans);
+	}
+
+	rx->trans = trans;
+	rx->service_id = htons(srx->srx_service);
+	rx->sk.sk_state = RXRPC_CLIENT_CONNECTED;
+
+	release_sock(&rx->sk);
+	return 0;
+}
+
+/*
+ * send a message through an RxRPC socket
+ * - in a client this does a number of things:
+ *   - finds/sets up a connection for the security specified (if any)
+ *   - initiates a call (ID in control data)
+ *   - ends the request phase of a call (if MSG_MORE is not set)
+ *   - sends a call data packet
+ *   - may send an abort (abort code in control data)
+ */
+static int rxrpc_sendmsg(struct kiocb *iocb, struct socket *sock,
+			 struct msghdr *m, size_t len)
+{
+	struct rxrpc_transport *trans;
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
+	int ret;
+
+	_enter(",{%d},,%zu", rx->sk.sk_state, len);
+
+	if (m->msg_flags & MSG_OOB)
+		return -EOPNOTSUPP;
+
+	if (m->msg_name) {
+		ret = rxrpc_validate_address(rx, m->msg_name, m->msg_namelen);
+		if (ret < 0) {
+			_leave(" = %d [bad addr]", ret);
+			return ret;
+		}
+	}
+
+	trans = NULL;
+	lock_sock(&rx->sk);
+
+	if (m->msg_name) {
+		ret = -EISCONN;
+		trans = rxrpc_name_to_transport(sock, m->msg_name,
+						m->msg_namelen, 0);
+		if (IS_ERR(trans)) {
+			ret = PTR_ERR(trans);
+			trans = NULL;
+			goto out;
+		}
+	} else {
+		trans = rx->trans;
+		if (trans)
+			atomic_inc(&trans->usage);
+	}
+
+	switch (rx->sk.sk_state) {
+	case RXRPC_SERVER_LISTENING:
+		if (!m->msg_name) {
+			ret = rxrpc_server_sendmsg(iocb, rx, m, len);
+			break;
+		}
+	case RXRPC_SERVER_BOUND:
+	case RXRPC_CLIENT_BOUND:
+		if (!m->msg_name) {
+			ret = -ENOTCONN;
+			break;
+		}
+	case RXRPC_CLIENT_CONNECTED:
+		ret = rxrpc_client_sendmsg(iocb, rx, trans, m, len);
+		break;
+	default:
+		ret = -ENOTCONN;
+		break;
+	}
+
+out:
+	release_sock(&rx->sk);
+	if (trans)
+		rxrpc_put_transport(trans);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * set RxRPC socket options
+ */
+static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
+			    char __user *optval, int optlen)
+{
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
+	unsigned min_sec_level;
+	int ret;
+
+	_enter(",%d,%d,,%d", level, optname, optlen);
+
+	lock_sock(&rx->sk);
+	ret = -EOPNOTSUPP;
+
+	if (level == SOL_RXRPC) {
+		switch (optname) {
+		case RXRPC_EXCLUSIVE_CONNECTION:
+			ret = -EINVAL;
+			if (optlen != 0)
+				goto error;
+			ret = -EISCONN;
+			if (rx->sk.sk_state != RXRPC_UNCONNECTED)
+				goto error;
+			set_bit(RXRPC_SOCK_EXCLUSIVE_CONN, &rx->flags);
+			goto success;
+
+		case RXRPC_SECURITY_KEY:
+			ret = -EINVAL;
+			if (rx->key)
+				goto error;
+			ret = -EISCONN;
+			if (rx->sk.sk_state != RXRPC_UNCONNECTED)
+				goto error;
+			ret = rxrpc_request_key(rx, optval, optlen);
+			goto error;
+
+		case RXRPC_SECURITY_KEYRING:
+			ret = -EINVAL;
+			if (rx->key)
+				goto error;
+			ret = -EISCONN;
+			if (rx->sk.sk_state != RXRPC_UNCONNECTED)
+				goto error;
+			ret = rxrpc_server_keyring(rx, optval, optlen);
+			goto error;
+
+		case RXRPC_MIN_SECURITY_LEVEL:
+			ret = -EINVAL;
+			if (optlen != sizeof(unsigned))
+				goto error;
+			ret = -EISCONN;
+			if (rx->sk.sk_state != RXRPC_UNCONNECTED)
+				goto error;
+			ret = get_user(min_sec_level,
+				       (unsigned __user *) optval);
+			if (ret < 0)
+				goto error;
+			ret = -EINVAL;
+			if (min_sec_level > RXRPC_SECURITY_MAX)
+				goto error;
+			rx->min_sec_level = min_sec_level;
+			goto success;
+
+		default:
+			break;
+		}
+	}
+
+success:
+	ret = 0;
+error:
+	release_sock(&rx->sk);
+	return ret;
+}
+
+/*
+ * permit an RxRPC socket to be polled
+ */
+static unsigned int rxrpc_poll(struct file *file, struct socket *sock,
+			       poll_table *wait)
+{
+	unsigned int mask;
+	struct sock *sk = sock->sk;
+
+	poll_wait(file, sk->sk_sleep, wait);
+	mask = 0;
+
+	/* the socket is readable if there are any messages waiting on the Rx
+	 * queue */
+	if (!skb_queue_empty(&sk->sk_receive_queue))
+		mask |= POLLIN | POLLRDNORM;
+
+	/* the socket is writable if there is space to add new data to the
+	 * socket; there is no guarantee that any particular call in progress
+	 * on the socket may have space in the Tx ACK window */
+	if (rxrpc_writable(sk))
+		mask |= POLLOUT | POLLWRNORM;
+
+	return mask;
+}
+
+/*
+ * create an RxRPC socket
+ */
+static int rxrpc_create(struct socket *sock, int protocol)
+{
+	struct rxrpc_sock *rx;
+	struct sock *sk;
+
+	_enter("%p,%d", sock, protocol);
+
+	/* we support transport protocol UDP only */
+	if (protocol != PF_INET)
+		return -EPROTONOSUPPORT;
+
+	if (sock->type != SOCK_DGRAM)
+		return -ESOCKTNOSUPPORT;
+
+	sock->ops = &rxrpc_rpc_ops;
+	sock->state = SS_UNCONNECTED;
+
+	sk = sk_alloc(PF_RXRPC, GFP_KERNEL, &rxrpc_proto, 1);
+	if (!sk)
+		return -ENOMEM;
+
+	sock_init_data(sock, sk);
+	sk->sk_state		= RXRPC_UNCONNECTED;
+	sk->sk_write_space	= rxrpc_write_space;
+	sk->sk_max_ack_backlog	= sysctl_rxrpc_max_qlen;
+	sk->sk_destruct		= rxrpc_sock_destructor;
+
+	rx = rxrpc_sk(sk);
+	rx->proto = protocol;
+	rx->calls = RB_ROOT;
+
+	INIT_LIST_HEAD(&rx->listen_link);
+	INIT_LIST_HEAD(&rx->secureq);
+	INIT_LIST_HEAD(&rx->acceptq);
+	rwlock_init(&rx->call_lock);
+	memset(&rx->srx, 0, sizeof(rx->srx));
+
+	_leave(" = 0 [%p]", rx);
+	return 0;
+}
+
+/*
+ * RxRPC socket destructor
+ */
+static void rxrpc_sock_destructor(struct sock *sk)
+{
+	_enter("%p", sk);
+
+	rxrpc_purge_queue(&sk->sk_receive_queue);
+
+	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
+	BUG_TRAP(sk_unhashed(sk));
+	BUG_TRAP(!sk->sk_socket);
+
+	if (!sock_flag(sk, SOCK_DEAD)) {
+		printk("Attempt to release alive rxrpc socket: %p\n", sk);
+		return;
+	}
+}
+
+/*
+ * release an RxRPC socket
+ */
+static int rxrpc_release_sock(struct sock *sk)
+{
+	struct rxrpc_sock *rx = rxrpc_sk(sk);
+
+	_enter("%p{%d,%d}", sk, sk->sk_state, atomic_read(&sk->sk_refcnt));
+
+	/* declare the socket closed for business */
+	sock_orphan(sk);
+	sk->sk_shutdown = SHUTDOWN_MASK;
+
+	spin_lock_bh(&sk->sk_receive_queue.lock);
+	sk->sk_state = RXRPC_CLOSE;
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
+
+	ASSERTCMP(rx->listen_link.next, !=, LIST_POISON1);
+
+	if (!list_empty(&rx->listen_link)) {
+		write_lock_bh(&rx->local->services_lock);
+		list_del(&rx->listen_link);
+		write_unlock_bh(&rx->local->services_lock);
+	}
+
+	/* try to flush out this socket */
+	rxrpc_release_calls_on_socket(rx);
+	flush_scheduled_work();
+	rxrpc_purge_queue(&sk->sk_receive_queue);
+
+	if (rx->conn) {
+		rxrpc_put_connection(rx->conn);
+		rx->conn = NULL;
+	}
+
+	if (rx->bundle) {
+		rxrpc_put_bundle(rx->trans, rx->bundle);
+		rx->bundle = NULL;
+	}
+	if (rx->trans) {
+		rxrpc_put_transport(rx->trans);
+		rx->trans = NULL;
+	}
+	if (rx->local) {
+		rxrpc_put_local(rx->local);
+		rx->local = NULL;
+	}
+
+	key_put(rx->key);
+	rx->key = NULL;
+	key_put(rx->securities);
+	rx->securities = NULL;
+	sock_put(sk);
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * release an RxRPC BSD socket on close() or equivalent
+ */
+static int rxrpc_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	_enter("%p{%p}", sock, sk);
+
+	if (!sk)
+		return 0;
+
+	sock->sk = NULL;
+
+	return rxrpc_release_sock(sk);
+}
+
+/*
+ * RxRPC network protocol
+ */
+static const struct proto_ops rxrpc_rpc_ops = {
+	.family		= PF_UNIX,
+	.owner		= THIS_MODULE,
+	.release	= rxrpc_release,
+	.bind		= rxrpc_bind,
+	.connect	= rxrpc_connect,
+	.socketpair	= sock_no_socketpair,
+	.accept		= sock_no_accept,
+	.getname	= sock_no_getname,
+	.poll		= rxrpc_poll,
+	.ioctl		= sock_no_ioctl,
+	.listen		= rxrpc_listen,
+	.shutdown	= sock_no_shutdown,
+	.setsockopt	= rxrpc_setsockopt,
+	.getsockopt	= sock_no_getsockopt,
+	.sendmsg	= rxrpc_sendmsg,
+	.recvmsg	= rxrpc_recvmsg,
+	.mmap		= sock_no_mmap,
+	.sendpage	= sock_no_sendpage,
+};
+
+static struct proto rxrpc_proto = {
+	.name		= "RXRPC",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct rxrpc_sock),
+	.max_header	= sizeof(struct rxrpc_header),
+};
+
+static struct net_proto_family rxrpc_family_ops = {
+	.family	= PF_RXRPC,
+	.create = rxrpc_create,
+	.owner	= THIS_MODULE,
+};
+
+/*
+ * initialise and register the RxRPC protocol
+ */
+static int __init af_rxrpc_init(void)
+{
+	struct sk_buff *dummy_skb;
+	int ret = -1;
+
+	BUILD_BUG_ON(sizeof(struct rxrpc_skb_priv) > sizeof(dummy_skb->cb));
+
+	rxrpc_epoch = htonl(xtime.tv_sec);
+
+	rxrpc_call_jar = kmem_cache_create(
+		"rxrpc_call_jar", sizeof(struct rxrpc_call), 0,
+		SLAB_HWCACHE_ALIGN, NULL, NULL);
+	if (!rxrpc_call_jar) {
+		printk(KERN_NOTICE "RxRPC: Failed to allocate call jar\n");
+		ret = -ENOMEM;
+		goto error_call_jar;
+	}
+
+	ret = proto_register(&rxrpc_proto, 1);
+        if (ret < 0) {
+                printk(KERN_CRIT "RxRPC: Cannot register protocol\n");
+		goto error_proto;
+	}
+
+	ret = sock_register(&rxrpc_family_ops);
+	if (ret < 0) {
+                printk(KERN_CRIT "RxRPC: Cannot register socket family\n");
+		goto error_sock;
+	}
+
+	ret = register_key_type(&key_type_rxrpc);
+	if (ret < 0) {
+                printk(KERN_CRIT "RxRPC: Cannot register client key type\n");
+		goto error_key_type;
+	}
+
+	ret = register_key_type(&key_type_rxrpc_s);
+	if (ret < 0) {
+                printk(KERN_CRIT "RxRPC: Cannot register server key type\n");
+		goto error_key_type_s;
+	}
+
+#ifdef CONFIG_PROC_FS
+	proc_net_fops_create("rxrpc_calls", 0, &rxrpc_call_seq_fops);
+	proc_net_fops_create("rxrpc_conns", 0, &rxrpc_connection_seq_fops);
+#endif
+	return 0;
+
+error_key_type_s:
+	unregister_key_type(&key_type_rxrpc);
+error_key_type:
+	sock_unregister(PF_RXRPC);
+error_sock:
+	proto_unregister(&rxrpc_proto);
+error_proto:
+	kmem_cache_destroy(rxrpc_call_jar);
+error_call_jar:
+	return ret;
+}
+
+/*
+ * unregister the RxRPC protocol
+ */
+static void __exit af_rxrpc_exit(void)
+{
+	_enter("");
+	unregister_key_type(&key_type_rxrpc_s);
+	unregister_key_type(&key_type_rxrpc);
+	sock_unregister(PF_RXRPC);
+	proto_unregister(&rxrpc_proto);
+	rxrpc_destroy_all_calls();
+	rxrpc_destroy_all_connections();
+	rxrpc_destroy_all_transports();
+	rxrpc_destroy_all_peers();
+	rxrpc_destroy_all_locals();
+
+	ASSERTCMP(atomic_read(&rxrpc_n_skbs), ==, 0);
+
+	_debug("flush scheduled work");
+	flush_scheduled_work();
+	proc_net_remove("rxrpc_conns");
+	proc_net_remove("rxrpc_calls");
+	kmem_cache_destroy(rxrpc_call_jar);
+	_leave("");
+}
+
+module_init(af_rxrpc_init);
+module_exit(af_rxrpc_exit);
diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
new file mode 100644
index 0000000..e7af780
--- /dev/null
+++ b/net/rxrpc/ar-accept.c
@@ -0,0 +1,399 @@
+/* incoming call handling
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/errqueue.h>
+#include <linux/udp.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/icmp.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include <net/ip.h>
+#include "ar-internal.h"
+
+/*
+ * generate a connection-level abort
+ */
+static int rxrpc_busy(struct rxrpc_local *local, struct sockaddr_rxrpc *srx,
+		      struct rxrpc_header *hdr)
+{
+	struct msghdr msg;
+	struct kvec iov[1];
+	size_t len;
+	int ret;
+
+	_enter("%d,,", local->debug_id);
+
+	msg.msg_name	= &srx->transport.sin;
+	msg.msg_namelen	= sizeof(srx->transport.sin);
+	msg.msg_control	= NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags	= 0;
+
+	hdr->seq	= 0;
+	hdr->type	= RXRPC_PACKET_TYPE_BUSY;
+	hdr->flags	= 0;
+	hdr->userStatus	= 0;
+	hdr->_rsvd	= 0;
+
+	iov[0].iov_base	= hdr;
+	iov[0].iov_len	= sizeof(*hdr);
+
+	len = iov[0].iov_len;
+
+	hdr->serial = htonl(1);
+	_proto("Tx BUSY %%%u", ntohl(hdr->serial));
+
+	ret = kernel_sendmsg(local->socket, &msg, iov, 1, len);
+	if (ret < 0) {
+		_leave(" = -EAGAIN [sendmsg failed: %d]", ret);
+		return -EAGAIN;
+	}
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * accept an incoming call that needs peer, transport and/or connection setting
+ * up
+ */
+static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
+				      struct rxrpc_sock *rx,
+				      struct sk_buff *skb,
+				      struct sockaddr_rxrpc *srx)
+{
+	struct rxrpc_connection *conn;
+	struct rxrpc_transport *trans;
+	struct rxrpc_skb_priv *sp, *nsp;
+	struct rxrpc_peer *peer;
+	struct rxrpc_call *call;
+	struct sk_buff *notification;
+	int ret;
+
+	_enter("");
+
+	sp = rxrpc_skb(skb);
+
+	/* get a notification message to send to the server app */
+	notification = alloc_skb(0, GFP_NOFS);
+	rxrpc_new_skb(notification);
+	notification->mark = RXRPC_SKB_MARK_NEW_CALL;
+
+	peer = rxrpc_get_peer(srx, GFP_NOIO);
+	if (IS_ERR(peer)) {
+		_debug("no peer");
+		ret = -EBUSY;
+		goto error;
+	}
+
+	trans = rxrpc_get_transport(local, peer, GFP_NOIO);
+	rxrpc_put_peer(peer);
+	if (!trans) {
+		_debug("no trans");
+		ret = -EBUSY;
+		goto error;
+	}
+
+	conn = rxrpc_incoming_connection(trans, &sp->hdr, GFP_NOIO);
+	rxrpc_put_transport(trans);
+	if (IS_ERR(conn)) {
+		_debug("no conn");
+		ret = PTR_ERR(conn);
+		goto error;
+	}
+
+	call = rxrpc_incoming_call(rx, conn, &sp->hdr, GFP_NOIO);
+	rxrpc_put_connection(conn);
+	if (IS_ERR(call)) {
+		_debug("no call");
+		ret = PTR_ERR(call);
+		goto error;
+	}
+
+	/* attach the call to the socket */
+	read_lock_bh(&local->services_lock);
+	if (rx->sk.sk_state == RXRPC_CLOSE)
+		goto invalid_service;
+
+	write_lock(&rx->call_lock);
+	if (!test_and_set_bit(RXRPC_CALL_INIT_ACCEPT, &call->flags)) {
+		rxrpc_get_call(call);
+
+		spin_lock(&call->conn->state_lock);
+		if (sp->hdr.securityIndex > 0 &&
+		    call->conn->state == RXRPC_CONN_SERVER_UNSECURED) {
+			_debug("await conn sec");
+			list_add_tail(&call->accept_link, &rx->secureq);
+			call->conn->state = RXRPC_CONN_SERVER_CHALLENGING;
+			atomic_inc(&call->conn->usage);
+			set_bit(RXRPC_CONN_CHALLENGE, &call->conn->events);
+			schedule_work(&call->conn->processor);
+		} else {
+			_debug("conn ready");
+			call->state = RXRPC_CALL_SERVER_ACCEPTING;
+			list_add_tail(&call->accept_link, &rx->acceptq);
+			rxrpc_get_call(call);
+			nsp = rxrpc_skb(notification);
+			nsp->call = call;
+
+			ASSERTCMP(atomic_read(&call->usage), >=, 3);
+
+			_debug("notify");
+			spin_lock(&call->lock);
+			ret = rxrpc_queue_rcv_skb(call, notification, true,
+						  false);
+			spin_unlock(&call->lock);
+			notification = NULL;
+			if (ret < 0)
+				BUG();
+		}
+		spin_unlock(&call->conn->state_lock);
+
+		_debug("queued");
+	}
+	write_unlock(&rx->call_lock);
+
+	_debug("process");
+	rxrpc_fast_process_packet(call, skb);
+
+	_debug("done");
+	read_unlock_bh(&local->services_lock);
+	rxrpc_free_skb(notification);
+	rxrpc_put_call(call);
+	_leave(" = 0");
+	return 0;
+
+invalid_service:
+	_debug("invalid");
+	read_unlock_bh(&local->services_lock);
+
+	read_lock_bh(&call->state_lock);
+	if (!test_bit(RXRPC_CALL_RELEASE, &call->flags) &&
+	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events)) {
+		rxrpc_get_call(call);
+		schedule_work(&call->processor);
+	}
+	read_unlock_bh(&call->state_lock);
+	rxrpc_put_call(call);
+	ret = -ECONNREFUSED;
+error:
+	rxrpc_free_skb(notification);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * accept incoming calls that need peer, transport and/or connection setting up
+ * - the packets we get are all incoming client DATA packets that have seq == 1
+ */
+void rxrpc_accept_incoming_calls(struct work_struct *work)
+{
+	struct rxrpc_local *local =
+		container_of(work, struct rxrpc_local, acceptor);
+	struct rxrpc_skb_priv *sp;
+	struct sockaddr_rxrpc srx;
+	struct rxrpc_sock *rx;
+	struct sk_buff *skb;
+	__be16 service_id;
+	int ret;
+
+	_enter("%d", local->debug_id);
+
+	read_lock_bh(&rxrpc_local_lock);
+	if (atomic_read(&local->usage) > 0)
+		rxrpc_get_local(local);
+	else
+		local = NULL;
+	read_unlock_bh(&rxrpc_local_lock);
+	if (!local) {
+		_leave(" [local dead]");
+		return;
+	}
+
+process_next_packet:
+	skb = skb_dequeue(&local->accept_queue);
+	if (!skb) {
+		rxrpc_put_local(local);
+		_leave("\n");
+		return;
+	}
+
+	_net("incoming call skb %p", skb);
+
+	sp = rxrpc_skb(skb);
+
+	/* determine the remote address */
+	memset(&srx, 0, sizeof(srx));
+	srx.srx_family = AF_RXRPC;
+	srx.transport.family = local->srx.transport.family;
+	srx.transport_type = local->srx.transport_type;
+	switch (srx.transport.family) {
+	case AF_INET:
+		srx.transport_len = sizeof(struct sockaddr_in);
+		srx.transport.sin.sin_port = udp_hdr(skb)->source;
+		srx.transport.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
+		break;
+	default:
+		goto busy;
+	}
+
+	/* get the socket providing the service */
+	service_id = sp->hdr.serviceId;
+	read_lock_bh(&local->services_lock);
+	list_for_each_entry(rx, &local->services, listen_link) {
+		if (rx->service_id == service_id &&
+		    rx->sk.sk_state != RXRPC_CLOSE)
+			goto found_service;
+	}
+	read_unlock_bh(&local->services_lock);
+	goto invalid_service;
+
+found_service:
+	_debug("found service %hd", ntohs(rx->service_id));
+	if (sk_acceptq_is_full(&rx->sk))
+		goto backlog_full;
+	sk_acceptq_added(&rx->sk);
+	sock_hold(&rx->sk);
+	read_unlock_bh(&local->services_lock);
+
+	ret = rxrpc_accept_incoming_call(local, rx, skb, &srx);
+	if (ret < 0)
+		sk_acceptq_removed(&rx->sk);
+	sock_put(&rx->sk);
+	switch (ret) {
+	case -ECONNRESET: /* old calls are ignored */
+	case -ECONNABORTED: /* aborted calls are reaborted or ignored */
+	case 0:
+		goto process_next_packet;
+	case -ECONNREFUSED:
+		goto invalid_service;
+	case -EBUSY:
+		goto busy;
+	case -EKEYREJECTED:
+		goto security_mismatch;
+	default:
+		BUG();
+	}
+
+backlog_full:
+	read_unlock_bh(&local->services_lock);
+busy:
+	rxrpc_busy(local, &srx, &sp->hdr);
+	rxrpc_free_skb(skb);
+	goto process_next_packet;
+
+invalid_service:
+	skb->priority = RX_INVALID_OPERATION;
+	rxrpc_reject_packet(local, skb);
+	goto process_next_packet;
+
+	/* can't change connection security type mid-flow */
+security_mismatch:
+	skb->priority = RX_PROTOCOL_ERROR;
+	rxrpc_reject_packet(local, skb);
+	goto process_next_packet;
+}
+
+/*
+ * handle acceptance of a call by userspace
+ * - assign the user call ID to the call at the front of the queue
+ */
+int rxrpc_accept_call(struct rxrpc_sock *rx, unsigned long user_call_ID)
+{
+	struct rxrpc_call *call;
+	struct rb_node *parent, **pp;
+	int ret;
+
+	_enter(",%lx", user_call_ID);
+
+	ASSERT(!irqs_disabled());
+
+	write_lock(&rx->call_lock);
+
+	ret = -ENODATA;
+	if (list_empty(&rx->acceptq))
+		goto out;
+
+	/* check the user ID isn't already in use */
+	ret = -EBADSLT;
+	pp = &rx->calls.rb_node;
+	parent = NULL;
+	while (*pp) {
+		parent = *pp;
+		call = rb_entry(parent, struct rxrpc_call, sock_node);
+
+		if (user_call_ID < call->user_call_ID)
+			pp = &(*pp)->rb_left;
+		else if (user_call_ID > call->user_call_ID)
+			pp = &(*pp)->rb_right;
+		else
+			goto out;
+	}
+
+	/* dequeue the first call and check it's still valid */
+	call = list_entry(rx->acceptq.next, struct rxrpc_call, accept_link);
+	list_del_init(&call->accept_link);
+	sk_acceptq_removed(&rx->sk);
+
+	write_lock_bh(&call->state_lock);
+	switch (call->state) {
+	case RXRPC_CALL_SERVER_ACCEPTING:
+		call->state = RXRPC_CALL_SERVER_RECV_REQUEST;
+		break;
+	case RXRPC_CALL_REMOTELY_ABORTED:
+	case RXRPC_CALL_LOCALLY_ABORTED:
+		ret = -ECONNABORTED;
+		goto out_release;
+	case RXRPC_CALL_NETWORK_ERROR:
+		ret = call->conn->error;
+		goto out_release;
+	case RXRPC_CALL_DEAD:
+		ret = -ETIME;
+		goto out_discard;
+	default:
+		BUG();
+	}
+
+	/* formalise the acceptance */
+	call->user_call_ID = user_call_ID;
+	rb_link_node(&call->sock_node, parent, pp);
+	rb_insert_color(&call->sock_node, &rx->calls);
+	if (test_and_set_bit(RXRPC_CALL_HAS_USERID, &call->flags))
+		BUG();
+	if (test_and_set_bit(RXRPC_CALL_ACCEPTED, &call->events))
+		BUG();
+	schedule_work(&call->processor);
+
+	write_unlock_bh(&call->state_lock);
+	write_unlock(&rx->call_lock);
+	_leave(" = 0");
+	return 0;
+
+	/* if the call is already dying or dead, then we leave the socket's ref
+	 * on it to be released by rxrpc_dead_call_expired() as induced by
+	 * rxrpc_release_call() */
+out_release:
+	_debug("release %p", call);
+	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
+	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+		schedule_work(&call->processor);
+out_discard:
+	write_unlock_bh(&call->state_lock);
+	_debug("discard %p", call);
+out:
+	write_unlock(&rx->call_lock);
+	_leave(" = %d", ret);
+	return ret;
+}
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
new file mode 100644
index 0000000..8f7764e
--- /dev/null
+++ b/net/rxrpc/ar-ack.c
@@ -0,0 +1,1250 @@
+/* Management of Tx window, Tx resend, ACKs and out-of-sequence reception
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/circ_buf.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/udp.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+static unsigned rxrpc_ack_defer = 1;
+
+static const char *rxrpc_acks[] = {
+	"---", "REQ", "DUP", "OOS", "WIN", "MEM", "PNG", "PNR", "DLY", "IDL",
+	"-?-"
+};
+
+static const s8 rxrpc_ack_priority[] = {
+	[0]				= 0,
+	[RXRPC_ACK_DELAY]		= 1,
+	[RXRPC_ACK_REQUESTED]		= 2,
+	[RXRPC_ACK_IDLE]		= 3,
+	[RXRPC_ACK_PING_RESPONSE]	= 4,
+	[RXRPC_ACK_DUPLICATE]		= 5,
+	[RXRPC_ACK_OUT_OF_SEQUENCE]	= 6,
+	[RXRPC_ACK_EXCEEDS_WINDOW]	= 7,
+	[RXRPC_ACK_NOSPACE]		= 8,
+};
+
+/*
+ * propose an ACK be sent
+ */
+void __rxrpc_propose_ACK(struct rxrpc_call *call, uint8_t ack_reason,
+			 __be32 serial, bool immediate)
+{
+	unsigned long expiry;
+	s8 prior = rxrpc_ack_priority[ack_reason];
+
+	ASSERTCMP(prior, >, 0);
+
+	_enter("{%d},%s,%%%x,%u",
+	       call->debug_id, rxrpc_acks[ack_reason], ntohl(serial),
+	       immediate);
+
+	if (prior < rxrpc_ack_priority[call->ackr_reason]) {
+		if (immediate)
+			goto cancel_timer;
+		return;
+	}
+
+	/* update DELAY, IDLE, REQUESTED and PING_RESPONSE ACK serial
+	 * numbers */
+	if (prior == rxrpc_ack_priority[call->ackr_reason]) {
+		if (prior <= 4)
+			call->ackr_serial = serial;
+		if (immediate)
+			goto cancel_timer;
+		return;
+	}
+
+	call->ackr_reason = ack_reason;
+	call->ackr_serial = serial;
+
+	switch (ack_reason) {
+	case RXRPC_ACK_DELAY:
+		_debug("run delay timer");
+		call->ack_timer.expires = jiffies + rxrpc_ack_timeout * HZ;
+		add_timer(&call->ack_timer);
+		return;
+
+	case RXRPC_ACK_IDLE:
+		if (!immediate) {
+			_debug("run defer timer");
+			expiry = 1;
+			goto run_timer;
+		}
+		goto cancel_timer;
+
+	case RXRPC_ACK_REQUESTED:
+		if (!rxrpc_ack_defer)
+			goto cancel_timer;
+		if (!immediate || serial == cpu_to_be32(1)) {
+			_debug("run defer timer");
+			expiry = rxrpc_ack_defer;
+			goto run_timer;
+		}
+
+	default:
+		_debug("immediate ACK");
+		goto cancel_timer;
+	}
+
+run_timer:
+	expiry += jiffies;
+	if (!timer_pending(&call->ack_timer) ||
+	    time_after(call->ack_timer.expires, expiry))
+		mod_timer(&call->ack_timer, expiry);
+	return;
+
+cancel_timer:
+	_debug("cancel timer %%%u", ntohl(serial));
+	try_to_del_timer_sync(&call->ack_timer);
+	read_lock_bh(&call->state_lock);
+	if (call->state <= RXRPC_CALL_COMPLETE &&
+	    !test_and_set_bit(RXRPC_CALL_ACK, &call->events))
+		schedule_work(&call->processor);
+	read_unlock_bh(&call->state_lock);
+}
+
+/*
+ * propose an ACK be sent, locking the call structure
+ */
+void rxrpc_propose_ACK(struct rxrpc_call *call, uint8_t ack_reason,
+		       __be32 serial, bool immediate)
+{
+	s8 prior = rxrpc_ack_priority[ack_reason];
+
+	if (prior > rxrpc_ack_priority[call->ackr_reason]) {
+		spin_lock_bh(&call->lock);
+		__rxrpc_propose_ACK(call, ack_reason, serial, immediate);
+		spin_unlock_bh(&call->lock);
+	}
+}
+
+/*
+ * set the resend timer
+ */
+static void rxrpc_set_resend(struct rxrpc_call *call, u8 resend,
+			     unsigned long resend_at)
+{
+	read_lock_bh(&call->state_lock);
+	if (call->state >= RXRPC_CALL_COMPLETE)
+		resend = 0;
+
+	if (resend & 1) {
+		_debug("SET RESEND");
+		set_bit(RXRPC_CALL_RESEND, &call->events);
+	}
+
+	if (resend & 2) {
+		_debug("MODIFY RESEND TIMER");
+		set_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
+		mod_timer(&call->resend_timer, resend_at);
+	} else {
+		_debug("KILL RESEND TIMER");
+		del_timer_sync(&call->resend_timer);
+		clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events);
+		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
+	}
+	read_unlock_bh(&call->state_lock);
+}
+
+/*
+ * resend packets
+ */
+static void rxrpc_resend(struct rxrpc_call *call)
+{
+	struct rxrpc_skb_priv *sp;
+	struct rxrpc_header *hdr;
+	struct sk_buff *txb;
+	unsigned long *p_txb, resend_at;
+	int loop, stop;
+	u8 resend;
+
+	_enter("{%d,%d,%d,%d},",
+	       call->acks_hard, call->acks_unacked,
+	       atomic_read(&call->sequence),
+	       CIRC_CNT(call->acks_head, call->acks_tail, call->acks_winsz));
+
+	stop = 0;
+	resend = 0;
+	resend_at = 0;
+
+	for (loop = call->acks_tail;
+	     loop != call->acks_head || stop;
+	     loop = (loop + 1) &  (call->acks_winsz - 1)
+	     ) {
+		p_txb = call->acks_window + loop;
+		smp_read_barrier_depends();
+		if (*p_txb & 1)
+			continue;
+
+		txb = (struct sk_buff *) *p_txb;
+		sp = rxrpc_skb(txb);
+
+		if (sp->need_resend) {
+			sp->need_resend = 0;
+
+			/* each Tx packet has a new serial number */
+			sp->hdr.serial =
+				htonl(atomic_inc_return(&call->conn->serial));
+
+			hdr = (struct rxrpc_header *) txb->head;
+			hdr->serial = sp->hdr.serial;
+
+			_proto("Tx DATA %%%u { #%d }",
+			       ntohl(sp->hdr.serial), ntohl(sp->hdr.seq));
+			if (rxrpc_send_packet(call->conn->trans, txb) < 0) {
+				stop = 0;
+				sp->resend_at = jiffies + 3;
+			} else {
+				sp->resend_at =
+					jiffies + rxrpc_resend_timeout * HZ;
+			}
+		}
+
+		if (time_after_eq(jiffies + 1, sp->resend_at)) {
+			sp->need_resend = 1;
+			resend |= 1;
+		} else if (resend & 2) {
+			if (time_before(sp->resend_at, resend_at))
+				resend_at = sp->resend_at;
+		} else {
+			resend_at = sp->resend_at;
+			resend |= 2;
+		}
+	}
+
+	rxrpc_set_resend(call, resend, resend_at);
+	_leave("");
+}
+
+/*
+ * handle resend timer expiry
+ */
+static void rxrpc_resend_timer(struct rxrpc_call *call)
+{
+	struct rxrpc_skb_priv *sp;
+	struct sk_buff *txb;
+	unsigned long *p_txb, resend_at;
+	int loop;
+	u8 resend;
+
+	_enter("%d,%d,%d",
+	       call->acks_tail, call->acks_unacked, call->acks_head);
+
+	resend = 0;
+	resend_at = 0;
+
+	for (loop = call->acks_unacked;
+	     loop != call->acks_head;
+	     loop = (loop + 1) &  (call->acks_winsz - 1)
+	     ) {
+		p_txb = call->acks_window + loop;
+		smp_read_barrier_depends();
+		txb = (struct sk_buff *) (*p_txb & ~1);
+		sp = rxrpc_skb(txb);
+
+		ASSERT(!(*p_txb & 1));
+
+		if (sp->need_resend) {
+			;
+		} else if (time_after_eq(jiffies + 1, sp->resend_at)) {
+			sp->need_resend = 1;
+			resend |= 1;
+		} else if (resend & 2) {
+			if (time_before(sp->resend_at, resend_at))
+				resend_at = sp->resend_at;
+		} else {
+			resend_at = sp->resend_at;
+			resend |= 2;
+		}
+	}
+
+	rxrpc_set_resend(call, resend, resend_at);
+	_leave("");
+}
+
+/*
+ * process soft ACKs of our transmitted packets
+ * - these indicate packets the peer has or has not received, but hasn't yet
+ *   given to the consumer, and so can still be discarded and re-requested
+ */
+static int rxrpc_process_soft_ACKs(struct rxrpc_call *call,
+				   struct rxrpc_ackpacket *ack,
+				   struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp;
+	struct sk_buff *txb;
+	unsigned long *p_txb, resend_at;
+	int loop;
+	u8 sacks[RXRPC_MAXACKS], resend;
+
+	_enter("{%d,%d},{%d},",
+	       call->acks_hard,
+	       CIRC_CNT(call->acks_head, call->acks_tail, call->acks_winsz),
+	       ack->nAcks);
+
+	if (skb_copy_bits(skb, 0, sacks, ack->nAcks) < 0)
+		goto protocol_error;
+
+	resend = 0;
+	resend_at = 0;
+	for (loop = 0; loop < ack->nAcks; loop++) {
+		p_txb = call->acks_window;
+		p_txb += (call->acks_tail + loop) & (call->acks_winsz - 1);
+		smp_read_barrier_depends();
+		txb = (struct sk_buff *) (*p_txb & ~1);
+		sp = rxrpc_skb(txb);
+
+		switch (sacks[loop]) {
+		case RXRPC_ACK_TYPE_ACK:
+			sp->need_resend = 0;
+			*p_txb |= 1;
+			break;
+		case RXRPC_ACK_TYPE_NACK:
+			sp->need_resend = 1;
+			*p_txb &= ~1;
+			resend = 1;
+			break;
+		default:
+			_debug("Unsupported ACK type %d", sacks[loop]);
+			goto protocol_error;
+		}
+	}
+
+	smp_mb();
+	call->acks_unacked = (call->acks_tail + loop) & (call->acks_winsz - 1);
+
+	/* anything not explicitly ACK'd is implicitly NACK'd, but may just not
+	 * have been received or processed yet by the far end */
+	for (loop = call->acks_unacked;
+	     loop != call->acks_head;
+	     loop = (loop + 1) &  (call->acks_winsz - 1)
+	     ) {
+		p_txb = call->acks_window + loop;
+		smp_read_barrier_depends();
+		txb = (struct sk_buff *) (*p_txb & ~1);
+		sp = rxrpc_skb(txb);
+
+		if (*p_txb & 1) {
+			/* packet must have been discarded */
+			sp->need_resend = 1;
+			*p_txb &= ~1;
+			resend |= 1;
+		} else if (sp->need_resend) {
+			;
+		} else if (time_after_eq(jiffies + 1, sp->resend_at)) {
+			sp->need_resend = 1;
+			resend |= 1;
+		} else if (resend & 2) {
+			if (time_before(sp->resend_at, resend_at))
+				resend_at = sp->resend_at;
+		} else {
+			resend_at = sp->resend_at;
+			resend |= 2;
+		}
+	}
+
+	rxrpc_set_resend(call, resend, resend_at);
+	_leave(" = 0");
+	return 0;
+
+protocol_error:
+	_leave(" = -EPROTO");
+	return -EPROTO;
+}
+
+/*
+ * discard hard-ACK'd packets from the Tx window
+ */
+static void rxrpc_rotate_tx_window(struct rxrpc_call *call, u32 hard)
+{
+	struct rxrpc_skb_priv *sp;
+	unsigned long _skb;
+	int tail = call->acks_tail, old_tail;
+	int win = CIRC_CNT(call->acks_head, tail, call->acks_winsz);
+
+	_enter("{%u,%u},%u", call->acks_hard, win, hard);
+
+	ASSERTCMP(hard - call->acks_hard, <=, win);
+
+	while (call->acks_hard < hard) {
+		smp_read_barrier_depends();
+		_skb = call->acks_window[tail] & ~1;
+		sp = rxrpc_skb((struct sk_buff *) _skb);
+		rxrpc_free_skb((struct sk_buff *) _skb);
+		old_tail = tail;
+		tail = (tail + 1) & (call->acks_winsz - 1);
+		call->acks_tail = tail;
+		if (call->acks_unacked == old_tail)
+			call->acks_unacked = tail;
+		call->acks_hard++;
+	}
+
+	wake_up(&call->tx_waitq);
+}
+
+/*
+ * clear the Tx window in the event of a failure
+ */
+static void rxrpc_clear_tx_window(struct rxrpc_call *call)
+{
+	rxrpc_rotate_tx_window(call, atomic_read(&call->sequence));
+}
+
+/*
+ * drain the out of sequence received packet queue into the packet Rx queue
+ */
+static int rxrpc_drain_rx_oos_queue(struct rxrpc_call *call)
+{
+	struct rxrpc_skb_priv *sp;
+	struct sk_buff *skb;
+	bool terminal;
+	int ret;
+
+	_enter("{%d,%d}", call->rx_data_post, call->rx_first_oos);
+
+	spin_lock_bh(&call->lock);
+
+	ret = -ECONNRESET;
+	if (test_bit(RXRPC_CALL_RELEASED, &call->flags))
+		goto socket_unavailable;
+
+	skb = skb_dequeue(&call->rx_oos_queue);
+	if (skb) {
+		sp = rxrpc_skb(skb);
+
+		_debug("drain OOS packet %d [%d]",
+		       ntohl(sp->hdr.seq), call->rx_first_oos);
+
+		if (ntohl(sp->hdr.seq) != call->rx_first_oos) {
+			skb_queue_head(&call->rx_oos_queue, skb);
+			call->rx_first_oos = ntohl(rxrpc_skb(skb)->hdr.seq);
+			_debug("requeue %p {%u}", skb, call->rx_first_oos);
+		} else {
+			skb->mark = RXRPC_SKB_MARK_DATA;
+			terminal = ((sp->hdr.flags & RXRPC_LAST_PACKET) &&
+				!(sp->hdr.flags & RXRPC_CLIENT_INITIATED));
+			ret = rxrpc_queue_rcv_skb(call, skb, true, terminal);
+			BUG_ON(ret < 0);
+			_debug("drain #%u", call->rx_data_post);
+			call->rx_data_post++;
+
+			/* find out what the next packet is */
+			skb = skb_peek(&call->rx_oos_queue);
+			if (skb)
+				call->rx_first_oos =
+					ntohl(rxrpc_skb(skb)->hdr.seq);
+			else
+				call->rx_first_oos = 0;
+			_debug("peek %p {%u}", skb, call->rx_first_oos);
+		}
+	}
+
+	ret = 0;
+socket_unavailable:
+	spin_unlock_bh(&call->lock);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * insert an out of sequence packet into the buffer
+ */
+static void rxrpc_insert_oos_packet(struct rxrpc_call *call,
+				    struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp, *psp;
+	struct sk_buff *p;
+	u32 seq;
+
+	sp = rxrpc_skb(skb);
+	seq = ntohl(sp->hdr.seq);
+	_enter(",,{%u}", seq);
+
+	skb->destructor = rxrpc_packet_destructor;
+	ASSERTCMP(sp->call, ==, NULL);
+	sp->call = call;
+	rxrpc_get_call(call);
+
+	/* insert into the buffer in sequence order */
+	spin_lock_bh(&call->lock);
+
+	skb_queue_walk(&call->rx_oos_queue, p) {
+		psp = rxrpc_skb(p);
+		if (ntohl(psp->hdr.seq) > seq) {
+			_debug("insert oos #%u before #%u",
+			       seq, ntohl(psp->hdr.seq));
+			skb_insert(p, skb, &call->rx_oos_queue);
+			goto inserted;
+		}
+	}
+
+	_debug("append oos #%u", seq);
+	skb_queue_tail(&call->rx_oos_queue, skb);
+inserted:
+
+	/* we might now have a new front to the queue */
+	if (call->rx_first_oos == 0 || seq < call->rx_first_oos)
+		call->rx_first_oos = seq;
+
+	read_lock(&call->state_lock);
+	if (call->state < RXRPC_CALL_COMPLETE &&
+	    call->rx_data_post == call->rx_first_oos) {
+		_debug("drain rx oos now");
+		set_bit(RXRPC_CALL_DRAIN_RX_OOS, &call->events);
+	}
+	read_unlock(&call->state_lock);
+
+	spin_unlock_bh(&call->lock);
+	_leave(" [stored #%u]", call->rx_first_oos);
+}
+
+/*
+ * clear the Tx window on final ACK reception
+ */
+static void rxrpc_zap_tx_window(struct rxrpc_call *call)
+{
+	struct rxrpc_skb_priv *sp;
+	struct sk_buff *skb;
+	unsigned long _skb, *acks_window;
+	uint8_t winsz = call->acks_winsz;
+	int tail;
+
+	acks_window = call->acks_window;
+	call->acks_window = NULL;
+
+	while (CIRC_CNT(call->acks_head, call->acks_tail, winsz) > 0) {
+		tail = call->acks_tail;
+		smp_read_barrier_depends();
+		_skb = acks_window[tail] & ~1;
+		smp_mb();
+		call->acks_tail = (call->acks_tail + 1) & (winsz - 1);
+
+		skb = (struct sk_buff *) _skb;
+		sp = rxrpc_skb(skb);
+		_debug("+++ clear Tx %u", ntohl(sp->hdr.seq));
+		rxrpc_free_skb(skb);
+	}
+
+	kfree(acks_window);
+}
+
+/*
+ * process packets in the reception queue
+ */
+static int rxrpc_process_rx_queue(struct rxrpc_call *call,
+				  u32 *_abort_code)
+{
+	struct rxrpc_ackpacket ack;
+	struct rxrpc_skb_priv *sp;
+	struct sk_buff *skb;
+	bool post_ACK;
+	int latest;
+	u32 hard, tx;
+
+	_enter("");
+
+process_further:
+	skb = skb_dequeue(&call->rx_queue);
+	if (!skb)
+		return -EAGAIN;
+
+	_net("deferred skb %p", skb);
+
+	sp = rxrpc_skb(skb);
+
+	_debug("process %s [st %d]", rxrpc_pkts[sp->hdr.type], call->state);
+
+	post_ACK = false;
+
+	switch (sp->hdr.type) {
+		/* data packets that wind up here have been received out of
+		 * order, need security processing or are jumbo packets */
+	case RXRPC_PACKET_TYPE_DATA:
+		_proto("OOSQ DATA %%%u { #%u }",
+		       ntohl(sp->hdr.serial), ntohl(sp->hdr.seq));
+
+		/* secured packets must be verified and possibly decrypted */
+		if (rxrpc_verify_packet(call, skb, _abort_code) < 0)
+			goto protocol_error;
+
+		rxrpc_insert_oos_packet(call, skb);
+		goto process_further;
+
+		/* partial ACK to process */
+	case RXRPC_PACKET_TYPE_ACK:
+		if (skb_copy_bits(skb, 0, &ack, sizeof(ack)) < 0) {
+			_debug("extraction failure");
+			goto protocol_error;
+		}
+		if (!skb_pull(skb, sizeof(ack)))
+			BUG();
+
+		latest = ntohl(sp->hdr.serial);
+		hard = ntohl(ack.firstPacket);
+		tx = atomic_read(&call->sequence);
+
+		_proto("Rx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
+		       latest,
+		       ntohs(ack.maxSkew),
+		       hard,
+		       ntohl(ack.previousPacket),
+		       ntohl(ack.serial),
+		       rxrpc_acks[ack.reason],
+		       ack.nAcks);
+
+		if (ack.reason == RXRPC_ACK_PING) {
+			_proto("Rx ACK %%%u PING Request", latest);
+			rxrpc_propose_ACK(call, RXRPC_ACK_PING_RESPONSE,
+					  sp->hdr.serial, true);
+		}
+
+		/* discard any out-of-order or duplicate ACKs */
+		if (latest - call->acks_latest <= 0) {
+			_debug("discard ACK %d <= %d",
+			       latest, call->acks_latest);
+			goto discard;
+		}
+		call->acks_latest = latest;
+
+		if (call->state != RXRPC_CALL_CLIENT_SEND_REQUEST &&
+		    call->state != RXRPC_CALL_CLIENT_AWAIT_REPLY &&
+		    call->state != RXRPC_CALL_SERVER_SEND_REPLY &&
+		    call->state != RXRPC_CALL_SERVER_AWAIT_ACK)
+			goto discard;
+
+		_debug("Tx=%d H=%u S=%d", tx, call->acks_hard, call->state);
+
+		if (hard > 0) {
+			if (hard - 1 > tx) {
+				_debug("hard-ACK'd packet %d not transmitted"
+				       " (%d top)",
+				       hard - 1, tx);
+				goto protocol_error;
+			}
+
+			if ((call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY ||
+			     call->state == RXRPC_CALL_SERVER_AWAIT_ACK) &&
+			    hard > tx)
+				goto all_acked;
+
+			smp_rmb();
+			rxrpc_rotate_tx_window(call, hard - 1);
+		}
+
+		if (ack.nAcks > 0) {
+			if (hard - 1 + ack.nAcks > tx) {
+				_debug("soft-ACK'd packet %d+%d not"
+				       " transmitted (%d top)",
+				       hard - 1, ack.nAcks, tx);
+				goto protocol_error;
+			}
+
+			if (rxrpc_process_soft_ACKs(call, &ack, skb) < 0)
+				goto protocol_error;
+		}
+		goto discard;
+
+		/* complete ACK to process */
+	case RXRPC_PACKET_TYPE_ACKALL:
+		goto all_acked;
+
+		/* abort and busy are handled elsewhere */
+	case RXRPC_PACKET_TYPE_BUSY:
+	case RXRPC_PACKET_TYPE_ABORT:
+		BUG();
+
+		/* connection level events - also handled elsewhere */
+	case RXRPC_PACKET_TYPE_CHALLENGE:
+	case RXRPC_PACKET_TYPE_RESPONSE:
+	case RXRPC_PACKET_TYPE_DEBUG:
+		BUG();
+	}
+
+	/* if we've had a hard ACK that covers all the packets we've sent, then
+	 * that ends that phase of the operation */
+all_acked:
+	write_lock_bh(&call->state_lock);
+	_debug("ack all %d", call->state);
+
+	switch (call->state) {
+	case RXRPC_CALL_CLIENT_AWAIT_REPLY:
+		call->state = RXRPC_CALL_CLIENT_RECV_REPLY;
+		break;
+	case RXRPC_CALL_SERVER_AWAIT_ACK:
+		_debug("srv complete");
+		call->state = RXRPC_CALL_COMPLETE;
+		post_ACK = true;
+		break;
+	case RXRPC_CALL_CLIENT_SEND_REQUEST:
+	case RXRPC_CALL_SERVER_RECV_REQUEST:
+		goto protocol_error_unlock; /* can't occur yet */
+	default:
+		write_unlock_bh(&call->state_lock);
+		goto discard; /* assume packet left over from earlier phase */
+	}
+
+	write_unlock_bh(&call->state_lock);
+
+	/* if all the packets we sent are hard-ACK'd, then we can discard
+	 * whatever we've got left */
+	_debug("clear Tx %d",
+	       CIRC_CNT(call->acks_head, call->acks_tail, call->acks_winsz));
+
+	del_timer_sync(&call->resend_timer);
+	clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
+	clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events);
+
+	if (call->acks_window)
+		rxrpc_zap_tx_window(call);
+
+	if (post_ACK) {
+		/* post the final ACK message for userspace to pick up */
+		_debug("post ACK");
+		skb->mark = RXRPC_SKB_MARK_FINAL_ACK;
+		sp->call = call;
+		rxrpc_get_call(call);
+		spin_lock_bh(&call->lock);
+		if (rxrpc_queue_rcv_skb(call, skb, true, true) < 0)
+			BUG();
+		spin_unlock_bh(&call->lock);
+		goto process_further;
+	}
+
+discard:
+	rxrpc_free_skb(skb);
+	goto process_further;
+
+protocol_error_unlock:
+	write_unlock_bh(&call->state_lock);
+protocol_error:
+	rxrpc_free_skb(skb);
+	_leave(" = -EPROTO");
+	return -EPROTO;
+}
+
+/*
+ * post a message to the socket Rx queue for recvmsg() to pick up
+ */
+static int rxrpc_post_message(struct rxrpc_call *call, u32 mark, u32 error,
+			      bool fatal)
+{
+	struct rxrpc_skb_priv *sp;
+	struct sk_buff *skb;
+	int ret;
+
+	_enter("{%d,%lx},%u,%u,%d",
+	       call->debug_id, call->flags, mark, error, fatal);
+
+	/* remove timers and things for fatal messages */
+	if (fatal) {
+		del_timer_sync(&call->resend_timer);
+		del_timer_sync(&call->ack_timer);
+		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
+	}
+
+	if (mark != RXRPC_SKB_MARK_NEW_CALL &&
+	    !test_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
+		_leave("[no userid]");
+		return 0;
+	}
+
+	if (!test_bit(RXRPC_CALL_TERMINAL_MSG, &call->flags)) {
+		skb = alloc_skb(0, GFP_NOFS);
+		if (!skb)
+			return -ENOMEM;
+
+		rxrpc_new_skb(skb);
+
+		skb->mark = mark;
+
+		sp = rxrpc_skb(skb);
+		memset(sp, 0, sizeof(*sp));
+		sp->error = error;
+		sp->call = call;
+		rxrpc_get_call(call);
+
+		spin_lock_bh(&call->lock);
+		ret = rxrpc_queue_rcv_skb(call, skb, true, fatal);
+		spin_unlock_bh(&call->lock);
+		if (ret < 0)
+			BUG();
+	}
+
+	return 0;
+}
+
+/*
+ * handle background processing of incoming call packets and ACK / abort
+ * generation
+ */
+void rxrpc_process_call(struct work_struct *work)
+{
+	struct rxrpc_call *call =
+		container_of(work, struct rxrpc_call, processor);
+	struct rxrpc_ackpacket ack;
+	struct rxrpc_ackinfo ackinfo;
+	struct rxrpc_header hdr;
+	struct msghdr msg;
+	struct kvec iov[5];
+	unsigned long bits;
+	__be32 data;
+	size_t len;
+	int genbit, loop, nbit, ioc, ret;
+	u32 abort_code = RX_PROTOCOL_ERROR;
+	u8 *acks = NULL;
+
+	//printk("\n--------------------\n");
+	_enter("{%d,%s,%lx} [%lu]",
+	       call->debug_id, rxrpc_call_states[call->state], call->events,
+	       (jiffies - call->creation_jif) / (HZ / 10));
+
+	if (test_and_set_bit(RXRPC_CALL_PROC_BUSY, &call->flags)) {
+		_debug("XXXXXXXXXXXXX RUNNING ON MULTIPLE CPUS XXXXXXXXXXXXX");
+		return;
+	}
+
+	/* there's a good chance we're going to have to send a message, so set
+	 * one up in advance */
+	msg.msg_name	= &call->conn->trans->peer->srx.transport.sin;
+	msg.msg_namelen	= sizeof(call->conn->trans->peer->srx.transport.sin);
+	msg.msg_control	= NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags	= 0;
+
+	hdr.epoch	= call->conn->epoch;
+	hdr.cid		= call->cid;
+	hdr.callNumber	= call->call_id;
+	hdr.seq		= 0;
+	hdr.type	= RXRPC_PACKET_TYPE_ACK;
+	hdr.flags	= call->conn->out_clientflag;
+	hdr.userStatus	= 0;
+	hdr.securityIndex = call->conn->security_ix;
+	hdr._rsvd	= 0;
+	hdr.serviceId	= call->conn->service_id;
+
+	memset(iov, 0, sizeof(iov));
+	iov[0].iov_base	= &hdr;
+	iov[0].iov_len	= sizeof(hdr);
+
+	/* deal with events of a final nature */
+	if (test_bit(RXRPC_CALL_RELEASE, &call->events)) {
+		rxrpc_release_call(call);
+		clear_bit(RXRPC_CALL_RELEASE, &call->events);
+	}
+
+	if (test_bit(RXRPC_CALL_RCVD_ERROR, &call->events)) {
+		int error;
+
+		clear_bit(RXRPC_CALL_CONN_ABORT, &call->events);
+		clear_bit(RXRPC_CALL_REJECT_BUSY, &call->events);
+		clear_bit(RXRPC_CALL_ABORT, &call->events);
+
+		error = call->conn->trans->peer->net_error;
+		_debug("post net error %d", error);
+
+		if (rxrpc_post_message(call, RXRPC_SKB_MARK_NET_ERROR,
+				       error, true) < 0)
+			goto no_mem;
+		clear_bit(RXRPC_CALL_RCVD_ERROR, &call->events);
+		goto kill_ACKs;
+	}
+
+	if (test_bit(RXRPC_CALL_CONN_ABORT, &call->events)) {
+		ASSERTCMP(call->state, >, RXRPC_CALL_COMPLETE);
+
+		clear_bit(RXRPC_CALL_REJECT_BUSY, &call->events);
+		clear_bit(RXRPC_CALL_ABORT, &call->events);
+
+		_debug("post conn abort");
+
+		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
+				       call->conn->error, true) < 0)
+			goto no_mem;
+		clear_bit(RXRPC_CALL_CONN_ABORT, &call->events);
+		goto kill_ACKs;
+	}
+
+	if (test_bit(RXRPC_CALL_REJECT_BUSY, &call->events)) {
+		hdr.type = RXRPC_PACKET_TYPE_BUSY;
+		genbit = RXRPC_CALL_REJECT_BUSY;
+		goto send_message;
+	}
+
+	if (test_bit(RXRPC_CALL_ABORT, &call->events)) {
+		ASSERTCMP(call->state, >, RXRPC_CALL_COMPLETE);
+
+		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
+				       ECONNABORTED, true) < 0)
+			goto no_mem;
+		hdr.type = RXRPC_PACKET_TYPE_ABORT;
+		data = htonl(call->abort_code);
+		iov[1].iov_base = &data;
+		iov[1].iov_len = sizeof(data);
+		genbit = RXRPC_CALL_ABORT;
+		goto send_message;
+	}
+
+	if (test_bit(RXRPC_CALL_ACK_FINAL, &call->events)) {
+		hdr.type = RXRPC_PACKET_TYPE_ACKALL;
+		genbit = RXRPC_CALL_ACK_FINAL;
+		goto send_message;
+	}
+
+	if (call->events & ((1 << RXRPC_CALL_RCVD_BUSY) |
+			    (1 << RXRPC_CALL_RCVD_ABORT))
+	    ) {
+		u32 mark;
+
+		if (test_bit(RXRPC_CALL_RCVD_ABORT, &call->events))
+			mark = RXRPC_SKB_MARK_REMOTE_ABORT;
+		else
+			mark = RXRPC_SKB_MARK_BUSY;
+
+		_debug("post abort/busy");
+		rxrpc_clear_tx_window(call);
+		if (rxrpc_post_message(call, mark, ECONNABORTED, true) < 0)
+			goto no_mem;
+
+		clear_bit(RXRPC_CALL_RCVD_BUSY, &call->events);
+		clear_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
+		goto kill_ACKs;
+	}
+
+	if (test_and_clear_bit(RXRPC_CALL_RCVD_ACKALL, &call->events)) {
+		_debug("do implicit ackall");
+		rxrpc_clear_tx_window(call);
+	}
+
+	if (test_bit(RXRPC_CALL_LIFE_TIMER, &call->events)) {
+		write_lock_bh(&call->state_lock);
+		if (call->state <= RXRPC_CALL_COMPLETE) {
+			call->state = RXRPC_CALL_LOCALLY_ABORTED;
+			call->abort_code = RX_CALL_TIMEOUT;
+			set_bit(RXRPC_CALL_ABORT, &call->events);
+		}
+		write_unlock_bh(&call->state_lock);
+
+		_debug("post timeout");
+		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
+				       ETIME, true) < 0)
+			goto no_mem;
+
+		clear_bit(RXRPC_CALL_LIFE_TIMER, &call->events);
+		goto kill_ACKs;
+	}
+
+	/* deal with assorted inbound messages */
+	if (!skb_queue_empty(&call->rx_queue)) {
+		switch (rxrpc_process_rx_queue(call, &abort_code)) {
+		case 0:
+		case -EAGAIN:
+			break;
+		case -ENOMEM:
+			goto no_mem;
+		case -EKEYEXPIRED:
+		case -EKEYREJECTED:
+		case -EPROTO:
+			rxrpc_abort_call(call, abort_code);
+			goto kill_ACKs;
+		}
+	}
+
+	/* handle resending */
+	if (test_and_clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
+		rxrpc_resend_timer(call);
+	if (test_and_clear_bit(RXRPC_CALL_RESEND, &call->events))
+		rxrpc_resend(call);
+
+	/* consider sending an ordinary ACK */
+	if (test_bit(RXRPC_CALL_ACK, &call->events)) {
+		__be32 pad;
+
+		_debug("send ACK: window: %d - %d { %lx }",
+		       call->rx_data_eaten, call->ackr_win_top,
+		       call->ackr_window[0]);
+
+		if (call->state > RXRPC_CALL_SERVER_ACK_REQUEST &&
+		    call->ackr_reason != RXRPC_ACK_PING_RESPONSE) {
+			/* ACK by sending reply DATA packet in this state */
+			clear_bit(RXRPC_CALL_ACK, &call->events);
+			goto maybe_reschedule;
+		}
+
+		genbit = RXRPC_CALL_ACK;
+
+		acks = kzalloc(call->ackr_win_top - call->rx_data_eaten,
+			       GFP_NOFS);
+		if (!acks)
+			goto no_mem;
+
+		//hdr.flags	= RXRPC_SLOW_START_OK;
+		ack.bufferSpace	= htons(8);
+		ack.maxSkew	= 0;
+		ack.serial	= 0;
+		ack.reason	= 0;
+
+		ackinfo.rxMTU	= htonl(5692);
+//		ackinfo.rxMTU	= htonl(call->conn->trans->peer->maxdata);
+		ackinfo.maxMTU	= htonl(call->conn->trans->peer->maxdata);
+		ackinfo.rwind	= htonl(32);
+		ackinfo.jumbo_max = htonl(4);
+
+		spin_lock_bh(&call->lock);
+		ack.reason = call->ackr_reason;
+		ack.serial = call->ackr_serial;
+		ack.previousPacket = call->ackr_prev_seq;
+		ack.firstPacket = htonl(call->rx_data_eaten + 1);
+
+		ack.nAcks = 0;
+		for (loop = 0; loop < RXRPC_ACKR_WINDOW_ASZ; loop++) {
+			nbit = loop * BITS_PER_LONG;
+			for (bits = call->ackr_window[loop]; bits; bits >>= 1
+			     ) {
+				_debug("- l=%d n=%d b=%lx", loop, nbit, bits);
+				if (bits & 1) {
+					acks[nbit] = RXRPC_ACK_TYPE_ACK;
+					ack.nAcks = nbit + 1;
+				}
+				nbit++;
+			}
+		}
+		call->ackr_reason = 0;
+		spin_unlock_bh(&call->lock);
+
+		pad = 0;
+
+		iov[1].iov_base = &ack;
+		iov[1].iov_len	= sizeof(ack);
+		iov[2].iov_base = acks;
+		iov[2].iov_len	= ack.nAcks;
+		iov[3].iov_base = &pad;
+		iov[3].iov_len	= 3;
+		iov[4].iov_base = &ackinfo;
+		iov[4].iov_len	= sizeof(ackinfo);
+
+		switch (ack.reason) {
+		case RXRPC_ACK_REQUESTED:
+		case RXRPC_ACK_DUPLICATE:
+		case RXRPC_ACK_OUT_OF_SEQUENCE:
+		case RXRPC_ACK_EXCEEDS_WINDOW:
+		case RXRPC_ACK_NOSPACE:
+		case RXRPC_ACK_PING:
+		case RXRPC_ACK_PING_RESPONSE:
+			goto send_ACK_with_skew;
+		case RXRPC_ACK_DELAY:
+		case RXRPC_ACK_IDLE:
+			goto send_ACK;
+		}
+	}
+
+	/* handle completion of security negotiations on an incoming
+	 * connection */
+	if (test_and_clear_bit(RXRPC_CALL_SECURED, &call->events)) {
+		_debug("secured");
+		spin_lock_bh(&call->lock);
+
+		if (call->state == RXRPC_CALL_SERVER_SECURING) {
+			_debug("securing");
+			write_lock(&call->conn->lock);
+			if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
+			    !test_bit(RXRPC_CALL_RELEASE, &call->events)) {
+				_debug("not released");
+				call->state = RXRPC_CALL_SERVER_ACCEPTING;
+				list_move_tail(&call->accept_link,
+					       &call->socket->acceptq);
+			}
+			write_unlock(&call->conn->lock);
+			read_lock(&call->state_lock);
+			if (call->state < RXRPC_CALL_COMPLETE)
+				set_bit(RXRPC_CALL_POST_ACCEPT, &call->events);
+			read_unlock(&call->state_lock);
+		}
+
+		spin_unlock_bh(&call->lock);
+		if (!test_bit(RXRPC_CALL_POST_ACCEPT, &call->events))
+			goto maybe_reschedule;
+	}
+
+	/* post a notification of an acceptable connection to the app */
+	if (test_bit(RXRPC_CALL_POST_ACCEPT, &call->events)) {
+		_debug("post accept");
+		if (rxrpc_post_message(call, RXRPC_SKB_MARK_NEW_CALL,
+				       0, false) < 0)
+			goto no_mem;
+		clear_bit(RXRPC_CALL_POST_ACCEPT, &call->events);
+		goto maybe_reschedule;
+	}
+
+	/* handle incoming call acceptance */
+	if (test_and_clear_bit(RXRPC_CALL_ACCEPTED, &call->events)) {
+		_debug("accepted");
+		ASSERTCMP(call->rx_data_post, ==, 0);
+		call->rx_data_post = 1;
+		read_lock_bh(&call->state_lock);
+		if (call->state < RXRPC_CALL_COMPLETE)
+			set_bit(RXRPC_CALL_DRAIN_RX_OOS, &call->events);
+		read_unlock_bh(&call->state_lock);
+	}
+
+	/* drain the out of sequence received packet queue into the packet Rx
+	 * queue */
+	if (test_and_clear_bit(RXRPC_CALL_DRAIN_RX_OOS, &call->events)) {
+		while (call->rx_data_post == call->rx_first_oos)
+			if (rxrpc_drain_rx_oos_queue(call) < 0)
+				break;
+		goto maybe_reschedule;
+	}
+
+	/* other events may have been raised since we started checking */
+	goto maybe_reschedule;
+
+send_ACK_with_skew:
+	ack.maxSkew = htons(atomic_read(&call->conn->hi_serial) -
+			    ntohl(ack.serial));
+send_ACK:
+	hdr.serial = htonl(atomic_inc_return(&call->conn->serial));
+	_proto("Tx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
+	       ntohl(hdr.serial),
+	       ntohs(ack.maxSkew),
+	       ntohl(ack.firstPacket),
+	       ntohl(ack.previousPacket),
+	       ntohl(ack.serial),
+	       rxrpc_acks[ack.reason],
+	       ack.nAcks);
+
+	del_timer_sync(&call->ack_timer);
+	if (ack.nAcks > 0)
+		set_bit(RXRPC_CALL_TX_SOFT_ACK, &call->flags);
+	goto send_message_2;
+
+send_message:
+	_debug("send message");
+
+	hdr.serial = htonl(atomic_inc_return(&call->conn->serial));
+	_proto("Tx %s %%%u", rxrpc_pkts[hdr.type], ntohl(hdr.serial));
+send_message_2:
+
+	len = iov[0].iov_len;
+	ioc = 1;
+	if (iov[4].iov_len) {
+		ioc = 5;
+		len += iov[4].iov_len;
+		len += iov[3].iov_len;
+		len += iov[2].iov_len;
+		len += iov[1].iov_len;
+	} else if (iov[3].iov_len) {
+		ioc = 4;
+		len += iov[3].iov_len;
+		len += iov[2].iov_len;
+		len += iov[1].iov_len;
+	} else if (iov[2].iov_len) {
+		ioc = 3;
+		len += iov[2].iov_len;
+		len += iov[1].iov_len;
+	} else if (iov[1].iov_len) {
+		ioc = 2;
+		len += iov[1].iov_len;
+	}
+
+	ret = kernel_sendmsg(call->conn->trans->local->socket,
+			     &msg, iov, ioc, len);
+	if (ret < 0) {
+		_debug("sendmsg failed: %d", ret);
+		read_lock_bh(&call->state_lock);
+		if (call->state < RXRPC_CALL_DEAD)
+			schedule_work(&call->processor);
+		read_unlock_bh(&call->state_lock);
+		goto error;
+	}
+
+	switch (genbit) {
+	case RXRPC_CALL_ABORT:
+		clear_bit(genbit, &call->events);
+		clear_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
+		goto kill_ACKs;
+
+	case RXRPC_CALL_ACK_FINAL:
+		write_lock_bh(&call->state_lock);
+		if (call->state == RXRPC_CALL_CLIENT_FINAL_ACK)
+			call->state = RXRPC_CALL_COMPLETE;
+		write_unlock_bh(&call->state_lock);
+		goto kill_ACKs;
+
+	default:
+		clear_bit(genbit, &call->events);
+		switch (call->state) {
+		case RXRPC_CALL_CLIENT_AWAIT_REPLY:
+		case RXRPC_CALL_CLIENT_RECV_REPLY:
+		case RXRPC_CALL_SERVER_RECV_REQUEST:
+		case RXRPC_CALL_SERVER_ACK_REQUEST:
+			_debug("start ACK timer");
+			rxrpc_propose_ACK(call, RXRPC_ACK_DELAY,
+					  call->ackr_serial, false);
+		default:
+			break;
+		}
+		goto maybe_reschedule;
+	}
+
+kill_ACKs:
+	del_timer_sync(&call->ack_timer);
+	if (test_and_clear_bit(RXRPC_CALL_ACK_FINAL, &call->events))
+		rxrpc_put_call(call);
+	clear_bit(RXRPC_CALL_ACK, &call->events);
+
+maybe_reschedule:
+	if (call->events || !skb_queue_empty(&call->rx_queue)) {
+		read_lock_bh(&call->state_lock);
+		if (call->state < RXRPC_CALL_DEAD)
+			schedule_work(&call->processor);
+		read_unlock_bh(&call->state_lock);
+	}
+
+	/* don't leave aborted connections on the accept queue */
+	if (call->state >= RXRPC_CALL_COMPLETE &&
+	    !list_empty(&call->accept_link)) {
+		_debug("X unlinking once-pending call %p { e=%lx f=%lx c=%x }",
+		       call, call->events, call->flags,
+		       ntohl(call->conn->cid));
+
+		read_lock_bh(&call->state_lock);
+		if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
+		    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+			schedule_work(&call->processor);
+		read_unlock_bh(&call->state_lock);
+	}
+
+error:
+	clear_bit(RXRPC_CALL_PROC_BUSY, &call->flags);
+	kfree(acks);
+
+	/* because we don't want two CPUs both processing the work item for one
+	 * call at the same time, we use a flag to note when it's busy; however
+	 * this means there's a race between clearing the flag and setting the
+	 * work pending bit and the work item being processed again */
+	if (call->events && !work_pending(&call->processor)) {
+		_debug("jumpstart %x", ntohl(call->conn->cid));
+		schedule_work(&call->processor);
+	}
+
+	_leave("");
+	return;
+
+no_mem:
+	_debug("out of memory");
+	goto maybe_reschedule;
+}
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
new file mode 100644
index 0000000..ac31cce
--- /dev/null
+++ b/net/rxrpc/ar-call.c
@@ -0,0 +1,787 @@
+/* RxRPC individual remote procedure call handling
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/circ_buf.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+struct kmem_cache *rxrpc_call_jar;
+LIST_HEAD(rxrpc_calls);
+DEFINE_RWLOCK(rxrpc_call_lock);
+static unsigned rxrpc_call_max_lifetime = 60;
+static unsigned rxrpc_dead_call_timeout = 10;
+
+static void rxrpc_destroy_call(struct work_struct *work);
+static void rxrpc_call_life_expired(unsigned long _call);
+static void rxrpc_dead_call_expired(unsigned long _call);
+static void rxrpc_ack_time_expired(unsigned long _call);
+static void rxrpc_resend_time_expired(unsigned long _call);
+
+/*
+ * allocate a new call
+ */
+static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
+{
+	struct rxrpc_call *call;
+
+	call = kmem_cache_zalloc(rxrpc_call_jar, gfp);
+	if (!call)
+		return NULL;
+
+	call->acks_winsz = 16;
+	call->acks_window = kmalloc(call->acks_winsz * sizeof(unsigned long),
+				    gfp);
+	if (!call->acks_window) {
+		kmem_cache_free(rxrpc_call_jar, call);
+		return NULL;
+	}
+
+	setup_timer(&call->lifetimer, &rxrpc_call_life_expired,
+		    (unsigned long) call);
+	setup_timer(&call->deadspan, &rxrpc_dead_call_expired,
+		    (unsigned long) call);
+	setup_timer(&call->ack_timer, &rxrpc_ack_time_expired,
+		    (unsigned long) call);
+	setup_timer(&call->resend_timer, &rxrpc_resend_time_expired,
+		    (unsigned long) call);
+	INIT_WORK(&call->destroyer, &rxrpc_destroy_call);
+	INIT_WORK(&call->processor, &rxrpc_process_call);
+	INIT_LIST_HEAD(&call->accept_link);
+	skb_queue_head_init(&call->rx_queue);
+	skb_queue_head_init(&call->rx_oos_queue);
+	init_waitqueue_head(&call->tx_waitq);
+	spin_lock_init(&call->lock);
+	rwlock_init(&call->state_lock);
+	atomic_set(&call->usage, 1);
+	call->debug_id = atomic_inc_return(&rxrpc_debug_id);
+	call->state = RXRPC_CALL_CLIENT_SEND_REQUEST;
+
+	memset(&call->sock_node, 0xed, sizeof(call->sock_node));
+
+	call->rx_data_expect = 1;
+	call->rx_data_eaten = 0;
+	call->rx_first_oos = 0;
+	call->ackr_win_top = call->rx_data_eaten + 1 + RXRPC_MAXACKS;
+	call->creation_jif = jiffies;
+	return call;
+}
+
+/*
+ * allocate a new client call and attempt to to get a connection slot for it
+ */
+static struct rxrpc_call *rxrpc_alloc_client_call(
+	struct rxrpc_sock *rx,
+	struct rxrpc_transport *trans,
+	struct rxrpc_conn_bundle *bundle,
+	gfp_t gfp)
+{
+	struct rxrpc_call *call;
+	int ret;
+
+	_enter("");
+
+	ASSERT(rx != NULL);
+	ASSERT(trans != NULL);
+	ASSERT(bundle != NULL);
+
+	call = rxrpc_alloc_call(gfp);
+	if (!call)
+		return ERR_PTR(-ENOMEM);
+
+	sock_hold(&rx->sk);
+	call->socket = rx;
+	call->rx_data_post = 1;
+
+	ret = rxrpc_connect_call(rx, trans, bundle, call, gfp);
+	if (ret < 0) {
+		kmem_cache_free(rxrpc_call_jar, call);
+		return ERR_PTR(ret);
+	}
+
+	spin_lock(&call->conn->trans->peer->lock);
+	list_add(&call->error_link, &call->conn->trans->peer->error_targets);
+	spin_unlock(&call->conn->trans->peer->lock);
+
+	call->lifetimer.expires = jiffies + rxrpc_call_max_lifetime * HZ;
+	add_timer(&call->lifetimer);
+
+	_leave(" = %p", call);
+	return call;
+}
+
+/*
+ * set up a call for the given data
+ * - called in process context with IRQs enabled
+ */
+struct rxrpc_call *rxrpc_get_client_call(struct rxrpc_sock *rx,
+					 struct rxrpc_transport *trans,
+					 struct rxrpc_conn_bundle *bundle,
+					 unsigned long user_call_ID,
+					 int create,
+					 gfp_t gfp)
+{
+	struct rxrpc_call *call, *candidate;
+	struct rb_node *p, *parent, **pp;
+
+	_enter("%p,%d,%d,%lx,%d",
+	       rx, trans ? trans->debug_id : -1, bundle ? bundle->debug_id : -1,
+	       user_call_ID, create);
+
+	/* search the extant calls first for one that matches the specified
+	 * user ID */
+	read_lock(&rx->call_lock);
+
+	p = rx->calls.rb_node;
+	while (p) {
+		call = rb_entry(p, struct rxrpc_call, sock_node);
+
+		if (user_call_ID < call->user_call_ID)
+			p = p->rb_left;
+		else if (user_call_ID > call->user_call_ID)
+			p = p->rb_right;
+		else
+			goto found_extant_call;
+	}
+
+	read_unlock(&rx->call_lock);
+
+	if (!create || !trans)
+		return ERR_PTR(-EBADSLT);
+
+	/* not yet present - create a candidate for a new record and then
+	 * redo the search */
+	candidate = rxrpc_alloc_client_call(rx, trans, bundle, gfp);
+	if (IS_ERR(candidate)) {
+		_leave(" = %ld", PTR_ERR(candidate));
+		return candidate;
+	}
+
+	candidate->user_call_ID = user_call_ID;
+	__set_bit(RXRPC_CALL_HAS_USERID, &candidate->flags);
+
+	write_lock(&rx->call_lock);
+
+	pp = &rx->calls.rb_node;
+	parent = NULL;
+	while (*pp) {
+		parent = *pp;
+		call = rb_entry(parent, struct rxrpc_call, sock_node);
+
+		if (user_call_ID < call->user_call_ID)
+			pp = &(*pp)->rb_left;
+		else if (user_call_ID > call->user_call_ID)
+			pp = &(*pp)->rb_right;
+		else
+			goto found_extant_second;
+	}
+
+	/* second search also failed; add the new call */
+	call = candidate;
+	candidate = NULL;
+	rxrpc_get_call(call);
+
+	rb_link_node(&call->sock_node, parent, pp);
+	rb_insert_color(&call->sock_node, &rx->calls);
+	write_unlock(&rx->call_lock);
+
+	write_lock_bh(&rxrpc_call_lock);
+	list_add_tail(&call->link, &rxrpc_calls);
+	write_unlock_bh(&rxrpc_call_lock);
+
+	_net("CALL new %d on CONN %d", call->debug_id, call->conn->debug_id);
+
+	_leave(" = %p [new]", call);
+	return call;
+
+	/* we found the call in the list immediately */
+found_extant_call:
+	rxrpc_get_call(call);
+	read_unlock(&rx->call_lock);
+	_leave(" = %p [extant %d]", call, atomic_read(&call->usage));
+	return call;
+
+	/* we found the call on the second time through the list */
+found_extant_second:
+	rxrpc_get_call(call);
+	write_unlock(&rx->call_lock);
+	rxrpc_put_call(candidate);
+	_leave(" = %p [second %d]", call, atomic_read(&call->usage));
+	return call;
+}
+
+/*
+ * set up an incoming call
+ * - called in process context with IRQs enabled
+ */
+struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
+				       struct rxrpc_connection *conn,
+				       struct rxrpc_header *hdr,
+				       gfp_t gfp)
+{
+	struct rxrpc_call *call, *candidate;
+	struct rb_node **p, *parent;
+	__be32 call_id;
+
+	_enter(",%d,,%x", conn->debug_id, gfp);
+
+	ASSERT(rx != NULL);
+
+	candidate = rxrpc_alloc_call(gfp);
+	if (!candidate)
+		return ERR_PTR(-EBUSY);
+
+	candidate->socket = rx;
+	candidate->conn = conn;
+	candidate->cid = hdr->cid;
+	candidate->call_id = hdr->callNumber;
+	candidate->channel = ntohl(hdr->cid) & RXRPC_CHANNELMASK;
+	candidate->rx_data_post = 0;
+	candidate->state = RXRPC_CALL_SERVER_ACCEPTING;
+	if (conn->security_ix > 0)
+		candidate->state = RXRPC_CALL_SERVER_SECURING;
+
+	write_lock_bh(&conn->lock);
+
+	/* set the channel for this call */
+	call = conn->channels[candidate->channel];
+	_debug("channel[%u] is %p", candidate->channel, call);
+	if (call && call->call_id == hdr->callNumber) {
+		/* already set; must've been a duplicate packet */
+		_debug("extant call [%d]", call->state);
+		ASSERTCMP(call->conn, ==, conn);
+
+		read_lock(&call->state_lock);
+		switch (call->state) {
+		case RXRPC_CALL_LOCALLY_ABORTED:
+			if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events))
+				schedule_work(&call->processor);
+		case RXRPC_CALL_REMOTELY_ABORTED:
+			read_unlock(&call->state_lock);
+			goto aborted_call;
+		default:
+			rxrpc_get_call(call);
+			read_unlock(&call->state_lock);
+			goto extant_call;
+		}
+	}
+
+	if (call) {
+		/* it seems the channel is still in use from the previous call
+		 * - ditch the old binding if its call is now complete */
+		_debug("CALL: %u { %s }",
+		       call->debug_id, rxrpc_call_states[call->state]);
+
+		if (call->state >= RXRPC_CALL_COMPLETE) {
+			conn->channels[call->channel] = NULL;
+		} else {
+			write_unlock_bh(&conn->lock);
+			kmem_cache_free(rxrpc_call_jar, candidate);
+			_leave(" = -EBUSY");
+			return ERR_PTR(-EBUSY);
+		}
+	}
+
+	/* check the call number isn't duplicate */
+	_debug("check dup");
+	call_id = hdr->callNumber;
+	p = &conn->calls.rb_node;
+	parent = NULL;
+	while (*p) {
+		parent = *p;
+		call = rb_entry(parent, struct rxrpc_call, conn_node);
+
+		if (call_id < call->call_id)
+			p = &(*p)->rb_left;
+		else if (call_id > call->call_id)
+			p = &(*p)->rb_right;
+		else
+			goto old_call;
+	}
+
+	/* make the call available */
+	_debug("new call");
+	call = candidate;
+	candidate = NULL;
+	rb_link_node(&call->conn_node, parent, p);
+	rb_insert_color(&call->conn_node, &conn->calls);
+	conn->channels[call->channel] = call;
+	sock_hold(&rx->sk);
+	atomic_inc(&conn->usage);
+	write_unlock_bh(&conn->lock);
+
+	spin_lock(&conn->trans->peer->lock);
+	list_add(&call->error_link, &conn->trans->peer->error_targets);
+	spin_unlock(&conn->trans->peer->lock);
+
+	write_lock_bh(&rxrpc_call_lock);
+	list_add_tail(&call->link, &rxrpc_calls);
+	write_unlock_bh(&rxrpc_call_lock);
+
+	_net("CALL incoming %d on CONN %d", call->debug_id, call->conn->debug_id);
+
+	call->lifetimer.expires = jiffies + rxrpc_call_max_lifetime * HZ;
+	add_timer(&call->lifetimer);
+	_leave(" = %p {%d} [new]", call, call->debug_id);
+	return call;
+
+extant_call:
+	write_unlock_bh(&conn->lock);
+	kmem_cache_free(rxrpc_call_jar, candidate);
+	_leave(" = %p {%d} [extant]", call, call ? call->debug_id : -1);
+	return call;
+
+aborted_call:
+	write_unlock_bh(&conn->lock);
+	kmem_cache_free(rxrpc_call_jar, candidate);
+	_leave(" = -ECONNABORTED");
+	return ERR_PTR(-ECONNABORTED);
+
+old_call:
+	write_unlock_bh(&conn->lock);
+	kmem_cache_free(rxrpc_call_jar, candidate);
+	_leave(" = -ECONNRESET [old]");
+	return ERR_PTR(-ECONNRESET);
+}
+
+/*
+ * find an extant server call
+ * - called in process context with IRQs enabled
+ */
+struct rxrpc_call *rxrpc_find_server_call(struct rxrpc_sock *rx,
+					  unsigned long user_call_ID)
+{
+	struct rxrpc_call *call;
+	struct rb_node *p;
+
+	_enter("%p,%lx", rx, user_call_ID);
+
+	/* search the extant calls for one that matches the specified user
+	 * ID */
+	read_lock(&rx->call_lock);
+
+	p = rx->calls.rb_node;
+	while (p) {
+		call = rb_entry(p, struct rxrpc_call, sock_node);
+
+		if (user_call_ID < call->user_call_ID)
+			p = p->rb_left;
+		else if (user_call_ID > call->user_call_ID)
+			p = p->rb_right;
+		else
+			goto found_extant_call;
+	}
+
+	read_unlock(&rx->call_lock);
+	_leave(" = NULL");
+	return NULL;
+
+	/* we found the call in the list immediately */
+found_extant_call:
+	rxrpc_get_call(call);
+	read_unlock(&rx->call_lock);
+	_leave(" = %p [%d]", call, atomic_read(&call->usage));
+	return call;
+}
+
+/*
+ * detach a call from a socket and set up for release
+ */
+void rxrpc_release_call(struct rxrpc_call *call)
+{
+	struct rxrpc_sock *rx = call->socket;
+
+	_enter("{%d,%d,%d,%d}",
+	       call->debug_id, atomic_read(&call->usage),
+	       atomic_read(&call->ackr_not_idle),
+	       call->rx_first_oos);
+
+	spin_lock_bh(&call->lock);
+	if (test_and_set_bit(RXRPC_CALL_RELEASED, &call->flags))
+		BUG();
+	spin_unlock_bh(&call->lock);
+
+	/* dissociate from the socket
+	 * - the socket's ref on the call is passed to the death timer
+	 */
+	_debug("RELEASE CALL %p (%d CONN %p)",
+	       call, call->debug_id, call->conn);
+
+	write_lock_bh(&rx->call_lock);
+	if (!list_empty(&call->accept_link)) {
+		_debug("unlinking once-pending call %p { e=%lx f=%lx }",
+		       call, call->events, call->flags);
+		ASSERT(!test_bit(RXRPC_CALL_HAS_USERID, &call->flags));
+		list_del_init(&call->accept_link);
+		sk_acceptq_removed(&rx->sk);
+	} else if (test_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
+		rb_erase(&call->sock_node, &rx->calls);
+		memset(&call->sock_node, 0xdd, sizeof(call->sock_node));
+		clear_bit(RXRPC_CALL_HAS_USERID, &call->flags);
+	}
+	write_unlock_bh(&rx->call_lock);
+
+	if (call->conn->out_clientflag)
+		spin_lock(&call->conn->trans->client_lock);
+	write_lock_bh(&call->conn->lock);
+
+	/* free up the channel for reuse */
+	if (call->conn->out_clientflag) {
+		call->conn->avail_calls++;
+		if (call->conn->avail_calls == RXRPC_MAXCALLS)
+			list_move_tail(&call->conn->bundle_link,
+				       &call->conn->bundle->unused_conns);
+		else if (call->conn->avail_calls == 1)
+			list_move_tail(&call->conn->bundle_link,
+				       &call->conn->bundle->avail_conns);
+	}
+
+	write_lock(&call->state_lock);
+	if (call->conn->channels[call->channel] == call)
+		call->conn->channels[call->channel] = NULL;
+
+	if (call->state < RXRPC_CALL_COMPLETE &&
+	    call->state != RXRPC_CALL_CLIENT_FINAL_ACK) {
+		_debug("+++ ABORTING STATE %d +++\n", call->state);
+		call->state = RXRPC_CALL_LOCALLY_ABORTED;
+		call->abort_code = RX_CALL_DEAD;
+		set_bit(RXRPC_CALL_ABORT, &call->events);
+		schedule_work(&call->processor);
+	}
+	write_unlock(&call->state_lock);
+	write_unlock_bh(&call->conn->lock);
+	if (call->conn->out_clientflag)
+		spin_unlock(&call->conn->trans->client_lock);
+
+	if (!skb_queue_empty(&call->rx_queue) ||
+	    !skb_queue_empty(&call->rx_oos_queue)) {
+		struct rxrpc_skb_priv *sp;
+		struct sk_buff *skb;
+
+		_debug("purge Rx queues");
+
+		spin_lock_bh(&call->lock);
+		while ((skb = skb_dequeue(&call->rx_queue)) ||
+		       (skb = skb_dequeue(&call->rx_oos_queue))) {
+			sp = rxrpc_skb(skb);
+			if (sp->call) {
+				ASSERTCMP(sp->call, ==, call);
+				rxrpc_put_call(call);
+				sp->call = NULL;
+			}
+			skb->destructor = NULL;
+			spin_unlock_bh(&call->lock);
+
+			_debug("- zap %s %%%u #%u",
+			       rxrpc_pkts[sp->hdr.type],
+			       ntohl(sp->hdr.serial),
+			       ntohl(sp->hdr.seq));
+			rxrpc_free_skb(skb);
+			spin_lock_bh(&call->lock);
+		}
+		spin_unlock_bh(&call->lock);
+
+		ASSERTCMP(call->state, !=, RXRPC_CALL_COMPLETE);
+	}
+
+	del_timer_sync(&call->resend_timer);
+	del_timer_sync(&call->ack_timer);
+	del_timer_sync(&call->lifetimer);
+	call->deadspan.expires = jiffies + rxrpc_dead_call_timeout * HZ;
+	add_timer(&call->deadspan);
+
+	_leave("");
+}
+
+/*
+ * handle a dead call being ready for reaping
+ */
+static void rxrpc_dead_call_expired(unsigned long _call)
+{
+	struct rxrpc_call *call = (struct rxrpc_call *) _call;
+
+	_enter("{%d}", call->debug_id);
+
+	write_lock_bh(&call->state_lock);
+	call->state = RXRPC_CALL_DEAD;
+	write_unlock_bh(&call->state_lock);
+	rxrpc_put_call(call);
+}
+
+/*
+ * mark a call as to be released, aborting it if it's still in progress
+ * - called with softirqs disabled
+ */
+static void rxrpc_mark_call_released(struct rxrpc_call *call)
+{
+	bool sched;
+
+	write_lock(&call->state_lock);
+	if (call->state < RXRPC_CALL_DEAD) {
+		sched = false;
+		if (call->state < RXRPC_CALL_COMPLETE) {
+			_debug("abort call %p", call);
+			call->state = RXRPC_CALL_LOCALLY_ABORTED;
+			call->abort_code = RX_CALL_DEAD;
+			if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events))
+				sched = true;
+		}
+		if (!test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+			sched = true;
+		if (sched)
+			schedule_work(&call->processor);
+	}
+	write_unlock(&call->state_lock);
+}
+
+/*
+ * release all the calls associated with a socket
+ */
+void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
+{
+	struct rxrpc_call *call;
+	struct rb_node *p;
+
+	_enter("%p", rx);
+
+	read_lock_bh(&rx->call_lock);
+
+	/* mark all the calls as no longer wanting incoming packets */
+	for (p = rb_first(&rx->calls); p; p = rb_next(p)) {
+		call = rb_entry(p, struct rxrpc_call, sock_node);
+		rxrpc_mark_call_released(call);
+	}
+
+	/* kill the not-yet-accepted incoming calls */
+	list_for_each_entry(call, &rx->secureq, accept_link) {
+		rxrpc_mark_call_released(call);
+	}
+
+	list_for_each_entry(call, &rx->acceptq, accept_link) {
+		rxrpc_mark_call_released(call);
+	}
+
+	read_unlock_bh(&rx->call_lock);
+	_leave("");
+}
+
+/*
+ * release a call
+ */
+void __rxrpc_put_call(struct rxrpc_call *call)
+{
+	ASSERT(call != NULL);
+
+	_enter("%p{u=%d}", call, atomic_read(&call->usage));
+
+	ASSERTCMP(atomic_read(&call->usage), >, 0);
+
+	if (atomic_dec_and_test(&call->usage)) {
+		_debug("call %d dead", call->debug_id);
+		ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
+		schedule_work(&call->destroyer);
+	}
+	_leave("");
+}
+
+/*
+ * clean up a call
+ */
+static void rxrpc_cleanup_call(struct rxrpc_call *call)
+{
+	_net("DESTROY CALL %d", call->debug_id);
+
+	ASSERT(call->socket);
+
+	memset(&call->sock_node, 0xcd, sizeof(call->sock_node));
+
+	del_timer_sync(&call->lifetimer);
+	del_timer_sync(&call->deadspan);
+	del_timer_sync(&call->ack_timer);
+	del_timer_sync(&call->resend_timer);
+
+	ASSERT(test_bit(RXRPC_CALL_RELEASED, &call->flags));
+	ASSERTCMP(call->events, ==, 0);
+	if (work_pending(&call->processor)) {
+		_debug("defer destroy");
+		schedule_work(&call->destroyer);
+		return;
+	}
+
+	if (call->conn) {
+		spin_lock(&call->conn->trans->peer->lock);
+		list_del(&call->error_link);
+		spin_unlock(&call->conn->trans->peer->lock);
+
+		write_lock_bh(&call->conn->lock);
+		rb_erase(&call->conn_node, &call->conn->calls);
+		write_unlock_bh(&call->conn->lock);
+		rxrpc_put_connection(call->conn);
+	}
+
+	if (call->acks_window) {
+		_debug("kill Tx window %d",
+		       CIRC_CNT(call->acks_head, call->acks_tail,
+				call->acks_winsz));
+		smp_mb();
+		while (CIRC_CNT(call->acks_head, call->acks_tail,
+				call->acks_winsz) > 0) {
+			struct rxrpc_skb_priv *sp;
+			unsigned long _skb;
+
+			_skb = call->acks_window[call->acks_tail] & ~1;
+			sp = rxrpc_skb((struct sk_buff *) _skb);
+			_debug("+++ clear Tx %u", ntohl(sp->hdr.seq));
+			rxrpc_free_skb((struct sk_buff *) _skb);
+			call->acks_tail =
+				(call->acks_tail + 1) & (call->acks_winsz - 1);
+		}
+
+		kfree(call->acks_window);
+	}
+
+	rxrpc_free_skb(call->tx_pending);
+
+	rxrpc_purge_queue(&call->rx_queue);
+	ASSERT(skb_queue_empty(&call->rx_oos_queue));
+	sock_put(&call->socket->sk);
+	kmem_cache_free(rxrpc_call_jar, call);
+}
+
+/*
+ * destroy a call
+ */
+static void rxrpc_destroy_call(struct work_struct *work)
+{
+	struct rxrpc_call *call =
+		container_of(work, struct rxrpc_call, destroyer);
+
+	_enter("%p{%d,%d,%p}",
+	       call, atomic_read(&call->usage), call->channel, call->conn);
+
+	ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
+
+	write_lock_bh(&rxrpc_call_lock);
+	list_del_init(&call->link);
+	write_unlock_bh(&rxrpc_call_lock);
+
+	rxrpc_cleanup_call(call);
+	_leave("");
+}
+
+/*
+ * preemptively destroy all the call records from a transport endpoint rather
+ * than waiting for them to time out
+ */
+void __exit rxrpc_destroy_all_calls(void)
+{
+	struct rxrpc_call *call;
+
+	_enter("");
+	write_lock_bh(&rxrpc_call_lock);
+
+	while (!list_empty(&rxrpc_calls)) {
+		call = list_entry(rxrpc_calls.next, struct rxrpc_call, link);
+		_debug("Zapping call %p", call);
+
+		list_del_init(&call->link);
+
+		switch (atomic_read(&call->usage)) {
+		case 0:
+			ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
+			break;
+		case 1:
+			if (del_timer_sync(&call->deadspan) != 0 &&
+			    call->state != RXRPC_CALL_DEAD)
+				rxrpc_dead_call_expired((unsigned long) call);
+			if (call->state != RXRPC_CALL_DEAD)
+				break;
+		default:
+			printk(KERN_ERR "RXRPC:"
+			       " Call %p still in use (%d,%d,%s,%lx,%lx)!\n",
+			       call, atomic_read(&call->usage),
+			       atomic_read(&call->ackr_not_idle),
+			       rxrpc_call_states[call->state],
+			       call->flags, call->events);
+			if (!skb_queue_empty(&call->rx_queue))
+				printk(KERN_ERR"RXRPC: Rx queue occupied\n");
+			if (!skb_queue_empty(&call->rx_oos_queue))
+				printk(KERN_ERR"RXRPC: OOS queue occupied\n");
+			break;
+		}
+
+		write_unlock_bh(&rxrpc_call_lock);
+		cond_resched();
+		write_lock_bh(&rxrpc_call_lock);
+	}
+
+	write_unlock_bh(&rxrpc_call_lock);
+	_leave("");
+}
+
+/*
+ * handle call lifetime being exceeded
+ */
+static void rxrpc_call_life_expired(unsigned long _call)
+{
+	struct rxrpc_call *call = (struct rxrpc_call *) _call;
+
+	if (call->state >= RXRPC_CALL_COMPLETE)
+		return;
+
+	_enter("{%d}", call->debug_id);
+	read_lock_bh(&call->state_lock);
+	if (call->state < RXRPC_CALL_COMPLETE) {
+		set_bit(RXRPC_CALL_LIFE_TIMER, &call->events);
+		schedule_work(&call->processor);
+	}
+	read_unlock_bh(&call->state_lock);
+}
+
+/*
+ * handle resend timer expiry
+ */
+static void rxrpc_resend_time_expired(unsigned long _call)
+{
+	struct rxrpc_call *call = (struct rxrpc_call *) _call;
+
+	_enter("{%d}", call->debug_id);
+
+	if (call->state >= RXRPC_CALL_COMPLETE)
+		return;
+
+	read_lock_bh(&call->state_lock);
+	clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
+	if (call->state < RXRPC_CALL_COMPLETE &&
+	    !test_and_set_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
+		schedule_work(&call->processor);
+	read_unlock_bh(&call->state_lock);
+}
+
+/*
+ * handle ACK timer expiry
+ */
+static void rxrpc_ack_time_expired(unsigned long _call)
+{
+	struct rxrpc_call *call = (struct rxrpc_call *) _call;
+
+	_enter("{%d}", call->debug_id);
+
+	if (call->state >= RXRPC_CALL_COMPLETE)
+		return;
+
+	read_lock_bh(&call->state_lock);
+	if (call->state < RXRPC_CALL_COMPLETE &&
+	    !test_and_set_bit(RXRPC_CALL_ACK, &call->events))
+		schedule_work(&call->processor);
+	read_unlock_bh(&call->state_lock);
+}
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
new file mode 100644
index 0000000..01eb33c
--- /dev/null
+++ b/net/rxrpc/ar-connection.c
@@ -0,0 +1,895 @@
+/* RxRPC virtual connection handler
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/crypto.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+static void rxrpc_connection_reaper(struct work_struct *work);
+
+LIST_HEAD(rxrpc_connections);
+DEFINE_RWLOCK(rxrpc_connection_lock);
+static unsigned long rxrpc_connection_timeout = 10 * 60;
+static DECLARE_DELAYED_WORK(rxrpc_connection_reap, rxrpc_connection_reaper);
+
+/*
+ * allocate a new client connection bundle
+ */
+static struct rxrpc_conn_bundle *rxrpc_alloc_bundle(gfp_t gfp)
+{
+	struct rxrpc_conn_bundle *bundle;
+
+	_enter("");
+
+	bundle = kzalloc(sizeof(struct rxrpc_conn_bundle), gfp);
+	if (bundle) {
+		INIT_LIST_HEAD(&bundle->unused_conns);
+		INIT_LIST_HEAD(&bundle->avail_conns);
+		INIT_LIST_HEAD(&bundle->busy_conns);
+		init_waitqueue_head(&bundle->chanwait);
+		atomic_set(&bundle->usage, 1);
+	}
+
+	_leave(" = %p", bundle);
+	return bundle;
+}
+
+/*
+ * compare bundle parameters with what we're looking for
+ * - return -ve, 0 or +ve
+ */
+static inline
+int rxrpc_cmp_bundle(const struct rxrpc_conn_bundle *bundle,
+		     struct key *key, __be16 service_id)
+{
+	return (bundle->service_id - service_id) ?:
+		((unsigned long) bundle->key - (unsigned long) key);
+}
+
+/*
+ * get bundle of client connections that a client socket can make use of
+ */
+struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
+					   struct rxrpc_transport *trans,
+					   struct key *key,
+					   __be16 service_id,
+					   gfp_t gfp)
+{
+	struct rxrpc_conn_bundle *bundle, *candidate;
+	struct rb_node *p, *parent, **pp;
+
+	_enter("%p{%x},%x,%hx,",
+	       rx, key_serial(key), trans->debug_id, ntohl(service_id));
+
+	if (rx->trans == trans && rx->bundle) {
+		atomic_inc(&rx->bundle->usage);
+		return rx->bundle;
+	}
+
+	/* search the extant bundles first for one that matches the specified
+	 * user ID */
+	spin_lock(&trans->client_lock);
+
+	p = trans->bundles.rb_node;
+	while (p) {
+		bundle = rb_entry(p, struct rxrpc_conn_bundle, node);
+
+		if (rxrpc_cmp_bundle(bundle, key, service_id) < 0)
+			p = p->rb_left;
+		else if (rxrpc_cmp_bundle(bundle, key, service_id) > 0)
+			p = p->rb_right;
+		else
+			goto found_extant_bundle;
+	}
+
+	spin_unlock(&trans->client_lock);
+
+	/* not yet present - create a candidate for a new record and then
+	 * redo the search */
+	candidate = rxrpc_alloc_bundle(gfp);
+	if (!candidate) {
+		_leave(" = -ENOMEM");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	candidate->key = key_get(key);
+	candidate->service_id = service_id;
+
+	spin_lock(&trans->client_lock);
+
+	pp = &trans->bundles.rb_node;
+	parent = NULL;
+	while (*pp) {
+		parent = *pp;
+		bundle = rb_entry(parent, struct rxrpc_conn_bundle, node);
+
+		if (rxrpc_cmp_bundle(bundle, key, service_id) < 0)
+			pp = &(*pp)->rb_left;
+		else if (rxrpc_cmp_bundle(bundle, key, service_id) > 0)
+			pp = &(*pp)->rb_right;
+		else
+			goto found_extant_second;
+	}
+
+	/* second search also failed; add the new bundle */
+	bundle = candidate;
+	candidate = NULL;
+
+	rb_link_node(&bundle->node, parent, pp);
+	rb_insert_color(&bundle->node, &trans->bundles);
+	spin_unlock(&trans->client_lock);
+	_net("BUNDLE new on trans %d", trans->debug_id);
+	if (!rx->bundle && rx->sk.sk_state == RXRPC_CLIENT_CONNECTED) {
+		atomic_inc(&bundle->usage);
+		rx->bundle = bundle;
+	}
+	_leave(" = %p [new]", bundle);
+	return bundle;
+
+	/* we found the bundle in the list immediately */
+found_extant_bundle:
+	atomic_inc(&bundle->usage);
+	spin_unlock(&trans->client_lock);
+	_net("BUNDLE old on trans %d", trans->debug_id);
+	if (!rx->bundle && rx->sk.sk_state == RXRPC_CLIENT_CONNECTED) {
+		atomic_inc(&bundle->usage);
+		rx->bundle = bundle;
+	}
+	_leave(" = %p [extant %d]", bundle, atomic_read(&bundle->usage));
+	return bundle;
+
+	/* we found the bundle on the second time through the list */
+found_extant_second:
+	atomic_inc(&bundle->usage);
+	spin_unlock(&trans->client_lock);
+	kfree(candidate);
+	_net("BUNDLE old2 on trans %d", trans->debug_id);
+	if (!rx->bundle && rx->sk.sk_state == RXRPC_CLIENT_CONNECTED) {
+		atomic_inc(&bundle->usage);
+		rx->bundle = bundle;
+	}
+	_leave(" = %p [second %d]", bundle, atomic_read(&bundle->usage));
+	return bundle;
+}
+
+/*
+ * release a bundle
+ */
+void rxrpc_put_bundle(struct rxrpc_transport *trans,
+		      struct rxrpc_conn_bundle *bundle)
+{
+	_enter("%p,%p{%d}",trans, bundle, atomic_read(&bundle->usage));
+
+	if (atomic_dec_and_lock(&bundle->usage, &trans->client_lock)) {
+		_debug("Destroy bundle");
+		rb_erase(&bundle->node, &trans->bundles);
+		spin_unlock(&trans->client_lock);
+		ASSERT(list_empty(&bundle->unused_conns));
+		ASSERT(list_empty(&bundle->avail_conns));
+		ASSERT(list_empty(&bundle->busy_conns));
+		ASSERTCMP(bundle->num_conns, ==, 0);
+		key_put(bundle->key);
+		kfree(bundle);
+	}
+
+	_leave("");
+}
+
+/*
+ * allocate a new connection
+ */
+static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
+{
+	struct rxrpc_connection *conn;
+
+	_enter("");
+
+	conn = kzalloc(sizeof(struct rxrpc_connection), gfp);
+	if (conn) {
+		INIT_WORK(&conn->processor, &rxrpc_process_connection);
+		INIT_LIST_HEAD(&conn->bundle_link);
+		conn->calls = RB_ROOT;
+		skb_queue_head_init(&conn->rx_queue);
+		rwlock_init(&conn->lock);
+		spin_lock_init(&conn->state_lock);
+		atomic_set(&conn->usage, 1);
+		conn->debug_id = atomic_inc_return(&rxrpc_debug_id);
+		conn->avail_calls = RXRPC_MAXCALLS;
+		conn->size_align = 4;
+		conn->header_size = sizeof(struct rxrpc_header);
+	}
+
+	_leave(" = %p{%d}", conn, conn->debug_id);
+	return conn;
+}
+
+/*
+ * assign a connection ID to a connection and add it to the transport's
+ * connection lookup tree
+ * - called with transport client lock held
+ */
+static void rxrpc_assign_connection_id(struct rxrpc_connection *conn)
+{
+	struct rxrpc_connection *xconn;
+	struct rb_node *parent, **p;
+	__be32 epoch;
+	u32 real_conn_id;
+
+	_enter("");
+
+	epoch = conn->epoch;
+
+	write_lock_bh(&conn->trans->conn_lock);
+
+	conn->trans->conn_idcounter += RXRPC_CID_INC;
+	if (conn->trans->conn_idcounter < RXRPC_CID_INC)
+		conn->trans->conn_idcounter = RXRPC_CID_INC;
+	real_conn_id = conn->trans->conn_idcounter;
+
+attempt_insertion:
+	parent = NULL;
+	p = &conn->trans->client_conns.rb_node;
+
+	while (*p) {
+		parent = *p;
+		xconn = rb_entry(parent, struct rxrpc_connection, node);
+
+		if (epoch < xconn->epoch)
+			p = &(*p)->rb_left;
+		else if (epoch > xconn->epoch)
+			p = &(*p)->rb_right;
+		else if (real_conn_id < xconn->real_conn_id)
+			p = &(*p)->rb_left;
+		else if (real_conn_id > xconn->real_conn_id)
+			p = &(*p)->rb_right;
+		else
+			goto id_exists;
+	}
+
+	/* we've found a suitable hole - arrange for this connection to occupy
+	 * it */
+	rb_link_node(&conn->node, parent, p);
+	rb_insert_color(&conn->node, &conn->trans->client_conns);
+
+	conn->real_conn_id = real_conn_id;
+	conn->cid = htonl(real_conn_id);
+	write_unlock_bh(&conn->trans->conn_lock);
+	_leave(" [CONNID %x CID %x]", real_conn_id, ntohl(conn->cid));
+	return;
+
+	/* we found a connection with the proposed ID - walk the tree from that
+	 * point looking for the next unused ID */
+id_exists:
+	for (;;) {
+		real_conn_id += RXRPC_CID_INC;
+		if (real_conn_id < RXRPC_CID_INC) {
+			real_conn_id = RXRPC_CID_INC;
+			conn->trans->conn_idcounter = real_conn_id;
+			goto attempt_insertion;
+		}
+
+		parent = rb_next(parent);
+		if (!parent)
+			goto attempt_insertion;
+
+		xconn = rb_entry(parent, struct rxrpc_connection, node);
+		if (epoch < xconn->epoch ||
+		    real_conn_id < xconn->real_conn_id)
+			goto attempt_insertion;
+	}
+}
+
+/*
+ * add a call to a connection's call-by-ID tree
+ */
+static void rxrpc_add_call_ID_to_conn(struct rxrpc_connection *conn,
+				      struct rxrpc_call *call)
+{
+	struct rxrpc_call *xcall;
+	struct rb_node *parent, **p;
+	__be32 call_id;
+
+	write_lock_bh(&conn->lock);
+
+	call_id = call->call_id;
+	p = &conn->calls.rb_node;
+	parent = NULL;
+	while (*p) {
+		parent = *p;
+		xcall = rb_entry(parent, struct rxrpc_call, conn_node);
+
+		if (call_id < xcall->call_id)
+			p = &(*p)->rb_left;
+		else if (call_id > xcall->call_id)
+			p = &(*p)->rb_right;
+		else
+			BUG();
+	}
+
+	rb_link_node(&call->conn_node, parent, p);
+	rb_insert_color(&call->conn_node, &conn->calls);
+
+	write_unlock_bh(&conn->lock);
+}
+
+/*
+ * connect a call on an exclusive connection
+ */
+static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
+				   struct rxrpc_transport *trans,
+				   __be16 service_id,
+				   struct rxrpc_call *call,
+				   gfp_t gfp)
+{
+	struct rxrpc_connection *conn;
+	int chan, ret;
+
+	_enter("");
+
+	conn = rx->conn;
+	if (!conn) {
+		/* not yet present - create a candidate for a new connection
+		 * and then redo the check */
+		conn = rxrpc_alloc_connection(gfp);
+		if (IS_ERR(conn)) {
+			_leave(" = %ld", PTR_ERR(conn));
+			return PTR_ERR(conn);
+		}
+
+		conn->trans = trans;
+		conn->bundle = NULL;
+		conn->service_id = service_id;
+		conn->epoch = rxrpc_epoch;
+		conn->in_clientflag = 0;
+		conn->out_clientflag = RXRPC_CLIENT_INITIATED;
+		conn->cid = 0;
+		conn->state = RXRPC_CONN_CLIENT;
+		conn->avail_calls = RXRPC_MAXCALLS;
+		conn->security_level = rx->min_sec_level;
+		conn->key = key_get(rx->key);
+
+		ret = rxrpc_init_client_conn_security(conn);
+		if (ret < 0) {
+			key_put(conn->key);
+			kfree(conn);
+			_leave(" = %d [key]", ret);
+			return ret;
+		}
+
+		write_lock_bh(&rxrpc_connection_lock);
+		list_add_tail(&conn->link, &rxrpc_connections);
+		write_unlock_bh(&rxrpc_connection_lock);
+
+		spin_lock(&trans->client_lock);
+		atomic_inc(&trans->usage);
+
+		_net("CONNECT EXCL new %d on TRANS %d",
+		     conn->debug_id, conn->trans->debug_id);
+
+		rxrpc_assign_connection_id(conn);
+		rx->conn = conn;
+	}
+
+	/* we've got a connection with a free channel and we can now attach the
+	 * call to it
+	 * - we're holding the transport's client lock
+	 * - we're holding a reference on the connection
+	 */
+	for (chan = 0; chan < RXRPC_MAXCALLS; chan++)
+		if (!conn->channels[chan])
+			goto found_channel;
+	goto no_free_channels;
+
+found_channel:
+	atomic_inc(&conn->usage);
+	conn->channels[chan] = call;
+	call->conn = conn;
+	call->channel = chan;
+	call->cid = conn->cid | htonl(chan);
+	call->call_id = htonl(++conn->call_counter);
+
+	_net("CONNECT client on conn %d chan %d as call %x",
+	     conn->debug_id, chan, ntohl(call->call_id));
+
+	spin_unlock(&trans->client_lock);
+
+	rxrpc_add_call_ID_to_conn(conn, call);
+	_leave(" = 0");
+	return 0;
+
+no_free_channels:
+	spin_unlock(&trans->client_lock);
+	_leave(" = -ENOSR");
+	return -ENOSR;
+}
+
+/*
+ * find a connection for a call
+ * - called in process context with IRQs enabled
+ */
+int rxrpc_connect_call(struct rxrpc_sock *rx,
+		       struct rxrpc_transport *trans,
+		       struct rxrpc_conn_bundle *bundle,
+		       struct rxrpc_call *call,
+		       gfp_t gfp)
+{
+	struct rxrpc_connection *conn, *candidate;
+	int chan, ret;
+
+	DECLARE_WAITQUEUE(myself, current);
+
+	_enter("%p,%lx,", rx, call->user_call_ID);
+
+	if (test_bit(RXRPC_SOCK_EXCLUSIVE_CONN, &rx->flags))
+		return rxrpc_connect_exclusive(rx, trans, bundle->service_id,
+					       call, gfp);
+
+	spin_lock(&trans->client_lock);
+	for (;;) {
+		/* see if the bundle has a call slot available */
+		if (!list_empty(&bundle->avail_conns)) {
+			_debug("avail");
+			conn = list_entry(bundle->avail_conns.next,
+					  struct rxrpc_connection,
+					  bundle_link);
+			if (--conn->avail_calls == 0)
+				list_move(&conn->bundle_link,
+					  &bundle->busy_conns);
+			atomic_inc(&conn->usage);
+			break;
+		}
+
+		if (!list_empty(&bundle->unused_conns)) {
+			_debug("unused");
+			conn = list_entry(bundle->unused_conns.next,
+					  struct rxrpc_connection,
+					  bundle_link);
+			atomic_inc(&conn->usage);
+			list_move(&conn->bundle_link, &bundle->avail_conns);
+			break;
+		}
+
+		/* need to allocate a new connection */
+		_debug("get new conn [%d]", bundle->num_conns);
+
+		spin_unlock(&trans->client_lock);
+
+		if (signal_pending(current))
+			goto interrupted;
+
+		if (bundle->num_conns >= 20) {
+			_debug("too many conns");
+
+			if (!(gfp & __GFP_WAIT)) {
+				_leave(" = -EAGAIN");
+				return -EAGAIN;
+			}
+
+			add_wait_queue(&bundle->chanwait, &myself);
+			for (;;) {
+				set_current_state(TASK_INTERRUPTIBLE);
+				if (bundle->num_conns < 20 ||
+				    !list_empty(&bundle->unused_conns) ||
+				    !list_empty(&bundle->avail_conns))
+					break;
+				if (signal_pending(current))
+					goto interrupted_dequeue;
+				schedule();
+			}
+			remove_wait_queue(&bundle->chanwait, &myself);
+			__set_current_state(TASK_RUNNING);
+			spin_lock(&trans->client_lock);
+			continue;
+		}
+
+		/* not yet present - create a candidate for a new connection and then
+		 * redo the check */
+		candidate = rxrpc_alloc_connection(gfp);
+		if (IS_ERR(candidate)) {
+			_leave(" = %ld", PTR_ERR(candidate));
+			return PTR_ERR(candidate);
+		}
+
+		candidate->trans = trans;
+		candidate->bundle = bundle;
+		candidate->service_id = bundle->service_id;
+		candidate->epoch = rxrpc_epoch;
+		candidate->in_clientflag = 0;
+		candidate->out_clientflag = RXRPC_CLIENT_INITIATED;
+		candidate->cid = 0;
+		candidate->state = RXRPC_CONN_CLIENT;
+		candidate->avail_calls = RXRPC_MAXCALLS;
+		candidate->security_level = rx->min_sec_level;
+		candidate->key = key_get(rx->key);
+
+		ret = rxrpc_init_client_conn_security(candidate);
+		if (ret < 0) {
+			key_put(candidate->key);
+			kfree(candidate);
+			_leave(" = %d [key]", ret);
+			return ret;
+		}
+
+		write_lock_bh(&rxrpc_connection_lock);
+		list_add_tail(&candidate->link, &rxrpc_connections);
+		write_unlock_bh(&rxrpc_connection_lock);
+
+		spin_lock(&trans->client_lock);
+
+		list_add(&candidate->bundle_link, &bundle->unused_conns);
+		bundle->num_conns++;
+		atomic_inc(&bundle->usage);
+		atomic_inc(&trans->usage);
+
+		_net("CONNECT new %d on TRANS %d",
+		     candidate->debug_id, candidate->trans->debug_id);
+
+		rxrpc_assign_connection_id(candidate);
+		if (candidate->security)
+			candidate->security->prime_packet_security(candidate);
+
+		/* leave the candidate lurking in zombie mode attached to the
+		 * bundle until we're ready for it */
+		rxrpc_put_connection(candidate);
+		candidate = NULL;
+	}
+
+	/* we've got a connection with a free channel and we can now attach the
+	 * call to it
+	 * - we're holding the transport's client lock
+	 * - we're holding a reference on the connection
+	 * - we're holding a reference on the bundle
+	 */
+	for (chan = 0; chan < RXRPC_MAXCALLS; chan++)
+		if (!conn->channels[chan])
+			goto found_channel;
+	BUG();
+
+found_channel:
+	conn->channels[chan] = call;
+	call->conn = conn;
+	call->channel = chan;
+	call->cid = conn->cid | htonl(chan);
+	call->call_id = htonl(++conn->call_counter);
+
+	_net("CONNECT client on conn %d chan %d as call %x",
+	     conn->debug_id, chan, ntohl(call->call_id));
+
+	spin_unlock(&trans->client_lock);
+
+	rxrpc_add_call_ID_to_conn(conn, call);
+
+	_leave(" = 0");
+	return 0;
+
+interrupted_dequeue:
+	remove_wait_queue(&bundle->chanwait, &myself);
+	__set_current_state(TASK_RUNNING);
+interrupted:
+	_leave(" = -ERESTARTSYS");
+	return -ERESTARTSYS;
+}
+
+/*
+ * get a record of an incoming connection
+ */
+struct rxrpc_connection *
+rxrpc_incoming_connection(struct rxrpc_transport *trans,
+			  struct rxrpc_header *hdr,
+			  gfp_t gfp)
+{
+	struct rxrpc_connection *conn, *candidate = NULL;
+	struct rb_node *p, **pp;
+	const char *new = "old";
+	__be32 epoch;
+	u32 conn_id;
+
+	_enter("");
+
+	ASSERT(hdr->flags & RXRPC_CLIENT_INITIATED);
+
+	epoch = hdr->epoch;
+	conn_id = ntohl(hdr->cid) & RXRPC_CIDMASK;
+
+	/* search the connection list first */
+	read_lock_bh(&trans->conn_lock);
+
+	p = trans->server_conns.rb_node;
+	while (p) {
+		conn = rb_entry(p, struct rxrpc_connection, node);
+
+		_debug("maybe %x", conn->real_conn_id);
+
+		if (epoch < conn->epoch)
+			p = p->rb_left;
+		else if (epoch > conn->epoch)
+			p = p->rb_right;
+		else if (conn_id < conn->real_conn_id)
+			p = p->rb_left;
+		else if (conn_id > conn->real_conn_id)
+			p = p->rb_right;
+		else
+			goto found_extant_connection;
+	}
+	read_unlock_bh(&trans->conn_lock);
+
+	/* not yet present - create a candidate for a new record and then
+	 * redo the search */
+	candidate = rxrpc_alloc_connection(gfp);
+	if (!candidate) {
+		_leave(" = -ENOMEM");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	candidate->trans = trans;
+	candidate->epoch = hdr->epoch;
+	candidate->cid = hdr->cid & __constant_cpu_to_be32(RXRPC_CIDMASK);
+	candidate->service_id = hdr->serviceId;
+	candidate->security_ix = hdr->securityIndex;
+	candidate->in_clientflag = RXRPC_CLIENT_INITIATED;
+	candidate->out_clientflag = 0;
+	candidate->real_conn_id = conn_id;
+	candidate->state = RXRPC_CONN_SERVER;
+	if (candidate->service_id)
+		candidate->state = RXRPC_CONN_SERVER_UNSECURED;
+
+	write_lock_bh(&trans->conn_lock);
+
+	pp = &trans->server_conns.rb_node;
+	p = NULL;
+	while (*pp) {
+		p = *pp;
+		conn = rb_entry(p, struct rxrpc_connection, node);
+
+		if (epoch < conn->epoch)
+			pp = &(*pp)->rb_left;
+		else if (epoch > conn->epoch)
+			pp = &(*pp)->rb_right;
+		else if (conn_id < conn->real_conn_id)
+			pp = &(*pp)->rb_left;
+		else if (conn_id > conn->real_conn_id)
+			pp = &(*pp)->rb_right;
+		else
+			goto found_extant_second;
+	}
+
+	/* we can now add the new candidate to the list */
+	conn = candidate;
+	candidate = NULL;
+	rb_link_node(&conn->node, p, pp);
+	rb_insert_color(&conn->node, &trans->server_conns);
+	atomic_inc(&conn->trans->usage);
+
+	write_unlock_bh(&trans->conn_lock);
+
+	write_lock_bh(&rxrpc_connection_lock);
+	list_add_tail(&conn->link, &rxrpc_connections);
+	write_unlock_bh(&rxrpc_connection_lock);
+
+	new = "new";
+
+success:
+	_net("CONNECTION %s %d {%x}", new, conn->debug_id, conn->real_conn_id);
+
+	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
+	return conn;
+
+	/* we found the connection in the list immediately */
+found_extant_connection:
+	if (hdr->securityIndex != conn->security_ix) {
+		read_unlock_bh(&trans->conn_lock);
+		goto security_mismatch;
+	}
+	atomic_inc(&conn->usage);
+	read_unlock_bh(&trans->conn_lock);
+	goto success;
+
+	/* we found the connection on the second time through the list */
+found_extant_second:
+	if (hdr->securityIndex != conn->security_ix) {
+		write_unlock_bh(&trans->conn_lock);
+		goto security_mismatch;
+	}
+	atomic_inc(&conn->usage);
+	write_unlock_bh(&trans->conn_lock);
+	kfree(candidate);
+	goto success;
+
+security_mismatch:
+	kfree(candidate);
+	_leave(" = -EKEYREJECTED");
+	return ERR_PTR(-EKEYREJECTED);
+}
+
+/*
+ * find a connection based on transport and RxRPC connection ID for an incoming
+ * packet
+ */
+struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *trans,
+					       struct rxrpc_header *hdr)
+{
+	struct rxrpc_connection *conn;
+	struct rb_node *p;
+	__be32 epoch;
+	u32 conn_id;
+
+	_enter(",{%x,%x}", ntohl(hdr->cid), hdr->flags);
+
+	read_lock_bh(&trans->conn_lock);
+
+	conn_id = ntohl(hdr->cid) & RXRPC_CIDMASK;
+	epoch = hdr->epoch;
+
+	if (hdr->flags & RXRPC_CLIENT_INITIATED)
+		p = trans->server_conns.rb_node;
+	else
+		p = trans->client_conns.rb_node;
+
+	while (p) {
+		conn = rb_entry(p, struct rxrpc_connection, node);
+
+		_debug("maybe %x", conn->real_conn_id);
+
+		if (epoch < conn->epoch)
+			p = p->rb_left;
+		else if (epoch > conn->epoch)
+			p = p->rb_right;
+		else if (conn_id < conn->real_conn_id)
+			p = p->rb_left;
+		else if (conn_id > conn->real_conn_id)
+			p = p->rb_right;
+		else
+			goto found;
+	}
+
+	read_unlock_bh(&trans->conn_lock);
+	_leave(" = NULL");
+	return NULL;
+
+found:
+	atomic_inc(&conn->usage);
+	read_unlock_bh(&trans->conn_lock);
+	_leave(" = %p", conn);
+	return conn;
+}
+
+/*
+ * release a virtual connection
+ */
+void rxrpc_put_connection(struct rxrpc_connection *conn)
+{
+	_enter("%p{u=%d,d=%d}",
+	       conn, atomic_read(&conn->usage), conn->debug_id);
+
+	ASSERTCMP(atomic_read(&conn->usage), >, 0);
+
+	conn->put_time = xtime.tv_sec;
+	if (atomic_dec_and_test(&conn->usage)) {
+		_debug("zombie");
+		schedule_delayed_work(&rxrpc_connection_reap, 0);
+	}
+
+	_leave("");
+}
+
+/*
+ * destroy a virtual connection
+ */
+static void rxrpc_destroy_connection(struct rxrpc_connection *conn)
+{
+	_enter("%p{%d}", conn, atomic_read(&conn->usage));
+
+	ASSERTCMP(atomic_read(&conn->usage), ==, 0);
+
+	_net("DESTROY CONN %d", conn->debug_id);
+
+	if (conn->bundle)
+		rxrpc_put_bundle(conn->trans, conn->bundle);
+
+	ASSERT(RB_EMPTY_ROOT(&conn->calls));
+	rxrpc_purge_queue(&conn->rx_queue);
+
+	rxrpc_clear_conn_security(conn);
+	rxrpc_put_transport(conn->trans);
+	kfree(conn);
+	_leave("");
+}
+
+/*
+ * reap dead connections
+ */
+void rxrpc_connection_reaper(struct work_struct *work)
+{
+	struct rxrpc_connection *conn, *_p;
+	unsigned long now, earliest, reap_time;
+
+	LIST_HEAD(graveyard);
+
+	_enter("");
+
+	now = xtime.tv_sec;
+	earliest = ULONG_MAX;
+
+	write_lock_bh(&rxrpc_connection_lock);
+	list_for_each_entry_safe(conn, _p, &rxrpc_connections, link) {
+		_debug("reap CONN %d { u=%d,t=%ld }",
+		       conn->debug_id, atomic_read(&conn->usage),
+		       (long) now - (long) conn->put_time);
+
+		if (likely(atomic_read(&conn->usage) > 0))
+			continue;
+
+		spin_lock(&conn->trans->client_lock);
+		write_lock(&conn->trans->conn_lock);
+		reap_time = conn->put_time + rxrpc_connection_timeout;
+
+		if (atomic_read(&conn->usage) > 0) {
+			;
+		} else if (reap_time <= now) {
+			list_move_tail(&conn->link, &graveyard);
+			if (conn->out_clientflag)
+				rb_erase(&conn->node,
+					 &conn->trans->client_conns);
+			else
+				rb_erase(&conn->node,
+					 &conn->trans->server_conns);
+			if (conn->bundle) {
+				list_del_init(&conn->bundle_link);
+				conn->bundle->num_conns--;
+			}
+
+		} else if (reap_time < earliest) {
+			earliest = reap_time;
+		}
+
+		write_unlock(&conn->trans->conn_lock);
+		spin_unlock(&conn->trans->client_lock);
+	}
+	write_unlock_bh(&rxrpc_connection_lock);
+
+	if (earliest != ULONG_MAX) {
+		_debug("reschedule reaper %ld", (long) earliest - now);
+		ASSERTCMP(earliest, >, now);
+		schedule_delayed_work(&rxrpc_connection_reap,
+				      (earliest - now) * HZ);
+	}
+
+	/* then destroy all those pulled out */
+	while (!list_empty(&graveyard)) {
+		conn = list_entry(graveyard.next, struct rxrpc_connection,
+				  link);
+		list_del_init(&conn->link);
+
+		ASSERTCMP(atomic_read(&conn->usage), ==, 0);
+		rxrpc_destroy_connection(conn);
+	}
+
+	_leave("");
+}
+
+/*
+ * preemptively destroy all the connection records rather than waiting for them
+ * to time out
+ */
+void __exit rxrpc_destroy_all_connections(void)
+{
+	_enter("");
+
+	rxrpc_connection_timeout = 0;
+	cancel_delayed_work(&rxrpc_connection_reap);
+	schedule_delayed_work(&rxrpc_connection_reap, 0);
+
+	_leave("");
+}
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
new file mode 100644
index 0000000..4b02815
--- /dev/null
+++ b/net/rxrpc/ar-connevent.c
@@ -0,0 +1,387 @@
+/* connection-level event handling
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/errqueue.h>
+#include <linux/udp.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/icmp.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include <net/ip.h>
+#include "ar-internal.h"
+
+/*
+ * pass a connection-level abort onto all calls on that connection
+ */
+static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
+			      u32 abort_code)
+{
+	struct rxrpc_call *call;
+	struct rb_node *p;
+
+	_enter("{%d},%x", conn->debug_id, abort_code);
+
+	read_lock_bh(&conn->lock);
+
+	for (p = rb_first(&conn->calls); p; p = rb_next(p)) {
+		call = rb_entry(p, struct rxrpc_call, conn_node);
+		write_lock(&call->state_lock);
+		if (call->state <= RXRPC_CALL_COMPLETE) {
+			call->state = state;
+			call->abort_code = abort_code;
+			if (state == RXRPC_CALL_LOCALLY_ABORTED)
+				set_bit(RXRPC_CALL_CONN_ABORT, &call->events);
+			else
+				set_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
+			schedule_work(&call->processor);
+		}
+		write_unlock(&call->state_lock);
+	}
+
+	read_unlock_bh(&conn->lock);
+	_leave("");
+}
+
+/*
+ * generate a connection-level abort
+ */
+static int rxrpc_abort_connection(struct rxrpc_connection *conn,
+				  u32 error, u32 abort_code)
+{
+	struct rxrpc_header hdr;
+	struct msghdr msg;
+	struct kvec iov[2];
+	__be32 word;
+	size_t len;
+	int ret;
+
+	_enter("%d,,%u,%u", conn->debug_id, error, abort_code);
+
+	/* generate a connection-level abort */
+	spin_lock_bh(&conn->state_lock);
+	if (conn->state < RXRPC_CONN_REMOTELY_ABORTED) {
+		conn->state = RXRPC_CONN_LOCALLY_ABORTED;
+		conn->error = error;
+		spin_unlock_bh(&conn->state_lock);
+	} else {
+		spin_unlock_bh(&conn->state_lock);
+		_leave(" = 0 [already dead]");
+		return 0;
+	}
+
+	rxrpc_abort_calls(conn, RXRPC_CALL_LOCALLY_ABORTED, abort_code);
+
+	msg.msg_name	= &conn->trans->peer->srx.transport.sin;
+	msg.msg_namelen	= sizeof(conn->trans->peer->srx.transport.sin);
+	msg.msg_control	= NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags	= 0;
+
+	hdr.epoch	= conn->epoch;
+	hdr.cid		= conn->cid;
+	hdr.callNumber	= 0;
+	hdr.seq		= 0;
+	hdr.type	= RXRPC_PACKET_TYPE_ABORT;
+	hdr.flags	= conn->out_clientflag;
+	hdr.userStatus	= 0;
+	hdr.securityIndex = conn->security_ix;
+	hdr._rsvd	= 0;
+	hdr.serviceId	= conn->service_id;
+
+	word = htonl(abort_code);
+
+	iov[0].iov_base	= &hdr;
+	iov[0].iov_len	= sizeof(hdr);
+	iov[1].iov_base	= &word;
+	iov[1].iov_len	= sizeof(word);
+
+	len = iov[0].iov_len + iov[1].iov_len;
+
+	hdr.serial = htonl(atomic_inc_return(&conn->serial));
+	_proto("Tx CONN ABORT %%%u { %d }", ntohl(hdr.serial), abort_code);
+
+	ret = kernel_sendmsg(conn->trans->local->socket, &msg, iov, 2, len);
+	if (ret < 0) {
+		_debug("sendmsg failed: %d", ret);
+		return -EAGAIN;
+	}
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * mark a call as being on a now-secured channel
+ * - must be called with softirqs disabled
+ */
+void rxrpc_call_is_secure(struct rxrpc_call *call)
+{
+	_enter("%p", call);
+	if (call) {
+		read_lock(&call->state_lock);
+		if (call->state < RXRPC_CALL_COMPLETE &&
+		    !test_and_set_bit(RXRPC_CALL_SECURED, &call->events))
+			schedule_work(&call->processor);
+		read_unlock(&call->state_lock);
+	}
+}
+
+/*
+ * connection-level Rx packet processor
+ */
+static int rxrpc_process_event(struct rxrpc_connection *conn,
+			       struct sk_buff *skb,
+			       u32 *_abort_code)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	__be32 tmp;
+	u32 serial;
+	int loop, ret;
+
+	if (conn->state >= RXRPC_CONN_REMOTELY_ABORTED)
+		return -ECONNABORTED;
+
+	serial = ntohl(sp->hdr.serial);
+
+	switch (sp->hdr.type) {
+	case RXRPC_PACKET_TYPE_ABORT:
+		if (skb_copy_bits(skb, 0, &tmp, sizeof(tmp)) < 0)
+			return -EPROTO;
+		_proto("Rx ABORT %%%u { ac=%d }", serial, ntohl(tmp));
+
+		conn->state = RXRPC_CONN_REMOTELY_ABORTED;
+		rxrpc_abort_calls(conn, RXRPC_CALL_REMOTELY_ABORTED,
+				  ntohl(tmp));
+		return -ECONNABORTED;
+
+	case RXRPC_PACKET_TYPE_CHALLENGE:
+		if (conn->security)
+			return conn->security->respond_to_challenge(
+				conn, skb, _abort_code);
+		return -EPROTO;
+
+	case RXRPC_PACKET_TYPE_RESPONSE:
+		if (!conn->security)
+			return -EPROTO;
+
+		ret = conn->security->verify_response(conn, skb, _abort_code);
+		if (ret < 0)
+			return ret;
+
+		ret = conn->security->init_connection_security(conn);
+		if (ret < 0)
+			return ret;
+
+		conn->security->prime_packet_security(conn);
+		read_lock_bh(&conn->lock);
+		spin_lock(&conn->state_lock);
+
+		if (conn->state == RXRPC_CONN_SERVER_CHALLENGING) {
+			conn->state = RXRPC_CONN_SERVER;
+			for (loop = 0; loop < RXRPC_MAXCALLS; loop++)
+				rxrpc_call_is_secure(conn->channels[loop]);
+		}
+
+		spin_unlock(&conn->state_lock);
+		read_unlock_bh(&conn->lock);
+		return 0;
+
+	default:
+		return -EPROTO;
+	}
+}
+
+/*
+ * set up security and issue a challenge
+ */
+static void rxrpc_secure_connection(struct rxrpc_connection *conn)
+{
+	u32 abort_code;
+	int ret;
+
+	_enter("{%d}", conn->debug_id);
+
+	ASSERT(conn->security_ix != 0);
+
+	if (!conn->key) {
+		_debug("set up security");
+		ret = rxrpc_init_server_conn_security(conn);
+		switch (ret) {
+		case 0:
+			break;
+		case -ENOENT:
+			abort_code = RX_CALL_DEAD;
+			goto abort;
+		default:
+			abort_code = RXKADNOAUTH;
+			goto abort;
+		}
+	}
+
+	ASSERT(conn->security != NULL);
+
+	if (conn->security->issue_challenge(conn) < 0) {
+		abort_code = RX_CALL_DEAD;
+		ret = -ENOMEM;
+		goto abort;
+	}
+
+	_leave("");
+	return;
+
+abort:
+	_debug("abort %d, %d", ret, abort_code);
+	rxrpc_abort_connection(conn, -ret, abort_code);
+	_leave(" [aborted]");
+}
+
+/*
+ * connection-level event processor
+ */
+void rxrpc_process_connection(struct work_struct *work)
+{
+	struct rxrpc_connection *conn =
+		container_of(work, struct rxrpc_connection, processor);
+	struct rxrpc_skb_priv *sp;
+	struct sk_buff *skb;
+	u32 abort_code = RX_PROTOCOL_ERROR;
+	int ret;
+
+	_enter("{%d}", conn->debug_id);
+
+	atomic_inc(&conn->usage);
+
+	if (test_and_clear_bit(RXRPC_CONN_CHALLENGE, &conn->events)) {
+		rxrpc_secure_connection(conn);
+		rxrpc_put_connection(conn);
+	}
+
+	/* go through the conn-level event packets, releasing the ref on this
+	 * connection that each one has when we've finished with it */
+	while ((skb = skb_dequeue(&conn->rx_queue))) {
+		sp = rxrpc_skb(skb);
+
+		ret = rxrpc_process_event(conn, skb, &abort_code);
+		switch (ret) {
+		case -EPROTO:
+		case -EKEYEXPIRED:
+		case -EKEYREJECTED:
+			goto protocol_error;
+		case -EAGAIN:
+			goto requeue_and_leave;
+		case -ECONNABORTED:
+		default:
+			rxrpc_put_connection(conn);
+			rxrpc_free_skb(skb);
+			break;
+		}
+	}
+
+out:
+	rxrpc_put_connection(conn);
+	_leave("");
+	return;
+
+requeue_and_leave:
+	skb_queue_head(&conn->rx_queue, skb);
+	goto out;
+
+protocol_error:
+	if (rxrpc_abort_connection(conn, -ret, abort_code) < 0)
+		goto requeue_and_leave;
+	rxrpc_put_connection(conn);
+	rxrpc_free_skb(skb);
+	_leave(" [EPROTO]");
+	goto out;
+}
+
+/*
+ * reject packets through the local endpoint
+ */
+void rxrpc_reject_packets(struct work_struct *work)
+{
+	union {
+		struct sockaddr sa;
+		struct sockaddr_in sin;
+	} sa;
+	struct rxrpc_skb_priv *sp;
+	struct rxrpc_header hdr;
+	struct rxrpc_local *local;
+	struct sk_buff *skb;
+	struct msghdr msg;
+	struct kvec iov[2];
+	size_t size;
+	__be32 code;
+
+	local = container_of(work, struct rxrpc_local, rejecter);
+	rxrpc_get_local(local);
+
+	_enter("%d", local->debug_id);
+
+	iov[0].iov_base = &hdr;
+	iov[0].iov_len = sizeof(hdr);
+	iov[1].iov_base = &code;
+	iov[1].iov_len = sizeof(code);
+	size = sizeof(hdr) + sizeof(code);
+
+	msg.msg_name = &sa;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = 0;
+
+	memset(&sa, 0, sizeof(sa));
+	sa.sa.sa_family = local->srx.transport.family;
+	switch (sa.sa.sa_family) {
+	case AF_INET:
+		msg.msg_namelen = sizeof(sa.sin);
+		break;
+	default:
+		msg.msg_namelen = 0;
+		break;
+	}
+
+	memset(&hdr, 0, sizeof(hdr));
+	hdr.type = RXRPC_PACKET_TYPE_ABORT;
+
+	while ((skb = skb_dequeue(&local->reject_queue))) {
+		sp = rxrpc_skb(skb);
+		switch (sa.sa.sa_family) {
+		case AF_INET:
+			sa.sin.sin_port = udp_hdr(skb)->source;
+			sa.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
+			code = htonl(skb->priority);
+
+			hdr.epoch = sp->hdr.epoch;
+			hdr.cid = sp->hdr.cid;
+			hdr.callNumber = sp->hdr.callNumber;
+			hdr.serviceId = sp->hdr.serviceId;
+			hdr.flags = sp->hdr.flags;
+			hdr.flags ^= RXRPC_CLIENT_INITIATED;
+			hdr.flags &= RXRPC_CLIENT_INITIATED;
+
+			kernel_sendmsg(local->socket, &msg, iov, 2, size);
+			break;
+
+		default:
+			break;
+		}
+
+		rxrpc_free_skb(skb);
+		rxrpc_put_local(local);
+	}
+
+	rxrpc_put_local(local);
+	_leave("");
+}
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
new file mode 100644
index 0000000..f5539e2
--- /dev/null
+++ b/net/rxrpc/ar-error.c
@@ -0,0 +1,253 @@
+/* Error message handling (ICMP)
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/errqueue.h>
+#include <linux/udp.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/icmp.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include <net/ip.h>
+#include "ar-internal.h"
+
+/*
+ * handle an error received on the local endpoint
+ */
+void rxrpc_UDP_error_report(struct sock *sk)
+{
+	struct sock_exterr_skb *serr;
+	struct rxrpc_transport *trans;
+	struct rxrpc_local *local = sk->sk_user_data;
+	struct rxrpc_peer *peer;
+	struct sk_buff *skb;
+	__be32 addr;
+	__be16 port;
+
+	_enter("%p{%d}", sk, local->debug_id);
+
+	skb = skb_dequeue(&sk->sk_error_queue);
+	if (!skb) {
+		_leave("UDP socket errqueue empty");
+		return;
+	}
+
+	rxrpc_new_skb(skb);
+
+	serr = SKB_EXT_ERR(skb);
+	addr = *(__be32 *)(skb_network_header(skb) + serr->addr_offset);
+	port = serr->port;
+
+	_net("Rx UDP Error from "NIPQUAD_FMT":%hu",
+	     NIPQUAD(addr), ntohs(port));
+	_debug("Msg l:%d d:%d", skb->len, skb->data_len);
+
+	peer = rxrpc_find_peer(local, addr, port);
+	if (IS_ERR(peer)) {
+		rxrpc_free_skb(skb);
+		_leave(" [no peer]");
+		return;
+	}
+
+	trans = rxrpc_find_transport(local, peer);
+	if (!trans) {
+		rxrpc_put_peer(peer);
+		rxrpc_free_skb(skb);
+		_leave(" [no trans]");
+		return;
+	}
+
+	if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP &&
+	    serr->ee.ee_type == ICMP_DEST_UNREACH &&
+	    serr->ee.ee_code == ICMP_FRAG_NEEDED
+	    ) {
+		u32 mtu = serr->ee.ee_info;
+
+		_net("Rx Received ICMP Fragmentation Needed (%d)", mtu);
+
+		/* wind down the local interface MTU */
+		if (mtu > 0 && peer->if_mtu == 65535 && mtu < peer->if_mtu) {
+			peer->if_mtu = mtu;
+			_net("I/F MTU %u", mtu);
+		}
+
+		/* ip_rt_frag_needed() may have eaten the info */
+		if (mtu == 0)
+			mtu = ntohs(icmp_hdr(skb)->un.frag.mtu);
+
+		if (mtu == 0) {
+			/* they didn't give us a size, estimate one */
+			if (mtu > 1500) {
+				mtu >>= 1;
+				if (mtu < 1500)
+					mtu = 1500;
+			} else {
+				mtu -= 100;
+				if (mtu < peer->hdrsize)
+					mtu = peer->hdrsize + 4;
+			}
+		}
+
+		if (mtu < peer->mtu) {
+			peer->mtu = mtu;
+			peer->maxdata = peer->mtu - peer->hdrsize;
+			_net("Net MTU %u (maxdata %u)",
+			     peer->mtu, peer->maxdata);
+		}
+	}
+
+	rxrpc_put_peer(peer);
+
+	/* pass the transport ref to error_handler to release */
+	skb_queue_tail(&trans->error_queue, skb);
+	schedule_work(&trans->error_handler);
+
+	/* reset and regenerate socket error */
+	spin_lock_bh(&sk->sk_error_queue.lock);
+	sk->sk_err = 0;
+	skb = skb_peek(&sk->sk_error_queue);
+	if (skb) {
+		sk->sk_err = SKB_EXT_ERR(skb)->ee.ee_errno;
+		spin_unlock_bh(&sk->sk_error_queue.lock);
+		sk->sk_error_report(sk);
+	} else {
+		spin_unlock_bh(&sk->sk_error_queue.lock);
+	}
+
+	_leave("");
+}
+
+/*
+ * deal with UDP error messages
+ */
+void rxrpc_UDP_error_handler(struct work_struct *work)
+{
+	struct sock_extended_err *ee;
+	struct sock_exterr_skb *serr;
+	struct rxrpc_transport *trans =
+		container_of(work, struct rxrpc_transport, error_handler);
+	struct sk_buff *skb;
+	int local, err;
+
+	_enter("");
+
+	skb = skb_dequeue(&trans->error_queue);
+	if (!skb)
+		return;
+
+	serr = SKB_EXT_ERR(skb);
+	ee = &serr->ee;
+
+	_net("Rx Error o=%d t=%d c=%d e=%d",
+	     ee->ee_origin, ee->ee_type, ee->ee_code, ee->ee_errno);
+
+	err = ee->ee_errno;
+
+	switch (ee->ee_origin) {
+	case SO_EE_ORIGIN_ICMP:
+		local = 0;
+		switch (ee->ee_type) {
+		case ICMP_DEST_UNREACH:
+			switch (ee->ee_code) {
+			case ICMP_NET_UNREACH:
+				_net("Rx Received ICMP Network Unreachable");
+				err = ENETUNREACH;
+				break;
+			case ICMP_HOST_UNREACH:
+				_net("Rx Received ICMP Host Unreachable");
+				err = EHOSTUNREACH;
+				break;
+			case ICMP_PORT_UNREACH:
+				_net("Rx Received ICMP Port Unreachable");
+				err = ECONNREFUSED;
+				break;
+			case ICMP_FRAG_NEEDED:
+				_net("Rx Received ICMP Fragmentation Needed (%d)",
+				     ee->ee_info);
+				err = 0; /* dealt with elsewhere */
+				break;
+			case ICMP_NET_UNKNOWN:
+				_net("Rx Received ICMP Unknown Network");
+				err = ENETUNREACH;
+				break;
+			case ICMP_HOST_UNKNOWN:
+				_net("Rx Received ICMP Unknown Host");
+				err = EHOSTUNREACH;
+				break;
+			default:
+				_net("Rx Received ICMP DestUnreach code=%u",
+				     ee->ee_code);
+				break;
+			}
+			break;
+
+		case ICMP_TIME_EXCEEDED:
+			_net("Rx Received ICMP TTL Exceeded");
+			break;
+
+		default:
+			_proto("Rx Received ICMP error { type=%u code=%u }",
+			       ee->ee_type, ee->ee_code);
+			break;
+		}
+		break;
+
+	case SO_EE_ORIGIN_LOCAL:
+		_proto("Rx Received local error { error=%d }",
+		       ee->ee_errno);
+		local = 1;
+		break;
+
+	case SO_EE_ORIGIN_NONE:
+	case SO_EE_ORIGIN_ICMP6:
+	default:
+		_proto("Rx Received error report { orig=%u }",
+		       ee->ee_origin);
+		local = 0;
+		break;
+	}
+
+	/* terminate all the affected calls if there's an unrecoverable
+	 * error */
+	if (err) {
+		struct rxrpc_call *call, *_n;
+
+		_debug("ISSUE ERROR %d", err);
+
+		spin_lock_bh(&trans->peer->lock);
+		trans->peer->net_error = err;
+
+		list_for_each_entry_safe(call, _n, &trans->peer->error_targets,
+					 error_link) {
+			write_lock(&call->state_lock);
+			if (call->state != RXRPC_CALL_COMPLETE &&
+			    call->state < RXRPC_CALL_NETWORK_ERROR) {
+				call->state = RXRPC_CALL_NETWORK_ERROR;
+				set_bit(RXRPC_CALL_RCVD_ERROR, &call->events);
+				schedule_work(&call->processor);
+			}
+			write_unlock(&call->state_lock);
+			list_del_init(&call->error_link);
+		}
+
+		spin_unlock_bh(&trans->peer->lock);
+	}
+
+	if (!skb_queue_empty(&trans->error_queue))
+		schedule_work(&trans->error_handler);
+
+	rxrpc_free_skb(skb);
+	rxrpc_put_transport(trans);
+	_leave("");
+}
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
new file mode 100644
index 0000000..323c345
--- /dev/null
+++ b/net/rxrpc/ar-input.c
@@ -0,0 +1,791 @@
+/* RxRPC packet reception
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/errqueue.h>
+#include <linux/udp.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/icmp.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include <net/ip.h>
+#include "ar-internal.h"
+
+unsigned long rxrpc_ack_timeout = 1;
+
+const char *rxrpc_pkts[] = {
+	"?00",
+	"DATA", "ACK", "BUSY", "ABORT", "ACKALL", "CHALL", "RESP", "DEBUG",
+	"?09", "?10", "?11", "?12", "?13", "?14", "?15"
+};
+
+/*
+ * queue a packet for recvmsg to pass to userspace
+ * - the caller must hold a lock on call->lock
+ * - must not be called with interrupts disabled (sk_filter() disables BH's)
+ * - eats the packet whether successful or not
+ * - there must be just one reference to the packet, which the caller passes to
+ *   this function
+ */
+int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
+			bool force, bool terminal)
+{
+	struct rxrpc_skb_priv *sp;
+	struct sock *sk;
+	int skb_len, ret;
+
+	_enter(",,%d,%d", force, terminal);
+
+	ASSERT(!irqs_disabled());
+
+	sp = rxrpc_skb(skb);
+	ASSERTCMP(sp->call, ==, call);
+
+	/* if we've already posted the terminal message for a call, then we
+	 * don't post any more */
+	if (test_bit(RXRPC_CALL_TERMINAL_MSG, &call->flags)) {
+		_debug("already terminated");
+		ASSERTCMP(call->state, >=, RXRPC_CALL_COMPLETE);
+		skb->destructor = NULL;
+		sp->call = NULL;
+		rxrpc_put_call(call);
+		rxrpc_free_skb(skb);
+		return 0;
+	}
+
+	sk = &call->socket->sk;
+
+	if (!force) {
+		/* cast skb->rcvbuf to unsigned...  It's pointless, but
+		 * reduces number of warnings when compiling with -W
+		 * --ANK */
+//		ret = -ENOBUFS;
+//		if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
+//		    (unsigned) sk->sk_rcvbuf)
+//			goto out;
+
+		ret = sk_filter(sk, skb);
+		if (ret < 0)
+			goto out;
+	}
+
+	spin_lock_bh(&sk->sk_receive_queue.lock);
+	if (!test_bit(RXRPC_CALL_TERMINAL_MSG, &call->flags) &&
+	    !test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
+	    call->socket->sk.sk_state != RXRPC_CLOSE) {
+		skb->destructor = rxrpc_packet_destructor;
+		skb->dev = NULL;
+		skb->sk = sk;
+		atomic_add(skb->truesize, &sk->sk_rmem_alloc);
+
+		/* Cache the SKB length before we tack it onto the receive
+		 * queue.  Once it is added it no longer belongs to us and
+		 * may be freed by other threads of control pulling packets
+		 * from the queue.
+		 */
+		skb_len = skb->len;
+
+		_net("post skb %p", skb);
+		__skb_queue_tail(&sk->sk_receive_queue, skb);
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_data_ready(sk, skb_len);
+
+		if (terminal) {
+			_debug("<<<< TERMINAL MESSAGE >>>>");
+			set_bit(RXRPC_CALL_TERMINAL_MSG, &call->flags);
+		}
+
+		skb = NULL;
+	} else {
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+	}
+	ret = 0;
+
+out:
+	/* release the socket buffer */
+	if (skb) {
+		skb->destructor = NULL;
+		sp->call = NULL;
+		rxrpc_put_call(call);
+		rxrpc_free_skb(skb);
+	}
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * process a DATA packet, posting the packet to the appropriate queue
+ * - eats the packet if successful
+ */
+static int rxrpc_fast_process_data(struct rxrpc_call *call,
+				   struct sk_buff *skb, u32 seq)
+{
+	struct rxrpc_skb_priv *sp;
+	bool terminal;
+	int ret, ackbit, ack;
+
+	_enter("{%u,%u},,{%u}", call->rx_data_post, call->rx_first_oos, seq);
+
+	sp = rxrpc_skb(skb);
+	ASSERTCMP(sp->call, ==, NULL);
+
+	spin_lock(&call->lock);
+
+	if (call->state > RXRPC_CALL_COMPLETE)
+		goto discard;
+
+	ASSERTCMP(call->rx_data_expect, >=, call->rx_data_post);
+	ASSERTCMP(call->rx_data_post, >=, call->rx_data_recv);
+	ASSERTCMP(call->rx_data_recv, >=, call->rx_data_eaten);
+
+	if (seq < call->rx_data_post) {
+		_debug("dup #%u [-%u]", seq, call->rx_data_post);
+		ack = RXRPC_ACK_DUPLICATE;
+		ret = -ENOBUFS;
+		goto discard_and_ack;
+	}
+
+	/* we may already have the packet in the out of sequence queue */
+	ackbit = seq - (call->rx_data_eaten + 1);
+	ASSERTCMP(ackbit, >=, 0);
+	if (__test_and_set_bit(ackbit, &call->ackr_window)) {
+		_debug("dup oos #%u [%u,%u]",
+		       seq, call->rx_data_eaten, call->rx_data_post);
+		ack = RXRPC_ACK_DUPLICATE;
+		goto discard_and_ack;
+	}
+
+	if (seq >= call->ackr_win_top) {
+		_debug("exceed #%u [%u]", seq, call->ackr_win_top);
+		__clear_bit(ackbit, &call->ackr_window);
+		ack = RXRPC_ACK_EXCEEDS_WINDOW;
+		goto discard_and_ack;
+	}
+
+	if (seq == call->rx_data_expect) {
+		clear_bit(RXRPC_CALL_EXPECT_OOS, &call->flags);
+		call->rx_data_expect++;
+	} else if (seq > call->rx_data_expect) {
+		_debug("oos #%u [%u]", seq, call->rx_data_expect);
+		call->rx_data_expect = seq + 1;
+		if (test_and_set_bit(RXRPC_CALL_EXPECT_OOS, &call->flags)) {
+			ack = RXRPC_ACK_OUT_OF_SEQUENCE;
+			goto enqueue_and_ack;
+		}
+		goto enqueue_packet;
+	}
+
+	if (seq != call->rx_data_post) {
+		_debug("ahead #%u [%u]", seq, call->rx_data_post);
+		goto enqueue_packet;
+	}
+
+	if (test_bit(RXRPC_CALL_RCVD_LAST, &call->flags))
+		goto protocol_error;
+
+	/* if the packet need security things doing to it, then it goes down
+	 * the slow path */
+	if (call->conn->security)
+		goto enqueue_packet;
+
+	sp->call = call;
+	rxrpc_get_call(call);
+	terminal = ((sp->hdr.flags & RXRPC_LAST_PACKET) &&
+		    !(sp->hdr.flags & RXRPC_CLIENT_INITIATED));
+	ret = rxrpc_queue_rcv_skb(call, skb, false, terminal);
+	if (ret < 0) {
+		if (ret == -ENOMEM || ret == -ENOBUFS) {
+			__clear_bit(ackbit, &call->ackr_window);
+			ack = RXRPC_ACK_NOSPACE;
+			goto discard_and_ack;
+		}
+		goto out;
+	}
+
+	skb = NULL;
+
+	_debug("post #%u", seq);
+	ASSERTCMP(call->rx_data_post, ==, seq);
+	call->rx_data_post++;
+
+	if (sp->hdr.flags & RXRPC_LAST_PACKET)
+		set_bit(RXRPC_CALL_RCVD_LAST, &call->flags);
+
+	/* if we've reached an out of sequence packet then we need to drain
+	 * that queue into the socket Rx queue now */
+	if (call->rx_data_post == call->rx_first_oos) {
+		_debug("drain rx oos now");
+		read_lock(&call->state_lock);
+		if (call->state < RXRPC_CALL_COMPLETE &&
+		    !test_and_set_bit(RXRPC_CALL_DRAIN_RX_OOS, &call->events))
+			schedule_work(&call->processor);
+		read_unlock(&call->state_lock);
+	}
+
+	spin_unlock(&call->lock);
+	atomic_inc(&call->ackr_not_idle);
+	rxrpc_propose_ACK(call, RXRPC_ACK_DELAY, sp->hdr.serial, false);
+	_leave(" = 0 [posted]");
+	return 0;
+
+protocol_error:
+	ret = -EBADMSG;
+out:
+	spin_unlock(&call->lock);
+	_leave(" = %d", ret);
+	return ret;
+
+discard_and_ack:
+	_debug("discard and ACK packet %p", skb);
+	__rxrpc_propose_ACK(call, ack, sp->hdr.serial, true);
+discard:
+	spin_unlock(&call->lock);
+	rxrpc_free_skb(skb);
+	_leave(" = 0 [discarded]");
+	return 0;
+
+enqueue_and_ack:
+	__rxrpc_propose_ACK(call, ack, sp->hdr.serial, true);
+enqueue_packet:
+	_net("defer skb %p", skb);
+	spin_unlock(&call->lock);
+	skb_queue_tail(&call->rx_queue, skb);
+	atomic_inc(&call->ackr_not_idle);
+	read_lock(&call->state_lock);
+	if (call->state < RXRPC_CALL_DEAD)
+		schedule_work(&call->processor);
+	read_unlock(&call->state_lock);
+	_leave(" = 0 [queued]");
+	return 0;
+}
+
+/*
+ * assume an implicit ACKALL of the transmission phase of a client socket upon
+ * reception of the first reply packet
+ */
+static void rxrpc_assume_implicit_ackall(struct rxrpc_call *call, u32 serial)
+{
+	write_lock_bh(&call->state_lock);
+
+	switch (call->state) {
+	case RXRPC_CALL_CLIENT_AWAIT_REPLY:
+		call->state = RXRPC_CALL_CLIENT_RECV_REPLY;
+		call->acks_latest = serial;
+
+		_debug("implicit ACKALL %%%u", call->acks_latest);
+		set_bit(RXRPC_CALL_RCVD_ACKALL, &call->events);
+		write_unlock_bh(&call->state_lock);
+
+		if (try_to_del_timer_sync(&call->resend_timer) >= 0) {
+			clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events);
+			clear_bit(RXRPC_CALL_RESEND, &call->events);
+			clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
+		}
+		break;
+
+	default:
+		write_unlock_bh(&call->state_lock);
+		break;
+	}
+}
+
+/*
+ * post an incoming packet to the nominated call to deal with
+ * - must get rid of the sk_buff, either by freeing it or by queuing it
+ */
+void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	__be32 _abort_code;
+	u32 serial, hi_serial, seq, abort_code;
+
+	_enter("%p,%p", call, skb);
+
+	ASSERT(!irqs_disabled());
+
+#if 0 // INJECT RX ERROR
+	if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA) {
+		static int skip = 0;
+		if (++skip == 3) {
+			printk("DROPPED 3RD PACKET!!!!!!!!!!!!!\n");
+			skip = 0;
+			goto free_packet;
+		}
+	}
+#endif
+
+	/* track the latest serial number on this connection for ACK packet
+	 * information */
+	serial = ntohl(sp->hdr.serial);
+	hi_serial = atomic_read(&call->conn->hi_serial);
+	while (serial > hi_serial)
+		hi_serial = atomic_cmpxchg(&call->conn->hi_serial, hi_serial,
+					   serial);
+
+	/* request ACK generation for any ACK or DATA packet that requests
+	 * it */
+	if (sp->hdr.flags & RXRPC_REQUEST_ACK) {
+		_proto("ACK Requested on %%%u", serial);
+		rxrpc_propose_ACK(call, RXRPC_ACK_REQUESTED, sp->hdr.serial,
+				  !(sp->hdr.flags & RXRPC_MORE_PACKETS));
+	}
+
+	switch (sp->hdr.type) {
+	case RXRPC_PACKET_TYPE_ABORT:
+		_debug("abort");
+
+		if (skb_copy_bits(skb, 0, &_abort_code,
+				  sizeof(_abort_code)) < 0)
+			goto protocol_error;
+
+		abort_code = ntohl(_abort_code);
+		_proto("Rx ABORT %%%u { %x }", serial, abort_code);
+
+		write_lock_bh(&call->state_lock);
+		if (call->state < RXRPC_CALL_COMPLETE) {
+			call->state = RXRPC_CALL_REMOTELY_ABORTED;
+			call->abort_code = abort_code;
+			set_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
+			schedule_work(&call->processor);
+		}
+		goto free_packet_unlock;
+
+	case RXRPC_PACKET_TYPE_BUSY:
+		_proto("Rx BUSY %%%u", serial);
+
+		if (call->conn->out_clientflag)
+			goto protocol_error;
+
+		write_lock_bh(&call->state_lock);
+		switch (call->state) {
+		case RXRPC_CALL_CLIENT_SEND_REQUEST:
+			call->state = RXRPC_CALL_SERVER_BUSY;
+			set_bit(RXRPC_CALL_RCVD_BUSY, &call->events);
+			schedule_work(&call->processor);
+		case RXRPC_CALL_SERVER_BUSY:
+			goto free_packet_unlock;
+		default:
+			goto protocol_error_locked;
+		}
+
+	default:
+		_proto("Rx %s %%%u", rxrpc_pkts[sp->hdr.type], serial);
+		goto protocol_error;
+
+	case RXRPC_PACKET_TYPE_DATA:
+		seq = ntohl(sp->hdr.seq);
+
+		_proto("Rx DATA %%%u { #%u }", serial, seq);
+
+		if (seq == 0)
+			goto protocol_error;
+
+		call->ackr_prev_seq = sp->hdr.seq;
+
+		/* received data implicitly ACKs all of the request packets we
+		 * sent when we're acting as a client */
+		if (call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY)
+			rxrpc_assume_implicit_ackall(call, serial);
+
+		switch (rxrpc_fast_process_data(call, skb, seq)) {
+		case 0:
+			skb = NULL;
+			goto done;
+
+		default:
+			BUG();
+
+			/* data packet received beyond the last packet */
+		case -EBADMSG:
+			goto protocol_error;
+		}
+
+	case RXRPC_PACKET_TYPE_ACK:
+		/* ACK processing is done in process context */
+		read_lock_bh(&call->state_lock);
+		if (call->state < RXRPC_CALL_DEAD) {
+			skb_queue_tail(&call->rx_queue, skb);
+			schedule_work(&call->processor);
+			skb = NULL;
+		}
+		read_unlock_bh(&call->state_lock);
+		goto free_packet;
+	}
+
+protocol_error:
+	_debug("protocol error");
+	write_lock_bh(&call->state_lock);
+protocol_error_locked:
+	if (call->state <= RXRPC_CALL_COMPLETE) {
+		call->state = RXRPC_CALL_LOCALLY_ABORTED;
+		call->abort_code = RX_PROTOCOL_ERROR;
+		set_bit(RXRPC_CALL_ABORT, &call->events);
+		schedule_work(&call->processor);
+	}
+free_packet_unlock:
+	write_unlock_bh(&call->state_lock);
+free_packet:
+	rxrpc_free_skb(skb);
+done:
+	_leave("");
+}
+
+/*
+ * split up a jumbo data packet
+ */
+static void rxrpc_process_jumbo_packet(struct rxrpc_call *call,
+				       struct sk_buff *jumbo)
+{
+	struct rxrpc_jumbo_header jhdr;
+	struct rxrpc_skb_priv *sp;
+	struct sk_buff *part;
+
+	_enter(",{%u,%u}", jumbo->data_len, jumbo->len);
+
+	sp = rxrpc_skb(jumbo);
+
+	do {
+		sp->hdr.flags &= ~RXRPC_JUMBO_PACKET;
+
+		/* make a clone to represent the first subpacket in what's left
+		 * of the jumbo packet */
+		part = skb_clone(jumbo, GFP_ATOMIC);
+		if (!part) {
+			/* simply ditch the tail in the event of ENOMEM */
+			pskb_trim(jumbo, RXRPC_JUMBO_DATALEN);
+			break;
+		}
+		rxrpc_new_skb(part);
+
+		pskb_trim(part, RXRPC_JUMBO_DATALEN);
+
+		if (!pskb_pull(jumbo, RXRPC_JUMBO_DATALEN))
+			goto protocol_error;
+
+		if (skb_copy_bits(jumbo, 0, &jhdr, sizeof(jhdr)) < 0)
+			goto protocol_error;
+		if (!pskb_pull(jumbo, sizeof(jhdr)))
+			BUG();
+
+		sp->hdr.seq	= htonl(ntohl(sp->hdr.seq) + 1);
+		sp->hdr.serial	= htonl(ntohl(sp->hdr.serial) + 1);
+		sp->hdr.flags	= jhdr.flags;
+		sp->hdr._rsvd	= jhdr._rsvd;
+
+		_proto("Rx DATA Jumbo %%%u", ntohl(sp->hdr.serial) - 1);
+
+		rxrpc_fast_process_packet(call, part);
+		part = NULL;
+
+	} while (sp->hdr.flags & RXRPC_JUMBO_PACKET);
+
+	rxrpc_fast_process_packet(call, jumbo);
+	_leave("");
+	return;
+
+protocol_error:
+	_debug("protocol error");
+	rxrpc_free_skb(part);
+	rxrpc_free_skb(jumbo);
+	write_lock_bh(&call->state_lock);
+	if (call->state <= RXRPC_CALL_COMPLETE) {
+		call->state = RXRPC_CALL_LOCALLY_ABORTED;
+		call->abort_code = RX_PROTOCOL_ERROR;
+		set_bit(RXRPC_CALL_ABORT, &call->events);
+		schedule_work(&call->processor);
+	}
+	write_unlock_bh(&call->state_lock);
+	_leave("");
+}
+
+/*
+ * post an incoming packet to the appropriate call/socket to deal with
+ * - must get rid of the sk_buff, either by freeing it or by queuing it
+ */
+static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
+				      struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp;
+	struct rxrpc_call *call;
+	struct rb_node *p;
+	__be32 call_id;
+
+	_enter("%p,%p", conn, skb);
+
+	read_lock_bh(&conn->lock);
+
+	sp = rxrpc_skb(skb);
+
+	/* look at extant calls by channel number first */
+	call = conn->channels[ntohl(sp->hdr.cid) & RXRPC_CHANNELMASK];
+	if (!call || call->call_id != sp->hdr.callNumber)
+		goto call_not_extant;
+
+	_debug("extant call [%d]", call->state);
+	ASSERTCMP(call->conn, ==, conn);
+
+	read_lock(&call->state_lock);
+	switch (call->state) {
+	case RXRPC_CALL_LOCALLY_ABORTED:
+		if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events))
+			schedule_work(&call->processor);
+	case RXRPC_CALL_REMOTELY_ABORTED:
+	case RXRPC_CALL_NETWORK_ERROR:
+	case RXRPC_CALL_DEAD:
+		goto free_unlock;
+	default:
+		break;
+	}
+
+	read_unlock(&call->state_lock);
+	rxrpc_get_call(call);
+	read_unlock_bh(&conn->lock);
+
+	if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA &&
+	    sp->hdr.flags & RXRPC_JUMBO_PACKET)
+		rxrpc_process_jumbo_packet(call, skb);
+	else
+		rxrpc_fast_process_packet(call, skb);
+
+	rxrpc_put_call(call);
+	goto done;
+
+call_not_extant:
+	/* search the completed calls in case what we're dealing with is
+	 * there */
+	_debug("call not extant");
+
+	call_id = sp->hdr.callNumber;
+	p = conn->calls.rb_node;
+	while (p) {
+		call = rb_entry(p, struct rxrpc_call, conn_node);
+
+		if (call_id < call->call_id)
+			p = p->rb_left;
+		else if (call_id > call->call_id)
+			p = p->rb_right;
+		else
+			goto found_completed_call;
+	}
+
+dead_call:
+	/* it's a either a really old call that we no longer remember or its a
+	 * new incoming call */
+	read_unlock_bh(&conn->lock);
+
+	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED &&
+	    sp->hdr.seq == __constant_cpu_to_be32(1)) {
+		_debug("incoming call");
+		skb_queue_tail(&conn->trans->local->accept_queue, skb);
+		schedule_work(&conn->trans->local->acceptor);
+		goto done;
+	}
+
+	_debug("dead call");
+	skb->priority = RX_CALL_DEAD;
+	rxrpc_reject_packet(conn->trans->local, skb);
+	goto done;
+
+	/* resend last packet of a completed call
+	 * - client calls may have been aborted or ACK'd
+	 * - server calls may have been aborted
+	 */
+found_completed_call:
+	_debug("completed call");
+
+	if (atomic_read(&call->usage) == 0)
+		goto dead_call;
+
+	/* synchronise any state changes */
+	read_lock(&call->state_lock);
+	ASSERTIFCMP(call->state != RXRPC_CALL_CLIENT_FINAL_ACK,
+		    call->state, >=, RXRPC_CALL_COMPLETE);
+
+	if (call->state == RXRPC_CALL_LOCALLY_ABORTED ||
+	    call->state == RXRPC_CALL_REMOTELY_ABORTED ||
+	    call->state == RXRPC_CALL_DEAD) {
+		read_unlock(&call->state_lock);
+		goto dead_call;
+	}
+
+	if (call->conn->in_clientflag) {
+		read_unlock(&call->state_lock);
+		goto dead_call; /* complete server call */
+	}
+
+	_debug("final ack again");
+	rxrpc_get_call(call);
+	set_bit(RXRPC_CALL_ACK_FINAL, &call->events);
+	schedule_work(&call->processor);
+
+free_unlock:
+	read_unlock(&call->state_lock);
+	read_unlock_bh(&conn->lock);
+	rxrpc_free_skb(skb);
+done:
+	_leave("");
+}
+
+/*
+ * post connection-level events to the connection
+ * - this includes challenges, responses and some aborts
+ */
+static void rxrpc_post_packet_to_conn(struct rxrpc_connection *conn,
+				      struct sk_buff *skb)
+{
+	_enter("%p,%p", conn, skb);
+
+	atomic_inc(&conn->usage);
+	skb_queue_tail(&conn->rx_queue, skb);
+	schedule_work(&conn->processor);
+}
+
+/*
+ * handle data received on the local endpoint
+ * - may be called in interrupt context
+ */
+void rxrpc_data_ready(struct sock *sk, int count)
+{
+	struct rxrpc_connection *conn;
+	struct rxrpc_transport *trans;
+	struct rxrpc_skb_priv *sp;
+	struct rxrpc_local *local;
+	struct rxrpc_peer *peer;
+	struct sk_buff *skb;
+	int ret;
+
+	_enter("%p, %d", sk, count);
+
+	ASSERT(!irqs_disabled());
+
+	read_lock_bh(&rxrpc_local_lock);
+	local = sk->sk_user_data;
+	if (local && atomic_read(&local->usage) > 0)
+		rxrpc_get_local(local);
+	else
+		local = NULL;
+	read_unlock_bh(&rxrpc_local_lock);
+	if (!local) {
+		_leave(" [local dead]");
+		return;
+	}
+
+	skb = skb_recv_datagram(sk, 0, 1, &ret);
+	if (!skb) {
+		rxrpc_put_local(local);
+		if (ret == -EAGAIN)
+			return;
+		_debug("UDP socket error %d", ret);
+		return;
+	}
+
+	rxrpc_new_skb(skb);
+
+	_net("recv skb %p", skb);
+
+	/* we'll probably need to checksum it (didn't call sock_recvmsg) */
+	if (skb_checksum_complete(skb)) {
+		rxrpc_free_skb(skb);
+		rxrpc_put_local(local);
+		_leave(" [CSUM failed]");
+		return;
+	}
+
+	/* the socket buffer we have is owned by UDP, with UDP's data all over
+	 * it, but we really want our own */
+	skb_orphan(skb);
+	sp = rxrpc_skb(skb);
+	memset(sp, 0, sizeof(*sp));
+
+	_net("Rx UDP packet from %08x:%04hu",
+	     ntohl(ip_hdr(skb)->saddr), ntohs(udp_hdr(skb)->source));
+
+	/* dig out the RxRPC connection details */
+	if (skb_copy_bits(skb, sizeof(struct udphdr), &sp->hdr,
+			  sizeof(sp->hdr)) < 0)
+		goto bad_message;
+	if (!pskb_pull(skb, sizeof(struct udphdr) + sizeof(sp->hdr)))
+		BUG();
+
+	_net("Rx RxRPC %s ep=%x call=%x:%x",
+	     sp->hdr.flags & RXRPC_CLIENT_INITIATED ? "ToServer" : "ToClient",
+	     ntohl(sp->hdr.epoch),
+	     ntohl(sp->hdr.cid),
+	     ntohl(sp->hdr.callNumber));
+
+	if (sp->hdr.type == 0 || sp->hdr.type >= RXRPC_N_PACKET_TYPES) {
+		_proto("Rx Bad Packet Type %u", sp->hdr.type);
+		goto bad_message;
+	}
+
+	if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA &&
+	    (sp->hdr.callNumber == 0 || sp->hdr.seq == 0))
+		goto bad_message;
+
+	peer = rxrpc_find_peer(local, ip_hdr(skb)->saddr, udp_hdr(skb)->source);
+	if (IS_ERR(peer))
+		goto cant_route_call;
+
+	trans = rxrpc_find_transport(local, peer);
+	rxrpc_put_peer(peer);
+	if (!trans)
+		goto cant_route_call;
+
+	conn = rxrpc_find_connection(trans, &sp->hdr);
+	rxrpc_put_transport(trans);
+	if (!conn)
+		goto cant_route_call;
+
+	_debug("CONN %p {%d}", conn, conn->debug_id);
+
+	if (sp->hdr.callNumber == 0)
+		rxrpc_post_packet_to_conn(conn, skb);
+	else
+		rxrpc_post_packet_to_call(conn, skb);
+	rxrpc_put_connection(conn);
+	rxrpc_put_local(local);
+	return;
+
+cant_route_call:
+	_debug("can't route call");
+	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED &&
+	    sp->hdr.type == RXRPC_PACKET_TYPE_DATA) {
+		if (sp->hdr.seq == __constant_cpu_to_be32(1)) {
+			_debug("first packet");
+			skb_queue_tail(&local->accept_queue, skb);
+			schedule_work(&local->acceptor);
+			rxrpc_put_local(local);
+			_leave(" [incoming]");
+			return;
+		}
+		skb->priority = RX_INVALID_OPERATION;
+	} else {
+		skb->priority = RX_CALL_DEAD;
+	}
+
+	_debug("reject");
+	rxrpc_reject_packet(local, skb);
+	rxrpc_put_local(local);
+	_leave(" [no call]");
+	return;
+
+bad_message:
+	skb->priority = RX_PROTOCOL_ERROR;
+	rxrpc_reject_packet(local, skb);
+	rxrpc_put_local(local);
+	_leave(" [badmsg]");
+}
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
new file mode 100644
index 0000000..7bfbf47
--- /dev/null
+++ b/net/rxrpc/ar-internal.h
@@ -0,0 +1,842 @@
+/* AF_RXRPC internal definitions
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <rxrpc/packet.h>
+
+#if 0
+#define CHECK_SLAB_OKAY(X)				     \
+	BUG_ON(atomic_read((X)) >> (sizeof(atomic_t) - 2) == \
+	       (POISON_FREE << 8 | POISON_FREE))
+#else
+#define CHECK_SLAB_OKAY(X) do {} while(0)
+#endif
+
+extern atomic_t rxrpc_n_skbs;
+
+#define FCRYPT_BSIZE 8
+struct rxrpc_crypt {
+	union {
+		u8	x[FCRYPT_BSIZE];
+		u32	n[2];
+	};
+} __attribute__((aligned(8)));
+
+extern __be32 rxrpc_epoch;		/* local epoch for detecting local-end reset */
+extern atomic_t rxrpc_debug_id;		/* current debugging ID */
+
+/*
+ * sk_state for RxRPC sockets
+ */
+enum {
+	RXRPC_UNCONNECTED = 0,
+	RXRPC_CLIENT_BOUND,		/* client local address bound */
+	RXRPC_CLIENT_CONNECTED,		/* client is connected */
+	RXRPC_SERVER_BOUND,		/* server local address bound */
+	RXRPC_SERVER_LISTENING,		/* server listening for connections */
+	RXRPC_CLOSE,			/* socket is being closed */
+};
+
+/*
+ * RxRPC socket definition
+ */
+struct rxrpc_sock {
+	/* WARNING: sk has to be the first member */
+	struct sock		sk;
+	struct rxrpc_local	*local;		/* local endpoint */
+	struct rxrpc_transport	*trans;		/* transport handler */
+	struct rxrpc_conn_bundle *bundle;	/* virtual connection bundle */
+	struct rxrpc_connection	*conn;		/* exclusive virtual connection */
+	struct list_head	listen_link;	/* link in the local endpoint's listen list */
+	struct list_head	secureq;	/* calls awaiting connection security clearance */
+	struct list_head	acceptq;	/* calls awaiting acceptance */
+	struct key		*key;		/* security for this socket */
+	struct key		*securities;	/* list of server security descriptors */
+	struct rb_root		calls;		/* outstanding calls on this socket */
+	unsigned long		flags;
+#define RXRPC_SOCK_EXCLUSIVE_CONN	1	/* exclusive connection for a client socket */
+	rwlock_t		call_lock;	/* lock for calls */
+	u32			min_sec_level;	/* minimum security level */
+#define RXRPC_SECURITY_MAX	RXRPC_SECURITY_ENCRYPT
+	struct sockaddr_rxrpc	srx;		/* local address */
+	sa_family_t		proto;		/* protocol created with */
+	__be16			service_id;	/* service ID of local/remote service */
+};
+
+#define rxrpc_sk(__sk) container_of((__sk), struct rxrpc_sock, sk)
+
+/*
+ * RxRPC socket buffer private variables
+ * - max 48 bytes (struct sk_buff::cb)
+ */
+struct rxrpc_skb_priv {
+	struct rxrpc_call	*call;		/* call with which associated */
+	unsigned long		resend_at;	/* time in jiffies at which to resend */
+	union {
+		unsigned	offset;		/* offset into buffer of next read */
+		int		remain;		/* amount of space remaining for next write */
+		u32		error;		/* network error code */
+		bool		need_resend;	/* T if needs resending */
+	};
+
+	struct rxrpc_header	hdr;		/* RxRPC packet header from this packet */
+};
+
+#define rxrpc_skb(__skb) ((struct rxrpc_skb_priv *) &(__skb)->cb)
+
+enum {
+	RXRPC_SKB_MARK_DATA,		/* data message */
+	RXRPC_SKB_MARK_FINAL_ACK,	/* final ACK received message */
+	RXRPC_SKB_MARK_BUSY,		/* server busy message */
+	RXRPC_SKB_MARK_REMOTE_ABORT,	/* remote abort message */
+	RXRPC_SKB_MARK_NET_ERROR,	/* network error message */
+	RXRPC_SKB_MARK_LOCAL_ERROR,	/* local error message */
+	RXRPC_SKB_MARK_NEW_CALL,	/* local error message */
+};
+
+enum rxrpc_command {
+	RXRPC_CMD_SEND_DATA,		/* send data message */
+	RXRPC_CMD_SEND_ABORT,		/* request abort generation */
+	RXRPC_CMD_ACCEPT,		/* [server] accept incoming call */
+	RXRPC_CMD_REJECT_BUSY,		/* [server] reject a call as busy */
+};
+
+/*
+ * RxRPC security module interface
+ */
+struct rxrpc_security {
+	struct module		*owner;		/* providing module */
+	struct list_head	link;		/* link in master list */
+	const char		*name;		/* name of this service */
+	u8			security_index;	/* security type provided */
+
+	/* initialise a connection's security */
+	int (*init_connection_security)(struct rxrpc_connection *);
+
+	/* prime a connection's packet security */
+	void (*prime_packet_security)(struct rxrpc_connection *);
+
+	/* impose security on a packet */
+	int (*secure_packet)(const struct rxrpc_call *,
+			     struct sk_buff *,
+			     size_t,
+			     void *);
+
+	/* verify the security on a received packet */
+	int (*verify_packet)(const struct rxrpc_call *, struct sk_buff *,
+			     u32 *);
+
+	/* issue a challenge */
+	int (*issue_challenge)(struct rxrpc_connection *);
+
+	/* respond to a challenge */
+	int (*respond_to_challenge)(struct rxrpc_connection *,
+				    struct sk_buff *,
+				    u32 *);
+
+	/* verify a response */
+	int (*verify_response)(struct rxrpc_connection *,
+			       struct sk_buff *,
+			       u32 *);
+
+	/* clear connection security */
+	void (*clear)(struct rxrpc_connection *);
+};
+
+/*
+ * RxRPC local transport endpoint definition
+ * - matched by local port, address and protocol type
+ */
+struct rxrpc_local {
+	struct socket		*socket;	/* my UDP socket */
+	struct work_struct	destroyer;	/* endpoint destroyer */
+	struct work_struct	acceptor;	/* incoming call processor */
+	struct work_struct	rejecter;	/* packet reject writer */
+	struct list_head	services;	/* services listening on this endpoint */
+	struct list_head	link;		/* link in endpoint list */
+	struct rw_semaphore	defrag_sem;	/* control re-enablement of IP DF bit */
+	struct sk_buff_head	accept_queue;	/* incoming calls awaiting acceptance */
+	struct sk_buff_head	reject_queue;	/* packets awaiting rejection */
+	spinlock_t		lock;		/* access lock */
+	rwlock_t		services_lock;	/* lock for services list */
+	atomic_t		usage;
+	int			debug_id;	/* debug ID for printks */
+	volatile char		error_rcvd;	/* T if received ICMP error outstanding */
+	struct sockaddr_rxrpc	srx;		/* local address */
+};
+
+/*
+ * RxRPC remote transport endpoint definition
+ * - matched by remote port, address and protocol type
+ * - holds the connection ID counter for connections between the two endpoints
+ */
+struct rxrpc_peer {
+	struct work_struct	destroyer;	/* peer destroyer */
+	struct list_head	link;		/* link in master peer list */
+	struct list_head	error_targets;	/* targets for net error distribution */
+	spinlock_t		lock;		/* access lock */
+	atomic_t		usage;
+	unsigned		if_mtu;		/* interface MTU for this peer */
+	unsigned		mtu;		/* network MTU for this peer */
+	unsigned		maxdata;	/* data size (MTU - hdrsize) */
+	unsigned short		hdrsize;	/* header size (IP + UDP + RxRPC) */
+	int			debug_id;	/* debug ID for printks */
+	int			net_error;	/* network error distributed */
+	struct sockaddr_rxrpc	srx;		/* remote address */
+
+	/* calculated RTT cache */
+#define RXRPC_RTT_CACHE_SIZE 32
+	suseconds_t		rtt;		/* current RTT estimate (in uS) */
+	unsigned		rtt_point;	/* next entry at which to insert */
+	unsigned		rtt_usage;	/* amount of cache actually used */
+	suseconds_t		rtt_cache[RXRPC_RTT_CACHE_SIZE]; /* calculated RTT cache */
+};
+
+/*
+ * RxRPC point-to-point transport / connection manager definition
+ * - handles a bundle of connections between two endpoints
+ * - matched by { local, peer }
+ */
+struct rxrpc_transport {
+	struct rxrpc_local	*local;		/* local transport endpoint */
+	struct rxrpc_peer	*peer;		/* remote transport endpoint */
+	struct work_struct	error_handler;	/* network error distributor */
+	struct rb_root		bundles;	/* client connection bundles on this transport */
+	struct rb_root		client_conns;	/* client connections on this transport */
+	struct rb_root		server_conns;	/* server connections on this transport */
+	struct list_head	link;		/* link in master session list */
+	struct sk_buff_head	error_queue;	/* error packets awaiting processing */
+	time_t			put_time;	/* time at which to reap */
+	spinlock_t		client_lock;	/* client connection allocation lock */
+	rwlock_t		conn_lock;	/* lock for active/dead connections */
+	atomic_t		usage;
+	int			debug_id;	/* debug ID for printks */
+	unsigned int		conn_idcounter;	/* connection ID counter (client) */
+};
+
+/*
+ * RxRPC client connection bundle
+ * - matched by { transport, service_id, key }
+ */
+struct rxrpc_conn_bundle {
+	struct rb_node		node;		/* node in transport's lookup tree */
+	struct list_head	unused_conns;	/* unused connections in this bundle */
+	struct list_head	avail_conns;	/* available connections in this bundle */
+	struct list_head	busy_conns;	/* busy connections in this bundle */
+	struct key		*key;		/* security for this bundle */
+	wait_queue_head_t	chanwait;	/* wait for channel to become available */
+	atomic_t		usage;
+	int			debug_id;	/* debug ID for printks */
+	unsigned short		num_conns;	/* number of connections in this bundle */
+	__be16			service_id;	/* service ID */
+	uint8_t			security_ix;	/* security type */
+};
+
+/*
+ * RxRPC connection definition
+ * - matched by { transport, service_id, conn_id, direction, key }
+ * - each connection can only handle four simultaneous calls
+ */
+struct rxrpc_connection {
+	struct rxrpc_transport	*trans;		/* transport session */
+	struct rxrpc_conn_bundle *bundle;	/* connection bundle (client) */
+	struct work_struct	processor;	/* connection event processor */
+	struct rb_node		node;		/* node in transport's lookup tree */
+	struct list_head	link;		/* link in master connection list */
+	struct list_head	bundle_link;	/* link in bundle */
+	struct rb_root		calls;		/* calls on this connection */
+	struct sk_buff_head	rx_queue;	/* received conn-level packets */
+	struct rxrpc_call	*channels[RXRPC_MAXCALLS]; /* channels (active calls) */
+	struct rxrpc_security	*security;	/* applied security module */
+	struct key		*key;		/* security for this connection (client) */
+	struct key		*server_key;	/* security for this service */
+	struct crypto_blkcipher	*cipher;	/* encryption handle */
+	struct rxrpc_crypt	csum_iv;	/* packet checksum base */
+	unsigned long		events;
+#define RXRPC_CONN_CHALLENGE	0		/* send challenge packet */
+	time_t			put_time;	/* time at which to reap */
+	rwlock_t		lock;		/* access lock */
+	spinlock_t		state_lock;	/* state-change lock */
+	atomic_t		usage;
+	u32			real_conn_id;	/* connection ID (host-endian) */
+	enum {					/* current state of connection */
+		RXRPC_CONN_UNUSED,		/* - connection not yet attempted */
+		RXRPC_CONN_CLIENT,		/* - client connection */
+		RXRPC_CONN_SERVER_UNSECURED,	/* - server unsecured connection */
+		RXRPC_CONN_SERVER_CHALLENGING,	/* - server challenging for security */
+		RXRPC_CONN_SERVER,		/* - server secured connection */
+		RXRPC_CONN_REMOTELY_ABORTED,	/* - conn aborted by peer */
+		RXRPC_CONN_LOCALLY_ABORTED,	/* - conn aborted locally */
+		RXRPC_CONN_NETWORK_ERROR,	/* - conn terminated by network error */
+	} state;
+	int			error;		/* error code for local abort */
+	int			debug_id;	/* debug ID for printks */
+	unsigned		call_counter;	/* call ID counter */
+	atomic_t		serial;		/* packet serial number counter */
+	atomic_t		hi_serial;	/* highest serial number received */
+	u8			avail_calls;	/* number of calls available */
+	u8			size_align;	/* data size alignment (for security) */
+	u8			header_size;	/* rxrpc + security header size */
+	u8			security_size;	/* security header size */
+	u32			security_level;	/* security level negotiated */
+	u32			security_nonce;	/* response re-use preventer */
+
+	/* the following are all in net order */
+	__be32			epoch;		/* epoch of this connection */
+	__be32			cid;		/* connection ID */
+	__be16			service_id;	/* service ID */
+	u8			security_ix;	/* security type */
+	u8			in_clientflag;	/* RXRPC_CLIENT_INITIATED if we are server */
+	u8			out_clientflag;	/* RXRPC_CLIENT_INITIATED if we are client */
+};
+
+/*
+ * RxRPC call definition
+ * - matched by { connection, call_id }
+ */
+struct rxrpc_call {
+	struct rxrpc_connection	*conn;		/* connection carrying call */
+	struct rxrpc_sock	*socket;	/* socket responsible */
+	struct timer_list	lifetimer;	/* lifetime remaining on call */
+	struct timer_list	deadspan;	/* reap timer for re-ACK'ing, etc  */
+	struct timer_list	ack_timer;	/* ACK generation timer */
+	struct timer_list	resend_timer;	/* Tx resend timer */
+	struct work_struct	destroyer;	/* call destroyer */
+	struct work_struct	processor;	/* packet processor and ACK generator */
+	struct list_head	link;		/* link in master call list */
+	struct list_head	error_link;	/* link in error distribution list */
+	struct list_head	accept_link;	/* calls awaiting acceptance */
+	struct rb_node		sock_node;	/* node in socket call tree */
+	struct rb_node		conn_node;	/* node in connection call tree */
+	struct sk_buff_head	rx_queue;	/* received packets */
+	struct sk_buff_head	rx_oos_queue;	/* packets received out of sequence */
+	struct sk_buff		*tx_pending;	/* Tx socket buffer being filled */
+	wait_queue_head_t	tx_waitq;	/* wait for Tx window space to become available */
+	unsigned long		user_call_ID;	/* user-defined call ID */
+	unsigned long		creation_jif;	/* time of call creation */
+	unsigned long		flags;
+#define RXRPC_CALL_RELEASED	0	/* call has been released - no more message to userspace */
+#define RXRPC_CALL_TERMINAL_MSG	1	/* call has given the socket its final message */
+#define RXRPC_CALL_RCVD_LAST	2	/* all packets received */
+#define RXRPC_CALL_RUN_RTIMER	3	/* Tx resend timer started */
+#define RXRPC_CALL_TX_SOFT_ACK	4	/* sent some soft ACKs */
+#define RXRPC_CALL_PROC_BUSY	5	/* the processor is busy */
+#define RXRPC_CALL_INIT_ACCEPT	6	/* acceptance was initiated */
+#define RXRPC_CALL_HAS_USERID	7	/* has a user ID attached */
+#define RXRPC_CALL_EXPECT_OOS	8	/* expect out of sequence packets */
+	unsigned long		events;
+#define RXRPC_CALL_RCVD_ACKALL	0	/* ACKALL or reply received */
+#define RXRPC_CALL_RCVD_BUSY	1	/* busy packet received */
+#define RXRPC_CALL_RCVD_ABORT	2	/* abort packet received */
+#define RXRPC_CALL_RCVD_ERROR	3	/* network error received */
+#define RXRPC_CALL_ACK_FINAL	4	/* need to generate final ACK (and release call) */
+#define RXRPC_CALL_ACK		5	/* need to generate ACK */
+#define RXRPC_CALL_REJECT_BUSY	6	/* need to generate busy message */
+#define RXRPC_CALL_ABORT	7	/* need to generate abort */
+#define RXRPC_CALL_CONN_ABORT	8	/* local connection abort generated */
+#define RXRPC_CALL_RESEND_TIMER	9	/* Tx resend timer expired */
+#define RXRPC_CALL_RESEND	10	/* Tx resend required */
+#define RXRPC_CALL_DRAIN_RX_OOS	11	/* drain the Rx out of sequence queue */
+#define RXRPC_CALL_LIFE_TIMER	12	/* call's lifetimer ran out */
+#define RXRPC_CALL_ACCEPTED	13	/* incoming call accepted by userspace app */
+#define RXRPC_CALL_SECURED	14	/* incoming call's connection is now secure */
+#define RXRPC_CALL_POST_ACCEPT	15	/* need to post an "accept?" message to the app */
+#define RXRPC_CALL_RELEASE	16	/* need to release the call's resources */
+
+	spinlock_t		lock;
+	rwlock_t		state_lock;	/* lock for state transition */
+	atomic_t		usage;
+	atomic_t		sequence;	/* Tx data packet sequence counter */
+	u32			abort_code;	/* local/remote abort code */
+	enum {					/* current state of call */
+		RXRPC_CALL_CLIENT_SEND_REQUEST,	/* - client sending request phase */
+		RXRPC_CALL_CLIENT_AWAIT_REPLY,	/* - client awaiting reply */
+		RXRPC_CALL_CLIENT_RECV_REPLY,	/* - client receiving reply phase */
+		RXRPC_CALL_CLIENT_FINAL_ACK,	/* - client sending final ACK phase */
+		RXRPC_CALL_SERVER_SECURING,	/* - server securing request connection */
+		RXRPC_CALL_SERVER_ACCEPTING,	/* - server accepting request */
+		RXRPC_CALL_SERVER_RECV_REQUEST,	/* - server receiving request */
+		RXRPC_CALL_SERVER_ACK_REQUEST,	/* - server pending ACK of request */
+		RXRPC_CALL_SERVER_SEND_REPLY,	/* - server sending reply */
+		RXRPC_CALL_SERVER_AWAIT_ACK,	/* - server awaiting final ACK */
+		RXRPC_CALL_COMPLETE,		/* - call completed */
+		RXRPC_CALL_SERVER_BUSY,		/* - call rejected by busy server */
+		RXRPC_CALL_REMOTELY_ABORTED,	/* - call aborted by peer */
+		RXRPC_CALL_LOCALLY_ABORTED,	/* - call aborted locally on error or close */
+		RXRPC_CALL_NETWORK_ERROR,	/* - call terminated by network error */
+		RXRPC_CALL_DEAD,		/* - call is dead */
+	} state;
+	int			debug_id;	/* debug ID for printks */
+	u8			channel;	/* connection channel occupied by this call */
+
+	/* transmission-phase ACK management */
+	uint8_t			acks_head;	/* offset into window of first entry */
+	uint8_t			acks_tail;	/* offset into window of last entry */
+	uint8_t			acks_winsz;	/* size of un-ACK'd window */
+	uint8_t			acks_unacked;	/* lowest unacked packet in last ACK received */
+	int			acks_latest;	/* serial number of latest ACK received */
+	rxrpc_seq_t		acks_hard;	/* highest definitively ACK'd msg seq */
+	unsigned long		*acks_window;	/* sent packet window
+						 * - elements are pointers with LSB set if ACK'd
+						 */
+
+	/* receive-phase ACK management */
+	rxrpc_seq_t		rx_data_expect;	/* next data seq ID expected to be received */
+	rxrpc_seq_t		rx_data_post;	/* next data seq ID expected to be posted */
+	rxrpc_seq_t		rx_data_recv;	/* last data seq ID encountered by recvmsg */
+	rxrpc_seq_t		rx_data_eaten;	/* last data seq ID consumed by recvmsg */
+	rxrpc_seq_t		rx_first_oos;	/* first packet in rx_oos_queue (or 0) */
+	rxrpc_seq_t		ackr_win_top;	/* top of ACK window (rx_data_eaten is bottom) */
+	rxrpc_seq_net_t		ackr_prev_seq;	/* previous sequence number received */
+	uint8_t			ackr_reason;	/* reason to ACK */
+	__be32			ackr_serial;	/* serial of packet being ACK'd */
+	atomic_t		ackr_not_idle;	/* number of packets in Rx queue */
+
+	/* received packet records, 1 bit per record */
+#define RXRPC_ACKR_WINDOW_ASZ DIV_ROUND_UP(RXRPC_MAXACKS, BITS_PER_LONG)
+	unsigned long		ackr_window[RXRPC_ACKR_WINDOW_ASZ + 1];
+
+	/* the following should all be in net order */
+	__be32			cid;		/* connection ID + channel index  */
+	__be32			call_id;	/* call ID on connection  */
+};
+
+/*
+ * RxRPC key for Kerberos (type-2 security)
+ */
+struct rxkad_key {
+	u16	security_index;		/* RxRPC header security index */
+	u16	ticket_len;		/* length of ticket[] */
+	u32	expiry;			/* time at which expires */
+	u32	kvno;			/* key version number */
+	u8	session_key[8];		/* DES session key */
+	u8	ticket[0];		/* the encrypted ticket */
+};
+
+struct rxrpc_key_payload {
+	struct rxkad_key k;
+};
+
+/*
+ * locally abort an RxRPC call
+ */
+static inline void rxrpc_abort_call(struct rxrpc_call *call, u32 abort_code)
+{
+	write_lock_bh(&call->state_lock);
+	if (call->state < RXRPC_CALL_COMPLETE) {
+		call->abort_code = abort_code;
+		call->state = RXRPC_CALL_LOCALLY_ABORTED;
+		set_bit(RXRPC_CALL_ABORT, &call->events);
+	}
+	write_unlock_bh(&call->state_lock);
+}
+
+/*
+ * put a packet up for transport-level abort
+ */
+static inline
+void rxrpc_reject_packet(struct rxrpc_local *local, struct sk_buff *skb)
+{
+	CHECK_SLAB_OKAY(&local->usage);
+	if (!atomic_inc_not_zero(&local->usage)) {
+		printk("resurrected on reject\n");
+		BUG();
+	}
+	skb_queue_tail(&local->reject_queue, skb);
+	schedule_work(&local->rejecter);
+}
+
+/*
+ * ar-accept.c
+ */
+extern void rxrpc_accept_incoming_calls(struct work_struct *);
+extern int rxrpc_accept_call(struct rxrpc_sock *, unsigned long);
+
+/*
+ * ar-ack.c
+ */
+extern void __rxrpc_propose_ACK(struct rxrpc_call *, uint8_t, __be32, bool);
+extern void rxrpc_propose_ACK(struct rxrpc_call *, uint8_t, __be32, bool);
+extern void rxrpc_process_call(struct work_struct *);
+
+/*
+ * ar-call.c
+ */
+extern struct kmem_cache *rxrpc_call_jar;
+extern struct list_head rxrpc_calls;
+extern rwlock_t rxrpc_call_lock;
+
+extern struct rxrpc_call *rxrpc_get_client_call(struct rxrpc_sock *,
+						struct rxrpc_transport *,
+						struct rxrpc_conn_bundle *,
+						unsigned long, int, gfp_t);
+extern struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *,
+					      struct rxrpc_connection *,
+					      struct rxrpc_header *, gfp_t);
+extern struct rxrpc_call *rxrpc_find_server_call(struct rxrpc_sock *,
+						 unsigned long);
+extern void rxrpc_release_call(struct rxrpc_call *);
+extern void rxrpc_release_calls_on_socket(struct rxrpc_sock *);
+extern void __rxrpc_put_call(struct rxrpc_call *);
+extern void __exit rxrpc_destroy_all_calls(void);
+
+/*
+ * ar-connection.c
+ */
+extern struct list_head rxrpc_connections;
+extern rwlock_t rxrpc_connection_lock;
+
+extern struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *,
+						  struct rxrpc_transport *,
+						  struct key *,
+						  __be16, gfp_t);
+extern void rxrpc_put_bundle(struct rxrpc_transport *,
+			     struct rxrpc_conn_bundle *);
+extern int rxrpc_connect_call(struct rxrpc_sock *, struct rxrpc_transport *,
+			      struct rxrpc_conn_bundle *, struct rxrpc_call *,
+			      gfp_t);
+extern void rxrpc_put_connection(struct rxrpc_connection *);
+extern void __exit rxrpc_destroy_all_connections(void);
+extern struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *,
+						      struct rxrpc_header *);
+extern struct rxrpc_connection *
+rxrpc_incoming_connection(struct rxrpc_transport *, struct rxrpc_header *,
+			  gfp_t);
+
+/*
+ * ar-connevent.c
+ */
+extern void rxrpc_process_connection(struct work_struct *);
+extern void rxrpc_reject_packets(struct work_struct *);
+
+/*
+ * ar-error.c
+ */
+extern void rxrpc_UDP_error_report(struct sock *);
+extern void rxrpc_UDP_error_handler(struct work_struct *);
+
+/*
+ * ar-input.c
+ */
+extern unsigned long rxrpc_ack_timeout;
+extern const char *rxrpc_pkts[];
+
+extern void rxrpc_data_ready(struct sock *, int);
+extern int rxrpc_queue_rcv_skb(struct rxrpc_call *, struct sk_buff *, bool,
+			       bool);
+extern void rxrpc_fast_process_packet(struct rxrpc_call *, struct sk_buff *);
+
+/*
+ * ar-local.c
+ */
+extern rwlock_t rxrpc_local_lock;
+extern struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *);
+extern void rxrpc_put_local(struct rxrpc_local *);
+extern void __exit rxrpc_destroy_all_locals(void);
+
+/*
+ * ar-key.c
+ */
+extern struct key_type key_type_rxrpc;
+extern struct key_type key_type_rxrpc_s;
+
+extern int rxrpc_request_key(struct rxrpc_sock *, char __user *, int);
+extern int rxrpc_server_keyring(struct rxrpc_sock *, char __user *, int);
+extern int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *,
+				     time_t, u32);
+
+/*
+ * ar-output.c
+ */
+extern int rxrpc_resend_timeout;
+
+extern int rxrpc_send_packet(struct rxrpc_transport *, struct sk_buff *);
+extern int rxrpc_client_sendmsg(struct kiocb *, struct rxrpc_sock *,
+				struct rxrpc_transport *, struct msghdr *,
+				size_t);
+extern int rxrpc_server_sendmsg(struct kiocb *, struct rxrpc_sock *,
+				struct msghdr *, size_t);
+
+/*
+ * ar-peer.c
+ */
+extern struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *, gfp_t);
+extern void rxrpc_put_peer(struct rxrpc_peer *);
+extern struct rxrpc_peer *rxrpc_find_peer(struct rxrpc_local *,
+					  __be32, __be16);
+extern void __exit rxrpc_destroy_all_peers(void);
+
+/*
+ * ar-proc.c
+ */
+extern const char *rxrpc_call_states[];
+extern struct file_operations rxrpc_call_seq_fops;
+extern struct file_operations rxrpc_connection_seq_fops;
+
+/*
+ * ar-recvmsg.c
+ */
+extern int rxrpc_recvmsg(struct kiocb *, struct socket *, struct msghdr *,
+			 size_t, int);
+
+/*
+ * ar-security.c
+ */
+extern int rxrpc_register_security(struct rxrpc_security *);
+extern void rxrpc_unregister_security(struct rxrpc_security *);
+extern int rxrpc_init_client_conn_security(struct rxrpc_connection *);
+extern int rxrpc_init_server_conn_security(struct rxrpc_connection *);
+extern int rxrpc_secure_packet(const struct rxrpc_call *, struct sk_buff *,
+			       size_t, void *);
+extern int rxrpc_verify_packet(const struct rxrpc_call *, struct sk_buff *,
+			       u32 *);
+extern void rxrpc_clear_conn_security(struct rxrpc_connection *);
+
+/*
+ * ar-skbuff.c
+ */
+extern void rxrpc_packet_destructor(struct sk_buff *);
+
+/*
+ * ar-transport.c
+ */
+extern struct rxrpc_transport *rxrpc_get_transport(struct rxrpc_local *,
+						   struct rxrpc_peer *,
+						   gfp_t);
+extern void rxrpc_put_transport(struct rxrpc_transport *);
+extern void __exit rxrpc_destroy_all_transports(void);
+extern struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
+						    struct rxrpc_peer *);
+
+/*
+ * debug tracing
+ */
+extern unsigned rxrpc_debug;
+
+#define dbgprintk(FMT,...) \
+	printk("[%x%-6.6s] "FMT"\n", smp_processor_id(), current->comm ,##__VA_ARGS__)
+
+/* make sure we maintain the format strings, even when debugging is disabled */
+static inline __attribute__((format(printf,1,2)))
+void _dbprintk(const char *fmt, ...)
+{
+}
+
+#define kenter(FMT,...)	dbgprintk("==> %s("FMT")",__FUNCTION__ ,##__VA_ARGS__)
+#define kleave(FMT,...)	dbgprintk("<== %s()"FMT"",__FUNCTION__ ,##__VA_ARGS__)
+#define kdebug(FMT,...)	dbgprintk("    "FMT ,##__VA_ARGS__)
+#define kproto(FMT,...)	dbgprintk("### "FMT ,##__VA_ARGS__)
+#define knet(FMT,...)	dbgprintk("@@@ "FMT ,##__VA_ARGS__)
+
+
+#if defined(__KDEBUG)
+#define _enter(FMT,...)	kenter(FMT,##__VA_ARGS__)
+#define _leave(FMT,...)	kleave(FMT,##__VA_ARGS__)
+#define _debug(FMT,...)	kdebug(FMT,##__VA_ARGS__)
+#define _proto(FMT,...)	kproto(FMT,##__VA_ARGS__)
+#define _net(FMT,...)	knet(FMT,##__VA_ARGS__)
+
+#elif defined(CONFIG_AF_RXRPC_DEBUG)
+#define RXRPC_DEBUG_KENTER	0x01
+#define RXRPC_DEBUG_KLEAVE	0x02
+#define RXRPC_DEBUG_KDEBUG	0x04
+#define RXRPC_DEBUG_KPROTO	0x08
+#define RXRPC_DEBUG_KNET	0x10
+
+#define _enter(FMT,...)					\
+do {							\
+	if (unlikely(rxrpc_debug & RXRPC_DEBUG_KENTER))	\
+		kenter(FMT,##__VA_ARGS__);		\
+} while (0)
+
+#define _leave(FMT,...)					\
+do {							\
+	if (unlikely(rxrpc_debug & RXRPC_DEBUG_KLEAVE))	\
+		kleave(FMT,##__VA_ARGS__);		\
+} while (0)
+
+#define _debug(FMT,...)					\
+do {							\
+	if (unlikely(rxrpc_debug & RXRPC_DEBUG_KDEBUG))	\
+		kdebug(FMT,##__VA_ARGS__);		\
+} while (0)
+
+#define _proto(FMT,...)					\
+do {							\
+	if (unlikely(rxrpc_debug & RXRPC_DEBUG_KPROTO))	\
+		kproto(FMT,##__VA_ARGS__);		\
+} while (0)
+
+#define _net(FMT,...)					\
+do {							\
+	if (unlikely(rxrpc_debug & RXRPC_DEBUG_KNET))	\
+		knet(FMT,##__VA_ARGS__);		\
+} while (0)
+
+#else
+#define _enter(FMT,...)	_dbprintk("==> %s("FMT")",__FUNCTION__ ,##__VA_ARGS__)
+#define _leave(FMT,...)	_dbprintk("<== %s()"FMT"",__FUNCTION__ ,##__VA_ARGS__)
+#define _debug(FMT,...)	_dbprintk("    "FMT ,##__VA_ARGS__)
+#define _proto(FMT,...)	_dbprintk("### "FMT ,##__VA_ARGS__)
+#define _net(FMT,...)	_dbprintk("@@@ "FMT ,##__VA_ARGS__)
+#endif
+
+/*
+ * debug assertion checking
+ */
+#if 1 // defined(__KDEBUGALL)
+
+#define ASSERT(X)						\
+do {								\
+	if (unlikely(!(X))) {					\
+		printk(KERN_ERR "\n");				\
+		printk(KERN_ERR "RxRPC: Assertion failed\n");	\
+		BUG();						\
+	}							\
+} while(0)
+
+#define ASSERTCMP(X, OP, Y)						\
+do {									\
+	if (unlikely(!((X) OP (Y)))) {					\
+		printk(KERN_ERR "\n");					\
+		printk(KERN_ERR "RxRPC: Assertion failed\n");		\
+		printk(KERN_ERR "%lu " #OP " %lu is false\n",		\
+		       (unsigned long)(X), (unsigned long)(Y));		\
+		printk(KERN_ERR "0x%lx " #OP " 0x%lx is false\n",	\
+		       (unsigned long)(X), (unsigned long)(Y));		\
+		BUG();							\
+	}								\
+} while(0)
+
+#define ASSERTIF(C, X)						\
+do {								\
+	if (unlikely((C) && !(X))) {				\
+		printk(KERN_ERR "\n");				\
+		printk(KERN_ERR "RxRPC: Assertion failed\n");	\
+		BUG();						\
+	}							\
+} while(0)
+
+#define ASSERTIFCMP(C, X, OP, Y)					\
+do {									\
+	if (unlikely((C) && !((X) OP (Y)))) {				\
+		printk(KERN_ERR "\n");					\
+		printk(KERN_ERR "RxRPC: Assertion failed\n");		\
+		printk(KERN_ERR "%lu " #OP " %lu is false\n",		\
+		       (unsigned long)(X), (unsigned long)(Y));		\
+		printk(KERN_ERR "0x%lx " #OP " 0x%lx is false\n",	\
+		       (unsigned long)(X), (unsigned long)(Y));		\
+		BUG();							\
+	}								\
+} while(0)
+
+#else
+
+#define ASSERT(X)				\
+do {						\
+} while(0)
+
+#define ASSERTCMP(X, OP, Y)			\
+do {						\
+} while(0)
+
+#define ASSERTIF(C, X)				\
+do {						\
+} while(0)
+
+#define ASSERTIFCMP(C, X, OP, Y)		\
+do {						\
+} while(0)
+
+#endif /* __KDEBUGALL */
+
+/*
+ * socket buffer accounting / leak finding
+ */
+static inline void __rxrpc_new_skb(struct sk_buff *skb, const char *fn)
+{
+	//_net("new skb %p %s [%d]", skb, fn, atomic_read(&rxrpc_n_skbs));
+	//atomic_inc(&rxrpc_n_skbs);
+}
+
+#define rxrpc_new_skb(skb) __rxrpc_new_skb((skb), __func__)
+
+static inline void __rxrpc_kill_skb(struct sk_buff *skb, const char *fn)
+{
+	//_net("kill skb %p %s [%d]", skb, fn, atomic_read(&rxrpc_n_skbs));
+	//atomic_dec(&rxrpc_n_skbs);
+}
+
+#define rxrpc_kill_skb(skb) __rxrpc_kill_skb((skb), __func__)
+
+static inline void __rxrpc_free_skb(struct sk_buff *skb, const char *fn)
+{
+	if (skb) {
+		CHECK_SLAB_OKAY(&skb->users);
+		//_net("free skb %p %s [%d]",
+		//     skb, fn, atomic_read(&rxrpc_n_skbs));
+		//atomic_dec(&rxrpc_n_skbs);
+		kfree_skb(skb);
+	}
+}
+
+#define rxrpc_free_skb(skb) __rxrpc_free_skb((skb), __func__)
+
+static inline void rxrpc_purge_queue(struct sk_buff_head *list)
+{
+	struct sk_buff *skb;
+	while ((skb = skb_dequeue((list))) != NULL)
+		rxrpc_free_skb(skb);
+}
+
+static inline void __rxrpc__atomic_inc(atomic_t *v)
+{
+	CHECK_SLAB_OKAY(v);
+	atomic_inc(v);
+}
+
+#define atomic_inc(v) __rxrpc__atomic_inc((v))
+
+static inline void __rxrpc__atomic_dec(atomic_t *v)
+{
+	CHECK_SLAB_OKAY(v);
+	atomic_dec(v);
+}
+
+#define atomic_dec(v) __rxrpc__atomic_dec((v))
+
+static inline int __rxrpc__atomic_dec_and_test(atomic_t *v)
+{
+	CHECK_SLAB_OKAY(v);
+	return atomic_dec_and_test(v);
+}
+
+#define atomic_dec_and_test(v) __rxrpc__atomic_dec_and_test((v))
+
+static inline void __rxrpc_get_local(struct rxrpc_local *local, const char *f)
+{
+	CHECK_SLAB_OKAY(&local->usage);
+	if (atomic_inc_return(&local->usage) == 1)
+		printk("resurrected (%s)\n", f);
+}
+
+#define rxrpc_get_local(LOCAL) __rxrpc_get_local((LOCAL), __func__)
+
+#define rxrpc_get_call(CALL)				\
+do {							\
+	CHECK_SLAB_OKAY(&(CALL)->usage);		\
+	if (atomic_inc_return(&(CALL)->usage) == 1)	\
+		BUG();					\
+} while(0)
+
+#define rxrpc_put_call(CALL)				\
+do {							\
+	__rxrpc_put_call(CALL);				\
+} while(0)
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
new file mode 100644
index 0000000..7e049ff
--- /dev/null
+++ b/net/rxrpc/ar-key.c
@@ -0,0 +1,334 @@
+/* RxRPC key management
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ *
+ * RxRPC keys should have a description of describing their purpose:
+ *	"afs@CAMBRIDGE.REDHAT.COM>
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/key.h>
+#include <linux/crypto.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include <keys/rxrpc-type.h>
+#include <keys/user-type.h>
+#include "ar-internal.h"
+
+static int rxrpc_instantiate(struct key *, const void *, size_t);
+static int rxrpc_instantiate_s(struct key *, const void *, size_t);
+static void rxrpc_destroy(struct key *);
+static void rxrpc_destroy_s(struct key *);
+static void rxrpc_describe(const struct key *, struct seq_file *);
+
+/*
+ * rxrpc defined keys take an arbitrary string as the description and an
+ * arbitrary blob of data as the payload
+ */
+struct key_type key_type_rxrpc = {
+	.name		= "rxrpc",
+	.instantiate	= rxrpc_instantiate,
+	.match		= user_match,
+	.destroy	= rxrpc_destroy,
+	.describe	= rxrpc_describe,
+};
+
+EXPORT_SYMBOL(key_type_rxrpc);
+
+/*
+ * rxrpc server defined keys take "<serviceId>:<securityIndex>" as the
+ * description and an 8-byte decryption key as the payload
+ */
+struct key_type key_type_rxrpc_s = {
+	.name		= "rxrpc_s",
+	.instantiate	= rxrpc_instantiate_s,
+	.match		= user_match,
+	.destroy	= rxrpc_destroy_s,
+	.describe	= rxrpc_describe,
+};
+
+/*
+ * instantiate an rxrpc defined key
+ * data should be of the form:
+ *	OFFSET	LEN	CONTENT
+ *	0	4	key interface version number
+ *	4	2	security index (type)
+ *	6	2	ticket length
+ *	8	4	key expiry time (time_t)
+ *	12	4	kvno
+ *	16	8	session key
+ *	24	[len]	ticket
+ *
+ * if no data is provided, then a no-security key is made
+ */
+static int rxrpc_instantiate(struct key *key, const void *data, size_t datalen)
+{
+	const struct rxkad_key *tsec;
+	struct rxrpc_key_payload *upayload;
+	size_t plen;
+	u32 kver;
+	int ret;
+
+	_enter("{%x},,%zu", key_serial(key), datalen);
+
+	/* handle a no-security key */
+	if (!data && datalen == 0)
+		return 0;
+
+	/* get the key interface version number */
+	ret = -EINVAL;
+	if (datalen <= 4 || !data)
+		goto error;
+	memcpy(&kver, data, sizeof(kver));
+	data += sizeof(kver);
+	datalen -= sizeof(kver);
+
+	_debug("KEY I/F VERSION: %u", kver);
+
+	ret = -EKEYREJECTED;
+	if (kver != 1)
+		goto error;
+
+	/* deal with a version 1 key */
+	ret = -EINVAL;
+	if (datalen < sizeof(*tsec))
+		goto error;
+
+	tsec = data;
+	if (datalen != sizeof(*tsec) + tsec->ticket_len)
+		goto error;
+
+	_debug("SCIX: %u", tsec->security_index);
+	_debug("TLEN: %u", tsec->ticket_len);
+	_debug("EXPY: %x", tsec->expiry);
+	_debug("KVNO: %u", tsec->kvno);
+	_debug("SKEY: %02x%02x%02x%02x%02x%02x%02x%02x",
+	       tsec->session_key[0], tsec->session_key[1],
+	       tsec->session_key[2], tsec->session_key[3],
+	       tsec->session_key[4], tsec->session_key[5],
+	       tsec->session_key[6], tsec->session_key[7]);
+	if (tsec->ticket_len >= 8)
+		_debug("TCKT: %02x%02x%02x%02x%02x%02x%02x%02x",
+		       tsec->ticket[0], tsec->ticket[1],
+		       tsec->ticket[2], tsec->ticket[3],
+		       tsec->ticket[4], tsec->ticket[5],
+		       tsec->ticket[6], tsec->ticket[7]);
+
+	ret = -EPROTONOSUPPORT;
+	if (tsec->security_index != 2)
+		goto error;
+
+	key->type_data.x[0] = tsec->security_index;
+
+	plen = sizeof(*upayload) + tsec->ticket_len;
+	ret = key_payload_reserve(key, plen);
+	if (ret < 0)
+		goto error;
+
+	ret = -ENOMEM;
+	upayload = kmalloc(plen, GFP_KERNEL);
+	if (!upayload)
+		goto error;
+
+	/* attach the data */
+	memcpy(&upayload->k, tsec, sizeof(*tsec));
+	memcpy(&upayload->k.ticket, (void *)tsec + sizeof(*tsec),
+	       tsec->ticket_len);
+	key->payload.data = upayload;
+	key->expiry = tsec->expiry;
+	ret = 0;
+
+error:
+	return ret;
+}
+
+/*
+ * instantiate a server secret key
+ * data should be a pointer to the 8-byte secret key
+ */
+static int rxrpc_instantiate_s(struct key *key, const void *data,
+			       size_t datalen)
+{
+	struct crypto_blkcipher *ci;
+
+	_enter("{%x},,%zu", key_serial(key), datalen);
+
+	if (datalen != 8)
+		return -EINVAL;
+
+	memcpy(&key->type_data, data, 8);
+
+	ci = crypto_alloc_blkcipher("pcbc(des)", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(ci)) {
+		_leave(" = %ld", PTR_ERR(ci));
+		return PTR_ERR(ci);
+	}
+
+	if (crypto_blkcipher_setkey(ci, data, 8) < 0)
+		BUG();
+
+	key->payload.data = ci;
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * dispose of the data dangling from the corpse of a rxrpc key
+ */
+static void rxrpc_destroy(struct key *key)
+{
+	kfree(key->payload.data);
+}
+
+/*
+ * dispose of the data dangling from the corpse of a rxrpc key
+ */
+static void rxrpc_destroy_s(struct key *key)
+{
+	if (key->payload.data) {
+		crypto_free_blkcipher(key->payload.data);
+		key->payload.data = NULL;
+	}
+}
+
+/*
+ * describe the rxrpc key
+ */
+static void rxrpc_describe(const struct key *key, struct seq_file *m)
+{
+	seq_puts(m, key->description);
+}
+
+/*
+ * grab the security key for a socket
+ */
+int rxrpc_request_key(struct rxrpc_sock *rx, char __user *optval, int optlen)
+{
+	struct key *key;
+	char *description;
+
+	_enter("");
+
+	if (optlen <= 0 || optlen > PAGE_SIZE - 1)
+		return -EINVAL;
+
+	description = kmalloc(optlen + 1, GFP_KERNEL);
+	if (!description)
+		return -ENOMEM;
+
+	if (copy_from_user(description, optval, optlen)) {
+		kfree(description);
+		return -EFAULT;
+	}
+	description[optlen] = 0;
+
+	key = request_key(&key_type_rxrpc, description, NULL);
+	if (IS_ERR(key)) {
+		kfree(description);
+		_leave(" = %ld", PTR_ERR(key));
+		return PTR_ERR(key);
+	}
+
+	rx->key = key;
+	kfree(description);
+	_leave(" = 0 [key %x]", key->serial);
+	return 0;
+}
+
+/*
+ * grab the security keyring for a server socket
+ */
+int rxrpc_server_keyring(struct rxrpc_sock *rx, char __user *optval,
+			 int optlen)
+{
+	struct key *key;
+	char *description;
+
+	_enter("");
+
+	if (optlen <= 0 || optlen > PAGE_SIZE - 1)
+		return -EINVAL;
+
+	description = kmalloc(optlen + 1, GFP_KERNEL);
+	if (!description)
+		return -ENOMEM;
+
+	if (copy_from_user(description, optval, optlen)) {
+		kfree(description);
+		return -EFAULT;
+	}
+	description[optlen] = 0;
+
+	key = request_key(&key_type_keyring, description, NULL);
+	if (IS_ERR(key)) {
+		kfree(description);
+		_leave(" = %ld", PTR_ERR(key));
+		return PTR_ERR(key);
+	}
+
+	rx->securities = key;
+	kfree(description);
+	_leave(" = 0 [key %x]", key->serial);
+	return 0;
+}
+
+/*
+ * generate a server data key
+ */
+int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
+			      const void *session_key,
+			      time_t expiry,
+			      u32 kvno)
+{
+	struct key *key;
+	int ret;
+
+	struct {
+		u32 kver;
+		struct rxkad_key tsec;
+	} data;
+
+	_enter("");
+
+	key = key_alloc(&key_type_rxrpc, "x", 0, 0, current, 0,
+			KEY_ALLOC_NOT_IN_QUOTA);
+	if (IS_ERR(key)) {
+		_leave(" = -ENOMEM [alloc %ld]", PTR_ERR(key));
+		return -ENOMEM;
+	}
+
+	_debug("key %d", key_serial(key));
+
+	data.kver = 1;
+	data.tsec.security_index = 2;
+	data.tsec.ticket_len = 0;
+	data.tsec.expiry = expiry;
+	data.tsec.kvno = 0;
+
+	memcpy(&data.tsec.session_key, session_key,
+	       sizeof(data.tsec.session_key));
+
+	ret = key_instantiate_and_link(key, &data, sizeof(data), NULL, NULL);
+	if (ret < 0)
+		goto error;
+
+	conn->key = key;
+	_leave(" = 0 [%d]", key_serial(key));
+	return 0;
+
+error:
+	key_revoke(key);
+	key_put(key);
+	_leave(" = -ENOMEM [ins %d]", ret);
+	return -ENOMEM;
+}
+
+EXPORT_SYMBOL(rxrpc_get_server_data_key);
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
new file mode 100644
index 0000000..a20a2c0
--- /dev/null
+++ b/net/rxrpc/ar-local.c
@@ -0,0 +1,309 @@
+/* AF_RXRPC local endpoint management
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+static LIST_HEAD(rxrpc_locals);
+DEFINE_RWLOCK(rxrpc_local_lock);
+static DECLARE_RWSEM(rxrpc_local_sem);
+static DECLARE_WAIT_QUEUE_HEAD(rxrpc_local_wq);
+
+static void rxrpc_destroy_local(struct work_struct *work);
+
+/*
+ * allocate a new local
+ */
+static
+struct rxrpc_local *rxrpc_alloc_local(struct sockaddr_rxrpc *srx)
+{
+	struct rxrpc_local *local;
+
+	local = kzalloc(sizeof(struct rxrpc_local), GFP_KERNEL);
+	if (local) {
+		INIT_WORK(&local->destroyer, &rxrpc_destroy_local);
+		INIT_WORK(&local->acceptor, &rxrpc_accept_incoming_calls);
+		INIT_WORK(&local->rejecter, &rxrpc_reject_packets);
+		INIT_LIST_HEAD(&local->services);
+		INIT_LIST_HEAD(&local->link);
+		init_rwsem(&local->defrag_sem);
+		skb_queue_head_init(&local->accept_queue);
+		skb_queue_head_init(&local->reject_queue);
+		spin_lock_init(&local->lock);
+		rwlock_init(&local->services_lock);
+		atomic_set(&local->usage, 1);
+		local->debug_id = atomic_inc_return(&rxrpc_debug_id);
+		memcpy(&local->srx, srx, sizeof(*srx));
+	}
+
+	_leave(" = %p", local);
+	return local;
+}
+
+/*
+ * create the local socket
+ * - must be called with rxrpc_local_sem writelocked
+ */
+static int rxrpc_create_local(struct rxrpc_local *local)
+{
+	struct sock *sock;
+	int ret, opt;
+
+	_enter("%p{%d}", local, local->srx.transport_type);
+
+	/* create a socket to represent the local endpoint */
+	ret = sock_create_kern(PF_INET, local->srx.transport_type, IPPROTO_UDP,
+			       &local->socket);
+	if (ret < 0) {
+		_leave(" = %d [socket]", ret);
+		return ret;
+	}
+
+	/* if a local address was supplied then bind it */
+	if (local->srx.transport_len > sizeof(sa_family_t)) {
+		_debug("bind");
+		ret = kernel_bind(local->socket,
+				  (struct sockaddr *) &local->srx.transport,
+				  local->srx.transport_len);
+		if (ret < 0) {
+			_debug("bind failed");
+			goto error;
+		}
+	}
+
+	/* we want to receive ICMP errors */
+	opt = 1;
+	ret = kernel_setsockopt(local->socket, SOL_IP, IP_RECVERR,
+				(char *) &opt, sizeof(opt));
+	if (ret < 0) {
+		_debug("setsockopt failed");
+		goto error;
+	}
+
+	/* we want to set the don't fragment bit */
+	opt = IP_PMTUDISC_DO;
+	ret = kernel_setsockopt(local->socket, SOL_IP, IP_MTU_DISCOVER,
+				(char *) &opt, sizeof(opt));
+	if (ret < 0) {
+		_debug("setsockopt failed");
+		goto error;
+	}
+
+	write_lock_bh(&rxrpc_local_lock);
+	list_add(&local->link, &rxrpc_locals);
+	write_unlock_bh(&rxrpc_local_lock);
+
+	/* set the socket up */
+	sock = local->socket->sk;
+	sock->sk_user_data	= local;
+	sock->sk_data_ready	= rxrpc_data_ready;
+	sock->sk_error_report	= rxrpc_UDP_error_report;
+	_leave(" = 0");
+	return 0;
+
+error:
+	local->socket->ops->shutdown(local->socket, 2);
+	local->socket->sk->sk_user_data = NULL;
+	sock_release(local->socket);
+	local->socket = NULL;
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * create a new local endpoint using the specified UDP address
+ */
+struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *srx)
+{
+	struct rxrpc_local *local;
+	int ret;
+
+	_enter("{%d,%u,%u.%u.%u.%u+%hu}",
+	       srx->transport_type,
+	       srx->transport.family,
+	       NIPQUAD(srx->transport.sin.sin_addr),
+	       ntohs(srx->transport.sin.sin_port));
+
+	down_write(&rxrpc_local_sem);
+
+	/* see if we have a suitable local local endpoint already */
+	read_lock_bh(&rxrpc_local_lock);
+
+	list_for_each_entry(local, &rxrpc_locals, link) {
+		_debug("CMP {%d,%u,%u.%u.%u.%u+%hu}",
+		       local->srx.transport_type,
+		       local->srx.transport.family,
+		       NIPQUAD(local->srx.transport.sin.sin_addr),
+		       ntohs(local->srx.transport.sin.sin_port));
+
+		if (local->srx.transport_type != srx->transport_type ||
+		    local->srx.transport.family != srx->transport.family)
+			continue;
+
+		switch (srx->transport.family) {
+		case AF_INET:
+			if (local->srx.transport.sin.sin_port !=
+			    srx->transport.sin.sin_port)
+				continue;
+			if (memcmp(&local->srx.transport.sin.sin_addr,
+				   &srx->transport.sin.sin_addr,
+				   sizeof(struct in_addr)) != 0)
+				continue;
+			goto found_local;
+
+		default:
+			BUG();
+		}
+	}
+
+	read_unlock_bh(&rxrpc_local_lock);
+
+	/* we didn't find one, so we need to create one */
+	local = rxrpc_alloc_local(srx);
+	if (!local) {
+		up_write(&rxrpc_local_sem);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	ret = rxrpc_create_local(local);
+	if (ret < 0) {
+		up_write(&rxrpc_local_sem);
+		kfree(local);
+		_leave(" = %d", ret);
+		return ERR_PTR(ret);
+	}
+
+	up_write(&rxrpc_local_sem);
+
+	_net("LOCAL new %d {%d,%u,%u.%u.%u.%u+%hu}",
+	     local->debug_id,
+	     local->srx.transport_type,
+	     local->srx.transport.family,
+	     NIPQUAD(local->srx.transport.sin.sin_addr),
+	     ntohs(local->srx.transport.sin.sin_port));
+
+	_leave(" = %p [new]", local);
+	return local;
+
+found_local:
+	rxrpc_get_local(local);
+	read_unlock_bh(&rxrpc_local_lock);
+	up_write(&rxrpc_local_sem);
+
+	_net("LOCAL old %d {%d,%u,%u.%u.%u.%u+%hu}",
+	     local->debug_id,
+	     local->srx.transport_type,
+	     local->srx.transport.family,
+	     NIPQUAD(local->srx.transport.sin.sin_addr),
+	     ntohs(local->srx.transport.sin.sin_port));
+
+	_leave(" = %p [reuse]", local);
+	return local;
+}
+
+/*
+ * release a local endpoint
+ */
+void rxrpc_put_local(struct rxrpc_local *local)
+{
+	_enter("%p{u=%d}", local, atomic_read(&local->usage));
+
+	ASSERTCMP(atomic_read(&local->usage), >, 0);
+
+	/* to prevent a race, the decrement and the dequeue must be effectively
+	 * atomic */
+	write_lock_bh(&rxrpc_local_lock);
+	if (unlikely(atomic_dec_and_test(&local->usage))) {
+		_debug("destroy local");
+		schedule_work(&local->destroyer);
+	}
+	write_unlock_bh(&rxrpc_local_lock);
+	_leave("");
+}
+
+/*
+ * destroy a local endpoint
+ */
+static void rxrpc_destroy_local(struct work_struct *work)
+{
+	struct rxrpc_local *local =
+		container_of(work, struct rxrpc_local, destroyer);
+
+	_enter("%p{%d}", local, atomic_read(&local->usage));
+
+	down_write(&rxrpc_local_sem);
+
+	write_lock_bh(&rxrpc_local_lock);
+	if (atomic_read(&local->usage) > 0) {
+		write_unlock_bh(&rxrpc_local_lock);
+		up_read(&rxrpc_local_sem);
+		_leave(" [resurrected]");
+		return;
+	}
+
+	list_del(&local->link);
+	local->socket->sk->sk_user_data = NULL;
+	write_unlock_bh(&rxrpc_local_lock);
+
+	downgrade_write(&rxrpc_local_sem);
+
+	ASSERT(list_empty(&local->services));
+	ASSERT(!work_pending(&local->acceptor));
+	ASSERT(!work_pending(&local->rejecter));
+
+	/* finish cleaning up the local descriptor */
+	rxrpc_purge_queue(&local->accept_queue);
+	rxrpc_purge_queue(&local->reject_queue);
+	local->socket->ops->shutdown(local->socket, 2);
+	sock_release(local->socket);
+
+	up_read(&rxrpc_local_sem);
+
+	_net("DESTROY LOCAL %d", local->debug_id);
+	kfree(local);
+
+	if (list_empty(&rxrpc_locals))
+		wake_up_all(&rxrpc_local_wq);
+
+	_leave("");
+}
+
+/*
+ * preemptively destroy all local local endpoint rather than waiting for
+ * them to be destroyed
+ */
+void __exit rxrpc_destroy_all_locals(void)
+{
+	DECLARE_WAITQUEUE(myself,current);
+
+	_enter("");
+
+	/* we simply have to wait for them to go away */
+	if (!list_empty(&rxrpc_locals)) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		add_wait_queue(&rxrpc_local_wq, &myself);
+
+		while (!list_empty(&rxrpc_locals)) {
+			schedule();
+			set_current_state(TASK_UNINTERRUPTIBLE);
+		}
+
+		remove_wait_queue(&rxrpc_local_wq, &myself);
+		set_current_state(TASK_RUNNING);
+	}
+
+	_leave("");
+}
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
new file mode 100644
index 0000000..67aa951
--- /dev/null
+++ b/net/rxrpc/ar-output.c
@@ -0,0 +1,658 @@
+/* RxRPC packet transmission
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/circ_buf.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+int rxrpc_resend_timeout = 4;
+
+static int rxrpc_send_data(struct kiocb *iocb,
+			   struct rxrpc_sock *rx,
+			   struct rxrpc_call *call,
+			   struct msghdr *msg, size_t len);
+
+/*
+ * extract control messages from the sendmsg() control buffer
+ */
+static int rxrpc_sendmsg_cmsg(struct rxrpc_sock *rx, struct msghdr *msg,
+			      unsigned long *user_call_ID,
+			      enum rxrpc_command *command,
+			      u32 *abort_code,
+			      bool server)
+{
+	struct cmsghdr *cmsg;
+	int len;
+
+	*command = RXRPC_CMD_SEND_DATA;
+
+	if (msg->msg_controllen == 0)
+		return -EINVAL;
+
+	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+		if (!CMSG_OK(msg, cmsg))
+			return -EINVAL;
+
+		len = cmsg->cmsg_len - CMSG_ALIGN(sizeof(struct cmsghdr));
+		_debug("CMSG %d, %d, %d",
+		       cmsg->cmsg_level, cmsg->cmsg_type, len);
+
+		if (cmsg->cmsg_level != SOL_RXRPC)
+			continue;
+
+		switch (cmsg->cmsg_type) {
+		case RXRPC_USER_CALL_ID:
+			if (msg->msg_flags & MSG_CMSG_COMPAT) {
+				if (len != sizeof(u32))
+					return -EINVAL;
+				*user_call_ID = *(u32 *) CMSG_DATA(cmsg);
+			} else {
+				if (len != sizeof(unsigned long))
+					return -EINVAL;
+				*user_call_ID = *(unsigned long *)
+					CMSG_DATA(cmsg);
+			}
+			_debug("User Call ID %lx", *user_call_ID);
+			break;
+
+		case RXRPC_ABORT:
+			if (*command != RXRPC_CMD_SEND_DATA)
+				return -EINVAL;
+			*command = RXRPC_CMD_SEND_ABORT;
+			if (len != sizeof(*abort_code))
+				return -EINVAL;
+			*abort_code = *(unsigned int *) CMSG_DATA(cmsg);
+			_debug("Abort %x", *abort_code);
+			if (*abort_code == 0)
+				return -EINVAL;
+			break;
+
+		case RXRPC_ACCEPT:
+			if (*command != RXRPC_CMD_SEND_DATA)
+				return -EINVAL;
+			*command = RXRPC_CMD_ACCEPT;
+			if (len != 0)
+				return -EINVAL;
+			if (!server)
+				return -EISCONN;
+			break;
+
+		default:
+			return -EINVAL;
+		}
+	}
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * abort a call, sending an ABORT packet to the peer
+ */
+static void rxrpc_send_abort(struct rxrpc_call *call, u32 abort_code)
+{
+	write_lock_bh(&call->state_lock);
+
+	if (call->state <= RXRPC_CALL_COMPLETE) {
+		call->state = RXRPC_CALL_LOCALLY_ABORTED;
+		call->abort_code = abort_code;
+		set_bit(RXRPC_CALL_ABORT, &call->events);
+		del_timer_sync(&call->resend_timer);
+		del_timer_sync(&call->ack_timer);
+		clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events);
+		clear_bit(RXRPC_CALL_ACK, &call->events);
+		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
+		schedule_work(&call->processor);
+	}
+
+	write_unlock_bh(&call->state_lock);
+}
+
+/*
+ * send a message forming part of a client call through an RxRPC socket
+ * - caller holds the socket locked
+ * - the socket may be either a client socket or a server socket
+ */
+int rxrpc_client_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
+			 struct rxrpc_transport *trans, struct msghdr *msg,
+			 size_t len)
+{
+	struct rxrpc_conn_bundle *bundle;
+	enum rxrpc_command cmd;
+	struct rxrpc_call *call;
+	unsigned long user_call_ID = 0;
+	struct key *key;
+	__be16 service_id;
+	u32 abort_code = 0;
+	int ret;
+
+	_enter("");
+
+	ASSERT(trans != NULL);
+
+	ret = rxrpc_sendmsg_cmsg(rx, msg, &user_call_ID, &cmd, &abort_code,
+				 false);
+	if (ret < 0)
+		return ret;
+
+	bundle = NULL;
+	if (trans) {
+		service_id = rx->service_id;
+		if (msg->msg_name) {
+			struct sockaddr_rxrpc *srx =
+				(struct sockaddr_rxrpc *) msg->msg_name;
+			service_id = htons(srx->srx_service);
+		}
+		key = rx->key;
+		if (key && !rx->key->payload.data)
+			key = NULL;
+		bundle = rxrpc_get_bundle(rx, trans, key, service_id,
+					  GFP_KERNEL);
+		if (IS_ERR(bundle))
+			return PTR_ERR(bundle);
+	}
+
+	call = rxrpc_get_client_call(rx, trans, bundle, user_call_ID,
+				     abort_code == 0, GFP_KERNEL);
+	if (trans)
+		rxrpc_put_bundle(trans, bundle);
+	if (IS_ERR(call)) {
+		_leave(" = %ld", PTR_ERR(call));
+		return PTR_ERR(call);
+	}
+
+	_debug("CALL %d USR %lx ST %d on CONN %p",
+	       call->debug_id, call->user_call_ID, call->state, call->conn);
+
+	if (call->state >= RXRPC_CALL_COMPLETE) {
+		/* it's too late for this call */
+		ret = -ESHUTDOWN;
+	} else if (cmd == RXRPC_CMD_SEND_ABORT) {
+		rxrpc_send_abort(call, abort_code);
+	} else if (cmd != RXRPC_CMD_SEND_DATA) {
+		ret = -EINVAL;
+	} else if (call->state != RXRPC_CALL_CLIENT_SEND_REQUEST) {
+		/* request phase complete for this client call */
+		ret = -EPROTO;
+	} else {
+		ret = rxrpc_send_data(iocb, rx, call, msg, len);
+	}
+
+	rxrpc_put_call(call);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * send a message through a server socket
+ * - caller holds the socket locked
+ */
+int rxrpc_server_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
+			 struct msghdr *msg, size_t len)
+{
+	enum rxrpc_command cmd;
+	struct rxrpc_call *call;
+	unsigned long user_call_ID = 0;
+	u32 abort_code = 0;
+	int ret;
+
+	_enter("");
+
+	ret = rxrpc_sendmsg_cmsg(rx, msg, &user_call_ID, &cmd, &abort_code,
+				 true);
+	if (ret < 0)
+		return ret;
+
+	if (cmd == RXRPC_CMD_ACCEPT)
+		return rxrpc_accept_call(rx, user_call_ID);
+
+	call = rxrpc_find_server_call(rx, user_call_ID);
+	if (!call)
+		return -EBADSLT;
+	if (call->state >= RXRPC_CALL_COMPLETE) {
+		ret = -ESHUTDOWN;
+		goto out;
+	}
+
+	switch (cmd) {
+	case RXRPC_CMD_SEND_DATA:
+		if (call->state != RXRPC_CALL_CLIENT_SEND_REQUEST &&
+		    call->state != RXRPC_CALL_SERVER_ACK_REQUEST &&
+		    call->state != RXRPC_CALL_SERVER_SEND_REPLY) {
+			/* Tx phase not yet begun for this call */
+			ret = -EPROTO;
+			break;
+		}
+
+		ret = rxrpc_send_data(iocb, rx, call, msg, len);
+		break;
+
+	case RXRPC_CMD_SEND_ABORT:
+		rxrpc_send_abort(call, abort_code);
+		break;
+	default:
+		BUG();
+	}
+
+	out:
+	rxrpc_put_call(call);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * send a packet through the transport endpoint
+ */
+int rxrpc_send_packet(struct rxrpc_transport *trans, struct sk_buff *skb)
+{
+	struct kvec iov[1];
+	struct msghdr msg;
+	int ret, opt;
+
+	_enter(",{%d}", skb->len);
+
+	iov[0].iov_base = skb->head;
+	iov[0].iov_len = skb->len;
+
+	msg.msg_name = &trans->peer->srx.transport.sin;
+	msg.msg_namelen = sizeof(trans->peer->srx.transport.sin);
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = 0;
+
+	/* send the packet with the don't fragment bit set if we currently
+	 * think it's small enough */
+	if (skb->len - sizeof(struct rxrpc_header) < trans->peer->maxdata) {
+		down_read(&trans->local->defrag_sem);
+		/* send the packet by UDP
+		 * - returns -EMSGSIZE if UDP would have to fragment the packet
+		 *   to go out of the interface
+		 *   - in which case, we'll have processed the ICMP error
+		 *     message and update the peer record
+		 */
+		ret = kernel_sendmsg(trans->local->socket, &msg, iov, 1,
+				     iov[0].iov_len);
+
+		up_read(&trans->local->defrag_sem);
+		if (ret == -EMSGSIZE)
+			goto send_fragmentable;
+
+		_leave(" = %d [%u]", ret, trans->peer->maxdata);
+		return ret;
+	}
+
+send_fragmentable:
+	/* attempt to send this message with fragmentation enabled */
+	_debug("send fragment");
+
+	down_write(&trans->local->defrag_sem);
+	opt = IP_PMTUDISC_DONT;
+	ret = kernel_setsockopt(trans->local->socket, SOL_IP, IP_MTU_DISCOVER,
+				(char *) &opt, sizeof(opt));
+	if (ret == 0) {
+		ret = kernel_sendmsg(trans->local->socket, &msg, iov, 1,
+				     iov[0].iov_len);
+
+		opt = IP_PMTUDISC_DO;
+		kernel_setsockopt(trans->local->socket, SOL_IP,
+				  IP_MTU_DISCOVER, (char *) &opt, sizeof(opt));
+	}
+
+	up_write(&trans->local->defrag_sem);
+	_leave(" = %d [frag %u]", ret, trans->peer->maxdata);
+	return ret;
+}
+
+/*
+ * wait for space to appear in the transmit/ACK window
+ * - caller holds the socket locked
+ */
+static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
+				    struct rxrpc_call *call,
+				    long *timeo)
+{
+	DECLARE_WAITQUEUE(myself, current);
+	int ret;
+
+	_enter(",{%d},%ld",
+	       CIRC_SPACE(call->acks_head, call->acks_tail, call->acks_winsz),
+	       *timeo);
+
+	add_wait_queue(&call->tx_waitq, &myself);
+
+	for (;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		ret = 0;
+		if (CIRC_SPACE(call->acks_head, call->acks_tail,
+			       call->acks_winsz) > 0)
+			break;
+		if (signal_pending(current)) {
+			ret = sock_intr_errno(*timeo);
+			break;
+		}
+
+		release_sock(&rx->sk);
+		*timeo = schedule_timeout(*timeo);
+		lock_sock(&rx->sk);
+	}
+
+	remove_wait_queue(&call->tx_waitq, &myself);
+	set_current_state(TASK_RUNNING);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * attempt to schedule an instant Tx resend
+ */
+static inline void rxrpc_instant_resend(struct rxrpc_call *call)
+{
+	read_lock_bh(&call->state_lock);
+	if (try_to_del_timer_sync(&call->resend_timer) >= 0) {
+		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
+		if (call->state < RXRPC_CALL_COMPLETE &&
+		    !test_and_set_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
+			schedule_work(&call->processor);
+	}
+	read_unlock_bh(&call->state_lock);
+}
+
+/*
+ * queue a packet for transmission, set the resend timer and attempt
+ * to send the packet immediately
+ */
+static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
+			       bool last)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	int ret;
+
+	_net("queue skb %p [%d]", skb, call->acks_head);
+
+	ASSERT(call->acks_window != NULL);
+	call->acks_window[call->acks_head] = (unsigned long) skb;
+	smp_wmb();
+	call->acks_head = (call->acks_head + 1) & (call->acks_winsz - 1);
+
+	if (last || call->state == RXRPC_CALL_SERVER_ACK_REQUEST) {
+		_debug("________awaiting reply/ACK__________");
+		write_lock_bh(&call->state_lock);
+		switch (call->state) {
+		case RXRPC_CALL_CLIENT_SEND_REQUEST:
+			call->state = RXRPC_CALL_CLIENT_AWAIT_REPLY;
+			break;
+		case RXRPC_CALL_SERVER_ACK_REQUEST:
+			call->state = RXRPC_CALL_SERVER_SEND_REPLY;
+			if (!last)
+				break;
+		case RXRPC_CALL_SERVER_SEND_REPLY:
+			call->state = RXRPC_CALL_SERVER_AWAIT_ACK;
+			break;
+		default:
+			break;
+		}
+		write_unlock_bh(&call->state_lock);
+	}
+
+	_proto("Tx DATA %%%u { #%u }",
+	       ntohl(sp->hdr.serial), ntohl(sp->hdr.seq));
+
+	sp->need_resend = 0;
+	sp->resend_at = jiffies + rxrpc_resend_timeout * HZ;
+	if (!test_and_set_bit(RXRPC_CALL_RUN_RTIMER, &call->flags)) {
+		_debug("run timer");
+		call->resend_timer.expires = sp->resend_at;
+		add_timer(&call->resend_timer);
+	}
+
+	/* attempt to cancel the rx-ACK timer, deferring reply transmission if
+	 * we're ACK'ing the request phase of an incoming call */
+	ret = -EAGAIN;
+	if (try_to_del_timer_sync(&call->ack_timer) >= 0) {
+		/* the packet may be freed by rxrpc_process_call() before this
+		 * returns */
+		ret = rxrpc_send_packet(call->conn->trans, skb);
+		_net("sent skb %p", skb);
+	} else {
+		_debug("failed to delete ACK timer");
+	}
+
+	if (ret < 0) {
+		_debug("need instant resend %d", ret);
+		sp->need_resend = 1;
+		rxrpc_instant_resend(call);
+	}
+
+	_leave("");
+}
+
+/*
+ * send data through a socket
+ * - must be called in process context
+ * - caller holds the socket locked
+ */
+static int rxrpc_send_data(struct kiocb *iocb,
+			   struct rxrpc_sock *rx,
+			   struct rxrpc_call *call,
+			   struct msghdr *msg, size_t len)
+{
+	struct rxrpc_skb_priv *sp;
+	unsigned char __user *from;
+	struct sk_buff *skb;
+	struct iovec *iov;
+	struct sock *sk = &rx->sk;
+	long timeo;
+	bool more;
+	int ret, ioc, segment, copied;
+
+	_enter(",,,{%zu},%zu", msg->msg_iovlen, len);
+
+	timeo = sock_sndtimeo(sk, msg->msg_flags & MSG_DONTWAIT);
+
+	/* this should be in poll */
+	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+
+	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
+		return -EPIPE;
+
+	iov = msg->msg_iov;
+	ioc = msg->msg_iovlen - 1;
+	from = iov->iov_base;
+	segment = iov->iov_len;
+	iov++;
+	more = msg->msg_flags & MSG_MORE;
+
+	skb = call->tx_pending;
+	call->tx_pending = NULL;
+
+	copied = 0;
+	do {
+		int copy;
+
+		if (segment > len)
+			segment = len;
+
+		_debug("SEGMENT %d @%p", segment, from);
+
+		if (!skb) {
+			size_t size, chunk, max, space;
+
+			_debug("alloc");
+
+			if (CIRC_SPACE(call->acks_head, call->acks_tail,
+				       call->acks_winsz) <= 0) {
+				ret = -EAGAIN;
+				if (msg->msg_flags & MSG_DONTWAIT)
+					goto maybe_error;
+				ret = rxrpc_wait_for_tx_window(rx, call,
+							       &timeo);
+				if (ret < 0)
+					goto maybe_error;
+			}
+
+			max = call->conn->trans->peer->maxdata;
+			max -= call->conn->security_size;
+			max &= ~(call->conn->size_align - 1UL);
+
+			chunk = max;
+			if (chunk > len)
+				chunk = len;
+
+			space = chunk + call->conn->size_align;
+			space &= ~(call->conn->size_align - 1UL);
+
+			size = space + call->conn->header_size;
+
+			_debug("SIZE: %zu/%zu/%zu", chunk, space, size);
+
+			/* create a buffer that we can retain until it's ACK'd */
+			skb = sock_alloc_send_skb(
+				sk, size, msg->msg_flags & MSG_DONTWAIT, &ret);
+			if (!skb)
+				goto maybe_error;
+
+			rxrpc_new_skb(skb);
+
+			_debug("ALLOC SEND %p", skb);
+
+			ASSERTCMP(skb->mark, ==, 0);
+
+			_debug("HS: %u", call->conn->header_size);
+			skb_reserve(skb, call->conn->header_size);
+			skb->len += call->conn->header_size;
+
+			sp = rxrpc_skb(skb);
+			sp->remain = chunk;
+			if (sp->remain > skb_tailroom(skb))
+				sp->remain = skb_tailroom(skb);
+
+			_net("skb: hr %d, tr %d, hl %d, rm %d",
+			       skb_headroom(skb),
+			       skb_tailroom(skb),
+			       skb_headlen(skb),
+			       sp->remain);
+
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		}
+
+		_debug("append");
+		sp = rxrpc_skb(skb);
+
+		/* append next segment of data to the current buffer */
+		copy = skb_tailroom(skb);
+		ASSERTCMP(copy, >, 0);
+		if (copy > segment)
+			copy = segment;
+		if (copy > sp->remain)
+			copy = sp->remain;
+
+		_debug("add");
+		ret = skb_add_data(skb, from, copy);
+		_debug("added");
+		if (ret < 0)
+			goto efault;
+		sp->remain -= copy;
+		skb->mark += copy;
+
+		len -= copy;
+		segment -= copy;
+		from += copy;
+		while (segment == 0 && ioc > 0) {
+			from = iov->iov_base;
+			segment = iov->iov_len;
+			iov++;
+			ioc--;
+		}
+		if (len == 0) {
+			segment = 0;
+			ioc = 0;
+		}
+
+		/* check for the far side aborting the call or a network error
+		 * occurring */
+		if (call->state > RXRPC_CALL_COMPLETE)
+			goto call_aborted;
+
+		/* add the packet to the send queue if it's now full */
+		if (sp->remain <= 0 || (segment == 0 && !more)) {
+			struct rxrpc_connection *conn = call->conn;
+			size_t pad;
+
+			/* pad out if we're using security */
+			if (conn->security) {
+				pad = conn->security_size + skb->mark;
+				pad = conn->size_align - pad;
+				pad &= conn->size_align - 1;
+				_debug("pad %zu", pad);
+				if (pad)
+					memset(skb_put(skb, pad), 0, pad);
+			}
+
+			sp->hdr.epoch = conn->epoch;
+			sp->hdr.cid = call->cid;
+			sp->hdr.callNumber = call->call_id;
+			sp->hdr.seq =
+				htonl(atomic_inc_return(&call->sequence));
+			sp->hdr.serial =
+				htonl(atomic_inc_return(&conn->serial));
+			sp->hdr.type = RXRPC_PACKET_TYPE_DATA;
+			sp->hdr.userStatus = 0;
+			sp->hdr.securityIndex = conn->security_ix;
+			sp->hdr._rsvd = 0;
+			sp->hdr.serviceId = conn->service_id;
+
+			sp->hdr.flags = conn->out_clientflag;
+			if (len == 0 && !more)
+				sp->hdr.flags |= RXRPC_LAST_PACKET;
+			else if (CIRC_SPACE(call->acks_head, call->acks_tail,
+					    call->acks_winsz) > 1)
+				sp->hdr.flags |= RXRPC_MORE_PACKETS;
+
+			ret = rxrpc_secure_packet(
+				call, skb, skb->mark,
+				skb->head + sizeof(struct rxrpc_header));
+			if (ret < 0)
+				goto out;
+
+			memcpy(skb->head, &sp->hdr,
+			       sizeof(struct rxrpc_header));
+			rxrpc_queue_packet(call, skb, segment == 0 && !more);
+			skb = NULL;
+		}
+
+	} while (segment > 0);
+
+out:
+	call->tx_pending = skb;
+	_leave(" = %d", ret);
+	return ret;
+
+call_aborted:
+	rxrpc_free_skb(skb);
+	if (call->state == RXRPC_CALL_NETWORK_ERROR)
+		ret = call->conn->trans->peer->net_error;
+	else
+		ret = -ECONNABORTED;
+	_leave(" = %d", ret);
+	return ret;
+
+maybe_error:
+	if (copied)
+		ret = copied;
+	goto out;
+
+efault:
+	ret = -EFAULT;
+	goto out;
+}
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
new file mode 100644
index 0000000..69ac355
--- /dev/null
+++ b/net/rxrpc/ar-peer.c
@@ -0,0 +1,273 @@
+/* RxRPC remote transport endpoint management
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/udp.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/icmp.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include <net/ip.h>
+#include "ar-internal.h"
+
+static LIST_HEAD(rxrpc_peers);
+static DEFINE_RWLOCK(rxrpc_peer_lock);
+static DECLARE_WAIT_QUEUE_HEAD(rxrpc_peer_wq);
+
+static void rxrpc_destroy_peer(struct work_struct *work);
+
+/*
+ * allocate a new peer
+ */
+static struct rxrpc_peer *rxrpc_alloc_peer(struct sockaddr_rxrpc *srx,
+					   gfp_t gfp)
+{
+	struct rxrpc_peer *peer;
+
+	_enter("");
+
+	peer = kzalloc(sizeof(struct rxrpc_peer), gfp);
+	if (peer) {
+		INIT_WORK(&peer->destroyer, &rxrpc_destroy_peer);
+		INIT_LIST_HEAD(&peer->link);
+		INIT_LIST_HEAD(&peer->error_targets);
+		spin_lock_init(&peer->lock);
+		atomic_set(&peer->usage, 1);
+		peer->debug_id = atomic_inc_return(&rxrpc_debug_id);
+		memcpy(&peer->srx, srx, sizeof(*srx));
+
+		peer->mtu = peer->if_mtu = 65535;
+
+		if (srx->transport.family == AF_INET) {
+			peer->hdrsize = sizeof(struct iphdr);
+			switch (srx->transport_type) {
+			case SOCK_DGRAM:
+				peer->hdrsize += sizeof(struct udphdr);
+				break;
+			default:
+				BUG();
+				break;
+			}
+		} else {
+			BUG();
+		}
+
+		peer->hdrsize += sizeof(struct rxrpc_header);
+		peer->maxdata = peer->mtu - peer->hdrsize;
+	}
+
+	_leave(" = %p", peer);
+	return peer;
+}
+
+/*
+ * obtain a remote transport endpoint for the specified address
+ */
+struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
+{
+	struct rxrpc_peer *peer, *candidate;
+	const char *new = "old";
+	int usage;
+
+	_enter("{%d,%d,%u.%u.%u.%u+%hu}",
+	       srx->transport_type,
+	       srx->transport_len,
+	       NIPQUAD(srx->transport.sin.sin_addr),
+	       ntohs(srx->transport.sin.sin_port));
+
+	/* search the peer list first */
+	read_lock_bh(&rxrpc_peer_lock);
+	list_for_each_entry(peer, &rxrpc_peers, link) {
+		_debug("check PEER %d { u=%d t=%d l=%d }",
+		       peer->debug_id,
+		       atomic_read(&peer->usage),
+		       peer->srx.transport_type,
+		       peer->srx.transport_len);
+
+		if (atomic_read(&peer->usage) > 0 &&
+		    peer->srx.transport_type == srx->transport_type &&
+		    peer->srx.transport_len == srx->transport_len &&
+		    memcmp(&peer->srx.transport,
+			   &srx->transport,
+			   srx->transport_len) == 0)
+			goto found_extant_peer;
+	}
+	read_unlock_bh(&rxrpc_peer_lock);
+
+	/* not yet present - create a candidate for a new record and then
+	 * redo the search */
+	candidate = rxrpc_alloc_peer(srx, gfp);
+	if (!candidate) {
+		_leave(" = -ENOMEM");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	write_lock_bh(&rxrpc_peer_lock);
+
+	list_for_each_entry(peer, &rxrpc_peers, link) {
+		if (atomic_read(&peer->usage) > 0 &&
+		    peer->srx.transport_type == srx->transport_type &&
+		    peer->srx.transport_len == srx->transport_len &&
+		    memcmp(&peer->srx.transport,
+			   &srx->transport,
+			   srx->transport_len) == 0)
+			goto found_extant_second;
+	}
+
+	/* we can now add the new candidate to the list */
+	peer = candidate;
+	candidate = NULL;
+
+	list_add_tail(&peer->link, &rxrpc_peers);
+	write_unlock_bh(&rxrpc_peer_lock);
+	new = "new";
+
+success:
+	_net("PEER %s %d {%d,%u,%u.%u.%u.%u+%hu}",
+	     new,
+	     peer->debug_id,
+	     peer->srx.transport_type,
+	     peer->srx.transport.family,
+	     NIPQUAD(peer->srx.transport.sin.sin_addr),
+	     ntohs(peer->srx.transport.sin.sin_port));
+
+	_leave(" = %p {u=%d}", peer, atomic_read(&peer->usage));
+	return peer;
+
+	/* we found the peer in the list immediately */
+found_extant_peer:
+	usage = atomic_inc_return(&peer->usage);
+	read_unlock_bh(&rxrpc_peer_lock);
+	goto success;
+
+	/* we found the peer on the second time through the list */
+found_extant_second:
+	usage = atomic_inc_return(&peer->usage);
+	write_unlock_bh(&rxrpc_peer_lock);
+	kfree(candidate);
+	goto success;
+}
+
+/*
+ * find the peer associated with a packet
+ */
+struct rxrpc_peer *rxrpc_find_peer(struct rxrpc_local *local,
+				   __be32 addr, __be16 port)
+{
+	struct rxrpc_peer *peer;
+
+	_enter("");
+
+	/* search the peer list */
+	read_lock_bh(&rxrpc_peer_lock);
+
+	if (local->srx.transport.family == AF_INET &&
+	    local->srx.transport_type == SOCK_DGRAM
+	    ) {
+		list_for_each_entry(peer, &rxrpc_peers, link) {
+			if (atomic_read(&peer->usage) > 0 &&
+			    peer->srx.transport_type == SOCK_DGRAM &&
+			    peer->srx.transport.family == AF_INET &&
+			    peer->srx.transport.sin.sin_port == port &&
+			    peer->srx.transport.sin.sin_addr.s_addr == addr)
+				goto found_UDP_peer;
+		}
+
+		goto new_UDP_peer;
+	}
+
+	read_unlock_bh(&rxrpc_peer_lock);
+	_leave(" = -EAFNOSUPPORT");
+	return ERR_PTR(-EAFNOSUPPORT);
+
+found_UDP_peer:
+	_net("Rx UDP DGRAM from peer %d", peer->debug_id);
+	atomic_inc(&peer->usage);
+	read_unlock_bh(&rxrpc_peer_lock);
+	_leave(" = %p", peer);
+	return peer;
+
+new_UDP_peer:
+	_net("Rx UDP DGRAM from NEW peer %d", peer->debug_id);
+	read_unlock_bh(&rxrpc_peer_lock);
+	_leave(" = -EBUSY [new]");
+	return ERR_PTR(-EBUSY);
+}
+
+/*
+ * release a remote transport endpoint
+ */
+void rxrpc_put_peer(struct rxrpc_peer *peer)
+{
+	_enter("%p{u=%d}", peer, atomic_read(&peer->usage));
+
+	ASSERTCMP(atomic_read(&peer->usage), >, 0);
+
+	if (likely(!atomic_dec_and_test(&peer->usage))) {
+		_leave(" [in use]");
+		return;
+	}
+
+	schedule_work(&peer->destroyer);
+	_leave("");
+}
+
+/*
+ * destroy a remote transport endpoint
+ */
+static void rxrpc_destroy_peer(struct work_struct *work)
+{
+	struct rxrpc_peer *peer =
+		container_of(work, struct rxrpc_peer, destroyer);
+
+	_enter("%p{%d}", peer, atomic_read(&peer->usage));
+
+	write_lock_bh(&rxrpc_peer_lock);
+	list_del(&peer->link);
+	write_unlock_bh(&rxrpc_peer_lock);
+
+	_net("DESTROY PEER %d", peer->debug_id);
+	kfree(peer);
+
+	if (list_empty(&rxrpc_peers))
+		wake_up_all(&rxrpc_peer_wq);
+	_leave("");
+}
+
+/*
+ * preemptively destroy all the peer records from a transport endpoint rather
+ * than waiting for them to time out
+ */
+void __exit rxrpc_destroy_all_peers(void)
+{
+	DECLARE_WAITQUEUE(myself,current);
+
+	_enter("");
+
+	/* we simply have to wait for them to go away */
+	if (!list_empty(&rxrpc_peers)) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		add_wait_queue(&rxrpc_peer_wq, &myself);
+
+		while (!list_empty(&rxrpc_peers)) {
+			schedule();
+			set_current_state(TASK_UNINTERRUPTIBLE);
+		}
+
+		remove_wait_queue(&rxrpc_peer_wq, &myself);
+		set_current_state(TASK_RUNNING);
+	}
+
+	_leave("");
+}
diff --git a/net/rxrpc/ar-proc.c b/net/rxrpc/ar-proc.c
new file mode 100644
index 0000000..58f4b4e
--- /dev/null
+++ b/net/rxrpc/ar-proc.c
@@ -0,0 +1,247 @@
+/* /proc/net/ support for AF_RXRPC
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+static const char *rxrpc_conn_states[] = {
+	[RXRPC_CONN_UNUSED]		= "Unused  ",
+	[RXRPC_CONN_CLIENT]		= "Client  ",
+	[RXRPC_CONN_SERVER_UNSECURED]	= "SvUnsec ",
+	[RXRPC_CONN_SERVER_CHALLENGING]	= "SvChall ",
+	[RXRPC_CONN_SERVER]		= "SvSecure",
+	[RXRPC_CONN_REMOTELY_ABORTED]	= "RmtAbort",
+	[RXRPC_CONN_LOCALLY_ABORTED]	= "LocAbort",
+	[RXRPC_CONN_NETWORK_ERROR]	= "NetError",
+};
+
+const char *rxrpc_call_states[] = {
+	[RXRPC_CALL_CLIENT_SEND_REQUEST]	= "ClSndReq",
+	[RXRPC_CALL_CLIENT_AWAIT_REPLY]		= "ClAwtRpl",
+	[RXRPC_CALL_CLIENT_RECV_REPLY]		= "ClRcvRpl",
+	[RXRPC_CALL_CLIENT_FINAL_ACK]		= "ClFnlACK",
+	[RXRPC_CALL_SERVER_SECURING]		= "SvSecure",
+	[RXRPC_CALL_SERVER_ACCEPTING]		= "SvAccept",
+	[RXRPC_CALL_SERVER_RECV_REQUEST]	= "SvRcvReq",
+	[RXRPC_CALL_SERVER_ACK_REQUEST]		= "SvAckReq",
+	[RXRPC_CALL_SERVER_SEND_REPLY]		= "SvSndRpl",
+	[RXRPC_CALL_SERVER_AWAIT_ACK]		= "SvAwtACK",
+	[RXRPC_CALL_COMPLETE]			= "Complete",
+	[RXRPC_CALL_SERVER_BUSY]		= "SvBusy  ",
+	[RXRPC_CALL_REMOTELY_ABORTED]		= "RmtAbort",
+	[RXRPC_CALL_LOCALLY_ABORTED]		= "LocAbort",
+	[RXRPC_CALL_NETWORK_ERROR]		= "NetError",
+	[RXRPC_CALL_DEAD]			= "Dead    ",
+};
+
+/*
+ * generate a list of extant and dead calls in /proc/net/rxrpc_calls
+ */
+static void *rxrpc_call_seq_start(struct seq_file *seq, loff_t *_pos)
+{
+	struct list_head *_p;
+	loff_t pos = *_pos;
+
+	read_lock(&rxrpc_call_lock);
+	if (!pos)
+		return SEQ_START_TOKEN;
+	pos--;
+
+	list_for_each(_p, &rxrpc_calls)
+		if (!pos--)
+			break;
+
+	return _p != &rxrpc_calls ? _p : NULL;
+}
+
+static void *rxrpc_call_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct list_head *_p;
+
+	(*pos)++;
+
+	_p = v;
+	_p = (v == SEQ_START_TOKEN) ? rxrpc_calls.next : _p->next;
+
+	return _p != &rxrpc_calls ? _p : NULL;
+}
+
+static void rxrpc_call_seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock(&rxrpc_call_lock);
+}
+
+static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
+{
+	struct rxrpc_transport *trans;
+	struct rxrpc_call *call;
+	char lbuff[4 + 4 + 4 + 4 + 5 + 1], rbuff[4 + 4 + 4 + 4 + 5 + 1];
+
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq,
+			 "Proto Local                  Remote                "
+			 " SvID ConnID   CallID   End Use State    Abort   "
+			 " UserID\n");
+		return 0;
+	}
+
+	call = list_entry(v, struct rxrpc_call, link);
+	trans = call->conn->trans;
+
+	sprintf(lbuff, NIPQUAD_FMT":%u",
+		NIPQUAD(trans->local->srx.transport.sin.sin_addr),
+		ntohs(trans->local->srx.transport.sin.sin_port));
+
+	sprintf(rbuff, NIPQUAD_FMT":%u",
+		NIPQUAD(trans->peer->srx.transport.sin.sin_addr),
+		ntohs(trans->peer->srx.transport.sin.sin_port));
+
+	seq_printf(seq,
+		   "UDP   %-22.22s %-22.22s %4x %08x %08x %s %3u"
+		   " %-8.8s %08x %lx\n",
+		   lbuff,
+		   rbuff,
+		   ntohs(call->conn->service_id),
+		   ntohl(call->conn->cid),
+		   ntohl(call->call_id),
+		   call->conn->in_clientflag ? "Svc" : "Clt",
+		   atomic_read(&call->usage),
+		   rxrpc_call_states[call->state],
+		   call->abort_code,
+		   call->user_call_ID);
+
+	return 0;
+}
+
+static struct seq_operations rxrpc_call_seq_ops = {
+	.start  = rxrpc_call_seq_start,
+	.next   = rxrpc_call_seq_next,
+	.stop   = rxrpc_call_seq_stop,
+	.show   = rxrpc_call_seq_show,
+};
+
+static int rxrpc_call_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &rxrpc_call_seq_ops);
+}
+
+struct file_operations rxrpc_call_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= rxrpc_call_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+
+/*
+ * generate a list of extant virtual connections in /proc/net/rxrpc_conns
+ */
+static void *rxrpc_connection_seq_start(struct seq_file *seq, loff_t *_pos)
+{
+	struct list_head *_p;
+	loff_t pos = *_pos;
+
+	read_lock(&rxrpc_connection_lock);
+	if (!pos)
+		return SEQ_START_TOKEN;
+	pos--;
+
+	list_for_each(_p, &rxrpc_connections)
+		if (!pos--)
+			break;
+
+	return _p != &rxrpc_connections ? _p : NULL;
+}
+
+static void *rxrpc_connection_seq_next(struct seq_file *seq, void *v,
+				       loff_t *pos)
+{
+	struct list_head *_p;
+
+	(*pos)++;
+
+	_p = v;
+	_p = (v == SEQ_START_TOKEN) ? rxrpc_connections.next : _p->next;
+
+	return _p != &rxrpc_connections ? _p : NULL;
+}
+
+static void rxrpc_connection_seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock(&rxrpc_connection_lock);
+}
+
+static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
+{
+	struct rxrpc_connection *conn;
+	struct rxrpc_transport *trans;
+	char lbuff[4 + 4 + 4 + 4 + 5 + 1], rbuff[4 + 4 + 4 + 4 + 5 + 1];
+
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq,
+			 "Proto Local                  Remote                "
+			 " SvID ConnID   Calls    End Use State    Key     "
+			 " Serial   ISerial\n"
+			 );
+		return 0;
+	}
+
+	conn = list_entry(v, struct rxrpc_connection, link);
+	trans = conn->trans;
+
+	sprintf(lbuff, NIPQUAD_FMT":%u",
+		NIPQUAD(trans->local->srx.transport.sin.sin_addr),
+		ntohs(trans->local->srx.transport.sin.sin_port));
+
+	sprintf(rbuff, NIPQUAD_FMT":%u",
+		NIPQUAD(trans->peer->srx.transport.sin.sin_addr),
+		ntohs(trans->peer->srx.transport.sin.sin_port));
+
+	seq_printf(seq,
+		   "UDP   %-22.22s %-22.22s %4x %08x %08x %s %3u"
+		   " %s %08x %08x %08x\n",
+		   lbuff,
+		   rbuff,
+		   ntohs(conn->service_id),
+		   ntohl(conn->cid),
+		   conn->call_counter,
+		   conn->in_clientflag ? "Svc" : "Clt",
+		   atomic_read(&conn->usage),
+		   rxrpc_conn_states[conn->state],
+		   key_serial(conn->key),
+		   atomic_read(&conn->serial),
+		   atomic_read(&conn->hi_serial));
+
+	return 0;
+}
+
+static struct seq_operations rxrpc_connection_seq_ops = {
+	.start  = rxrpc_connection_seq_start,
+	.next   = rxrpc_connection_seq_next,
+	.stop   = rxrpc_connection_seq_stop,
+	.show   = rxrpc_connection_seq_show,
+};
+
+
+static int rxrpc_connection_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &rxrpc_connection_seq_ops);
+}
+
+struct file_operations rxrpc_connection_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= rxrpc_connection_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
new file mode 100644
index 0000000..e947d5c
--- /dev/null
+++ b/net/rxrpc/ar-recvmsg.c
@@ -0,0 +1,366 @@
+/* RxRPC recvmsg() implementation
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+/*
+ * removal a call's user ID from the socket tree to make the user ID available
+ * again and so that it won't be seen again in association with that call
+ */
+static void rxrpc_remove_user_ID(struct rxrpc_sock *rx, struct rxrpc_call *call)
+{
+	_debug("RELEASE CALL %d", call->debug_id);
+
+	if (test_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
+		write_lock_bh(&rx->call_lock);
+		rb_erase(&call->sock_node, &call->socket->calls);
+		clear_bit(RXRPC_CALL_HAS_USERID, &call->flags);
+		write_unlock_bh(&rx->call_lock);
+	}
+
+	read_lock_bh(&call->state_lock);
+	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
+	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+		schedule_work(&call->processor);
+	read_unlock_bh(&call->state_lock);
+}
+
+/*
+ * receive a message from an RxRPC socket
+ * - we need to be careful about two or more threads calling recvmsg
+ *   simultaneously
+ */
+int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
+		  struct msghdr *msg, size_t len, int flags)
+{
+	struct rxrpc_skb_priv *sp;
+	struct rxrpc_call *call = NULL, *continue_call = NULL;
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
+	struct sk_buff *skb;
+	long timeo;
+	int copy, ret, ullen, offset, copied = 0;
+	u32 abort_code;
+
+	DEFINE_WAIT(wait);
+
+	_enter(",,,%zu,%d", len, flags);
+
+	if (flags & (MSG_OOB | MSG_TRUNC))
+		return -EOPNOTSUPP;
+
+	ullen = msg->msg_flags & MSG_CMSG_COMPAT ? 4 : sizeof(unsigned long);
+
+	timeo = sock_rcvtimeo(&rx->sk, flags & MSG_DONTWAIT);
+	msg->msg_flags |= MSG_MORE;
+
+	lock_sock(&rx->sk);
+
+	for (;;) {
+		/* return immediately if a client socket has no outstanding
+		 * calls */
+		if (RB_EMPTY_ROOT(&rx->calls)) {
+			if (copied)
+				goto out;
+			if (rx->sk.sk_state != RXRPC_SERVER_LISTENING) {
+				release_sock(&rx->sk);
+				if (continue_call)
+					rxrpc_put_call(continue_call);
+				return -ENODATA;
+			}
+		}
+
+		/* get the next message on the Rx queue */
+		skb = skb_peek(&rx->sk.sk_receive_queue);
+		if (!skb) {
+			/* nothing remains on the queue */
+			if (copied &&
+			    (msg->msg_flags & MSG_PEEK || timeo == 0))
+				goto out;
+
+			/* wait for a message to turn up */
+			release_sock(&rx->sk);
+			prepare_to_wait_exclusive(rx->sk.sk_sleep, &wait,
+						  TASK_INTERRUPTIBLE);
+			ret = sock_error(&rx->sk);
+			if (ret)
+				goto wait_error;
+
+			if (skb_queue_empty(&rx->sk.sk_receive_queue)) {
+				if (signal_pending(current))
+					goto wait_interrupted;
+				timeo = schedule_timeout(timeo);
+			}
+			finish_wait(rx->sk.sk_sleep, &wait);
+			lock_sock(&rx->sk);
+			continue;
+		}
+
+	peek_next_packet:
+		sp = rxrpc_skb(skb);
+		call = sp->call;
+		ASSERT(call != NULL);
+
+		_debug("next pkt %s", rxrpc_pkts[sp->hdr.type]);
+
+		/* make sure we wait for the state to be updated in this call */
+		spin_lock_bh(&call->lock);
+		spin_unlock_bh(&call->lock);
+
+		if (test_bit(RXRPC_CALL_RELEASED, &call->flags)) {
+			_debug("packet from released call");
+			if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
+				BUG();
+			rxrpc_free_skb(skb);
+			continue;
+		}
+
+		/* determine whether to continue last data receive */
+		if (continue_call) {
+			_debug("maybe cont");
+			if (call != continue_call ||
+			    skb->mark != RXRPC_SKB_MARK_DATA) {
+				release_sock(&rx->sk);
+				rxrpc_put_call(continue_call);
+				_leave(" = %d [noncont]", copied);
+				return copied;
+			}
+		}
+
+		rxrpc_get_call(call);
+
+		/* copy the peer address and timestamp */
+		if (!continue_call) {
+			if (msg->msg_name && msg->msg_namelen > 0)
+				memcpy(&msg->msg_name, &call->conn->trans->peer->srx,
+				       sizeof(call->conn->trans->peer->srx));
+			sock_recv_timestamp(msg, &rx->sk, skb);
+		}
+
+		/* receive the message */
+		if (skb->mark != RXRPC_SKB_MARK_DATA)
+			goto receive_non_data_message;
+
+		_debug("recvmsg DATA #%u { %d, %d }",
+		       ntohl(sp->hdr.seq), skb->len, sp->offset);
+
+		if (!continue_call) {
+			/* only set the control data once per recvmsg() */
+			ret = put_cmsg(msg, SOL_RXRPC, RXRPC_USER_CALL_ID,
+				       ullen, &call->user_call_ID);
+			if (ret < 0)
+				goto copy_error;
+			ASSERT(test_bit(RXRPC_CALL_HAS_USERID, &call->flags));
+		}
+
+		ASSERTCMP(ntohl(sp->hdr.seq), >=, call->rx_data_recv);
+		ASSERTCMP(ntohl(sp->hdr.seq), <=, call->rx_data_recv + 1);
+		call->rx_data_recv = ntohl(sp->hdr.seq);
+
+		ASSERTCMP(ntohl(sp->hdr.seq), >, call->rx_data_eaten);
+
+		offset = sp->offset;
+		copy = skb->len - offset;
+		if (copy > len - copied)
+			copy = len - copied;
+
+		if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+			ret = skb_copy_datagram_iovec(skb, offset,
+						      msg->msg_iov, copy);
+		} else {
+			ret = skb_copy_and_csum_datagram_iovec(skb, offset,
+							       msg->msg_iov);
+			if (ret == -EINVAL)
+				goto csum_copy_error;
+		}
+
+		if (ret < 0)
+			goto copy_error;
+
+		/* handle piecemeal consumption of data packets */
+		_debug("copied %d+%d", copy, copied);
+
+		offset += copy;
+		copied += copy;
+
+		if (!(flags & MSG_PEEK))
+			sp->offset = offset;
+
+		if (sp->offset < skb->len) {
+			_debug("buffer full");
+			ASSERTCMP(copied, ==, len);
+			break;
+		}
+
+		/* we transferred the whole data packet */
+		if (sp->hdr.flags & RXRPC_LAST_PACKET) {
+			_debug("last");
+			if (call->conn->out_clientflag) {
+				 /* last byte of reply received */
+				ret = copied;
+				goto terminal_message;
+			}
+
+			/* last bit of request received */
+			if (!(flags & MSG_PEEK)) {
+				_debug("eat packet");
+				if (skb_dequeue(&rx->sk.sk_receive_queue) !=
+				    skb)
+					BUG();
+				rxrpc_free_skb(skb);
+			}
+			msg->msg_flags &= ~MSG_MORE;
+			break;
+		}
+
+		/* move on to the next data message */
+		_debug("next");
+		if (!continue_call)
+			continue_call = sp->call;
+		else
+			rxrpc_put_call(call);
+		call = NULL;
+
+		if (flags & MSG_PEEK) {
+			_debug("peek next");
+			skb = skb->next;
+			if (skb == (struct sk_buff *) &rx->sk.sk_receive_queue)
+				break;
+			goto peek_next_packet;
+		}
+
+		_debug("eat packet");
+		if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
+			BUG();
+		rxrpc_free_skb(skb);
+	}
+
+	/* end of non-terminal data packet reception for the moment */
+	_debug("end rcv data");
+out:
+	release_sock(&rx->sk);
+	if (call)
+		rxrpc_put_call(call);
+	if (continue_call)
+		rxrpc_put_call(continue_call);
+	_leave(" = %d [data]", copied);
+	return copied;
+
+	/* handle non-DATA messages such as aborts, incoming connections and
+	 * final ACKs */
+receive_non_data_message:
+	_debug("non-data");
+
+	if (skb->mark == RXRPC_SKB_MARK_NEW_CALL) {
+		_debug("RECV NEW CALL");
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_NEW_CALL, 0, &abort_code);
+		if (ret < 0)
+			goto copy_error;
+		if (!(flags & MSG_PEEK)) {
+			if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
+				BUG();
+			rxrpc_free_skb(skb);
+		}
+		goto out;
+	}
+
+	ret = put_cmsg(msg, SOL_RXRPC, RXRPC_USER_CALL_ID,
+		       ullen, &call->user_call_ID);
+	if (ret < 0)
+		goto copy_error;
+	ASSERT(test_bit(RXRPC_CALL_HAS_USERID, &call->flags));
+
+	switch (skb->mark) {
+	case RXRPC_SKB_MARK_DATA:
+		BUG();
+	case RXRPC_SKB_MARK_FINAL_ACK:
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ACK, 0, &abort_code);
+		break;
+	case RXRPC_SKB_MARK_BUSY:
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_BUSY, 0, &abort_code);
+		break;
+	case RXRPC_SKB_MARK_REMOTE_ABORT:
+		abort_code = call->abort_code;
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT, 4, &abort_code);
+		break;
+	case RXRPC_SKB_MARK_NET_ERROR:
+		_debug("RECV NET ERROR %d", sp->error);
+		abort_code = sp->error;
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_NET_ERROR, 4, &abort_code);
+		break;
+	case RXRPC_SKB_MARK_LOCAL_ERROR:
+		_debug("RECV LOCAL ERROR %d", sp->error);
+		abort_code = sp->error;
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_LOCAL_ERROR, 4,
+			       &abort_code);
+		break;
+	default:
+		BUG();
+		break;
+	}
+
+	if (ret < 0)
+		goto copy_error;
+
+terminal_message:
+	_debug("terminal");
+	msg->msg_flags &= ~MSG_MORE;
+	msg->msg_flags |= MSG_EOR;
+
+	if (!(flags & MSG_PEEK)) {
+		_net("free terminal skb %p", skb);
+		if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
+			BUG();
+		rxrpc_free_skb(skb);
+		rxrpc_remove_user_ID(rx, call);
+	}
+
+	release_sock(&rx->sk);
+	rxrpc_put_call(call);
+	if (continue_call)
+		rxrpc_put_call(continue_call);
+	_leave(" = %d", ret);
+	return ret;
+
+copy_error:
+	_debug("copy error");
+	release_sock(&rx->sk);
+	rxrpc_put_call(call);
+	if (continue_call)
+		rxrpc_put_call(continue_call);
+	_leave(" = %d", ret);
+	return ret;
+
+csum_copy_error:
+	_debug("csum error");
+	release_sock(&rx->sk);
+	if (continue_call)
+		rxrpc_put_call(continue_call);
+	rxrpc_kill_skb(skb);
+	skb_kill_datagram(&rx->sk, skb, flags);
+	rxrpc_put_call(call);
+	return -EAGAIN;
+
+wait_interrupted:
+	ret = sock_intr_errno(timeo);
+wait_error:
+	finish_wait(rx->sk.sk_sleep, &wait);
+	if (continue_call)
+		rxrpc_put_call(continue_call);
+	if (copied)
+		copied = ret;
+	_leave(" = %d [waitfail %d]", copied, ret);
+	return copied;
+
+}
diff --git a/net/rxrpc/ar-security.c b/net/rxrpc/ar-security.c
new file mode 100644
index 0000000..60d1d36
--- /dev/null
+++ b/net/rxrpc/ar-security.c
@@ -0,0 +1,258 @@
+/* RxRPC security handling
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/udp.h>
+#include <linux/crypto.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+static LIST_HEAD(rxrpc_security_methods);
+static DECLARE_RWSEM(rxrpc_security_sem);
+
+/*
+ * get an RxRPC security module
+ */
+static struct rxrpc_security *rxrpc_security_get(struct rxrpc_security *sec)
+{
+	return try_module_get(sec->owner) ? sec : NULL;
+}
+
+/*
+ * release an RxRPC security module
+ */
+static void rxrpc_security_put(struct rxrpc_security *sec)
+{
+	module_put(sec->owner);
+}
+
+/*
+ * look up an rxrpc security module
+ */
+struct rxrpc_security *rxrpc_security_lookup(u8 security_index)
+{
+	struct rxrpc_security *sec = NULL;
+
+	_enter("");
+
+	down_read(&rxrpc_security_sem);
+
+	list_for_each_entry(sec, &rxrpc_security_methods, link) {
+		if (sec->security_index == security_index) {
+			if (unlikely(!rxrpc_security_get(sec)))
+				break;
+			goto out;
+		}
+	}
+
+	sec = NULL;
+out:
+	up_read(&rxrpc_security_sem);
+	_leave(" = %p [%s]", sec, sec ? sec->name : "");
+	return sec;
+}
+
+/**
+ * rxrpc_register_security - register an RxRPC security handler
+ * @sec: security module
+ *
+ * register an RxRPC security handler for use by RxRPC
+ */
+int rxrpc_register_security(struct rxrpc_security *sec)
+{
+	struct rxrpc_security *psec;
+	int ret;
+
+	_enter("");
+	down_write(&rxrpc_security_sem);
+
+	ret = -EEXIST;
+	list_for_each_entry(psec, &rxrpc_security_methods, link) {
+		if (psec->security_index == sec->security_index)
+			goto out;
+	}
+
+	list_add(&sec->link, &rxrpc_security_methods);
+
+	printk(KERN_NOTICE "RxRPC: Registered security type %d '%s'\n",
+	       sec->security_index, sec->name);
+	ret = 0;
+
+out:
+	up_write(&rxrpc_security_sem);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+EXPORT_SYMBOL_GPL(rxrpc_register_security);
+
+/**
+ * rxrpc_unregister_security - unregister an RxRPC security handler
+ * @sec: security module
+ *
+ * unregister an RxRPC security handler
+ */
+void rxrpc_unregister_security(struct rxrpc_security *sec)
+{
+
+	_enter("");
+	down_write(&rxrpc_security_sem);
+	list_del_init(&sec->link);
+	up_write(&rxrpc_security_sem);
+
+	printk(KERN_NOTICE "RxRPC: Unregistered security type %d '%s'\n",
+	       sec->security_index, sec->name);
+}
+
+EXPORT_SYMBOL_GPL(rxrpc_unregister_security);
+
+/*
+ * initialise the security on a client connection
+ */
+int rxrpc_init_client_conn_security(struct rxrpc_connection *conn)
+{
+	struct rxrpc_security *sec;
+	struct key *key = conn->key;
+	int ret;
+
+	_enter("{%d},{%x}", conn->debug_id, key_serial(key));
+
+	if (!key)
+		return 0;
+
+	ret = key_validate(key);
+	if (ret < 0)
+		return ret;
+
+	sec = rxrpc_security_lookup(key->type_data.x[0]);
+	if (!sec)
+		return -EKEYREJECTED;
+	conn->security = sec;
+
+	ret = conn->security->init_connection_security(conn);
+	if (ret < 0) {
+		rxrpc_security_put(conn->security);
+		conn->security = NULL;
+		return ret;
+	}
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * initialise the security on a server connection
+ */
+int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
+{
+	struct rxrpc_security *sec;
+	struct rxrpc_local *local = conn->trans->local;
+	struct rxrpc_sock *rx;
+	struct key *key;
+	key_ref_t kref;
+	char kdesc[5+1+3+1];
+
+	_enter("");
+
+	sprintf(kdesc, "%u:%u", ntohs(conn->service_id), conn->security_ix);
+
+	sec = rxrpc_security_lookup(conn->security_ix);
+	if (!sec) {
+		_leave(" = -ENOKEY [lookup]");
+		return -ENOKEY;
+	}
+
+	/* find the service */
+	read_lock_bh(&local->services_lock);
+	list_for_each_entry(rx, &local->services, listen_link) {
+		if (rx->service_id == conn->service_id)
+			goto found_service;
+	}
+
+	/* the service appears to have died */
+	read_unlock_bh(&local->services_lock);
+	rxrpc_security_put(sec);
+	_leave(" = -ENOENT");
+	return -ENOENT;
+
+found_service:
+	if (!rx->securities) {
+		read_unlock_bh(&local->services_lock);
+		rxrpc_security_put(sec);
+		_leave(" = -ENOKEY");
+		return -ENOKEY;
+	}
+
+	/* look through the service's keyring */
+	kref = keyring_search(make_key_ref(rx->securities, 1UL),
+			      &key_type_rxrpc_s, kdesc);
+	if (IS_ERR(kref)) {
+		read_unlock_bh(&local->services_lock);
+		rxrpc_security_put(sec);
+		_leave(" = %ld [search]", PTR_ERR(kref));
+		return PTR_ERR(kref);
+	}
+
+	key = key_ref_to_ptr(kref);
+	read_unlock_bh(&local->services_lock);
+
+	conn->server_key = key;
+	conn->security = sec;
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * secure a packet prior to transmission
+ */
+int rxrpc_secure_packet(const struct rxrpc_call *call,
+			struct sk_buff *skb,
+			size_t data_size,
+			void *sechdr)
+{
+	if (call->conn->security)
+		return call->conn->security->secure_packet(
+			call, skb, data_size, sechdr);
+	return 0;
+}
+
+/*
+ * secure a packet prior to transmission
+ */
+int rxrpc_verify_packet(const struct rxrpc_call *call, struct sk_buff *skb,
+			u32 *_abort_code)
+{
+	if (call->conn->security)
+		return call->conn->security->verify_packet(
+			call, skb, _abort_code);
+	return 0;
+}
+
+/*
+ * clear connection security
+ */
+void rxrpc_clear_conn_security(struct rxrpc_connection *conn)
+{
+	_enter("{%d}", conn->debug_id);
+
+	if (conn->security) {
+		conn->security->clear(conn);
+		rxrpc_security_put(conn->security);
+		conn->security = NULL;
+	}
+
+	key_put(conn->key);
+	key_put(conn->server_key);
+}
diff --git a/net/rxrpc/ar-skbuff.c b/net/rxrpc/ar-skbuff.c
new file mode 100644
index 0000000..d73f6fc
--- /dev/null
+++ b/net/rxrpc/ar-skbuff.c
@@ -0,0 +1,118 @@
+/* ar-skbuff.c: socket buffer destruction handling
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+/*
+ * set up for the ACK at the end of the receive phase when we discard the final
+ * receive phase data packet
+ * - called with softirqs disabled
+ */
+static void rxrpc_request_final_ACK(struct rxrpc_call *call)
+{
+	/* the call may be aborted before we have a chance to ACK it */
+	write_lock(&call->state_lock);
+
+	switch (call->state) {
+	case RXRPC_CALL_CLIENT_RECV_REPLY:
+		call->state = RXRPC_CALL_CLIENT_FINAL_ACK;
+		_debug("request final ACK");
+
+		/* get an extra ref on the call for the final-ACK generator to
+		 * release */
+		rxrpc_get_call(call);
+		set_bit(RXRPC_CALL_ACK_FINAL, &call->events);
+		if (try_to_del_timer_sync(&call->ack_timer) >= 0)
+			schedule_work(&call->processor);
+		break;
+
+	case RXRPC_CALL_SERVER_RECV_REQUEST:
+		call->state = RXRPC_CALL_SERVER_ACK_REQUEST;
+	default:
+		break;
+	}
+
+	write_unlock(&call->state_lock);
+}
+
+/*
+ * drop the bottom ACK off of the call ACK window and advance the window
+ */
+static void rxrpc_hard_ACK_data(struct rxrpc_call *call,
+				struct rxrpc_skb_priv *sp)
+{
+	int loop;
+	u32 seq;
+
+	spin_lock_bh(&call->lock);
+
+	_debug("hard ACK #%u", ntohl(sp->hdr.seq));
+
+	for (loop = 0; loop < RXRPC_ACKR_WINDOW_ASZ; loop++) {
+		call->ackr_window[loop] >>= 1;
+		call->ackr_window[loop] |=
+			call->ackr_window[loop + 1] << (BITS_PER_LONG - 1);
+	}
+
+	seq = ntohl(sp->hdr.seq);
+	ASSERTCMP(seq, ==, call->rx_data_eaten + 1);
+	call->rx_data_eaten = seq;
+
+	if (call->ackr_win_top < UINT_MAX)
+		call->ackr_win_top++;
+
+	ASSERTIFCMP(call->state <= RXRPC_CALL_COMPLETE,
+		    call->rx_data_post, >=, call->rx_data_recv);
+	ASSERTIFCMP(call->state <= RXRPC_CALL_COMPLETE,
+		    call->rx_data_recv, >=, call->rx_data_eaten);
+
+	if (sp->hdr.flags & RXRPC_LAST_PACKET) {
+		rxrpc_request_final_ACK(call);
+	} else if (atomic_dec_and_test(&call->ackr_not_idle) &&
+		   test_and_clear_bit(RXRPC_CALL_TX_SOFT_ACK, &call->flags)) {
+		_debug("send Rx idle ACK");
+		__rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, sp->hdr.serial,
+				    true);
+	}
+
+	spin_unlock_bh(&call->lock);
+}
+
+/*
+ * destroy a packet that has an RxRPC control buffer
+ * - advance the hard-ACK state of the parent call (done here in case something
+ *   in the kernel bypasses recvmsg() and steals the packet directly off of the
+ *   socket receive queue)
+ */
+void rxrpc_packet_destructor(struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct rxrpc_call *call = sp->call;
+
+	_enter("%p{%p}", skb, call);
+
+	if (call) {
+		/* send the final ACK on a client call */
+		if (sp->hdr.type == RXRPC_PACKET_TYPE_DATA)
+			rxrpc_hard_ACK_data(call, sp);
+		rxrpc_put_call(call);
+		sp->call = NULL;
+	}
+
+	if (skb->sk)
+		sock_rfree(skb);
+	_leave("");
+}
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
new file mode 100644
index 0000000..9b4e5cb
--- /dev/null
+++ b/net/rxrpc/ar-transport.c
@@ -0,0 +1,276 @@
+/* RxRPC point-to-point transport session management
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+static void rxrpc_transport_reaper(struct work_struct *work);
+
+static LIST_HEAD(rxrpc_transports);
+static DEFINE_RWLOCK(rxrpc_transport_lock);
+static unsigned long rxrpc_transport_timeout = 3600 * 24;
+static DECLARE_DELAYED_WORK(rxrpc_transport_reap, rxrpc_transport_reaper);
+
+/*
+ * allocate a new transport session manager
+ */
+static struct rxrpc_transport *rxrpc_alloc_transport(struct rxrpc_local *local,
+						     struct rxrpc_peer *peer,
+						     gfp_t gfp)
+{
+	struct rxrpc_transport *trans;
+
+	_enter("");
+
+	trans = kzalloc(sizeof(struct rxrpc_transport), gfp);
+	if (trans) {
+		trans->local = local;
+		trans->peer = peer;
+		INIT_LIST_HEAD(&trans->link);
+		trans->bundles = RB_ROOT;
+		trans->client_conns = RB_ROOT;
+		trans->server_conns = RB_ROOT;
+		skb_queue_head_init(&trans->error_queue);
+		spin_lock_init(&trans->client_lock);
+		rwlock_init(&trans->conn_lock);
+		atomic_set(&trans->usage, 1);
+		trans->debug_id = atomic_inc_return(&rxrpc_debug_id);
+
+		if (peer->srx.transport.family == AF_INET) {
+			switch (peer->srx.transport_type) {
+			case SOCK_DGRAM:
+				INIT_WORK(&trans->error_handler,
+					  rxrpc_UDP_error_handler);
+				break;
+			default:
+				BUG();
+				break;
+			}
+		} else {
+			BUG();
+		}
+	}
+
+	_leave(" = %p", trans);
+	return trans;
+}
+
+/*
+ * obtain a transport session for the nominated endpoints
+ */
+struct rxrpc_transport *rxrpc_get_transport(struct rxrpc_local *local,
+					    struct rxrpc_peer *peer,
+					    gfp_t gfp)
+{
+	struct rxrpc_transport *trans, *candidate;
+	const char *new = "old";
+	int usage;
+
+	_enter("{%u.%u.%u.%u+%hu},{%u.%u.%u.%u+%hu},",
+	       NIPQUAD(local->srx.transport.sin.sin_addr),
+	       ntohs(local->srx.transport.sin.sin_port),
+	       NIPQUAD(peer->srx.transport.sin.sin_addr),
+	       ntohs(peer->srx.transport.sin.sin_port));
+
+	/* search the transport list first */
+	read_lock_bh(&rxrpc_transport_lock);
+	list_for_each_entry(trans, &rxrpc_transports, link) {
+		if (trans->local == local && trans->peer == peer)
+			goto found_extant_transport;
+	}
+	read_unlock_bh(&rxrpc_transport_lock);
+
+	/* not yet present - create a candidate for a new record and then
+	 * redo the search */
+	candidate = rxrpc_alloc_transport(local, peer, gfp);
+	if (!candidate) {
+		_leave(" = -ENOMEM");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	write_lock_bh(&rxrpc_transport_lock);
+
+	list_for_each_entry(trans, &rxrpc_transports, link) {
+		if (trans->local == local && trans->peer == peer)
+			goto found_extant_second;
+	}
+
+	/* we can now add the new candidate to the list */
+	trans = candidate;
+	candidate = NULL;
+
+	rxrpc_get_local(trans->local);
+	atomic_inc(&trans->peer->usage);
+	list_add_tail(&trans->link, &rxrpc_transports);
+	write_unlock_bh(&rxrpc_transport_lock);
+	new = "new";
+
+success:
+	_net("TRANSPORT %s %d local %d -> peer %d",
+	     new,
+	     trans->debug_id,
+	     trans->local->debug_id,
+	     trans->peer->debug_id);
+
+	_leave(" = %p {u=%d}", trans, atomic_read(&trans->usage));
+	return trans;
+
+	/* we found the transport in the list immediately */
+found_extant_transport:
+	usage = atomic_inc_return(&trans->usage);
+	read_unlock_bh(&rxrpc_transport_lock);
+	goto success;
+
+	/* we found the transport on the second time through the list */
+found_extant_second:
+	usage = atomic_inc_return(&trans->usage);
+	write_unlock_bh(&rxrpc_transport_lock);
+	kfree(candidate);
+	goto success;
+}
+
+/*
+ * find the transport connecting two endpoints
+ */
+struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *local,
+					     struct rxrpc_peer *peer)
+{
+	struct rxrpc_transport *trans;
+
+	_enter("{%u.%u.%u.%u+%hu},{%u.%u.%u.%u+%hu},",
+	       NIPQUAD(local->srx.transport.sin.sin_addr),
+	       ntohs(local->srx.transport.sin.sin_port),
+	       NIPQUAD(peer->srx.transport.sin.sin_addr),
+	       ntohs(peer->srx.transport.sin.sin_port));
+
+	/* search the transport list */
+	read_lock_bh(&rxrpc_transport_lock);
+
+	list_for_each_entry(trans, &rxrpc_transports, link) {
+		if (trans->local == local && trans->peer == peer)
+			goto found_extant_transport;
+	}
+
+	read_unlock_bh(&rxrpc_transport_lock);
+	_leave(" = NULL");
+	return NULL;
+
+found_extant_transport:
+	atomic_inc(&trans->usage);
+	read_unlock_bh(&rxrpc_transport_lock);
+	_leave(" = %p", trans);
+	return trans;
+}
+
+/*
+ * release a transport session
+ */
+void rxrpc_put_transport(struct rxrpc_transport *trans)
+{
+	_enter("%p{u=%d}", trans, atomic_read(&trans->usage));
+
+	ASSERTCMP(atomic_read(&trans->usage), >, 0);
+
+	trans->put_time = xtime.tv_sec;
+	if (unlikely(atomic_dec_and_test(&trans->usage)))
+		_debug("zombie");
+		/* let the reaper determine the timeout to avoid a race with
+		 * overextending the timeout if the reaper is running at the
+		 * same time */
+		schedule_delayed_work(&rxrpc_transport_reap, 0);
+	_leave("");
+}
+
+/*
+ * clean up a transport session
+ */
+static void rxrpc_cleanup_transport(struct rxrpc_transport *trans)
+{
+	_net("DESTROY TRANS %d", trans->debug_id);
+
+	rxrpc_purge_queue(&trans->error_queue);
+
+	rxrpc_put_local(trans->local);
+	rxrpc_put_peer(trans->peer);
+	kfree(trans);
+}
+
+/*
+ * reap dead transports that have passed their expiry date
+ */
+static void rxrpc_transport_reaper(struct work_struct *work)
+{
+	struct rxrpc_transport *trans, *_p;
+	unsigned long now, earliest, reap_time;
+
+	LIST_HEAD(graveyard);
+
+	_enter("");
+
+	now = xtime.tv_sec;
+	earliest = ULONG_MAX;
+
+	/* extract all the transports that have been dead too long */
+	write_lock_bh(&rxrpc_transport_lock);
+	list_for_each_entry_safe(trans, _p, &rxrpc_transports, link) {
+		_debug("reap TRANS %d { u=%d t=%ld }",
+		       trans->debug_id, atomic_read(&trans->usage),
+		       (long) now - (long) trans->put_time);
+
+		if (likely(atomic_read(&trans->usage) > 0))
+			continue;
+
+		reap_time = trans->put_time + rxrpc_transport_timeout;
+		if (reap_time <= now)
+			list_move_tail(&trans->link, &graveyard);
+		else if (reap_time < earliest)
+			earliest = reap_time;
+	}
+	write_unlock_bh(&rxrpc_transport_lock);
+
+	if (earliest != ULONG_MAX) {
+		_debug("reschedule reaper %ld", (long) earliest - now);
+		ASSERTCMP(earliest, >, now);
+		schedule_delayed_work(&rxrpc_transport_reap,
+				      (earliest - now) * HZ);
+	}
+
+	/* then destroy all those pulled out */
+	while (!list_empty(&graveyard)) {
+		trans = list_entry(graveyard.next, struct rxrpc_transport,
+				   link);
+		list_del_init(&trans->link);
+
+		ASSERTCMP(atomic_read(&trans->usage), ==, 0);
+		rxrpc_cleanup_transport(trans);
+	}
+
+	_leave("");
+}
+
+/*
+ * preemptively destroy all the transport session records rather than waiting
+ * for them to time out
+ */
+void __exit rxrpc_destroy_all_transports(void)
+{
+	_enter("");
+
+	rxrpc_transport_timeout = 0;
+	cancel_delayed_work(&rxrpc_transport_reap);
+	schedule_delayed_work(&rxrpc_transport_reap, 0);
+
+	_leave("");
+}
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
new file mode 100644
index 0000000..1eaf529
--- /dev/null
+++ b/net/rxrpc/rxkad.c
@@ -0,0 +1,1153 @@
+/* Kerberos-based RxRPC security
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/udp.h>
+#include <linux/crypto.h>
+#include <linux/scatterlist.h>
+#include <linux/ctype.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+#define RXKAD_VERSION			2
+#define MAXKRB5TICKETLEN		1024
+#define RXKAD_TKT_TYPE_KERBEROS_V5	256
+#define ANAME_SZ			40	/* size of authentication name */
+#define INST_SZ				40	/* size of principal's instance */
+#define REALM_SZ			40	/* size of principal's auth domain */
+#define SNAME_SZ			40	/* size of service name */
+
+unsigned rxrpc_debug;
+module_param_named(debug, rxrpc_debug, uint, S_IWUSR | S_IRUGO);
+MODULE_PARM_DESC(rxrpc_debug, "rxkad debugging mask");
+
+struct rxkad_level1_hdr {
+	__be32	data_size;	/* true data size (excluding padding) */
+};
+
+struct rxkad_level2_hdr {
+	__be32	data_size;	/* true data size (excluding padding) */
+	__be32	checksum;	/* decrypted data checksum */
+};
+
+MODULE_DESCRIPTION("RxRPC network protocol type-2 security (Kerberos)");
+MODULE_AUTHOR("Red Hat, Inc.");
+MODULE_LICENSE("GPL");
+
+/*
+ * this holds a pinned cipher so that keventd doesn't get called by the cipher
+ * alloc routine, but since we have it to hand, we use it to decrypt RESPONSE
+ * packets
+ */
+static struct crypto_blkcipher *rxkad_ci;
+static DEFINE_MUTEX(rxkad_ci_mutex);
+
+/*
+ * initialise connection security
+ */
+static int rxkad_init_connection_security(struct rxrpc_connection *conn)
+{
+	struct rxrpc_key_payload *payload;
+	struct crypto_blkcipher *ci;
+	int ret;
+
+	_enter("{%d},{%x}", conn->debug_id, key_serial(conn->key));
+
+	payload = conn->key->payload.data;
+	conn->security_ix = payload->k.security_index;
+
+	ci = crypto_alloc_blkcipher("pcbc(fcrypt)", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(ci)) {
+		_debug("no cipher");
+		ret = PTR_ERR(ci);
+		goto error;
+	}
+
+	if (crypto_blkcipher_setkey(ci, payload->k.session_key,
+				    sizeof(payload->k.session_key)) < 0)
+		BUG();
+
+	switch (conn->security_level) {
+	case RXRPC_SECURITY_PLAIN:
+		break;
+	case RXRPC_SECURITY_AUTH:
+		conn->size_align = 8;
+		conn->security_size = sizeof(struct rxkad_level1_hdr);
+		conn->header_size += sizeof(struct rxkad_level1_hdr);
+		break;
+	case RXRPC_SECURITY_ENCRYPT:
+		conn->size_align = 8;
+		conn->security_size = sizeof(struct rxkad_level2_hdr);
+		conn->header_size += sizeof(struct rxkad_level2_hdr);
+		break;
+	default:
+		ret = -EKEYREJECTED;
+		goto error;
+	}
+
+	conn->cipher = ci;
+	ret = 0;
+error:
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * prime the encryption state with the invariant parts of a connection's
+ * description
+ */
+static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
+{
+	struct rxrpc_key_payload *payload;
+	struct blkcipher_desc desc;
+	struct scatterlist sg[2];
+	struct rxrpc_crypt iv;
+	struct {
+		__be32 x[4];
+	} tmpbuf __attribute__((aligned(16))); /* must all be in same page */
+
+	_enter("");
+
+	if (!conn->key)
+		return;
+
+	payload = conn->key->payload.data;
+	memcpy(&iv, payload->k.session_key, sizeof(iv));
+
+	desc.tfm = conn->cipher;
+	desc.info = iv.x;
+	desc.flags = 0;
+
+	tmpbuf.x[0] = conn->epoch;
+	tmpbuf.x[1] = conn->cid;
+	tmpbuf.x[2] = 0;
+	tmpbuf.x[3] = htonl(conn->security_ix);
+
+	memset(sg, 0, sizeof(sg));
+	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
+
+	memcpy(&conn->csum_iv, &tmpbuf.x[2], sizeof(conn->csum_iv));
+	ASSERTCMP(conn->csum_iv.n[0], ==, tmpbuf.x[2]);
+
+	_leave("");
+}
+
+/*
+ * partially encrypt a packet (level 1 security)
+ */
+static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
+				    struct sk_buff *skb,
+				    u32 data_size,
+				    void *sechdr)
+{
+	struct rxrpc_skb_priv *sp;
+	struct blkcipher_desc desc;
+	struct rxrpc_crypt iv;
+	struct scatterlist sg[2];
+	struct {
+		struct rxkad_level1_hdr hdr;
+		__be32	first;	/* first four bytes of data and padding */
+	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
+	u16 check;
+
+	sp = rxrpc_skb(skb);
+
+	_enter("");
+
+	check = ntohl(sp->hdr.seq ^ sp->hdr.callNumber);
+	data_size |= (u32) check << 16;
+
+	tmpbuf.hdr.data_size = htonl(data_size);
+	memcpy(&tmpbuf.first, sechdr + 4, sizeof(tmpbuf.first));
+
+	/* start the encryption afresh */
+	memset(&iv, 0, sizeof(iv));
+	desc.tfm = call->conn->cipher;
+	desc.info = iv.x;
+	desc.flags = 0;
+
+	memset(sg, 0, sizeof(sg));
+	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
+
+	memcpy(sechdr, &tmpbuf, sizeof(tmpbuf));
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * wholly encrypt a packet (level 2 security)
+ */
+static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
+					struct sk_buff *skb,
+					u32 data_size,
+					void *sechdr)
+{
+	const struct rxrpc_key_payload *payload;
+	struct rxkad_level2_hdr rxkhdr
+		__attribute__((aligned(8))); /* must be all on one page */
+	struct rxrpc_skb_priv *sp;
+	struct blkcipher_desc desc;
+	struct rxrpc_crypt iv;
+	struct scatterlist sg[16];
+	struct sk_buff *trailer;
+	unsigned len;
+	u16 check;
+	int nsg;
+
+	sp = rxrpc_skb(skb);
+
+	_enter("");
+
+	check = ntohl(sp->hdr.seq ^ sp->hdr.callNumber);
+
+	rxkhdr.data_size = htonl(data_size | (u32) check << 16);
+	rxkhdr.checksum = 0;
+
+	/* encrypt from the session key */
+	payload = call->conn->key->payload.data;
+	memcpy(&iv, payload->k.session_key, sizeof(iv));
+	desc.tfm = call->conn->cipher;
+	desc.info = iv.x;
+	desc.flags = 0;
+
+	memset(sg, 0, sizeof(sg[0]) * 2);
+	sg_set_buf(&sg[0], sechdr, sizeof(rxkhdr));
+	sg_set_buf(&sg[1], &rxkhdr, sizeof(rxkhdr));
+	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(rxkhdr));
+
+	/* we want to encrypt the skbuff in-place */
+	nsg = skb_cow_data(skb, 0, &trailer);
+	if (nsg < 0 || nsg > 16)
+		return -ENOMEM;
+
+	len = data_size + call->conn->size_align - 1;
+	len &= ~(call->conn->size_align - 1);
+
+	skb_to_sgvec(skb, sg, 0, len);
+	crypto_blkcipher_encrypt_iv(&desc, sg, sg, len);
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * checksum an RxRPC packet header
+ */
+static int rxkad_secure_packet(const struct rxrpc_call *call,
+				struct sk_buff *skb,
+				size_t data_size,
+				void *sechdr)
+{
+	struct rxrpc_skb_priv *sp;
+	struct blkcipher_desc desc;
+	struct rxrpc_crypt iv;
+	struct scatterlist sg[2];
+	struct {
+		__be32 x[2];
+	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
+	__be32 x;
+	int ret;
+
+	sp = rxrpc_skb(skb);
+
+	_enter("{%d{%x}},{#%u},%zu,",
+	       call->debug_id, key_serial(call->conn->key), ntohl(sp->hdr.seq),
+	       data_size);
+
+	if (!call->conn->cipher)
+		return 0;
+
+	ret = key_validate(call->conn->key);
+	if (ret < 0)
+		return ret;
+
+	/* continue encrypting from where we left off */
+	memcpy(&iv, call->conn->csum_iv.x, sizeof(iv));
+	desc.tfm = call->conn->cipher;
+	desc.info = iv.x;
+	desc.flags = 0;
+
+	/* calculate the security checksum */
+	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
+	x |= sp->hdr.seq & __constant_cpu_to_be32(0x3fffffff);
+	tmpbuf.x[0] = sp->hdr.callNumber;
+	tmpbuf.x[1] = x;
+
+	memset(&sg, 0, sizeof(sg));
+	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
+
+	x = ntohl(tmpbuf.x[1]);
+	x = (x >> 16) & 0xffff;
+	if (x == 0)
+		x = 1; /* zero checksums are not permitted */
+	sp->hdr.cksum = htons(x);
+
+	switch (call->conn->security_level) {
+	case RXRPC_SECURITY_PLAIN:
+		ret = 0;
+		break;
+	case RXRPC_SECURITY_AUTH:
+		ret = rxkad_secure_packet_auth(call, skb, data_size, sechdr);
+		break;
+	case RXRPC_SECURITY_ENCRYPT:
+		ret = rxkad_secure_packet_encrypt(call, skb, data_size,
+						  sechdr);
+		break;
+	default:
+		ret = -EPERM;
+		break;
+	}
+
+	_leave(" = %d [set %hx]", ret, x);
+	return ret;
+}
+
+/*
+ * decrypt partial encryption on a packet (level 1 security)
+ */
+static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
+				    struct sk_buff *skb,
+				    u32 *_abort_code)
+{
+	struct rxkad_level1_hdr sechdr;
+	struct rxrpc_skb_priv *sp;
+	struct blkcipher_desc desc;
+	struct rxrpc_crypt iv;
+	struct scatterlist sg[2];
+	struct sk_buff *trailer;
+	u32 data_size, buf;
+	u16 check;
+
+	_enter("");
+
+	sp = rxrpc_skb(skb);
+
+	/* we want to decrypt the skbuff in-place */
+	if (skb_cow_data(skb, 0, &trailer) < 0)
+		goto nomem;
+
+	skb_to_sgvec(skb, sg, 0, 8);
+
+	/* start the decryption afresh */
+	memset(&iv, 0, sizeof(iv));
+	desc.tfm = call->conn->cipher;
+	desc.info = iv.x;
+	desc.flags = 0;
+
+	crypto_blkcipher_decrypt_iv(&desc, sg, sg, 8);
+
+	/* remove the decrypted packet length */
+	if (skb_copy_bits(skb, 0, &sechdr, sizeof(sechdr)) < 0)
+		goto datalen_error;
+	if (!skb_pull(skb, sizeof(sechdr)))
+		BUG();
+
+	buf = ntohl(sechdr.data_size);
+	data_size = buf & 0xffff;
+
+	check = buf >> 16;
+	check ^= ntohl(sp->hdr.seq ^ sp->hdr.callNumber);
+	check &= 0xffff;
+	if (check != 0) {
+		*_abort_code = RXKADSEALEDINCON;
+		goto protocol_error;
+	}
+
+	/* shorten the packet to remove the padding */
+	if (data_size > skb->len)
+		goto datalen_error;
+	else if (data_size < skb->len)
+		skb->len = data_size;
+
+	_leave(" = 0 [dlen=%x]", data_size);
+	return 0;
+
+datalen_error:
+	*_abort_code = RXKADDATALEN;
+protocol_error:
+	_leave(" = -EPROTO");
+	return -EPROTO;
+
+nomem:
+	_leave(" = -ENOMEM");
+	return -ENOMEM;
+}
+
+/*
+ * wholly decrypt a packet (level 2 security)
+ */
+static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
+				       struct sk_buff *skb,
+				       u32 *_abort_code)
+{
+	const struct rxrpc_key_payload *payload;
+	struct rxkad_level2_hdr sechdr;
+	struct rxrpc_skb_priv *sp;
+	struct blkcipher_desc desc;
+	struct rxrpc_crypt iv;
+	struct scatterlist _sg[4], *sg;
+	struct sk_buff *trailer;
+	u32 data_size, buf;
+	u16 check;
+	int nsg;
+
+	_enter(",{%d}", skb->len);
+
+	sp = rxrpc_skb(skb);
+
+	/* we want to decrypt the skbuff in-place */
+	nsg = skb_cow_data(skb, 0, &trailer);
+	if (nsg < 0)
+		goto nomem;
+
+	sg = _sg;
+	if (unlikely(nsg > 4)) {
+		sg = kmalloc(sizeof(*sg) * nsg, GFP_NOIO);
+		if (!sg)
+			goto nomem;
+	}
+
+	skb_to_sgvec(skb, sg, 0, skb->len);
+
+	/* decrypt from the session key */
+	payload = call->conn->key->payload.data;
+	memcpy(&iv, payload->k.session_key, sizeof(iv));
+	desc.tfm = call->conn->cipher;
+	desc.info = iv.x;
+	desc.flags = 0;
+
+	crypto_blkcipher_decrypt_iv(&desc, sg, sg, skb->len);
+	if (sg != _sg)
+		kfree(sg);
+
+	/* remove the decrypted packet length */
+	if (skb_copy_bits(skb, 0, &sechdr, sizeof(sechdr)) < 0)
+		goto datalen_error;
+	if (!skb_pull(skb, sizeof(sechdr)))
+		BUG();
+
+	buf = ntohl(sechdr.data_size);
+	data_size = buf & 0xffff;
+
+	check = buf >> 16;
+	check ^= ntohl(sp->hdr.seq ^ sp->hdr.callNumber);
+	check &= 0xffff;
+	if (check != 0) {
+		*_abort_code = RXKADSEALEDINCON;
+		goto protocol_error;
+	}
+
+	/* shorten the packet to remove the padding */
+	if (data_size > skb->len)
+		goto datalen_error;
+	else if (data_size < skb->len)
+		skb->len = data_size;
+
+	_leave(" = 0 [dlen=%x]", data_size);
+	return 0;
+
+datalen_error:
+	*_abort_code = RXKADDATALEN;
+protocol_error:
+	_leave(" = -EPROTO");
+	return -EPROTO;
+
+nomem:
+	_leave(" = -ENOMEM");
+	return -ENOMEM;
+}
+
+/*
+ * verify the security on a received packet
+ */
+static int rxkad_verify_packet(const struct rxrpc_call *call,
+			       struct sk_buff *skb,
+			       u32 *_abort_code)
+{
+	struct blkcipher_desc desc;
+	struct rxrpc_skb_priv *sp;
+	struct rxrpc_crypt iv;
+	struct scatterlist sg[2];
+	struct {
+		__be32 x[2];
+	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
+	__be32 x;
+	__be16 cksum;
+	int ret;
+
+	sp = rxrpc_skb(skb);
+
+	_enter("{%d{%x}},{#%u}",
+	       call->debug_id, key_serial(call->conn->key),
+	       ntohl(sp->hdr.seq));
+
+	if (!call->conn->cipher)
+		return 0;
+
+	if (sp->hdr.securityIndex != 2) {
+		*_abort_code = RXKADINCONSISTENCY;
+		_leave(" = -EPROTO [not rxkad]");
+		return -EPROTO;
+	}
+
+	/* continue encrypting from where we left off */
+	memcpy(&iv, call->conn->csum_iv.x, sizeof(iv));
+	desc.tfm = call->conn->cipher;
+	desc.info = iv.x;
+	desc.flags = 0;
+
+	/* validate the security checksum */
+	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
+	x |= sp->hdr.seq & __constant_cpu_to_be32(0x3fffffff);
+	tmpbuf.x[0] = call->call_id;
+	tmpbuf.x[1] = x;
+
+	memset(&sg, 0, sizeof(sg));
+	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
+
+	x = ntohl(tmpbuf.x[1]);
+	x = (x >> 16) & 0xffff;
+	if (x == 0)
+		x = 1; /* zero checksums are not permitted */
+
+	cksum = htons(x);
+	if (sp->hdr.cksum != cksum) {
+		*_abort_code = RXKADSEALEDINCON;
+		_leave(" = -EPROTO [csum failed]");
+		return -EPROTO;
+	}
+
+	switch (call->conn->security_level) {
+	case RXRPC_SECURITY_PLAIN:
+		ret = 0;
+		break;
+	case RXRPC_SECURITY_AUTH:
+		ret = rxkad_verify_packet_auth(call, skb, _abort_code);
+		break;
+	case RXRPC_SECURITY_ENCRYPT:
+		ret = rxkad_verify_packet_encrypt(call, skb, _abort_code);
+		break;
+	default:
+		ret = -ENOANO;
+		break;
+	}
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * issue a challenge
+ */
+static int rxkad_issue_challenge(struct rxrpc_connection *conn)
+{
+	struct rxkad_challenge challenge;
+	struct rxrpc_header hdr;
+	struct msghdr msg;
+	struct kvec iov[2];
+	size_t len;
+	int ret;
+
+	_enter("{%d,%x}", conn->debug_id, key_serial(conn->key));
+
+	ret = key_validate(conn->key);
+	if (ret < 0)
+		return ret;
+
+	get_random_bytes(&conn->security_nonce, sizeof(conn->security_nonce));
+
+	challenge.version	= htonl(2);
+	challenge.nonce		= htonl(conn->security_nonce);
+	challenge.min_level	= htonl(0);
+	challenge.__padding	= 0;
+
+	msg.msg_name	= &conn->trans->peer->srx.transport.sin;
+	msg.msg_namelen	= sizeof(conn->trans->peer->srx.transport.sin);
+	msg.msg_control	= NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags	= 0;
+
+	hdr.epoch	= conn->epoch;
+	hdr.cid		= conn->cid;
+	hdr.callNumber	= 0;
+	hdr.seq		= 0;
+	hdr.type	= RXRPC_PACKET_TYPE_CHALLENGE;
+	hdr.flags	= conn->out_clientflag;
+	hdr.userStatus	= 0;
+	hdr.securityIndex = conn->security_ix;
+	hdr._rsvd	= 0;
+	hdr.serviceId	= conn->service_id;
+
+	iov[0].iov_base	= &hdr;
+	iov[0].iov_len	= sizeof(hdr);
+	iov[1].iov_base	= &challenge;
+	iov[1].iov_len	= sizeof(challenge);
+
+	len = iov[0].iov_len + iov[1].iov_len;
+
+	hdr.serial = htonl(atomic_inc_return(&conn->serial));
+	_proto("Tx CHALLENGE %%%u", ntohl(hdr.serial));
+
+	ret = kernel_sendmsg(conn->trans->local->socket, &msg, iov, 2, len);
+	if (ret < 0) {
+		_debug("sendmsg failed: %d", ret);
+		return -EAGAIN;
+	}
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * send a Kerberos security response
+ */
+static int rxkad_send_response(struct rxrpc_connection *conn,
+			       struct rxrpc_header *hdr,
+			       struct rxkad_response *resp,
+			       const struct rxkad_key *s2)
+{
+	struct msghdr msg;
+	struct kvec iov[3];
+	size_t len;
+	int ret;
+
+	_enter("");
+
+	msg.msg_name	= &conn->trans->peer->srx.transport.sin;
+	msg.msg_namelen	= sizeof(conn->trans->peer->srx.transport.sin);
+	msg.msg_control	= NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags	= 0;
+
+	hdr->epoch	= conn->epoch;
+	hdr->seq	= 0;
+	hdr->type	= RXRPC_PACKET_TYPE_RESPONSE;
+	hdr->flags	= conn->out_clientflag;
+	hdr->userStatus	= 0;
+	hdr->_rsvd	= 0;
+
+	iov[0].iov_base	= hdr;
+	iov[0].iov_len	= sizeof(*hdr);
+	iov[1].iov_base	= resp;
+	iov[1].iov_len	= sizeof(*resp);
+	iov[2].iov_base	= (void *) s2->ticket;
+	iov[2].iov_len	= s2->ticket_len;
+
+	len = iov[0].iov_len + iov[1].iov_len + iov[2].iov_len;
+
+	hdr->serial = htonl(atomic_inc_return(&conn->serial));
+	_proto("Tx RESPONSE %%%u", ntohl(hdr->serial));
+
+	ret = kernel_sendmsg(conn->trans->local->socket, &msg, iov, 3, len);
+	if (ret < 0) {
+		_debug("sendmsg failed: %d", ret);
+		return -EAGAIN;
+	}
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * calculate the response checksum
+ */
+static void rxkad_calc_response_checksum(struct rxkad_response *response)
+{
+	u32 csum = 1000003;
+	int loop;
+	u8 *p = (u8 *) response;
+
+	for (loop = sizeof(*response); loop > 0; loop--)
+		csum = csum * 0x10204081 + *p++;
+
+	response->encrypted.checksum = htonl(csum);
+}
+
+/*
+ * load a scatterlist with a potentially split-page buffer
+ */
+static void rxkad_sg_set_buf2(struct scatterlist sg[2],
+			      void *buf, size_t buflen)
+{
+
+	memset(sg, 0, sizeof(sg));
+
+	sg_set_buf(&sg[0], buf, buflen);
+	if (sg[0].offset + buflen > PAGE_SIZE) {
+		/* the buffer was split over two pages */
+		sg[0].length = PAGE_SIZE - sg[0].offset;
+		sg_set_buf(&sg[1], buf + sg[0].length, buflen - sg[0].length);
+	}
+
+	ASSERTCMP(sg[0].length + sg[1].length, ==, buflen);
+}
+
+/*
+ * encrypt the response packet
+ */
+static void rxkad_encrypt_response(struct rxrpc_connection *conn,
+				   struct rxkad_response *resp,
+				   const struct rxkad_key *s2)
+{
+	struct blkcipher_desc desc;
+	struct rxrpc_crypt iv;
+	struct scatterlist ssg[2], dsg[2];
+
+	/* continue encrypting from where we left off */
+	memcpy(&iv, s2->session_key, sizeof(iv));
+	desc.tfm = conn->cipher;
+	desc.info = iv.x;
+	desc.flags = 0;
+
+	rxkad_sg_set_buf2(ssg, &resp->encrypted, sizeof(resp->encrypted));
+	memcpy(dsg, ssg, sizeof(dsg));
+	crypto_blkcipher_encrypt_iv(&desc, dsg, ssg, sizeof(resp->encrypted));
+}
+
+/*
+ * respond to a challenge packet
+ */
+static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
+				      struct sk_buff *skb,
+				      u32 *_abort_code)
+{
+	const struct rxrpc_key_payload *payload;
+	struct rxkad_challenge challenge;
+	struct rxkad_response resp
+		__attribute__((aligned(8))); /* must be aligned for crypto */
+	struct rxrpc_skb_priv *sp;
+	u32 version, nonce, min_level, abort_code;
+	int ret;
+
+	_enter("{%d,%x}", conn->debug_id, key_serial(conn->key));
+
+	if (!conn->key) {
+		_leave(" = -EPROTO [no key]");
+		return -EPROTO;
+	}
+
+	ret = key_validate(conn->key);
+	if (ret < 0) {
+		*_abort_code = RXKADEXPIRED;
+		return ret;
+	}
+
+	abort_code = RXKADPACKETSHORT;
+	sp = rxrpc_skb(skb);
+	if (skb_copy_bits(skb, 0, &challenge, sizeof(challenge)) < 0)
+		goto protocol_error;
+
+	version = ntohl(challenge.version);
+	nonce = ntohl(challenge.nonce);
+	min_level = ntohl(challenge.min_level);
+
+	_proto("Rx CHALLENGE %%%u { v=%u n=%u ml=%u }",
+	       ntohl(sp->hdr.serial), version, nonce, min_level);
+
+	abort_code = RXKADINCONSISTENCY;
+	if (version != RXKAD_VERSION)
+		goto protocol_error;
+
+	abort_code = RXKADLEVELFAIL;
+	if (conn->security_level < min_level)
+		goto protocol_error;
+
+	payload = conn->key->payload.data;
+
+	/* build the response packet */
+	memset(&resp, 0, sizeof(resp));
+
+	resp.version = RXKAD_VERSION;
+	resp.encrypted.epoch = conn->epoch;
+	resp.encrypted.cid = conn->cid;
+	resp.encrypted.securityIndex = htonl(conn->security_ix);
+	resp.encrypted.call_id[0] =
+		(conn->channels[0] ? conn->channels[0]->call_id : 0);
+	resp.encrypted.call_id[1] =
+		(conn->channels[1] ? conn->channels[1]->call_id : 0);
+	resp.encrypted.call_id[2] =
+		(conn->channels[2] ? conn->channels[2]->call_id : 0);
+	resp.encrypted.call_id[3] =
+		(conn->channels[3] ? conn->channels[3]->call_id : 0);
+	resp.encrypted.inc_nonce = htonl(nonce + 1);
+	resp.encrypted.level = htonl(conn->security_level);
+	resp.kvno = htonl(payload->k.kvno);
+	resp.ticket_len = htonl(payload->k.ticket_len);
+
+	/* calculate the response checksum and then do the encryption */
+	rxkad_calc_response_checksum(&resp);
+	rxkad_encrypt_response(conn, &resp, &payload->k);
+	return rxkad_send_response(conn, &sp->hdr, &resp, &payload->k);
+
+protocol_error:
+	*_abort_code = abort_code;
+	_leave(" = -EPROTO [%d]", abort_code);
+	return -EPROTO;
+}
+
+/*
+ * decrypt the kerberos IV ticket in the response
+ */
+static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
+				void *ticket, size_t ticket_len,
+				struct rxrpc_crypt *_session_key,
+				time_t *_expiry,
+				u32 *_abort_code)
+{
+	struct blkcipher_desc desc;
+	struct rxrpc_crypt iv, key;
+	struct scatterlist ssg[1], dsg[1];
+	struct in_addr addr;
+	unsigned life;
+	time_t issue, now;
+	bool little_endian;
+	int ret;
+	u8 *p, *q, *name, *end;
+
+	_enter("{%d},{%x}", conn->debug_id, key_serial(conn->server_key));
+
+	*_expiry = 0;
+
+	ret = key_validate(conn->server_key);
+	if (ret < 0) {
+		switch (ret) {
+		case -EKEYEXPIRED:
+			*_abort_code = RXKADEXPIRED;
+			goto error;
+		default:
+			*_abort_code = RXKADNOAUTH;
+			goto error;
+		}
+	}
+
+	ASSERT(conn->server_key->payload.data != NULL);
+	ASSERTCMP((unsigned long) ticket & 7UL, ==, 0);
+
+	memcpy(&iv, &conn->server_key->type_data, sizeof(iv));
+
+	desc.tfm = conn->server_key->payload.data;
+	desc.info = iv.x;
+	desc.flags = 0;
+
+	sg_init_one(&ssg[0], ticket, ticket_len);
+	memcpy(dsg, ssg, sizeof(dsg));
+	crypto_blkcipher_decrypt_iv(&desc, dsg, ssg, ticket_len);
+
+	p = ticket;
+	end = p + ticket_len;
+
+#define Z(size)						\
+	({						\
+		u8 *__str = p;				\
+		q = memchr(p, 0, end - p);		\
+		if (!q || q - p > (size))		\
+			goto bad_ticket;		\
+		for (; p < q; p++)			\
+			if (!isprint(*p))		\
+				goto bad_ticket;	\
+		p++;					\
+		__str;					\
+	})
+
+	/* extract the ticket flags */
+	_debug("KIV FLAGS: %x", *p);
+	little_endian = *p & 1;
+	p++;
+
+	/* extract the authentication name */
+	name = Z(ANAME_SZ);
+	_debug("KIV ANAME: %s", name);
+
+	/* extract the principal's instance */
+	name = Z(INST_SZ);
+	_debug("KIV INST : %s", name);
+
+	/* extract the principal's authentication domain */
+	name = Z(REALM_SZ);
+	_debug("KIV REALM: %s", name);
+
+	if (end - p < 4 + 8 + 4 + 2)
+		goto bad_ticket;
+
+	/* get the IPv4 address of the entity that requested the ticket */
+	memcpy(&addr, p, sizeof(addr));
+	p += 4;
+	_debug("KIV ADDR : "NIPQUAD_FMT, NIPQUAD(addr));
+
+	/* get the session key from the ticket */
+	memcpy(&key, p, sizeof(key));
+	p += 8;
+	_debug("KIV KEY  : %08x %08x", ntohl(key.n[0]), ntohl(key.n[1]));
+	memcpy(_session_key, &key, sizeof(key));
+
+	/* get the ticket's lifetime */
+	life = *p++ * 5 * 60;
+	_debug("KIV LIFE : %u", life);
+
+	/* get the issue time of the ticket */
+	if (little_endian) {
+		__le32 stamp;
+		memcpy(&stamp, p, 4);
+		issue = le32_to_cpu(stamp);
+	} else {
+		__be32 stamp;
+		memcpy(&stamp, p, 4);
+		issue = be32_to_cpu(stamp);
+	}
+	p += 4;
+	now = xtime.tv_sec;
+	_debug("KIV ISSUE: %lx [%lx]", issue, now);
+
+	/* check the ticket is in date */
+	if (issue > now) {
+		*_abort_code = RXKADNOAUTH;
+		ret = -EKEYREJECTED;
+		goto error;
+	}
+
+	if (issue < now - life) {
+		*_abort_code = RXKADEXPIRED;
+		ret = -EKEYEXPIRED;
+		goto error;
+	}
+
+	*_expiry = issue + life;
+
+	/* get the service name */
+	name = Z(SNAME_SZ);
+	_debug("KIV SNAME: %s", name);
+
+	/* get the service instance name */
+	name = Z(INST_SZ);
+	_debug("KIV SINST: %s", name);
+
+	ret = 0;
+error:
+	_leave(" = %d", ret);
+	return ret;
+
+bad_ticket:
+	*_abort_code = RXKADBADTICKET;
+	ret = -EBADMSG;
+	goto error;
+}
+
+/*
+ * decrypt the response packet
+ */
+static void rxkad_decrypt_response(struct rxrpc_connection *conn,
+				   struct rxkad_response *resp,
+				   const struct rxrpc_crypt *session_key)
+{
+	struct blkcipher_desc desc;
+	struct scatterlist ssg[2], dsg[2];
+	struct rxrpc_crypt iv;
+
+	_enter(",,%08x%08x",
+	       ntohl(session_key->n[0]), ntohl(session_key->n[1]));
+
+	ASSERT(rxkad_ci != NULL);
+
+	mutex_lock(&rxkad_ci_mutex);
+	if (crypto_blkcipher_setkey(rxkad_ci, session_key->x,
+				    sizeof(*session_key)) < 0)
+		BUG();
+
+	memcpy(&iv, session_key, sizeof(iv));
+	desc.tfm = rxkad_ci;
+	desc.info = iv.x;
+	desc.flags = 0;
+
+	rxkad_sg_set_buf2(ssg, &resp->encrypted, sizeof(resp->encrypted));
+	memcpy(dsg, ssg, sizeof(dsg));
+	crypto_blkcipher_decrypt_iv(&desc, dsg, ssg, sizeof(resp->encrypted));
+	mutex_unlock(&rxkad_ci_mutex);
+
+	_leave("");
+}
+
+/*
+ * verify a response
+ */
+static int rxkad_verify_response(struct rxrpc_connection *conn,
+				 struct sk_buff *skb,
+				 u32 *_abort_code)
+{
+	struct rxkad_response response
+		__attribute__((aligned(8))); /* must be aligned for crypto */
+	struct rxrpc_skb_priv *sp;
+	struct rxrpc_crypt session_key;
+	time_t expiry;
+	void *ticket;
+	u32 abort_code, version, kvno, ticket_len, csum, level;
+	int ret;
+
+	_enter("{%d,%x}", conn->debug_id, key_serial(conn->server_key));
+
+	abort_code = RXKADPACKETSHORT;
+	if (skb_copy_bits(skb, 0, &response, sizeof(response)) < 0)
+		goto protocol_error;
+	if (!pskb_pull(skb, sizeof(response)))
+		BUG();
+
+	version = ntohl(response.version);
+	ticket_len = ntohl(response.ticket_len);
+	kvno = ntohl(response.kvno);
+	sp = rxrpc_skb(skb);
+	_proto("Rx RESPONSE %%%u { v=%u kv=%u tl=%u }",
+	       ntohl(sp->hdr.serial), version, kvno, ticket_len);
+
+	abort_code = RXKADINCONSISTENCY;
+	if (version != RXKAD_VERSION)
+
+	abort_code = RXKADTICKETLEN;
+	if (ticket_len < 4 || ticket_len > MAXKRB5TICKETLEN)
+		goto protocol_error;
+
+	abort_code = RXKADUNKNOWNKEY;
+	if (kvno >= RXKAD_TKT_TYPE_KERBEROS_V5)
+		goto protocol_error;
+
+	/* extract the kerberos ticket and decrypt and decode it */
+	ticket = kmalloc(ticket_len, GFP_NOFS);
+	if (!ticket)
+		return -ENOMEM;
+
+	abort_code = RXKADPACKETSHORT;
+	if (skb_copy_bits(skb, 0, ticket, ticket_len) < 0)
+		goto protocol_error_free;
+
+	ret = rxkad_decrypt_ticket(conn, ticket, ticket_len, &session_key,
+				   &expiry, &abort_code);
+	if (ret < 0) {
+		*_abort_code = abort_code;
+		kfree(ticket);
+		return ret;
+	}
+
+	/* use the session key from inside the ticket to decrypt the
+	 * response */
+	rxkad_decrypt_response(conn, &response, &session_key);
+
+	abort_code = RXKADSEALEDINCON;
+	if (response.encrypted.epoch != conn->epoch)
+		goto protocol_error_free;
+	if (response.encrypted.cid != conn->cid)
+		goto protocol_error_free;
+	if (ntohl(response.encrypted.securityIndex) != conn->security_ix)
+		goto protocol_error_free;
+	csum = response.encrypted.checksum;
+	response.encrypted.checksum = 0;
+	rxkad_calc_response_checksum(&response);
+	if (response.encrypted.checksum != csum)
+		goto protocol_error_free;
+
+	if (ntohl(response.encrypted.call_id[0]) > INT_MAX ||
+	    ntohl(response.encrypted.call_id[1]) > INT_MAX ||
+	    ntohl(response.encrypted.call_id[2]) > INT_MAX ||
+	    ntohl(response.encrypted.call_id[3]) > INT_MAX)
+		goto protocol_error_free;
+
+	abort_code = RXKADOUTOFSEQUENCE;
+	if (response.encrypted.inc_nonce != htonl(conn->security_nonce + 1))
+		goto protocol_error_free;
+
+	abort_code = RXKADLEVELFAIL;
+	level = ntohl(response.encrypted.level);
+	if (level > RXRPC_SECURITY_ENCRYPT)
+		goto protocol_error_free;
+	conn->security_level = level;
+
+	/* create a key to hold the security data and expiration time - after
+	 * this the connection security can be handled in exactly the same way
+	 * as for a client connection */
+	ret = rxrpc_get_server_data_key(conn, &session_key, expiry, kvno);
+	if (ret < 0) {
+		kfree(ticket);
+		return ret;
+	}
+
+	kfree(ticket);
+	_leave(" = 0");
+	return 0;
+
+protocol_error_free:
+	kfree(ticket);
+protocol_error:
+	*_abort_code = abort_code;
+	_leave(" = -EPROTO [%d]", abort_code);
+	return -EPROTO;
+}
+
+/*
+ * clear the connection security
+ */
+static void rxkad_clear(struct rxrpc_connection *conn)
+{
+	_enter("");
+
+	if (conn->cipher)
+		crypto_free_blkcipher(conn->cipher);
+}
+
+/*
+ * RxRPC Kerberos-based security
+ */
+static struct rxrpc_security rxkad = {
+	.owner				= THIS_MODULE,
+	.name				= "rxkad",
+	.security_index			= RXKAD_VERSION,
+	.init_connection_security	= rxkad_init_connection_security,
+	.prime_packet_security		= rxkad_prime_packet_security,
+	.secure_packet			= rxkad_secure_packet,
+	.verify_packet			= rxkad_verify_packet,
+	.issue_challenge		= rxkad_issue_challenge,
+	.respond_to_challenge		= rxkad_respond_to_challenge,
+	.verify_response		= rxkad_verify_response,
+	.clear				= rxkad_clear,
+};
+
+static __init int rxkad_init(void)
+{
+	_enter("");
+
+	/* pin the cipher we need so that the crypto layer doesn't invoke
+	 * keventd to go get it */
+	rxkad_ci = crypto_alloc_blkcipher("pcbc(fcrypt)", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(rxkad_ci))
+		return PTR_ERR(rxkad_ci);
+
+	return rxrpc_register_security(&rxkad);
+}
+
+module_init(rxkad_init);
+
+static __exit void rxkad_exit(void)
+{
+	_enter("");
+
+	rxrpc_unregister_security(&rxkad);
+	crypto_free_blkcipher(rxkad_ci);
+}
+
+module_exit(rxkad_exit);

