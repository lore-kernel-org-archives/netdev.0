From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/8] rxrpc: Implement slow-start and other bits
Date: Sun, 25 Sep 2016 00:24:56 +0100
Message-ID: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This set of patches implements the RxRPC slow-start feature for AF_RXRPC to
improve performance and handling of occasional packet loss.  This is more or
less the same as TCP slow start [RFC 5681].  Firstly, there are some ACK
generation improvements:

 (1) Send ACKs regularly to apprise the peer of our state so that they can do
     congestion management of their own.

 (2) Send an ACK when we fill in a hole in the buffer so that the peer can
     find out that we did this thus forestalling retransmission.

 (3) Note the final DATA packet's serial number in the final ACK for
     correlation purposes.

and a couple of bug fixes:

 (4) Reinitialise the ACK state and clear the ACK and resend timers upon
     entering the client reply reception phase to kill off any pending probe
     ACKs.

 (5) Delay the resend timer to allow for nsec->jiffies conversion errors.

and then there's the slow-start pieces:

 (6) Summarise an ACK.

 (7) Schedule a PING or IDLE ACK if the reply to a client call is overdue to
     try and find out what happened to it.

 (8) Implement the slow start feature.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160924

David
---
David Howells (8):
      rxrpc: Send an ACK after every few DATA packets we receive
      rxrpc: Send an immediate ACK if we fill in a hole
      rxrpc: Include the last reply DATA serial number in the final ACK
      rxrpc: Reinitialise the call ACK and timer state for client reply phase
      rxrpc: Delay the resend timer to allow for nsec->jiffies conv error
      rxrpc: Generate a summary of the ACK state for later use
      rxrpc: Schedule an ACK if the reply to a client call appears overdue
      rxrpc: Implement slow-start


 include/trace/events/rxrpc.h |   45 ++++++++
 net/rxrpc/ar-internal.h      |   71 ++++++++++++
 net/rxrpc/call_event.c       |   47 +++++++-
 net/rxrpc/call_object.c      |   13 ++
 net/rxrpc/conn_event.c       |    1 
 net/rxrpc/input.c            |  241 +++++++++++++++++++++++++++++++++++++++---
 net/rxrpc/misc.c             |   23 ++++
 net/rxrpc/output.c           |   34 ++++--
 net/rxrpc/recvmsg.c          |   19 +++
 net/rxrpc/sendmsg.c          |    7 +
 10 files changed, 463 insertions(+), 38 deletions(-)
