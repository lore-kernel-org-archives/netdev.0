From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 6/9] netvsc: use refcount_t for keeping track of sub channels
Date: Wed, 22 Mar 2017 14:51:02 -0700
Message-ID: <20170322215105.1059-7-sthemmin@microsoft.com>
References: <20170322215105.1059-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35763 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751456AbdCVVvV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:51:21 -0400
Received: by mail-pf0-f169.google.com with SMTP id 20so48963439pfk.2
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 14:51:20 -0700 (PDT)
In-Reply-To: <20170322215105.1059-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than a lock and variable, use a refcount_t to keep track
of the number of sub channels.  Don't need to wait for subchannels
on device removal since wait was already done in device_add.

Also fix the error handling; don't wait forever in case of
an error on request to create sub channels.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |  4 ++--
 drivers/net/hyperv/rndis_filter.c | 41 ++++++++++-----------------------------
 2 files changed, 12 insertions(+), 33 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 907f55960ba8..4747ad48b3cc 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -761,8 +761,8 @@ struct netvsc_device {
 
 	u32 max_chn;
 	u32 num_chn;
-	spinlock_t sc_lock; /* Protects num_sc_offered variable */
-	u32 num_sc_offered;
+
+	refcount_t sc_offered;
 
 	/* Holds rndis device info */
 	void *extension;
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index d193d549cec6..3bd5447277ad 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -997,7 +997,6 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 	struct netvsc_device *nvscdev = net_device_to_netvsc_device(ndev);
 	u16 chn_index = new_sc->offermsg.offer.sub_channel_index;
 	struct netvsc_channel *nvchan;
-	unsigned long flags;
 	int ret;
 
 	if (chn_index >= nvscdev->num_chn)
@@ -1019,10 +1018,7 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 
 	napi_enable(&nvchan->napi);
 
-	spin_lock_irqsave(&nvscdev->sc_lock, flags);
-	nvscdev->num_sc_offered--;
-	spin_unlock_irqrestore(&nvscdev->sc_lock, flags);
-	if (nvscdev->num_sc_offered == 0)
+	if (refcount_dec_and_test(&nvscdev->sc_offered))
 		complete(&nvscdev->channel_init_wait);
 }
 
@@ -1039,12 +1035,9 @@ int rndis_filter_device_add(struct hv_device *dev,
 	struct ndis_recv_scale_cap rsscap;
 	u32 rsscap_size = sizeof(struct ndis_recv_scale_cap);
 	unsigned int gso_max_size = GSO_MAX_SIZE;
-	u32 mtu, size;
-	u32 num_rss_qs;
-	u32 sc_delta;
+	u32 mtu, size, num_rss_qs;
 	const struct cpumask *node_cpu_mask;
 	u32 num_possible_rss_qs;
-	unsigned long flags;
 	int i, ret;
 
 	rndis_device = get_rndis_device();
@@ -1067,7 +1060,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 	net_device->max_chn = 1;
 	net_device->num_chn = 1;
 
-	spin_lock_init(&net_device->sc_lock);
+	refcount_set(&net_device->sc_offered, 0);
 
 	net_device->extension = rndis_device;
 	rndis_device->ndev = net;
@@ -1204,6 +1197,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 	if (num_rss_qs == 0)
 		return 0;
 
+	refcount_set(&net_device->sc_offered, num_rss_qs);
 	vmbus_set_sc_create_callback(dev->channel, netvsc_sc_open);
 
 	init_packet = &net_device->channel_init_pkt;
@@ -1219,32 +1213,23 @@ int rndis_filter_device_add(struct hv_device *dev,
 			       VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
 	if (ret)
 		goto out;
-	wait_for_completion(&net_device->channel_init_wait);
 
-	if (init_packet->msg.v5_msg.subchn_comp.status !=
-	    NVSP_STAT_SUCCESS) {
+	if (init_packet->msg.v5_msg.subchn_comp.status != NVSP_STAT_SUCCESS) {
 		ret = -ENODEV;
 		goto out;
 	}
+	wait_for_completion(&net_device->channel_init_wait);
+
 	net_device->num_chn = 1 +
 		init_packet->msg.v5_msg.subchn_comp.num_subchannels;
 
-	ret = rndis_filter_set_rss_param(rndis_device, netvsc_hash_key,
-					 net_device->num_chn);
-
-	/*
-	 * Set the number of sub-channels to be received.
-	 */
-	spin_lock_irqsave(&net_device->sc_lock, flags);
-	sc_delta = num_rss_qs - (net_device->num_chn - 1);
-	net_device->num_sc_offered -= sc_delta;
-	spin_unlock_irqrestore(&net_device->sc_lock, flags);
-
+	/* ignore failues from setting rss parameters, still have channels */
+	rndis_filter_set_rss_param(rndis_device, netvsc_hash_key,
+				   net_device->num_chn);
 out:
 	if (ret) {
 		net_device->max_chn = 1;
 		net_device->num_chn = 1;
-		net_device->num_sc_offered = 0;
 	}
 
 	return 0; /* return 0 because primary channel can be used alone */
@@ -1259,12 +1244,6 @@ void rndis_filter_device_remove(struct hv_device *dev,
 {
 	struct rndis_device *rndis_dev = net_dev->extension;
 
-	/* If not all subchannel offers are complete, wait for them until
-	 * completion to avoid race.
-	 */
-	if (net_dev->num_sc_offered > 0)
-		wait_for_completion(&net_dev->channel_init_wait);
-
 	/* Halt and release the rndis device */
 	rndis_filter_halt_device(rndis_dev);
 
-- 
2.11.0
