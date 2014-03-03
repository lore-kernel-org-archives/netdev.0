From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hyperv: Move state setting for link query
Date: Mon,  3 Mar 2014 15:54:35 -0800
Message-ID: <1393890875-1420-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

It moves the state setting for query into rndis_filter_receive_response().
All callbacks including query-complete and status-callback are synchronized
by channel->inbound_lock. This prevents pentential race between them.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/rndis_filter.c |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index f0cc8ef..6a9f602 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -240,6 +240,22 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 	return ret;
 }
 
+static void rndis_set_link_state(struct rndis_device *rdev,
+				 struct rndis_request *request)
+{
+	u32 link_status;
+	struct rndis_query_complete *query_complete;
+
+	query_complete = &request->response_msg.msg.query_complete;
+
+	if (query_complete->status == RNDIS_STATUS_SUCCESS &&
+	    query_complete->info_buflen == sizeof(u32)) {
+		memcpy(&link_status, (void *)((unsigned long)query_complete +
+		       query_complete->info_buf_offset), sizeof(u32));
+		rdev->link_state = link_status != 0;
+	}
+}
+
 static void rndis_filter_receive_response(struct rndis_device *dev,
 				       struct rndis_message *resp)
 {
@@ -269,6 +285,10 @@ static void rndis_filter_receive_response(struct rndis_device *dev,
 		    sizeof(struct rndis_message) + RNDIS_EXT_LEN) {
 			memcpy(&request->response_msg, resp,
 			       resp->msg_len);
+			if (request->request_msg.ndis_msg_type ==
+			    RNDIS_MSG_QUERY && request->request_msg.msg.
+			    query_req.oid == RNDIS_OID_GEN_MEDIA_CONNECT_STATUS)
+				rndis_set_link_state(dev, request);
 		} else {
 			netdev_err(ndev,
 				"rndis response buffer overflow "
@@ -617,7 +637,6 @@ static int rndis_filter_query_device_link_status(struct rndis_device *dev)
 	ret = rndis_filter_query_device(dev,
 				      RNDIS_OID_GEN_MEDIA_CONNECT_STATUS,
 				      &link_status, &size);
-	dev->link_state = (link_status != 0) ? true : false;
 
 	return ret;
 }
-- 
1.7.4.1
