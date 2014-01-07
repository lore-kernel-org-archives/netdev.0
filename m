From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/4] tipc: introduce new spinlock
	to protect struct link_req
Date: Tue,  7 Jan 2014 17:02:43 -0500
Message-ID: <1389132164-32451-4-git-send-email-jon.maloy@ericsson.com>
References: <1389132164-32451-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1389132164-32451-1-git-send-email-jon.maloy@ericsson.com>
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

Currently, only 'bearer_lock' is used to protect struct link_req in
the function disc_timeout(). This is unsafe, since the member fields
'num_nodes' and 'timer_intv' might be accessed by below three different
threads simultaneously, none of them grabbing bearer_lock in the
critical region:

link_activate()
  tipc_bearer_add_dest()
    tipc_disc_add_dest()
      req->num_nodes++;

tipc_link_reset()
  tipc_bearer_remove_dest()
    tipc_disc_remove_dest()
      req->num_nodes--
      disc_update()
        read req->num_nodes
	write req->timer_intv

disc_timeout()
  read req->num_nodes
  read/write req->timer_intv

Without lock protection, the only symptom of a race is that discovery
messages occasionally may not be sent out. This is not fatal, since such
messages are best-effort anyway. On the other hand, since discovery
messages are not time critical, adding a protecting lock brings no
serious overhead either. So we add a new, dedicated spinlock in
order to guarantee absolute data consistency in link_req objects.
This also helps reduce the overall role of the bearer_lock, which
we want to remove completely in a later commit series.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/discover.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index bc849f1..412ff41 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -50,6 +50,7 @@
  * @dest: destination address for request messages
  * @domain: network domain to which links can be established
  * @num_nodes: number of nodes currently discovered (i.e. with an active link)
+ * @lock: spinlock for controlling access to requests
  * @buf: request message to be (repeatedly) sent
  * @timer: timer governing period between requests
  * @timer_intv: current interval between requests (in ms)
@@ -59,6 +60,7 @@ struct tipc_link_req {
 	struct tipc_media_addr dest;
 	u32 domain;
 	int num_nodes;
+	spinlock_t lock;
 	struct sk_buff *buf;
 	struct timer_list timer;
 	unsigned int timer_intv;
@@ -274,7 +276,9 @@ static void disc_update(struct tipc_link_req *req)
  */
 void tipc_disc_add_dest(struct tipc_link_req *req)
 {
+	spin_lock_bh(&req->lock);
 	req->num_nodes++;
+	spin_unlock_bh(&req->lock);
 }
 
 /**
@@ -283,8 +287,10 @@ void tipc_disc_add_dest(struct tipc_link_req *req)
  */
 void tipc_disc_remove_dest(struct tipc_link_req *req)
 {
+	spin_lock_bh(&req->lock);
 	req->num_nodes--;
 	disc_update(req);
+	spin_unlock_bh(&req->lock);
 }
 
 /**
@@ -297,7 +303,7 @@ static void disc_timeout(struct tipc_link_req *req)
 {
 	int max_delay;
 
-	spin_lock_bh(&req->bearer->lock);
+	spin_lock_bh(&req->lock);
 
 	/* Stop searching if only desired node has been found */
 	if (tipc_node(req->domain) && req->num_nodes) {
@@ -325,7 +331,7 @@ static void disc_timeout(struct tipc_link_req *req)
 
 	k_start_timer(&req->timer, req->timer_intv);
 exit:
-	spin_unlock_bh(&req->bearer->lock);
+	spin_unlock_bh(&req->lock);
 }
 
 /**
@@ -356,6 +362,7 @@ int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest,
 	req->domain = dest_domain;
 	req->num_nodes = 0;
 	req->timer_intv = TIPC_LINK_REQ_INIT;
+	spin_lock_init(&req->lock);
 	k_init_timer(&req->timer, (Handler)disc_timeout, (unsigned long)req);
 	k_start_timer(&req->timer, req->timer_intv);
 	b_ptr->link_req = req;
-- 
1.7.9.5


------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
