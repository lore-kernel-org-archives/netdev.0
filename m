From: David Howells <dhowells@redhat.com>
Subject: [PATCH 00/14] AF_RXRPC socket family and AFS rewrite [net-2.6]
Date: Thu, 26 Apr 2007 20:54:15 +0100
Message-ID: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754983AbXDZTya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 15:54:30 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3QJsTiW028220
	for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 15:54:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[This set of patches is built against Dave Miller's net-2.6 GIT tree]

The first of these patches together provide secure client-side RxRPC
connectivity as a Linux kernel socket family.  Only the RxRPC transport/session
side is supplied - the presentation side (marshalling the data) is left to the
client.  Copies of the patches can be found here:

	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/series
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/01-cancel_delayed_work.diff
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/02-keys.diff
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/03-timer-exports.diff
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/04-af_rxrpc.diff

Further patches make the in-kernel AFS filesystem use AF_RXRPC and delete the
old RxRPC implementation:

	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/05-afs-cleanup.diff
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/06-af_rxrpc-kernel.diff
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/07-af_rxrpc-afs.diff
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/08-af_rxrpc-delete-old.diff

And then the rest of the patches extend AFS to provide automatic unmounting of
automount trees, security support and directory-level write support (create,
mkdir, etc.):

	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/09-afs-multimount.diff
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/10-afs-security.diff
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/11-afs-doc.diff
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/12-afs-get-capabilities.diff
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/13-afs-initcallbackstate3.diff
	http://people.redhat.com/~dhowells/rxrpc/nfs-2.6/14-afs-dir-write-support.diff

Note that file-level write support is not yet complete and so is not included
in this patch set.


The userspace access methods make use of the control data passed to/by
sendmsg() and recvmsg().  See the three simple test programs:

	http://people.redhat.com/~dhowells/rxrpc/klog.c
	http://people.redhat.com/~dhowells/rxrpc/rxrpc.c
	http://people.redhat.com/~dhowells/rxrpc/listen.c

The klog program is provided to go and get a Kerberos IV key from the AFS
kaserver.  Currently it must be edited before compiling to note the right
server IP address and the appropriate credentials.

These programs can be compiled by:

	make klog rxrpc listen CFLAGS="-Wall -g" LDLIBS="-lcrypto -lcrypt -lkrb4 -lkeyutils"

Then a ticket can be obtained by:

	./klog

If a security key is acquired in this way, then all subsequent AFS operations -
including VL lookups and mounts - performed with that session keyring will be
authenticated using that key.  The key can be viewed like so:

	[root@andromeda ~]# keyctl show
	Session Keyring
	       -3 --alswrv      0     0  keyring: _ses.3268
		2 --alswrv      0     0   \_ keyring: _uid.0
	111416553 --als--v      0     0   \_ rxrpc: afs@CAMBRIDGE.REDHAT.COM

TODO:

 (*) Make certain parameters (such as connection timeouts) userspace
     configurable.

 (*) Make userspace utilities use it; librxrpc.

 (*) Userspace documentation.

 (*) KerberosV security.

Changes:

 (*) SOCK_RPC has been removed.  SOCK_DGRAM is now used instead.

 (*) I've add a facility whereby calls can be made to destinations other than
     the connect() address of a client socket by making use of msg_name in the
     msghdr struct when using sendmsg() to send the first data packet of a
     call.  Indeed, a client socket need not be connected before being used
     so.

 (*) I've also added a facility whereby client calls may also be made on
     server sockets, again by using msg_name in the msghdr struct.  In such a
     case, the server's local transport endpoint is used.

 (*) I've made the write buffer space check available to various callers
     (sk_write_space) and implemented poll support.

 (*) Rewrote rxrpc_recvmsg().  It now concatenates adjacent data messages from
     the same call when delivering them.

 (*) Updated the documentation to include notes on recvmsg, cover control
     messages and cover SOL_RXRPC-level socket options.

 (*) Provided an in-kernel interface to give in-kernel utilities easier access
     to the facility.

 (*) Made fs/afs/ use it.

 (*) Deleted the old contents of net/rxrpc/.

 (*) Use the scatterlist interface to the crypto API for now.  The patch that
     added the direct access interface conflicts with patches Herbert Xu is
     producing, so I've dropped it for the moment.

 (*) Moved a bug fix to make secure connection reuse work from the
     af_rxrpc-kernel patch to the af_rxrpc main patch.

 (*) Make RxRPC use its own private work queues rather than keventd's to avoid
     deadlocks when AFS tries to use keventd too.  This also puts encryption
     in the private work queue rather than keventd's queue as that might take
     a relatively long time to process.

 (*) Shorten the dead call timeout to 2 seconds.  Without this, each completed
     call sits around eating up resources for 10 seconds.  The calls need to
     hang around for a little while in case duplicate packets appear, but 10
     seconds is excessive.

 (*) Decrement the number of available calls on a connection when a new call is
     allocated for a connection that doesn't have any calls in progress.

 (*) Rename header files with uppercase names to lowercase names.

 (*) Make sure include/keys/rxrpc-type.h is included.

David
