From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 00/14] rxrpc: Get rid of conn bundle and transport
 structs
Date: Wed, 22 Jun 2016 10:49:42 +0100
Message-ID: <146658898230.4550.7226255613607733759.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42750 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866AbcFVJ7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 05:59:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Here's the next part of the AF_RXRPC rewrite.  The primary purpose of this
set is to get rid of the rxrpc_conn_bundle and rxrpc_transport structs.
This simplifies things for future development of the connection handling.

To this end, the following significant changes are made:

 (1) The rxrpc_connection struct is given pointers to the local and peer
     endpoints, inside the rxrpc_conn_parameters struct.  Pointers to the
     transport's copy of these pointers are then redirected to the
     connection struct.

 (2) Exclusive connection handling is fixed.  Exclusive connections should
     do just one call and then be retired.  They are used in security
     negotiations and, I believe, the idea is to avoid reuse of negotiated
     security contexts.

     The current code is doing a single connection per socket and doing all
     the calls over that.  With this change it gets a new connection for
     each call made.

 (3) A new sendmsg() control message marker is added to make individual
     calls operate over exclusive connections.  This should be used in
     future in preference to the sockopt that marks a socket as "exclusive
     connection".

 (4) IDs for client connections initiated by a machine are now allocated
     from a global pool using the IDR facility and are unique across all
     client connections, no matter their destination.  The IDR facility is
     then used to look up a connection on the connection ID alone.  Other
     parameters are then verified afterwards.

     Note that the IDR facility may use a lot of memory if the IDs it holds
     are widely scattered.  Given this, in a future commit, client
     connections will be retired if they are more than a certain distance
     from the last ID allocated.

     The client epoch is advanced by 1 each time the client ID counter
     wraps.  Connections outside the current epoch will also be retired in
     a future commit.

 (5) The connection bundle concept is removed and the client connection
     tree is moved into the local endpoint.  The queue for waiting for a
     call channel is moved to the rxrpc_connection struct as there can only
     be one connection for any particular key going to any particular peer
     now.

 (6) The rxrpc_transport struct is removed and the service connection tree
     is moved into the peer struct.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160622


David
---
Arnd Bergmann (1):
      rxrpc: fix uninitialized variable use

Dan Carpenter (1):
      rxrpc: checking for IS_ERR() instead of NULL

David Howells (12):
      rxrpc: Use structs to hold connection params and protocol info
      rxrpc: Replace conn->trans->{local,peer} with conn->params.{local,peer}
      rxrpc: Fix exclusive connection handling
      rxrpc: Pass sk_buff * rather than rxrpc_host_header * to functions
      rxrpc: rxrpc_connection_lock shouldn't be a BH lock, but conn_lock is
      rxrpc: Use IDR to allocate client conn IDs on a machine-wide basis
      rxrpc: Validate the net address given to rxrpc_kernel_begin_call()
      rxrpc: Calls displayed in /proc may in future lack a connection
      rxrpc: Make rxrpc_send_packet() take a connection not a transport
      rxrpc: Provide more refcount helper functions
      rxrpc: Kill the client connection bundle concept
      rxrpc: Kill off the rxrpc_transport struct


 include/linux/rxrpc.h    |    3 
 net/rxrpc/Makefile       |    2 
 net/rxrpc/af_rxrpc.c     |   87 +----
 net/rxrpc/ar-internal.h  |  173 +++++----
 net/rxrpc/call_accept.c  |   17 -
 net/rxrpc/call_event.c   |   20 +
 net/rxrpc/call_object.c  |  206 ++++++-----
 net/rxrpc/conn_client.c  |   99 +++++
 net/rxrpc/conn_event.c   |   16 -
 net/rxrpc/conn_object.c  |  860 +++++++++++++++++-----------------------------
 net/rxrpc/input.c        |   23 -
 net/rxrpc/key.c          |    2 
 net/rxrpc/local_object.c |    5 
 net/rxrpc/output.c       |  109 +++---
 net/rxrpc/peer_object.c  |    5 
 net/rxrpc/proc.c         |   39 +-
 net/rxrpc/recvmsg.c      |    6 
 net/rxrpc/rxkad.c        |   74 ++--
 net/rxrpc/security.c     |    8 
 net/rxrpc/sysctl.c       |    8 
 net/rxrpc/transport.c    |  269 --------------
 21 files changed, 780 insertions(+), 1251 deletions(-)
 create mode 100644 net/rxrpc/conn_client.c
 delete mode 100644 net/rxrpc/transport.c
