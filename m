From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 07/18] netvsc: allow get/set of RSS indirection table
Date: Tue, 24 Jan 2017 13:06:04 -0800
Message-ID: <20170124210615.18628-8-sthemmin@microsoft.com>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35322 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750827AbdAXVG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:06:59 -0500
Received: by mail-pg0-f41.google.com with SMTP id 194so57794325pgd.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:06:25 -0800 (PST)
In-Reply-To: <20170124210615.18628-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow setting receive indirection table. Also uses the system standard
for initialization.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |  1 +
 drivers/net/hyperv/netvsc_drv.c   | 26 +++++++++++++++++++++++---
 drivers/net/hyperv/rndis_filter.c |  9 +++++++--
 3 files changed, 31 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 5a652eb8a619..db11f7ab67a8 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -170,6 +170,7 @@ struct rndis_device {
 
 	u8 hw_mac_adr[ETH_ALEN];
 	u8 rss_key[NETVSC_HASH_KEYLEN];
+	u16 ind_table[ITAB_NUM];
 };
 
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index ead472150742..a09602e59cf5 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1035,7 +1035,7 @@ static u32 netvsc_get_rxfh_key_size(struct net_device *dev)
 
 static u32 netvsc_rss_indir_size(struct net_device *dev)
 {
-	return 0;
+	return ITAB_NUM;
 }
 
 static int netvsc_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
@@ -1044,10 +1044,16 @@ static int netvsc_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 	struct net_device_context *ndc = netdev_priv(dev);
 	struct netvsc_device *ndev = ndc->nvdev;
 	struct rndis_device *rndis_dev = ndev->extension;
+	int i;
 
 	if (hfunc)
 		*hfunc = ETH_RSS_HASH_TOP;	/* Toeplitz */
 
+	if (indir) {
+		for (i = 0; i < ITAB_NUM; i++)
+			indir[i] = rndis_dev->ind_table[i];
+	}
+
 	if (key)
 		memcpy(key, rndis_dev->rss_key, NETVSC_HASH_KEYLEN);
 
@@ -1060,12 +1066,26 @@ static int netvsc_set_rxfh(struct net_device *dev, const u32 *indir,
 	struct net_device_context *ndc = netdev_priv(dev);
 	struct netvsc_device *ndev = ndc->nvdev;
 	struct rndis_device *rndis_dev = ndev->extension;
+	int i;
 
 	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
 		return -EOPNOTSUPP;
 
-	if (!key || memcmp(key, rndis_dev->rss_key, NETVSC_HASH_KEYLEN) == 0)
-		return 0; /* no change */
+	if (indir) {
+		for (i = 0; i < ITAB_NUM; i++)
+			if (indir[i] >= dev->num_rx_queues)
+				return -EINVAL;
+
+		for (i = 0; i < ITAB_NUM; i++)
+			rndis_dev->ind_table[i] = indir[i];
+	}
+
+	if (!key) {
+		if (!indir)
+			return 0;
+
+		key = rndis_dev->rss_key;
+	}
 
 	return rndis_filter_set_rss_param(rndis_dev, key, ndev->num_chn);
 }
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index ac08aa1b089a..8d2b078403de 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -780,7 +780,7 @@ int rndis_filter_set_rss_param(struct rndis_device *rdev,
 	/* Set indirection table entries */
 	itab = (u32 *)(rssp + 1);
 	for (i = 0; i < ITAB_NUM; i++)
-		itab[i] = i % num_queue;
+		itab[i] = rdev->ind_table[i];
 
 	/* Set hask key values */
 	keyp = (u8 *)((unsigned long)rssp + rssp->kashkey_offset);
@@ -1035,7 +1035,6 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 int rndis_filter_device_add(struct hv_device *dev,
 			    void *additional_info)
 {
-	int ret;
 	struct net_device *net = hv_get_drvdata(dev);
 	struct net_device_context *net_device_ctx = netdev_priv(net);
 	struct netvsc_device *net_device;
@@ -1053,6 +1052,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 	const struct cpumask *node_cpu_mask;
 	u32 num_possible_rss_qs;
 	unsigned long flags;
+	int i, ret;
 
 	rndis_device = get_rndis_device();
 	if (!rndis_device)
@@ -1206,6 +1206,11 @@ int rndis_filter_device_add(struct hv_device *dev,
 		net_device->num_chn = min(num_possible_rss_qs, num_rss_qs);
 
 	num_rss_qs = net_device->num_chn - 1;
+
+	for (i = 0; i < ITAB_NUM; i++)
+		rndis_device->ind_table[i] = ethtool_rxfh_indir_default(i,
+							net_device->num_chn);
+
 	net_device->num_sc_offered = num_rss_qs;
 
 	if (net_device->num_chn == 1)
-- 
2.11.0
