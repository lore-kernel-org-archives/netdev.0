From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,6/6] hyperv: Add buffer for extended info after the RNDIS response message.
Date: Tue,  2 Oct 2012 08:30:24 -0700
Message-ID: <1349191824-14001-6-git-send-email-haiyangz@microsoft.com>
References: <1349191824-14001-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:46415
	"EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754225Ab2JBPLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 11:11:24 -0400
In-Reply-To: <1349191824-14001-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some response messages, there may be some extended info after the
message.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/rndis_filter.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index e7e12cf..928148c 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -32,16 +32,19 @@
 #include "hyperv_net.h"
 
 
+#define RNDIS_EXT_LEN 100
 struct rndis_request {
 	struct list_head list_ent;
 	struct completion  wait_event;
 
+	struct rndis_message response_msg;
 	/*
-	 * FIXME: We assumed a fixed size response here. If we do ever need to
-	 * handle a bigger response, we can either define a max response
-	 * message or add a response buffer variable above this field
+	 * The buffer for extended info after the RNDIS response message. It's
+	 * referenced based on the data offset in the RNDIS message. Its size
+	 * is enough for current needs, and should be sufficient for the near
+	 * future.
 	 */
-	struct rndis_message response_msg;
+	u8 response_ext[RNDIS_EXT_LEN];
 
 	/* Simplify allocation by having a netvsc packet inline */
 	struct hv_netvsc_packet	pkt;
@@ -50,12 +53,10 @@ struct rndis_request {
 
 	struct rndis_message request_msg;
 	/*
-	 * The buffer for the extended info after the RNDIS message. It's
-	 * referenced based on the data offset in the RNDIS message. Its size
-	 * is enough for current needs, and should be sufficient for the near
-	 * future.
+	 * The buffer for the extended info after the RNDIS request message.
+	 * It is referenced and sized in a similar way as response_ext.
 	 */
-	u8 ext[100];
+	u8 request_ext[RNDIS_EXT_LEN];
 };
 
 static void rndis_filter_send_completion(void *ctx);
@@ -274,7 +275,8 @@ static void rndis_filter_receive_response(struct rndis_device *dev,
 	spin_unlock_irqrestore(&dev->request_lock, flags);
 
 	if (found) {
-		if (resp->msg_len <= sizeof(struct rndis_message)) {
+		if (resp->msg_len <=
+		    sizeof(struct rndis_message) + RNDIS_EXT_LEN) {
 			memcpy(&request->response_msg, resp,
 			       resp->msg_len);
 		} else {
-- 
1.7.4.1
