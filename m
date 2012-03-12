From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 1/2] net/hyperv: Fix data corruption in rndis_filter_receive()
Date: Mon, 12 Mar 2012 13:20:49 -0700
Message-ID: <1331583650-29686-2-git-send-email-haiyangz@microsoft.com>
References: <1331583650-29686-1-git-send-email-haiyangz@microsoft.com>
To: haiyangz@microsoft.com, kys@microsoft.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331583650-29686-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Limiting the memcpy to be the sizeof(struct rndis_message) can truncate
the message if there are Per-Packet-Info or Out-of-Band data.

In my earlier patch (commit 45326342), the unnecessary kmap_atomic and
kunmap_atomic surrounding this memcpy have been removed because the memory
in the receive buffer is always mapped. This memcpy is not necessary
either. To fix the bug, I removed the memcpy.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/rndis_filter.c |   33 +++++++++------------------------
 1 files changed, 9 insertions(+), 24 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 136efd8..0c3d7d9 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -352,8 +352,7 @@ int rndis_filter_receive(struct hv_device *dev,
 {
 	struct netvsc_device *net_dev = hv_get_drvdata(dev);
 	struct rndis_device *rndis_dev;
-	struct rndis_message rndis_msg;
-	struct rndis_message *rndis_hdr;
+	struct rndis_message *rndis_msg;
 	struct net_device *ndev;
 
 	if (!net_dev)
@@ -375,46 +374,32 @@ int rndis_filter_receive(struct hv_device *dev,
 		return -ENODEV;
 	}
 
-	rndis_hdr = pkt->data;
-
-	/* Make sure we got a valid rndis message */
-	if ((rndis_hdr->ndis_msg_type != REMOTE_NDIS_PACKET_MSG) &&
-	    (rndis_hdr->msg_len > sizeof(struct rndis_message))) {
-		netdev_err(ndev, "incoming rndis message buffer overflow "
-			   "detected (got %u, max %zu)..marking it an error!\n",
-			   rndis_hdr->msg_len,
-			   sizeof(struct rndis_message));
-	}
+	rndis_msg = pkt->data;
 
-	memcpy(&rndis_msg, rndis_hdr,
-		(rndis_hdr->msg_len > sizeof(struct rndis_message)) ?
-			sizeof(struct rndis_message) :
-			rndis_hdr->msg_len);
+	dump_rndis_message(dev, rndis_msg);
 
-	dump_rndis_message(dev, &rndis_msg);
-
-	switch (rndis_msg.ndis_msg_type) {
+	switch (rndis_msg->ndis_msg_type) {
 	case REMOTE_NDIS_PACKET_MSG:
 		/* data msg */
-		rndis_filter_receive_data(rndis_dev, &rndis_msg, pkt);
+		rndis_filter_receive_data(rndis_dev, rndis_msg, pkt);
 		break;
 
 	case REMOTE_NDIS_INITIALIZE_CMPLT:
 	case REMOTE_NDIS_QUERY_CMPLT:
 	case REMOTE_NDIS_SET_CMPLT:
 		/* completion msgs */
-		rndis_filter_receive_response(rndis_dev, &rndis_msg);
+		rndis_filter_receive_response(rndis_dev, rndis_msg);
 		break;
 
 	case REMOTE_NDIS_INDICATE_STATUS_MSG:
 		/* notification msgs */
-		rndis_filter_receive_indicate_status(rndis_dev, &rndis_msg);
+		rndis_filter_receive_indicate_status(rndis_dev, rndis_msg);
 		break;
 	default:
 		netdev_err(ndev,
 			"unhandled rndis message (type %u len %u)\n",
-			   rndis_msg.ndis_msg_type,
-			   rndis_msg.msg_len);
+			   rndis_msg->ndis_msg_type,
+			   rndis_msg->msg_len);
 		break;
 	}
 
-- 
1.7.4.1
