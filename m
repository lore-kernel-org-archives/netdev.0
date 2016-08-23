From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/3] rxrpc: Miscellaneous improvements
Date: Tue, 23 Aug 2016 16:28:54 +0100
Message-ID: <147196613431.28436.14522158196410989643.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Here are some improvements that are part of the AF_RXRPC rewrite.  They
need to be applied on top of the just posted cleanups.

 (1) Set the connection expiry on the connection becoming idle when its
     last currently active call completes rather than each time put is
     called.

     This means that the connection isn't held open by retransmissions,
     pings and duplicate packets.  Future patches will limit the number of
     live connections that the kernel will support, so making sure that old
     connections don't overstay their welcome is necessary.

 (2) Calculate packet serial skew in the UDP data_ready callback rather
     than in the call processor on a work queue.  Deferring it like this
     causes the skew to be elevated by further packets coming in before we
     get to make the calculation.

 (3) Move retransmission of the terminal ACK or ABORT packet for a
     connection to the connection processor, using the terminal state
     cached in the rxrpc_connection struct.  This means that once last_call
     is set in a channel to the current call's ID, no more packets will be
     routed to that rxrpc_call struct.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160823-2

David
---
David Howells (3):
      rxrpc: Set connection expiry on idle, not put
      rxrpc: Calculate serial skew on packet reception
      rxrpc: Perform terminal call ACK/ABORT retransmission from conn processor


 net/rxrpc/ar-internal.h |   25 ++++++++--
 net/rxrpc/call_event.c  |   18 ++++---
 net/rxrpc/conn_event.c  |  113 +++++++++++++++++++++++++++++++++++++++++++++++
 net/rxrpc/conn_object.c |   52 +++++++++++-----------
 net/rxrpc/input.c       |   68 ++++++++++++++++++++++------
 net/rxrpc/proc.c        |    2 -
 net/rxrpc/skbuff.c      |   10 ++--
 7 files changed, 226 insertions(+), 62 deletions(-)
