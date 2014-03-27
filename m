From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 00/10] clean up bearer and node
	layer
Date: Thu, 27 Mar 2014 12:54:29 +0800
Message-ID: <1395896080-7926-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
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

This is another commit series which aims at facilitating future
changes to the locking policy around nodes, links and bearers.

Currently, the tipc routing hierarchy comprises the structures 'node',
'link' and 'bearer'. The whole hierarchy is protected by a big
read/write lock (tipc_net_lock), to ensure that nothing is added or
removed while any of these structures is being accessed. Obviously
the locking policy makes node, link and bearer components closely
bound together so that their relationship becomes extremely complex.
In the worst case, such locking policy not only has a negative
influence on performance, but also it's prone to lead to deadlock
occasionally.

In order to decouple the complex relationship between bearer and node
as well as link, the locking policy is adjusted as follows:

- Bearer level
  RTNL lock is used on update side, and RCU is used on read side.
  Meanwhile, all bearer instances including broadcast bearer are
  saved into bearer_list array.

- Node and link level
  All node instances are saved into two tipc_node_list and node_htable
  lists. The two lists are protected by node_list_lock on write side,
  and they are guarded with RCU lock on read side. All members in node
  structure including link instances are protected by node spin lock.

- The relationship between bearer and node
  When link accesses bearer, it first needs to find the bearer with
  its bearer identity from the bearer_list array. When bearer accesses
  node, it can iterate the node_htable hash list with the node address
  to find the corresponding node.

In the new locking policy, every component has its private locking
solution and the relationship between bearer and node is very simple,
that is, they can find each other with node address or bearer identity
from node_htable hash list or bearer_list array.

But, prior to these changes, we need to do some necessary cleanup and
code consolidation. This is what we do with this commit series. In a
later series we will replace net_lock with RTNL as well as RCU lock
to deploy the new locking policy.

Ying Xue (10):
  tipc: remove unnecessary checking for node object
  tipc: obsolete the remote management feature
  tipc: acquire necessary locks in named_cluster_distribute routine
  tipc: convert tipc_bearers array to pointer list
  tipc: remove active flag from tipc_bearer structure
  tipc: make broadcast bearer store in bearer_list array
  tipc: rename node create lock to protect node list and hlist
  tipc: tipc: convert node list and node hlist to RCU lists
  tipc: use node_list_lock to protect tipc_num_nodes variable
  tipc: use node list lock to protect tipc_num_links variable

 net/tipc/bcast.c      |   13 +++---
 net/tipc/bearer.c     |   49 ++++++++++++++++------
 net/tipc/bearer.h     |    4 +-
 net/tipc/config.c     |  107 ++-----------------------------------------------
 net/tipc/config.h     |    5 ---
 net/tipc/core.c       |    9 -----
 net/tipc/core.h       |    1 -
 net/tipc/link.c       |   20 ++++-----
 net/tipc/name_distr.c |   16 ++++++--
 net/tipc/net.c        |    9 ++---
 net/tipc/node.c       |  107 ++++++++++++++++++++++++-------------------------
 net/tipc/node.h       |    6 ++-
 12 files changed, 129 insertions(+), 217 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
