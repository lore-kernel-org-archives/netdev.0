From: David Howells <dhowells@redhat.com>
Subject: [GIT PULL net-next] rxrpc: Improve conn/call lookup and fix call
 number generation [ver #3]
Date: Wed, 06 Jul 2016 11:48:15 +0100
Message-ID: <10481.1467802095@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753843AbcGFKsR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 06:48:17 -0400
Content-ID: <10480.1467802095.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Can you pull this into net-next please?

I've fixed a couple of patch descriptions and excised the patch that
duplicated the connections list for reconsideration at a later date.

For reference, the excised patch is sitting on the rxrpc-experimental
branch of my git tree, based on top of the rxrpc-rewrite branch.  Diffing
it against yesterday's tag shows no differences.

Would you prefer the patch set to be emailed afresh instead of a git-pull
request?

David
---
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
     than by keeping calls in an rbtree on that connection.  Also look up
     calls using the channel array rather than using a hashtable.

     The call hashtable can then be removed.

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


Changes:

 (V2) In rxrpc_find_service_conn_rcu() initialised the sequence number to 0.

      Fixed the RCU handling in conn_service.c by introducing and using
      rb_replace_node_rcu() as an RCU-safe alternative in
      rxrpc_publish_service_conn().

      Modified and used rcu_dereference_raw() to avoid RCU sparse warnings
      in rxrpc_find_service_conn_rcu().

      Added in some missing RCU dereference wrappers.  It seems to be
      necessary to turn on CONFIG_PROVE_RCU_REPEATEDLY as well as
      CONFIG_SPARSE_RCU_POINTER to get the static __rcu annotation checking
      to happen.

      Fixed some other sparse warnings, including a missing ntohs() in
      jumbo packet processing.

 (V3) Fixed some commit descriptions.

      Excised the patch that duplicated the connection list to separate out
      the procfs list for reconsideration at a later date.

---
The following changes since commit de2fbe7ae3637533ebf711b91b04988633bf38ee:

  Merge branch 'sfp-infra' (2016-06-27 10:41:02 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/rxrpc-rewrite-20160706

for you to fetch changes up to d440a1ce5d2cf9d90390f6c0d8badc4c0a4f8b6b:

  rxrpc: Kill off the call hash table (2016-07-06 11:23:54 +0100)

----------------------------------------------------------------
RxRPC rewrite

----------------------------------------------------------------
David Howells (21):
      rxrpc: Fix processing of authenticated/encrypted jumbo packets
      rxrpc: Fix some sparse errors
      rxrpc: Check the source of a packet to a client conn
      rxrpc: Provide queuing helper functions
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
      Introduce rb_replace_node_rcu()
      rxrpc: Use RCU to access a peer's service connection tree
      rxrpc: Kill off the call hash table

Herbert Xu (1):
      rxrpc: Avoid using stack memory in SG lists in rxkad

Paul E. McKenney (1):
      rcu: Suppress sparse warnings for rcu_dereference_raw()

 include/linux/rbtree.h           |   2 +
 include/linux/rbtree_augmented.h |  13 +
 include/linux/rcupdate.h         |   8 +-
 lib/rbtree.c                     |  26 +-
 net/rxrpc/Makefile               |   1 +
 net/rxrpc/af_rxrpc.c             |  20 --
 net/rxrpc/ar-internal.h          | 156 ++++++----
 net/rxrpc/call_accept.c          |  38 +--
 net/rxrpc/call_event.c           |  14 +-
 net/rxrpc/call_object.c          | 273 +++--------------
 net/rxrpc/conn_client.c          | 282 ++++++++++++++++-
 net/rxrpc/conn_event.c           |  44 +--
 net/rxrpc/conn_object.c          | 636 +++++++++------------------------------
 net/rxrpc/conn_service.c         | 230 ++++++++++++++
 net/rxrpc/input.c                |  71 ++---
 net/rxrpc/insecure.c             |   7 +-
 net/rxrpc/local_object.c         |  19 +-
 net/rxrpc/peer_object.c          |   2 +-
 net/rxrpc/proc.c                 |  23 +-
 net/rxrpc/rxkad.c                | 191 +++++-------
 net/rxrpc/utils.c                |  37 ++-
 21 files changed, 1031 insertions(+), 1062 deletions(-)
 create mode 100644 net/rxrpc/conn_service.c
