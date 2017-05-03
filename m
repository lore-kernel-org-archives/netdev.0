From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 03/15] netvsc: make sure napi enabled before vmbus_open
Date: Wed,  3 May 2017 16:01:05 -0700
Message-ID: <20170503230117.20070-4-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33770 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752037AbdECXBY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:24 -0400
Received: by mail-pg0-f52.google.com with SMTP id y4so1996499pge.0
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:24 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a race where vmbus callback for new packet arriving
could occur before NAPI is initialized.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c       | 8 +++++---
 drivers/net/hyperv/rndis_filter.c | 2 +-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 8108e119d8a5..385809512c9f 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1327,6 +1327,10 @@ int netvsc_device_add(struct hv_device *device,
 		nvchan->channel = device->channel;
 	}
 
+	/* Enable NAPI handler before init callbacks */
+	netif_napi_add(ndev, &net_device->chan_table[0].napi,
+		       netvsc_poll, NAPI_POLL_WEIGHT);
+
 	/* Open the channel */
 	ret = vmbus_open(device->channel, ring_size * PAGE_SIZE,
 			 ring_size * PAGE_SIZE, NULL, 0,
@@ -1334,6 +1338,7 @@ int netvsc_device_add(struct hv_device *device,
 			 net_device->chan_table);
 
 	if (ret != 0) {
+		netif_napi_del(&net_device->chan_table[0].napi);
 		netdev_err(ndev, "unable to open channel: %d\n", ret);
 		goto cleanup;
 	}
@@ -1341,9 +1346,6 @@ int netvsc_device_add(struct hv_device *device,
 	/* Channel is opened */
 	netdev_dbg(ndev, "hv_netvsc channel opened successfully\n");
 
-	/* Enable NAPI handler for init callbacks */
-	netif_napi_add(ndev, &net_device->chan_table[0].napi,
-		       netvsc_poll, NAPI_POLL_WEIGHT);
 	napi_enable(&net_device->chan_table[0].napi);
 
 	/* Writing nvdev pointer unlocks netvsc_send(), make sure chn_table is
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index ab92c3c95951..f9d5b0b8209a 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1018,7 +1018,7 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 	if (ret == 0)
 		napi_enable(&nvchan->napi);
 	else
-		netdev_err(ndev, "sub channel open failed (%d)\n", ret);
+		netif_napi_del(&nvchan->napi);
 
 	if (refcount_dec_and_test(&nvscdev->sc_offered))
 		complete(&nvscdev->channel_init_wait);
-- 
2.11.0
