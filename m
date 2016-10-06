From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 00/13] rxrpc: Fixes
Date: Thu, 06 Oct 2016 11:03:56 +0100
Message-ID: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This set of patches contains a bunch of fixes:

 (1) Fix an oops on incoming call to a local endpoint without a bound
     service.

 (2) Only ping for a lost reply in a client call (this is inapplicable to
     service calls).

 (3) Fix maybe uninitialised variable warnings in the ACK/ABORT sending
     function by splitting it.

 (4) Fix loss of PING RESPONSE ACKs due to them being subsumed by PING ACK
     generation.

 (5) OpenAFS improperly terminates calls it makes as a client under some
     circumstances by not fully hard-ACK'ing the last DATA packets.  This
     is alleviated by a new call appearing on the same channel implicitly
     completing the previous call on that channel.  Handle this implicit
     completion.

 (6) Properly handle expiry of service calls due to the aforementioned
     improper termination with no follow up call to implicitly complete it:

     (a) The call's background processor needs to be queued to complete the
     	 call, send an abort and notify the socket.

     (b) The call's background processor needs to notify the socket (or the
     	 kernel service) when it has completed the call.

     (c) A negative error code must thence be returned to the kernel
     	 service so that it knows the call died.

     (d) The AFS filesystem must detect the fatal error and end the call.

 (7) Must produce a DELAY ACK when the actual service operation takes a
     while to process and must cancel the ACK when the reply is ready.

 (8) Don't request an ACK on the last DATA packet of the Tx phase as this
     confuses OpenAFS.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20161004

David
---
David Howells (13):
      rxrpc: Accesses of rxrpc_local::service need to be RCU managed
      rxrpc: Fix duplicate const
      rxrpc: Fix oops on incoming call to serviceless endpoint
      rxrpc: Only ping for lost reply in client call
      rxrpc: Fix warning by splitting rxrpc_send_call_packet()
      rxrpc: Fix loss of PING RESPONSE ACK production due to PING ACKs
      rxrpc: Partially handle OpenAFS's improper termination of calls
      rxrpc: Queue the call on expiry
      rxrpc: Add missing notification
      rxrpc: Return negative error code to kernel service
      afs: Check for fatal error when in waiting for ack state
      rxrpc: Need to produce an ACK for service op if op takes a long time
      rxrpc: Don't request an ACK on the last DATA packet of a call's Tx phase


 fs/afs/rxrpc.c          |    2 -
 net/rxrpc/af_rxrpc.c    |    4 +
 net/rxrpc/ar-internal.h |   18 ++++-
 net/rxrpc/call_accept.c |    4 +
 net/rxrpc/call_event.c  |   77 +++++++++++++++++---
 net/rxrpc/call_object.c |    3 +
 net/rxrpc/input.c       |   44 +++++++++++-
 net/rxrpc/misc.c        |    6 +-
 net/rxrpc/output.c      |  179 +++++++++++++++++++++++++++--------------------
 net/rxrpc/recvmsg.c     |   14 ++--
 net/rxrpc/rxkad.c       |    6 +-
 net/rxrpc/sendmsg.c     |   12 ++-
 12 files changed, 252 insertions(+), 117 deletions(-)
