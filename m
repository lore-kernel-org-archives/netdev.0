From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 00/19] rxrpc: Improve conn/call lookup and fix call
 number generation
Date: Thu, 30 Jun 2016 15:10:41 +0100
Message-ID: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33399 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845AbcF3OMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:12:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Here's the next part of the AF_RXRPC rewrite.  The two main purposes of
this set are to fix the call number handling and to make use of RCU when
looking up the connection or call to pass a received packet to.

Important changes in this set include:

 (1) Avoidance of placing stack data into SG lists in rxkad so that kernel
     stacks can become vmalloc'd (Herbert Xu).

 (2) Calls cease pinning the connection they used as soon as possible,
     which allows the connection to be discarded sooner and allows the call
     channel on that connection to be reused earlier.

 (3) Make each call channel on a connection have a separate and independent
     call number space rather than having a shared number space for the
     connection.  Call numbers should increment monotonically per channel
     on the client, and the server should ignore a call with a lower call
     number for that channel than the latest it has seen.  The RESPONSE
     packet sets the minimum values of each call ID counter on a
     connection.

 (4) Look up calls by indexing the channel array on a connection rather
     than by keeping calls in an rbtree on that connection.

 (5) Call terminal statuses are cached in the channel array for the last
     call.  It is assumed that if we the server have seen call N, then the
     client no longer cares about call N-1 on the same channel.

     This will allow retransmission of the terminal status in future
     without the need to keep the rxrpc_call struct around.

 (6) Peer lookups are moved out of common connection handling code and into
     service connection handling code as client connections (a) must point
     to a peer before they can be used and (b) are looked up by a
     machine-unique connection ID directly, so we only need to look up the
     peer first if we're going to deal with a service call.

 (7) The reference count on a connection is held elevated by 1 whilst it is
     alive (ie. idle unused connections have a refcount of 1).  The reaper
     will attempt to change the refcount from 1->0 and skip if this cannot
     be done, whilst look ups only increment the refcount if it's non-zero.

     This makes the implementation of RCU lookups easier as we don't have
     to get a ref on the connection or a lock on the connection list to
     prevent a connection being reaped whilst we're contemplating queueing
     a packet that initiates a new service call upon it.

     If we need to get a connection, but there's a dead connection in the
     tree, we use rb_replace_node() to replace the dead one with a new one.

 (8) Use a seqlock to validate the walk over the service connection rbtree
     attached to a peer when it's being walked in RCU mode.

 (9) Make the incoming call/connection packet handling code use RCU mode
     and locks and make it only take a reference if the call/connection
     gets queued on a workqueue.

The intention is that the next set will introduce the connection lifetime
management and capacity limits to prevent clients from overloading the
server.


There are some fixes too:

 (1) Verifying that a packet coming in to a client connection came from the
     expected source.

 (2) Fix handling of connection failure in client call creation where we
     don't reinitialise the list linkage block and a second attempt to
     unlink the failed connection oopses and also we don't set the state
     correctly, which causes an assertion failure.

 (3) New service calls were being added to the socket's accept queue under
     the wrong lock.


The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160630

David
---
David Howells (18):
      rxrpc: Check the source of a packet to a client conn
      rxrpc: Provide more refcount helper functions
      rxrpc: Dup the main conn list for the proc interface
      rxrpc: Turn connection #defines into enums and put outside struct def
      rxrpc: Check that the client conns cache is empty before module removal
      rxrpc: Move usage count getting into rxrpc_queue_conn()
      rxrpc: Fix handling of connection failure in client call creation
      rxrpc: Release a call's connection ref on call disconnection
      rxrpc: Add RCU destruction for connections and calls
      rxrpc: Access socket accept queue under right lock
      rxrpc: Call channels should have separate call number spaces
      rxrpc: Split client connection code out into its own file
      rxrpc: Split service connection code out into its own file
      rxrpc: Move peer lookup from call-accept to new-incoming-conn
      rxrpc: Maintain an extra ref on a conn for the cache list
      rxrpc: Prune the contents of the rxrpc_conn_proto struct
      rxrpc: Move data_ready peer lookup into rxrpc_find_connection()
      rxrpc: Use RCU to access a peer's service connection tree

Herbert Xu (1):
      rxrpc: Avoid using stack memory in SG lists in rxkad


 net/rxrpc/Makefile       |    1 
 net/rxrpc/af_rxrpc.c     |   20 -
 net/rxrpc/ar-internal.h  |  145 +++++++---
 net/rxrpc/call_accept.c  |   38 +--
 net/rxrpc/call_event.c   |   14 +
 net/rxrpc/call_object.c  |  100 +++----
 net/rxrpc/conn_client.c  |  283 ++++++++++++++++++++
 net/rxrpc/conn_event.c   |   39 +--
 net/rxrpc/conn_object.c  |  639 +++++++++++-----------------------------------
 net/rxrpc/conn_service.c |  231 +++++++++++++++++
 net/rxrpc/input.c        |   69 ++---
 net/rxrpc/insecure.c     |    7 -
 net/rxrpc/local_object.c |   19 +
 net/rxrpc/peer_object.c  |    2 
 net/rxrpc/proc.c         |   31 +-
 net/rxrpc/rxkad.c        |  191 +++++---------
 net/rxrpc/utils.c        |   37 ++-
 17 files changed, 989 insertions(+), 877 deletions(-)
 create mode 100644 net/rxrpc/conn_service.c
