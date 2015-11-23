From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 06/10] hv_netvsc: Eliminate send_completion from
 struct hv_netvsc_packet
Date: Mon, 23 Nov 2015 15:29:02 -0800
Message-ID: <1448321346-21357-6-git-send-email-kys@microsoft.com>
References: <1448321324-21318-1-git-send-email-kys@microsoft.com>
 <1448321346-21357-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1448321346-21357-1-git-send-email-kys@microsoft.com>
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

Eliminate send_completion from struct hv_netvsc_packet.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |    3 +--
 drivers/net/hyperv/netvsc.c       |    6 +++---
 drivers/net/hyperv/netvsc_drv.c   |    2 +-
 drivers/net/hyperv/rndis_filter.c |    2 +-
 4 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 506d552..9a3c972 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -135,7 +135,7 @@ struct hv_netvsc_packet {
 	u8 rmsg_size; /* RNDIS header and PPI size */
 	u8 rmsg_pgcnt; /* page count of RNDIS header and PPI */
 	u8 page_buf_cnt;
-	u8 pad0;
+	u8 completion_func;
 
 	u16 vlan_tci;
 	u16 q_idx;
@@ -147,7 +147,6 @@ struct hv_netvsc_packet {
 
 	u64 send_completion_tid;
 	void *send_completion_ctx;
-	void (*send_completion)(void *context);
 	struct hv_page_buffer *page_buf;
 };
 
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 8fbf816..34c16d1 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -653,8 +653,8 @@ static void netvsc_send_completion(struct netvsc_device *net_device,
 				netvsc_free_send_slot(net_device, send_index);
 			q_idx = nvsc_packet->q_idx;
 			channel = incoming_channel;
-			nvsc_packet->send_completion(nvsc_packet->
-						     send_completion_ctx);
+			netvsc_xmit_completion(nvsc_packet->
+					       send_completion_ctx);
 		}
 
 		num_outstanding_sends =
@@ -775,7 +775,7 @@ static inline int netvsc_send_pkt(
 		nvmsg.msg.v1_msg.send_rndis_pkt.send_buf_section_size =
 			packet->total_data_buflen;
 
-	if (packet->send_completion)
+	if (packet->completion_func)
 		req_id = (ulong)packet;
 	else
 		req_id = 0;
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index c73afb1..6d71a1e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -488,7 +488,7 @@ check_size:
 	memset(rndis_msg, 0, RNDIS_AND_PPI_SIZE);
 
 	/* Set the completion routine */
-	packet->send_completion = netvsc_xmit_completion;
+	packet->completion_func = 1;
 	packet->send_completion_ctx = packet;
 	packet->send_completion_tid = (unsigned long)skb;
 
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index be0fa9c..c8af172 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -237,7 +237,7 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 			packet->page_buf[0].len;
 	}
 
-	packet->send_completion = NULL;
+	packet->completion_func = 0;
 	packet->xmit_more = false;
 
 	ret = netvsc_send(dev->net_dev->dev, packet, NULL);
-- 
1.7.4.1
