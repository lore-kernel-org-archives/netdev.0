From: David Howells <dhowells@redhat.com>
Subject: [PATCH 00/11] RxRPC: Rewrite part 2
Date: Mon, 07 Mar 2016 14:37:59 +0000
Message-ID: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34817 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752675AbcCGOiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 09:38:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here's the second set of patches from my RxRPC rewrite, aimed at net-next.

The RxRPC driver wants to end up with four different classes of object
residing in five/six different hashes:

 (1) Local endpoints (hashed by transport address).

 (2) Peers (hashed by remote transport address).

 (3) Connections (hashed by protocol data; hashed by user parameters).

 (4) Calls (temporarily hashed by protocol data; hashed by control message
     user ID).

And, possibly, in future:

 (5) Services (hashed by local endpoint + service ID; hashed by incoming
     protocol data).

The desirable end result is that the connection is the main switch for
incoming packets rather than calls, since each connection has four
'channels' that are the (up to) four calls currently active on it.  This is
how the other RxRPC implementations work.  This means that the transport
object can be killed off, simplifying the code.

Incoming calls currently work by building peer, transport, connection and
call objects and then dumping the incoming packet onto the call.  This
needs to change somewhat also - but will be addressed in a later part of
the rewrite (and may change yet again if service objects are introduced).

The code currently uses spinlocks and rb-trees or lists to find, stepwise,
the target call.  One of the aims of the rewrite is to change this to
RCU-governed hash tables and get rid of as much locking a possible.


To this end, patches 01-02 add a hash table-based object manager that will
then be used to handle all four object classes.  This provides the
following facilities:

 (1) Two hashes per object class.  These have slightly different
     characteristics: All objects must be on the primary hash, but being on
     the secondary hash is optional.  Objects can only be removed from the
     primary by the garbage collector, but can be removed once from the
     secondary hash.

 (2) RCU-safe lookup.

 (3) Usage-count based RCU-safe garbage collection.

 (4) Object re-use.

 (5) One per-class expiry timer instead of per-object timers.

 (6) /proc listing (the primary hash lists all the objects, so a separate
     list isn't necessary).


Patches 03-06 implement the local endpoint object cache using the new
object manager.  This will be responsible for setting up a new connection
object for a new incoming call for which we don't have one set up and
replying to version request packets.

Patches 07-09 implement the peer object cache using the new object manager.
Peers objects will become responsible for handling error reports and MTU
calculation when transport objects are removed.

Patches 10-11 "reclassify" the error report handling as peer event
handling.  This will be overhauled in a later patch to really be driven by
a peer event handler - but the transport object must be got rid of first.
For the moment, this is just a bit of renaming.

Note that some of these patches are basically renames with Makefile
adjustment or the extraction of source out into their own file.  In such a
case, the extracted/moved code isn't modified until a later patch to
simplify GIT history management.

In the case of mass code extraction, should I copy the file in one commit
(without attaching it to the Makefile), then delete the relevant bits from
both files in the next commit to make the patch easier to review?

The object class implementations are going to end up with two files each:

	<class>-object.c	- Object creation, lookup, management
	<class>-event.c		- Object state machine & event processing


The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160307

This is based on net-next/master

David
---
David Howells (11):
      rxrpc: Add a common object cache
      rxrpc: Do procfs lists through objcache
      rxrpc: Separate local endpoint object handling out into its own file
      rxrpc: Implement local endpoint cache
      rxrpc: procfs file to list local endpoints
      rxrpc: Rename ar-local.c to local-event.c
      rxrpc: Rename ar-peer.c to peer-object.c
      rxrpc: Implement peer endpoint cache
      rxrpc: Add /proc/net/rxrpc_peers to display the known remote endpoints
      rxrpc: Rename ar-error.c to peer-event.c
      rxrpc: Rename rxrpc_UDP_error_report() to rxrpc_error_report()


 net/rxrpc/Makefile       |   11 +
 net/rxrpc/af_rxrpc.c     |   17 +
 net/rxrpc/ar-accept.c    |    9 -
 net/rxrpc/ar-connevent.c |    2 
 net/rxrpc/ar-error.c     |  230 ------------------
 net/rxrpc/ar-input.c     |   31 +-
 net/rxrpc/ar-internal.h  |  150 +++++++++---
 net/rxrpc/ar-local.c     |  415 ---------------------------------
 net/rxrpc/ar-peer.c      |  303 ------------------------
 net/rxrpc/ar-transport.c |    2 
 net/rxrpc/local-event.c  |  119 +++++++++
 net/rxrpc/local-object.c |  340 +++++++++++++++++++++++++++
 net/rxrpc/objcache.c     |  581 ++++++++++++++++++++++++++++++++++++++++++++++
 net/rxrpc/objcache.h     |   97 ++++++++
 net/rxrpc/peer-event.c   |  281 ++++++++++++++++++++++
 net/rxrpc/peer-object.c  |  295 +++++++++++++++++++++++
 net/rxrpc/utils.c        |   41 +++
 17 files changed, 1906 insertions(+), 1018 deletions(-)
 delete mode 100644 net/rxrpc/ar-error.c
 delete mode 100644 net/rxrpc/ar-local.c
 delete mode 100644 net/rxrpc/ar-peer.c
 create mode 100644 net/rxrpc/local-event.c
 create mode 100644 net/rxrpc/local-object.c
 create mode 100644 net/rxrpc/objcache.c
 create mode 100644 net/rxrpc/objcache.h
 create mode 100644 net/rxrpc/peer-event.c
 create mode 100644 net/rxrpc/peer-object.c
 create mode 100644 net/rxrpc/utils.c
