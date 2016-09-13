From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 00/10] rxrpc: Miscellaneous fixes
Date: Tue, 13 Sep 2016 23:20:56 +0100
Message-ID: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here's a set of miscellaneous fix patches.  There are a couple of points of
note:

 (1) There is one non-fix patch that adjusts the call ref tracking
     tracepoint to make kernel API-held refs on calls more obvious.  This
     is a prerequisite for the patch that fixes prealloc refcounting.

 (2) The final patch alters how jumbo packets that partially exceed the
     receive window are handled.  Previously, space was being left in the
     Rx buffer for them, but this significantly hurts performance as the Rx
     window can't be increased to match the OpenAFS Tx window size.

     Instead, the excess subpackets are discarded and an EXCEEDS_WINDOW ACK
     is generated for the first.  To avoid the problem of someone trying to
     run the kernel out of space by feeding the kernel a series of
     overlapping maximal jumbo packets, we stop allowing jumbo packets on a
     call if we encounter more than three jumbo packets with duplicate or
     excessive subpackets.

The patches can be found here also (non-terminally on the branch):

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160913-1

David
---
David Howells (10):
      rxrpc: Make sure we initialise the peer hash key
      rxrpc: Add missing wakeup on Tx window rotation
      rxrpc: The IDLE ACK packet should use rxrpc_idle_ack_delay
      rxrpc: Requeue call for recvmsg if more data
      rxrpc: Add missing unlock in rxrpc_call_accept()
      rxrpc: Use skb->len not skb->data_len
      rxrpc: Allow tx_winsize to grow in response to an ACK
      rxrpc: Adjust the call ref tracepoint to show kernel API refs
      rxrpc: Fix prealloc refcounting
      rxrpc: Correctly initialise, limit and transmit call->rx_winsize


 net/rxrpc/af_rxrpc.c    |    2 +-
 net/rxrpc/ar-internal.h |    5 ++++-
 net/rxrpc/call_accept.c |   20 +++++++++++++++-----
 net/rxrpc/call_event.c  |    2 +-
 net/rxrpc/call_object.c |    7 +++----
 net/rxrpc/input.c       |   41 +++++++++++++++++++++++++++--------------
 net/rxrpc/misc.c        |    5 ++++-
 net/rxrpc/output.c      |    4 ++--
 net/rxrpc/peer_object.c |    2 +-
 net/rxrpc/recvmsg.c     |    5 +++++
 net/rxrpc/sysctl.c      |    2 +-
 11 files changed, 64 insertions(+), 31 deletions(-)
