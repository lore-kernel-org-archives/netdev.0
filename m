From: David Howells <dhowells@redhat.com>
Subject: [PATCH 0/9] RxRPC: 2nd rewrite part 1
Date: Thu, 07 Apr 2016 17:22:56 +0100
Message-ID: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Okay, I'm in the process of rewriting the RxRPC rewrite.  The primary aim of
this second rewrite is to strictly control the number of active connections we
know about and to get rid of connections we don't need much more quickly.

On top of this, there are fixes to the protocol handling which will all occur
in later parts.

Here's the first set of patches from the second go, aimed at net-next.  These
are all fixes and cleanups preparatory to the main event.

Notable parts of this set include:

 (1) A fix for the AFS filesystem to wait for outstanding calls to complete
     before closing the RxRPC socket.

 (2) Differentiation of local and remote abort codes.  At a future point
     userspace will get to see this via control message data on recvmsg().

 (3) Absorb the rxkad module into the af_rxrpc module to prevent a dependency
     loop.

 (4) Create a null security module and unconditionalise calls into the
     security module that's in force (there will always be a security module
     applied to a connection, even if it's just the null one).


The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160407

This is based on net-next/master

David
---
David Howells (9):
      afs: Wait for outstanding async calls before closing rxrpc socket
      rxrpc: Disable a debugging statement that has been left enabled.
      rxrpc: Move some miscellaneous bits out into their own file
      rxrpc: Static arrays of strings should be const char *const[]
      rxrpc: Differentiate local and remote abort codes in structs
      rxrpc: Don't pass gfp around in incoming call handling functions
      rxrpc: Don't assume transport address family and size when using it
      rxrpc: Absorb the rxkad security module
      rxrpc: Create a null security type and get rid of conditional calls


 fs/afs/rxrpc.c            |   30 +++++++-
 include/net/af_rxrpc.h    |    4 +
 include/rxrpc/packet.h    |    2 -
 net/rxrpc/Kconfig         |    2 -
 net/rxrpc/Makefile        |    7 +-
 net/rxrpc/af_rxrpc.c      |    9 ++
 net/rxrpc/ar-accept.c     |    4 +
 net/rxrpc/ar-ack.c        |   81 ++--------------------
 net/rxrpc/ar-call.c       |   11 +--
 net/rxrpc/ar-connection.c |   14 ++--
 net/rxrpc/ar-connevent.c  |   27 +++----
 net/rxrpc/ar-input.c      |   14 +---
 net/rxrpc/ar-internal.h   |   70 ++++++++++++-------
 net/rxrpc/ar-output.c     |    6 +-
 net/rxrpc/ar-proc.c       |    2 -
 net/rxrpc/ar-recvmsg.c    |   18 ++++-
 net/rxrpc/ar-security.c   |  166 +++++++++------------------------------------
 net/rxrpc/insecure.c      |   83 +++++++++++++++++++++++
 net/rxrpc/misc.c          |   89 ++++++++++++++++++++++++
 net/rxrpc/rxkad.c         |   61 +++++++----------
 20 files changed, 374 insertions(+), 326 deletions(-)
 create mode 100644 net/rxrpc/insecure.c
 create mode 100644 net/rxrpc/misc.c
