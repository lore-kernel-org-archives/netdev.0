From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 00/14] tipc: clean up media and bearer layer
Date: Thu, 13 Feb 2014 17:27:29 -0500
Message-ID: <1392330463-18954-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.ne1.yahoo.com ([98.138.207.11]:44586 "HELO
	smtp104.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752282AbaBMW1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:27:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit series aims at facilitating future changes to the
locking policy around nodes, links and bearers.

Currently, we have a big read/write lock (net_lock) that is used for
serializing all changes to the node, link and bearer lists, as well
as to their mutual pointers and references.

But, in order to allow for concurrent access to the contents of these
structures, net_lock is only used in read mode by the data path code,
and hence a finer granular locking policy must be applied inside the
scope of net_lock: a spinlock (node_lock) for each node structure,
and another one (bearer_lock) for protection of bearer structures.

This locking policy has proved hard to maintain. We have several 
times encountered contention problems between node_lock and 
bearer_lock, and with the advent of the RCU locking mechanism we
feel it is anyway obsolete and ripe for improvements.

We now plan to replace net_lock with an RCU lock, as well as
getting rid of bearer_lock altogether. This will both reduce data
path overhead and make the code more manageable, while reducing the
risk of future lock contention problems.

Prior to these changes, we need to do some necessary cleanup and
code consolidation. This is what we do with this commit series,
before we finally remove bearer_lock. In a later series we will
replace net_lock with an RCU lock.

v2:
 - Re-inserted a removed kerneldoc entry in commit#5, based on 
   feedback from D. Miller.


Jon Maloy (9):
  tipc: stricter behavior of message reassembly function
  tipc: change reception of tunnelled duplicate packets
  tipc: change reception of tunnelled failover packets
  tipc: change signature of tunnelling reception function
  tipc: more cleanup of tunnelling reception function
  tipc: rename stack variables in function tipc_link_tunnel_rcv
  tipc: changes to general packet reception algorithm
  tipc: delay delete of link when failover is needed
  tipc: add node_lock protection to link lookup function

Ying Xue (5):
  tipc: move code for resetting links from bearer.c to link.c
  tipc: move code for deleting links from bearer.c to link.c
  tipc: redefine 'started' flag in struct link to bitmap
  tipc: remove 'links' list from tipc_bearer struct
  tipc: remove bearer_lock from tipc_bearer struct

 net/tipc/bcast.c  |    7 +-
 net/tipc/bearer.c |   42 ++----
 net/tipc/bearer.h |    7 +-
 net/tipc/core.c   |    2 +-
 net/tipc/link.c   |  432 ++++++++++++++++++++++++++++++-----------------------
 net/tipc/link.h   |   34 ++---
 net/tipc/node.c   |    8 +-
 7 files changed, 283 insertions(+), 249 deletions(-)

-- 
1.7.9.5
