From: David Howells <dhowells@redhat.com>
Subject: [PATCH 0/3] RxRPC: 2nd rewrite part 2
Date: Tue, 12 Apr 2016 16:05:33 +0100
Message-ID: <20160412150533.20637.23952.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here's the next part of the AF_RXRPC rewrite.  In this set I make some
changes to the user interface for AF_RXRPC:

 (1) connect() is no longer supported on an AF_RXRPC socket.  It is
     redundant given that sendmsg() can be given the target address;
     indeed, even on a connected client socket, sendmsg() can still be used
     with an address other than the connection address.

 (2) listen() is required to allow a service socket to begin accepting
     incoming calls.  Previously, bind() with a service ID set in the
     address caused the socket to begin listening.  Listen only adjusted
     the backlog parameter on the socket previously.

 (3) The maximum backlog size can be adjusted through a sysctl - though it
     is still limited to the range 4-32.  At some point I would like to
     have some preallocated rxrpc_call structs prepared for incoming calls,
     using the backlog to limit the preallocation.  Passing INT_MAX to
     listen() requests the maximum allowed.

 (4) Calling sendmsg() on a socket that is not yet bound shifts the socket
     to be a purely client socket and binds a random local UDP port.

 (5) sendmsg() with a RXRPC_ACCEPT control message must not also have an
     address specified in msg_name.  It doesn't make sense to supply an
     address here.

 (6) If sendmsg() is asked to make a call with a particular user call ID
     which doesn't yet exist, the user call ID must not come into existence
     whilst sendmsg() is off creating a new call.  Previously it would just
     add its data to the call.

I would also like to consider making further changes, but I think they'd
probably be too much of a change:

 (*) Require a control message of RXRPC_NEW_CALL to be passed to sendmsg()
     when beginning a new call to make it clear that we're instituting a
     new user call ID, not expecting the user call ID to already exist with
     the socket.  This would make (6) above cleaner.

 (*) Provide RXRPC_LOCALLY_ABORTED and RXRPC_REMOTELY_ABORTED control
     messages for recvmsg() to return instead of RXRPC_ABORT (which would
     then be for sendmsg() only).  Another way to do this is to return an
     additional control message that, say, indicates that the termination
     was remote.

 (*) Allow userspace to presupply user call IDs for incoming calls to use.
     These would be used instead of RXRPC_ACCEPT.  A control message would
     be required: one for sendmsg() to supply a user ID (RXRPC_PREACCEPT
     say) and then RXRPC_NEW_CALL would be given a parameter through
     recvmsg() to indicate the number of user call IDs available.


The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160412

This is based on net-next/master

David
---
David Howells (3):
      rxrpc: Don't permit use of connect() op and simplify sendmsg() op
      rxrpc: The RXRPC_ACCEPT control message should not have an address
      rxrpc: Use the listen() system call to move to listening state


 Documentation/networking/rxrpc.txt |    8 -
 fs/afs/rxrpc.c                     |   34 +++---
 include/linux/rxrpc.h              |   18 ++-
 net/rxrpc/af_rxrpc.c               |  209 ++++++++++--------------------------
 net/rxrpc/ar-call.c                |  158 +++++++++++----------------
 net/rxrpc/ar-connection.c          |   17 ---
 net/rxrpc/ar-internal.h            |   22 ++--
 net/rxrpc/ar-output.c              |  187 +++++++++++++++-----------------
 net/rxrpc/misc.c                   |    6 +
 net/rxrpc/sysctl.c                 |   10 ++
 10 files changed, 269 insertions(+), 400 deletions(-)
