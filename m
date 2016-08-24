From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/2] rxrpc: Add better client conn management
 strategy
Date: Wed, 24 Aug 2016 16:04:07 +0100
Message-ID: <147205104744.13653.18154187942560167277.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


These two patches add a better client connection management strategy.  They
need to be applied on top of the just-posted fixes.

 (1) Duplicate the connection list and separate out procfs iteration from
     garbage collection.  This is necessary for the next patch as with that
     client connections no longer appear on a single list and may not
     appear on a list at all - and really don't want to be exposed to the
     old garbage collector.

     (Note that client conns aren't left dangling, they're also in a tree
     rooted in the local endpoint so that they can be found by a user
     wanting to make a new client call.  Service conns do not appear in
     this tree.)

 (2) Implement a better lifetime management and garbage collection strategy
     for client connections.

     In this, a client connection can be in one of five cache states
     (inactive, waiting, active, culled and idle).  Limits are set on the
     number of client conns that may be active at any one time and makes
     users wait if they want to start a new call when there isn't capacity
     available.

     To make capacity available, active and idle connections can be culled,
     after a short delay (to allow for retransmission).  The delay is
     reduced if the capacity exceeds a tunable threshold.

     If there is spare capacity, client conns are permitted to hang around
     a fair bit longer (tunable) so as to allow reuse of negotiated
     security contexts.

     After this patch, the client conn strategy is separate from that of
     service conns (which continues to use the old code for the moment).

     This difference in strategy is because the client side retains control
     over when it allows a connection to become active, whereas the service
     side has no control over when it sees a new connection or a new call
     on an old connection.


The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160824-2

David
---
David Howells (2):
      rxrpc: Dup the main conn list for the proc interface
      rxrpc: Improve management and caching of client connection objects


 net/rxrpc/ar-internal.h  |   58 ++-
 net/rxrpc/call_event.c   |    4 
 net/rxrpc/call_object.c  |    5 
 net/rxrpc/conn_client.c  |  911 ++++++++++++++++++++++++++++++++++++++++------
 net/rxrpc/conn_object.c  |   72 +++-
 net/rxrpc/conn_service.c |    6 
 net/rxrpc/output.c       |    6 
 net/rxrpc/proc.c         |    8 
 net/rxrpc/sysctl.c       |   33 +-
 9 files changed, 943 insertions(+), 160 deletions(-)
