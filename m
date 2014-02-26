From: David Howells <dhowells@redhat.com>
Subject: [GIT PULL] AF_RXRPC fixes and development
Date: Wed, 26 Feb 2014 17:41:45 +0000
Message-ID: <12143.1393436505@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	Tim Smith <tim@electronghost.co.uk>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here are some AF_RXRPC fixes (to tag rxrpc-20140226):

 (1) Fix to remove incorrect checksum calculation made during recvmsg().  It's
     unnecessary to try to do this there since we check the checksum before
     reading the RxRPC header from the packet.

 (2) Fix to prevent the sending of an ABORT packet in response to another
     ABORT packet and inducing a storm.

 (3) Fix UDP MTU calculation from parsing ICMP_FRAG_NEEDED packets where we
     don't handle the ICMP packet not specifying an MTU size.

And development patches (to tag rxrpc-devel-20140226):

 (4) Add sysctls for configuring RxRPC parameters, specifically various delays
     pertaining to ACK generation, the time before we resend a packet for
     which we don't receive an ACK, the maximum time a call is permitted to
     live and the amount of time transport, connection and dead call
     information is cached.

 (5) Improve ACK packet production by adjusting the handling of ACK_REQUESTED
     packets, ignoring the MORE_PACKETS flag, delaying the production of
     otherwise immediate ACK_IDLE packets and delaying all ACK_IDLE production
     (barring the call termination) to half a second.

 (6) Add more sysctl parameters to expose the Rx window size, the maximum
     packet size that we're willing to receive and the number of jumbo rxrpc
     packets we're willing to handle in a single UDP packet.

 (7) Request ACKs on alternate DATA packets so that the other side doesn't
     wait till we fill up the Tx window.

 (8) Use a RCU hash table to look up the rxrpc_call for an incoming packet
     rather than stepping through a hierarchy involving several spinlocks.

Would you rather these were separate pull requests?

David
---
The following changes since commit 38dbfb59d1175ef458d006556061adeaa8751b72:

  Linus 3.14-rc1 (2014-02-02 16:42:13 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/rxrpc-devel-20140226

for you to fetch changes up to 224c577c412f620a600c15c86afe82157161d7e7:

  af_rxrpc: Keep rxrpc_call pointers in a hashtable (2014-02-26 17:25:07 +0000)

----------------------------------------------------------------
(from the branch description for rxrpc local branch)

RxRPC development
RxRPC development

----------------------------------------------------------------
David Howells (5):
      af_rxrpc: Fix UDP MTU calculation from ICMP_FRAG_NEEDED
      af_rxrpc: Add sysctls for configuring RxRPC parameters
      af_rxrpc: Improve ACK production
      af_rxrpc: Expose more RxRPC parameters via sysctls
      af_rxrpc: Request an ACK for every alternate DATA packet

Tim Smith (3):
      af_rxrpc: Remove incorrect checksum calculation from rxrpc_recvmsg()
      af_rxrpc: Prevent RxRPC peers from ABORT-storming one another
      af_rxrpc: Keep rxrpc_call pointers in a hashtable

 Documentation/networking/rxrpc.txt |  81 +++++++++++++++
 net/rxrpc/Makefile                 |   5 +-
 net/rxrpc/af_rxrpc.c               |   9 ++
 net/rxrpc/ar-ack.c                 |  61 +++++++++--
 net/rxrpc/ar-call.c                | 202 +++++++++++++++++++++++++++++++++++--
 net/rxrpc/ar-connection.c          |  10 +-
 net/rxrpc/ar-error.c               |   1 +
 net/rxrpc/ar-input.c               | 190 +++++++++++++++-------------------
 net/rxrpc/ar-internal.h            |  40 +++++++-
 net/rxrpc/ar-output.c              |  15 ++-
 net/rxrpc/ar-recvmsg.c             |  25 +----
 net/rxrpc/ar-skbuff.c              |   7 +-
 net/rxrpc/ar-transport.c           |  10 +-
 net/rxrpc/sysctl.c                 | 146 +++++++++++++++++++++++++++
 14 files changed, 636 insertions(+), 166 deletions(-)
 create mode 100644 net/rxrpc/sysctl.c
