From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/4] rxrpc: Support service upgrade
Date: Tue, 06 Jun 2017 10:54:21 +0100
Message-ID: <149674286135.26138.12623162384868251541.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here's a set of patches that allow AF_RXRPC to support the AuriStor service
upgrade facility.  This allows the server to change the service ID
requested to an upgraded service if the client requests it upon the
initiation of a connection.

This is used by the AuriStor AFS-compatible servers to implement IPv6
handling and improved facilities by providing improved volume location,
volume, protection, file and cache management services.  Note that certain
parts of the AFS protocol carry hard-coded IPv4 addresses.

The reason AuriStor does it this way is that probing the improved service
ID first will not incur an ABORT or any other response on some servers if
the server is not listening on it - and so one have to employ a timeout.

This is implemented in the server by allowing an AF_RXRPC server to call
bind() twice on a socket to allow it to listen on two service IDs and then
call setsockopt() to instruct the server to upgrade one into the other if
the client requests it (by setting userStatus to 1 on the first DATA packet
on a connection).  If the upgrade occurs, all further operations on that
connection are done with the new service ID.  AF_RXRPC has to handle this
automatically as connections are not exposed to userspace.

Clients can request this facility by setting an RXRPC_UPGRADE_SERVICE
command in the sendmsg() control buffer and then observing the resultant
service ID in the msg_addr returned by recvmsg().  This should only be used
to probe the service.  Clients should then use the returned service ID in
all subsequent communications with that server.  Note that the kernel will
not retain this information should the connection expire from its cache.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20170606

David
---
David Howells (4):
      rxrpc: Separate the connection's protocol service ID from the lookup ID
      rxrpc: Permit multiple service binding
      rxrpc: Implement service upgrade
      rxrpc: Add service upgrade support for client connections


 Documentation/networking/rxrpc.txt |   68 +++++++++++++++++++++++++---
 include/linux/rxrpc.h              |    2 +
 include/rxrpc/packet.h             |    2 +
 include/trace/events/rxrpc.h       |    1 
 net/rxrpc/af_rxrpc.c               |   88 ++++++++++++++++++++++++++----------
 net/rxrpc/ar-internal.h            |   17 ++++++-
 net/rxrpc/call_accept.c            |    5 +-
 net/rxrpc/conn_client.c            |   47 ++++++++++++++++---
 net/rxrpc/conn_event.c             |    4 +-
 net/rxrpc/conn_object.c            |    1 
 net/rxrpc/conn_service.c           |   12 +++++
 net/rxrpc/input.c                  |   17 +++++++
 net/rxrpc/local_object.c           |    1 
 net/rxrpc/output.c                 |    4 ++
 net/rxrpc/proc.c                   |    2 -
 net/rxrpc/recvmsg.c                |    7 ++-
 net/rxrpc/rxkad.c                  |    2 -
 net/rxrpc/security.c               |    5 +-
 net/rxrpc/sendmsg.c                |   19 ++++++--
 19 files changed, 245 insertions(+), 59 deletions(-)
