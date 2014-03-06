From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v3 4/6] tipc: drop subscriber
	connection id invalidation
Date: Thu, 6 Mar 2014 14:40:19 +0100
Message-ID: <1394113221-30100-5-git-send-email-erik.hugne@ericsson.com>
References: <1394113221-30100-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1394113221-30100-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

When a topology server subscriber is disconnected, the associated
connection id is set to zero. A check vs zero is then done in the
subscription timeout function to see if the subscriber have been
shut down. This is unnecessary, because all subscription timers
will be cancelled when a subscriber terminates. Setting the
connection id to zero is actually harmful because id zero is the
identity of the topology server listening socket, and can cause a
race that leads to this socket being closed instead.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/subscr.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index a6ce3bb..11c9ae0 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -149,14 +149,6 @@ static void subscr_timeout(struct tipc_subscription *sub)
 	/* The spin lock per subscriber is used to protect its members */
 	spin_lock_bh(&subscriber->lock);
 
-	/* Validate if the connection related to the subscriber is
-	 * closed (in case subscriber is terminating)
-	 */
-	if (subscriber->conid == 0) {
-		spin_unlock_bh(&subscriber->lock);
-		return;
-	}
-
 	/* Validate timeout (in case subscription is being cancelled) */
 	if (sub->timeout == TIPC_WAIT_FOREVER) {
 		spin_unlock_bh(&subscriber->lock);
@@ -211,9 +203,6 @@ static void subscr_release(struct tipc_subscriber *subscriber)
 
 	spin_lock_bh(&subscriber->lock);
 
-	/* Invalidate subscriber reference */
-	subscriber->conid = 0;
-
 	/* Destroy any existing subscriptions for subscriber */
 	list_for_each_entry_safe(sub, sub_temp, &subscriber->subscription_list,
 				 subscription_list) {
-- 
1.8.3.2


------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
