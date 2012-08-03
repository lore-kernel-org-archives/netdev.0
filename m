From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,1/1] hyperv: Move wait completion msg code into rndis_filter_halt_device()
Date: Fri,  3 Aug 2012 12:32:18 -0700
Message-ID: <1344022338-3010-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to wait for send_completion msg before put_rndis_request() at
the end of rndis_filter_halt_device(). Otherwise, netvsc_send_completion()
may reference freed memory which is overwritten, and cause panic.

Reported-by: Long Li <longli@microsoft.com>
Reported-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc.c       |    7 -------
 drivers/net/hyperv/rndis_filter.c |   11 +++++++++++
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 6cee291..4a1a5f5 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -383,13 +383,6 @@ int netvsc_device_remove(struct hv_device *device)
 	unsigned long flags;
 
 	net_device = hv_get_drvdata(device);
-	spin_lock_irqsave(&device->channel->inbound_lock, flags);
-	net_device->destroy = true;
-	spin_unlock_irqrestore(&device->channel->inbound_lock, flags);
-
-	/* Wait for all send completions */
-	wait_event(net_device->wait_drain,
-		   atomic_read(&net_device->num_outstanding_sends) == 0);
 
 	netvsc_disconnect_vsp(net_device);
 
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index e5d6146..1e88a10 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -718,6 +718,9 @@ static void rndis_filter_halt_device(struct rndis_device *dev)
 {
 	struct rndis_request *request;
 	struct rndis_halt_request *halt;
+	struct netvsc_device *nvdev = dev->net_dev;
+	struct hv_device *hdev = nvdev->dev;
+	ulong flags;
 
 	/* Attempt to do a rndis device halt */
 	request = get_rndis_request(dev, RNDIS_MSG_HALT,
@@ -735,6 +738,14 @@ static void rndis_filter_halt_device(struct rndis_device *dev)
 	dev->state = RNDIS_DEV_UNINITIALIZED;
 
 cleanup:
+	spin_lock_irqsave(&hdev->channel->inbound_lock, flags);
+	nvdev->destroy = true;
+	spin_unlock_irqrestore(&hdev->channel->inbound_lock, flags);
+
+	/* Wait for all send completions */
+	wait_event(nvdev->wait_drain,
+		atomic_read(&nvdev->num_outstanding_sends) == 0);
+
 	if (request)
 		put_rndis_request(dev, request);
 	return;
-- 
1.7.4.1
