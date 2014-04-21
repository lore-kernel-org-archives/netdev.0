From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 02/11] tipc: adjust locking
	policy of protecting tipc_ptr pointer of net_device
Date: Mon, 21 Apr 2014 10:55:43 +0800
Message-ID: <1398048952-7825-3-git-send-email-ying.xue@windriver.com>
References: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Currently the 'tipc_ptr' pointer is protected by tipc_net_lock
write lock on write side, and RCU read lock is applied to read
side. In addition, there have two paths on write side where we
may change variables pointed by the 'tipc_ptr' pointer: one is
to configure bearer by tipc-config tool and another one is that
bearer status is changed by notification events of its attached
interface. But on the latter path, we improperly deem that
accessing 'tipc_ptr' pointer happens on read side with
rcu_read_lock() although some variables pointed by the 'tipc_ptr'
pointer are changed possibly.

Moreover, as now the both paths are guarded by RTNL lock, it's
better to adjust the locking policy of 'tipc_ptr' pointer
protection, allowing RTNL instead of tipc_net_lock write lock to
protect it on write side, which will help us purge tipc_net_lock
in the future.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bearer.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 3fef7eb..dfb4c7f 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -535,7 +535,7 @@ static int tipc_l2_rcv_msg(struct sk_buff *buf, struct net_device *dev,
 	}
 
 	rcu_read_lock();
-	b_ptr = rcu_dereference(dev->tipc_ptr);
+	b_ptr = rcu_dereference_rtnl(dev->tipc_ptr);
 	if (likely(b_ptr)) {
 		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
 			buf->next = NULL;
@@ -568,12 +568,9 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
-	rcu_read_lock();
-	b_ptr = rcu_dereference(dev->tipc_ptr);
-	if (!b_ptr) {
-		rcu_read_unlock();
+	b_ptr = rtnl_dereference(dev->tipc_ptr);
+	if (!b_ptr)
 		return NOTIFY_DONE;
-	}
 
 	b_ptr->mtu = dev->mtu;
 
@@ -595,8 +592,6 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 		tipc_disable_bearer(b_ptr->name);
 		break;
 	}
-	rcu_read_unlock();
-
 	return NOTIFY_OK;
 }
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
