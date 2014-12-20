From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hyperv: Fix some variable name typos in send-buffer
 init/revoke
Date: Fri, 19 Dec 2014 18:25:18 -0800
Message-ID: <1419042318-7221-1-git-send-email-haiyangz@microsoft.com>
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
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The changed names are union fields with the same size, so the existing code
still works. But, we now update these variables to the correct names.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    1 +
 drivers/net/hyperv/netvsc.c     |   15 ++++++++-------
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 2f48f79..384ca4f 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -590,6 +590,7 @@ struct nvsp_message {
 
 
 #define NETVSC_RECEIVE_BUFFER_ID		0xcafe
+#define NETVSC_SEND_BUFFER_ID			0
 
 #define NETVSC_PACKET_SIZE                      4096
 
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index dd867e6..9f49c01 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -161,8 +161,8 @@ static int netvsc_destroy_buf(struct netvsc_device *net_device)
 
 	/* Deal with the send buffer we may have setup.
 	 * If we got a  send section size, it means we received a
-	 * SendsendBufferComplete msg (ie sent
-	 * NvspMessage1TypeSendReceiveBuffer msg) therefore, we need
+	 * NVSP_MSG1_TYPE_SEND_SEND_BUF_COMPLETE msg (ie sent
+	 * NVSP_MSG1_TYPE_SEND_SEND_BUF msg) therefore, we need
 	 * to send a revoke msg here
 	 */
 	if (net_device->send_section_size) {
@@ -172,7 +172,8 @@ static int netvsc_destroy_buf(struct netvsc_device *net_device)
 
 		revoke_packet->hdr.msg_type =
 			NVSP_MSG1_TYPE_REVOKE_SEND_BUF;
-		revoke_packet->msg.v1_msg.revoke_recv_buf.id = 0;
+		revoke_packet->msg.v1_msg.revoke_send_buf.id =
+			NETVSC_SEND_BUFFER_ID;
 
 		ret = vmbus_sendpacket(net_device->dev->channel,
 				       revoke_packet,
@@ -204,7 +205,7 @@ static int netvsc_destroy_buf(struct netvsc_device *net_device)
 		net_device->send_buf_gpadl_handle = 0;
 	}
 	if (net_device->send_buf) {
-		/* Free up the receive buffer */
+		/* Free up the send buffer */
 		vfree(net_device->send_buf);
 		net_device->send_buf = NULL;
 	}
@@ -339,9 +340,9 @@ static int netvsc_init_buf(struct hv_device *device)
 	init_packet = &net_device->channel_init_pkt;
 	memset(init_packet, 0, sizeof(struct nvsp_message));
 	init_packet->hdr.msg_type = NVSP_MSG1_TYPE_SEND_SEND_BUF;
-	init_packet->msg.v1_msg.send_recv_buf.gpadl_handle =
+	init_packet->msg.v1_msg.send_send_buf.gpadl_handle =
 		net_device->send_buf_gpadl_handle;
-	init_packet->msg.v1_msg.send_recv_buf.id = 0;
+	init_packet->msg.v1_msg.send_send_buf.id = NETVSC_SEND_BUFFER_ID;
 
 	/* Send the gpadl notification request */
 	ret = vmbus_sendpacket(device->channel, init_packet,
@@ -364,7 +365,7 @@ static int netvsc_init_buf(struct hv_device *device)
 		netdev_err(ndev, "Unable to complete send buffer "
 			   "initialization with NetVsp - status %d\n",
 			   init_packet->msg.v1_msg.
-			   send_recv_buf_complete.status);
+			   send_send_buf_complete.status);
 		ret = -EINVAL;
 		goto cleanup;
 	}
-- 
1.7.1
