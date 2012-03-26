From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 1/1] net/hyperv: Add flow control based on hi/low watermark
Date: Mon, 26 Mar 2012 15:18:24 -0700
Message-ID: <1332800304-5060-2-git-send-email-haiyangz@microsoft.com>
References: <1332800304-5060-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332800304-5060-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the existing code, we only stop queue when the ringbuffer is full,
so the current packet has to be dropped or retried from upper layer.

This patch stops the tx queue when available ringbuffer is below
the low watermark. So the ringbuffer still has small amount of space
available for the current packet. This will reduce the overhead of
retries on sending.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/hv/ring_buffer.c        |   15 +++++++++++++++
 drivers/net/hyperv/hyperv_net.h |    3 +++
 drivers/net/hyperv/netvsc.c     |   23 +++++++++++++++++++----
 drivers/net/hyperv/netvsc_drv.c |   16 +++++++++++++++-
 include/linux/hyperv.h          |    3 +++
 5 files changed, 55 insertions(+), 5 deletions(-)

diff --git a/drivers/hv/ring_buffer.c b/drivers/hv/ring_buffer.c
index 8af25a0..8cc3f63 100644
--- a/drivers/hv/ring_buffer.c
+++ b/drivers/hv/ring_buffer.c
@@ -23,6 +23,7 @@
  */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/hyperv.h>
@@ -160,6 +161,20 @@ hv_get_ring_buffersize(struct hv_ring_buffer_info *ring_info)
 }
 
 /*
+ * Get the percentage of available bytes to write in the ring.
+ * The return value is in range from 0 to 100.
+ */
+u32 hv_ringbuf_avail_percent(struct hv_ring_buffer_info *ring_info)
+{
+	u32 avail_read, avail_write;
+
+	hv_get_ringbuffer_availbytes(ring_info, &avail_read, &avail_write);
+
+	return avail_write * 100 / hv_get_ring_buffersize(ring_info);
+}
+EXPORT_SYMBOL(hv_ringbuf_avail_percent);
+
+/*
  *
  * hv_get_ring_bufferindices()
  *
diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index c358245..cd234cd 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -470,6 +470,9 @@ struct nvsp_message {
 
 #define NETVSC_PACKET_SIZE                      2048
 
+extern uint ring_avail_percent_hiwater;
+extern uint ring_avail_percent_lowater;
+
 /* Per netvsc channel-specific */
 struct netvsc_device {
 	struct hv_device *dev;
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index d025c83..fbf4f18 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -455,6 +455,8 @@ static void netvsc_send_completion(struct hv_device *device,
 		complete(&net_device->channel_init_wait);
 	} else if (nvsp_packet->hdr.msg_type ==
 		   NVSP_MSG1_TYPE_SEND_RNDIS_PKT_COMPLETE) {
+		int num_outstanding_sends;
+
 		/* Get the send context */
 		nvsc_packet = (struct hv_netvsc_packet *)(unsigned long)
 			packet->trans_id;
@@ -463,10 +465,14 @@ static void netvsc_send_completion(struct hv_device *device,
 		nvsc_packet->completion.send.send_completion(
 			nvsc_packet->completion.send.send_completion_ctx);
 
-		atomic_dec(&net_device->num_outstanding_sends);
+		num_outstanding_sends =
+			atomic_dec_return(&net_device->num_outstanding_sends);
 
-		if (netif_queue_stopped(ndev) && !net_device->start_remove)
-			netif_wake_queue(ndev);
+		if (netif_queue_stopped(ndev) && !net_device->start_remove &&
+			(hv_ringbuf_avail_percent(&device->channel->outbound)
+			> ring_avail_percent_hiwater ||
+			num_outstanding_sends < 1))
+				netif_wake_queue(ndev);
 	} else {
 		netdev_err(ndev, "Unknown send completion packet type- "
 			   "%d received!!\n", nvsp_packet->hdr.msg_type);
@@ -519,10 +525,19 @@ int netvsc_send(struct hv_device *device,
 
 	if (ret == 0) {
 		atomic_inc(&net_device->num_outstanding_sends);
+		if (hv_ringbuf_avail_percent(&device->channel->outbound) <
+			ring_avail_percent_lowater) {
+			netif_stop_queue(ndev);
+			if (atomic_read(&net_device->
+				num_outstanding_sends) < 1)
+				netif_wake_queue(ndev);
+		}
 	} else if (ret == -EAGAIN) {
 		netif_stop_queue(ndev);
-		if (atomic_read(&net_device->num_outstanding_sends) < 1)
+		if (atomic_read(&net_device->num_outstanding_sends) < 1) {
 			netif_wake_queue(ndev);
+			ret = -ENOSPC;
+		}
 	} else {
 		netdev_err(ndev, "Unable to send packet %p ret %d\n",
 			   packet, ret);
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index dd29478..f13887c 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -51,6 +51,16 @@ static int ring_size = 128;
 module_param(ring_size, int, S_IRUGO);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
 
+uint ring_avail_percent_hiwater = 20;
+module_param(ring_avail_percent_hiwater, uint, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(ring_avail_percent_hiwater,
+	"Ring buffer available percentiles to wake up xmit queue");
+
+uint ring_avail_percent_lowater = 10;
+module_param(ring_avail_percent_lowater, uint, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(ring_avail_percent_lowater,
+	"Ring buffer available percentiles to stop xmit queue");
+
 struct set_multicast_work {
 	struct work_struct work;
 	struct net_device *net;
@@ -224,9 +234,13 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 		net->stats.tx_packets++;
 	} else {
 		kfree(packet);
+		if (ret != -EAGAIN) {
+			dev_kfree_skb_any(skb);
+			net->stats.tx_dropped++;
+		}
 	}
 
-	return ret ? NETDEV_TX_BUSY : NETDEV_TX_OK;
+	return (ret == -EAGAIN) ? NETDEV_TX_BUSY : NETDEV_TX_OK;
 }
 
 /*
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index 5852545..e8e4c31 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -274,6 +274,9 @@ struct hv_ring_buffer_debug_info {
 	u32 bytes_avail_towrite;
 };
 
+extern u32 hv_ringbuf_avail_percent(struct hv_ring_buffer_info *ring_info);
+
+
 /*
  * We use the same version numbering for all Hyper-V modules.
  *
-- 
1.7.4.1
