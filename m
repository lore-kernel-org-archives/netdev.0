From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 13/15] netvsc: convert open count from atomic to refcount
Date: Wed,  3 May 2017 16:01:15 -0700
Message-ID: <20170503230117.20070-14-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33885 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752476AbdECXBk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:40 -0400
Received: by mail-pg0-f47.google.com with SMTP id v1so1977758pgv.1
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:39 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refcount provides wraparond protection.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   | 2 +-
 drivers/net/hyperv/netvsc.c       | 3 ++-
 drivers/net/hyperv/rndis_filter.c | 4 ++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 5627003bd8b6..29555317ca05 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -772,7 +772,7 @@ struct netvsc_device {
 
 	atomic_t num_outstanding_recvs;
 
-	atomic_t open_cnt;
+	refcount_t open_cnt;
 
 	struct netvsc_channel chan_table[VRSS_CHANNEL_MAX];
 
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 56e0721f703c..eb9f3e517fa5 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -80,7 +80,8 @@ static struct netvsc_device *alloc_net_device(u32 recvslot_max)
 
 	init_waitqueue_head(&net_device->wait_drain);
 	net_device->destroy = false;
-	atomic_set(&net_device->open_cnt, 0);
+
+	refcount_set(&net_device->open_cnt, 0);
 	net_device->max_pkt = RNDIS_MAX_PKT_DEFAULT;
 	net_device->pkt_align = RNDIS_PKT_ALIGN_DEFAULT;
 	init_completion(&net_device->channel_init_wait);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index bfeaa0549f7f..2a89bbd6e42b 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1259,7 +1259,7 @@ int rndis_filter_open(struct netvsc_device *nvdev)
 	if (!nvdev)
 		return -EINVAL;
 
-	if (atomic_inc_return(&nvdev->open_cnt) != 1)
+	if (refcount_inc_not_zero(&nvdev->open_cnt))
 		return 0;
 
 	return rndis_filter_open_device(nvdev->extension);
@@ -1270,7 +1270,7 @@ int rndis_filter_close(struct netvsc_device *nvdev)
 	if (!nvdev)
 		return -EINVAL;
 
-	if (atomic_dec_return(&nvdev->open_cnt) != 0)
+	if (refcount_dec_not_one(&nvdev->open_cnt))
 		return 0;
 
 	return rndis_filter_close_device(nvdev->extension);
-- 
2.11.0
