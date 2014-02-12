From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 00/14] tipc: clean up media and
	bearer layer
Date: Wed, 12 Feb 2014 13:31:00 -0500
Message-ID: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

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
 net/tipc/link.c   |  433 ++++++++++++++++++++++++++++++-----------------------
 net/tipc/link.h   |   34 ++---
 net/tipc/node.c   |    8 +-
 7 files changed, 283 insertions(+), 250 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
