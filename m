From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 4/5] tipc: adjust locking policy
	of subscription
Date: Mon, 4 May 2015 10:36:47 +0800
Message-ID: <1430707008-11141-5-git-send-email-ying.xue@windriver.com>
References: <1430707008-11141-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1430707008-11141-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Currently subscriber's lock protects not only subscriber's subscription
list but also all subscriptions linked into the list. However, as all
members of subscription are never changed after they are initialized,
it's unnecessary for subscription to be protected under subscriber's
lock. If the lock is used to only protect subscriber's subscription
list, the adjustment not only makes the locking policy simpler, but
also helps to avoid a deadlock which may happen once creating a
subscription is failed.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericson.com>
---
 net/tipc/subscr.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 9b24c9c..350cca3 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -201,6 +201,7 @@ static void tipc_subscrp_cancel(struct tipc_subscr *s,
 {
 	struct tipc_subscription *sub, *temp;
 
+	spin_lock_bh(&subscriber->lock);
 	/* Find first matching subscription, exit if not found */
 	list_for_each_entry_safe(sub, temp, &subscriber->subscrp_list,
 				 subscrp_list) {
@@ -212,6 +213,7 @@ static void tipc_subscrp_cancel(struct tipc_subscr *s,
 			break;
 		}
 	}
+	spin_unlock_bh(&subscriber->lock);
 }
 
 static int tipc_subscrp_create(struct net *net, struct tipc_subscr *s,
@@ -260,7 +262,9 @@ static int tipc_subscrp_create(struct net *net, struct tipc_subscr *s,
 		kfree(sub);
 		return -EINVAL;
 	}
+	spin_lock_bh(&subscriber->lock);
 	list_add(&sub->subscrp_list, &subscriber->subscrp_list);
+	spin_unlock_bh(&subscriber->lock);
 	sub->subscriber = subscriber;
 	sub->swap = swap;
 	memcpy(&sub->evt.s, s, sizeof(*s));
@@ -289,13 +293,11 @@ static void tipc_subscrb_rcv_cb(struct net *net, int conid,
 	struct tipc_subscription *sub = NULL;
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
-	spin_lock_bh(&subscriber->lock);
 	tipc_subscrp_create(net, (struct tipc_subscr *)buf, subscriber, &sub);
 	if (sub)
 		tipc_nametbl_subscribe(sub);
 	else
 		tipc_conn_terminate(tn->topsrv, subscriber->conid);
-	spin_unlock_bh(&subscriber->lock);
 }
 
 /* Handle one request to establish a new subscriber */
-- 
1.7.9.5


------------------------------------------------------------------------------
One dashboard for servers and applications across Physical-Virtual-Cloud 
Widest out-of-the-box monitoring support with 50+ applications
Performance metrics, stats and reports that give you Actionable Insights
Deep dive visibility with transaction tracing using APM Insight.
http://ad.doubleclick.net/ddm/clk/290420510;117567292;y
