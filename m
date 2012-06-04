From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH] net/hyperv: Use wait_event on outstanding sends during device removal
Date: Mon,  4 Jun 2012 09:42:38 -0700
Message-ID: <1338828158-3133-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the busy-waiting/udelay to wait_event on outstanding sends.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    1 +
 drivers/net/hyperv/netvsc.c     |   12 ++++++------
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 4ffcd57..2857ab0 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -478,6 +478,7 @@ struct netvsc_device {
 	u32 nvsp_version;
 
 	atomic_t num_outstanding_sends;
+	wait_queue_head_t wait_drain;
 	bool start_remove;
 	bool destroy;
 	/*
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 8b91947..0c56983 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -42,6 +42,7 @@ static struct netvsc_device *alloc_net_device(struct hv_device *device)
 	if (!net_device)
 		return NULL;
 
+	init_waitqueue_head(&net_device->wait_drain);
 	net_device->start_remove = false;
 	net_device->destroy = false;
 	net_device->dev = device;
@@ -387,12 +388,8 @@ int netvsc_device_remove(struct hv_device *device)
 	spin_unlock_irqrestore(&device->channel->inbound_lock, flags);
 
 	/* Wait for all send completions */
-	while (atomic_read(&net_device->num_outstanding_sends)) {
-		dev_info(&device->device,
-			"waiting for %d requests to complete...\n",
-			atomic_read(&net_device->num_outstanding_sends));
-		udelay(100);
-	}
+	wait_event(net_device->wait_drain,
+		   atomic_read(&net_device->num_outstanding_sends) == 0);
 
 	netvsc_disconnect_vsp(net_device);
 
@@ -486,6 +483,9 @@ static void netvsc_send_completion(struct hv_device *device,
 		num_outstanding_sends =
 			atomic_dec_return(&net_device->num_outstanding_sends);
 
+		if (net_device->destroy && num_outstanding_sends == 0)
+			wake_up(&net_device->wait_drain);
+
 		if (netif_queue_stopped(ndev) && !net_device->start_remove &&
 			(hv_ringbuf_avail_percent(&device->channel->outbound)
 			> RING_AVAIL_PERCENT_HIWATER ||
-- 
1.7.4.1
