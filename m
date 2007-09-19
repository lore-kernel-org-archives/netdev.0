From: ggrundstrom@neteffect.com
Subject: [ofa-general] [PATCH] RDMA/CMA: Implement rdma_resolve_ip retry
	enhancement.
Date: Tue, 18 Sep 2007 19:22:37 -0500
Message-ID: <200709190022.l8J0MbWt024754@neteffect.com>
Cc: , netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


RDMA/CMA: Implement rdma_resolve_ip retry enhancement.

If an application is calling rdma_resolve_ip() and a status of -ENODATA is returned from addr_resolve_local/remote(), the timeout mechanism waits until the application's timeout occurs before rechecking the address resolution status; the application will wait until it's full timeout occurs.  This case is seen when the work thread call to process_req() is made before the arp packet is processed.

This patch is in addition to Steve Wise's neigh_event_send patch to initiate neighbour discovery sent on 9/12/2007.

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---
 drivers/infiniband/core/addr.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index c5c33d3..a953780 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -55,6 +55,7 @@ struct addr_req {
 	int status;
 };
 
+#define MIN_ADDR_TIMEOUT_MS 500
 static void process_req(struct work_struct *work);
 
 static DEFINE_MUTEX(lock);
@@ -136,6 +137,7 @@ static void set_timeout(unsigned long ti
 static void queue_req(struct addr_req *req)
 {
 	struct addr_req *temp_req;
+	unsigned long req_timeout = msecs_to_jiffies(MIN_ADDR_TIMEOUT_MS) + jiffies;
 
 	mutex_lock(&lock);
 	list_for_each_entry_reverse(temp_req, &req_list, list) {
@@ -145,8 +147,10 @@ static void queue_req(struct addr_req *r
 
 	list_add(&req->list, &temp_req->list);
 
-	if (req_list.next == &req->list)
+	if (req_list.next == &req->list) {
+		req_timeout = min(req_timeout, req->timeout);
 		set_timeout(req->timeout);
+	}
 	mutex_unlock(&lock);
 }
 
@@ -220,6 +224,7 @@ static void process_req(struct work_stru
 	struct addr_req *req, *temp_req;
 	struct sockaddr_in *src_in, *dst_in;
 	struct list_head done_list;
+	unsigned long req_timeout;
 
 	INIT_LIST_HEAD(&done_list);
 
@@ -238,9 +243,11 @@ static void process_req(struct work_stru
 		list_move_tail(&req->list, &done_list);
 	}
 
+	req_timeout = msecs_to_jiffies(MIN_ADDR_TIMEOUT_MS) + jiffies;
 	if (!list_empty(&req_list)) {
 		req = list_entry(req_list.next, struct addr_req, list);
-		set_timeout(req->timeout);
+		req_timeout = min(req_timeout, req->timeout);
+		set_timeout(req_timeout);
 	}
 	mutex_unlock(&lock);
 
