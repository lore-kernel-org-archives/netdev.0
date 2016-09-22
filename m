From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/9] rxrpc: Preparation for slow-start algorithm
Date: Thu, 22 Sep 2016 01:39:08 +0100
Message-ID: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here are some patches that prepare for improvements in ACK generation and
for the implementation of the slow-start part of the protocol:

 (1) Stop storing the protocol header in the Tx socket buffers, but rather
     generate it on the fly.  This potentially saves a little space and
     makes it easier to alter the header just before transmission (the
     flags may get altered and the serial number has to be changed).

 (2) Mask off the Tx buffer annotations and add a flag to record which ones
     have already been resent.

 (3) Track RTT on a per-peer basis for use in future changes.  Tracepoints
     are added to log this.

 (4) Send PING ACKs in response to incoming calls to elicit a PING-RESPONSE
     ACK from which RTT data can be calculated.  The response also carries
     other useful information.

 (5) Expedite PING-RESPONSE ACK generation from sendmsg.  If we're actively
     using sendmsg, this allows us, under some circumstances, to avoid
     having to rely on the background work item to run to generate this
     ACK.

     This requires ktime_sub_ms() to be added.

 (6) Set the REQUEST-ACK flag on some DATA packets to elicit ACK-REQUESTED
     ACKs from which RTT data can be calculated.

 (7) Limit the use of pings and ACK requests for RTT determination.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160922

David
---
David Howells (9):
      rxrpc: Don't store the rxrpc header in the Tx queue sk_buffs
      rxrpc: Add re-sent Tx annotation
      rxrpc: Add per-peer RTT tracker
      rxrpc: Send pings to get RTT data
      rxrpc: Expedite ping response transmission
      rxrpc: Add ktime_sub_ms()
      rxrpc: Obtain RTT data by requesting ACKs on DATA packets
      rxrpc: Reduce the number of PING ACKs sent
      rxrpc: Reduce the number of ACK-Requests sent


 include/linux/ktime.h        |    5 ++
 include/trace/events/rxrpc.h |   61 ++++++++++++++++++++++
 net/rxrpc/ar-internal.h      |   47 ++++++++++++-----
 net/rxrpc/call_event.c       |   57 +++++++++++---------
 net/rxrpc/conn_object.c      |    1 
 net/rxrpc/input.c            |  100 ++++++++++++++++++++++++++++++++++--
 net/rxrpc/misc.c             |   25 ++++++---
 net/rxrpc/output.c           |  117 ++++++++++++++++++++++++++++++++----------
 net/rxrpc/peer_event.c       |   39 ++++++++++++++
 net/rxrpc/peer_object.c      |    1 
 net/rxrpc/rxkad.c            |    8 +--
 net/rxrpc/sendmsg.c          |   56 ++++----------------
 net/rxrpc/sysctl.c           |    2 -
 13 files changed, 389 insertions(+), 130 deletions(-)
