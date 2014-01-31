From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 1/2] Drivers: net: hyperv: Get rid of the rndis_filter_packet
 structure
Date: Fri, 31 Jan 2014 08:25:16 -0800
Message-ID: <1391185517-5698-1-git-send-email-kys@microsoft.com>
References: <1391185478-5655-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1391185478-5655-1-git-send-email-kys@microsoft.com>
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

This structure is redundant; get rid of it make the code little more efficient -
get rid of the unnecessary indirection.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |    6 -----
 drivers/net/hyperv/netvsc_drv.c   |    2 +-
 drivers/net/hyperv/rndis_filter.c |   41 ++----------------------------------
 3 files changed, 4 insertions(+), 45 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 7b594ce..7645ba3 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -846,12 +846,6 @@ struct rndis_message {
 };
 
 
-struct rndis_filter_packet {
-	void *completion_ctx;
-	void (*completion)(void *context);
-	struct rndis_message msg;
-};
-
 /* Handy macros */
 
 /* get the size of an RNDIS message. Pass in the message type, */
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 7756118..1eadc13 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -146,7 +146,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	/* Allocate a netvsc packet based on # of frags. */
 	packet = kzalloc(sizeof(struct hv_netvsc_packet) +
 			 (num_pages * sizeof(struct hv_page_buffer)) +
-			 sizeof(struct rndis_filter_packet) +
+			 sizeof(struct rndis_message) +
 			 NDIS_VLAN_PPI_SIZE, GFP_ATOMIC);
 	if (!packet) {
 		/* out of memory, drop packet */
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 1084e5d..f0cc8ef 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -58,9 +58,6 @@ struct rndis_request {
 	u8 request_ext[RNDIS_EXT_LEN];
 };
 
-static void rndis_filter_send_completion(void *ctx);
-
-
 static struct rndis_device *get_rndis_device(void)
 {
 	struct rndis_device *device;
@@ -277,7 +274,7 @@ static void rndis_filter_receive_response(struct rndis_device *dev,
 				"rndis response buffer overflow "
 				"detected (size %u max %zu)\n",
 				resp->msg_len,
-				sizeof(struct rndis_filter_packet));
+				sizeof(struct rndis_message));
 
 			if (resp->ndis_msg_type ==
 			    RNDIS_MSG_RESET_C) {
@@ -898,17 +895,14 @@ int rndis_filter_close(struct hv_device *dev)
 int rndis_filter_send(struct hv_device *dev,
 			     struct hv_netvsc_packet *pkt)
 {
-	int ret;
-	struct rndis_filter_packet *filter_pkt;
 	struct rndis_message *rndis_msg;
 	struct rndis_packet *rndis_pkt;
 	u32 rndis_msg_size;
 	bool isvlan = pkt->vlan_tci & VLAN_TAG_PRESENT;
 
 	/* Add the rndis header */
-	filter_pkt = (struct rndis_filter_packet *)pkt->extension;
+	rndis_msg = (struct rndis_message *)pkt->extension;
 
-	rndis_msg = &filter_pkt->msg;
 	rndis_msg_size = RNDIS_MESSAGE_SIZE(struct rndis_packet);
 	if (isvlan)
 		rndis_msg_size += NDIS_VLAN_PPI_SIZE;
@@ -961,34 +955,5 @@ int rndis_filter_send(struct hv_device *dev,
 		pkt->page_buf[1].len = rndis_msg_size - pkt->page_buf[0].len;
 	}
 
-	/* Save the packet send completion and context */
-	filter_pkt->completion = pkt->completion.send.send_completion;
-	filter_pkt->completion_ctx =
-				pkt->completion.send.send_completion_ctx;
-
-	/* Use ours */
-	pkt->completion.send.send_completion = rndis_filter_send_completion;
-	pkt->completion.send.send_completion_ctx = filter_pkt;
-
-	ret = netvsc_send(dev, pkt);
-	if (ret != 0) {
-		/*
-		 * Reset the completion to originals to allow retries from
-		 * above
-		 */
-		pkt->completion.send.send_completion =
-				filter_pkt->completion;
-		pkt->completion.send.send_completion_ctx =
-				filter_pkt->completion_ctx;
-	}
-
-	return ret;
-}
-
-static void rndis_filter_send_completion(void *ctx)
-{
-	struct rndis_filter_packet *filter_pkt = ctx;
-
-	/* Pass it back to the original handler */
-	filter_pkt->completion(filter_pkt->completion_ctx);
+	return netvsc_send(dev, pkt);
 }
-- 
1.7.4.1
