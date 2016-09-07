From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/8] rxrpc: Overhaul call refcounting
Date: Wed, 07 Sep 2016 16:22:26 +0100
Message-ID: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59390 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757248AbcIGPW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 11:22:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here's a set of mostly small patches leading up to one big one.

The big patch at the end of the series overhauls how rxrpc_call refcounting
is handled, making it more sane so that calls bound to user IDs are _only_
released from socket operations or kernel API functions.  Further, the
patch stops calls from holding refs on their parent socket - which can
prevent the socket from being cleaned up.

The second largest patch improves the call tracking tracepoint by providing
extra information about the situation in which gets and puts occur.  This
allows distinctions to be drawn between refs held by the socket user ID
tree, refs held by the work queue (to be implemented by a future patch) and
other refs.

The other patches include a couple of cleanups and some simple alterations
to avoid NULL pointer dereferences in the big patch.

The patches can be found here also (non-terminally on the branch):

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160907-1

David
---
David Howells (8):
      rxrpc: Whitespace cleanup
      rxrpc: Delete unused rxrpc_kernel_free_skb()
      rxrpc: Improve the call tracking tracepoint
      rxrpc: Use call->peer rather than call->conn->params.peer
      rxrpc: Cache the security index in the rxrpc_call struct
      rxrpc: Pass the connection pointer to rxrpc_post_packet_to_call()
      rxrpc: Use rxrpc_is_service_call() rather than rxrpc_conn_is_service()
      rxrpc: Calls shouldn't hold socket refs


 include/trace/events/rxrpc.h |   11 --
 net/rxrpc/af_rxrpc.c         |    6 -
 net/rxrpc/ar-internal.h      |   41 ++++--
 net/rxrpc/call_accept.c      |   63 +++-------
 net/rxrpc/call_event.c       |   74 +++++------
 net/rxrpc/call_object.c      |  277 +++++++++++++++++++-----------------------
 net/rxrpc/conn_client.c      |    3 
 net/rxrpc/input.c            |   39 +++---
 net/rxrpc/output.c           |  145 ++++++++++++++++++++++
 net/rxrpc/proc.c             |    4 -
 net/rxrpc/recvmsg.c          |   47 ++-----
 net/rxrpc/sendmsg.c          |    6 -
 net/rxrpc/skbuff.c           |   16 --
 net/rxrpc/sysctl.c           |    8 -
 14 files changed, 393 insertions(+), 347 deletions(-)
