From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V2 net-next 1/1] hv_netvsc: Wait for sub-channels to be
 processed during probe
Date: Wed, 22 Jul 2015 11:42:32 -0700
Message-ID: <1437590552-10211-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, vkuznets@redhat.com, decui@microsoft.com
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

The current code returns from probe without waiting for the proper handling
of subchannels that may be requested. If the netvsc driver were to be rapidly
loaded/unloaded, we can  trigger a panic as the unload will be tearing
down state that may not have been fully setup yet. We fix this issue by making
sure that we return from the probe call only after ensuring that the
sub-channel offers in flight are properly handled.

Reviewed-and-tested-by: Haiyang Zhang <haiyangz@microsoft.com
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
	V2: Introduce timed wait - Vitaly Kuznetsov <vkuznets@redhat.com>
	v2: Fix the sub-channel accounting - Dexuan Cui <decui@microsoft.com>

 drivers/net/hyperv/hyperv_net.h   |    2 ++
 drivers/net/hyperv/rndis_filter.c |   28 ++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 26cd14c..925b75d 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -671,6 +671,8 @@ struct netvsc_device {
 	u32 send_table[VRSS_SEND_TAB_SIZE];
 	u32 max_chn;
 	u32 num_chn;
+	spinlock_t sc_lock; /* Protects num_sc_offered variable */
+	u32 num_sc_offered;
 	atomic_t queue_sends[NR_CPUS];
 
 	/* Holds rndis device info */
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 2e40417..9b8263d 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -984,9 +984,16 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 	struct netvsc_device *nvscdev;
 	u16 chn_index = new_sc->offermsg.offer.sub_channel_index;
 	int ret;
+	unsigned long flags;
 
 	nvscdev = hv_get_drvdata(new_sc->primary_channel->device_obj);
 
+	spin_lock_irqsave(&nvscdev->sc_lock, flags);
+	nvscdev->num_sc_offered--;
+	spin_unlock_irqrestore(&nvscdev->sc_lock, flags);
+	if (nvscdev->num_sc_offered == 0)
+		complete(&nvscdev->channel_init_wait);
+
 	if (chn_index >= nvscdev->num_chn)
 		return;
 
@@ -1015,8 +1022,10 @@ int rndis_filter_device_add(struct hv_device *dev,
 	u32 rsscap_size = sizeof(struct ndis_recv_scale_cap);
 	u32 mtu, size;
 	u32 num_rss_qs;
+	u32 sc_delta;
 	const struct cpumask *node_cpu_mask;
 	u32 num_possible_rss_qs;
+	unsigned long flags;
 
 	rndis_device = get_rndis_device();
 	if (!rndis_device)
@@ -1039,6 +1048,8 @@ int rndis_filter_device_add(struct hv_device *dev,
 	net_device->max_chn = 1;
 	net_device->num_chn = 1;
 
+	spin_lock_init(&net_device->sc_lock);
+
 	net_device->extension = rndis_device;
 	rndis_device->net_dev = net_device;
 
@@ -1116,6 +1127,9 @@ int rndis_filter_device_add(struct hv_device *dev,
 	num_possible_rss_qs = cpumask_weight(node_cpu_mask);
 	net_device->num_chn = min(num_possible_rss_qs, num_rss_qs);
 
+	num_rss_qs = net_device->num_chn - 1;
+	net_device->num_sc_offered = num_rss_qs;
+
 	if (net_device->num_chn == 1)
 		goto out;
 
@@ -1157,11 +1171,25 @@ int rndis_filter_device_add(struct hv_device *dev,
 
 	ret = rndis_filter_set_rss_param(rndis_device, net_device->num_chn);
 
+	/*
+	 * Wait for the host to send us the sub-channel offers.
+	 */
+	spin_lock_irqsave(&net_device->sc_lock, flags);
+	sc_delta = num_rss_qs - (net_device->num_chn - 1);
+	net_device->num_sc_offered -= sc_delta;
+	spin_unlock_irqrestore(&net_device->sc_lock, flags);
+
+	while (net_device->num_sc_offered != 0) {
+		t = wait_for_completion_timeout(&net_device->channel_init_wait, 10*HZ);
+		if (t == 0)
+			WARN(1, "Netvsc: Waiting for sub-channel processing");
+	}
 out:
 	if (ret) {
 		net_device->max_chn = 1;
 		net_device->num_chn = 1;
 	}
+
 	return 0; /* return 0 because primary channel can be used alone */
 
 err_dev_remv:
-- 
1.7.4.1
