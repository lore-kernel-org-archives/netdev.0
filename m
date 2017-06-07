From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/3] rxrpc: Tx length parameter
Date: Wed, 07 Jun 2017 22:12:32 +0100
Message-ID: <149686995195.21359.17550471913376009423.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here's a set of patches that allows someone initiating a client call with
AF_RXRPC to indicate upfront the total amount of data that will be
transmitted.  This will allow AF_RXRPC to encrypt directly from source
buffer to packet rather than having to copy into the buffer and only
encrypt when it's full (the encrypted portion of the packet starts with a
length and so we can't encrypt until we know what the length will be).

The three patches are:

 (1) Provide a means of finding out what control message types are actually
     supported.  EINVAL is reported if an unsupported cmsg type is seen, so
     we don't want to set the new cmsg unless we know it will be accepted.

 (2) Consolidate some stuff into a struct to reduce the parameter count on
     the function that parses the cmsg buffer.

 (3) Introduce the RXRPC_TX_LENGTH cmsg.  This can be provided on the first
     sendmsg() that contributes data to a client call request or a service
     call reply.  If provided, the user must provide exactly that amount of
     data or an error will be incurred.

Changes in version 2:

 (*) struct rxrpc_send_params::tx_total_len should be s64 not u64.  Thanks to
     Julia Lawall for reporting this.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20170607-v2

David
---
David Howells (3):
      rxrpc: Provide a getsockopt call to query what cmsgs types are supported
      rxrpc: Consolidate sendmsg parameters
      rxrpc: Provide a cmsg to specify the amount of Tx data for a call


 Documentation/networking/rxrpc.txt |   43 +++++++++++
 fs/afs/rxrpc.c                     |   18 +++++
 include/linux/rxrpc.h              |   25 ++++---
 include/net/af_rxrpc.h             |    2 +
 net/rxrpc/af_rxrpc.c               |   35 +++++++++
 net/rxrpc/ar-internal.h            |    3 +
 net/rxrpc/call_object.c            |    3 +
 net/rxrpc/sendmsg.c                |  135 +++++++++++++++++++++++++-----------
 8 files changed, 207 insertions(+), 57 deletions(-)
