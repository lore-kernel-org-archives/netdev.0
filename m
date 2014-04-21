From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 00/11] purge tipc_net_lock
Date: Mon, 21 Apr 2014 10:55:41 +0800
Message-ID: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
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

Now tipc routing hierarchy comprises the structures 'node', 'link'and
'bearer'. The whole hierarchy is protected by a big read/write lock,
tipc_net_lock, to ensure that nothing is added or removed while code
is accessing any of these structures. Obviously the locking policy
makes node, link and bearer components closely bound together so that
their relationship becomes unnecessarily complex. In the worst case,
such locking policy not only has a negative influence on performance,
but also it's prone to lead to deadlock occasionally.

In order o decouple the complex relationship between bearer and node
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

Ying Xue (11):
  tipc: replace config_mutex lock with RTNL lock
  tipc: adjust locking policy of protecting tipc_ptr pointer of
    net_device
  tipc: use RTNL lock to protect tipc_net_stop routine
  tipc: convert bearer_list to RCU list
  tipc: decouple the relationship between bearer and link
  tipc: use RCU to protect media_ptr pointer
  tipc: purge tipc_net_lock lock
  tipc: make media_ptr pointed netdevice valid
  tipc: use bearer_disable to disable bearer in tipc_l2_device_event
  tipc: use bc_lock to protect node map in bearer structure
  tipc: fix race in disc create/delete

 net/tipc/bcast.c      |   37 +++++++++-------
 net/tipc/bcast.h      |    5 +--
 net/tipc/bearer.c     |  117 ++++++++++++++++++++++++++-----------------------
 net/tipc/bearer.h     |   12 ++---
 net/tipc/config.c     |    6 +--
 net/tipc/core.h       |    2 +-
 net/tipc/discover.c   |   70 ++++++++++++++++++-----------
 net/tipc/discover.h   |    1 +
 net/tipc/link.c       |   89 +++++++++++++++++--------------------
 net/tipc/link.h       |    6 ++-
 net/tipc/name_distr.c |    2 -
 net/tipc/net.c        |   61 +++++++++++---------------
 net/tipc/net.h        |    2 -
 net/tipc/node.c       |   10 ++---
 14 files changed, 215 insertions(+), 205 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
