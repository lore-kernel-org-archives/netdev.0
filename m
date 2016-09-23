From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 00/15] rxrpc: Bug fixes and tracepoints
Date: Fri, 23 Sep 2016 16:15:17 +0100
Message-ID: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here are a bunch of bug fixes:

 (1) Need to set the timestamp on a Tx packet before queueing it to avoid
     trouble with the retransmission function.

 (2) Don't send an ACK at the end of the service reply transmission; it's
     the responsibility of the client to send an ACK to close the call.
     The service can resend the last DATA packet or send a PING ACK.

 (3) Wake sendmsg() on abnormal call termination.

 (4) Use ktime_add_ms() not ktime_add_ns() to add millisecond offsets.

 (5) Use before_eq() & co. to compare serial numbers (which may wrap).

 (6) Start the resend timer on DATA packet transmission.

 (7) Don't accidentally cancel a retransmission upon receiving a NACK.

 (8) Fix the call timer setting function to deal with timeouts that are now
     or past.

 (9) Don't use a flag to communicate the presence of the last packet in the
     Tx buffer from sendmsg to the input routines where ACK and DATA
     reception is handled.  The problem is that there's a window between
     queueing the last packet for transmission and setting the flag in
     which ACKs or reply DATA packets can arrive, causing apparent state
     machine violation issues.

     Instead use the annotation buffer to mark the last packet and pick up
     and set the flag in the input routines.

(10) Don't call the tx_ack tracepoint and don't allocate a serial number if
     someone else nicked the ACK we were about to transmit.

There are also new tracepoints and one altered tracepoint used to track
down the above bugs:

(11) Call timer tracepoint.

(12) Data Tx tracepoint (and adjustments to ACK tracepoint).

(13) Injected Rx packet loss tracepoint.

(14) Ack proposal tracepoint.

(15) Retransmission selection tracepoint.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160923

David
---
David Howells (15):
      rxrpc: Preset timestamp on Tx sk_buffs
      rxrpc: Don't send an ACK at the end of service call response transmission
      rxrpc: Make sure sendmsg() is woken on call completion
      rxrpc: Should be using ktime_add_ms() not ktime_add_ns()
      rxrpc: Use before_eq() and friends to compare serial numbers
      rxrpc: Need to start the resend timer on initial transmission
      rxrpc: Fix accidental cancellation of scheduled resend by ACK parser
      rxrpc: Fix call timer
      rxrpc: Pass the last Tx packet marker in the annotation buffer
      rxrpc: Don't call the tx_ack tracepoint if don't generate an ACK
      rxrpc: Add a tracepoint for the call timer
      rxrpc: Add data Tx tracepoint and adjust Tx ACK tracepoint
      rxrpc: Add a tracepoint to log injected Rx packet loss
      rxrpc: Add tracepoint for ACK proposal
      rxrpc: Add a tracepoint to log which packets will be retransmitted


 include/rxrpc/packet.h       |    1 
 include/trace/events/rxrpc.h |  174 ++++++++++++++++++++++++++++++++++++++++--
 net/rxrpc/ar-internal.h      |   45 ++++++++++-
 net/rxrpc/call_event.c       |   57 ++++++++------
 net/rxrpc/call_object.c      |    8 +-
 net/rxrpc/conn_event.c       |    5 -
 net/rxrpc/input.c            |  136 +++++++++++++++++++++------------
 net/rxrpc/misc.c             |   41 +++++++---
 net/rxrpc/output.c           |   32 ++++----
 net/rxrpc/recvmsg.c          |    5 -
 net/rxrpc/sendmsg.c          |   28 +++++--
 11 files changed, 405 insertions(+), 127 deletions(-)
