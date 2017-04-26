From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] netvsc: make sure napi enabled before vmbus_open
Date: Wed, 26 Apr 2017 16:58:30 -0700
Message-ID: <20170426235830.14801-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33928 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937889AbdDZX6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:58:46 -0400
Received: by mail-pf0-f175.google.com with SMTP id c198so8715997pfc.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 16:58:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a race where vmbus callback for new packet arriving
could occur before NAPI is initialized. Happens more on WS2008
which takes longer to setup channel.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c       | 8 +++++---
 drivers/net/hyperv/rndis_filter.c | 4 +++-
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index f99651c03e0a..8150febb86d6 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1323,6 +1323,10 @@ int netvsc_device_add(struct hv_device *device,
 		nvchan->channel = device->channel;
 	}
 
+	/* Enable NAPI handler before init callbacks */
+	netif_napi_add(ndev, &net_device->chan_table[0].napi,
+		       netvsc_poll, NAPI_POLL_WEIGHT);
+
 	/* Open the channel */
 	ret = vmbus_open(device->channel, ring_size * PAGE_SIZE,
 			 ring_size * PAGE_SIZE, NULL, 0,
@@ -1330,6 +1334,7 @@ int netvsc_device_add(struct hv_device *device,
 			 net_device->chan_table);
 
 	if (ret != 0) {
+		netif_napi_del(&net_device->chan_table[0].napi);
 		netdev_err(ndev, "unable to open channel: %d\n", ret);
 		goto cleanup;
 	}
@@ -1337,9 +1342,6 @@ int netvsc_device_add(struct hv_device *device,
 	/* Channel is opened */
 	netdev_dbg(ndev, "hv_netvsc channel opened successfully\n");
 
-	/* Enable NAPI handler for init callbacks */
-	netif_napi_add(ndev, &net_device->chan_table[0].napi,
-		       netvsc_poll, NAPI_POLL_WEIGHT);
 	napi_enable(&net_device->chan_table[0].napi);
 
 	/* Writing nvdev pointer unlocks netvsc_send(), make sure chn_table is
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index ab92c3c95951..a9e9fb4bb9c5 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1017,8 +1017,10 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 			 netvsc_channel_cb, nvchan);
 	if (ret == 0)
 		napi_enable(&nvchan->napi);
-	else
+	else {
+		netif_napi_del(&nvchan->napi);
 		netdev_err(ndev, "sub channel open failed (%d)\n", ret);
+	}
 
 	if (refcount_dec_and_test(&nvscdev->sc_offered))
 		complete(&nvscdev->channel_init_wait);
-- 
2.11.0
