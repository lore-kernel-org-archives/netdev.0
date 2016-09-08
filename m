From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/7] rxrpc: Rewrite data and ack handling
Date: Thu, 08 Sep 2016 12:43:28 +0100
Message-ID: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch set constitutes the main portion of the AF_RXRPC rewrite.  It
consists of five fix/helper patches:

 (1) Fix ASSERTCMP's and ASSERTIFCMP's handling of signed values.

 (2) Update some protocol definitions slightly.

 (3) Use of an hlist for RCU purposes.

 (4) Removal of per-call sk_buff accounting (not really needed when skbs
     aren't being queued on the main queue).

 (5) Addition of a tracepoint to log incoming packets in the data_ready
     callback and to log the end of the data_ready callback.

And then there are two patches that form the main part:

 (6) Preallocation of resources for incoming calls so that in patch (7) the
     data_ready handler can be made to fully instantiate an incoming call
     and make it live.  This extends through into AFS so that AFS can
     preallocate its own incoming call resources.

     The preallocation size is capped at the listen() backlog setting - and
     that is capped at a sysctl limit which can be set between 4 and 32.

     The preallocation is (re)charged either by accepting/rejecting pending
     calls or, in the case of AFS, manually.  If insufficient preallocation
     resources exist, a BUSY packet will be transmitted.

     The advantage of using this preallocation is that once a call is set
     up in the data_ready handler, DATA packets can be queued on it
     immediately rather than the DATA packets being queued for a background
     work item to do all the allocation and then try and sort out the DATA
     packets whilst other DATA packets may still be coming in and going
     either to the background thread or the new call.

 (7) Rewrite the handling of DATA, ACK and ABORT packets.

     In the receive phase, DATA packets are now held in per-call circular
     buffers with deduplication, out of sequence detection and suchlike
     being done in data_ready.  Since there is only one producer and only
     once consumer, no locks need be used on the receive queue.

     Received ACK and ABORT packets are now parsed and discarded in
     data_ready to recycle resources as fast as possible.

     sk_buffs are no longer pulled, trimmed or cloned, but rather the
     offset and size of the content is tracked.  This particularly affects
     jumbo DATA packets which need insertion into the receive buffer in
     multiple places.  Annotations are kept to track which bit is which.

     Packets are no longer queued on the socket receive queue; rather,
     calls are queued.  Dummy packets to convey events therefore no longer
     need to be invented and metadata packets can be discarded as soon as
     parsed rather then being pushed onto the socket receive queue to
     indicate terminal events.

     The preallocation facility added in (6) is now used to set up incoming
     calls with very little locking required and no calls to the allocator
     in data_ready.

     Decryption and verification is now handled in recvmsg() rather than in
     a background thread.  This allows for the future possibility of
     decrypting directly into the user buffer.

     With this patch, the code is a lot simpler and most of the mass of
     call event and state wangling code in call_event.c is gone.

With this, the majority of the AF_RXRPC rewrite is complete.  However,
there are still things to be done, including:

 (*) Limit the number of active service calls to prevent an attacker from
     filling up a server's memory.

 (*) Limit the number of calls on the rebuff-with-BUSY queue.

 (*) Transmit delayed/deferred ACKs from recvmsg() if possible, rather than
     punting to the background thread.  Ideally, the background thread
     shouldn't run at all, but data_ready can't call kernel_sendmsg() and
     we can't rely on recvmsg() attending to the call in a timely fashion.

 (*) Prevent the call at the front of the socket queue from hogging
     recvmsg()'s attention if there's a sufficiently continuous supply of
     data.

 (*) Distribute ICMP errors by connection rather than by call.  Possibly
     parse the ICMP packet to try and pin down the exact connection and
     call.

 (*) Encrypt/decrypt directly between user buffers and socket buffers where
     possible.

 (*) IPv6.

 (*) Service ID upgrade.  This is a facility whereby a special flag bit is
     set in the DATA packet header when making a call that tells the server
     that it is allowed to change the service ID to an upgraded one and
     reply with an equivalent call from the upgraded service.

     This is used, for example, to override certain AFS calls so that IPv6
     addresses can be returned.

 (*) Allow userspace to preallocate call user IDs for incoming calls.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160908

David
---
David Howells (7):
      rxrpc: Fix ASSERTCMP and ASSERTIFCMP to handle signed values
      rxrpc: Update protocol definitions slightly
      rxrpc: Convert rxrpc_local::services to an hlist
      rxrpc: Remove skb_count from struct rxrpc_call
      rxrpc: Add tracepoints to record received packets and end of data_ready
      rxrpc: Preallocate peers, conns and calls for incoming service requests
      rxrpc: Rewrite the data and ack handling code


 fs/afs/rxrpc.c               |   88 ++-
 include/net/af_rxrpc.h       |   13 
 include/rxrpc/packet.h       |   15 
 include/trace/events/rxrpc.h |   48 +
 net/rxrpc/af_rxrpc.c         |   83 ++-
 net/rxrpc/ar-internal.h      |  238 ++++---
 net/rxrpc/call_accept.c      |  651 ++++++++++++--------
 net/rxrpc/call_event.c       | 1357 ++++++------------------------------------
 net/rxrpc/call_object.c      |  567 +++++-------------
 net/rxrpc/conn_event.c       |  137 +---
 net/rxrpc/conn_object.c      |    8 
 net/rxrpc/conn_service.c     |  119 +---
 net/rxrpc/input.c            | 1048 +++++++++++++++++---------------
 net/rxrpc/insecure.c         |   13 
 net/rxrpc/local_event.c      |    2 
 net/rxrpc/local_object.c     |   11 
 net/rxrpc/misc.c             |    2 
 net/rxrpc/output.c           |  125 ++++
 net/rxrpc/peer_event.c       |   17 -
 net/rxrpc/peer_object.c      |   82 ++-
 net/rxrpc/proc.c             |    8 
 net/rxrpc/recvmsg.c          |  764 +++++++++++++-----------
 net/rxrpc/rxkad.c            |  108 ++-
 net/rxrpc/security.c         |   12 
 net/rxrpc/sendmsg.c          |  126 +---
 net/rxrpc/skbuff.c           |  127 ----
 26 files changed, 2416 insertions(+), 3353 deletions(-)
