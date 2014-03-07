From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv4 net-next 18/32] iw_cxgb4: fix possible memory leak in RX_PKT processing
Date: Fri,  7 Mar 2014 16:03:15 +0530
Message-ID: <1394188409-9739-19-git-send-email-hariprasad@chelsio.com>
References: <1394188409-9739-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, santosh@chelsio.com,
	dm@chelsio.com, kumaras@chelsio.com, swise@opengridcomputing.com,
	leedom@chelsio.com, nirranjan@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25014 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752285AbaCGKml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 05:42:41 -0500
In-Reply-To: <1394188409-9739-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

If cxgb4_ofld_send() returns < 0, then send_fw_pass_open_req() must
free the request skb and the saved skb with the tcp header.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 899be48..5e9e258 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -3204,6 +3204,7 @@ static void send_fw_pass_open_req(struct c4iw_dev *dev, struct sk_buff *skb,
 	struct sk_buff *req_skb;
 	struct fw_ofld_connection_wr *req;
 	struct cpl_pass_accept_req *cpl = cplhdr(skb);
+	int ret;
 
 	req_skb = alloc_skb(sizeof(struct fw_ofld_connection_wr), GFP_KERNEL);
 	req = (struct fw_ofld_connection_wr *)__skb_put(req_skb, sizeof(*req));
@@ -3240,7 +3241,13 @@ static void send_fw_pass_open_req(struct c4iw_dev *dev, struct sk_buff *skb,
 	req->cookie = (unsigned long)skb;
 
 	set_wr_txq(req_skb, CPL_PRIORITY_CONTROL, port_id);
-	cxgb4_ofld_send(dev->rdev.lldi.ports[0], req_skb);
+	ret = cxgb4_ofld_send(dev->rdev.lldi.ports[0], req_skb);
+	if (ret < 0) {
+		pr_err("%s - cxgb4_ofld_send error %d - dropping\n", __func__,
+		       ret);
+		kfree_skb(skb);
+		kfree_skb(req_skb);
+	}
 }
 
 /*
-- 
1.8.4
