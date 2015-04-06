From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,
 3/3] hv_netvsc: Fix the packet free when it is in skb headroom
Date: Mon,  6 Apr 2015 15:22:54 -0700
Message-ID: <1428358974-7958-3-git-send-email-haiyangz@microsoft.com>
References: <1428358974-7958-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1428358974-7958-1-git-send-email-haiyangz@microsoft.com>
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

In the two places changed, we now use netvsc_xmit_completion() which properly
frees hv_netvsc_packet in or not in skb headroom.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    1 +
 drivers/net/hyperv/netvsc.c     |    6 ++++--
 drivers/net/hyperv/netvsc_drv.c |    2 +-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 80bc52e..f0b8b3e 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -188,6 +188,7 @@ int netvsc_send(struct hv_device *device,
 		struct hv_netvsc_packet *packet);
 void netvsc_linkstatus_callback(struct hv_device *device_obj,
 				struct rndis_message *resp);
+void netvsc_xmit_completion(void *context);
 int netvsc_recv_callback(struct hv_device *device_obj,
 			struct hv_netvsc_packet *packet,
 			struct ndis_tcp_ip_checksum_info *csum_info);
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 7e83c6a..4d4d497 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -878,7 +878,9 @@ int netvsc_send(struct hv_device *device,
 		packet->send_buf_index = section_index;
 		packet->total_data_buflen += msd_len;
 
-		kfree(msdp->pkt);
+		if (msdp->pkt)
+			netvsc_xmit_completion(msdp->pkt);
+
 		if (packet->xmit_more) {
 			msdp->pkt = packet;
 			msdp->count++;
@@ -902,7 +904,7 @@ int netvsc_send(struct hv_device *device,
 		if (m_ret != 0) {
 			netvsc_free_send_slot(net_device,
 					      msd_send->send_buf_index);
-			kfree(msd_send);
+			netvsc_xmit_completion(msd_send);
 		}
 	}
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 73f8fba..e5fa094 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -229,7 +229,7 @@ static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 	return q_idx;
 }
 
-static void netvsc_xmit_completion(void *context)
+void netvsc_xmit_completion(void *context)
 {
 	struct hv_netvsc_packet *packet = (struct hv_netvsc_packet *)context;
 	struct sk_buff *skb = (struct sk_buff *)
-- 
1.7.4.1
