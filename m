From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 14/18] netvsc: eliminate per-device outstanding send counter
Date: Tue, 24 Jan 2017 13:06:11 -0800
Message-ID: <20170124210615.18628-15-sthemmin@microsoft.com>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33886 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750843AbdAXVG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:06:59 -0500
Received: by mail-pg0-f44.google.com with SMTP id 14so57792548pgg.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:06:33 -0800 (PST)
In-Reply-To: <20170124210615.18628-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since now keep track of per-queue outstanding sends, we can avoid
one atomic update by removing no longer needed per-device atomic.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |  1 -
 drivers/net/hyperv/netvsc.c       | 44 ++++++++++++++-------------------------
 drivers/net/hyperv/rndis_filter.c | 21 ++++++++++++++++---
 3 files changed, 34 insertions(+), 32 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 757205c9cb93..fec365241f37 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -729,7 +729,6 @@ struct netvsc_channel {
 struct netvsc_device {
 	u32 nvsp_version;
 
-	atomic_t num_outstanding_sends;
 	wait_queue_head_t wait_drain;
 	bool destroy;
 
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 359e7ef7040b..bd055146f098 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -90,29 +90,23 @@ static void free_netvsc_device(struct netvsc_device *nvdev)
 	kfree(nvdev);
 }
 
-static struct netvsc_device *get_outbound_net_device(struct hv_device *device)
-{
-	struct netvsc_device *net_device = hv_device_to_netvsc_device(device);
 
-	if (net_device && net_device->destroy)
-		net_device = NULL;
+static inline bool netvsc_channel_idle(const struct netvsc_device *net_device,
+				       u16 q_idx)
+{
+	const struct netvsc_channel *nvchan = &net_device->chan_table[q_idx];
 
-	return net_device;
+	return atomic_read(&net_device->num_outstanding_recvs) == 0 &&
+		atomic_read(&nvchan->queue_sends) == 0;
 }
 
-static struct netvsc_device *get_inbound_net_device(struct hv_device *device)
+static struct netvsc_device *get_outbound_net_device(struct hv_device *device)
 {
 	struct netvsc_device *net_device = hv_device_to_netvsc_device(device);
 
-	if (!net_device)
-		goto get_in_err;
-
-	if (net_device->destroy &&
-	    atomic_read(&net_device->num_outstanding_sends) == 0 &&
-	    atomic_read(&net_device->num_outstanding_recvs) == 0)
+	if (net_device && net_device->destroy)
 		net_device = NULL;
 
-get_in_err:
 	return net_device;
 }
 
@@ -612,7 +606,6 @@ static void netvsc_send_tx_complete(struct netvsc_device *net_device,
 	struct net_device *ndev = hv_get_drvdata(device);
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 	struct vmbus_channel *channel = device->channel;
-	int num_outstanding_sends;
 	u16 q_idx = 0;
 	int queue_sends;
 
@@ -630,13 +623,10 @@ static void netvsc_send_tx_complete(struct netvsc_device *net_device,
 		dev_consume_skb_any(skb);
 	}
 
-	num_outstanding_sends =
-		atomic_dec_return(&net_device->num_outstanding_sends);
-
 	queue_sends =
 		atomic_dec_return(&net_device->chan_table[q_idx].queue_sends);
 
-	if (net_device->destroy && num_outstanding_sends == 0)
+	if (net_device->destroy && queue_sends == 0)
 		wake_up(&net_device->wait_drain);
 
 	if (netif_tx_queue_stopped(netdev_get_tx_queue(ndev, q_idx)) &&
@@ -823,15 +813,10 @@ static inline int netvsc_send_pkt(
 	}
 
 	if (ret == 0) {
-		atomic_inc(&net_device->num_outstanding_sends);
 		atomic_inc_return(&nvchan->queue_sends);
 
-		if (ring_avail < RING_AVAIL_PERCENT_LOWATER) {
+		if (ring_avail < RING_AVAIL_PERCENT_LOWATER)
 			netif_tx_stop_queue(txq);
-
-			if (atomic_read(&nvchan->queue_sends) < 1)
-				netif_tx_wake_queue(txq);
-		}
 	} else if (ret == -EAGAIN) {
 		netif_tx_stop_queue(txq);
 		if (atomic_read(&nvchan->queue_sends) < 1) {
@@ -1259,11 +1244,14 @@ void netvsc_channel_cb(void *context)
 	else
 		device = channel->device_obj;
 
-	net_device = get_inbound_net_device(device);
-	if (!net_device)
+	ndev = hv_get_drvdata(device);
+	if (unlikely(!ndev))
 		return;
 
-	ndev = hv_get_drvdata(device);
+	net_device = net_device_to_netvsc_device(ndev);
+	if (unlikely(net_device->destroy) &&
+	    netvsc_channel_idle(net_device, q_idx))
+		return;
 
 	while ((desc = get_next_pkt_raw(channel)) != NULL) {
 		netvsc_process_raw_pkt(device, channel, net_device,
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 70b099a731a9..19356f56b7b1 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -903,6 +903,23 @@ static int rndis_filter_init_device(struct rndis_device *dev)
 	return ret;
 }
 
+static bool netvsc_device_idle(const struct netvsc_device *nvdev)
+{
+	int i;
+
+	if (atomic_read(&nvdev->num_outstanding_recvs) > 0)
+		return false;
+
+	for (i = 0; i < nvdev->num_chn; i++) {
+		const struct netvsc_channel *nvchan = &nvdev->chan_table[i];
+
+		if (atomic_read(&nvchan->queue_sends) > 0)
+			return false;
+	}
+
+	return true;
+}
+
 static void rndis_filter_halt_device(struct rndis_device *dev)
 {
 	struct rndis_request *request;
@@ -933,9 +950,7 @@ static void rndis_filter_halt_device(struct rndis_device *dev)
 	spin_unlock_irqrestore(&hdev->channel->inbound_lock, flags);
 
 	/* Wait for all send completions */
-	wait_event(nvdev->wait_drain,
-		   atomic_read(&nvdev->num_outstanding_sends) == 0 &&
-		   atomic_read(&nvdev->num_outstanding_recvs) == 0);
+	wait_event(nvdev->wait_drain, netvsc_device_idle(nvdev));
 
 	if (request)
 		put_rndis_request(dev, request);
-- 
2.11.0
