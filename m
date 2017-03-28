From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 1/2] tipc: advance the time of
	deleting subscription from subscriber->subscrp_list
Date: Tue, 28 Mar 2017 12:28:27 +0200
Message-ID: <1490696908-7790-2-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1490696908-7790-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1490696908-7790-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ying Xue <ying.xue@windriver.com>

After a subscription object is created, it's inserted into its
subscriber subscrp_list list under subscriber lock protection,
similarly, before it's destroyed, it should be first removed from
its subscriber->subscrp_list. Since the subscription list is
accessed with subscriber lock, all the subscriptions are valid
during the lock duration. Hence in tipc_subscrb_subscrp_delete(), we
remove subscription get/put and the extra subscriber unlock/lock.

After this change, the subscriptions refcount cleanup is very simple
and does not access any lock.

Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/subscr.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 271cd66e4b3b..0649bc29c6bb 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -145,6 +145,7 @@ static void tipc_subscrp_timeout(unsigned long data)
 
 	spin_lock_bh(&subscriber->lock);
 	tipc_nametbl_unsubscribe(sub);
+	list_del(&sub->subscrp_list);
 	spin_unlock_bh(&subscriber->lock);
 
 	/* Notify subscriber of timeout */
@@ -177,10 +178,7 @@ static void tipc_subscrp_kref_release(struct kref *kref)
 	struct tipc_net *tn = net_generic(sub->net, tipc_net_id);
 	struct tipc_subscriber *subscriber = sub->subscriber;
 
-	spin_lock_bh(&subscriber->lock);
-	list_del(&sub->subscrp_list);
 	atomic_dec(&tn->subscription_count);
-	spin_unlock_bh(&subscriber->lock);
 	kfree(sub);
 	tipc_subscrb_put(subscriber);
 }
@@ -210,11 +208,8 @@ static void tipc_subscrb_subscrp_delete(struct tipc_subscriber *subscriber,
 			continue;
 
 		tipc_nametbl_unsubscribe(sub);
-		tipc_subscrp_get(sub);
-		spin_unlock_bh(&subscriber->lock);
+		list_del(&sub->subscrp_list);
 		tipc_subscrp_delete(sub);
-		tipc_subscrp_put(sub);
-		spin_lock_bh(&subscriber->lock);
 
 		if (s)
 			break;
-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
