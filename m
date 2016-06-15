From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/8] rxrpc: Rework endpoint record handling
Date: Wed, 15 Jun 2016 17:41:38 +0100
Message-ID: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Here's the next part of the AF_RXRPC rewrite.  In this set I rework
endpoint record handling.  There are two types of endpoint record, local
and peer.  The local endpoint record is used as an anchor for the transport
socket that AF_RXRPC uses (at the moment a UDP socket).  Local endpoints
can be shared between AF_RXRPC sockets under certain restricted
circumstances.

The peer endpoint is a record of the remote end.  It is (or will be) used
to keep track MTU and RTT values and, with these changes, is used to find
the call(s) to abort when a network error occurs.

The following significant changes are made:

 (1) The local endpoint event handling code is split out into its own file.

 (2) The local endpoint list bottom half-excluding spinlock is removed as
     things are arranged such that sk_user_data will not change whilst the
     transport socket callbacks are in progress.

 (3) Local endpoints can now only be shared if they have the same transport
     address (as before) and have a local service ID of 0 (ie. they're not
     listening for incoming calls).  This prevents callbacks from a server
     to one process being picked up by another process.

 (4) Local endpoint destruction is now accomplished by the same work item
     as processes events, meaning that the destructor doesn't need to wait
     for the event processor.

 (5) Peer endpoints are now held in a hash table rather than a flat list.

 (6) Peer endpoints are now destroyed by RCU rather than by work item.

 (7) Peer endpoints are now differentiated by local endpoint and remote
     transport port in addition to remote transport address and transport
     type and family.

     This means that a firewall that excludes access between a particular
     local port and remote port won't cause calls to be aborted that use a
     different port pair.

 (8) Error report handling now no longer assumes that the source is always
     an IPv4 ICMP message from a UDP port and has assumptions that an ICMP
     message comes from an IPv4 socket removed.  At some point IPv6 support
     will be added.

 (9) Peer endpoints rather than local endpoints are now the anchor point
     for distributing network error reports.

(10) Both types of endpoint records are now disposed of as soon as all
     references to them are gone.  There is less hanging around and once
     their usage counts hit zero, records can no longer be resurrected.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160615


David
---
David Howells (8):
      rxrpc: Rework peer object handling to use hash table and RCU
      rxrpc: Rename rxrpc_UDP_error_report() to rxrpc_error_report()
      rxrpc: Break MTU determination from ICMP into its own function
      rxrpc: Don't assume anything about the address in an ICMP packet
      rxrpc: Do a little bit of tidying in the ICMP processing
      rxrpc: Use the peer record to distribute network errors
      rxrpc: Separate local endpoint event handling out into its own file
      rxrpc: Rework local endpoint management


 net/rxrpc/Makefile       |    4 
 net/rxrpc/af_rxrpc.c     |   22 ++
 net/rxrpc/ar-internal.h  |  124 +++++++++----
 net/rxrpc/call_accept.c  |   27 +--
 net/rxrpc/call_event.c   |   15 +-
 net/rxrpc/call_object.c  |    6 -
 net/rxrpc/conn_event.c   |   15 --
 net/rxrpc/input.c        |   42 ++--
 net/rxrpc/local_event.c  |  116 ++++++++++++
 net/rxrpc/local_object.c |  430 +++++++++++++++++++++-------------------------
 net/rxrpc/output.c       |    4 
 net/rxrpc/peer_event.c   |  251 ++++++++++++++++-----------
 net/rxrpc/peer_object.c  |  373 ++++++++++++++++++++--------------------
 net/rxrpc/transport.c    |   19 --
 net/rxrpc/utils.c        |   41 ++++
 15 files changed, 842 insertions(+), 647 deletions(-)
 create mode 100644 net/rxrpc/local_event.c
 create mode 100644 net/rxrpc/utils.c
