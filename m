From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 2/2] tipc: protect handler_enabled
	variable with qitem_lock spin lock
Date: Mon,  9 Dec 2013 22:54:47 -0800
Message-ID: <1386658487-5463-3-git-send-email-jon.maloy@ericsson.com>
References: <1386658487-5463-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1386658487-5463-1-git-send-email-jon.maloy@ericsson.com>
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

'handler_enabled' is a global flag indicating whether the TIPC
signal handling service is enabled or not. The lack of lock
protection for this flag incurs a risk for contention, so that
a tipc_k_signal() call might queue a signal handler to a destroyed
signal queue, with unpredictable results. To correct this, we let
the already existing 'qitem_lock' protect the flag, as it already
does with the queue itself. This way, we ensure that the flag
always is consistent across all cores.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/handler.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/tipc/handler.c b/net/tipc/handler.c
index b36f0fc..e4bc8a2 100644
--- a/net/tipc/handler.c
+++ b/net/tipc/handler.c
@@ -56,12 +56,13 @@ unsigned int tipc_k_signal(Handler routine, unsigned long argument)
 {
 	struct queue_item *item;
 
+	spin_lock_bh(&qitem_lock);
 	if (!handler_enabled) {
 		pr_err("Signal request ignored by handler\n");
+		spin_unlock_bh(&qitem_lock);
 		return -ENOPROTOOPT;
 	}
 
-	spin_lock_bh(&qitem_lock);
 	item = kmem_cache_alloc(tipc_queue_item_cache, GFP_ATOMIC);
 	if (!item) {
 		pr_err("Signal queue out of memory\n");
@@ -112,10 +113,14 @@ void tipc_handler_stop(void)
 	struct list_head *l, *n;
 	struct queue_item *item;
 
-	if (!handler_enabled)
+	spin_lock_bh(&qitem_lock);
+	if (!handler_enabled) {
+		spin_unlock_bh(&qitem_lock);
 		return;
-
+	}
 	handler_enabled = 0;
+	spin_unlock_bh(&qitem_lock);
+
 	tasklet_kill(&tipc_tasklet);
 
 	spin_lock_bh(&qitem_lock);
-- 
1.7.9.5


------------------------------------------------------------------------------
Sponsored by Intel(R) XDK 
Develop, test and display web and hybrid apps with a single code base.
Download it for free now!
http://pubads.g.doubleclick.net/gampad/clk?id=111408631&iu=/4140/ostg.clktrk
