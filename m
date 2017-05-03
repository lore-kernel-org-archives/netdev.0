From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 15/15] netvsc: use vzalloc_node for receive completion data
Date: Wed,  3 May 2017 16:01:17 -0700
Message-ID: <20170503230117.20070-16-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36072 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752707AbdECXBm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:42 -0400
Received: by mail-pf0-f182.google.com with SMTP id q66so1732175pfi.3
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:41 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put the receive completion ring on the NUMA node of the CPU
assigned to the channel.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |  3 +++
 drivers/net/hyperv/netvsc.c       | 30 +++++++++++++++++++++++-------
 drivers/net/hyperv/rndis_filter.c |  8 ++++----
 3 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index a4417100a040..779c77a1638b 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -668,6 +668,9 @@ static inline bool recv_complete_ring_empty(const struct multi_recv_comp *mrc)
 	return mrc->read == mrc->write;
 }
 
+int netvsc_recv_comp_alloc(const struct vmbus_channel *chan,
+			   struct multi_recv_comp *mrc, u32 recv_slots);
+
 struct netvsc_stats {
 	u64 packets;
 	u64 bytes;
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 2938f1a2b765..ee42aa56460c 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -61,19 +61,33 @@ void netvsc_switch_datapath(struct net_device *ndev, bool vf)
 			       VM_PKT_DATA_INBAND, 0);
 }
 
-static struct netvsc_device *alloc_net_device(u32 recvslot_max)
+int netvsc_recv_comp_alloc(const struct vmbus_channel *channel,
+			   struct multi_recv_comp *mrc, u32 recv_slots)
+{
+	int node = cpu_to_node(channel->target_cpu);
+	size_t size = recv_slots * sizeof(struct recv_comp_data);
+
+	mrc->ring = vzalloc_node(size, node);
+	if (!mrc->ring)
+		mrc->ring = vzalloc(size);
+	if (!mrc->ring)
+		return -ENOMEM;
+
+	mrc->size = recv_slots;
+	return 0;
+}
+
+static struct netvsc_device *alloc_net_device(const struct vmbus_channel *chan,
+					      u32 recvslot_max)
 {
 	struct netvsc_device *net_device;
-	struct multi_recv_comp *mrc;
 
 	net_device = kzalloc(sizeof(struct netvsc_device), GFP_KERNEL);
 	if (!net_device)
 		return NULL;
 
-	mrc = &net_device->chan_table[0].mrc;
-	mrc->size = recvslot_max;
-	mrc->ring = vzalloc(recvslot_max * sizeof(struct recv_comp_data));
-	if (!mrc->ring) {
+	if (netvsc_recv_comp_alloc(chan, &net_device->chan_table[0].mrc,
+				   recvslot_max) != 0) {
 		kfree(net_device);
 		return NULL;
 	}
@@ -1246,7 +1260,9 @@ int netvsc_device_add(struct hv_device *device,
 	struct net_device *ndev = hv_get_drvdata(device);
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 
-	net_device = alloc_net_device(device_info->recv_buf_size / ETH_DATA_LEN + 1);
+	net_device = alloc_net_device(device->channel,
+				      device_info->recv_buf_size
+				      / ETH_DATA_LEN + 1);
 	if (!net_device)
 		return -ENOMEM;
 
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 1b8ce9bc0ce7..da4992b26397 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -996,10 +996,10 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 		return;
 
 	nvchan = nvscdev->chan_table + chn_index;
-	nvchan->mrc.size = nvscdev->recv_buf_size / ETH_DATA_LEN + 1;
-	nvchan->mrc.ring = vzalloc(nvchan->mrc.size
-				   * sizeof(struct recv_comp_data));
-	if (!nvchan->mrc.ring)
+	ret = netvsc_recv_comp_alloc(new_sc,
+				     &nvchan->mrc,
+				     nvscdev->recv_buf_size / ETH_DATA_LEN + 1);
+	if (ret)
 		return;
 
 	/* Because the device uses NAPI, all the interrupt batching and
-- 
2.11.0
