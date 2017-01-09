From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/4] afs: Refcount afs_call struct
Date: Mon, 09 Jan 2017 14:52:49 +0000
Message-ID: <148397356909.20445.15077871371099721338.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


These patches provide some tracepoints for AFS and fix a potential leak by
adding refcounting to the afs_call struct.

The patches are:

 (1) Add some tracepoints for logging incoming calls and monitoring
     notifications from AF_RXRPC and data reception.

 (2) Get rid of afs_wait_mode as it didn't turn out to be as useful as
     initially expected.  It can be brought back later if needed.  This
     clears some stuff out that I don't then need to fix up in (4).

 (3) Allow listen(..., 0) to be used to disable listening.  This makes
     shutting down the AFS cache manager server in the kernel much easier
     and the accounting simpler as we can then be sure that (a) all
     preallocated afs_call structs are relesed and (b) no new incoming
     calls are going to be started.

     For the moment, listening cannot be reenabled.

 (4) Add refcounting to the afs_call struct to fix a potential multiple
     release detected by static checking and add a tracepoint to follow the
     lifecycle of afs_call objects.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20170109

David
---
David Howells (4):
      afs: Add some tracepoints
      afs: Kill afs_wait_mode
      rxrpc: Allow listen(sock, 0) to be used to disable listening
      afs: Refcount the afs_call struct


 fs/afs/callback.c          |    2 
 fs/afs/cmservice.c         |   63 ++++++++-----
 fs/afs/fsclient.c          |   80 ++++++++---------
 fs/afs/internal.h          |   96 ++++++++------------
 fs/afs/main.c              |    1 
 fs/afs/rxrpc.c             |  208 +++++++++++++++++++++++---------------------
 fs/afs/vlclient.c          |    8 +-
 fs/afs/vlocation.c         |    4 -
 fs/afs/vnode.c             |   26 +++---
 include/trace/events/afs.h |  184 +++++++++++++++++++++++++++++++++++++++
 net/rxrpc/af_rxrpc.c       |    8 ++
 net/rxrpc/ar-internal.h    |    1 
 net/rxrpc/call_accept.c    |    3 -
 13 files changed, 442 insertions(+), 242 deletions(-)
 create mode 100644 include/trace/events/afs.h
